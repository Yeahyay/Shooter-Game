local EntityQuery = {}

local EntityArchetype = Feint.ECS.EntityArchetype
function EntityQuery:new(...)
	local newEntityQuery = {
		-- init = self.init
	}
	setmetatable(newEntityQuery, {
		__index = self
	})
	newEntityQuery:init(...)
	return newEntityQuery
end
function EntityQuery:init(with, with_Count, withAll, withAll_Count, without, without_Count)
	self.components = {}
	for k, v in pairs(withAll) do
		self.components[k] = v
	end
	self.components[withAll_Count + 1] = nil

	--[[
	-- printf("Built entity query with %d elements\n", withAll_Count)
	local componentNames = {}
	for i = 1, withAll_Count, 1 do
		componentNames[i] = self.components[i].Name
	end
	local string = string.format("Built entity query with %02d elements: %s\n",
		withAll_Count,
		table.concat(componentNames, ", ", 1, withAll_Count)
		-- table.concat(self.componentsExclude, ", ")
	):gsub("0", "_")
	printf(string)
	--]]

	self.archetypeSignature, self.rawArchetypeSignature = EntityArchetype:getArchetypeSignatureFromComponents(self.components)
end
function EntityQuery:findValidArchetypes(query, entityManager)
	local validArchetypes = {}
	-- printf("Finding valid archetypes for \"%s\"\n", self.archetypeSignature)
	for archetypeSignature, _ in pairs(entityManager.archetypeChunkManager.archetypes) do
		if archetypeSignature == "size" then goto continue end

		local match = true
		for _, component in ipairs(self.components) do
			if not archetypeSignature:match(component.Name .. "|") then
				match = false
				break
			end
		end
		if match then
			validArchetypes[#validArchetypes + 1] = archetypeSignature
		end

		::continue::
	end
	return validArchetypes
end
function EntityQuery:getArchetypeChunks(query, entityManager)
	local validArchetypes = self:findValidArchetypes(query, entityManager)
	local archetypeChunks = {}
	for i = 1, #validArchetypes, 1 do
		local archetypeChunkGroup = entityManager.archetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(validArchetypes[i])
		for _, archetypeChunk in pairs(archetypeChunkGroup:getArchetypeChunks()) do
			archetypeChunks[#archetypeChunks + 1] = archetypeChunk
		end
	end
	return archetypeChunks
end
function EntityQuery:getChunkCount()
	Feint.Log:logln("ITERATE OVER ALL RELEVANT ARCHETYPE CHUNKS TO GET CHUNK COUNT")
end
function EntityQuery:getEntityCount()
	Feint.Log:logln("ITERATE OVER ALL RELEVANT ARCHETYPE CHUNKS TO GET ENTITY COUNT")
end

return EntityQuery
