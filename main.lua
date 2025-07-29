function love.draw()
    require "src/draw"
    drawGame()
end

function love.load()
    require "src/load"
    loadGame()
end

function love.focus(f) gameIsPaused = not f end

function love.update(dt)
	if gameIsPaused then return end

    require "src/update"
    updateGame(dt)
end

function love.quit()
  require "src/quit"
  quitGame()
end