require "src/states/init"
require "src/states/registry"

menuState = GameState:new({
    key = "MAIN_MENU"
    ,transition_to_key = "LATTE_ART"
})

-- register state
StateRegistry:register(menuState.key, menuState)


function menuState:draw()
    -- draw 
    cafeOutside:draw()

    -- draw buttons
    suit.draw()
end

function menuState:update(dt)
    if suit.ImageButton(assets.playButton, {hovered=assets.playButtonHover, scale=pixelScale}, windowWidth * 0.6, windowHeight * 0.75).hit then
        print("Button clicked!")
        StateRegistry:transitionTo(self.transition_to_key)
    end

    -- -- centre info button underneath image button
    -- local imageButtonCenterX = (windowWidth * 0.6) + (assets.playButton:getWidth() * pixelScale) / 2
    
    -- love.graphics.setFont(fonts.cousineBold)
    -- local font = love.graphics.getFont()
    -- local infoButtonWidth = font:getWidth("Info") + 4
    -- local infoButtonX = imageButtonCenterX - infoButtonWidth / 2

    -- if suit.Button("Info", {}, infoButtonX, (windowHeight - 10*pixelScale)).hit then
    --     print("Info button clicked!")
    -- end
end
