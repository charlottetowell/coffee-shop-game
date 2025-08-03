require "src/states/init"
require "src/states/registry"

latteArtState = GameState:new({
    key = "LATTE_ART"
    ,transition_to_key = "MAIN_MENU"
})

-- register state
StateRegistry:register(latteArtState.key, latteArtState)

-- Table to store line points
linePoints = {}

-- Predefined path coordinates
predefinedPath = {
    100, 100,
    200, 150,
    300, 200,
    400, 250,
    500, 300
}

-- Tolerance value for line comparison
tolerance = 20

-- Function to check if a point is within tolerance of the predefined path
local function isPointNearPath(x, y)
    for i = 1, #predefinedPath, 2 do
        local px, py = predefinedPath[i], predefinedPath[i + 1]
        local distance = math.sqrt((x - px)^2 + (y - py)^2)
        if distance <= tolerance then
            return true
        end
    end
    return false
end

function latteArtState:draw()
    -- Draw black background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

    -- Draw white text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Latte Art State", windowWidth * 0.5, windowHeight * 0.5)

    -- Draw the predefined path in red
    if #predefinedPath >= 4 then -- Ensure at least two vertices (x, y pairs)
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(predefinedPath)
    end

    -- Draw the user's line if within tolerance
    if #linePoints >= 4 then -- Ensure at least two vertices (x, y pairs)
        local filteredPoints = {}
        for i = 1, #linePoints, 2 do
            local x, y = linePoints[i], linePoints[i + 1]
            if isPointNearPath(x, y) then
                table.insert(filteredPoints, x)
                table.insert(filteredPoints, y)
            end
        end

        if #filteredPoints >= 4 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.line(filteredPoints)
        end
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
