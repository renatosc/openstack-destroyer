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


    local physics = require "physics"
    physics.start( )
    physics.setGravity(0,0)

--physics.setDrawMode( "hybrid" )
--physics.setDrawMode( "debug" )

    local logo = display.newImage(sceneGroup, "images/logo.png")
    logo.id = "logo"
    local scaleF = math.min(SCREEN_H*.7/logo.contentWidth , SCREEN_W*0.9/logo.contentHeight)
    --logo:scale(scaleF, scaleF)

    logo.width = logo.width * scaleF
    logo.height = logo.height *scaleF

    logo.x=_G.CENTER_X
    logo.y= 40 + logo.contentHeight*.5
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



    sceneGroup.startGame = function()
        print("GAME STARTED! Good Luck!")
        sceneGroup.startRefreshing()

        require("class-star").start()
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





    ---------------------------------------------------
    -- GLOBAL COLLISION HANDLER


    local function onGlobalCollision( event )
        --print("on onGlobalCollision")
        if ( event.phase == "began" ) then
            --print( "began: " .. event.object1.myName .. " and " .. event.object2.myName )
            --print(event.object1.id, event.object2.id)
            -- if event.object1.id == "logo" or event.object2.id == "logo" then
            --     return
            -- end

            if event.object1.id == "ship" and event.object2.id == "laser" then
                return
            end
            if event.object2.id == "ship" and event.object1.id == "laser" then
                return
            end
            if event.object1.id ==  event.object2.id then
                return
            end

            if event.object1.onCollision then
                event.object1.onCollision()
            end

            if event.object2.onCollision then
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