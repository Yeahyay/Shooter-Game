local ArchetypeMethods = {}

local EntityArchetype = Feint.ECS.EntityArchetype
local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk
function ArchetypeMethods:load(EntityManager)
	EntityManager = EntityManager
	-- ARCHETYPE CONSTRUCTORS
	function self:newArchetypeFromComponents(components)
		local archetype = EntityArchetype:new(components)
		self.archetypes[archetype.signature] = archetype
		self.archetypes.size = self.archetypes.size + 1
		-- self.archetypeCount = self.archetypeCount + 1
		-- Feint.Log:logln("Creating archetype " .. archetype.Name)

		self:newArchetypeChunkFromArchetype(archetype)
		return archetype
	end

	-- ARCHETYPE GETTERS
	-- function self:getArchetypeSignatureFromComponents(arguments)
	-- 	local stringTable = {}
	-- 	assert(arguments, "no arguments", 3)
	-- 	for i = 1, #arguments do
	-- 		local v = arguments[i]
	-- 		if v.componentData then
	-- 			stringTable[#stringTable + 1] = v.Name
	-- 		end
	-- 	end
	-- 	return table.concat(stringTable)
	-- end
	-- Feint.Util.Memoize(ArchetypeMethods.getArchetypeSignatureFromComponents)
	function self:getArchetypeFromString(string)
		return self.archetypes[string]
	end
	function self:getArchetypeFromComponents(componentArguments)
		local archetypeSignature = self:getArchetypeSignatureFromComponents(componentArguments)
		if not self.archetypes[archetypeSignature] then
			self.archetypes[archetypeSignature] = self:newArchetypeFromComponents(componentArguments)
		end
		return self.archetypes[archetypeSignature]
	end

	-- ARCHETYPE CHUNK CONSTRUCTORS
	function self:newArchetypeChunkFromArchetype(archetype)
		local archetypeChunk = EntityArchetypeChunk:new(archetype)
		-- Feint.Log.log("Creating archetype chunk %s, id: %d\n", archetypeChunk.Name, archetypeChunk.index)


		local currentArchetypeChunkTable = self:getArchetypeChunkTableFromArchetype(archetype)

		self.archetypeChunks[archetype].size = self.archetypeChunks[archetype].size + 1
		currentArchetypeChunkTable[self.archetypeChunks[archetype].size] = archetypeChunk

		-- self.archetypeChunksCount[archetype] = self.archetypeChunksCount[archetype] + 1
		-- currentArchetypeChunkTable[self.archetypeChunksCount[archetype]] = archetypeChunk

		return archetypeChunk
	end

	-- ARCHETYPE CHUNK GETTERS
	function self:getNextArchetypeChunk(archetype)
		local currentArchetypeChunkTable = self:getArchetypeChunkTableFromArchetype(archetype)
		-- print(archetype)
		assert(self.archetypes[archetype.signature],
			string.format("Archetype %s does not exist", archetype.signature), 2)
		local currentArchetypeChunkTableCount = self.archetypeChunksCount[archetype]

		local currentArchetypeChunk = currentArchetypeChunkTable[currentArchetypeChunkTableCount]

		if currentArchetypeChunk:isFull() then
			-- Feint.Log:logln(currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes)
			-- Feint.Log:logln((currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes) / 1024)
			currentArchetypeChunk = self:newArchetypeChunkFromArchetype(archetype)
		end
		return currentArchetypeChunk
	end

	function self:getArchetypeChunkTableFromArchetype(archetype)
		local currentArchetypeChunkTable = self.archetypeChunks[archetype]
		if not currentArchetypeChunkTable then
			self.archetypeChunks[archetype] = {size = 0}
			-- self.archetypeChunks[archetype] = setmetatable({}, {__index = {size = 0},
				-- __newindex = function(self, k, v)
				-- 	if type(k) ~= "number" then
				-- 		error("not a number", 2)
				-- 	end
				-- end
				-- })

			-- self.archetypeChunksCount[archetype] = 0
			-- currentArchetypeChunkTable = self.archetypeChunks[archetype]
			currentArchetypeChunkTable  = self:newArchetypeChunkFromArchetype(archetype)
		end
		return currentArchetypeChunkTable
	end
	function self:getArchetypeChunkTableFromString(string)
		local currentArchetype = self:getArchetypeFromString(string)
		local currentArchetypeChunkTable = self.archetypeChunks[currentArchetype]
		if not currentArchetypeChunkTable then
			self.archetypeChunks[currentArchetype] = {}
			self.archetypeChunksCount[currentArchetype] = 0
			currentArchetypeChunkTable = self.archetypeChunks[currentArchetype]
		end
		return currentArchetypeChunkTable
	end
	function self:getArchetypeChunkFromEntity(id)
		return self.entities[id][1]
	end
	function self:getArchetypeChunkEntityIndexFromEntity(id)
		return self.entities[id][2]
	end

	setmetatable(ArchetypeMethods, {
		__index = function(t, k)
			return rawget(EntityManager, k)
		end,
		__newindex = function(t, k, v)
			error("no.", 3)
		end
	})
end

return ArchetypeMethods
