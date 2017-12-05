local fonts = {
	regular = "fonts/Roboto-Regular",
	light = "fonts/Roboto-Light",
	thin = "fonts/Roboto-Thin",
}



local searchString = "Robo"
local systemFonts = native.getFontNames()
print("")
print( "- - - FONTS - - -")
for i, fontName in ipairs( systemFonts ) do
   local j, k = string.find( string.lower(fontName), string.lower(searchString) )
   if ( j ~= nil ) then
       print( "Font Name = " .. tostring( fontName ) )
   end
end
print( "- - - - - - - - -")
print("")

return fonts