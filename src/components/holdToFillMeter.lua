-- shared "press and hold to fill a progress bar" step mechanic, used by
-- GRIND, FROTH_MILK, WHISK, BLEND and plain POUR station steps
HoldToFillMeter = {
    duration = 1.2
    ,width = 60
    ,height = 8
}

function HoldToFillMeter:new(s)
    local meter = s
    setmetatable(meter, self)
    self.__index = self

    meter.progress = 0
    meter.isComplete = false

    return meter
end

function HoldToFillMeter:isMouseInHotspot()
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    local h = self.hotspot
    return mouseX >= h.x and mouseX <= h.x + h.width
        and mouseY >= h.y and mouseY <= h.y + h.height
end

function HoldToFillMeter:reset()
    self.progress = 0
    self.isComplete = false
end

function HoldToFillMeter:update(dt)
    if self.isComplete then return end

    if love.mouse.isDown(1) and self:isMouseInHotspot() then
        self.progress = math.min(self.duration, self.progress + dt)
        if self.progress >= self.duration then
            self.isComplete = true
        end
    else
        -- drain back down while not actively held, so players can't walk away mid-step
        self.progress = math.max(0, self.progress - dt * 2)
    end
end

function HoldToFillMeter:draw()
    local width = self.width * pixelScale
    local height = self.height * pixelScale
    local fillPct = self.progress / self.duration

    setColourWhite()
    if self.label then
        love.graphics.setFont(fonts.cousineBold)
        love.graphics.printf(self.label, self.x, self.y - 14 * pixelScale, width, "center")
    end

    love.graphics.setColor(0.15, 0.15, 0.15, 0.85)
    love.graphics.rectangle("fill", self.x, self.y, width, height)

    love.graphics.setColor(0.3, 0.8, 0.4)
    love.graphics.rectangle("fill", self.x, self.y, width * fillPct, height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1 * pixelScale)
    love.graphics.rectangle("line", self.x, self.y, width, height)
    love.graphics.setLineWidth(1)
    setColourWhite()
end
