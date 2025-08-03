coffeeBench = {}

function coffeeBench:draw()
    setColourWhite()

    -- set background colour
    love.graphics.setBackgroundColor(colours.ground.r, colours.ground.g, colours.ground.b)

    -- draw coffee cup in middle of the screen
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    love.graphics.draw(assets.coffeeBase, cupX, cupY, 0, pixelScale, pixelScale)
    love.graphics.draw(assets.latteArt.heart_100, cupX, cupY, 0, pixelScale, pixelScale)
end