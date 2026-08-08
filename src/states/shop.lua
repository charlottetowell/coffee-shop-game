require "src/states/init"
require "src/states/registry"

local drinksConfig = require("src/config/drinksConfig")

shopState = GameState:new({
    key = "SHOP"
    ,transition_to_keys = {COFFEE_MACHINE = true, MATCHA = true, BLENDER = true}
})

StateRegistry:register(shopState.key, shopState)

local CUSTOMER_STATE = {
    WALKING_IN = "WALKING_IN",
    WAITING = "WAITING",
}

local MAX_CUSTOMERS = 3
local PATIENCE_SECONDS = 15
local WALK_SPEED = 40 -- units/sec, scaled by pixelScale
local MIN_SPAWN_INTERVAL = 3
local MAX_SPAWN_INTERVAL = 6
local MAX_VISIBLE_DOCKETS = 5

local customers = {}
local dockets = {}
local nextCustomerId = 1
local nextDocketId = 1
local spawnTimer = 0
local nextSpawnAt = 0
local wasMouseDown = false

local function totalWeight()
    local total = 0
    for _, drink in ipairs(drinksConfig) do
        total = total + drink.weight
    end
    return total
end

local function pickRandomDrink()
    local roll = math.random() * totalWeight()
    local cumulative = 0
    for _, drink in ipairs(drinksConfig) do
        cumulative = cumulative + drink.weight
        if roll <= cumulative then
            return drink
        end
    end
    return drinksConfig[#drinksConfig]
end

local function customerSlotX(slotIndex)
    local slotWidth = windowWidth / MAX_CUSTOMERS
    return slotWidth * (slotIndex - 1) + slotWidth / 2
end

local function freeSlot()
    local taken = {}
    for _, customer in ipairs(customers) do
        taken[customer.slot] = true
    end
    for i = 1, MAX_CUSTOMERS do
        if not taken[i] then return i end
    end
    return nil
end

local function spawnCustomer()
    local slot = freeSlot()
    if not slot then return end

    local drink = pickRandomDrink()
    table.insert(customers, {
        id = nextCustomerId,
        drink = drink,
        slot = slot,
        x = -20 * pixelScale,
        targetX = customerSlotX(slot),
        state = CUSTOMER_STATE.WALKING_IN,
        waitStart = nil,
    })
    nextCustomerId = nextCustomerId + 1
end

local function floorY()
    return windowHeight * shopCounter.FLOOR_RATIO
end

local function customerBubbleRect(customer)
    local size = 14 * pixelScale
    return customer.x - size / 2, floorY() - size - 22 * pixelScale, size, size
end

local function removeCustomerAt(index)
    table.remove(customers, index)
end

local function takeOrder(index)
    local customer = customers[index]
    table.insert(dockets, {
        id = nextDocketId,
        drink = customer.drink,
        orderedAt = gameTime,
    })
    nextDocketId = nextDocketId + 1
    sounds.chaChing:clone():play()
    removeCustomerAt(index)
end

-- called by stations when a drink finishes; scans oldest-first for a
-- matching docket rather than binding to one up front (see plan notes)
function fulfillDrink(drink)
    for i, docket in ipairs(dockets) do
        if docket.drink.id == drink.id then
            local waitSeconds = gameTime - docket.orderedAt
            local points = math.max(10, 100 - 2 * waitSeconds)
            score = score + points
            drinksMade = drinksMade + 1
            table.remove(dockets, i)
            return points
        end
    end
    return 0
end

function resetShopRun()
    customers = {}
    dockets = {}
    nextCustomerId = 1
    nextDocketId = 1
    spawnTimer = 0
    nextSpawnAt = MIN_SPAWN_INTERVAL + math.random() * (MAX_SPAWN_INTERVAL - MIN_SPAWN_INTERVAL)
    score = 0
    drinksMade = 0
    gameTime = 0
end

local function drawDockets()
    love.graphics.setFont(fonts.cousineBold)
    local cardSize = 12 * pixelScale
    local spacing = 2 * pixelScale
    local x = 2 * pixelScale
    local y = 2 * pixelScale

    local visibleCount = math.min(#dockets, MAX_VISIBLE_DOCKETS)
    for i = 1, visibleCount do
        local docket = dockets[i]
        local c = docket.drink.colour

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x, y, cardSize, cardSize)
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", x + 1 * pixelScale, y + 1 * pixelScale, cardSize - 2 * pixelScale, cardSize - 2 * pixelScale)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", x, y, cardSize, cardSize)

        x = x + cardSize + spacing
    end

    if #dockets > MAX_VISIBLE_DOCKETS then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("+" .. (#dockets - MAX_VISIBLE_DOCKETS), x, y)
    end
    setColourWhite()
end

local function drawCustomers()
    local bodyWidth = 12 * pixelScale
    local bodyHeight = 20 * pixelScale

    for _, customer in ipairs(customers) do
        local c = customer.drink.colour
        love.graphics.setColor(c[1] * 0.5, c[2] * 0.5, c[3] * 0.5)
        love.graphics.rectangle("fill", customer.x - bodyWidth / 2, floorY() - bodyHeight, bodyWidth, bodyHeight)

        if customer.state == CUSTOMER_STATE.WAITING then
            local bx, by, bw, bh = customerBubbleRect(customer)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", bx, by, bw, bh)
            love.graphics.setColor(c[1], c[2], c[3])
            love.graphics.rectangle("fill", bx + 2 * pixelScale, by + 2 * pixelScale, bw - 4 * pixelScale, bh - 4 * pixelScale)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", bx, by, bw, bh)
        end
    end
    setColourWhite()
end

function shopState:draw()
    shopCounter:draw()
    drawCustomers()
    drawDockets()
    PauseButton.draw()

    love.graphics.setFont(fonts.cousineBold)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 2 * pixelScale, windowHeight - 12 * pixelScale)
    setColourWhite()
end

function shopState:update(dt)
    gameTime = gameTime + dt

    if PauseButton.update() then return end

    spawnTimer = spawnTimer + dt
    if spawnTimer >= nextSpawnAt then
        spawnTimer = 0
        nextSpawnAt = MIN_SPAWN_INTERVAL + math.random() * (MAX_SPAWN_INTERVAL - MIN_SPAWN_INTERVAL)
        spawnCustomer()
    end

    -- walk-in / patience, iterated backwards so removals are safe
    for i = #customers, 1, -1 do
        local customer = customers[i]
        if customer.state == CUSTOMER_STATE.WALKING_IN then
            local dx = customer.targetX - customer.x
            local step = WALK_SPEED * pixelScale * dt
            if math.abs(dx) <= step then
                customer.x = customer.targetX
                customer.state = CUSTOMER_STATE.WAITING
                customer.waitStart = gameTime
            else
                customer.x = customer.x + (dx > 0 and step or -step)
            end
        elseif customer.state == CUSTOMER_STATE.WAITING then
            if gameTime - customer.waitStart > PATIENCE_SECONDS then
                removeCustomerAt(i)
            end
        end
    end

    local mouseDown = love.mouse.isDown(1)
    local clicked = mouseDown and not wasMouseDown
    wasMouseDown = mouseDown

    if not clicked then return end

    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()

    for i, customer in ipairs(customers) do
        if customer.state == CUSTOMER_STATE.WAITING then
            local bx, by, bw, bh = customerBubbleRect(customer)
            if mouseX >= bx and mouseX <= bx + bw and mouseY >= by and mouseY <= by + bh then
                takeOrder(i)
                return
            end
        end
    end

    for _, rect in ipairs(shopCounter.getStationRects()) do
        if mouseX >= rect.x and mouseX <= rect.x + rect.w and mouseY >= rect.y and mouseY <= rect.y + rect.h then
            StateRegistry:transitionTo(rect.station.key)
            return
        end
    end
end
