-- initializes the bare minimum for the engine to run

require("Feint_Engine.feintAPI")

Feint.LoadModule("ECS")
Feint.LoadModule("Parsing")
Feint.LoadModule("Serialize")
Feint.LoadModule("Audio")
Feint.LoadModule("Tween")
Feint.LoadModule("UI")

print(Feint.UI.Immediate)

printf("\n")
log("Initializing Feint Engine\n\n")

Feint.Run.framerate = 60 -- framerate cap
Feint.Run.rate = 1 / 60 -- update dt
Feint.Run.sleep = 0.001
G_DEBUG = false
-- G_TIMER = 0

G_FPS = 0
G_FPS_DELTA = 0
G_FPS_DELTA_SMOOTHNESS = 0.9

G_AVG_FPS = 0
G_AVG_FPS_DELTA = 0
G_AVG_FPS_DELTA_ITERATIONS = 60

G_TPS = 0
G_TPS_DELTA = 0
G_TPS_DELTA_SMOOTHNESS = 0.9

G_AVG_TPS = 0
G_AVG_TPS_DELTA = 0
G_AVG_TPS_DELTA_ITERATIONS = 60

G_SPEED = 1

G_INT = 0

-- G_RENDERSTATS = love.graphics.getStats()
do
	local screenHeight = 720
	local screenWidth = screenHeight * (16 / 9)
	G_SCREEN_SIZE = Feint.Math.Vec2.new(screenWidth, screenHeight)
end

G_INF = math.huge
G_SEED = 2--love.timer.getTime())

love.graphics.setLineStyle("rough")
--love.graphics.setWireframe(true)
love.graphics.setDefaultFilter("nearest", "nearest", 16)
love.math.setRandomSeed(G_SEED)


require(Feint.Paths.Root.."run")


Feint.Util.Debug.PRINT_ENV(_ENV, false)

printf("\n")
log("Initialized\n")

printf("\n")
log("Exiting bootstrap.lua\n")
