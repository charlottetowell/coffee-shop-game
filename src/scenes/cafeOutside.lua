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
    love.graphics.draw(self.assets.cafe, 0, 0)
end