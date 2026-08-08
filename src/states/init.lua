GameState = {
    key = ""
    ,transition_to_keys = {}
}

function GameState:new(s)
    local state = s
    setmetatable(state, self)
    self.__index = self

    return state
end