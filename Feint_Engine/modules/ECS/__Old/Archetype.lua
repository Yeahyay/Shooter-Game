local ffi = require("ffi")

local Archetype = {}
Archetype.DEFINED_TYPES = {}
function Archetype:new(components, ...)
	local signature, signatureStripped = self:getArchetypeSignatureFromComponents(components)

	if self:exists(signatureStripped) then
		printf("ARCHETYPE DEFINITION WARNING: archetype %q is already defined\n", signatureStripped)
		return self.DEFINED_TYPES[signatureStripped]
	end
	-- print(signature, signatureStripped)
	local archetype = {
		ECSData = true;
		ECSType = "Archetype";
		NameDisplay = false;--"Archetype_" .. (signatureStripped or "?");
		Name = signatureStripped;
		NameType = "Archetype_" .. signatureStripped;
		Signature = signature;
	}
	archetype.NameDisplay = string.format("Archetype %q (%s)", signatureStripped, tostring(archetype):gsub("table: ", ""))
	setmetatable(archetype, {
		__index = self;
		__tostring = function()
			return archetype.NameDisplay -- string.format("Archetype \"%s\"", archetype.NameDisplay)
		end
	})
	archetype:init(components, ...)
	Archetype.DEFINED_TYPES[archetype.Name] = archetype
	Feint.Util.Table.makeTableReadOnly(archetype, function(self, k)
		return string.format("attempt to modify %s", archetype.NameDisplay)
	end)
	return archetype
end
function Archetype:exists(componentName)
	return Archetype.DEFINED_TYPES[componentName]
end
function Archetype:init(components, ...)
	assert(type(components) ~= "string", nil, 1)
	assert(components ~= nil, "no components given")
	-- holds components for the archetype
	self.components = components
	self.chunkCount = 0
	self.numInstances = 0
	self.totalSize = 0 -- the total size of every component and its fields
	self.totalSizeBytes = 0
	self.ffiType = nil

	self:createArchetype()
	-- print("rjwiegfwaoijfungoeriwfowds", self.Signature, self.Name)
	return self
end

function Archetype:containsComponent(component)
	return self.Signature:find(component.Name) and true or false
end

function Archetype:createArchetype()
	for i = 1, #self.components, 1 do
		self.totalSize = self.totalSize + self.components[i].numMembers
		self.totalSizeBytes = self.totalSizeBytes + self.components[i].sizeBytes
	end

	local structMembers = {}
	for k, v in pairs(self.components) do
		structMembers[k] = string.format("struct %s %s", v.NameType, v.Name)
	end
	local s = string.format("struct\n%s\n{\n%s\n}", self.NameType, table.concat(structMembers, ";\n") .. ";")
	print(s)
	ffi.cdef(s)

	local ct = ffi.typeof(string.format("struct %s", self.NameType))
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
		self.initValues[name] = self.components[i]:getInitValues()
		-- print(i, name, self.components[i], self.components[i]:getInitValues())
		-- for k, v in pairs(self.components[i]:getInitValues()) do
		-- 	print(k, v)
		-- end
	end
	self.initializer = ffi.new(string.format("struct %s", self.NameType), self.initValues)

	return self
end

function Archetype:getArchetypeSignatureFromComponents(components)
	local stringTable = {}
	assert(components, "no components", 3)
	local unique = {}
	for i = 1, #components do
		local v = components[i]
		if v.ECSData and v.ECSType == "Component" then
			stringTable[#stringTable + 1] = v.Name .. "|"
			assert(not unique[v.Name], string.format("duplicate component %q archetype", v.NameDisplay), 2)
			unique[v.Name] = true
		end
	end
	table.sort(stringTable, function(a, b) return a < b end)
	local archetypeSignatureStripped = table.concat(stringTable):gsub("|", "")
	stringTable[#stringTable + 1] = "_signature"
	local archetypeSignature = table.concat(stringTable)
	return archetypeSignature, archetypeSignatureStripped
end

return Archetype
