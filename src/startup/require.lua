function requireEverything()

    -- global variables
    require "src/startup/globals"

    -- game states + registry
    require "src/states/registry"
    require "src/states/mainMenu"

    -- main controllers
    require "src/draw"
    require "src/update"
    require "src/quit"

    -- colours
    require "src/startup/colours"

    -- assets
    require "src/startup/assets"

    -- scenes
    require "src/scenes/init"
    
end