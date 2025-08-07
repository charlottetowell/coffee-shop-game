require "src/states/init"
require "src/states/registry"

latteArtState = GameState:new({
    key = "LATTE_ART"
    ,transition_to_key = "MAIN_MENU"
})

-- register state
StateRegistry:register(latteArtState.key, latteArtState)


local latteArtConfig = require("src/config/latteArtConfig")

-- init vars
linePoints = {}
local SUB_STATE = {
    DRAW_ART = "DRAW_ART",
    JUDGE_ART = "JUDGE_ART"
}
local currentSubState = SUB_STATE.DRAW_ART

local CURRENT_LATTE_ART = latteArtConfig[math.random(#latteArtConfig)]


local drawTolerance = 50 * pixelScale
local matchTolerance = 50 * pixelScale

-- draw line
local function isPointNearPath(x, y)
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    
    -- Get the actual latte art image to check its size
    local latteArtImage = CURRENT_LATTE_ART.images[100] -- Use the 100% image as reference
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    for i = 1, #CURRENT_LATTE_ART.path, 2 do
        -- Position relative to where the latte art image is drawn, scaled to match image size
        local px = CURRENT_LATTE_ART.path[i] * scaleFactorX * pixelScale + cupX
        local py = CURRENT_LATTE_ART.path[i + 1] * scaleFactorY * pixelScale + cupY
        local distance = math.sqrt((x - px)^2 + (y - py)^2)
        if distance <= drawTolerance then
            return true
        end
    end
    return false
end

-- contribute to match %
local function isPointStrictlyNearPath(x, y)
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    
    -- Get the actual latte art image to check its size
    local latteArtImage = CURRENT_LATTE_ART.images[100] -- Use the 100% image as reference
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    for i = 1, #CURRENT_LATTE_ART.path, 2 do
        -- Position relative to where the latte art image is drawn, scaled to match image size
        local px, py = CURRENT_LATTE_ART.path[i] * scaleFactorX * pixelScale + cupX, CURRENT_LATTE_ART.path[i + 1] * scaleFactorY * pixelScale + cupY
        local distance = math.sqrt((x - px)^2 + (y - py)^2)
        if distance <= matchTolerance then
            return true
        end
    end
    return false
end

local function calculatePathLength(path)
    local latteArtImage = CURRENT_LATTE_ART.images[100]
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    local length = 0
    for i = 1, #path - 2, 2 do
        local x1, y1 = path[i] * scaleFactorX * pixelScale, path[i + 1] * scaleFactorY * pixelScale
        local x2, y2 = path[i + 2] * scaleFactorX * pixelScale, path[i + 3] * scaleFactorY * pixelScale
        length = length + math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end
    return length
end

-- Update computeMatchPercentage to consider the length of the user's line
local function computeMatchPercentage()
    if #linePoints < 4 then return 0 end -- No match if not enough points

    local matchingLength = 0
    local totalPathLength = calculatePathLength(CURRENT_LATTE_ART.path)

    for i = 1, #linePoints - 2, 2 do
        local x1, y1 = linePoints[i], linePoints[i + 1]
        local x2, y2 = linePoints[i + 2], linePoints[i + 3]

        -- Check if both points of the segment are near the predefined path
        if isPointStrictlyNearPath(x1, y1) and isPointStrictlyNearPath(x2, y2) then
            matchingLength = matchingLength + math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        end
    end

    return math.min(math.floor((matchingLength / totalPathLength) * 100), 100)
end

function latteArtState:draw()
    -- draw 
    coffeeBench:draw()

    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2

    local matchPercentage = computeMatchPercentage()
    if matchPercentage >= 20 then
        -- Draw a different latte art image based on match percentage and config setup
        local maxImages = #CURRENT_LATTE_ART.images
        local imageIndex = math.min(maxImages, math.floor(matchPercentage / (100 / maxImages)))

        -- Ensure imageIndex is always one of the valid values (20, 40, 60, 80, 100)
        local validIndices = {20, 40, 60, 80, 100}
        local closestIndex = validIndices[1]
        for _, index in ipairs(validIndices) do
            if math.abs(matchPercentage - index) < math.abs(matchPercentage - closestIndex) then
                closestIndex = index
            end
        end
        imageIndex = closestIndex

        love.graphics.draw(CURRENT_LATTE_ART.images[imageIndex], cupX, cupY, 0, pixelScale, pixelScale)
    end

    if currentSubState == SUB_STATE.DRAW_ART then

        -- draw the latte art path
        if #CURRENT_LATTE_ART.path >= 4 then -- min 2 vertices
            love.graphics.setColor(1, 0, 0)
            -- Create path with scaling and cup position offset
            local latteArtImage = CURRENT_LATTE_ART.images[100]
            local scaleFactorX = latteArtImage:getWidth() / 54
            local scaleFactorY = latteArtImage:getHeight() / 54
            
            local offsetPath = {}
            for i = 1, #CURRENT_LATTE_ART.path, 2 do
                table.insert(offsetPath, CURRENT_LATTE_ART.path[i] * scaleFactorX * pixelScale + cupX)
                table.insert(offsetPath, CURRENT_LATTE_ART.path[i + 1] * scaleFactorY * pixelScale + cupY)
            end
            love.graphics.line(offsetPath)
        end

        -- draw user's path if within drawTolerance
        if #linePoints >= 4 then -- min 2 vertices
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

        -- match percentage
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Match: " .. matchPercentage .. "%", 10, 10)
    elseif currentSubState == SUB_STATE.JUDGE_ART then
        -- Display the match percentage in the JUDGE_ART sub-state
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Judging Art...", windowWidth * 0.5, windowHeight * 0.4)
        love.graphics.print("Final Match: " .. computeMatchPercentage() .. "%", windowWidth * 0.5, windowHeight * 0.5)
    end

    -- Draw milk pourer at cursor position
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    love.graphics.setColor(1, 1, 1)
    
    -- Choose milk pourer image based on mouse state
    local milkPourerImage = love.mouse.isDown(1) and assets.milkPourer.enabled or assets.milkPourer.disabled
    
    -- Draw milk pourer centered on cursor
    local pourerWidth = milkPourerImage:getWidth() * pixelScale
    local pourerHeight = milkPourerImage:getHeight() * pixelScale
    love.graphics.draw(milkPourerImage, mouseX - pourerWidth/2, mouseY - pourerHeight/2, 0, pixelScale, pixelScale)
    
    -- Display mouse position for debugging
    love.graphics.print("Mouse: (" .. mouseX .. ", " .. mouseY .. ")", windowWidth - 150, 10)
end

local pointAddTimer = 0 -- Timer to control point addition

function latteArtState:update(dt)
    if currentSubState == SUB_STATE.DRAW_ART then
        -- Update the timer
        pointAddTimer = pointAddTimer + dt

        -- Add a new point only if the timer exceeds the threshold (e.g., 10 * dt)
        if love.mouse.isDown(1) and pointAddTimer >= 0.1 then
            local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
            table.insert(linePoints, mouseX)
            table.insert(linePoints, mouseY)

            -- Reset the timer
            pointAddTimer = 0

            -- Limit the number of points to avoid performance issues
            if #linePoints > 1000 then
                table.remove(linePoints, 1)
                table.remove(linePoints, 1)
            end
        end

        -- Transition to JUDGE_ART sub-state if match percentage reaches 100%
        if computeMatchPercentage() == 100 then
            currentSubState = SUB_STATE.JUDGE_ART
        end
    end
end
