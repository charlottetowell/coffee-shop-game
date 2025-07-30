function requireEverything()

    -- global variables
    require "src/startup/globals"

    -- game states + registry
    require "src/states/registry"
    require "src/states/intro"
    require "src/states/mainMenu"

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

    -- scenes
    require "src/scenes/init"
    
end