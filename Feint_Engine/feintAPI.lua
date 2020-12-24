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

--[[ Module Format
|- MODULE_NAME
|  |- module.lua
|  |- whatever else
--]]

Feint = {}
Feint.Modules = {
	Name = "MODULE_HEIRARCHY_ROOT"
}
Feint.LoadedModules = {}
setmetatable(Feint, {
	__index = Feint.Modules
})

local modules = {} -- luacheck: ignore

local moduleLoadQueue = {}
local root = FEINT_ROOT:gsub("%.", "/") .. "modules"

-- local moduleDepth = {}
local moduleDependencies = {}

local funcSpace = function(num)
	io.write(("    "):rep(num))
end
local function countOccurences(source, string)
	return select(2, source:gsub(string, ""))
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
		return countOccurences(fullName, "[%a%d]+")
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
			-- assert(not moduleDepth[module.Name])
			-- moduleDepth[module.Name] = depth

			-- record how many times each module is depended on
			assert(not modules[module.Name])

			-- funcSpace(1)
			-- print("DEPTH:", depth)
			modules[module.Name] = module
			if module.depends then
				for k, dependency in pairs(module.depends) do
					assert(dependency:len() > 1, string.format("module %s depends on an empty string", module.Name))
					moduleDependencies[dependency] = (moduleDependencies[dependency] or 0) + 1

					funcSpace(1)
					print(string.format("*        Dependency: %s depends on %s", module.Name, dependency))
				end
				-- moduleDependencies[module.Name] = (moduleDependencies[moduleName] or 0) - #module.depends
			end

			-- get the module's parent string
			local parentString = module.Name:gsub(module.Name:reverse():match("([%a%d]+.)"):reverse(), "")

			if depth > 1 then
				moduleDependencies[parentString] = (moduleDependencies[parentString] or 0) + 1
				funcSpace(1)
				print(string.format("* Parent Dependency: %s depends on %s", module.Name, parentString))
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

print("Num Dependencies:")
local t = {}
for dependency, score in pairs(moduleDependencies) do
	t[#t + 1] = dependency
end
table.sort(t, function(a, b)
	return moduleDependencies[a] > moduleDependencies[b]
end)
-- [[
for k, moduleFullName in ipairs(t) do
	local numDependencies = moduleDependencies[moduleFullName]
	io.write(string.format("%3d %s depend on %s\n",
		numDependencies,
		numDependencies > 1 and "modules" or "module",
		moduleFullName
	))
end
print()
--]]

table.sort(moduleLoadQueue, function(a, b)
	return (moduleDependencies[a.Name] or 0) > (moduleDependencies[b.Name] or 0)
end)

print("Module Load Order:")
for k, entry in pairs(moduleLoadQueue) do
	io.write(string.format("%3d: %s\n", k, entry.Name))
end
print()

local function mergeTables(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			mergeTables(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

local function createEtherealTable(name)
	local etherealTable = {Name = name, Ethereal = true}
	etherealTable.TableToString = tostring(etherealTable)
	function etherealTable:deEtherize(table2)
		self.Name = nil
		self.Ethereal = nil
		self.Table = nil
		self.deEtherize = nil
		self.TableToString = nil
		self = mergeTables(table2, self)
		setmetatable(self, getmetatable(table2))
	end
	setmetatable(etherealTable, {
	__tostring = function()
		return "Ethereal: " .. etherealTable.TableToString:gsub("table: ", "")
	end
	})
	return etherealTable
end

print("Loading Modules")
for k, module in pairs(moduleLoadQueue) do
	local moduleFullName = module.Name
	io.write(string.format("* Loading module %s\n", moduleFullName))
	local current = Feint.Modules

	local accum = ""

	local moduleDepth = countOccurences(moduleFullName, "([%a%d]+).?")
	local currentDepth = 0
	if moduleDepth > 0 then -- if there is a dot in the name, it is a child
		for name in string.gmatch(moduleFullName, "([%a%d]+).?") do -- traverse to the end and add the module
			currentDepth = currentDepth + 1
			-- funcSpace(1)
			-- io.write(string.format("%s exists: %s\n", name, current[name] and true or false))

			accum = accum:len() > 0 and accum .. "." .. name or name
			local currentModule = current[name]

			if module.Name == (currentModule and currentModule.Name) then
				currentModule:deEtherize(module)
				break
			end
			if not currentModule then
				-- io.write(string.format("%s does not exist\n", accum))
				-- funcSpace(1)
				if moduleDepth > currentDepth then
					-- io.write(string.format("it is not terminal, making it ethereal\n", accum))
					current[name] = createEtherealTable(accum)
					currentModule = current[name]
				else
					-- io.write(string.format("it is terminal\n", accum))
					break
				end
			end

			current = currentModule
		end
	end
	current[module.ModuleName] = module

	if Feint.LoadedModules["Core"] then
		pushPrintPrefix(moduleFullName .. " debug: ")
	end
	module:load()
	if Feint.LoadedModules["Core"] then
		popPrintPrefix()
	end

	Feint.LoadedModules[moduleFullName] = module
	io.write(string.format("* Loaded  module %s\n", module.Name))
	print()
end

io.write("Loaded Modules\n\n")
