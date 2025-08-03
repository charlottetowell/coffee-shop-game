require "src/states/init"
require "src/states/registry"

latteArtState = GameState:new({
    key = "LATTE_ART"
    ,transition_to_key = "MAIN_MENU"
})

-- register state
StateRegistry:register(latteArtState.key, latteArtState)


function latteArtState:draw()
    --draw black background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
    -- draw white text
    love.graphics.setColor(1,1,1)
    love.graphics.print("Latte Art State", windowWidth * 0.5, windowHeight * 0.5)
end

function latteArtState:update(dt)
    -- do nothing
end
