local EntityQuery = {}

function EntityQuery:init(with, withCount, withall, withallCount, without, withoutCount)
	self.components = withall

	printf("Built entity query with %d elements\n", #self.components)
	local componentNames = {}
	for i = 1, #self.components, 1 do
		componentNames[i] = self.components[i].Name
	end
	printf("Built entity query with %s\n",
		table.concat(componentNames, ", ")
		-- table.concat(self.componentsExclude, ", ")
	)
end
function EntityQuery:getChunkCount()

end
function EntityQuery:getEntityCount()

end
function EntityQuery:new(with, withall, without)
	local newEntityQuery = {
		init = EntityQuery.init
	} -- maybe a premature optimization
	-- setmetatable({}, {
	-- 	__index = EntityQuery
	-- })
	newEntityQuery:init(with, withall, without)
	return newEntityQuery
end

return EntityQuery
