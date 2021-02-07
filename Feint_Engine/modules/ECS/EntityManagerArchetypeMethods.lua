local ArchetypeMethods = {}

local EntityArchetype = Feint.ECS.EntityArchetype
local EntityArchetypeChunk = Feint.ECS.EntityArchetypeChunk
function ArchetypeMethods:load(EntityManager)
	EntityManager = EntityManager
	-- ARCHETYPE CONSTRUCTORS
	function self:newArchetypeFromComponents(components)
		local archetype = EntityArchetype:new(components)
		EntityManager.archetypes[archetype.archetypeString] = archetype
		EntityManager.archetypeCount = EntityManager.archetypeCount + 1
		-- Feint.Log:logln("Creating archetype " .. archetype.Name)

		EntityManager:newArchetypeChunkFromComponents(archetype)
		return archetype
	end

	-- ARCHETYPE GETTERS
	function self:getArchetypeStringFromComponents(arguments)
		local stringTable = {}
		assert(arguments, "no arguments", 3)
		for i = 1, #arguments do
			local v = arguments[i]
			if v.componentData then
				stringTable[#stringTable + 1] = v.Name
			end
		end
		return table.concat(stringTable)
	end
	-- Feint.Util.Memoize(ArchetypeMethods.getArchetypeStringFromComponents)
	function self:getArchetypeFromString(string)
		return self.archetypes[string]
	end
	function self:getArchetypeFromComponents(arguments)
		local archetypeString = self:getArchetypeStringFromComponents(arguments)
		return self.archetypes[archetypeString]
	end


	-- ARCHETYPE CHUNK CONSTRUCTORS
	function self:newArchetypeChunkFromComponents(archetype)
		local archetypeChunk = EntityArchetypeChunk:new(archetype)

		local currentArchetypeChunkTable = self:getArchetypeChunkTableFromArchetype(archetype)

		self.archetypeChunksCount[archetype] = self.archetypeChunksCount[archetype] + 1
		currentArchetypeChunkTable[self.archetypeChunksCount[archetype]] = archetypeChunk

		-- Feint.Log.log("Creating archetype chunk %s, id: %d\n", archetypeChunk.Name, archetypeChunk.index)
		return archetypeChunk
	end

	-- ARCHETYPE CHUNK GETTERS
	function self:getNextArchetypeChunk(archetype)
		local currentArchetypeChunkTable = self:getArchetypeChunkTableFromArchetype(archetype)
		-- print(archetype)
		assert(self.archetypes[archetype.archetypeString],
			string.format("Archetype %s does not exist", archetype.archetypeString), 2)
		local currentArchetypeChunkTableCount = self.archetypeChunksCount[archetype]

		local currentArchetypeChunk = currentArchetypeChunkTable[currentArchetypeChunkTableCount]

		if currentArchetypeChunk:isFull() then
			-- Feint.Log:logln(currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes)
			-- Feint.Log:logln((currentArchetypeChunk.numEntities * currentArchetypeChunk.entitySizeBytes) / 1024)
			currentArchetypeChunk = self:newArchetypeChunkFromComponents(archetype)
		end
		return currentArchetypeChunk
	end

	function self:getArchetypeChunkTableFromArchetype(archetype)
		local currentArchetypeChunkTable = self.archetypeChunks[archetype]
		if not currentArchetypeChunkTable then
			self.archetypeChunks[archetype] = {}
			self.archetypeChunksCount[archetype] = 0
			currentArchetypeChunkTable = self.archetypeChunks[archetype]
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
