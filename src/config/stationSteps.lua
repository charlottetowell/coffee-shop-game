-- derives a drink's step sequence from its category/temperature so steps
-- aren't hand-duplicated per drink
local STATION_STEP_TEMPLATES = {
    COFFEE = {"GRIND", "FROTH_MILK", "POUR"},
    MATCHA = {"WHISK", "FROTH_MILK", "POUR"},
    BLENDER = {"CHOOSE_INGREDIENTS", "BLEND"},
}

local function getStepsForDrink(drink)
    local steps = {}
    for _, step in ipairs(STATION_STEP_TEMPLATES[drink.category]) do
        if not (step == "FROTH_MILK" and drink.temperature == "COLD") then
            table.insert(steps, step)
        end
    end
    return steps
end

return {
    STATION_STEP_TEMPLATES = STATION_STEP_TEMPLATES,
    getStepsForDrink = getStepsForDrink
}
