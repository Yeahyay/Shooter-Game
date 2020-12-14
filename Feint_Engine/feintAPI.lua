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
local root = FEINT_ROOT:gsub("%.", "/") .. "modules"

local moduleDepth = {}
local numDependencies = {}

-- local funcSpace = function(num)
-- 	io.write(("    "):rep(num))
-- end
function Feint:importModules(root)
	local moduleQueue = {}
	local moduleQueuePointer = 0
	local function insert(dir)
		moduleQueuePointer = moduleQueuePointer + 1
		moduleQueue[moduleQueuePointer] = dir
	end
	local function pop()
		local item = moduleQueue[moduleQueuePointer]
		moduleQueue[moduleQueuePointer] = nil
		moduleQueuePointer = moduleQueuePointer - 1
		return item
	end

	insert(root)

	local dir = pop()
	local lim = 0
	while (dir and love.filesystem.getDirectoryItems(dir) and lim < 100) do
		lim = lim + 1
		local items = love.filesystem.getDirectoryItems(dir)
		table.sort(items, function(a, b)
			return a:upper() > b:upper()
		end)
		for i = 1, #items, 1 do
			local item = items[i]
			local path = dir .. "/" .. item

			if love.filesystem.getInfo(path).type ~= "directory" or item:find("%.lua") then
				goto continue
			end

			insert(path)

			local moduleName = item
			local name = path:gsub(root .. "/", ""):gsub("/", ".")

			print(string.format("importing %s: %s", moduleName, name))

			local modulePath = path .. "/module"
			if not love.filesystem.getInfo(modulePath .. ".lua") then
				-- print(string.format("! Module Error: %s/module.lua not found", item))
				print(string.format("* Module Folder: module.lua not found, assumed to be resource folder", item))
				goto continue
			end

			-- import the module
			local module = require(modulePath)
			assert(type(module) == "table", "! Module Error: got " .. type(module) .. "(expected string)", 2)
			if not module.Name then
				module.ModuleName = moduleName
			end
			if not module.Name then
				module.Name = name
			end

			-- calculate the current module's depth
			local depth = 0
			module.Name:gsub("%a+", function()
				depth = depth + 1
			end)

			-- every assert makes sure that every entry is unique
			assert(not moduleDepth[module.Name])
			moduleDepth[module.Name] = depth

			-- record how many times each module is depended on
			assert(not modules[module.Name])
			modules[module.Name] = module
			if module.depends then
				for k, dependency in pairs(module.depends) do
					numDependencies[dependency] = (numDependencies[dependency] or 0) + 1
					print(string.format("* Module Dependency: %s depends on %s", module.Name, dependency))
				end
			end

			-- print(depth > 1 and module.Name:reverse():match("%a+.(%a+)"):reverse())
			-- get the module's parent string
			local parentString = module.Name:gsub(module.Name:reverse():match("([%a%d]+.)"):reverse(), "")

			if depth > 1 then
				numDependencies[parentString] = (numDependencies[parentString] or 0) + 1
				print(string.format("* Module Parent Dependency: %s depends on %s", module.Name, parentString))
			end

			-- insert each module in a default order
			table.insert(moduleLoadQueue, #moduleLoadQueue + 1, module)

			::continue::
		end

		dir = pop()
	end
	return moduleQueue
end

print("Module Structure:")
Feint:importModules(root)
print()

--[[
print("Priorities:")
for k, v in pairs(moduleDepth) do
	print(k, v)
end
print()

print("Num Dependencies:")
for k, v in pairs(numDependencies) do
	print(k, v)
end
print()
--]]

table.sort(moduleLoadQueue, function(a, b)
	local _a, _b = numDependencies[a.Name] or 0, numDependencies[b.Name] or 0
	if _a == _b then
		_a, _b = moduleDepth[b.Name] or 0, moduleDepth[a.Name] or 0
	end

	return _a > _b
end)

print("Module Load Order:")
for k, entry in pairs(moduleLoadQueue) do
	print(k, entry.Name)
end
print()

print("Loading Modules")
for k, module in pairs(moduleLoadQueue) do
	-- io.write(string.format("^^ Loading module %s ^^\n", module.ModuleName))
	local current = Feint
	if string.find(module.Name, "%.") then -- if there is a dot in the name, it is a chil
		for word in string.gmatch(module.Name, "(%a+).?") do -- traverse to the end and add the module
			if not current[word] then break end
			current = current[word]
		end
	end
	current[module.ModuleName] = module
	assert(module.load, "Malformed module " .. module.ModuleName .. ", no load function")
	module:load()
	-- io.write(string.format("VV Loaded module %s VV\n", module.ModuleName))
end
print()

-- print("Feint Layout:")
-- for k, v in pairs(Feint) do
-- 	print(k, v)
-- end
-- print()
-- for k, v in pairs(Feint.Core) do
-- 	print(k, v)
-- end
--
-- print()
-- for k, v in pairs(Feint.Core.Util) do
-- 	print(k, v)
-- end
-- print()
-- print(Feint.Core.Util.Test)
