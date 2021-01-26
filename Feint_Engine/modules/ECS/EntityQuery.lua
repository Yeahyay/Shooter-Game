local EntityQuery = {}

function EntityQuery:init(with, withCount, withall, withallCount, without, withoutCount)
	self.components = withall

	--[[
	-- printf("Built entity query with %d elements\n", #self.components)
	local componentNames = {}
	for i = 1, #self.components, 1 do
		componentNames[i] = self.components[i].Name
	end
	local string = string.format("Built entity query with %02d elements: %s\n",
		#self.components,
		table.concat(componentNames, ", ")
		-- table.concat(self.componentsExclude, ", ")
	):gsub("0", "_")
	printf(string)
	--]]
end
function EntityQuery:getArchetypeChunks(archetypeChunks)
	-- for k, v in pairs(archetypeChunks) do
	-- 	print(k.archetypeString, v)
	-- end
	-- for k, v in pairs(self.components) do print(k, v) end
	-- print(#self.components)
end
function EntityQuery:getChunkCount()
	Feint.Log:logln("ITERATE OVER ALL RELEVANT ARCHETYPE CHUNKS TO GET CHUNK COUNT")
end
function EntityQuery:getEntityCount()
	Feint.Log:logln("ITERATE OVER ALL RELEVANT ARCHETYPE CHUNKS TO GET ENTITY COUNT")
end
function EntityQuery:new(with, withall, without)
	local newEntityQuery = {
		init = EntityQuery.init
	}
	setmetatable(newEntityQuery, {
		__index = EntityQuery
	})
	newEntityQuery:init(with, withall, without)
	return newEntityQuery
end

return EntityQuery
