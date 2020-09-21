
function printf(format, ...)
	if format then
		io.write(string.format(format or "", ...))
	else
		io.write("")
	end
end

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

local exceptions = require("Feint_Engine.exceptions")

function hidden.AddModule(name)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	printf("Adding module %s\n", name)
	local newModule = {}
	local newHidden = {}
	newHidden.private = newHidden
	setmetatable(newModule, {
		__index = newHidden,
		__tostring = function() return string.format("Feint %s", name) end,
	})

	-- function newHidden.Finalize()
	-- 	getmetatable(newModule).__newindex = function(t, k, v)
	-- 		if t[k] then
	-- 			t[k] = v
	-- 		else
	-- 			error(exceptions.READ_ONLY_MODIFICATION_ERROR(t, k))
	-- 		end
	-- 	end
	-- end

	Feint[name] = newModule
end

Feint.AddModule("Paths")
Feint.Paths.size = 1
-- Feint.Util = require("Feint_Engine.utilities")
-- Feint.Util.Core = require("Feint_Engine.coreUtilities")

-- PATHS DEFINITION
if Feint.Paths.Root == nil then
	Feint.Paths.Root = (...):gsub("feintAPI", "")
end
function Feint.Paths.Add(name, path, external, file)
	local path = path or name
	assert(type(path) == "string", "needs a string")

	local newPath = nil

	-- if it's a file, no postfix
	local postfix = ""
	if file ~= "file" then
		postfix = "."
	end
	if external == "external" then
		newPath = path .. postfix
	else
		newPath = Feint.Paths.Root .. path .. postfix
	end
	if not Feint.Paths[name] then
		Feint.Paths[name] = newPath

		Feint.Paths.size = Feint.Paths.size + 1
		if file == "file" then
			-- printf("Added file     path \"%s\" (%s)\n", name, newPath)
		else
			if external == "external" then
				-- printf("Added external path \"%s\" (%s)\n", name, newPath)
			else
				-- printf("Added Feint    path \"%s\" (%s)\n", name, newPath)
			end
		end
	else
		printf("Path %s (%s) already exists.\n", newPath)
	end
end
function Feint.Paths.SlashDelimited(path)
	return path:gsub("%.", "/")
end
function Feint.Paths.PRINT()
	local min = 0
	for k, v in pairs(Feint.Paths) do
		if k ~= "hidden" then --k ~= "size" and k ~= "PRINT" then
			min = math.max(min, k:len())
		end
	end
	min = min + 1
	-- printf("hidden\n")
	-- for k, v in pairs(Feint.Paths.hidden) do
	-- 	printf("%-" .. min .. "s %s\n", k .. ",", v)
	-- end
	-- printf("main\n")
	local fmt = "%-" .. min .. "s %s\n"
	for k, v in pairs(Feint.Paths) do
		if k ~= "hidden" then--k ~= "size" and k ~= "PRINT" then
			printf(fmt, k .. ",", v)
		end
	end
end

Feint.Paths.Add("Archive", "archive")
Feint.Paths.Add("Lib", "lib")

-- UTIL
Feint.AddModule("Util")
Feint.Util = require(Feint.Paths.Root .. "utilities")
Feint.Util.Core = require(Feint.Paths.Root .. "coreUtilities")
Feint.Util.Class = require(Feint.Paths.Lib .. "30log-master.30log-clean")
Feint.Util.Memoize = require(Feint.Paths.Lib .. "memoize-master.memoize")
Feint.Util.Exceptions = exceptions

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

-- MATH
Feint.AddModule("Math")
Feint.Math.Vec2 = require(Feint.Paths.Lib .. "brinevector2D.brinevector")
Feint.Math.Vec3 = require(Feint.Paths.Lib .. "brinevector3D.brinevector3D")
-- Feint.vMath = require(Feint.Paths.Root .. "vMath")

-- LOGGING
-- Feint

-- SERIALIZATION
Feint.Paths.Add("Parsing")
-- return Feint

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
