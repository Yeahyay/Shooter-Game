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
local dependencies = {}--setmetatable({}, {__mode = "kv"})
local dependenciesIndex = {}
local priorities = {}
local parents = {}
local numDependencies = {}
local function getDependency(name)
	return dependencies[dependenciesIndex[name]]
end
-- local func
local funcSpace = function(num)
	io.write(("    "):rep(num))
end
-- func = function(dir, parent, level)
-- 	for _, item in pairs(love.filesystem.getDirectoryItems(dir)) do
-- 		-- local parentDir = parent and dir
-- 		local dir = dir .. "/" .. item
--
-- 		funcSpace(level)
-- 		print(string.format("- %s, %d", item, level))
--
-- 		if item == "module.lua" then
-- 			goto continue
-- 		end
--
-- 		local path = dir .. "/module"
-- 		if not love.filesystem.getInfo(path .. ".lua") then
-- 			funcSpace(level + 1)
-- 			print(string.format("! Module %s Error: module.lua not found", item))
-- 			goto continue
-- 		end
--
-- 		-- import the module
-- 		local module = require(path)
-- 		if not module.Name then
-- 			module.Name = item
-- 		end
-- 		modules[module.Name] = module
-- 		if module.depends then
-- 			for k, dependency in pairs(module.depends) do
-- 				funcSpace(level + 1)
-- 				print(string.format("* %s depends on %s", module.Name, dependency))
-- 			end
-- 		end
-- 		dependencies[module.Name] = module.depends or {}
--
-- 		if parent and love.filesystem.getInfo(dir).type == "directory" then
-- 			if level > 0 then
-- 				funcSpace(level + 1)
-- 				print(string.format("~ %s is parent of %s", parent, item))
-- 				parents[item] = parent
-- 			end
-- 		end
--
-- 		-- print(item, parent)
-- 		-- print(moduleLoadQueue[1].Priority)
-- 		-- modulesQueued[module.Name] = true
--
-- 		if love.filesystem.getInfo(dir).type == "directory" then
-- 			func(dir, item, level + 1)
-- 		end
-- 		::continue::
-- 	end
-- end
function Feint:importModules(root)
	local moduleQueue = {}
	local moduleQueuePointer = 0
	local function insert(dir)
		moduleQueuePointer = moduleQueuePointer + 1
		moduleQueue[moduleQueuePointer] = dir
	end
	local function pop()
		assert(moduleQueuePointer >= 0, "too many pops")
		-- print("Popping " .. moduleQueue[moduleQueuePointer])
		local item = moduleQueue[moduleQueuePointer]
		moduleQueue[moduleQueuePointer] = nil
		moduleQueuePointer = moduleQueuePointer - 1
		return item
	end
	local function peek()
		return moduleQueue[moduleQueuePointer]
	end

	insert(root)

	local dir = pop()
	local lim = 0
	while (dir and love.filesystem.getDirectoryItems(dir) and lim < 100) do
		lim = lim + 1
		-- print(dir)
		local items = love.filesystem.getDirectoryItems(dir)
		table.sort(items, function(a, b)
			return a:upper() > b:upper()
		end)
		-- level = level - 1
		-- print(items[1])
		-- print("Current Modules:")
		-- for k, v in pairs(modules) do
		-- 	print(k)
		-- end
		-- print()
		for i = 1, #items, 1 do
			local item = items[i]
			local path = dir .. "/" .. item

			if item == "module.lua" then
				goto continue
			end

			insert(path)

			--[[
			print("QUEUE STATE:")
			for i = moduleQueuePointer, 1, -1 do
				local v = moduleQueue[i]
				if i == moduleQueuePointer then
					io.write("*")
				end
				print(moduleQueuePointer + 1 - i, v)
			end
			print()
			--]]

			local moduleName = item
			local name = path:gsub(root .. "/", ""):gsub("/", ".")

			print(string.format("importing %s: %s", moduleName, name))

			local modulePath = path .. "/module"
			if not love.filesystem.getInfo(modulePath .. ".lua") then
				print(string.format("! Module Error: %s/module.lua not found", item))
				goto continue
			end

			-- import the module
			local module = require(modulePath)
			assert(type(module) == "table", "Malformed module, got " .. type(module) .. "(expected string)", 2)
			if not module.Name then
				module.ModuleName = moduleName
			end
			if not module.Name then
				module.Name = name
			end

			-- print(module.Name)
			local basePriority = 0
			module.Name:gsub("%a+", function()
				basePriority = basePriority + 1
			end)

			-- print(priority > 1 and module.Name:reverse():match("%a+.(%a+)"):reverse())
			local parentString = module.Name:gsub(module.Name:reverse():match("([%a%d]+.)"):reverse(), "")
			assert(not parents[module.Name])
			parents[module.Name] = basePriority > 1 and parentString or nil

			local priority = basePriority-- + 1 + (priorities[parentString] or 0)

			assert(not priorities[module.Name])
			priorities[module.Name] = priority
			-- table.insert(moduleLoadQueue, 1, module.Name)

			assert(not modules[module.Name]) -- every assert makes sure that every entry is unique
			modules[module.Name] = module
			if module.depends then
				for k, dependency in pairs(module.depends) do
					-- funcSpace(level)
					numDependencies[dependency] = (numDependencies[dependency] or 0) + 1
					print(string.format("* Module Dependency: %s depends on %s", module.Name, dependency))
				end
			end
			if basePriority > 1 then
				numDependencies[parentString] = (numDependencies[parentString] or 0) + 1
				print(string.format("* Module Parent Dependency: %s depends on %s", module.Name, parentString))
			end
			-- print(basePriority, parentString)
			local index = #dependencies + 1
			assert(not dependencies[index])
			dependencies[index] = module.depends or {}
			assert(not dependenciesIndex[module.Name])
			dependenciesIndex[module.Name] = index

			table.insert(moduleLoadQueue, #moduleLoadQueue + 1, module)

			::continue::
		end

		dir = pop()
	end
	return moduleQueue
end
Feint.Modules = modules
print("Module Structure:")
-- func(root, nil, 0)
Feint:importModules(root)
print()

-- print("Priorities:")
-- for k, v in pairs(priorities) do
-- 	print(k, v)
-- end
-- print()

print("Num Dependencies:")
for k, v in pairs(numDependencies) do
	print(k, v)
end
print()

print("Dependencies:")
local notYet = {}
local moduleLoadQueueIndex = {}
for i = 1, 10, 1 do
	moduleLoadQueueIndex[i] = nil
end
for k, v in pairs(dependenciesIndex) do
	print(k, v)
	for _, module in pairs(dependencies[v]) do
		notYet[module] = module
		print("  -NotYet", module)
	end
	local insertIndex = #moduleLoadQueue + 1

	-- table.insert(moduleLoadQueue, insertIndex, k)
end
print()

table.sort(moduleLoadQueue, function(a, b)
	print(a.Name, b.Name)
	local _a, _b = numDependencies[a.Name] or 0, numDependencies[b.Name] or 0
	return _a > _b
end)
print()

print("Module Load Order (Pre sort):")
for k, entry in pairs(moduleLoadQueue) do
	print(k, entry.Name)
	-- funcSpace(1)
	-- print(parents[entry], priorities[parents[entry]])
end
print()

print("Loading Modules")
for k, module in pairs(moduleLoadQueue) do
	-- print(k, module.Name)
	print(module.Name)
	if string.find(module.Name, "%.") then
		local current = Feint
		for word in string.gmatch(module.Name, "(%a+).?") do
			print("", word)
			current = current[word]
			print(current)
			if not current then break end
		end
	else
		Feint[module.ModuleName] = module
	end
	print("Loaded module " .. module.ModuleName)
	-- module:load()
	-- funcSpace(1)
	-- print(parents[entry], priorities[parents[entry]])
end
print()

print("Feint Layout:")
for k, v in pairs(Feint) do
	print(k, v)
end

-- for k, entry in ipairs(moduleLoadQueue) do
-- 	local module = entry.Module
-- 	print(module.Name)
-- 	module:load()
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
