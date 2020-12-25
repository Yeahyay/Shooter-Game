local moduleObject = {}

function moduleObject:new(...)
	local newModule = {}
	setmetatable(newModule, {
		__index = self
	})
	newModule:init(...)
	return newModule
end
function moduleObject:init(root, path)
	self.Name = path:reverse():match("[%a%d]+"):reverse()
	self.FullName = path:gsub(root .. "/", ""):gsub("/", ".")
	self.ParentFullName = self.FullName:gsub(self.FullName:reverse():match("([%a%d]+.)"):reverse(), "")
	self.ModulePath = path .. "/module"
	self.Module = false
end
function moduleObject:loadModule()
	self.Module = require(self.ModulePath)
end

return moduleObject
