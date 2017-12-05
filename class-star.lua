local classStar = {}

classStar._star = nil

local newStar = function()

	if classStar._star then return end


	local starW = 40
	local starH = 40

	local star = display.newImageRect("images/star.png", starW, starW) -- display.newRect(starW*.5, starH*.5, starW, starH)
	star.name = "star-".. os.time()
	--star.fill = {type="image", filename="images/star.png"}

	local fromLeft = (math.random( 1,4 ) > 2)

	local initialX = SCREEN_W + star.contentWidth
	local impulse = - (0.01  + math.rad( 1,5 )/100)
	if fromLeft then
		initialX = - star.contentWidth
		impulse = - impulse
	end
	star.x = initialX
	star.y = SCREEN_H * math.random( 1,70 )/100
	star._x = initialX
print("new Star!!")
	physics.addBody( star, "dynamic", {radius = star.contentWidth*0.5, isSensor = true} )
	star:applyLinearImpulse( impulse, 0, star.x, star.y)


	star.showFusion = function()
		local mEffects = require("module-effects")
    	star._effect = mEffects.show("whitePuff",star.x, star.y, star.contentWidth, star.contentHeight)
	end


    star.onCollision = function()
    	display.remove(star)
    	if star._isAlreadyHit then return end

    	star._isAlreadyHit = true

    	star.showFusion()

    	-- spin new instance
    	API.createNewVirtualMachine(star.name, function()

    		--TODO: Create new planet here

    	end)

    end


    star.destroy = function()
    	if star._effect then
    		star._effect.stop()
    	end
    	display.remove(star)
    	classStar._star = nil
    	timer.performWithDelay(10, function()
    	    star = nil
    	end)
    end

    classStar._star = star

end


classStar.start = function()
	classStar._spawnLoopId = timer.performWithDelay(1000,   --1000 * math.random(1,10),
		function()
	    	newStar()
	end, -1)
end

return classStar