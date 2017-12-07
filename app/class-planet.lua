local classPlanet = {}

classPlanet._planets = {}


function createPlanet(options)
	local name = options.name or "unknown"
	local vmId = options.id
	local index = math.random(1,3)

	-- optional parameters
	local raw = options.raw
	local os = options.os or ""
	local x = options.x
	local y = options.y
	local fromLeft = options.fromLeft or (math.random( 1,4 ) > 2)

print("OSSS=", os)

	-- finding the characteristics

	-- finding OS of the virtual machine
	local isWindows = os == "windows"
	local isLinux = os == "linux"
	local imageFilename = "computer-" .. os .. ".png"
	local pointsValue = isWindows and 10 or 5
	-- if string.find( imageName, "win" ) then
	-- 	isWindows = true
	-- 	imageFilename = imageFilename .. "windows.png"
	-- 	pointsValue = 10
	-- else
	-- 	isLinux = false
	-- 	imageFilename = imageFilename .. "linux.png"
	-- 	pointsValue = 5
	-- end



	-- local size = 3
	-- if string.find( imageName, "small" ) then
	-- 	size = 1
	-- elseif string.find( imageName, "medium" ) then
	-- 	size = 2
	-- end
	local size = _G.STORAGE.getVMSize(raw)
size = 3


	print("Creating Planet for VM with name '" ..tostring(name) .. "'")


	local scaleFactor = 1 * (size/3)

	local planet = display.newImage( "images/" .. imageFilename)
	planet.width = planet.width * scaleFactor
	planet.height = planet.height * scaleFactor

	planet.id = "planet"
	planet.vmName = name
	planet.vmId = vmId
	planet.fromLeft = fromLeft
	planet.isWindows = isWindows
	planet.isLinux = isLinux
	planet.size = size
	planet.pointsValue = pointsValue


	local initialX = SCREEN_W + planet.contentWidth + math.random(1,30)
	local impulse = - (0.01  + math.rad( 1,5 )/100)
	if fromLeft then
		initialX = - planet.contentWidth - math.random(1,30)
		impulse = - impulse
	end
	planet.x = initialX
	planet.y = SCREEN_H * math.random( 1,70 )/100


	-- overwriting position if manually set (used for when the planet is coming from a star)
	planet.x = x or planet.x
	planet.y = y or planet.y

	if IS_DEBUG then
		planet.x = CENTER_X
	end
	-- making sure it is not on top of the game header
	planet.y = math.max(planet.y, _G.MIN_Y + planet.contentHeight)

	planet.initialx = planet.x
	physics.addBody( planet, "dynamic", {radius = planet.contentWidth*0.5} )
    planet.isSensor = true;
    if not IS_DEBUG then
		planet:applyLinearImpulse( impulse*5, 0, planet.x, planet.y)
	end



	planet.showExplosion = function()
		local mEffects = require("module-effects")
    	planet._effect = mEffects.show("explosion", planet.x, planet.y, planet.contentWidth, planet.contentHeight)
	end

	planet.resize = function()
		if planet._isResizing then return end
		planet._isResizing = true

		API.decreaseVirtualMachineSize(planet.vmId, function()
			planet._isAlreadyHit = false
			planet._isResizing = false
		end)
	end

	planet.stopMotion = function()
		timer.performWithDelay(10, function()
		    planet:setLinearVelocity( 0, 0)
		end)
	end

	planet.resumeMotion = function()
		planet:applyLinearImpulse( impulse*5, 0, planet.x, planet.y)
	end

	planet.pause = function()
		if planet._isPausing then return end
		planet._isPausing = true
		local tId = transition.blink( planet, { time=4000 }  )
		API.pauseVirtualMachine(planet.vmId, function()
			planet._isAlreadyHit = false
			transition.cancel(tId)
			planet.alpha = 0.3
			planet.stopMotion()
			planet._imgPause = display.newImage("images/pause.png")
			local scaleF = (planet.contentHeight / planet._imgPause.contentHeight)*.5
			planet._imgPause:scale(scaleF, scaleF)
			planet._imgPause.x = planet.x
			planet._imgPause.y = planet.y
		end)
	end

	planet.unpause = function()
		print("on planet.resume")
		if planet._isResuming then return end
		planet._isResuming = true
		local tId = transition.blink( panet, { time=1000 }  )
		API.unpauseVirtualMachine(planet.vmId, function()
			planet._isAlreadyHit = false
			planet._isResuming = false
			planet._isPausing = false
			transition.cancel(tId)
			planet.alpha = 1
			display.remove(planet._imgPause)
			planet.resumeMotion()
		end)
	end

    planet.onCollision = function(laserType)
    	print("on planet.onCollision - ", laserType)

    	if planet._isAlreadyHit then return end
    	planet._isAlreadyHit = true

    	if laserType == "pause" then
    		planet.pause()
    		return
		elseif laserType == "start" then
			planet.unpause()
			return
    	elseif laserType == "destroy" then
    		planet.isVisible = false
    		planet.showExplosion()
	    	API.terminateVirtualMachine(planet.vmId,
	    		function()
	    			planet.destroy()
	    		end)
    	end


    end


    planet.destroy = function()
    	print("on planet.destroy - ", planet._effect)
    	if planet._effect then
    		planet._effect.stop()
    	end
    	display.remove(planet)
    	_G.GAME.increaseInstancesBy(-1)
    	_G.GAME.increasePointsBy(planet.pointsValue)
    end

    -- storing this planet
    classPlanet._planets[name] = planet



    planet.restart = function()
    	planet.x = planet.initialx
    end

    _G.GAME.increaseInstancesBy(1)

    --timer.performWithDelay(2000, function()planet.x = planet.initialx end, -1)

end

classPlanet.new = createPlanet



classPlanet.refreshPlanets = function()
	print("on refreshPlanets")
	local currPlanets = classPlanet._planets
	local planetsToCreate = {}
	local planetsToDestroy = {}

	local activeVMs = _G.STORAGE.getActiveVMs()

	-- finding the virtual machines that are NEW and thus we need to create planets for them
	for name, actvVM in pairs(activeVMs) do
		if currPlanets[name] == nil then
			planetsToCreate[name] = actvVM
		end
	end

	-- finding the virtual machines that does not exist anymore
	for name, planet in pairs(currPlanets) do
		if activeVMs[name] == nil and pausedVms[name] == nil then
			planetsToDestroy[name] = planet
		end
	end


	-- creating the planets for the new VMs
	for name, planet in pairs(planetsToCreate) do
		createPlanet({name=name, id=planet.id, os=planet.os })
		if IS_DEBUG then
			break
		end
	end

	-- removing the planets that shouldn't exist anymore
	for name, planet in pairs(planetsToDestroy) do
		planet:destroy()
	end

end

return classPlanet

-- for j=3,1,-1
-- do
-- createPlanet(j)
-- end