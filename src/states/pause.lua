require "src/states/init"
require "src/states/registry"

pauseState = GameState:new({
    key = "PAUSE"
    ,transition_to_keys = {SHOP_CLOSED = true}
})

StateRegistry:register(pauseState.key, pauseState)

function pauseState:draw()
    -- draw the frozen gameplay state behind the overlay
    StateRegistry:get(StateRegistry.pausedFromKey):draw()

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.cousineBold)
    love.graphics.printf("Paused", 0, windowHeight * 0.25, windowWidth, "center")

    suit.draw()
    setColourWhite()
end

function pauseState:update(dt)
    local buttonWidth = windowWidth * 0.5
    local buttonX = (windowWidth - buttonWidth) / 2

    if suit.Button("Resume", {}, buttonX, windowHeight * 0.45, buttonWidth, 16 * pixelScale).hit then
        StateRegistry:popOverlay()
        return
    end

    if suit.Button("Close Shop", {}, buttonX, windowHeight * 0.65, buttonWidth, 16 * pixelScale).hit then
        StateRegistry:transitionTo("SHOP_CLOSED")
    end
end
