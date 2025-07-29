colours = {
    sky = { r = 116, g = 195, b = 255 }
    ,ground = { r = 81, g = 52, b = 32}
}

-- utility to convert to LOVE's /255 RGB format
for key, colour in pairs(colours) do
    colours[key] = {
        r = colour.r / 255,
        g = colour.g / 255,
        b = colour.b / 255
    }
end

function setColourWhite()
    love.graphics.setColor(1,1,1)
end