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
	if module.Name:find("__[%a%d]+") then
		return nil
	end
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
		funcSpace(1)
		print(string.format("* Module Info for %s, %s: module.lua not found, assumed to be resource folder",
			module.Name, module.FullName
		))
		return nil
	end
	print(string.format("importing %s: %s", module.Name, module.FullName))

	module:loadModule()
	if not modulePriorities[module.FullName] then
		modulePriorities[module.FullName] = 0
	end

	if not module.Module.load then
		funcSpace(1)
		print(string.format("! Module Error in %s, %s: no load function", module.Name, module.FullName))
		return nil
	end

	if module.Module.depends then
		for k, dependency in pairs(module.Module.depends) do
			assert(dependency:len() > 1, string.format("module %s depends on an empty string", module.Name))
			modulePriorities[dependency] = (modulePriorities[dependency] or 0) + 1

			funcSpace(1)
			print(string.format("* Module Dependency: %s depends on %s", module.Name, dependency))
		end
	end

	-- add the module to the list of all modules
	modules[module.FullName] = module

	funcSpace(1)
	print("! imported")
	print()
	return module
end
function moduleLoader:sortDependencies()
	local notUsed = {}
	local graph = {}
	local graphIndex = {}
	for name, module in pairs(modules) do
		local node = {
			FullName = name,
			Dependencies = {Index = {}},
			Dependants = {Index = {}},
		}
		local indexMT = {
			__index = function(t, k)
				return rawget(t, t.Index[k]) -- defer to the index by default
			end,
			__newindex = function(t, k, v)
				if type(k) == "number" then -- accessing the array portion is normal
					rawset(t, k, v)
				else -- accessing the hash is spicy
					if v == nil then
						for i = t.Index[k], #t - 1, 1 do
							rawset(t, i, next)
							t.Index[i] = t.Index[i + 1]
							t.Index[t.Index[i]] = i
						end
						rawset(t.Index, k, nil)
						rawset(t.Index, #t, nil)
						rawset(t, #t, nil)
					else
						rawset(t, #t + 1, v) -- add the value to the end of the list
						rawset(t.Index, k, #t) -- use the key as the value's index
						rawset(t.Index, #t, k) -- use the index the index's key
					end
				end
			end
		}
		setmetatable(node.Dependencies, indexMT)
		setmetatable(node.Dependants, indexMT)
		graph[#graph + 1] = node
		graphIndex[name] = #graph
		notUsed[name] = true
	end
	for name, module in pairs(modules) do
		local node = graph[graphIndex[name]]
		if module.Module.depends then
			for k, dependency in pairs(module.Module.depends) do
				local dependNode = graph[graphIndex[dependency]]
				assert(modules[dependency], "dependency " .. dependency .. " does not exist", 1)
				node.Dependencies[dependNode.FullName] = dependNode
				dependNode.Dependants[node.FullName] = node
				io.write(string.format("   %s depends on module %s\n", name, dependency))
			end
			io.write(string.format("%s depends on %d %s\n",
				node.FullName, #node.Dependencies, #node.Dependencies == 1 and "module" or "modules")
			)
		else
		io.write(string.format("%s depends on 0 modules\n", node.FullName))
		end
	end

	local queue = {}
	for _, node in pairs(graph) do
		if #node.Dependencies == 0 then
			queue[#queue + 1] = node
		end
	end
	while #queue > 0 do
		local current = queue[1]
		table.remove(queue, 1)
		moduleLoadList[#moduleLoadList + 1] = current

		for k, node in ipairs(current.Dependants) do
			if notUsed[node.FullName] then
				node.Dependencies[current.FullName] = nil
				if #node.Dependencies == 0 then
					queue[#queue + 1] = node
					notUsed[node.FullName] = nil
				end
			end
		end
	end
	print()
	print("Module Load Order:")
	for k, entry in pairs(moduleLoadList) do
		io.write(string.format("%2d: %s\n", k, entry.FullName))
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
