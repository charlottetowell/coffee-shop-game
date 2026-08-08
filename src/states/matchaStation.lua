require "src/states/init"
require "src/states/registry"

matchaStationState = GameState:new({
    key = "MATCHA"
    ,transition_to_keys = {SHOP = true}
})

StateRegistry:register(matchaStationState.key, matchaStationState)

local flow = StationFlow:new({category = "MATCHA", scene = matchaBench})

function matchaStationState:draw()
    flow:draw()
end

function matchaStationState:update(dt)
    flow:update(dt)
end
