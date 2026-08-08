require "src/states/init"
require "src/states/registry"

coffeeMachineState = GameState:new({
    key = "COFFEE_MACHINE"
    ,transition_to_keys = {SHOP = true}
})

StateRegistry:register(coffeeMachineState.key, coffeeMachineState)

local flow = StationFlow:new({category = "COFFEE", scene = coffeeBench})

function coffeeMachineState:draw()
    flow:draw()
end

function coffeeMachineState:update(dt)
    flow:update(dt)
end
