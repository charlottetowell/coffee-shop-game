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
    love.window.setMode(windowWidth, windowHeight, {resizable = false})
    
    -- set initial game state
    StateRegistry:setCurrentState("MAIN_MENU")
end