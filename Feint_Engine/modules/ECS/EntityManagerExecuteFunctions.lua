local ExecuteFunctions = {
	size = 0
}

local ffi = require("ffi")

function ExecuteFunctions:load(EntityManager)
	function ExecuteFunctions:generateExecuteFunction(num, name)
		if not self[name] then
			local args = {}
			for j = 1, num, 1 do
				local s = [=[
					local a[] = arguments[[]]
					local a[]Name = a[] and a[].Name or nil
				]=]
				args[j] = s:gsub("%[%]", j)
			end
			local argsString = table.concat(args)

			local loop = {}
			for j = 1, num, 1 do
				local s = [=[
					data[j][a[]Name]]=]
				.. (num > 1 and j < num and ",\n" or "")
				loop[j] = s:gsub("%[%]", j)
			end
			local loopString = table.concat(loop)
			local code = [[
				local archetypeChunks = self.archetypeChunks
			]]
			.. argsString ..
			[[
				for i = 1, self.archetypeChunksCount[archetype], 1 do
					local archetypeChunk = archetypeChunks[archetype][i]
					local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

					for j = archetypeChunk.numEntities - 1, 0, -1 do
						callback(
			]]
			.. loopString ..
			[[
						)
					end
				end
			]]

			-- code = code:gsub("\t", "")
			local chunk = load(code, name)
			rawset(self, name, chunk)
			self.size = self.size + 1
			return chunk
		else
			print("ALREADY GENERATED CODE FOR: " .. name)
			return self[name]
		end
	end
	for i = 1, 10, 1 do
		ExecuteFunctions:generateExecuteFunction(i, "execute" .. i)
	end

	if Feint.ECS.FFI_OPTIMIZATIONS then
		function ExecuteFunctions:execute(arguments, archetype, callback)
			local archetypeChunks = self.archetypeChunks
			local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
			local a1Name, a2Name = a1 and a1.Name or nil, a2 and a2.Name or nil
			local a3Name, a4Name = a3 and a3.Name or nil, a4 and a4.Name or nil
			-- local a5Name, a6Name = a5 and a5.Name or nil, a6 and a6.Name or nil
			print(a1, a2, a3, a4, a5, a6)

			for i = 1, self.archetypeChunksCount[archetype], 1 do
				local archetypeChunk = archetypeChunks[archetype][i]
				local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

				for j = archetypeChunk.numEntities - 1, 0, -1 do
					callback(
						data[j][a1Name], data[j][a2Name],
						data[j][a3Name], data[j][a4Name]
						-- data[j][a5Name], data[j][a6Name]
					)
				end
			end
		end
		function ExecuteFunctions:executeEntity(arguments, archetype, callback)
			local archetypeChunks = self.archetypeChunks
			local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
			local a3Name, a4Name = a3.Name, a4.Name

			for i = 1, self.archetypeChunksCount[archetype], 1 do
				local archetypeChunk = archetypeChunks[archetype][i]
				local idList = archetypeChunk.entityIndexToId
				local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

				for j = archetypeChunk.numEntities - 1, 0, -1 do
					callback(idList[j + 1], data[j][a3Name], data[j][a4Name])
				end
			end
		end
		function ExecuteFunctions:executeEntityAndData(arguments, archetype, callback)
			local archetypeChunks = self.archetypeChunks
			local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
			local a3Name, a4Name = a3.Name, a4.Name

			for i = 1, self.archetypeChunksCount[archetype], 1 do
				local archetypeChunk = archetypeChunks[archetype][i]
				local idList = archetypeChunk.entityIndexToId
				local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

				for j = archetypeChunk.numEntities - 1, 0, -1 do
					callback(data, idList[j + 1], data[j][a3Name], data[j][a4Name])
				end
			end
		end
	else
		function ExecuteFunctions:execute(arguments, archetype, callback)
			-- printf("Calling function on entities\n")
			local archetypeChunks = self.archetypeChunks
			local a1, a2, a3, a4, a5, a6 = unpack(arguments) --luacheck: ignore
			--local a1, a2, a3, a4, a5, a6 = arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]

			for i = 1, self.archetypeChunksCount[archetype], 1 do
				local archetypeChunk = archetypeChunks[archetype][i]
				local idList = archetypeChunk.entityIndexToId
				local data = archetypeChunk.data

				for j = 1, archetypeChunk.numEntities, 1 do
					local offset = (j - 1) * archetypeChunk.entitySize + 1
					-- callback(data, idList[j], offset, a3[1] + offset)
					callback(data, idList[j], offset, a3.size + offset)
				end											-- [1] is actually .size
			end
		end
	end
	setmetatable(ExecuteFunctions,
		{
			__newindex = function(self, name, v)
				self:generateExecuteFunction(self.size, name)
			end
		}
	)
end

return ExecuteFunctions
