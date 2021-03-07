local queryBuilder = {}

function queryBuilder:load(isThread)
	function self:buildQueryFromComponents(components, componentsCount)
		local queryBuilder = self.EntityQueryBuilder
		local query = queryBuilder:withAll(components):build();
		return query
	end
	function self:getEntitiesFromQuery(query)
		-- printf("Getting Entities from Query\n")
		local entities = {}
		return entities
	end
end

return queryBuilder
