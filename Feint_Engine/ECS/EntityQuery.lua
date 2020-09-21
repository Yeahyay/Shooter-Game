local EntityQuery = {}
function EntityQuery:init(components, componentsExclude)
	printf("created entity query with %s and without %s", table.concat(self.queryComponents, ", "), table.concat(self.queryComponentsExclude, ", "))
end
function EntityQuery:getChunkCount()

end
function EntityQuery:getEntityCount()

end
function EntityQuery:new(with, withall, without)
	local newEntityQuery = setmetatable({}, {
		__index = EntityQuery
	})
	return newEntityQuery
end
return EntityQuery
