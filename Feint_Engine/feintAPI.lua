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

			-- funcSpace(1)
			-- print("DEPTH:", depth)
			modules[module.Name] = module
			if module.depends then
				for k, dependency in pairs(module.depends) do
					numDependencies[dependency] = (numDependencies[dependency] or 0) + 1

					-- local dependencyDepth = getModuleDepth(dependency)
					-- funcSpace(1)
					-- print("DEPENDENCY DEPTH:", dependencyDepth)

					funcSpace(1)
					print(string.format("* Module Dependency: %s depends on %s", module.Name, dependency))
				end
				numDependencies[moduleName] = (numDependencies[moduleName] or 0) - #module.depends
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

-- local function qualifyModule(module)
-- 	local current = Feint.Modules
-- 	if string.find(module.Name, "%.") then -- if there is a dot in the name, it is a chil
-- 		for word in string.gmatch(module.Name, "([%a%d]+).?") do -- traverse to the end and add the module
-- 			io.write(string.format("%s exists: %s\n", word, current[word] and true or false))
-- 			if not current[word] then
-- 				-- io.write(string.format("!! Parent %s does not exist, creating\n", word))
-- 				break
-- 			end
-- 			current = current[word]
-- 			-- ::continue::
-- 		end
-- 	end
-- 	return current
-- 	-- current[module.Name] = module
-- end

-- local function moveTableMember(table1, member, table2)
-- 	table2[member] = table1[member]
-- 	table1[member] = nil
-- end

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

Feint.LoadedModules = {}
local fakeParents = {}

print("Loading Modules")
for k, module in pairs(moduleLoadQueue) do
	local moduleFullName = module.Name
	local moduleName = module.ModuleName
	io.write(string.format("^^  Loading module %s ^^\n", moduleFullName))
	-- Feint.Modules[module.ModuleName] = module
	local current = Feint.Modules

	local accum = ""--string.match(moduleFullName, "([%a%d]+)")

	-- if moduleFullName == "ECS" then
	-- 	funcSpace(1)
	-- 	io.write(string.format("EHHH %s\n", Feint.ECS.Util))
	-- 	for k, v in pairs(Feint.ECS.Util) do
	-- 		print(k, v)
	-- 	end
	-- end

	local count = countOccurences(moduleFullName, "([%a%d]+).?")
	local i = 0
	-- print("---", string.match(moduleFullName, ("[%a%d]+.?"):rep(count - 1) .. "[%a%d]+"))
	if count > 0 then -- if there is a dot in the name, it is a child
		for word in string.gmatch(moduleFullName, "([%a%d]+).?") do -- traverse to the end and add the module
			i = i + 1
			funcSpace(1)
			io.write(string.format("%s exists: %s\n", word, current[word] and true or false))
			-- local preAccum = accum
			-- if fakeParents[accum] then
			-- 	if not Feint.LoadedModules[accum] then
			-- 		io.write(string.format("!!!!! MODULE %s IS ETHEREAL\n", accum))
			-- 	end
			-- end
			if current[word] and current[word].Ethereal then
				funcSpace(2)
				io.write(string.format("!!  ETHEREAL TABLE %s\n", tostring(current[word])))
			end
			-- funcSpace(1)
			-- print("pre", accum)
			-- funcSpace(1)
			print(count, i)
			accum = accum:len() > 0 and accum .. "." .. word or word
			-- funcSpace(1)
			-- print("post", accum)

			if not current[word] then
				if count > i then
					funcSpace(1)
					io.write(string.format("!!  Parent %s does not exist, creating ethereal table\n", word))
					local etherealTable = {Name = "Ethereal " .. accum, Ethereal = true}
					etherealTable.Table = tostring(etherealTable)
					function etherealTable:deEtherize(table2)
						-- mergeTables(table2, self)
						-- self.Name = nil
						-- self.Ethereal = false
						-- self.Table = nil
						-- setmetatable(self, getmetatable(table2))
					end
					setmetatable(etherealTable, {
						__tostring = function()
							return "Ethereal: " .. etherealTable.Table:gsub("table: ", "")
						end
					})
					current[word] = etherealTable
					fakeParents[accum] = etherealTable
				else
					funcSpace(1)
					io.write(string.format("*   Module %s does not exist, terminal\n", word))
					break
				end
			end

			if true then
				print()
				print("__DEBUG__")
				print()
				print("word", word) -- luacheck: ignore
				print("current", current)
				print()
				local f
				f = function(v, d)
					for _k, _v in pairs(v) do
						if d > 0 or _k == "Modules" then
							if type(_v) == "table" then
								print(("   "):rep(d - 1) .. (" - "):rep(math.min(d, 1)) .. _k, _v)
								if next(v) and d < 100 then
									f(_v, d + 1)
								end
							else
								print(("   "):rep(d) .. _k, _v)
							end
						end
					end
				end
				f(Feint, 0)
				print()
				print("__DEBUG__")
				print()
			end
			-- parent = current
			current = current[word]
			-- ::continue::
		end
	end
	if fakeParents[accum] then
		-- for k, v in pairs(fakeParents) do
		-- 	print(k, v)
		-- end
		io.write(string.format("Deetherizing module %s\n", fakeParents[accum].Name))
		fakeParents[accum]:deEtherize(module)
		fakeParents[accum] = nil
	end
	current[module.ModuleName] = module
	-- if not Feint.Modules[moduleFullName] then
	-- 	Feint.Modules[moduleFullName] = {}
	-- end
	-- local moduleStore = Feint.Modules[moduleFullName]
	-- moduleStore[#modules + 1] = module

	if Feint.LoadedModules["Core"] then
		pushPrintPrefix(moduleFullName .. " debug: ")
	end
	module:load()
	if Feint.LoadedModules["Core"] then
		popPrintPrefix()
	end

	Feint.LoadedModules[moduleFullName] = module
	io.write(string.format("VV  Loaded  module %s VV\n", module.Name))
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
