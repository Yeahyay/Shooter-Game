local ffi = require("ffi")

local ECSutils = Feint.ECS.Util

local EntityArchetype = ECSutils.newClass("EntityArchetype")

function EntityArchetype:init(components, ...)
	assert(type(components) ~= "string", 1)
	-- holds components for the archetype
	self.components = components
	self.componentData = {}
	self.componentData_componentName = {}
	self.componentData_fieldCount = {}
	self.componentData_fieldName = {}
	self.archetypeString = nil
	self.chunkCount = 0
	self.numInstances = 0
	-- self.chunkCapacity = 32
	self.totalSize = 0 -- the total size of every component and its fields
	self.totalSizeBytes = 0
	self.ffiType = nil

	self:createArchetype()
	return self
end

function EntityArchetype:createArchetype()
	local components = {}
	for i = 1, #self.components, 1 do
		local v = self.components[i]
		components[i] = v.Name
		self.totalSize = self.totalSize + self.components[i].size
		self.totalSizeBytes = self.totalSizeBytes + self.components[i].sizeBytes
	end
	table.sort(components, function(a, b) return a < b end)
	self.archetypeString = table.concat(components)
	self.Name = self.archetypeString -- redundant?
	-- Feint.Log.logln(self.archetypeString)


	self.structMembers = {}
	for k, v in pairs(self.components) do
		self.structMembers[k] = "struct component_" .. v.Name
	end
	self.ffiType = ffi.cdef(string.format([[
		struct archetype_%s {
			%s
		}
	]], self.archetypeString, table.concat(self.structMembers, ";\n") .. ";"))

	return self
end

-- Feint.Util.Table.makeTableReadOnly(EntityArchetype, function(self, k)
-- 	return string.format("attempt to modify %s", EntityArchetype.Name)
-- end)
return EntityArchetype
