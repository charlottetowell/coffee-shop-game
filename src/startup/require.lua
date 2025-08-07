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

    -- libraries
    require "libraries/init"

    -- scenes
    require "src/scenes/init"

    -- game states
    require "src/states/intro"
    require "src/states/mainMenu"
    require "src/states/latteArt"
    
end