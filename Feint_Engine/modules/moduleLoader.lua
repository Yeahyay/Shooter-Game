local moduleLoader = {}

local rootDir = ""

local function funcSpace(num)
	io.write(("    "):rep(num))
end
local function countOccurences(source, string)
	return select(2, source:gsub(string, ""))
end
-- local function getModuleDepth(fullName)
-- 	return countOccurences(fullName, "[%a%d]+")
-- end

local tempModuleObject = require("Feint_Engine.modules.tempModuleObject")
local moduleObject = require("Feint_Engine.modules.moduleObject")

local moduleLoadList = {}
local modules = {}
local modulePriorities = {}

function moduleLoader:setRoot(path)
	rootDir = path
end
function moduleLoader:getRoot()
	return rootDir
end
function moduleLoader:importModule(path)
	local module = moduleObject:new(rootDir, path)
	if love.filesystem.getInfo(path).type ~= "directory" or module.Name:find("%.lua") then
		if module.Name:find("%.lua") then
			funcSpace(1)
			print(string.format("! Module Error in %s, %s: got lua file (expected folder)",
				module.Name, module.FullName
			))
		else
			funcSpace(1)
			print(string.format("! Module Error in %s, %s: got something weird (expected folder)",
				module.Name, module.FullName
			))
		end
		return nil
	end

	if not love.filesystem.getInfo(module.ModulePath .. ".lua") then
		-- funcSpace(1)
		-- print(string.format("* Module Info for %s, %s: module.lua not found, assumed to be resource folder",
		-- 	module.Name, module.FullName
		-- ))
		return nil
	end
	print(string.format("importing %s: %s", module.Name, module.FullName))

	module:loadModule()

	if not module.Module.load then
		funcSpace(1)
		print(string.format("! Module Error in %s, %s: no load function", module.Name, module.FullName))
		return nil
	end

	-- funcSpace(1)
	-- print("DEPTH:", depth)
	if module.Module.depends then
		for k, dependency in pairs(module.Module.depends) do
			assert(dependency:len() > 1, string.format("module %s depends on an empty string", module.Name))
			modulePriorities[dependency] = (modulePriorities[dependency] or 0) + 1

			funcSpace(1)
			print(string.format("*        Dependency: %s depends on %s", module.Name, dependency))
		end
		-- moduleDependencies[module.Name] = (moduleDependencies[moduleName] or 0) - #module.depends
	end

	-- if getModuleDepth(module.FullName) > 1 then
	-- 	modulePriorities[module.ParentFullName] = (modulePriorities[module.ParentFullName] or 0) + 1
	-- 	funcSpace(1)
	-- 	print(string.format("* Parent Dependency: %s depends on %s", module.Name, module.ParentFullName))
	-- end

	-- insert each module in a default order
	table.insert(moduleLoadList, #moduleLoadList + 1, module)
	modules[module.FullName] = module
	return module
end
function moduleLoader:sortDependencies()
	print()
	print("Module Dependencies:")
	local t = {}
	for name, _ in pairs(modulePriorities) do
		t[#t + 1] = name
	end
	-- table.sort(t, function(a, b)
	-- 	return modulePriorities[a] > modulePriorities[b]
	-- end)
	for name, priority in pairs(modulePriorities) do
		io.write(string.format("%3d %s %s on %s\n",
			priority,
			priority == 1 and "module" or "modules",
			priority == 1 and "depends" or "depend",
			name
		))
	end

	table.sort(moduleLoadList, function(a, b)
		return (modulePriorities[a.FullName] or 0) > (modulePriorities[b.FullName] or 0)
	end)

	print()
	print("Module Load Order:")
	for k, entry in pairs(moduleLoadList) do
		io.write(string.format("%3d: %s\n", k, entry.FullName))
	end
end
function moduleLoader:loadModule(fullName)
	io.write(string.format("* Loading module %s\n", fullName))
	local module = modules[fullName]
	local current = Feint.Modules

	local accum = ""

	local moduleDepth = countOccurences(fullName, "([%a%d]+).?")
	local currentDepth = 0
	if moduleDepth > 0 then -- if there is a dot in the name, it is a child
		for name in string.gmatch(fullName, "([%a%d]+).?") do -- traverse to the end and add the module
			currentDepth = currentDepth + 1
			-- funcSpace(1)
			-- io.write(string.format("%s exists: %s\n", name, current[name] and true or false))

			accum = accum:len() > 0 and accum .. "." .. name or name
			local currentModule = current[name]

			if module.Name == (currentModule and currentModule.Name) then
				currentModule:convert(module.Module)
				break
			end
			if not currentModule then
				-- io.write(string.format("%s does not exist\n", accum))
				-- funcSpace(1)
				if moduleDepth > currentDepth then
					-- io.write(string.format("it is not terminal, making it ethereal\n", accum))
					current[name] = tempModuleObject:new(accum)
					currentModule = current[name]
				else
					-- io.write(string.format("it is terminal\n", accum))
					break
				end
			end

			current = currentModule
		end
	end
	current[module.Name] = module.Module

	-- print(Feint.Core, Feint.Core.Paths, current.Name)

	if Feint.LoadedModules["Core"] then
		pushPrintPrefix(fullName .. " debug: ")
	end
	module.Module:load()
	if Feint.LoadedModules["Core"] then
		popPrintPrefix()
	end

	Feint.LoadedModules[fullName] = module.Module
	io.write(string.format("* Loaded  module %s\n", fullName))
	print()

end
function moduleLoader:loadModules()
	self:sortDependencies()

	print()
	print("Loading Modules")
	for k, module in pairs(moduleLoadList) do
		self:loadModule(module.FullName)
	end

	io.write("Loaded Modules\n")
end

return moduleLoader
