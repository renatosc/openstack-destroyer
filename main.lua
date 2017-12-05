-- setting default background to white
display.setDefault( "background", 0,0,0 )

-- defyning the status bar type
display.setStatusBar( display.HiddenStatusBar )

-- definying globals
_G.STATUS_BAR_H = display.topStatusBarContentHeight + 2
_G.TOP_Y_AFTER_STATUS_BAR = display.topStatusBarContentHeight + 2

_G.CENTER_X = display.contentCenterX
_G.CENTER_Y = display.contentCenterY
_G.SCREEN_W = display.contentWidth
_G.SCREEN_H = display.contentHeight



_G.API = require("api")
_G.STORAGE = require("module-storage")


-- _G.MARGIN_W = 20

_G.COLORS = require("module-colors")
_G.FONTS = require("module-fonts")
-- -- _G.AUX = require("module-aux")
-- _G.BACK = require("rb-libs.rb-back")
-- _G.DEVICE = require("rb-libs.rb-device")
-- --_G.SERVER = require("server")

-- _G.CW = require "custom-widgets"


-- _G.RBW = require("rb-libs.rb-widget")




local background = display.newRect(CENTER_X, CENTER_Y, SCREEN_W, SCREEN_H)
background.fill = _G.COLORS.transparent
background.isHitTestable = true
_G.BACKGROUND = background
background:addEventListener( "tap", function() native.setKeyboardFocus( nil ) end)



-- giving a small delay to main to allow it close, avoiding possible black screens when lauching Corona
timer.performWithDelay(10, function()

    local composer = require("composer");
    --composer.recycleOnSceneChange = true


    composer.gotoScene("scene-main")





end)
