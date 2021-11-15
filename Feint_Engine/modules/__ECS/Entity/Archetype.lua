local ffi = require("ffi")

-- local ECSutils = Feint.ECS.Util

local Archetype = {}
function Archetype:new(...)
	local newArchetype = {name = "Archetype"}
	setmetatable(newArchetype, {
		__index = self;
		__tostring = function()
			return string.format("Archetype \"%s\"", newArchetype.Name)
		end
	})
	newArchetype:init(...)
	return newArchetype
end

function Archetype:containsComponent(component)
	return self.signature:find(component.Name) and true or false
end

function Archetype:init(components, ...)
	assert(type(components) ~= "string", nil, 1)
	-- holds components for the archetype
	self.components = components
	self.signature = nil
	self.signatureStripped = nil
	self.chunkCount = 0
	self.numInstances = 0
	self.totalSize = 0 -- the total size of every component and its fields
	self.totalSizeBytes = 0
	self.ffiType = nil

	self:createArchetype()
	return self
end

function Archetype:getArchetypeSignatureFromComponents(components)
	local stringTable = {}
	assert(components, "no components", 3)
	local unique = {}
	for i = 1, #components do
		local v = components[i]
		if v.componentData then
			stringTable[#stringTable + 1] = v.Name .. "|"
			assert(not unique[v.Name], "duplicate component \"" .. v.Name .. "\" for archetype", 2)
			unique[v.Name] = true
		end
	end
	table.sort(stringTable, function(a, b) return a < b end)
	local archetypeSignatureStripped = table.concat(stringTable):gsub("|", "")
	stringTable[#stringTable + 1] = "_signature"
	local archetypeSignature = table.concat(stringTable)
	return archetypeSignature, archetypeSignatureStripped
end

function Archetype:createArchetype()
	-- local components = {}
	for i = 1, #self.components, 1 do
		-- local v = self.components[i]
		-- components[i] = v.Name
		self.totalSize = self.totalSize + self.components[i].numMembers
		self.totalSizeBytes = self.totalSizeBytes + self.components[i].sizeBytes
	end
	-- table.sort(components, function(a, b) return a < b end)
	-- components[#components + 1] = "_signature"
	-- self.signature = table.concat(components)

	self.signature, self.signatureStripped = self:getArchetypeSignatureFromComponents(self.components)

	self.Name = self.signatureStripped -- redundant?
	-- Feint.Log:logln(self.signature)
	-- print(self.signature)
	-- print()

	local structMembers = {}
	for k, v in pairs(self.components) do
		structMembers[k] = "struct component_" .. v.Name .. " " .. v.Name
	end
	local s = string.format([[
		struct archetype_%s {%s}
	]], self.signatureStripped, table.concat(structMembers, ";\n") .. ";")
	print(s)
	ffi.cdef(s)

	local ct = ffi.typeof("struct archetype_" .. self.signatureStripped)
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
		self.initValues[name] = self.components[i].data
	end
	self.initializer = ffi.new("struct archetype_" .. self.signatureStripped, self.initValues)

	return self
end

-- Feint.Util.Table.makeTableReadOnly(Archetype, function(self, k)
-- 	return string.format("attempt to modify %s", Archetype.Name)
-- end)
return Archetype