
_G.IS_DEBUG = true

-- setting default background to white
display.setDefault( "background", 0,0,0 )

-- defyning the status bar type
display.setStatusBar( display.HiddenStatusBar )

-- definying globals
_G.CENTER_X = display.contentCenterX
_G.CENTER_Y = display.contentCenterY
_G.SCREEN_W = display.contentWidth
_G.SCREEN_H = display.contentHeight



_G.API = require("api")
_G.STORAGE = require("module-storage")



-- giving a small delay to main to allow it close, avoiding possible black screens when lauching Corona
timer.performWithDelay(10, function()

    local composer = require("composer");
    --composer.recycleOnSceneChange = true

    composer.gotoScene("scene-main")

end)
