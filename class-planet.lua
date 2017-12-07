local classPlanet = {}

classPlanet._planets = {}


function createPlanet(options)
	local name = options.name or "unknown"
	local vmId = options.id
	local index = math.random(1,3)

	-- optional parameters
	local imageName = options.image or ""
	local x = options.x
	local y = options.y
	local fromLeft = options.fromLeft or (math.random( 1,4 ) > 2)



	-- finding the characteristics

	-- finding OS of the virtual machine
	local isWindows = false
	local isLinux = false
	local imageFilename = "computer-"
	-- local imageWidth = 789
	-- local imageHeight = 792
	local pointsValue = 0
	if string.find( imageName, "win" ) then
		isWindows = true
		imageFilename = imageFilename .. "windows.png"
		pointsValue = 10
	else
		isLinux = false
		imageFilename = imageFilename .. "linux.png"
		pointsValue = 5
	end



	local size = 3
	if string.find( imageName, "small" ) then
		size = 1
	elseif string.find( imageName, "medium" ) then
		size = 2
	end
size = math.random( 1,3 )
	print("Creating Planet for VM with name '" ..tostring(name) .. "'")

	-- local planetData = {}
	-- planetData[1] = { y= math.random(1,4)/4,  imageWidth=50, imageHeight=50 }
	-- planetData[2] = { y= math.random(1,5)/5, imageWidth=35, imageHeight=35}
	-- planetData[3] = { y= math.random(1,10)/10,  imageWidth=30, imageHeight=30}

	local scaleFactor = 1 * (size/3)

	--local p = planetData[index]
	--local planet = display.newImageRect( "images/planet-" .. index .. ".png", p.imageWidth, p.imageHeight )
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

	-- making sure it is not on top of the game header
	planet.y = math.max(planet.y, _G.MIN_Y + planet.contentHeight)

	planet.initialx = planet.x
	physics.addBody( planet, "dynamic", {radius = planet.contentWidth*0.5} )
    planet.isSensor = true;
--	planet:applyLinearImpulse( impulse*5, 0, planet.x, planet.y)




	planet.showExplosion = function()
		local mEffects = require("module-effects")
    	planet._effect = mEffects.show("explosion", planet.x, planet.y, planet.contentWidth, planet.contentHeight)
	end


    planet.onCollision = function()
    	print("on planet.onCollision")
    	planet.isVisible = false
    	if planet._isAlreadyHit then return end

    	planet._isAlreadyHit = true
    	planet.showExplosion()
    	API.terminateVirtualMachine(planet.vmId,
    		function()
    			planet.destroy()
    		end)
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
		if activeVMs[name] == nil then
			planetsToDestroy[name] = planet
		end
	end


	-- creating the planets for the new VMs
	for name, planet in pairs(planetsToCreate) do
		createPlanet({name=name})
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