function gameStart()

    math.randomseed(os.time())

    -- set game title
    love.window.setTitle ("Coffee Shop Game")

    -- set window size
    local windowWidthPx = 128
    local windowHeightPx = 96
    local scaleFactor = 10
    setWindowSize(windowWidthPx * scaleFactor, windowHeightPx * scaleFactor)

    -- set colours
    love.graphics.setNewFont(12)
    love.graphics.setColor(0,0,0)
    love.graphics.setBackgroundColor(255,255,255)
    
    -- make pixels scale
    love.graphics.setDefaultFilter("nearest", "nearest")

    require("src/startup/require")
    requireEverything()

    -- set initial game state
    StateRegistry:setCurrentState("MAIN_MENU")
end

function setWindowSize(width, height)
    windowWidth = width
    windowHeight = height
    love.window.setMode(windowWidth, windowHeight, {resizable = false})
end
