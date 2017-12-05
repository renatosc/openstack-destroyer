local effects = {}

local data = {
	["explosion"] = {numOfImages=9},
	["whitePuff"] = {numOfImages=25},
}


effects.show = function(tpe, x,y,w,h)

	local effectData = data[tpe]

	local group = display.newGroup()
	--group.anchorChildren = true
	group._type = tpe
	group._currIndex = 0
	group._maxIndex = effectData.numOfImages - 1


	group.showImageIndex = function()
		display.remove(group._img)
		local index = group._currIndex + 1
		if index > group._maxIndex then
			index = 0
		end
		local img = display.newImage(group, "images/effects/" .. group._type .. index.. ".png")
		local scaleF = math.min(w/img.contentWidth, h/img.contentHeight)
		img:scale(scaleF, scaleF)
		img.x = x
		img.y = y

		group._img = img
		group._currIndex = index
	end

	group.showImageIndex()
	group._timerId = timer.performWithDelay(100, function()
	    group.showImageIndex()
	end,-1)


	group.stop = function()
		if group._timerId then
			timer.cancel( group._timerId )
			group._timerId = nil
		end
		display.remove(group)
	end

	return group

end


return effects