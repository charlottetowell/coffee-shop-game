cafeOutside = {}

-- load in assets
cafeOutside.assets = {
    cafe = love.graphics.newImage("assets/cafe-outside.png"),
    playButton = love.graphics.newImage("assets/play-button.png"),
}

function cafeOutside:draw()
    setColourWhite()

    -- set background colour
    love.graphics.setBackgroundColor(colours.sky.r, colours.sky.g, colours.sky.b)

    -- draw cafe
    love.graphics.draw(self.assets.cafe, 0, 0, 0, pixelScale, pixelScale)

    -- draw ground
    love.graphics.setColor(colours.ground.r, colours.ground.g, colours.ground.b)
    love.graphics.rectangle("fill", 0, windowHeight-(4*pixelScale), windowWidth, 4*pixelScale)
end