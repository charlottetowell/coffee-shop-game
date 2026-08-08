-- menu of makeable drinks
-- category drives which station makes it (see stationSteps.lua)
-- temperature drives whether the FROTH_MILK step is included
return {
    {
        id = "matcha_latte", name = "Matcha Latte", abbr = "ML",
        temperature = "HOT", category = "MATCHA",
        hasLatteArt = true, latteArtPattern = "Leaf",
        colour = {0.42, 0.62, 0.32}, weight = 3
    },
    {
        id = "iced_matcha_latte", name = "Iced Matcha Latte", abbr = "IML",
        temperature = "COLD", category = "MATCHA",
        hasLatteArt = false,
        colour = {0.62, 0.82, 0.52}, weight = 2
    },
    {
        id = "flat_white", name = "Flat White", abbr = "FW",
        temperature = "HOT", category = "COFFEE",
        hasLatteArt = true, latteArtPattern = "Heart",
        colour = {0.82, 0.72, 0.58}, weight = 4
    },
    {
        id = "iced_latte", name = "Iced Latte", abbr = "IL",
        temperature = "COLD", category = "COFFEE",
        hasLatteArt = false,
        colour = {0.7, 0.55, 0.38}, weight = 3
    },
    {
        id = "mocha", name = "Mocha", abbr = "MO",
        temperature = "HOT", category = "COFFEE",
        hasLatteArt = true, latteArtPattern = "Crescent",
        colour = {0.42, 0.26, 0.16}, weight = 3
    },
    {
        id = "cappuccino", name = "Cappuccino", abbr = "CAP",
        temperature = "HOT", category = "COFFEE",
        hasLatteArt = true, latteArtPattern = "Swan",
        colour = {0.88, 0.8, 0.68}, weight = 4
    },
    {
        id = "banana_smoothie", name = "Banana Smoothie", abbr = "BS",
        temperature = "COLD", category = "BLENDER",
        hasLatteArt = false, ingredients = {"banana"},
        colour = {0.95, 0.85, 0.25}, weight = 2
    },
    {
        id = "strawberry_smoothie", name = "Strawberry Smoothie", abbr = "SS",
        temperature = "COLD", category = "BLENDER",
        hasLatteArt = false, ingredients = {"strawberry"},
        colour = {0.9, 0.3, 0.4}, weight = 2
    },
}
