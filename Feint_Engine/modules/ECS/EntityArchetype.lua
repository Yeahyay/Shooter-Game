local ffi = require("ffi")

-- local ECSutils = Feint.ECS.Util

local EntityArchetype = {}--ECSutils.newClass("EntityArchetype")
function EntityArchetype:new(...)
	local newArchetype = {name = "EntityArchetype"}
	setmetatable(newArchetype, {
		__index = self;
		__tostring = function()
			return string.format("EntityArchetype \"%s\"", newArchetype.Name)
		end
	})
	newArchetype:init(...)
	return newArchetype
end
-- setmetatable(EntityArchetype, {
-- 	__index = EntityArchetype
-- })

function EntityArchetype:containsComponent(component)
	return self.signature:find(component.Name) and true or false
end

function EntityArchetype:init(components, ...)
	assert(type(components) ~= "string", nil, 1)
	-- holds components for the archetype
	self.components = components
	-- table.sort(self.components, function(a, b) return a.Name < b.Name end)
	-- self.componentData = {}
	-- self.componentData_componentName = {}
	-- self.componentData_fieldCount = {}
	-- self.componentData_fieldName = {}
	self.signature = nil
	self.chunkCount = 0
	self.numInstances = 0
	-- self.chunkCapacity = 32
	self.totalSize = 0 -- the total size of every component and its fields
	self.totalSizeBytes = 0
	self.ffiType = nil

	self:createArchetype()
	return self
end

function EntityArchetype:getArchetypeSignatureFromComponents(components)
	local stringTable = {}
	assert(components, "no components", 3)
	local unique = {}
	for i = 1, #components do
		local v = components[i]
		if v.componentData then
			stringTable[#stringTable + 1] = v.Name
			assert(not unique[v.Name], "duplicate component \"" .. v.Name .. "\" for archetype", 2)
			unique[v.Name] = true
		end
	end
	table.sort(stringTable, function(a, b) return a < b end)
	local rawArchetypeSignature = table.concat(stringTable)
	stringTable[#stringTable + 1] = "_signature"
	local archetypeSignature = table.concat(stringTable)
	return archetypeSignature, rawArchetypeSignature
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
	components[#components + 1] = "_signature"
	self.signature = table.concat(components)
	self.Name = self.signature -- redundant?
	-- Feint.Log:logln(self.signature)

	local structMembers = {}
	for k, v in pairs(self.components) do
		structMembers[k] = "struct component_" .. v.Name .. " " .. v.Name
	end
	local s = string.format([[
		struct archetype_%s {
			%s
		}
	]], self.signature, table.concat(structMembers, ";\n") .. ";")
	-- print(s)
	ffi.cdef(s)

	local ct = ffi.typeof("struct archetype_" .. self.signature)
	local final = ffi.metatype(ct, {
		__pairs = function(t)
			local function iter(t, k)
				k = k + 1
				if k <= #structMembers then
					local name = self.components[k].Name
					return k, name, t[name]
				end
			end
			return iter, t, 0
		end
	})
	self.ffiType = final

	self.initValues = {}
	for i = 1, #self.components, 1 do
		local name = self.components[i].Name
		self.initValues[name] = self.components[i].data --{}
		-- for k, v in ipairs(self.components[i].values) do
		-- 	local field = self.components[i].keys[k]
		-- 	self.initValues[name][field] = v
		-- end
	end
	self.initializer = ffi.new("struct archetype_" .. self.signature, self.initValues)


	return self
end

-- Feint.Util.Table.makeTableReadOnly(EntityArchetype, function(self, k)
-- 	return string.format("attempt to modify %s", EntityArchetype.Name)
-- end)
return EntityArchetype
