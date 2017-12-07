local colors = {
	black = {44/255, 44/255, 44/255},
	darkBlue = {79/255, 126/255, 220/255},
	blue = {84/255, 140/255, 240/255},
	lightBlue = {0/255, 160/255, 255/255},
	darkGreen = {36/255, 160/255, 90/255},
	green = {57/255, 189/255, 114/255},
	gray = {236/255, 238/255, 238/255},
	darkBrown = {122/255, 83/255, 64/255},
	brown = {173/255, 115/255, 115/255},
	black = {41/255, 47/255, 51/255},
	white = {255/255, 255/255, 255/255},
	transparent = {255/255, 255/255, 255/255, 0},
	darkRed = {133/255, 34/255, 40/255},
	red = {192/255, 25/255, 35/255},


	yellow = {242/255, 200/255, 71/255}
}




colors.background = colors.darkBlue
colors.topBar = colors.darkBlue
colors.tabBar = colors.darkBlue
colors.placeholder = colors.gray

colors.carb = colors.red
colors.fat = colors.yellow
colors.protein = colors.darkBrown





colors.overlay = function(colorName, alpha)
	alpha = alpha or 0.7
	local color = colors[colorName]
	if color == nil then
		error("Color '" .. colorName .. "' not found!")
	end
	return {color[1], color[2], color[3], alpha}
end

-- local searchString = "PassionOne"
-- local systemFonts = native.getFontNames()
-- print("")
-- print( "- - - FONTS - - -")
-- for i, fontName in ipairs( systemFonts ) do
--    local j, k = string.find( string.lower(fontName), string.lower(searchString) )
--    if ( j ~= nil ) then
--        print( "Font Name = " .. tostring( fontName ) )
--    end
-- end
-- print( "- - - - - - - - -")
-- print("")

return colors