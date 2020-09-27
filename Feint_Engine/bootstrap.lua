-- initializes the bare minimum for the engine to run

require("Feint_Engine.feintAPI")

printf("\nInitializing Feint Engine\n\n")

Feint.Paths.Print()

-- REQUIRE LIBRARIES
-- global = require("globalFunctions", true)

require(Feint.Paths.Root.."run")

tick = require(Feint.Paths.Lib.."tick-master.tick")
-- Slab = require(Feint.Paths.Lib.."Slab-0_6_3.Slab")
-- memoize = require(LIB_PATH.."memoize-master.memoize", true)
-- uuid = require(LIB_PATH.."uuid-master.src.uuid", true)
-- bitser = require(LIB_PATH.."bitser.bitser", true)
-- slam = require(LIB_PATH.."slam-master.slam", true)
-- flux = require(LIB_PATH.."flux-master.flux", true)

tick.framerate = 60
tick.rate = 1 / 60
G_DEBUG = false
-- G_TIMER = 0
G_FPS = 0
G_AVG_FPS = 0

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

local ui = Feint.UI.Immediate
ui.Initialize()

love.graphics.setLineStyle("rough")
--love.graphics.setWireframe(true)
love.graphics.setDefaultFilter("nearest", "nearest", 16)
love.math.setRandomSeed(G_SEED)

Feint.Util.Debug.PRINT_ENV(_ENV, false)

printf("\nInitialized\n")

printf("\nExiting bootstrap.lua\n")
