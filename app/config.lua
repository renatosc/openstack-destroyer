
application = {
    launchPad = false,  -- disabling corona analytics
    content =
    {
        width = 320,
        height = 480,
        scale = "adaptive",
        fps = 30,
        -- imageSuffix = {
        --     ["@2x"] = 1.5,
        --     ["@3x"] = 2.5,
        -- }
    },


    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }

}
