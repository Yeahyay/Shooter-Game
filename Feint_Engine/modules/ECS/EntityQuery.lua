local EntityQuery = {}

local EntityArchetype = Feint.ECS.EntityArchetype
function EntityQuery:init(with, with_Count, withAll, withAll_Count, without, without_Count)
	self.components = withAll
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
function EntityQuery:findValidArchetypes(entityManager)
	local validArchetypes = {}
	printf("Finding valid archetypes for \"%s\"\n", self.rawArchetypeSignature)
	for archetypeSignature, _ in pairs(entityManager.archetypeChunkManager.archetypes) do
		if archetypeSignature == "size" then goto continue end

		local match = true
		for _, component in ipairs(self.components) do
			if not archetypeSignature:match(component.Name) then
				match = false
				printf("%s contains %s: %s\n", archetypeSignature, component.Name, match)
				break
			end
			printf("%s contains %s: %s\n", archetypeSignature, component.Name, match)
		end
		if match then
			validArchetypes[#validArchetypes + 1] = archetypeSignature
		end
		-- local match = false
		-- if archetypeSignature:match(self.rawArchetypeSignature) then
		-- 	match = true
		-- 	validArchetypes[#validArchetypes + 1] = archetypeSignature
		-- end
		printf("Signature \"%s\" matches: %s\n\n", archetypeSignature, match)

		::continue::
	end
	print()
	print()
	print()
	return validArchetypes
end
function EntityQuery:getArchetypeChunks(entityManager)
	local validArchetypes = self:findValidArchetypes(entityManager)
	local archetypeChunks = {}
	-- print(#validArchetypes)
	for i = 1, #validArchetypes, 1 do
		local archetypeChunkGroup = entityManager.archetypeChunkManager:getArchetypeChunkGroupFromArchetypeSignature(validArchetypes[i])
		-- print(archetypeChunkGroup:getArchetypeChunks())
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
function EntityQuery:new(...)
	local newEntityQuery = {
		init = EntityQuery.init
	}
	setmetatable(newEntityQuery, {
		__index = self
	})
	newEntityQuery:init(...)
	return newEntityQuery
end

return EntityQuery
