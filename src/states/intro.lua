require "src/states/init"
require "src/states/registry"

menuState = GameState:new({
    key = "INTRO"
    ,transition_to_key = "PLAY"
})

-- register state
StateRegistry:register(menuState.key, menuState)

local alpha = 1

function menuState:draw()
    -- draw a black rectangle
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end


function menuState:update(dt)
    if alpha == 0 then
        menuState:transitionTo(self.transition_to_key)
    else
        alpha = alpha - dt
        if alpha < 0 then
            alpha = 0
        end
    end
end
