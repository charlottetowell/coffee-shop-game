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

local playButton = {
    x = windowWidth * 0.75,
    y = windowHeight * 0.75,
    image = assets.playButton,
    hoveredImage = assets.playButtonHover,
    scale = pixelScale
}

function menuState:update(dt)
    if suit.ImageButton(playButton.image, {hovered=playButton.hoveredImage, scale=playButton.scale}, playButton.x, playButton.y).hit then
            print("Button clicked!")
    end
end
