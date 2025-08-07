
-- base resolution
baseWidthPx = 128
baseHeightPx = 96

-- default scale
pixelScale = 1

-- window dimensions
windowWidth = baseWidthPx * pixelScale
windowHeight = baseHeightPx * pixelScale

function setWindowSize(width, height)
    -- If width and height are provided, use them directly without scaling
    if width and height then
        windowWidth = width
        windowHeight = height
        love.window.setMode( windowWidth, windowHeight, {resizable = true} )
        return
    end
    
    -- Auto-scale based on desktop dimensions when no specific size is provided
    width, height = love.window.getDesktopDimensions()

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