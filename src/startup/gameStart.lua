function gameStart()

    math.randomseed(os.time())

    -- set game title
    love.window.setTitle ("Coffee Shop Game")

    -- set colours
    love.graphics.setNewFont(12)
    love.graphics.setColor(0,0,0)
    love.graphics.setBackgroundColor(255,255,255)
    
    -- -- make pixels scale
    love.graphics.setDefaultFilter("nearest", "nearest")

    require("src/startup/require")
    requireEverything()

    -- set window size
    setWindowSize(false, windowWidth, windowHeight)
    
    -- set initial game state
    StateRegistry:setCurrentState("MAIN_MENU")
end


function setWindowSize(fullscreen, width, height)
    if fullscreen then
        love.window.setFullscreen(true)
        windowWidth = love.graphics.getWidth()
        windowHeight = love.graphics.getHeight()
    else
        -- verify that dont exceed screen dimensions
        local screenWidth, screenHeight = love.window.getDesktopDimensions()
        windowWidth = math.min(width, screenWidth)
        windowHeight = math.min(height, screenHeight*0.9)
        love.window.setMode( windowWidth, windowHeight, {resizable = true} )
    end
    setPixelScale()
end