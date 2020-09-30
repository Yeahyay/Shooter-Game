local args = {...}

local FEINT_ROOT = args[1]:gsub("feintAPI", "")

local excludedModules = args[2] or {}

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
Feint.Paths.Print()

-- UTIL
Feint.Paths.Add("Util", Feint.Paths.Modules .. "utilities")
Feint.AddModule("Util", function(self)
	self.Core = require(Feint.Paths.Util .. "coreUtilities")
	self.Debug = require(Feint.Paths.Util .. "debugUtilities")
	self.File = require(Feint.Paths.Util .. "fileUtilities")
	self.String = require(Feint.Paths.Util .. "stringUtilities")
	self.Table = require(Feint.Paths.Util .. "tableUtilities")
	self.Exceptions = require(Feint.Paths.Util .. "exceptions")
	-- UTIL LIBRARIES
	self.Class = require(Feint.Paths.Lib .. "30log-master.30log-clean")
	self.Memoize = require(Feint.Paths.Lib .. "memoize-master.memoize")
	self.UUID = require(Feint.Paths.Lib .. "uuid-master.src.uuid")
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
	self.Util = require(Feint.Paths.ECS .. "ECSUtils") -- require components into table
	self.EntityManager = require(Feint.Paths.ECS .. "EntityManager")
	self.World = require(Feint.Paths.ECS .. "World")
	self.EntityArchetype = require(Feint.Paths.ECS .. "EntityArchetype")
	self.Component = require(Feint.Paths.ECS .. "Component")
	self.System = require(Feint.Paths.ECS .. "System")
	self.Assemblage = require(Feint.Paths.ECS .. "Assemblage")
	self.Finalize()
end)

-- MATH
Feint.AddModule("Math", function(self)
	self.require(Feint.Paths.Modules .. "extendedMath")
	self.Vec2 = require(Feint.Paths.Lib .. "brinevector2D.brinevector")
	self.Vec3 = require(Feint.Paths.Lib .. "brinevector3D.brinevector3D")
	-- Feint.vMath = require(Feint.Paths.Root .. "vMath")
	self.Finalize()
end)

-- LOGGING
Feint.Paths.Add("Log", Feint.Paths.Root .. "logs")
Feint.AddModule("Log", function(self)
	self.require(Feint.Paths.Modules.. "log")
end)
Feint.Log.Finalize()

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
		-- self.Finalize()
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
Feint.LoadModule("Thread")
Feint.LoadModule("Math")
Feint.LoadModule("Log")
Feint.LoadModule("Run")
