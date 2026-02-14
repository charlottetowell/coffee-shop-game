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
local judgeTimer = 0 -- Timer for judging animation
local startPointRadius = 15 * pixelScale -- Radius for start point indicator

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

-- Helper function to get start point coordinates
local function getStartPoint()
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    local latteArtImage = CURRENT_LATTE_ART.images[100]
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    local startX = CURRENT_LATTE_ART.path[1] * scaleFactorX * pixelScale + cupX
    local startY = CURRENT_LATTE_ART.path[2] * scaleFactorY * pixelScale + cupY
    
    return startX, startY
end

-- Check if user started drawing from correct point
local function checkStartPointAccuracy()
    if #linePoints < 2 then return 0 end
    
    local startX, startY = getStartPoint()
    local userStartX, userStartY = linePoints[1], linePoints[2]
    local distance = math.sqrt((userStartX - startX)^2 + (userStartY - startY)^2)
    
    -- Full points if within 30 pixels, scaling down to 0 at 100 pixels
    local accuracy = math.max(0, 1 - (distance / (100 * pixelScale)))
    return accuracy
end

-- Calculate length accuracy (penalize if too short or too long)
local function checkLengthAccuracy()
    if #linePoints < 4 then return 0 end
    
    local userLength = 0
    for i = 1, #linePoints - 2, 2 do
        local x1, y1 = linePoints[i], linePoints[i + 1]
        local x2, y2 = linePoints[i + 2], linePoints[i + 3]
        userLength = userLength + math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end
    
    local targetLength = calculatePathLength(CURRENT_LATTE_ART.path)
    local lengthRatio = userLength / targetLength
    
    -- Ideal is 0.8 to 1.2 times the target length
    if lengthRatio >= 0.8 and lengthRatio <= 1.2 then
        return 1.0
    elseif lengthRatio < 0.8 then
        -- Too short: scale from 0 to 1 as we approach 0.8
        return math.max(0, lengthRatio / 0.8)
    else
        -- Too long: scale down as we exceed 1.2
        return math.max(0, 1 - ((lengthRatio - 1.2) * 0.5))
    end
end

-- Find closest point on path to given coordinates and return distance and progress %
local function getClosestPathPoint(x, y)
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    local latteArtImage = CURRENT_LATTE_ART.images[100]
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    local minDist = math.huge
    local closestIndex = 1
    local pathLength = 0
    local lengthToClosest = 0
    
    -- Find closest point and calculate path progress
    for i = 1, #CURRENT_LATTE_ART.path, 2 do
        local px = CURRENT_LATTE_ART.path[i] * scaleFactorX * pixelScale + cupX
        local py = CURRENT_LATTE_ART.path[i + 1] * scaleFactorY * pixelScale + cupY
        local distance = math.sqrt((x - px)^2 + (y - py)^2)
        
        if distance < minDist then
            minDist = distance
            closestIndex = i
            lengthToClosest = pathLength
        end
        
        -- Calculate cumulative path length
        if i > 1 then
            local prevPx = CURRENT_LATTE_ART.path[i - 2] * scaleFactorX * pixelScale + cupX
            local prevPy = CURRENT_LATTE_ART.path[i - 1] * scaleFactorY * pixelScale + cupY
            pathLength = pathLength + math.sqrt((px - prevPx)^2 + (py - prevPy)^2)
        end
    end
    
    local progress = pathLength > 0 and (lengthToClosest / pathLength) or 0
    return minDist, progress, closestIndex
end

-- Check if user is following path in correct order/direction
local function checkPathProgression()
    if #linePoints < 6 then return 0 end -- Need at least 3 points
    
    local progressions = {}
    local totalDeviation = 0
    local validSegments = 0
    
    -- Sample points along user's line and check their path progress
    local sampleInterval = math.max(4, math.floor(#linePoints / 20)) -- Sample ~20 points
    
    for i = 1, #linePoints - 2, sampleInterval do
        local x, y = linePoints[i], linePoints[i + 1]
        local dist, progress, idx = getClosestPathPoint(x, y)
        
        -- Only consider points that are reasonably close to the path
        if dist <= matchTolerance * 2 then
            table.insert(progressions, progress)
        end
    end
    
    -- Check if progressions are generally increasing (following path forward)
    if #progressions < 3 then return 0 end
    
    local orderedCorrectly = 0
    local totalComparisons = 0
    
    for i = 1, #progressions - 1 do
        totalComparisons = totalComparisons + 1
        local diff = progressions[i + 1] - progressions[i]
        
        -- Allow small backwards movement (trembling hand) but penalize large jumps
        if diff >= -0.05 then
            -- Good - moving forward or slight backward
            orderedCorrectly = orderedCorrectly + 1
        elseif diff >= -0.15 then
            -- Acceptable - minor backtrack
            orderedCorrectly = orderedCorrectly + 0.5
        end
        -- else: major backtrack, no points
    end
    
    return totalComparisons > 0 and (orderedCorrectly / totalComparisons) or 0
end

-- Check accuracy at key points along the path (start, middle quarters, end)
local function checkKeyPointsAccuracy()
    if #linePoints < 6 then return 0 end
    
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    local latteArtImage = CURRENT_LATTE_ART.images[100]
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    -- Define key points: start (0%), 25%, 50%, 75%, end (100%)
    local keyPointIndices = {1, math.floor(#CURRENT_LATTE_ART.path * 0.25), 
                            math.floor(#CURRENT_LATTE_ART.path * 0.5),
                            math.floor(#CURRENT_LATTE_ART.path * 0.75),
                            #CURRENT_LATTE_ART.path - 1}
    
    local totalAccuracy = 0
    local pointsChecked = 0
    
    for _, idx in ipairs(keyPointIndices) do
        if idx > 0 and idx < #CURRENT_LATTE_ART.path then
            local targetX = CURRENT_LATTE_ART.path[idx] * scaleFactorX * pixelScale + cupX
            local targetY = CURRENT_LATTE_ART.path[idx + 1] * scaleFactorY * pixelScale + cupY
            
            -- Find closest point in user's line to this key point
            local minDist = math.huge
            for i = 1, #linePoints, 2 do
                local userX, userY = linePoints[i], linePoints[i + 1]
                local dist = math.sqrt((userX - targetX)^2 + (userY - targetY)^2)
                minDist = math.min(minDist, dist)
            end
            
            -- Score: 1.0 if within matchTolerance, scaling down to 0 at matchTolerance * 3
            local accuracy = math.max(0, 1 - (minDist / (matchTolerance * 3)))
            totalAccuracy = totalAccuracy + accuracy
            pointsChecked = pointsChecked + 1
        end
    end
    
    return pointsChecked > 0 and (totalAccuracy / pointsChecked) or 0
end

-- Calculate average distance from user's line to target path
local function checkAveragePathDistance()
    if #linePoints < 4 then return 0 end
    
    local totalDistance = 0
    local pointsChecked = 0
    
    -- Check every point in user's line
    for i = 1, #linePoints, 2 do
        local x, y = linePoints[i], linePoints[i + 1]
        local dist, _, _ = getClosestPathPoint(x, y)
        
        totalDistance = totalDistance + dist
        pointsChecked = pointsChecked + 1
    end
    
    local avgDist = pointsChecked > 0 and (totalDistance / pointsChecked) or math.huge
    
    -- Score: 1.0 if avgDist is 0, scaling down to 0 at matchTolerance * 2
    return math.max(0, 1 - (avgDist / (matchTolerance * 2)))
end

-- Enhanced path matching percentage with comprehensive tracking
local function computeMatchPercentage()
    if #linePoints < 4 then return 0 end

    -- Calculate individual components
    local startAccuracy = checkStartPointAccuracy()
    local lengthAccuracy = checkLengthAccuracy()
    local progressionAccuracy = checkPathProgression()
    local keyPointsAccuracy = checkKeyPointsAccuracy()
    local avgDistanceAccuracy = checkAveragePathDistance()
    
    -- Weighted scoring for comprehensive path tracking:
    -- 15% - Start point (did you start correctly?)
    -- 15% - Length (is your line the right length?)
    -- 25% - Path progression (are you following the path in order?)
    -- 25% - Key points (do you hit the important waypoints?)
    -- 20% - Average distance (how close are you overall?)
    local finalScore = (startAccuracy * 0.15) + 
                       (lengthAccuracy * 0.15) + 
                       (progressionAccuracy * 0.25) +
                       (keyPointsAccuracy * 0.25) +
                       (avgDistanceAccuracy * 0.20)
    
    return math.min(math.floor(finalScore * 100), 100)
end

-- Calculate path completion percentage (how much of the path has been covered)
local function calculatePathCompletion()
    if #linePoints < 2 then return 0 end
    
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    local latteArtImage = CURRENT_LATTE_ART.images[100]
    local scaleFactorX = latteArtImage:getWidth() / 54
    local scaleFactorY = latteArtImage:getHeight() / 54
    
    -- Track which segments of the target path have been covered
    local pathSegmentsCovered = {}
    for i = 1, #CURRENT_LATTE_ART.path - 2, 2 do
        pathSegmentsCovered[i] = false
    end
    
    -- Check each user point against each path segment
    for i = 1, #linePoints, 2 do
        local userX, userY = linePoints[i], linePoints[i + 1]
        
        -- Find which path segment this point is closest to
        local minDist = math.huge
        local closestSegment = 1
        
        for j = 1, #CURRENT_LATTE_ART.path - 2, 2 do
            local pathX = CURRENT_LATTE_ART.path[j] * scaleFactorX * pixelScale + cupX
            local pathY = CURRENT_LATTE_ART.path[j + 1] * scaleFactorY * pixelScale + cupY
            local dist = math.sqrt((userX - pathX)^2 + (userY - pathY)^2)
            
            if dist < minDist then
                minDist = dist
                closestSegment = j
            end
        end
        
        -- If close enough, mark this segment as covered
        if minDist <= matchTolerance * 1.5 then
            pathSegmentsCovered[closestSegment] = true
        end
    end
    
    -- Calculate percentage of path covered
    local coveredCount = 0
    local totalSegments = 0
    for _, covered in pairs(pathSegmentsCovered) do
        totalSegments = totalSegments + 1
        if covered then
            coveredCount = coveredCount + 1
        end
    end
    
    return totalSegments > 0 and (coveredCount / totalSegments) or 0
end

-- Calculate display score combining accuracy and completion
local function calculateDisplayScore()
    if #linePoints < 2 then return 0 end
    
    local accuracy = computeMatchPercentage() / 100 -- Convert to 0-1 range
    local completion = calculatePathCompletion()
    
    -- Blend accuracy and completion: 40% accuracy, 60% completion
    -- This ensures the image builds up as you draw, but quality matters too
    local displayScore = (accuracy * 0.4) + (completion * 0.6)
    
    return math.floor(displayScore * 100)
end

-- Catmull-Rom spline interpolation for smooth curves
local function getCatmullRomPoint(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    
    local v0 = (p2 - p0) * 0.5
    local v1 = (p3 - p1) * 0.5
    
    return (2 * p1 - 2 * p2 + v0 + v1) * t3 +
           (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 +
           v0 * t + p1
end

-- Generate smooth curve from raw points
local function getSmoothCurve(points)
    if #points < 8 then return points end -- Need at least 4 points for smoothing
    
    local smoothPoints = {}
    local segments = 10 -- Number of interpolated points between each pair
    
    for i = 1, #points - 6, 2 do
        local p0x, p0y = points[math.max(1, i - 2)], points[math.max(2, i - 1)]
        local p1x, p1y = points[i], points[i + 1]
        local p2x, p2y = points[i + 2], points[i + 3]
        local p3x, p3y = points[math.min(#points - 1, i + 4)], points[math.min(#points, i + 5)]
        
        for s = 0, segments - 1 do
            local t = s / segments
            local x = getCatmullRomPoint(p0x, p1x, p2x, p3x, t)
            local y = getCatmullRomPoint(p0y, p1y, p2y, p3y, t)
            table.insert(smoothPoints, x)
            table.insert(smoothPoints, y)
        end
    end
    
    -- Add the last point
    if #points >= 2 then
        table.insert(smoothPoints, points[#points - 1])
        table.insert(smoothPoints, points[#points])
    end
    
    return smoothPoints
end

function latteArtState:draw()
    -- draw 
    coffeeBench:draw()

    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2

    -- Use display score (accuracy + completion) for showing progressive images
    local displayScore = calculateDisplayScore()
    if displayScore >= 20 then
        -- Draw a different latte art image based on display score
        local maxImages = #CURRENT_LATTE_ART.images
        local imageIndex = math.min(maxImages, math.floor(displayScore / (100 / maxImages)))

        -- Ensure imageIndex is always one of the valid values (20, 40, 60, 80, 100)
        local validIndices = {20, 40, 60, 80, 100}
        local closestIndex = validIndices[1]
        for _, index in ipairs(validIndices) do
            if math.abs(displayScore - index) < math.abs(displayScore - closestIndex) then
                closestIndex = index
            end
        end
        imageIndex = closestIndex

        love.graphics.draw(CURRENT_LATTE_ART.images[imageIndex], cupX, cupY, 0, pixelScale, pixelScale)
    end

    if currentSubState == SUB_STATE.DRAW_ART then

        -- Draw transparent ghost image of the final latte art as a guide
        love.graphics.setColor(1, 1, 1, 0.15) -- Very transparent white
        love.graphics.draw(CURRENT_LATTE_ART.images[100], cupX, cupY, 0, pixelScale, pixelScale)
        love.graphics.setColor(1, 1, 1, 1) -- Reset to full opacity
        
        -- Draw start point indicator (pulsing circle)
        local startX, startY = getStartPoint()
        local pulseSize = math.sin(love.timer.getTime() * 3) * 5 * pixelScale + startPointRadius
        
        -- Outer glow
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.circle("fill", startX, startY, pulseSize)
        
        -- Inner circle
        love.graphics.setColor(0.2, 0.8, 0.3, 0.8)
        love.graphics.circle("fill", startX, startY, startPointRadius * 0.6)
        
        -- Border
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setLineWidth(2 * pixelScale)
        love.graphics.circle("line", startX, startY, startPointRadius * 0.6)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(1, 1, 1, 1) -- Reset

        -- draw user's path if within drawTolerance (with smooth curves)
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
                local smoothPoints = getSmoothCurve(filteredPoints)
                if #smoothPoints >= 4 then
                    love.graphics.setColor(1, 1, 1, 0.4) -- More transparent so image shows through
                    love.graphics.setLineWidth(3 * pixelScale)
                    love.graphics.line(smoothPoints)
                    love.graphics.setLineWidth(1)
                end
            end
        end

        -- match percentage and component scores (smaller, less intrusive)
        local matchPercentage = computeMatchPercentage()
        local displayScore = calculateDisplayScore()
        local completion = math.floor(calculatePathCompletion() * 100)
        
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("Accuracy: " .. matchPercentage .. "%  Display: " .. displayScore .. "%  Complete: " .. completion .. "%", 10, 10)
        
        -- Debug info showing all accuracy components
        if #linePoints >= 4 then
            local startAcc = math.floor(checkStartPointAccuracy() * 100)
            local lengthAcc = math.floor(checkLengthAccuracy() * 100)
            local progAcc = math.floor(checkPathProgression() * 100)
            local keyAcc = math.floor(checkKeyPointsAccuracy() * 100)
            local distAcc = math.floor(checkAveragePathDistance() * 100)
            love.graphics.print(string.format("S:%d%% L:%d%% P:%d%% K:%d%% D:%d%%", 
                startAcc, lengthAcc, progAcc, keyAcc, distAcc), 10, 30)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    elseif currentSubState == SUB_STATE.JUDGE_ART then
        -- Draw improved scoring popup with animation
        local finalMatch = computeMatchPercentage()
        local popupAlpha = math.min(judgeTimer * 2, 1) -- Fade in over 0.5 seconds
        
        -- Semi-transparent overlay
        love.graphics.setColor(0, 0, 0, 0.7 * popupAlpha)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
        
        -- Popup background
        local popupWidth = 400 * pixelScale
        local popupHeight = 300 * pixelScale
        local popupX = (windowWidth - popupWidth) / 2
        local popupY = (windowHeight - popupHeight) / 2
        
        love.graphics.setColor(0.95, 0.9, 0.85, popupAlpha)
        love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 15 * pixelScale, 15 * pixelScale)
        
        -- Border
        love.graphics.setColor(0.4, 0.3, 0.2, popupAlpha)
        love.graphics.setLineWidth(3 * pixelScale)
        love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 15 * pixelScale, 15 * pixelScale)
        love.graphics.setLineWidth(1)
        
        -- Title
        love.graphics.setColor(0.3, 0.2, 0.1, popupAlpha)
        local titleFont = love.graphics.getFont()
        local titleText = "Latte Art Complete!"
        local titleWidth = titleFont:getWidth(titleText)
        love.graphics.print(titleText, popupX + (popupWidth - titleWidth) / 2, popupY + 30 * pixelScale)
        
        -- Score with color based on performance (harsher thresholds)
        local scoreColor = {0.5, 0.5, 0.5} -- Gray for low scores
        local rating = "Needs Practice"
        if finalMatch >= 90 then
            scoreColor = {0.2, 0.6, 0.2} -- Green
            rating = "Excellent!"
        elseif finalMatch >= 75 then
            scoreColor = {0.4, 0.5, 0.2} -- Yellow-green
            rating = "Great!"
        elseif finalMatch >= 60 then
            scoreColor = {0.7, 0.5, 0.1} -- Orange
            rating = "Good!"
        elseif finalMatch >= 40 then
            scoreColor = {0.7, 0.4, 0.2} -- Light brown
            rating = "Keep Trying!"
        end
        
        -- Large percentage score
        love.graphics.setColor(scoreColor[1], scoreColor[2], scoreColor[3], popupAlpha)
        local scoreText = finalMatch .. "%"
        local scoreWidth = titleFont:getWidth(scoreText) * 2
        love.graphics.print(scoreText, popupX + (popupWidth - scoreWidth) / 2, popupY + 90 * pixelScale, 0, 2, 2)
        
        -- Rating text
        love.graphics.setColor(0.3, 0.2, 0.1, popupAlpha)
        local ratingWidth = titleFont:getWidth(rating)
        love.graphics.print(rating, popupX + (popupWidth - ratingWidth) / 2, popupY + 160 * pixelScale)
        
        -- Instructions
        love.graphics.setColor(0.4, 0.3, 0.2, popupAlpha * 0.8)
        local instructText = "Click to continue"
        local instructWidth = titleFont:getWidth(instructText)
        love.graphics.print(instructText, popupX + (popupWidth - instructWidth) / 2, popupY + 220 * pixelScale)
        
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
    end

    -- Draw milk pourer at cursor position
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    love.graphics.setColor(1, 1, 1)
    
    -- Choose milk pourer image based on mouse state
    local milkPourerImage = love.mouse.isDown(1) and assets.milkPourer.enabled or assets.milkPourer.disabled
    
    -- Draw milk pourer with cursor at upper-left corner, with offset for enabled state
    local offsetY = love.mouse.isDown(1) and (-20 * pixelScale) or 0
    love.graphics.draw(milkPourerImage, mouseX, mouseY + offsetY, 0, pixelScale, pixelScale)
    
    -- Display mouse position for debugging
    love.graphics.print("Mouse: (" .. mouseX .. ", " .. mouseY .. ")", windowWidth - 150, 10)
end


local pointAddTimer = 0 -- Timer to control point addition
local hasDrawn = false -- Track if the user has started drawing
local wasMouseDown = false -- Track previous mouse state
local judgeWasMouseDown = false -- Track mouse state in judge mode


function latteArtState:update(dt)
    if currentSubState == SUB_STATE.DRAW_ART then
        local mouseDown = love.mouse.isDown(1)
        pointAddTimer = pointAddTimer + dt

        if mouseDown then
            hasDrawn = true
            -- Add a new point only if the timer exceeds the threshold (smoother line)
            if pointAddTimer >= 0.03 then -- Further reduced for even smoother drawing
                local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
                
                -- Only add point if it's different enough from the last point (avoid duplicates)
                local shouldAdd = true
                if #linePoints >= 2 then
                    local lastX, lastY = linePoints[#linePoints - 1], linePoints[#linePoints]
                    local dist = math.sqrt((mouseX - lastX)^2 + (mouseY - lastY)^2)
                    if dist < 2 * pixelScale then
                        shouldAdd = false
                    end
                end
                
                if shouldAdd then
                    table.insert(linePoints, mouseX)
                    table.insert(linePoints, mouseY)
                    pointAddTimer = 0

                    -- Limit the number of points to avoid performance issues
                    if #linePoints > 2000 then -- Increased limit for smoother lines
                        table.remove(linePoints, 1)
                        table.remove(linePoints, 1)
                    end
                end
            end
        end

        -- If the user was drawing and now released the mouse, go to judge mode
        if not mouseDown and wasMouseDown and hasDrawn then
            currentSubState = SUB_STATE.JUDGE_ART
            judgeTimer = 0 -- Reset judge timer for animation
        end

        wasMouseDown = mouseDown
    elseif currentSubState == SUB_STATE.JUDGE_ART then
        judgeTimer = judgeTimer + dt
        
        -- Handle click to continue (after popup has faded in)
        local mouseDown = love.mouse.isDown(1)
        if judgeTimer > 0.5 and not mouseDown and judgeWasMouseDown then
            -- Reset state for next round
            linePoints = {}
            hasDrawn = false
            wasMouseDown = false
            judgeWasMouseDown = false
            judgeTimer = 0
            currentSubState = SUB_STATE.DRAW_ART
            -- Pick a new random latte art
            CURRENT_LATTE_ART = latteArtConfig[math.random(#latteArtConfig)]
        end
        judgeWasMouseDown = mouseDown
    end
end
