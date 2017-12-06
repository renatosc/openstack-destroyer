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

	physics.addBody( star, "dynamic", {radius = star.contentWidth*0.5, isSensor = true} )
	star:applyLinearImpulse( impulse, 0, star.x, star.y)

--DEBUG VALUES
--star.x = CENTER_X
--star.y = CENTER_Y


	star.showFusion = function()
		local mEffects = require("module-effects")
    	star._effect = mEffects.show("whitePuff",star.x, star.y, star.contentWidth, star.contentHeight)
	end
print("CENTER_X, CENTER_Y=", CENTER_X, CENTER_Y)

    star.onCollision = function()
    	local currX, currY = star.x, star.y
    	display.remove(star)
    	if star._isAlreadyHit then return end

    	star._isAlreadyHit = true

    	star.showFusion()

    	-- spin new instance
    	API.createNewVirtualMachine(star.name,
    		function(vmData)


    		require("class-planet").new{
    			id=vmData.id,
    			name=vmData.name,
    			x=currX,
    			y=currY,
    			fromLeft=fromLeft,

    		}
    		star.destroy()


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
	classStar._spawnLoopId = timer.performWithDelay(5000,   --1000 * math.random(1,10),
		function()
	    	newStar()
	end, -1)
end

return classStar