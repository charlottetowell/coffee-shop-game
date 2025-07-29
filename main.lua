function love.draw()
    drawGame()
end

function love.load()
    require "src/load"
    loadGame()
end

function love.focus(f) gameIsPaused = not f end

function love.update(dt)
	if gameIsPaused then return end

    updateGame(dt)
end

function love.quit()
  quitGame()
end