-- shared pause icon shown in the corner of SHOP and all station states
PauseButton = {
    size = 10
    ,margin = 2
}

function PauseButton.getRect()
    local size = PauseButton.size * pixelScale
    local margin = PauseButton.margin * pixelScale
    return windowWidth - size - margin, margin, size, size
end

local wasMouseDown = false

-- returns true if the click was consumed (so callers can skip other hit-tests this frame)
function PauseButton.update()
    local mouseDown = love.mouse.isDown(1)
    local clicked = mouseDown and not wasMouseDown
    wasMouseDown = mouseDown

    if not clicked then return false end

    local x, y, w, h = PauseButton.getRect()
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    if mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h then
        StateRegistry:pushOverlay("PAUSE")
        return true
    end

    return false
end

function PauseButton.draw()
    local x, y, w, h = PauseButton.getRect()

    setColourWhite()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(1, 1, 1)
    local barWidth = w * 0.2
    love.graphics.rectangle("fill", x + w * 0.25, y + h * 0.2, barWidth, h * 0.6)
    love.graphics.rectangle("fill", x + w * 0.55, y + h * 0.2, barWidth, h * 0.6)
    setColourWhite()
end
