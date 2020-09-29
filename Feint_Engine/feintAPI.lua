local args = {...}

local FEINT_ROOT = args[1]:gsub("feintAPI", "")

local excludedModules = args[2] or {}

Feint = require(FEINT_ROOT .. "modules.core")

-- PATHS
do
	-- To use the path system, I need the path to it; ironic
	local paths = Feint.AddModule("Paths", require("Feint_Engine.modules.paths", FEINT_ROOT)) -- give it the root as well
	Feint.LoadModule("Paths")
	paths.Add("Modules", "modules")
	paths.Add("Lib", "lib")
	paths.Add("Archive", "archive")
	-- paths.Finalize()
end

-- UTIL
Feint.Paths.Add("Util", "modules.utilities")
Feint.AddModule("Util", nil, function(self)--, require(Feint.Paths.Modules .. "utilities"))
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
end)
Feint.LoadModule("Util")
-- Feint.Util.Finalize()

-- THREADING
Feint.Paths.Add("Thread", "modules.threading")
Feint.AddModule("Thread", require(Feint.Paths.Thread .. "thread"), function(self)
end)
Feint.LoadModule("Thread")

-- ECS
Feint.Paths.Add("ECS", "ECS") -- add path
Feint.AddModule("ECS", nil, function(self)
	self.Util = require(Feint.Paths.ECS .. "ECSUtils") -- require components into table
	self.EntityManager = require(Feint.Paths.ECS .. "EntityManager")
	self.World = require(Feint.Paths.ECS .. "World")
	self.EntityArchetype = require(Feint.Paths.ECS .. "EntityArchetype")
	self.Component = require(Feint.Paths.ECS .. "Component")
	self.System = require(Feint.Paths.ECS .. "System")
	self.Assemblage = require(Feint.Paths.ECS .. "Assemblage")
end)
-- Feint.ECS.Finalize()

-- MATH
Feint.AddModule("Math", require(Feint.Paths.Modules .. "extendedMath"), function(self)
	self.Vec2 = require(Feint.Paths.Lib .. "brinevector2D.brinevector")
	self.Vec3 = require(Feint.Paths.Lib .. "brinevector3D.brinevector3D")
	-- Feint.vMath = require(Feint.Paths.Root .. "vMath")
end)
-- Feint.Math.Finalize()
Feint.LoadModule("Math")

-- LOGGING
Feint.Paths.Add("Log", "logs")
Feint.AddModule("Log", require(Feint.Paths.Modules.. "log"), function(self)
end)
Feint.LoadModule("Log")

-- PARSING
Feint.Paths.Add("Parsing", Feint.Paths.Modules .. "parsing")
Feint.AddModule("Parsing", nil, function(self)
end)

-- SERIALIZATION
Feint.AddModule("Serialize", nil, function(self)
	Feint.Serialize.Bitser = require(Feint.Paths.Lib .. "bitser.bitser")
end)

-- AUDIO
Feint.AddModule("Audio", nil, function(self)
	Feint.Audio.Slam = require(Feint.Paths.Lib .. "slam-master.slam")
end)

-- TWEENING
Feint.AddModule("Tween", nil, function(self)
	Feint.Tween.Flux = require(Feint.Paths.Lib .. "flux-master.flux")
end)

-- LIB
do
	local Slab = require(Feint.Paths.Lib.."Slab-0_6_3.Slab")
	Feint.AddModule("UI", nil, function(self)
		self.Immediate = setmetatable({}, {
			__index = Slab
		})
	end)

	Feint.AddModule("Run", require(Feint.Paths.Lib.."tick-master.tick"), function(self)
	end)
	Feint.LoadModule("Run")
	-- Feint.Run
end

getmetatable(Feint).__newindex = function(t, k, v)
	if t[k] then
		t[k] = v
	else
		error(string.format("Module \"%s\" does not exist in Feint\n", k))
	end
end
