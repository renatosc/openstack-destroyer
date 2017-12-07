local classPack = {}

classPack._pack = nil

local newPack = function()

    local rndon = math.random(1,3)
    local list = {}
    for k, _ in pairs(LASER_TYPE) do
        list[#list+1] = k
    end
    local laserType = list[rndon]
    ---print("laserType=", laserType)
	if classPack._pack then return end -- only 1 pack at a time

    local packFilename = LASER_TYPE[laserType].filename
	local pack = display.newImage("images/pill_"..packFilename ..".png")
	pack.name = "pack-".. os.time()
    pack.id = "pack"

	local fromLeft = (math.random( 1,4 ) > 2)
	pack.fromLeft = fromLeft


	local initialX = SCREEN_W + pack.contentWidth
	local impulse = - (0.01  + math.rad( 1,5 )/100)
	if fromLeft then
		initialX = - pack.contentWidth
		impulse = - impulse
	end
	pack.x = initialX
	pack.y = SCREEN_H * math.random( 1,70 )/100

    -- making sure it is not on top of the game header
    pack.y = math.max(pack.y, _G.MIN_Y + pack.contentHeight)

	pack._x = initialX

	physics.addBody( pack, "dynamic", {radius = pack.contentWidth*0.5, isSensor = true} )
	pack:applyLinearImpulse( impulse, 0, pack.x, pack.y)

--DEBUG VALUES
-- pack.x = CENTER_X
-- pack.y = CENTER_Y



    pack.onCollision = function()
    	display.remove(pack)
    	if pack._isAlreadyHit then return end
    	pack._isAlreadyHit = true

        _G.BALANCE_INCREASE_BY(10, laserType)
        pack.destroy()
    end


    pack.destroy = function()
    	display.remove(pack)
    	classPack._pack = nil
    	timer.performWithDelay(10, function()
    	    pack = nil
    	end)
    end

    pack.restart = function()
    	pack.x = pack._x
    end

    classPack._pack = pack

end


classPack.start = function()
	classPack._spawnLoopId = timer.performWithDelay(1000,   --1000 * math.random(1,10),
		function()
	    	newPack()
	end, -1)
end

return classPack