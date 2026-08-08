function requireEverything()

    -- global variables
    require "src/startup/globals"

    -- game state registry
    require "src/states/registry"

    -- main controllers
    require "src/draw"
    require "src/update"
    require "src/quit"

    -- window size handling
    require "src/startup/windowSize"

    -- colours
    require "src/startup/colours"

    -- assets
    require "src/startup/assets"

    -- sounds
    require "src/startup/sounds"

    -- libraries
    require "libraries/init"

    -- reusable components
    require "src/components/holdToFillMeter"
    require "src/components/latteArtStep"
    require "src/components/ingredientPicker"
    require "src/components/pauseButton"
    require "src/components/stationFlow"

    -- scenes
    require "src/scenes/init"

    -- game states
    require "src/states/intro"
    require "src/states/mainMenu"
    require "src/states/pause"
    require "src/states/shopClosed"
    require "src/states/shop"
    require "src/states/coffeeMachine"
    require "src/states/matchaStation"
    require "src/states/blenderStation"

end