local ECSUtils = Feint.ECS.Util

-- queries entities with specific filters
local EntityQuery = Feint.ECS.EntityQuery
local EntityQueryBuilder = ECSUtils.newClass("EntityQueryBuilder")
function EntityQueryBuilder:init()
	self.queryComponents_With_Count = 0
	self.queryComponents_With = setmetatable({},{
		__tostring = function()
			return "EntityQuery_With"
		end;
		__mode = 'v';
	})
	self.queryComponents_WithAll_Count = 0
	self.queryComponents_WithAll = setmetatable({},{
		__tostring = function()
			return "EntityQuery_WithAll"
		end;
		__mode = 'v';
	})
	self.queryComponents_Without_Count = 0
	self.queryComponents_Without = setmetatable({},{
		__tostring = function()
			return "EntityQuery_Without"
		end;
		__mode = 'v';
	})
end
function EntityQueryBuilder:withAll(components)
	local componentCount = #components
	local count = 0
	for i = 1, componentCount do
		local v = components[i]
		if v.componentData then
			count = count + 1
			self.queryComponents_WithAll[count] = v
		end
	end
	-- print(#self.queryComponents_WithAll, count)
	self.queryComponents_WithAll_Count = count--self.queryComponents_WithAll_Count + 1
	-- print(self.queryComponents_WithAll_Count)
	return self
end
function EntityQueryBuilder:with(components)
	local componentCount = #components
	for i = 1, componentCount do
		local v = components[i]
		if v.componentData then
			self.queryComponents_With_Count = self.queryComponents_With_Count + 1
			self.queryComponents_With[self.queryComponents_With_Count] = v
		end
	end
	return self
end
function EntityQueryBuilder:without(components)
	local componentCount = #components
	for i = 1, componentCount do
		local v = components[i]
		if v.componentData then
			self.queryComponents_Without_Count = self.queryComponents_Without_Count + 1
			self.queryComponents_Without[self.queryComponents_Without_Count] = v
		end
	end
	return self
end

function EntityQueryBuilder:withAllArgs(...)
	local argsCount = select("#", ...)
	for i = 1, argsCount do
		local v = select(i, ...)
		if v.componentData then
			self.queryComponents_WithAll_Count = self.queryComponents_WithAll_Count + 1
			self.queryComponents_WithAll[self.queryComponents_WithAll_Count] = v
		end
	end
	return self
end
function EntityQueryBuilder:withArgs(...)
	local argsCount = select("#", ...)
	for i = 1, argsCount do
		local v = select(i, ...)
		if v.componentData then
			self.queryComponents_With_Count = self.queryComponents_With_Count + 1
			self.queryComponents_With[self.queryComponents_With_Count] = v
		end
	end
	return self
end
function EntityQueryBuilder:withoutArgs(...)
	local argsCount = select("#", ...)
	for i = 1, argsCount do
		local v = select(i, ...)
		if v.componentData then
			self.queryComponents_Without_Count = self.queryComponents_Without_Count + 1
			self.queryComponents_Without[self.queryComponents_Without_Count] = v
		end
	end
	return self
end
function EntityQueryBuilder:build()
	-- create query
	-- printf("Building entity query\n")
	local query = EntityQuery:new(
		self.queryComponents_With, self.queryComponents_With_Count,
		self.queryComponents_WithAll, self.queryComponents_WithAll_Count,
		self.queryComponents_Without, self.queryComponents_Without_Count
	)
	-- setup for next query
	self.queryComponents_With_Count = 0
	self.queryComponents_WithAll_Count = 0
	self.queryComponents_Without_Count = 0
	-- for i = 1, self.queryComponents_With_Count do
	-- 	self.queryComponents_With[i] = nil
	-- end
	-- for i = 1, self.queryComponents_WithAll_Count do
	-- 	self.queryComponents_WithAll[i] = nil
	-- end
	-- for i = 1, self.queryComponents_Without_Count do
	-- 	self.queryComponents_Without[i] = nil
	-- end

	-- this creates new objects which is a no no unless query building is memoize
	-- self:init()
	return query
end
-- EntityQueryBuilder.with = Feint.Util.Memoize(EntityQueryBuilder.with)
-- EntityQueryBuilder.withAll = Feint.Util.Memoize(EntityQueryBuilder.withAll)
-- EntityQueryBuilder.without = Feint.Util.Memoize(EntityQueryBuilder.without)
-- EntityQueryBuilder.build = Feint.Util.Memoize(EntityQueryBuilder.build) -- DON'T DO THIS


return EntityQueryBuilder
