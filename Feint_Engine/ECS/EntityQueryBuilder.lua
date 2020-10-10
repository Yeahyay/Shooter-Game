local ECSUtils = Feint.ECS.Util

-- queries entities with specific filters
local EntityQuery = Feint.ECS.EntityQuery
local EntityQueryBuilder = ECSUtils.newClass("EntityQueryBuilder")
function EntityQueryBuilder:init()
	self.queryComponents_With = {}
	self.queryComponents_With_Count = 0
	self.queryComponents_WithAll = {}
	self.queryComponents_WithAll_Count = 0
	self.queryComponents_Without = {}
	self.queryComponents_Without_Count = 0
end
function EntityQueryBuilder:withAll(...)
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
function EntityQueryBuilder:with(...)
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
function EntityQueryBuilder:without(...)
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
	local query = EntityQuery:new(self.queryComponents_With, self.queryComponents_WithAll, self.queryComponents_Without)
	-- setup for next query
	self.queryComponents_With = {}
	self.queryComponents_Without = {}
	return query
end
return EntityQueryBuilder
