matchaBench = {}

function matchaBench:draw()
    setColourWhite()
    love.graphics.setBackgroundColor(0.5, 0.62, 0.42)

    -- reuse the coffee cup sprite as a placeholder vessel, centered like coffeeBench
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    love.graphics.draw(assets.coffeeBase, cupX, cupY, 0, pixelScale, pixelScale)
end
