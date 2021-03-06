local classShip = {}

classShip._ship = nil


LASER_TYPE = {}
LASER_TYPE["destroy"] = {filename="red", name="Destroy", balance = 10}
LASER_TYPE["pause"] = {filename="blue", name="Pause", balance = 10}
LASER_TYPE["start"] = {filename="green", name="Unpause", balance = 10}
MAX_BALANCE = 20 -- max laser balance



classShip._laserSelectedId = nil

classShip.new = function()

	local group = display.newGroup()


    local ship = display.newImage(group, "images/ship-orange.png")
    ship.x = CENTER_X
    ship.y = SCREEN_H - ship.contentHeight

    physics.addBody( ship, "dynamic" )
    ship.id = "ship"

    group.shoot = function()
        print("on shoot")
        if _G.BALANCE_INCREASE_BY(0, classShip._laserSelectedId) == 0 then
            print("no more laser available")
            return
        end
        if _G.HAS_SHOT_FIRST_SHOOT then
            _G.BALANCE_INCREASE_BY(-1, classShip._laserSelectedId)
        end
        _G.HAS_SHOT_FIRST_SHOOT = true
        local laserFilename = LASER_TYPE[classShip._laserSelectedId].filename
        local laser = display.newImage("images/laser-" .. laserFilename ..".png")
        physics.addBody( laser, "dynamic" ,{radius=4, isSensor=true})
        -- local laser = display.newCircle()
        -- physics.addBody( laser, "dynamic" )
        laser.id = "laser"
        laser.laserType = classShip._laserSelectedId

        if ship then
            ship:toFront( )
        end
        laser.x = ship.x
        laser.y = ship.y
        laser.rotation = ship.rotation

        local force = 0.15
        local angle = (laser.rotation) -- * (360/100) -- (100 == total percange)
        local sin = math.sin(angle*math.pi/180)
        local cos = math.cos(angle*math.pi/180)
        local x = force*sin
        local y = - force*cos


        laser:applyLinearImpulse( x, y, laser.x, laser.y )
        media.playSound( "sounds/sfx_laser2.wav", system.ResourceDirectory )


        laser.onCollision = function()
            display.remove(laser)
        end

        -- local function onLocalCollision( self, event )
        --     print("laser collision!!")
        --     print( event.target )        --the first object in the collision
        --     print( event.other )         --the second object in the collision
        --     print( event.selfElement )   --the element (number) of the first object which was hit in the collision
        --     print( event.otherElement )  --the element (number) of the second object which was hit in the collision
        --     laser:removeEventListener( "collision" )
        --     timer.performWithDelay(30, function()
        --            display.remove(laser)
        --        end)
        -- end
        -- laser.collision = onLocalCollision
        -- laser:addEventListener( "collision" )



		-- local angle = (ship.rotation) * (360/100) -- (100 == total percange)
  --       local sin = math.sin(angle*math.pi/180)
  --       local cos = math.cos(angle*math.pi/180)
  --       local x = radius*sin*.5
  --       local y = radius*cos*.5





    end

    group.rotate = function(direction)
    	local delta = 10
    	--ship.rotation = ship.rotation + direction*delta
        if ship then
    	   ship:applyAngularImpulse( direction*delta )
        end
    end


    group.startRotation = function(direction)
    	group._rotationId = transition.to( ship, {rotation=ship.rotation+360*10, time=10*10, transition=easing.inOutQuad } )

    end
    group.stopRotation = function(direction)
    	if group._rotationId then
    		transition.cancel(group._rotationId)
    		group._rotationId = nil
    	end
    end

    group.move = function()
        if ship == nil then return end

    	local force = 0.15

    	local angle = (ship.rotation) -- * (360/100) -- (100 == total percange)
        if angle == nil then
            return
        end
        local sin = math.sin(angle*math.pi/180)
        local cos = math.cos(angle*math.pi/180)
        local x = force*sin
        local y = - force*cos
		print("angle=", angle, sin, cos)


    	ship:applyLinearImpulse( x, y, ship.x, ship.y)

    end

    ship.onCollision = function()
        print("on ship.onCollision")
        display.remove(ship)
        if ship._isAlreadyHit then return end

        ship._isAlreadyHit = true
        ship.showExplosion()

        _G.END_GAME()
    end


    ship.showExplosion = function()
        local mEffects = require("module-effects")
        ship._effect = mEffects.show("explosion", ship.x, ship.y, ship.contentWidth, ship.contentHeight)
    end


    ship.destroy = function()
        print("on planet.destroy - ", ship._effect)
        if ship._effect then
            ship._effect.stop()
        end
        display.remove(ship)
    end



    ship.x = -100
    group.goToStartPosition = function(skipAnimation)
        if skipAnimation then
            ship.x=CENTER_X
            ship.rotation=0
            return
        end
        ship.x = -100
        ship.rotation = 90
        transition.to(ship, {x=CENTER_X, time=3000, transition=easing.inOutQuad, onComplete=function()
            transition.to(ship, {rotation=0, time=1000, transition=easing.inOutQuad})
        end})
    end

    classShip._ship = group

    return group
end



local onKeyEvent = function( event )
    --print("running: aux, onKeyEvent - keyName:", event.keyName, " - keyPhase: ", event.phase)
    if event.phase == "down" then
    	if event.keyName == "space" then
    		classShip._ship.shoot()
    	elseif event.keyName == "left" then --or ("b" == event.keyName and system.getInfo("environment") == "simulator") then
    		classShip._ship.rotate(-1)
    	elseif event.keyName == "right" then
    		classShip._ship.rotate(1)
    	elseif event.keyName == "up" then
    		classShip._ship.move()
    	end


    end
end



Runtime:addEventListener( "key", onKeyEvent )




return classShip