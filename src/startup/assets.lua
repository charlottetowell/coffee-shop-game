-- tilesets
local tilesets = {
    clouds = love.graphics.newImage("assets/clouds.png")
}
local tilesetQuads = {
    clouds = {
        love.graphics.newQuad(0, 0, 48, 16, tilesets.clouds),
        love.graphics.newQuad(0, 17, 48, 16, tilesets.clouds),
        love.graphics.newQuad(0, 17, 47, 16, tilesets.clouds),
        love.graphics.newQuad(48, 17, 60, 16, tilesets.clouds)
    }
}

-- image assets
assets = {
    cafeOutside = love.graphics.newImage("assets/cafe-outside.png")
    ,playButton = love.graphics.newImage("assets/play-button.png")
    ,playButtonHover = love.graphics.newImage("assets/play-button-hover.png")
    ,clouds = {
        image = tilesets.clouds
        ,quads = tilesetQuads.clouds
    }
    ,coffeeBase = love.graphics.newImage("assets/coffee-base.png")
    ,latteArt = {
        heart_20 = love.graphics.newImage("assets/latteArt/heart_20.png")
        ,heart_40 = love.graphics.newImage("assets/latteArt/heart_40.png")
        ,heart_60 = love.graphics.newImage("assets/latteArt/heart_60.png")
        ,heart_80 = love.graphics.newImage("assets/latteArt/heart_80.png")
        ,heart_100 = love.graphics.newImage("assets/latteArt/heart_100.png")
    }
    ,milkPourer = {
        enabled = love.graphics.newImage("assets/milk-pourer-enabled.png")
        ,disabled = love.graphics.newImage("assets/milk-pourer.png")
    }
}

-- fonts
fonts = {
    cousineBold = love.graphics.newFont("assets/fonts/Cousine-Bold.ttf", 15)
}