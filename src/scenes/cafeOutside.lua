cafeOutside = {}

function cafeOutside:draw()
    setColourWhite()

    -- set background colour
    love.graphics.setBackgroundColor(colours.sky.r, colours.sky.g, colours.sky.b)

    -- draw ground
    love.graphics.setColor(colours.ground.r, colours.ground.g, colours.ground.b)
    love.graphics.rectangle("fill", 0, windowHeight-(4*pixelScale), windowWidth, 4*pixelScale)

    -- draw clouds (animated scrolling)
    setColourWhite()
    local time = love.timer.getTime()
    local cloudSpeeds = {20, 15, 25, 12}
    local cloudStartX = {windowWidth * 0.9, windowWidth * 0.6, windowWidth * 0.2, windowWidth * 0.7}
    local cloudYPositions = {windowHeight * 0.1, windowHeight * 0.3, windowHeight * 0.5, windowHeight * 0.75}
    
    local cloudsPerRow = 2
    for cloudSet = 0, (cloudsPerRow-1) do -- number of cloud sets (per row)
        local offset = cloudSet * (windowWidth + 100) / cloudsPerRow
        
        for i = 1, 4 do -- draw clouds for each row
            local cloudX = (cloudStartX[i] - time * cloudSpeeds[i] + offset) % (windowWidth + 100) - 100
            love.graphics.draw(assets.clouds.image, assets.clouds.quads[i], cloudX, cloudYPositions[i], 0, pixelScale, pixelScale)
        end
    end

    -- draw cafe
    love.graphics.draw(assets.cafeOutside, 0, 0, 0, pixelScale, pixelScale)
end