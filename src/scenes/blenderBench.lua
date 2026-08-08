blenderBench = {}

function blenderBench:draw()
    setColourWhite()
    love.graphics.setBackgroundColor(0.6, 0.5, 0.75)

    -- block-shape placeholder for the blender jug
    local jugWidth = 28 * pixelScale
    local jugHeight = 36 * pixelScale
    local jugX = (windowWidth - jugWidth) / 2
    local jugY = (windowHeight - jugHeight) / 2

    love.graphics.setColor(0.85, 0.9, 0.95, 0.8)
    love.graphics.rectangle("fill", jugX, jugY, jugWidth, jugHeight)
    love.graphics.setColor(0.2, 0.2, 0.25)
    love.graphics.setLineWidth(2 * pixelScale)
    love.graphics.rectangle("line", jugX, jugY, jugWidth, jugHeight)
    love.graphics.setLineWidth(1)
    setColourWhite()
end
