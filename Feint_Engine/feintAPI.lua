local FEINT_ROOT = (...):gsub("feintAPI", "")

Feint = require(FEINT_ROOT .. "modules.core")

-- PATHS
-- To use the path system, I need the path to it; ironic
Feint.AddModule("Paths", require("Feint_Engine.modules.paths", FEINT_ROOT)) -- give it the root as well
Feint.Paths.Add("Modules", "modules")
Feint.Paths.Add("Lib", "lib")
Feint.Paths.Add("Archive", "archive")
Feint.Paths.Finalize()

-- UTIL
Feint.Paths.Add("Util", "modules.utilities")
Feint.AddModule("Util")--, require(Feint.Paths.Modules .. "utilities"))
Feint.Util.Core = require(Feint.Paths.Util .. "coreUtilities")
Feint.Util.Debug = require(Feint.Paths.Util .. "debugUtilities")
Feint.Util.File = require(Feint.Paths.Util .. "fileUtilities")
Feint.Util.String = require(Feint.Paths.Util .. "stringUtilities")
Feint.Util.Table = require(Feint.Paths.Util .. "tableUtilities")
Feint.Util.Exceptions = require(Feint.Paths.Util .. "exceptions")
-- UTIL LIBRARIES
Feint.Util.Class = require(Feint.Paths.Lib .. "30log-master.30log-clean")
Feint.Util.Memoize = require(Feint.Paths.Lib .. "memoize-master.memoize")
Feint.Util.Finalize()

-- ECS
Feint.Paths.Add("ECS", "ECS") -- add path
Feint.AddModule("ECS")
Feint.ECS.Util = require(Feint.Paths.ECS .. "ECSUtils") -- require components into table
Feint.ECS.EntityManager = require(Feint.Paths.ECS .. "EntityManager")
Feint.ECS.World = require(Feint.Paths.ECS .. "World")
Feint.ECS.EntityArchetype = require(Feint.Paths.ECS .. "EntityArchetype")
Feint.ECS.Component = require(Feint.Paths.ECS .. "Component")
Feint.ECS.System = require(Feint.Paths.ECS .. "System")
Feint.ECS.Assemblage = require(Feint.Paths.ECS .. "Assemblage")
Feint.ECS.Finalize()

-- MATH
Feint.AddModule("Math", require(Feint.Paths.Modules .. "extendedMath"))
-- MATH LIBRARIES
Feint.Math.Vec2 = require(Feint.Paths.Lib .. "brinevector2D.brinevector")
Feint.Math.Vec3 = require(Feint.Paths.Lib .. "brinevector3D.brinevector3D")
-- Feint.vMath = require(Feint.Paths.Root .. "vMath")
Feint.Math.Finalize()

-- LOGGING
Feint.Paths.Add("Log", "logs")
Feint.AddModule("Log", require(Feint.Paths.Modules.. "log"))
-- Feint

-- SERIALIZATION
Feint.Paths.Add("Parsing", Feint.Paths.Modules .. "parsing")
Feint.AddModule("Parsing")

-- LIB
local Slab = require(Feint.Paths.Lib.."Slab-0_6_3.Slab")
Feint.AddModule("UI")
Feint.UI.Immediate = setmetatable({}, {
	__index = Slab
})

getmetatable(Feint).__newindex = function(t, k, v)
	if t[k] then
		t[k] = v
	else
		error(string.format("Module \"%s\" does not exist in Feint\n", k))
	end
end
