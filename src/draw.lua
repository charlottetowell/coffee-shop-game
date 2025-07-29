require "src/states/registry"

function drawGame()
    StateRegistry:getCurrentState():draw()
end