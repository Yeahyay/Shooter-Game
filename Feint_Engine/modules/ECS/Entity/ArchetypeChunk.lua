local ffi = require("ffi")

local ArchetypeChunk = {}
function ArchetypeChunk:new(...)
	local newArchetypeChunk = {
		Name = "Archetype Chunk";
	}
	local string = string.format("Archetype Chunk %q (%s)", newArchetypeChunk.Name, tostring(newArchetypeChunk):gsub("table: ", ""))
	setmetatable(newArchetypeChunk, {
		__index = self;
		__tostring = function()
			return string
		end
	})
	newArchetypeChunk:init(...)
	Feint.Util.Table.makeTableReadOnly(newArchetypeChunk, function(self, k)
		return string.format("attempt to modify %s", newArchetypeChunk.Name)
	end)
	return newArchetypeChunk
end

function ArchetypeChunk:init(archetype, ...)
	assert(Feint.Core.Util:type(archetype) == "table", "EntityArchetypeChunk needs an archetype", 1)
	self.archetype = archetype

	self.entitySizeBytes = self.archetype.totalSizeBytes

	self.capacityBytes = 16384
	self.capacity = math.floor(self.capacityBytes / self.entitySizeBytes) -- 1024 - 2
	self.numEntities = 0

	self.entityIdToIndex = {}
	self.entityIndexToId = {}

	getmetatable(self).__tostring = function() return self.Name end

	self.structDefinition = string.format("struct %s*", self.archetype.NameType)

	local tp = ffi.typeof(string.format("struct %s[$]", self.archetype.NameType), self.capacity)
	self.rawData = ffi.new(tp, self.archetype.initializer)
	self.byteData = love.data.newByteData(self.capacity * self.entitySizeBytes)
	local data = self.byteData:getFFIPointer()
	ffi.copy(data, self.rawData, self.capacity * self.entitySizeBytes)
	self.data = data

	self:preallocate(self.capacity)

	self.dead = false

	self.archetype.chunkCount = self.archetype.chunkCount + 1
	self.index = self.archetype.chunkCount
end
function ArchetypeChunk:remove()
	self.archetype.chunkCount = self.archetype.chunkCount - 1
	for k, v in pairs(self) do
		self[k] = nil
	end
	self.dead = true
end
function ArchetypeChunk:isFull()
	return self.numEntities >= self.capacity
end
function ArchetypeChunk:isFullBytes()
	return self.numEntities * self.entitySizeBytes >= self.capacityBytes - self.entitySizeBytes
end
function ArchetypeChunk:isEmpty()
	return self.numEntities <= 0
end

function ArchetypeChunk:getEntityIndexFromID(id)
	return self.entityIdToIndex[id]
end
function ArchetypeChunk:getEntityIDFromIndex(index)
	return self.entityIndexToId[index]
end
function ArchetypeChunk:getDataArray()
	return ffi.cast(self.structDefinition, self.data)
end

local cstring = ffi.typeof("cstring")
function ArchetypeChunk:preallocate(num)
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
function ArchetypeChunk:newEntity(id)
	if not self:isFull() then
		-- assert(type(id) == "number" and id >= -math.huge, "new entity expects a number", 3)
		-- if not (type(id) == "number" and id >= -math.huge) then
		-- 	print("New entity would like a number")
		-- end
		self.numEntities = self.numEntities + 1
		self.entityIdToIndex[id] = self.numEntities
		self.entityIndexToId[self.numEntities] = id
		return self.numEntities
	else
		Feint.Log:logln("Archetype chunk is full")
	end
	return nil
end
function ArchetypeChunk:removeEntity(index)
	-- swap a removed entity with the last entity
	local data = self:getDataArray()
	data[index], data[self.numEntities] = data[self.numEntities], data[index]
	self.numEntities = self.numEntities - 1
end

return ArchetypeChunk
