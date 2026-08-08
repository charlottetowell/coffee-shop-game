-- the POUR step for drinks with hasLatteArt: drag-path matching against a
-- pattern from latteArtConfig, deterministically chosen by the calling
-- station (drink.latteArtPattern) rather than random. Accuracy is shown for
-- flavor only -- it never gates completion; the player continues by clicking
-- the popup, which fires the onComplete callback given to :start().
local latteArtConfig = require("src/config/latteArtConfig")

LatteArtStep = {}

local SUB_STATE = {
    DRAW_ART = "DRAW_ART",
    JUDGE_ART = "JUDGE_ART"
}

local linePoints = {}
local currentSubState = SUB_STATE.DRAW_ART
local currentPattern = nil
local onCompleteCallback = nil

local drawTolerance = 50 * pixelScale
local matchTolerance = 50 * pixelScale
local judgeTimer = 0
local startPointRadius = 15 * pixelScale

local pointAddTimer = 0
local hasDrawn = false
local wasMouseDown = false
local judgeWasMouseDown = false

local function cupPosition()
    local cupX = (windowWidth - assets.coffeeBase:getWidth() * pixelScale) / 2
    local cupY = (windowHeight - assets.coffeeBase:getHeight() * pixelScale) / 2
    return cupX, cupY
end

local function patternScale()
    local latteArtImage = currentPattern.images[100]
    return latteArtImage:getWidth() / 54, latteArtImage:getHeight() / 54
end

local function isPointNearPath(x, y)
    local cupX, cupY = cupPosition()
    local scaleFactorX, scaleFactorY = patternScale()

    for i = 1, #currentPattern.path, 2 do
        local px = currentPattern.path[i] * scaleFactorX * pixelScale + cupX
        local py = currentPattern.path[i + 1] * scaleFactorY * pixelScale + cupY
        local distance = math.sqrt((x - px)^2 + (y - py)^2)
        if distance <= drawTolerance then
            return true
        end
    end
    return false
end

local function calculatePathLength(path)
    local scaleFactorX, scaleFactorY = patternScale()

    local length = 0
    for i = 1, #path - 2, 2 do
        local x1, y1 = path[i] * scaleFactorX * pixelScale, path[i + 1] * scaleFactorY * pixelScale
        local x2, y2 = path[i + 2] * scaleFactorX * pixelScale, path[i + 3] * scaleFactorY * pixelScale
        length = length + math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end
    return length
end

local function getStartPoint()
    local cupX, cupY = cupPosition()
    local scaleFactorX, scaleFactorY = patternScale()

    local startX = currentPattern.path[1] * scaleFactorX * pixelScale + cupX
    local startY = currentPattern.path[2] * scaleFactorY * pixelScale + cupY

    return startX, startY
end

local function checkStartPointAccuracy()
    if #linePoints < 2 then return 0 end

    local startX, startY = getStartPoint()
    local userStartX, userStartY = linePoints[1], linePoints[2]
    local distance = math.sqrt((userStartX - startX)^2 + (userStartY - startY)^2)

    local accuracy = math.max(0, 1 - (distance / (100 * pixelScale)))
    return accuracy
end

local function checkLengthAccuracy()
    if #linePoints < 4 then return 0 end

    local userLength = 0
    for i = 1, #linePoints - 2, 2 do
        local x1, y1 = linePoints[i], linePoints[i + 1]
        local x2, y2 = linePoints[i + 2], linePoints[i + 3]
        userLength = userLength + math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    end

    local targetLength = calculatePathLength(currentPattern.path)
    local lengthRatio = userLength / targetLength

    if lengthRatio >= 0.8 and lengthRatio <= 1.2 then
        return 1.0
    elseif lengthRatio < 0.8 then
        return math.max(0, lengthRatio / 0.8)
    else
        return math.max(0, 1 - ((lengthRatio - 1.2) * 0.5))
    end
end

local function getClosestPathPoint(x, y)
    local cupX, cupY = cupPosition()
    local scaleFactorX, scaleFactorY = patternScale()

    local minDist = math.huge
    local closestIndex = 1
    local pathLength = 0
    local lengthToClosest = 0

    for i = 1, #currentPattern.path, 2 do
        local px = currentPattern.path[i] * scaleFactorX * pixelScale + cupX
        local py = currentPattern.path[i + 1] * scaleFactorY * pixelScale + cupY
        local distance = math.sqrt((x - px)^2 + (y - py)^2)

        if distance < minDist then
            minDist = distance
            closestIndex = i
            lengthToClosest = pathLength
        end

        if i > 1 then
            local prevPx = currentPattern.path[i - 2] * scaleFactorX * pixelScale + cupX
            local prevPy = currentPattern.path[i - 1] * scaleFactorY * pixelScale + cupY
            pathLength = pathLength + math.sqrt((px - prevPx)^2 + (py - prevPy)^2)
        end
    end

    local progress = pathLength > 0 and (lengthToClosest / pathLength) or 0
    return minDist, progress, closestIndex
end

local function checkPathProgression()
    if #linePoints < 6 then return 0 end

    local progressions = {}
    local sampleInterval = math.max(4, math.floor(#linePoints / 20))

    for i = 1, #linePoints - 2, sampleInterval do
        local x, y = linePoints[i], linePoints[i + 1]
        local dist, progress = getClosestPathPoint(x, y)

        if dist <= matchTolerance * 2 then
            table.insert(progressions, progress)
        end
    end

    if #progressions < 3 then return 0 end

    local orderedCorrectly = 0
    local totalComparisons = 0

    for i = 1, #progressions - 1 do
        totalComparisons = totalComparisons + 1
        local diff = progressions[i + 1] - progressions[i]

        if diff >= -0.05 then
            orderedCorrectly = orderedCorrectly + 1
        elseif diff >= -0.15 then
            orderedCorrectly = orderedCorrectly + 0.5
        end
    end

    return totalComparisons > 0 and (orderedCorrectly / totalComparisons) or 0
end

local function checkKeyPointsAccuracy()
    if #linePoints < 6 then return 0 end

    local cupX, cupY = cupPosition()
    local scaleFactorX, scaleFactorY = patternScale()

    local keyPointIndices = {1, math.floor(#currentPattern.path * 0.25),
                            math.floor(#currentPattern.path * 0.5),
                            math.floor(#currentPattern.path * 0.75),
                            #currentPattern.path - 1}

    local totalAccuracy = 0
    local pointsChecked = 0

    for _, idx in ipairs(keyPointIndices) do
        if idx > 0 and idx < #currentPattern.path then
            local targetX = currentPattern.path[idx] * scaleFactorX * pixelScale + cupX
            local targetY = currentPattern.path[idx + 1] * scaleFactorY * pixelScale + cupY

            local minDist = math.huge
            for i = 1, #linePoints, 2 do
                local userX, userY = linePoints[i], linePoints[i + 1]
                local dist = math.sqrt((userX - targetX)^2 + (userY - targetY)^2)
                minDist = math.min(minDist, dist)
            end

            local accuracy = math.max(0, 1 - (minDist / (matchTolerance * 3)))
            totalAccuracy = totalAccuracy + accuracy
            pointsChecked = pointsChecked + 1
        end
    end

    return pointsChecked > 0 and (totalAccuracy / pointsChecked) or 0
end

local function checkAveragePathDistance()
    if #linePoints < 4 then return 0 end

    local totalDistance = 0
    local pointsChecked = 0

    for i = 1, #linePoints, 2 do
        local x, y = linePoints[i], linePoints[i + 1]
        local dist = getClosestPathPoint(x, y)

        totalDistance = totalDistance + dist
        pointsChecked = pointsChecked + 1
    end

    local avgDist = pointsChecked > 0 and (totalDistance / pointsChecked) or math.huge

    return math.max(0, 1 - (avgDist / (matchTolerance * 2)))
end

local function computeMatchPercentage()
    if #linePoints < 4 then return 0 end

    local startAccuracy = checkStartPointAccuracy()
    local lengthAccuracy = checkLengthAccuracy()
    local progressionAccuracy = checkPathProgression()
    local keyPointsAccuracy = checkKeyPointsAccuracy()
    local avgDistanceAccuracy = checkAveragePathDistance()

    local finalScore = (startAccuracy * 0.15) +
                       (lengthAccuracy * 0.15) +
                       (progressionAccuracy * 0.25) +
                       (keyPointsAccuracy * 0.25) +
                       (avgDistanceAccuracy * 0.20)

    return math.min(math.floor(finalScore * 100), 100)
end

local function calculatePathCompletion()
    if #linePoints < 2 then return 0 end

    local cupX, cupY = cupPosition()
    local scaleFactorX, scaleFactorY = patternScale()

    local pathSegmentsCovered = {}
    for i = 1, #currentPattern.path - 2, 2 do
        pathSegmentsCovered[i] = false
    end

    for i = 1, #linePoints, 2 do
        local userX, userY = linePoints[i], linePoints[i + 1]

        local minDist = math.huge
        local closestSegment = 1

        for j = 1, #currentPattern.path - 2, 2 do
            local pathX = currentPattern.path[j] * scaleFactorX * pixelScale + cupX
            local pathY = currentPattern.path[j + 1] * scaleFactorY * pixelScale + cupY
            local dist = math.sqrt((userX - pathX)^2 + (userY - pathY)^2)

            if dist < minDist then
                minDist = dist
                closestSegment = j
            end
        end

        if minDist <= matchTolerance * 1.5 then
            pathSegmentsCovered[closestSegment] = true
        end
    end

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

local function calculateDisplayScore()
    if #linePoints < 2 then return 0 end

    local accuracy = computeMatchPercentage() / 100
    local completion = calculatePathCompletion()

    local displayScore = (accuracy * 0.4) + (completion * 0.6)

    return math.floor(displayScore * 100)
end

local function getCatmullRomPoint(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t

    local v0 = (p2 - p0) * 0.5
    local v1 = (p3 - p1) * 0.5

    return (2 * p1 - 2 * p2 + v0 + v1) * t3 +
           (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 +
           v0 * t + p1
end

local function getSmoothCurve(points)
    if #points < 8 then return points end

    local smoothPoints = {}
    local segments = 10

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

    if #points >= 2 then
        table.insert(smoothPoints, points[#points - 1])
        table.insert(smoothPoints, points[#points])
    end

    return smoothPoints
end

-- pattern comes from drink.latteArtPattern; onComplete fires once the player
-- clicks through the score popup
function LatteArtStep:start(patternName, onComplete)
    for _, pattern in ipairs(latteArtConfig) do
        if pattern.name == patternName then
            currentPattern = pattern
            break
        end
    end

    onCompleteCallback = onComplete
    linePoints = {}
    currentSubState = SUB_STATE.DRAW_ART
    judgeTimer = 0
    pointAddTimer = 0
    hasDrawn = false
    wasMouseDown = false
    judgeWasMouseDown = false
end

function LatteArtStep:draw()
    local cupX, cupY = cupPosition()

    local displayScore = calculateDisplayScore()
    if displayScore >= 20 then
        local maxImages = #currentPattern.images
        local validIndices = {20, 40, 60, 80, 100}
        local closestIndex = validIndices[1]
        for _, index in ipairs(validIndices) do
            if math.abs(displayScore - index) < math.abs(displayScore - closestIndex) then
                closestIndex = index
            end
        end

        love.graphics.draw(currentPattern.images[closestIndex], cupX, cupY, 0, pixelScale, pixelScale)
    end

    if currentSubState == SUB_STATE.DRAW_ART then
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.draw(currentPattern.images[100], cupX, cupY, 0, pixelScale, pixelScale)
        love.graphics.setColor(1, 1, 1, 1)

        local startX, startY = getStartPoint()
        local pulseSize = math.sin(love.timer.getTime() * 3) * 5 * pixelScale + startPointRadius

        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.circle("fill", startX, startY, pulseSize)

        love.graphics.setColor(0.2, 0.8, 0.3, 0.8)
        love.graphics.circle("fill", startX, startY, startPointRadius * 0.6)

        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setLineWidth(2 * pixelScale)
        love.graphics.circle("line", startX, startY, startPointRadius * 0.6)
        love.graphics.setLineWidth(1)

        love.graphics.setColor(1, 1, 1, 1)

        if #linePoints >= 4 then
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
                    love.graphics.setColor(1, 1, 1, 0.4)
                    love.graphics.setLineWidth(3 * pixelScale)
                    love.graphics.line(smoothPoints)
                    love.graphics.setLineWidth(1)
                end
            end
        end

        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.setFont(fonts.cousineBold)
        love.graphics.print("Accuracy: " .. computeMatchPercentage() .. "%", 4 * pixelScale, 4 * pixelScale)

        love.graphics.setColor(1, 1, 1, 1)
    elseif currentSubState == SUB_STATE.JUDGE_ART then
        local finalMatch = computeMatchPercentage()
        local popupAlpha = math.min(judgeTimer * 2, 1)

        love.graphics.setColor(0, 0, 0, 0.7 * popupAlpha)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

        local popupWidth = windowWidth * 0.75
        local popupHeight = windowHeight * 0.6
        local popupX = (windowWidth - popupWidth) / 2
        local popupY = (windowHeight - popupHeight) / 2

        love.graphics.setColor(0.95, 0.9, 0.85, popupAlpha)
        love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 6 * pixelScale, 6 * pixelScale)

        love.graphics.setColor(0.4, 0.3, 0.2, popupAlpha)
        love.graphics.setLineWidth(2 * pixelScale)
        love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 6 * pixelScale, 6 * pixelScale)
        love.graphics.setLineWidth(1)

        love.graphics.setFont(fonts.cousineBold)

        love.graphics.setColor(0.3, 0.2, 0.1, popupAlpha)
        love.graphics.printf("Pour Complete!", popupX, popupY + popupHeight * 0.12, popupWidth, "center")

        local scoreColor = {0.5, 0.5, 0.5}
        local rating = "Needs Practice"
        if finalMatch >= 90 then
            scoreColor = {0.2, 0.6, 0.2}
            rating = "Excellent!"
        elseif finalMatch >= 75 then
            scoreColor = {0.4, 0.5, 0.2}
            rating = "Great!"
        elseif finalMatch >= 60 then
            scoreColor = {0.7, 0.5, 0.1}
            rating = "Good!"
        elseif finalMatch >= 40 then
            scoreColor = {0.7, 0.4, 0.2}
            rating = "Keep Trying!"
        end

        love.graphics.setColor(scoreColor[1], scoreColor[2], scoreColor[3], popupAlpha)
        love.graphics.printf(finalMatch .. "%", popupX, popupY + popupHeight * 0.35, popupWidth, "center")

        love.graphics.setColor(0.3, 0.2, 0.1, popupAlpha)
        love.graphics.printf(rating, popupX, popupY + popupHeight * 0.6, popupWidth, "center")

        love.graphics.setColor(0.4, 0.3, 0.2, popupAlpha * 0.8)
        love.graphics.printf("Click to continue", popupX, popupY + popupHeight * 0.82, popupWidth, "center")

        love.graphics.setColor(1, 1, 1, 1)
    end

    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    love.graphics.setColor(1, 1, 1)

    local milkPourerImage = love.mouse.isDown(1) and assets.milkPourer.enabled or assets.milkPourer.disabled
    local offsetY = love.mouse.isDown(1) and (-20 * pixelScale) or 0
    love.graphics.draw(milkPourerImage, mouseX, mouseY + offsetY, 0, pixelScale, pixelScale)
end

function LatteArtStep:update(dt)
    if currentSubState == SUB_STATE.DRAW_ART then
        local mouseDown = love.mouse.isDown(1)
        pointAddTimer = pointAddTimer + dt

        if mouseDown then
            hasDrawn = true
            if pointAddTimer >= 0.03 then
                local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()

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

                    if #linePoints > 2000 then
                        table.remove(linePoints, 1)
                        table.remove(linePoints, 1)
                    end
                end
            end
        end

        if not mouseDown and wasMouseDown and hasDrawn then
            currentSubState = SUB_STATE.JUDGE_ART
            judgeTimer = 0
        end

        wasMouseDown = mouseDown
    elseif currentSubState == SUB_STATE.JUDGE_ART then
        judgeTimer = judgeTimer + dt

        local mouseDown = love.mouse.isDown(1)
        if judgeTimer > 0.5 and not mouseDown and judgeWasMouseDown then
            local callback = onCompleteCallback
            onCompleteCallback = nil
            linePoints = {}
            hasDrawn = false
            wasMouseDown = false
            judgeWasMouseDown = false
            judgeTimer = 0
            currentSubState = SUB_STATE.DRAW_ART
            if callback then callback() end
        end
        judgeWasMouseDown = mouseDown
    end
end
