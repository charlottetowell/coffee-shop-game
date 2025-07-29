cafeOutside = {}

function cafeOutside:draw()
    setColourWhite()

    -- set background colour
    love.graphics.setBackgroundColor(colours.sky.r, colours.sky.g, colours.sky.b)

    -- draw cafe
    love.graphics.draw(assets.cafe, 0, 0, 0, pixelScale, pixelScale)

    -- draw ground
    love.graphics.setColor(colours.ground.r, colours.ground.g, colours.ground.b)
    love.graphics.rectangle("fill", 0, windowHeight-(4*pixelScale), windowWidth, 4*pixelScale)

    -- draw clouds
    setColourWhite()
    love.graphics.draw(assets.clouds.image, assets.clouds.quads[1], 0, 0, 0, pixelScale, pixelScale)
    love.graphics.draw(assets.clouds.image, assets.clouds.quads[2], windowHeight/4, 0, 0, pixelScale, pixelScale)
end