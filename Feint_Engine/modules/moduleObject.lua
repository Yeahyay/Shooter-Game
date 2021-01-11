local moduleObject = {}

function moduleObject:new(...)
	local newModule = {}
	setmetatable(newModule, {
		__index = self,
		__tostring = function() return newModule.FullName end
	})
	newModule:init(...)
	return newModule
end
function moduleObject:init(root, path)
	self.Name = path:reverse():match("[%a%d-_]+"):reverse()
	self.FullName = path:gsub(root .. "/", ""):gsub("/", ".")
	self.ParentFullName = self.FullName:gsub(self.FullName:reverse():match("([%a%d-_]+.)"):reverse(), "")
	self.ModulePath = path .. "/module"
	self.Module = false
	self.Dependencies = {}
	self.Dependants = {}
	self.DependenciesIndex = {}
	self.DependantsIndex = {}
	-- self.Depth = select(2, self.FullName:gsub("%.", ""))
end
function moduleObject:getDependency(moduleObject)

end
function moduleObject:addDependency(moduleObject)
	self.Dependencies[#self.Dependencies + 1] = moduleObject
	self.DependenciesIndex[moduleObject.FullName] = #self.Dependencies
end
function moduleObject:addDependant(moduleObject)
	self.Dependants[#self.Dependants + 1] = moduleObject
	self.DependantsIndex[moduleObject.FullName] = #self.Dependants
end
function moduleObject:loadModule()
	self.Module = require(self.ModulePath)
end

return moduleObject
