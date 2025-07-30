require "src/states/init"
require "src/states/registry"

menuState = GameState:new({
    key = "MAIN_MENU"
    ,transition_to_key = "INTRO"
})

-- register state
StateRegistry:register(menuState.key, menuState)


function menuState:draw()
    -- draw 
    cafeOutside:draw()

    -- play button
    suit.draw()
end

function menuState:update(dt)
    if suit.ImageButton(assets.playButton, {hovered=assets.playButtonHover, scale=pixelScale}, windowWidth * 0.60, windowHeight * 0.75).hit then
            print("Button clicked!")
    end
end
