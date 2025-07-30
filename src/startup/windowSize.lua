
-- base resolution
baseWidthPx = 128
baseHeightPx = 96

-- default scale
pixelScale = 10

-- window dimensions
windowWidth = baseWidthPx * pixelScale
windowHeight = baseHeightPx * pixelScale

function setWindowSize(width, height)
    -- set based on max screen dimensions is size not provided
    if not width or not height then
        width, height = love.window.getDesktopDimensions()
    end

    -- Calculate the maximum scale factor that fits within screen dimensions
    local maxScaleX = math.floor(width / baseWidthPx)
    local maxScaleY = math.floor(height / baseHeightPx)
    local maxScale = math.min(maxScaleX, maxScaleY)
    
    -- Ensure minimum scale of 1
    pixelScale = math.max(maxScale, 1)
    
    -- Calculate window dimensions based on max scale
    windowWidth = baseWidthPx * pixelScale
    windowHeight = baseHeightPx * pixelScale
    
    love.window.setMode( windowWidth, windowHeight, {resizable = true} )
end