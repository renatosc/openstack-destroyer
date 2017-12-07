local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    local physics = require "physics"
    physics.start( )
    physics.setGravity(0,0)

    --physics.setDrawMode( "hybrid" )
    --physics.setDrawMode( "debug" )

    local background = display.newRect(sceneGroup, CENTER_X, CENTER_Y, SCREEN_W, SCREEN_H)
    --display.setDefault( "textureWrapX", "repeat" )
    --display.setDefault( "textureWrapY", "mirroredRepeat" )
    background.fill = {filename="images/background-blue.png", type="image"}
    background.fill.scaleX = 0.5
    background.fill.scaleY = 0.5


    ---------------------------------------------------
    -- HEADER (Points, Timer, Number of Machines)
    local function createGameStatus( ... )

        local margin = 10

        local group = display.newGroup()

        -- CENTER
        local lbTimer = display.newText{parent=group, text="1:00", x=CENTER_X, y=20, font=native.systemFont, fontSize=24 }
        lbTimer:setTextColor(1,1,1)


        -- RIGHT
        local lbNumOfInstancesValue = display.newText{parent=group, text="88", x=SCREEN_W, y=lbTimer.y, font=native.systemFont, fontSize=24 }
        lbNumOfInstancesValue:setTextColor(1,1,1)
        lbNumOfInstancesValue.anchorX = 0
        lbNumOfInstancesValue.x = SCREEN_W - lbNumOfInstancesValue.contentWidth - margin

        local lbNumOfInstances = display.newText{parent=group, text="Number of Instances:", x=lbNumOfInstancesValue.x - 4, y=lbTimer.y, font=native.systemFont, fontSize=24 }
        lbNumOfInstances:setTextColor(1,1,1)
        lbNumOfInstances.anchorX = 1


        -- LEFT
         local lbNumOfPoints = display.newText{parent=group, text="Points:", x=margin, y=lbTimer.y, font=native.systemFont, fontSize=24 }
        lbNumOfPoints:setTextColor(1,1,1)
        lbNumOfPoints.anchorX = 0

        local lbNumOfPointsValue = display.newText{parent=group, text="888", x=lbNumOfPoints.x + lbNumOfPoints.contentWidth + 4, y=lbTimer.y, font=native.systemFont, fontSize=24 }
        lbNumOfPointsValue:setTextColor(1,1,1)
        lbNumOfPointsValue.anchorX = 0



        -- BOTTOM RIGHT
        local cShip = require("class-ship")
        local dataLasers = LASER_TYPE
        local groupButtons = display.newGroup()
        local btLaserHandler = function(id, newStatus)
            cShip._laserSelectedId = id
            for i=1, groupButtons.numChildren do
                local g = groupButtons[i]
                if g.id ~= id then
                    g.deSelect()
                end
            end
        end
        local function createLaserGroup(id, name, imageColor, onHandler)
            local groupButton = display.newGroup()
            groupButton.id = id
            local colorSelected = {.4,.4,.4}
            local colorNotSelected = {.3,.3,.3,.3}

            local buttonW = 60
            local buttonH = 100
            local button = display.newRect(groupButton, buttonW*0.5, buttonH*.5, buttonW, buttonH)
            local function onTap()
                if button._selected then -- not allowing to deselect itself
                    return
                end
                local newStatus = not button._selected

                if newStatus then
                    button.fill = colorSelected
                else
                    button.fill = colorNotSelected
                end
                button._selected = button._selected
                if onHandler then
                    onHandler(id, newStatus)
                end
            end
            button:addEventListener( "tap", onTap)

            local img = display.newImage("images/laser-" .. imageColor .. ".png")
            groupButton:insert(img)
            img.x = button.x
            img.y = buttonH*0.4

            local lb = display.newText{parent=groupButton, text=name, x=button.x, y=buttonH*0.9 , font=native.systemFont, fontSize=16 }
            lb.anchorY = 1
            lb:setTextColor(1,1,1)

            groupButton.deSelect = function()
                button.fill = colorNotSelected
            end
            groupButton.select = onTap


            groupButton.deSelect()

            return groupButton
        end

        for id, v in pairs(dataLasers) do
            local b = createLaserGroup(id, v.name, v.filename,btLaserHandler)
            b.x = groupButtons.numChildren > 0 and groupButtons.contentWidth or 0
            groupButtons:insert(b)
            if id == "destroy" then
                b.select()
            end
        end
        groupButtons.x = SCREEN_W
        groupButtons._x = SCREEN_W - groupButtons.contentWidth
        groupButtons.y = SCREEN_H - groupButtons.contentHeight

        group.showLaserSelection = function()
            transition.to(groupButtons, {x = groupButtons._x, time=1000, transition=easing.inOutCubic})
        end


        group.startTimer = function(numOfPoints)
            group.isVisible = true
            local durationInMinutes = 1

            if group._timerID ~= nil then return end

            group._endTime = os.time() + durationInMinutes * 60

            group._timerID = timer.performWithDelay(800, function()


                local remainingTime = group._endTime - os.time()

                 if remainingTime <= 0 then
                    print("pairing time expired")
                    lbTimer.text = "0:00"

                    --_G.END_GAME()
                    return
                end

                                -- updating timer label
                local minutes = math.floor(remainingTime/60)
                local seconds = remainingTime - minutes*60
                lbTimer.text = string.format( "%d:%02d", minutes, seconds )

            end,-1)

        end

        group.stopTimer = function()
            if group._timerID then
                timer.cancel(group._timerID)
                group._timerID = nil
            end
        end

        group.increasePointsBy = function(numOfPoints)
            lbNumOfPointsValue.text = tonumber(lbNumOfPointsValue.text) + numOfPoints
        end

        group.increaseInstancesBy = function(qty)
            lbNumOfInstancesValue.text = tonumber(lbNumOfInstancesValue.text) + qty
        end


        group.reset = function()
            lbNumOfInstancesValue.text = "0"
            lbNumOfPointsValue.text = "0"

            group.stopTimer()
        end


        group.reset()

        group.isVisible = false

        _G.MIN_Y = group.contentHeight

        return group

    end
    _G.GAME = createGameStatus()









    ---------------------------------------------------
    -- Logo


    local logo = display.newImage(sceneGroup, "images/logo.png")
    logo.id = "logo"
    local scaleF = math.min(SCREEN_H*.7/logo.contentWidth , SCREEN_W*0.9/logo.contentHeight)
    logo.width = logo.width * scaleF
    logo.height = logo.height *scaleF
    logo.x = _G.CENTER_X
    logo.y = 40 + logo.contentHeight*.5
    sceneGroup:insert(logo)
    physics.addBody( logo, "dynamic", {isSensor=true} )
    logo.onCollision = function()
        display.remove(logo)
        sceneGroup.startGame()
    end
    sceneGroup.logo = logo
--logo.x = -4000








    local classPlanet = require("class-planet")



    -- for i=1,3 do
    --     classPlanet.new({name=i, id=i..os.time()})
    -- end
    --classPlanet.new({name=i, id=i, x=CENTER_X, y=CENTER_Y})



    sceneGroup.startGame = function()
        print("GAME STARTED! Good Luck!")

        sceneGroup.startRefreshing()
        require("class-star").start()

        _G.GAME.startTimer()

        _G.GAME.showLaserSelection()
    end




    ---------------------------------------------------
    -- SCENE BOUNDARIES


    local wallLeft = display.newRect( sceneGroup, 0,CENTER_Y,2,SCREEN_H)
    wallLeft.fill = {1,0,0,0}
    wallLeft.id="wallLeft"
    physics.addBody( wallLeft, "dynamic", {isSensor = true} )

    local wallRight = display.newRect( sceneGroup, SCREEN_W,CENTER_Y,2,SCREEN_H)
    wallRight.id="wallRight"
    wallRight.fill = {1,0,0,0}
    physics.addBody( wallRight, "dynamic", {isSensor = true} )

    local function onLocalCollision( self, event )

        if ( event.phase == "began" ) then
            print( tostring(self.id) .. ": collision began with " .. tostring(event.other.id ))
            return
        elseif ( event.phase == "ended" ) then
            print( tostring(self.myName) .. ": collision ended with " .. tostring(event.other.id ))
            if event.other.id == "planet" or event.other.id == "star" then
                if self.id == "wallLeft" and not event.other.fromLeft then
                    timer.performWithDelay(1000, function()
                        event.other.restart()
                    end)

                elseif self.id == "wallRight" and event.other.fromLeft then
                    timer.performWithDelay(1000, function()
                        event.other.restart()
                    end)
                end
            end

        end
    end

    wallLeft.collision = onLocalCollision
    wallLeft:addEventListener( "collision" )
    wallRight.collision = onLocalCollision
    wallRight:addEventListener( "collision" )







    ---------------------------------------------------
    -- GLOBAL COLLISION HANDLER

    local function onGlobalCollision( event )
        print("on onGlobalCollision")
        if ( event.phase == "began" ) then
            print( "began: " .. tostring(event.object1.id) .. " and " .. tostring(event.object2.id) )
            --print(event.object1.id, event.object2.id)
            -- if event.object1.id == "logo" or event.object2.id == "logo" then
            --     return
            -- end
            local o1, o2 = event.object1, event.object2

            if event.object1.id == "ship" and event.object2.id == "laser" then
                return
            end
            if event.object2.id == "ship" and event.object1.id == "laser" then
                return
            end
            if event.object1.id == event.object2.id then
                return
            end
            if event.object1.id == "wallLeft" or event.object1.id == "wallRight" or
                event.object2.id == "wallLeft" or event.object2.id == "wallRight" then
                -- we are handling wall collision locally
                return
            end
            if (event.object1.id == "star" and event.object1.id == "planet") or
                (event.object2.id == "star" and event.object2.id == "planet") then
                -- not allow collision between planet and stars
                return
            end

            -- allowing laser collisions with all objects (the ship is already removed from that above)
            if (o1.id== "laser" or o2.id == "laser") then
                if o1.onCollision then
                    o1.onCollision(o2.laserType)
                end
                if o2.onCollision then
                    o2.onCollision(o1.laserType)
                end
                return
            end


            -- allowing ship hit planet
            if (o1.id== "ship" or o2.id == "planet") or (o2.id== "ship" or o1.id == "planet") then
                o1.onCollision()
                o2.onCollision()
                return
            end




            print("event.object1.id, event.object2.id=", event.object1.id, event.object1.id)
            if event.object1.onCollision then
                print("Global Collision - going call collision obj1")
                event.object1.onCollision()
            end

            if event.object2.onCollision then
                print("Global Collision - going call collision obj2 - ")
                event.object2.onCollision()
            end

        elseif ( event.phase == "ended" ) then
          --  print( "ended: " .. event.object1.myName .. " and " .. event.object2.myName )
        end
    end

     Runtime:addEventListener( "collision", onGlobalCollision )




    ---------------------------------------------------
    -- REFRESH STATE

    sceneGroup.startRefreshing = function()
        if sceneGroup._refreshLoopId then return end
        sceneGroup._refreshLoopId = timer.performWithDelay(2000, function()
            print("going to get Virtual Machines...")
            API.getVirtualMachines(
                function(dataVMs) -- on success
                    classPlanet.refreshPlanets()
                end)
        end,IS_DEBUG and 1 or -1)
    end

    sceneGroup.stopRefreshing = function()
        if sceneGroup._refreshLoopId then
            timer.cancel(sceneGroup._refreshLoopId)
            sceneGroup._refreshLoopId = nil
        end
    end


    ---------------------------------------------------
    -- LOADING BASIC OPENSTACK INFO

    sceneGroup.loadOpenStackInfo = function()
        API.getImages()
        API.getFlavors()
        API.getNetworks()
    end

    sceneGroup.loadOpenStackInfo()

end



function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).


    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        local ship = require("class-ship").new()

        if _G.IS_DEBUG then
            ship.goToStartPosition(true)
            return
        end

        transition.from(sceneGroup.logo,{xScale=0.1, yScale=0.1, time=2000, transition=easing.outElastic, onComplete=function()

            ship.goToStartPosition()
        end})

    end

end



function scene:hide( event )
    print("on scene hide")
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.


    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.

    end
end



function scene:destroy( event )
    print("on scene destroy")
    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.


end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene