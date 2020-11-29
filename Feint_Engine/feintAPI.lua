local args = {...}

local FEINT_ROOT = args[1]:gsub("feintAPI", "")

--[[ CREATE A MODULE SYSTEM
eacg module can have submodules
every module, including submodules, can have dependencies
Feint.AddModule("Log", function(self) end) -- last argument is the module initializer
Feint.AddModule("Util")
Feint.AddModule("Util", "Core") -- every argument except the second to last is the heirarchy
Feint.AddModule("Util", "Debug")

Feint.AddModule("Test")
Feint.AddModule("Test", "Level1")
Feint.AddModule("Test", "Level1", "Level2")
Feint.AddModule("Paths")
--]]

Feint = require(FEINT_ROOT .. "modules.core")

-- PATHS
-- To use the path system, I need the path to it; ironic
Feint.AddModule("Paths", function(self) -- give it the root as well
	self.require("Feint_Engine.modules.paths", FEINT_ROOT)
	self.Add("Modules", Feint.Paths.Root .. "modules")
	self.Add("Lib", Feint.Paths.Root .. "lib")
	self.Add("Archive", Feint.Paths.Root .. "archive")
	self.Finalize()
end)
Feint.LoadModule("Paths")
-- Feint.Paths.Print()

-- UTIL
Feint.Paths.Add("Util", Feint.Paths.Modules .. "utilities")
Feint.AddModule("Util", function(self)
	-- UTIL LIBRARIES
	self.Class = require(Feint.Paths.Lib .. "30log-master.30log-clean")
	self.Memoize = require(Feint.Paths.Lib .. "memoize-master.memoize")
	self.UUID = require(Feint.Paths.Lib .. "uuid-master.src.uuid")

	self.Exceptions = require(Feint.Paths.Util .. "exceptions")

	self.Core = require(Feint.Paths.Util .. "coreUtilities")
	self.Debug = require(Feint.Paths.Util .. "debugUtilities")
	self.File = require(Feint.Paths.Util .. "fileUtilities")
	self.String = require(Feint.Paths.Util .. "stringUtilities")
	self.Table = require(Feint.Paths.Util .. "tableUtilities")
	self.Finalize()
end)

-- THREADING
Feint.Paths.Add("Thread", Feint.Paths.Modules .. "threading")
Feint.AddModule("Thread", function(self)
	self.require(Feint.Paths.Thread .. "thread")
	self.Finalize()
end)

-- ECS
Feint.Paths.Add("ECS", Feint.Paths.Root .. "ECS") -- add path
Feint.AddModule("ECS", function(self)
	self.FFI_OPTIMIZATIONS = true

	self.Util = require(Feint.Paths.ECS .. "ECSUtils") -- require components into table
	self.EntityArchetype = require(Feint.Paths.ECS .. "EntityArchetype")
	self.EntityArchetypeChunk = require(Feint.Paths.ECS .. "EntityArchetypeChunk")

	self.EntityQuery = require(Feint.Paths.ECS .. "EntityQuery")
	self.EntityQueryBuilder = require(Feint.Paths.ECS .. "EntityQueryBuilder")

	self.EntityManager = require(Feint.Paths.ECS .. "EntityManager")
	self.World = require(Feint.Paths.ECS .. "World")
	self.Component = require(Feint.Paths.ECS .. "Component")
	self.System = require(Feint.Paths.ECS .. "System")

	self.Finalize()
end)

-- INPUT
Feint.Paths.Add("Input", Feint.Paths.Modules .."input")
Feint.AddModule("Input", function(self)
	self.require(Feint.Paths.Input .. "input")
	self.Finalize()
end)

-- GRAPHICS
Feint.Paths.Add("Graphics", Feint.Paths.Modules .. "graphics")
Feint.AddModule("Graphics", function(self)
	self.require(Feint.Paths.Graphics .. "graphics")
	do
		local width, height, flags = love.window.getMode() -- luacheck: ignore
		local screenHeight = height
		local screenWidth = screenHeight * (16 / 9)
		self.RenderSize = Feint.Math.Vec2.new(1280, 720)
		self.ScreenSize = Feint.Math.Vec2.new(screenWidth, screenHeight)
		self.RenderToScreenRatio = self.ScreenSize / self.RenderSize
		self.ScreenToRenderRatio = self.RenderSize / self.ScreenSize
		-- print(self.ScreenToRenderRatio)
		-- print(self.RenderToScreenRatio)
	end
	self.Finalize()
end)

-- MATH
Feint.AddModule("Math", function(self)
	self.require(Feint.Paths.Modules .. "extendedMath")
	self.Vec2 = require(Feint.Paths.Lib .. "brinevector2D.brinevector")
	self.Vec3 = require(Feint.Paths.Lib .. "brinevector3D.brinevector3D")
	-- Feint.vMath = require(Feint.Paths.Root .. "vMath")
	self.G_INF = math.huge
	self.G_SEED = 2--love.timer.getTime())
	self.Finalize()
end)

-- LOGGING
Feint.Paths.Add("Log", Feint.Paths.Root .. "logs")
Feint.AddModule("Log", function(self)
	self.require(Feint.Paths.Modules.. "log")
	self.Finalize()
end)

-- PARSING
Feint.Paths.Add("Parsing", Feint.Paths.Modules .. "parsing")
Feint.AddModule("Parsing", function(self)
	self.Finalize()
end)

-- SERIALIZATION
Feint.AddModule("Serialize", function(self)
	self.Bitser = require(Feint.Paths.Lib .. "bitser.bitser")
	self.Finalize()
end)

-- AUDIO
Feint.AddModule("Audio", function(self)
	Feint.Audio.Slam = require(Feint.Paths.Lib .. "slam-master.slam")
	self.Finalize()
end)

-- TWEENING
Feint.AddModule("Tween", function(self)
	self.Flux = require(Feint.Paths.Lib .. "flux-master.flux")
	self.Finalize()
end)

-- LIB
do
	local Slab = require(Feint.Paths.Lib .. "Slab-0_6_3.Slab")
	Feint.AddModule("UI", function(self)
		self.Immediate = setmetatable({}, {
			__index = Slab
		})
		self.Finalize()
	end)

	Feint.AddModule("Run", function(self)
		self.require(Feint.Paths.Lib.."tick-master.tick")

		self.G_DEBUG = false
		-- G_TIMER = 0

		self.G_FPS = 0
		self.G_FPS_DELTA = 0
		self.G_FPS_DELTA_SMOOTHNESS = 0.975

		self.G_AVG_FPS = 0
		self.G_AVG_FPS_DELTA = 0
		self.G_AVG_FPS_DELTA_ITERATIONS = self.framerate > 0 and self.framerate * 2 or 60

		self.G_TPS = 0
		self.G_TPS_DELTA = 0
		self.G_TPS_DELTA_SMOOTHNESS = 0.9

		self.G_AVG_TPS = 0
		self.G_AVG_TPS_DELTA = 0
		self.G_AVG_TPS_DELTA_ITERATIONS = 60

		self.G_SPEED = 1

		self.G_INT = 0
		self.Finalize()
	end)
end

getmetatable(Feint).__newindex = function(t, k, v)
	if t[k] then
		t[k] = v
	else
		error(string.format("Module \"%s\" does not exist in Feint\n", k))
	end
end

-- DEFAULT MODULES
Feint.LoadModule("Util")
Feint.LoadModule("Math")
Feint.LoadModule("Log")
Feint.LoadModule("Run")
Feint.LoadModule("Thread")
