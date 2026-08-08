-- blender's CHOOSE_INGREDIENTS step: click the icon(s) matching the drink's
-- ingredients (plus a couple of decoys); auto-completes once all are picked,
-- no penalty for wrong clicks
IngredientPicker = {}

local ALL_INGREDIENTS = {
    {id = "banana", colour = {0.95, 0.85, 0.25}},
    {id = "strawberry", colour = {0.9, 0.3, 0.4}},
    {id = "ice", colour = {0.8, 0.9, 0.95}},
    {id = "milk", colour = {0.95, 0.95, 0.9}},
}

local requiredIngredients = {}
local selected = {}
local onCompleteCallback = nil
local wasMouseDown = false

function IngredientPicker:start(drink, onComplete)
    requiredIngredients = {}
    for _, id in ipairs(drink.ingredients or {}) do
        requiredIngredients[id] = true
    end
    selected = {}
    onCompleteCallback = onComplete
    wasMouseDown = false
end

function IngredientPicker:getButtonRects()
    local buttonSize = 16 * pixelScale
    local spacing = 4 * pixelScale
    local totalWidth = (#ALL_INGREDIENTS * buttonSize) + ((#ALL_INGREDIENTS - 1) * spacing)
    local startX = (windowWidth - totalWidth) / 2
    local y = windowHeight * 0.55

    local rects = {}
    for i, ingredient in ipairs(ALL_INGREDIENTS) do
        local x = startX + (i - 1) * (buttonSize + spacing)
        table.insert(rects, {ingredient = ingredient, x = x, y = y, w = buttonSize, h = buttonSize})
    end
    return rects
end

local function allSelected()
    for id, _ in pairs(requiredIngredients) do
        if not selected[id] then return false end
    end
    return true
end

function IngredientPicker:update(dt)
    local mouseDown = love.mouse.isDown(1)
    local clicked = mouseDown and not wasMouseDown
    wasMouseDown = mouseDown

    if clicked then
        local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
        for _, rect in ipairs(self:getButtonRects()) do
            if mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h then
                if requiredIngredients[rect.ingredient.id] then
                    selected[rect.ingredient.id] = true
                end
            end
        end
    end

    if onCompleteCallback and allSelected() then
        local callback = onCompleteCallback
        onCompleteCallback = nil
        callback()
    end
end

function IngredientPicker:draw()
    setColourWhite()
    love.graphics.setFont(fonts.cousineBold)
    love.graphics.printf("Choose ingredients", 0, windowHeight * 0.55 - 14 * pixelScale, windowWidth, "center")

    for _, rect in ipairs(self:getButtonRects()) do
        local c = rect.ingredient.colour
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)

        if selected[rect.ingredient.id] then
            love.graphics.setColor(0.2, 0.9, 0.3)
            love.graphics.setLineWidth(2 * pixelScale)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(1 * pixelScale)
        end
        love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
        love.graphics.setLineWidth(1)
    end
    setColourWhite()
end
