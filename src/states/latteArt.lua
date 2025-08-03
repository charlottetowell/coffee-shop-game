require "src/states/init"
require "src/states/registry"

latteArtState = GameState:new({
    key = "LATTE_ART"
    ,transition_to_key = "MAIN_MENU"
})

-- register state
StateRegistry:register(latteArtState.key, latteArtState)

mouse = {
    x = love.mouse.getX(),
    y = love.mouse.getY()
}

-- Table to store line points
linePoints = {}

function latteArtState:draw()
    -- Draw black background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

    -- Draw white text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Latte Art State", windowWidth * 0.5, windowHeight * 0.5)

    -- Draw the line based on stored points
    if #linePoints >= 4 then -- Ensure at least two vertices (x, y pairs)
        love.graphics.setColor(1, 1, 1)
        love.graphics.line(linePoints)
    end
end

function latteArtState:update(dt)
    -- Update mouse position and add to line points
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    table.insert(linePoints, mouseX)
    table.insert(linePoints, mouseY)

    -- Limit the number of points to avoid performance issues
    if #linePoints > 1000 then
        table.remove(linePoints, 1)
        table.remove(linePoints, 1)
    end
end
