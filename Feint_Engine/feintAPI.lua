local args = {...}

local FEINT_ROOT = args[1]:gsub("feintAPI", "")

-- require("love.audio")
-- require("love.data")
-- require("love.event")
-- require("love.filesystem")
-- require("love.font")
-- require("love.graphics")
-- require("love.image")
-- require("love.joystick")
-- require("love.keyboard")
-- require("love.math")
-- require("love.mouse")
-- require("love.physics")
-- require("love.sound")
-- require("love.system")
-- require("love.thread")
-- require("love.timer")
-- require("love.touch")
-- require("love.video")
-- require("love.window")

--[[ CREATE A MODULE SYSTEM
|- MODULE_NAME
|  |- module.lua
|  |- whatever else
--]]

Feint = {}--require(FEINT_ROOT .. "modules.core.module")

local modules = {} -- luacheck: ignore
local moduleLoadQueue = {}
-- local modulesQueued = {}
local root = FEINT_ROOT:gsub("%.", "/") .. "modules"
local parents = {}
local dependencies = {}--setmetatable({}, {__mode = "kv"})
local func
local funcSpace = function(num)
	for i = 1, num, 1 do
		io.write("    ")
	end
end
func = function(dir, parent, level)
	for _, item in pairs(love.filesystem.getDirectoryItems(dir)) do
		-- local parentDir = parent and dir
		local dir = dir .. "/" .. item

		funcSpace(level)
		print(string.format("- %s, %d", item, level))

		if item == "module.lua" then
			goto continue
		end

		local path = dir .. "/module"
		if not love.filesystem.getInfo(path .. ".lua") then
			funcSpace(level + 1)
			print(string.format("! Module %s Error: module.lua not found", item))
			goto continue
		end

		-- import the module
		local module = require(path)
		if not module.Name then
			module.Name = item
		end
		modules[module.Name] = module
		if module.depends then
			for k, dependency in pairs(module.depends) do
				funcSpace(level + 1)
				print(string.format("* %s depends on %s", module.Name, dependency))
			end
		end
		dependencies[module.Name] = module.depends or {}

		if parent and love.filesystem.getInfo(dir).type == "directory" then
			if level > 0 then
				funcSpace(level + 1)
				print(string.format("~ %s is parent of %s", parent, item))
				parents[item] = parent
			end
		end

		-- print(item, parent)
		-- print(moduleLoadQueue[1].Priority)
		local priority = moduleLoadQueue[1] and moduleLoadQueue[1].Priority + 1 or 1
		table.insert(moduleLoadQueue, 1, {Module = module, Priority = priority})
		-- modulesQueued[module.Name] = true

		if love.filesystem.getInfo(dir).type == "directory" then
			func(dir, item, level + 1)
		end
		::continue::
	end
end
Feint.Modules = modules
print("Module Structure:")
func(root, nil, 0)
print()

print("Dependencies")
for Module, _dependencies in pairs(dependencies) do
	print(Module)
	for k, dependency in ipairs(_dependencies) do
		funcSpace(1)
		print(k, dependency)
	end
end
print()

print("Module Load Order:")
for k, entry in pairs(modules) do
end
for k, entry in pairs(moduleLoadQueue) do
	local module = entry.Module
	print(module.Name, k, entry.Priority)
	if module.depends then
		for k, dependency in pairs(module.depends) do
			print("  depends on:", dependency)
		end
	end
end

-- for k, entry in ipairs(moduleLoadQueue) do
-- 	local module = entry.Module
-- 	print(module.Name)
-- 	module:load()
-- 	-- Feint[module.Name] = module
-- end

-- PATHS
-- To use the path system, I need the path to it; ironic
-- Feint.AddModule("Paths", function(self) -- give it the root as well
-- 	self.require("Feint_Engine.modules.paths", FEINT_ROOT)
-- 	self.Add("Modules", Feint.Paths.Root .. "modules")
-- 	self.Add("Lib", Feint.Paths.Root .. "lib")
-- 	self.Add("Archive", Feint.Paths.Root .. "archive")
-- 	self.Finalize()
-- end)
-- Feint.LoadModule("Paths")
-- Feint.Paths.Print()

-- local mt = getmetatable(Feint)
-- mt.__newindex = function(t, k, v)
-- 	if t[k] then
-- 		t[k] = v
-- 	else
-- 		error(string.format("Module \"%s\" does not exist in Feint\n", k))
-- 	end
-- end
