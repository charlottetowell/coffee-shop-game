require "src/states/init"
require "src/states/registry"

shopClosedState = GameState:new({
    key = "SHOP_CLOSED"
    ,transition_to_keys = {MAIN_MENU = true}
})

StateRegistry:register(shopClosedState.key, shopClosedState)

function shopClosedState:draw()
    setColourWhite()
    love.graphics.setBackgroundColor(colours.ground.r, colours.ground.g, colours.ground.b)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.cousineBold)
    love.graphics.printf("Shop Closed!", 0, windowHeight * 0.2, windowWidth, "center")
    love.graphics.printf("Score: " .. score, 0, windowHeight * 0.4, windowWidth, "center")
    love.graphics.printf("Drinks Made: " .. drinksMade, 0, windowHeight * 0.5, windowWidth, "center")

    suit.draw()
    setColourWhite()
end

function shopClosedState:update(dt)
    local buttonWidth = windowWidth * 0.5
    local buttonX = (windowWidth - buttonWidth) / 2

    if suit.Button("Back to Menu", {}, buttonX, windowHeight * 0.7, buttonWidth, 16 * pixelScale).hit then
        StateRegistry:transitionTo("MAIN_MENU")
    end
end
