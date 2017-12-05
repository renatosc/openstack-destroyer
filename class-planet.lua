local classPlanet = {}

classPlanet._planets = {}


function createPlanet(options)
	local name = options.name
	local id = options.id
	local index = math.random(1,3)

	print("Creating Planet for VM with name '" ..tostring(name) .. "'")

	local planetData = {}
	planetData[1] = { y= math.random(1,4)/4,  imageWidth=50, imageHeight=50, impulse=-0.03}
	planetData[2] = { y= math.random(1,5)/5, imageWidth=35, imageHeight=35, impulse=-0.02}
	planetData[3] = { y= math.random(1,10)/10,  imageWidth=30, imageHeight=30, impulse=0.01}


	local p = planetData[index]
	local planet = display.newImageRect( "images/planet-" .. index .. ".png", p.imageWidth, p.imageHeight )
	planet.y = display.contentCenterY * p.y
	planet.id = "planet"
	planet.vmName = name
	planet.vmId = id


	if index == 3 then
		planet.x = - planet.contentWidth
	else
		planet.x = SCREEN_W +  planet.contentWidth
	end

	planet.initialx = planet.x
	physics.addBody( planet, "dynamic", {radius = p.imageWidth*0.5} )
    planet.isSensor = true;
	planet:applyLinearImpulse( p.impulse, 0, planet.x, planet.y)
-- planet.x = CENTER_X
-- planet.y = CENTER_Y
-- planet:applyLinearImpulse( -0.01, 0  , planet.x, planet.y)




	planet.showExplosion = function()
		local mEffects = require("module-effects")
    	planet._effect = mEffects.show("explosion", planet.x, planet.y, planet.contentWidth, planet.contentHeight)
	end


    planet.onCollision = function()
    	display.remove(planet)
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
    end

    -- storing this planet
    classPlanet._planets[name] = planet



    timer.performWithDelay(17000, function()planet.x = planet.initialx end, -1)

end

classPlanet.new = createPlanet



classPlanet.refreshPlanets = function()

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