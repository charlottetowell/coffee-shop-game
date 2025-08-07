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
        ,leaf_20 = love.graphics.newImage("assets/latteArt/leaf_20.png")
        ,leaf_40 = love.graphics.newImage("assets/latteArt/leaf_40.png")
        ,leaf_60 = love.graphics.newImage("assets/latteArt/leaf_60.png")
        ,leaf_80 = love.graphics.newImage("assets/latteArt/leaf_80.png")
        ,leaf_100 = love.graphics.newImage("assets/latteArt/leaf_100.png")
        ,crescent_20 = love.graphics.newImage("assets/latteArt/crescent_20.png")
        ,crescent_40 = love.graphics.newImage("assets/latteArt/crescent_40.png")
        ,crescent_60 = love.graphics.newImage("assets/latteArt/crescent_60.png")
        ,crescent_80 = love.graphics.newImage("assets/latteArt/crescent_80.png")
        ,crescent_100 = love.graphics.newImage("assets/latteArt/crescent_100.png")
        ,swan_20 = love.graphics.newImage("assets/latteArt/swan_20.png")
        ,swan_40 = love.graphics.newImage("assets/latteArt/swan_40.png")
        ,swan_60 = love.graphics.newImage("assets/latteArt/swan_60.png")
        ,swan_80 = love.graphics.newImage("assets/latteArt/swan_80.png")
        ,swan_100 = love.graphics.newImage("assets/latteArt/swan_100.png")
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