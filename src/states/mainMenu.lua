require "src/states/init"
require "src/states/registry"

menuState = GameState:new({
    key = "MAIN_MENU"
    ,transition_to_key = "INTRO"
})

-- register state
StateRegistry:register(menuState.key, menuState)

function menuState:draw()
    -- draw 
    cafeOutside:draw()
end


function menuState:update(dt)
   -- do nothing
end
