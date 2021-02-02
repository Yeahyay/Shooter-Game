local ffi = require("ffi")

local ECSutils = Feint.ECS.Util

local EntityChunk = ECSutils.newClass("EntityChunk")
function EntityChunk:init(archetype, ...)
	assert(Feint.Core.Util:type(archetype) == "table", "EntityArchetypeChunk needs an archetype", 1)
	self.archetype = archetype
	self.Name = archetype.Name.."_ArchetypeChunk"
	self.isFull_cached = false

	self.entitySize = self.archetype.totalSize
	self.entitySizeBytes = self.archetype.totalSizeBytes

	self.capacityBytes = 16384
	self.capacity = math.floor(self.capacityBytes / self.entitySizeBytes) -- 1024 - 2
	self.numEntities = 0

	self.entityIdToIndex = {}
	self.entityIndexToId = {}

	self.structDefinition = "struct archetype_" .. self.archetype.archetypeString .. "*"
	if Feint.ECS.FFI_OPTIMIZATIONS then
		-- self.ffiDataType =
		-- self.data =
		-- 	ffi.new("archetype_" .. self.archetype.archetypeString .. "[?]", self.capacityBytes / self.entitySizeBytes)
		local tp = ffi.typeof("struct archetype_" .. self.archetype.archetypeString .. "[$]", self.capacity)
		-- self.data = ffi.new(tp, self.archetype.initializer)
		self.rawData = ffi.new(tp, self.archetype.initializer)
		self.byteData = love.data.newByteData(self.capacity * self.entitySizeBytes)
		local data = self.byteData:getFFIPointer()
		ffi.copy(data, self.rawData, self.capacity * self.entitySizeBytes)
		self.data = data--ffi.cast(self.structDefinition, data)
	else
		self.data = Feint.Util.Table.preallocate(self.capacity * self.archetype.totalSize, 0)
		self.dataStatus = Feint.Util.Table.preallocate(self.capacity)
	end
	self:preallocate(self.capacity)

	-- self.dataStatus = {}
	-- self.dataAlive = 0

	self.dead = false

	self.archetype.chunkCount = self.archetype.chunkCount + 1
	self.index = self.archetype.chunkCount

	-- local s = 40
	-- for k, v in pairs(self) do
	-- 	if type(k) == "string" then
	-- 		s = s + 40
	-- 	elseif type(k) == "number" then
	-- 		s = s + 16
	-- 	end
	-- end
	-- self.capacityBytes = self.capacityBytes - s
	-- self.capacityBytes = math.floor(self.capacityBytes / 64) * 64
	-- self.capacity = math.floor(self.capacityBytes / self.entitySizeBytes) -- 1024 - 2
	-- print(self.capacity, self.capacityBytes, self.capacity * self.entitySizeBytes)
end
function EntityChunk:remove()
	self.archetype.chunkCount = self.archetype.chunkCount - 1
	for k, v in pairs(self) do
		self[k] = nil
	end
	self.dead = true
end
function EntityChunk:isFull()
	return self.numEntities >= self.capacity
end
function EntityChunk:isFullBytes()
	return self.numEntities * self.entitySizeBytes >= self.capacityBytes - self.entitySizeBytes
end
function EntityChunk:isEmpty()
	return self.numEntities <= 0
end
-- function EntityChunk:getEntity()
if Feint.ECS.FFI_OPTIMIZATIONS then
	local cstring = ffi.typeof("cstring")
	function EntityChunk:preallocate(num)
		local components = self.archetype.components
		local data = ffi.cast(self.structDefinition, self.data)
		for i = 0, num - 1, 1 do
			local archetypeInstance = data[i]
			for j = 1, #components, 1 do
				local component = components[j]
				local componentInstance = archetypeInstance[component.Name]
				for k, v in pairs(component.strings) do
					componentInstance[k] = cstring(v)
				end
			end
		end
	end
	function EntityChunk:newEntity(id)
		if not self:isFull() then
			assert(type(id) == "number" and id >= 0, "new entity expects a number", 3)
			self.numEntities = self.numEntities + 1
			self.entityIdToIndex[id] = self.numEntities
			self.entityIndexToId[self.numEntities] = id
			return self.numEntities
		else
			Feint.Log:logln("Archetype chunk is full")
		end
		return nil
	end
else
	function EntityChunk:newEntity(id)
		if not self:isFull() then
			assert(type(id) == "number" and id >= 0, "new entity expects a number", 3)
			local dataOffset = self.numEntities * self.entitySize
			for archetyeComponentIndex = 1, #self.archetype.components, 1 do
				local component = self.archetype.components[archetyeComponentIndex]
				-- Feint.Log.log("Allocating memory for component %s\n", component.Name)
				-- for k, v in pairs(self.archetype.components[i]) do
				-- 	print(k, v)
				-- end
				for i = 1, component.size, 1 do
					dataOffset = dataOffset + 1
					local value = component.values[i]
					self.data[dataOffset] = value -- set each field to its default value
				end
			end
			self.numEntities = self.numEntities + 1
			self.entityIdToIndex[id] = self.numEntities
			self.entityIndexToId[self.numEntities] = id
			return self.numEntities
		else
			Feint.Log:logln("Archetype chunk is full")
		end
		return nil
	end
	function EntityChunk:preallocate(num)
		for j = 1, math.min(num, self.capacity), 1 do
			local dataOffset = j * self.entitySize
			for archetyeComponentIndex = 1, #self.archetype.components, 1 do
				local component = self.archetype.components[archetyeComponentIndex]
				-- Feint.Log.log("Allocating memory for component %s\n", component.Name)
				-- for k, v in pairs(self.archetype.components[i]) do
				-- 	print(k, v)
				-- end
				for i = 1, component.size, 1 do
					dataOffset = dataOffset + 1
					self.data[dataOffset] = component.values[i] -- set each field to its default value
				end
			end
			-- self.numEntities = self.numEntities + 1
			-- self.entityIdToIndex[id] = dataOffset / self.entitySize
			-- self.entityIndexToId[dataOffset / self.entitySize] = id
			-- return dataOffset / self.archetype.entitySize
			-- self.dataAlive = self.dataAlive + 1
			-- self.dataStatus[self.dataAlive] = true
		end
	end
end
function EntityChunk:removeEntity(index)
	-- swap a removed entity with the last entity
	self.data[index], self.data[self.numEntities] = self.data[self.numEntities], self.data[index]
	self.numEntities = self.numEntities - 1
end
-- Feint.Util.Table.makeTableReadOnly(EntityChunk, function(self, k)
-- 	return string.format("attempt to modify %s", EntityChunk.Name)
-- end)
return EntityChunk
