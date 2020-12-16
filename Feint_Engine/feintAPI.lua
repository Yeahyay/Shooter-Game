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
Feint.Modules = {}
setmetatable(Feint, {
	__index = Feint.Modules
})

local modules = {} -- luacheck: ignore

local moduleLoadQueue = {}
local root = FEINT_ROOT:gsub("%.", "/") .. "modules"

local moduleDepth = {}
local numDependencies = {}

local funcSpace = function(num)
	io.write(("    "):rep(num))
end
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
	local function getModuleDepth(fullName)
		local depth = 0
		fullName:gsub("%a+", function()
			depth = depth + 1
		end)
		return depth
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
				funcSpace(1)
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
			assert(module.load, "Malformed module " .. module.ModuleName .. ", no load function")

			-- calculate the current module's depth
			local depth = getModuleDepth(module.Name)

			-- every assert makes sure that every entry is unique
			assert(not moduleDepth[module.Name])
			moduleDepth[module.Name] = depth

			-- record how many times each module is depended on
			assert(not modules[module.Name])

			funcSpace(1)
			print("DEPTH:", depth)
			modules[module.Name] = module
			if module.depends then
				for k, dependency in pairs(module.depends) do
					numDependencies[dependency] = (numDependencies[dependency] or 0) + 1
					local dependencyDepth = getModuleDepth(dependency)

					funcSpace(1)
					print("DEPENDENCY DEPTH:", dependencyDepth)

					funcSpace(1)
					print(string.format("* Module Dependency: %s depends on %s", module.Name, dependency))
				end
			end

			-- print(depth > 1 and module.Name:reverse():match("%a+.(%a+)"):reverse())
			-- get the module's parent string
			local parentString = module.Name:gsub(module.Name:reverse():match("([%a%d]+.)"):reverse(), "")

			if depth > 1 then
				numDependencies[parentString] = (numDependencies[parentString] or 0) + 1
				funcSpace(1)
				print(string.format("* Module Parent Dependency: %s depends on %s", module.Name, parentString))
			-- else
			-- 	numDependencies["Core"] = (numDependencies["Core"] or 0) + 1
			-- 	print("CORE DEP")
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
--]]

-- [[
print("Num Dependencies:")
local t = {}
for k, v in pairs(numDependencies) do
	t[#t + 1] = k
end
table.sort(t, function(a, b)
	return numDependencies[a] > numDependencies[b]
end)
for k, v in ipairs(t) do
	print(v, numDependencies[v])
end
print()
--]]

table.sort(moduleLoadQueue, function(a, b)
	local _a, _b = numDependencies[a.Name] or 0, numDependencies[b.Name] or 0
	-- if _a == _b then
	-- 	_a, _b = moduleDepth[b.Name] or 0, moduleDepth[a.Name] or 0
	-- end

	return _a > _b
end)

print("Module Load Order:")
for k, entry in pairs(moduleLoadQueue) do
	print(k, entry.Name)
end
print()

local function qualifyModule(module)
	local current = Feint.Modules
	if string.find(module.Name, "%.") then -- if there is a dot in the name, it is a chil
		for word in string.gmatch(module.Name, "(%a+).?") do -- traverse to the end and add the module
			io.write(string.format("%s exists: %s\n", word, current[word] and true or false))
			if not current[word] then
				-- io.write(string.format("!! Parent %s does not exist, creating\n", word))
				break
			end
			current = current[word]
			-- ::continue::
		end
	end
	return current
	-- current[module.Name] = module
end

print("Loading Modules")
for k, module in pairs(moduleLoadQueue) do
	io.write(string.format("^^ Loading module %s ^^\n", module.Name))
	-- Feint.Modules[module.ModuleName] = module
	local current = Feint.Modules
	local parent = nil
	local missingAncestry = {}
	local function addFakeIntermediary(name, table)
		table[name] = {}
	end

	if string.find(module.Name, "%.") then -- if there is a dot in the name, it is a chil
		for word in string.gmatch(module.Name, "(%a+).?") do -- traverse to the end and add the module
			io.write(string.format("%s exists: %s\n", word, current[word] and true or false))
			if not current[word] then
				-- io.write(string.format("!! Parent %s does not exist, creating\n", word))
				break
			end
			parent = current
			current = current[word]
			-- ::continue::
		end
	end
	-- current[module.ModuleName] = module
	Feint.Module[module.Name] = module

	module:load()
	io.write(string.format("VV Loaded  module %s VV\n", module.Name))
end
io.write("Loaded Modules\n\n")

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
