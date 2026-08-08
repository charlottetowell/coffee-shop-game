-- shared run state, reset via resetShopRun() (src/states/shop.lua)
score = 0
drinksMade = 0

-- accumulated only while gameplay states update (never real wall-clock time),
-- so it naturally freezes whenever the pause overlay is active
gameTime = 0
