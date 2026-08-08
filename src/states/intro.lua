require "src/states/init"
require "src/states/registry"

introState = GameState:new({
    key = "INTRO"
    ,transition_to_keys = {MAIN_MENU = true}
})

-- register state
StateRegistry:register(introState.key, introState)

local alpha = 1
local timer = love.timer.getTime()
local startFadeAt = 3 -- seconds
local transitionSpeed = 0.01

function introState:draw()

    -- draw 
    cafeOutside:draw()

    -- draw a black rectangle
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if love.timer.getTime() - timer < startFadeAt  then
        -- draw text
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.setFont(fonts.cousineBold)
        love.graphics.printf("A game by Charlotte :)", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end

end


function introState:update(dt)
    if alpha == 0 then
        StateRegistry:transitionTo("MAIN_MENU")
    else
        if love.timer.getTime() - timer > startFadeAt then
            alpha = alpha - transitionSpeed
            if alpha < 0 then
                alpha = 0
            end
        end
    end
end
