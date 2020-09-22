
function printf(format, ...)
	if format then
		io.write(string.format(format or "", ...))
	else
		io.write("")
	end
end

local FEINT_ROOT = (...):gsub("feintAPI", "")

Feint = {
	Name = "Feint API",
	-- Paths = {
	-- 	hidden = {
	-- 		size = 1
	-- 	}
	-- },
	-- ECS = {},
	-- Util = nil,
	-- Math = {},
}
-- the API's hidden table
local hidden = {}
setmetatable(Feint, {
	__index = hidden,
})

local exceptions = require("Feint_Engine.modules.exceptions")

function hidden.AddModule(name, privateData)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	printf("Adding module %s\n", name)
	local newModule = {}
	local newPrivate = privateData or {} -- closure to a module's private state
	newPrivate.private = newPrivate

	function newPrivate.Finalize()
		-- getmetatable(newModule).__newindex = function(t, k, v)
		-- 	if t[k] then
		-- 		t[k] = v
		-- 	else
		-- 		-- newPrivate[k] = v
		-- 		error(exceptions.READ_ONLY_MODIFICATION_ERROR(t, k))
		-- 	end
		-- end
	end
	-- newPrivate.AddModule = self.AddModule

	setmetatable(newModule, {
		__index = newPrivate,
		__tostring = function() return string.format("Feint %s", name) end,
	})

	Feint[name] = newModule
end

-- PATHS
-- To use the path system, I need the path to it; ironic
Feint.AddModule("Paths", require("Feint_Engine.modules.paths", FEINT_ROOT)) -- give it the root as well
Feint.Paths.Add("Modules", "modules")
Feint.Paths.Add("Lib", "lib")
-- Feint.Paths.Add("Archive", "archive")
Feint.Paths.Finalize()

-- UTIL
Feint.AddModule("Util", require(Feint.Paths.Modules .. "utilities"))
Feint.Util.Core = require(Feint.Paths.Modules .. "coreUtilities")
Feint.Util.Class = require(Feint.Paths.Lib .. "30log-master.30log-clean")
Feint.Util.Memoize = require(Feint.Paths.Lib .. "memoize-master.memoize")
Feint.Util.Exceptions = exceptions
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
Feint.AddModule("Math")
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
-- return Feint


for k, v in pairs(Feint.Paths) do
	print(k, v)
end

--[[
if Feint.Paths.Root == nil then
	local newPath = ( .. .):gsub("feintAPI", "")
	-- local t = {
		-- path = newPath,
		-- parent = t,
	-- }
	Feint.Paths.Root = setmetatable({
		size = 0
	}, {
		__tostring = function()
			return newPath--t.path
		end,
		__concat = function(a, b)
			return tostring(a)  ..  tostring(b)
		end
	})
end
function Feint.Paths.PRINT()
	local p = nil
	p = function(path, layer)
		local i = 1
		for k, v in pairs(path) do
			if type(v) == "table" and k ~= "parent" then
				for j = 1, layer do
					printf("│  ")
				end
				printf("%s──%s, %s\n", v.parent and i < v.parent.size and "├" or "└", k, v)
				if v.size > 0 and layer < 20 then
					p(v, layer + 1)
				end
				i = i + 1
			end

		end
	end
	printf("%s\n", Feint.Paths.Root)
	p(Feint.Paths.Root, 0)
end
function Feint_ADD_PATH(parent, name, path)
	local parent = parent or Feint.Paths.Root
	local path = path or name

	if not parent[name] then
		local newPath = parent .. path .. "."
		-- local t = {
		-- 	path = newPath,
		-- }
		parent[name] = setmetatable({
			size = 0,
			parent = parent
		}, {
			__tostring = function()
				return newPath--t.path
			end,
			__concat = function(a, b)
				return tostring(a)  ..  tostring(b)
			end
		})
		parent.size = parent.size + 1
		-- print(parent, parent.size)
		printf("Added Path (%s) to %s\n", parent[name], parent)
	else
		printf("Path %s (%s) already exists.\n", parent[name])
	end
end
-- ]]

getmetatable(Feint).__newindex = function(t, k, v)
	if t[k] then
		t[k] = v
	else
		error(string.format("Module \"%s\" does not exist in Feint\n", k))
	end
end
