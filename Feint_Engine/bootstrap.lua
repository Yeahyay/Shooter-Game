-- initializes the bare minimum for the engine to run

require("Feint_Engine.feintAPI")

printf("\n")
Feint.Log.log("Initializing Feint Engine\n\n")

Feint.LoadModule("Input")
Feint.LoadModule("ECS")
Feint.LoadModule("Graphics")
Feint.LoadModule("Parsing")
Feint.LoadModule("Serialize")
Feint.LoadModule("Audio")
Feint.LoadModule("Tween")
Feint.LoadModule("UI")

Feint.Run.framerate = 60 -- framerate cap
Feint.Run.rate = 1 / 60 -- update dt
Feint.Run.sleep = 0.001

love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest", "nearest", 16)
love.math.setRandomSeed(Feint.Math.G_SEED)

require(Feint.Paths.Root.."run")

Feint.Util.Debug.PRINT_ENV(_ENV, false)

printf("\n")
Feint.Log.log("Initialized\n")
