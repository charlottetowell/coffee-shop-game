-- shared flow driving each station: pick a drink of that station's category,
-- run its steps (from stationSteps.getStepsForDrink) via HoldToFillMeter /
-- LatteArtStep / IngredientPicker as appropriate, then fulfillDrink() and
-- return to SHOP. One instance per station (coffeeMachine/matchaStation/
-- blenderStation), each just wires this up to its own GameState + scene.
local drinksConfig = require("src/config/drinksConfig")
local stationSteps = require("src/config/stationSteps")

local STEP_LABELS = {
    GRIND = "Grind Beans",
    FROTH_MILK = "Froth Milk",
    WHISK = "Whisk Matcha",
    BLEND = "Blend",
    POUR = "Pour",
}

StationFlow = {}

function StationFlow:new(s)
    local flow = s
    setmetatable(flow, self)
    self.__index = self

    flow:reset()
    return flow
end

function StationFlow:reset()
    self.drink = nil
    self.steps = nil
    self.stepIndex = nil
    self.activeMeter = nil
    self.wasMouseDown = false
end

function StationFlow:drinksForCategory()
    local list = {}
    for _, drink in ipairs(drinksConfig) do
        if drink.category == self.category then
            table.insert(list, drink)
        end
    end
    return list
end

function StationFlow:getDrinkButtonRects()
    local drinks = self:drinksForCategory()
    local buttonWidth = 34 * pixelScale
    local buttonHeight = 14 * pixelScale
    local spacing = 3 * pixelScale
    local totalHeight = (#drinks * buttonHeight) + ((#drinks - 1) * spacing)
    local startY = (windowHeight - totalHeight) / 2
    local x = (windowWidth - buttonWidth) / 2

    local rects = {}
    for i, drink in ipairs(drinks) do
        table.insert(rects, {
            drink = drink,
            x = x, y = startY + (i - 1) * (buttonHeight + spacing),
            w = buttonWidth, h = buttonHeight
        })
    end
    return rects
end

local function hotspotRect()
    local w = 60 * pixelScale
    local h = 10 * pixelScale
    return {
        x = (windowWidth - w) / 2,
        y = windowHeight * 0.55,
        width = w,
        height = h
    }
end

function StationFlow:currentStepType()
    if not self.steps then return nil end
    return self.steps[self.stepIndex]
end

function StationFlow:startCurrentStep()
    local stepType = self:currentStepType()

    if stepType == "POUR" and self.drink.hasLatteArt then
        self.activeMeter = nil
        LatteArtStep:start(self.drink.latteArtPattern, function() self:advanceStep() end)
    elseif stepType == "CHOOSE_INGREDIENTS" then
        self.activeMeter = nil
        IngredientPicker:start(self.drink, function() self:advanceStep() end)
    else
        local hotspot = hotspotRect()
        self.activeMeter = HoldToFillMeter:new({
            duration = 1.2,
            x = hotspot.x, y = hotspot.y,
            width = 60, height = 10,
            hotspot = hotspot,
            label = STEP_LABELS[stepType] or stepType,
        })
    end
end

function StationFlow:startDrink(drink)
    self.drink = drink
    self.steps = stationSteps.getStepsForDrink(drink)
    self.stepIndex = 1
    self:startCurrentStep()
end

function StationFlow:advanceStep()
    sounds.stepComplete:clone():play()
    self.stepIndex = self.stepIndex + 1

    if self.stepIndex > #self.steps then
        fulfillDrink(self.drink)
        self:reset()
        StateRegistry:transitionTo("SHOP")
    else
        self:startCurrentStep()
    end
end

function StationFlow:update(dt)
    if PauseButton.update() then return end

    if not self.drink then
        local mouseDown = love.mouse.isDown(1)
        local clicked = mouseDown and not self.wasMouseDown
        self.wasMouseDown = mouseDown

        if clicked then
            local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
            for _, rect in ipairs(self:getDrinkButtonRects()) do
                if mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h then
                    self:startDrink(rect.drink)
                    return
                end
            end
        end
        return
    end

    local stepType = self:currentStepType()
    if stepType == "POUR" and self.drink.hasLatteArt then
        LatteArtStep:update(dt)
    elseif stepType == "CHOOSE_INGREDIENTS" then
        IngredientPicker:update(dt)
    else
        self.activeMeter:update(dt)
        if self.activeMeter.isComplete then
            self:advanceStep()
        end
    end
end

function StationFlow:draw()
    self.scene:draw()

    love.graphics.setFont(fonts.cousineBold)

    if not self.drink then
        setColourWhite()
        love.graphics.printf("Pick a drink", 0, 4 * pixelScale, windowWidth, "center")

        for _, rect in ipairs(self:getDrinkButtonRects()) do
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
            love.graphics.printf(rect.drink.abbr, rect.x, rect.y + 2 * pixelScale, rect.w, "center")
        end
        setColourWhite()
    else
        local stepType = self:currentStepType()
        if stepType == "POUR" and self.drink.hasLatteArt then
            LatteArtStep:draw()
        elseif stepType == "CHOOSE_INGREDIENTS" then
            IngredientPicker:draw()
        else
            self.activeMeter:draw()
        end

        setColourWhite()
        love.graphics.print("Making: " .. self.drink.name, 2 * pixelScale, windowHeight - 12 * pixelScale)
    end

    PauseButton.draw()
end
