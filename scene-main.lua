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


    local background = display.newRect(sceneGroup, CENTER_X, CENTER_Y, SCREEN_W, SCREEN_H)

--display.setDefault( "textureWrapX", "repeat" )
--display.setDefault( "textureWrapY", "mirroredRepeat" )
    background.fill = {filename="images/background-blue.png", type="image"}
    background.fill.scaleX = 0.5
    background.fill.scaleY = 0.5


    ----------
    -- HEADER (Points, Timer, Number of Machines)
    local function createHeader( ... )

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
    _G.GAME = createHeader()

    ---




    local physics = require "physics"
    physics.start( )
    physics.setGravity(0,0)

--    physics.setDrawMode( "hybrid" )
--physics.setDrawMode( "debug" )

    local logo = display.newImage(sceneGroup, "images/logo.png")
    logo.id = "logo"
    local scaleF = math.min(SCREEN_H*.7/logo.contentWidth , SCREEN_W*0.9/logo.contentHeight)
    --logo:scale(scaleF, scaleF)

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

--logo.x = -4000


    local ship = require("class-ship").new()

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
    end


    -- sceneGroup.selectLevel = function(levelNumber)


    --     _G.SERVER.startVMs(
    --         function(dataVMs)

    --             for _, vm in ipairs(dataVMs) do
    --                 classPlanet.new(vm)
    --             end

    --         end,
    --         function()

    --         end)

    -- end


    local wallLeft = display.newRect( sceneGroup, 0,CENTER_Y,2,SCREEN_H)
    wallLeft.fill = {1,0,0}
    wallLeft.id="wallLeft"
    physics.addBody( wallLeft, "dynamic", {isSensor = true} )

    local wallRight = display.newRect( sceneGroup, SCREEN_W,CENTER_Y,2,SCREEN_H)
    wallRight.id="wallRight"
    wallRight.fill = {1,0,0}
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
        --print("on onGlobalCollision")
        if ( event.phase == "began" ) then
            --print( "began: " .. event.object1.id .. " and " .. event.object2.id )
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
                    o1.onCollision()
                end
                if o2.onCollision then
                    o2.onCollision()
                end
                return
            end


            -- allowing ship hit planet
            if (o1.id== "ship" or o2.id == "planet") or (o2.id== "ship" or o1.id == "planet") then
                print("calling c")
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






    -- local mEffects = require("module-effects")
    -- mEffects.show("explosion", CENTER_X, CENTER_Y, 50, 50)





    sceneGroup.startRefreshing = function()
        if sceneGroup._refreshLoopId then return end
        sceneGroup._refreshLoopId = timer.performWithDelay(2000, function()
            print("going to get Virtual Machines...")
            API.getVirtualMachines(
                function(dataVMs) -- on success
                    classPlanet.refreshPlanets()
                end)
        end, -1)
    end


    sceneGroup.stopRefreshing = function()
        if sceneGroup._refreshLoopId then
            timer.cancel(sceneGroup._refreshLoopId)
            sceneGroup._refreshLoopId = nil
        end
    end




    --classPlanet.new({name=1, id=os.time()})
    --sceneGroup.startGame()

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