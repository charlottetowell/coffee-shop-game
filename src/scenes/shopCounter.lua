-- backdrop for the SHOP hub: behind-the-counter POV with block-shape
-- placeholder stations, reused (bare, without stations drawn) as the
-- backdrop base for each station scene too
shopCounter = {}

shopCounter.FLOOR_RATIO = 0.72

local STATIONS = {
    {key = "COFFEE_MACHINE", label = "Coffee", colour = {0.36, 0.22, 0.14}},
    {key = "MATCHA", label = "Matcha", colour = {0.42, 0.62, 0.32}},
    {key = "BLENDER", label = "Blender", colour = {0.55, 0.4, 0.75}},
}

function shopCounter.getStationRects()
    local count = #STATIONS
    local stationWidth = windowWidth / count
    local stationHeight = windowHeight * (1 - shopCounter.FLOOR_RATIO)
    local y = windowHeight - stationHeight

    local rects = {}
    for i, station in ipairs(STATIONS) do
        table.insert(rects, {
            station = station,
            x = (i - 1) * stationWidth,
            y = y,
            w = stationWidth,
            h = stationHeight
        })
    end
    return rects
end

function shopCounter:drawBackdrop()
    setColourWhite()
    love.graphics.setBackgroundColor(colours.ground.r, colours.ground.g, colours.ground.b)

    -- back wall
    love.graphics.setColor(0.75, 0.68, 0.6)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight * shopCounter.FLOOR_RATIO)

    -- floor
    love.graphics.setColor(0.55, 0.42, 0.32)
    love.graphics.rectangle("fill", 0, windowHeight * shopCounter.FLOOR_RATIO, windowWidth, windowHeight * (1 - shopCounter.FLOOR_RATIO))
    setColourWhite()
end

function shopCounter:draw()
    self:drawBackdrop()

    love.graphics.setFont(fonts.cousineBold)
    for _, rect in ipairs(shopCounter.getStationRects()) do
        local c = rect.station.colour
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", rect.x + 2 * pixelScale, rect.y, rect.w - 4 * pixelScale, rect.h)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(rect.station.label, rect.x, rect.y + 4 * pixelScale, rect.w, "center")
    end
    setColourWhite()
end
