require "src/states/init"
require "src/states/registry"

blenderStationState = GameState:new({
    key = "BLENDER"
    ,transition_to_keys = {SHOP = true}
})

StateRegistry:register(blenderStationState.key, blenderStationState)

local flow = StationFlow:new({category = "BLENDER", scene = blenderBench})

function blenderStationState:draw()
    flow:draw()
end

function blenderStationState:update(dt)
    flow:update(dt)
end
