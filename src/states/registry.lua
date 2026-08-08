-- State registry to avoid circular dependencies
StateRegistry = {
    states = {},
    currentState = nil
}

function StateRegistry:register(key, state)
    self.states[key] = state
end

function StateRegistry:get(key)
    local state = self.states[key]
    if not state then
        error("State '" .. tostring(key) .. "' not found")
    end
    return state
end

function StateRegistry:getCurrentState()
    return self.currentState
end

function StateRegistry:setCurrentState(key)
    self.currentState = self:get(key)
end

function StateRegistry:transitionTo(targetKey)
    local currentState = self:getCurrentState()

    if not currentState then
        error("Cannot transition from nil state")
    end

    -- Validate the transition is allowed
    if not currentState.transition_to_keys or not currentState.transition_to_keys[targetKey] then
        error("Invalid state change from " .. tostring(currentState.key) .. " to " .. targetKey)
    end

    return self:setCurrentState(targetKey)
end

-- Pause/resume escape hatch, reserved for the pause overlay only: bypasses
-- transition_to_keys validation (same as the unchecked setCurrentState) so
-- the overlay can be pushed from any gameplay state and resumed back to it.
function StateRegistry:pushOverlay(key)
    self.pausedFromKey = self.currentState.key
    self:setCurrentState(key)
end

function StateRegistry:popOverlay()
    self:setCurrentState(self.pausedFromKey)
    self.pausedFromKey = nil
end