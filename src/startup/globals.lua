-- base resolution
local baseWidthPx = 128
local baseHeightPx = 96

-- init scale
pixelScale = 5
windowWidth = baseWidthPx * pixelScale
windowHeight = baseHeightPx * pixelScale

function setPixelScale()
    -- use smaller scale factor to maintain aspect ratio
    local scaleX = windowWidth / baseWidthPx
    local scaleY = windowHeight / baseHeightPx
    pixelScale = math.max(math.min(scaleX, scaleY), 1)
end