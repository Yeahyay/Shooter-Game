local ExecuteFunctions = {
	size = 0
}

local ffi = require("ffi")

function ExecuteFunctions:load(EntityManager)
	function self:getTabs(code)
		local _, count = code:match("([%s]*)%g"):gsub("\t", "__tab;")
		return count
	end
	function self:debugPrint(code)
		local tabString = string.rep("\t", 	4)--self:getTabs(code))
		-- print("\n\n;"..tabString:gsub("\t", "   ")..";\n\n")
		-- local c = 0
		code = code:gsub("([^\n]*)\n", function(match, cap1)
			-- c = c + 1
			-- local s = match:gsub(tabString .. "([\t%a]*\n)", "%1")
			-- print(match.."\n")
			-- local s = match:gsub(tabString, "   ", 1)
			local s = match:gsub(tabString, "   ")
			-- print(c)
			-- print(s)
			return s .. "\n"
		end)

		local c = 0
		code = code:gsub("([^\n]*)\n", function(match)
			c = c + 1
			return string.format("%4d |\t%s\n", c, match)
		end)

		-- code = code:gsub("\t", "__;")
		printf("\n%s\n", code)
	end
	function ExecuteFunctions:generateExecuteFunction(num, name)
		assert(num > 0, "no args", 2)
		if not self[name] then
			local args = {}
			for j = 1, num, 1 do
				local s = [=[
					local a$ = arguments[$]
					local a$Name = a$ and a$.Name or nil
					-- print(a$Name, "a$", arguments[$].Name)
				]=]
				args[j] = s:gsub("%$", j)
			end
			local argsString = "\n" .. table.concat(args) .. "\n"

			local loop = {}
			for j = 1, num, 1 do
				local s = string.rep("\t", 4) .. [=[data[j][a$Name]]=]
				.. (num > 1 and j < num and ",\n" or "")
				loop[j] = s:gsub("%$", j)
			end
			local loopString = table.concat(loop) .. "\n"
			-- print(argsString, "jnijoinopo[jipnj]")
			local code = [[
				-- local archetypeChunkManager, arguments, archetype, callback = ...
				local ffi = require("ffi")
				return function(entityManager, source, arguments, archetype, archetypeChunks, callback)
					assert(archetype, "no archetype given to execute function", 2)
					-- local archetypeChunkManager = entityManager.archetypeChunkManager
					-- local archetypeChunkGroup = archetypeChunkManager:getArchetypeChunkGroupFromArchetype(archetype)

					-- printf("System: %s, Archetype: %s\n   Num Args: %d, Callback: %s\n", source, archetype.signature, #arguments, callback)
					-- local archetypeChunks = archetypeChunkGroup:getArchetypeChunks()
			]]
			.. argsString ..
			[[
					-- print(archetypeChunkGroup)
					-- for k, v in pairs(archetypeChunkGroup) do
					-- 	print(k, v, "--0-ko0")
					-- end
					-- print(source, archetype)

					-- archetypeChunkGroup:getOpenArchetypeChunk():newEntity(entityManager:getNewEntityId())
					-- print(archetypeChunkGroup, archetypeChunkGroup.size, archetypeChunkGroup.archetype)
					-- print()
					-- print(archetypeChunks, #archetypeChunks, archetypeChunks.archetype)
					-- print()
					for i = 1, #archetypeChunks or 0, 1 do
						local archetypeChunk = archetypeChunks[i]
						local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

						-- print(archetypeChunk.numEntities, archetypeChunk.archetype)
						local idList = archetypeChunk.entityIndexToId
						for j = archetypeChunk.numEntities - 1, 0, -1 do
							callback(j,
			]]
			.. loopString ..
			[[
							)
						end
					end
					-- print(archetypeChunkManager, arguments, archetype, callback)
					return 0
				end
			]]

			-- printf("\n%s\n", code:gsub("\t*(%g*)\n", "\n"):gsub("\t", "__;"))
			-- self:debugPrint(code)

			local chunk = load(code, name)()
			-- print(chunk)
			rawset(self, name, chunk)
			-- self.size = self.size + 1
			return chunk
		else
			print("ALREADY GENERATED CODE FOR: " .. name)
			return self[name]
		end
	end
	for i = 1, 0, 1 do
		ExecuteFunctions:generateExecuteFunction(i, "execute" .. i)
	end

	if Feint.ECS.FFI_OPTIMIZATIONS then
		function ExecuteFunctions:noarg()
			error("no arguments given")
		end
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
					local current = data[j]
					callback(
						current[a1Name], current[a2Name],
						current[a3Name], current[a4Name]
						-- current[a5Name], current[a6Name]
					)
				end
			end
		end
		-- function ExecuteFunctions:executeEntity2(arguments, archetype, callback)
		-- 	local archetypeChunks = self.archetypeChunks
		-- 	-- luacheck: push ignore
		-- 	local a1, a2, a3, a4, a5, a6 = unpack(arguments)
		-- 	local a1Name, a2Name = a1 and a1.Name or nil, a2 and a2.Name or nil
		-- 	local a3Name, a4Name = a3 and a3.Name or nil, a4 and a4.Name or nil
		-- 	-- luacheck: pop ignore
		--
		-- 	local operation = callback()
		--
		-- 	for i = 1, self.archetypeChunksCount[archetype], 1 do
		-- 		local archetypeChunk = archetypeChunks[archetype][i]
		-- 		-- local idList = archetypeChunk.entityIndexToId
		-- 		local entities = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)
		--
		-- 		for j = archetypeChunk.numEntities - 1, 0, -1 do
		-- 			operation(nil, j, entities[j][a3Name], entities[j][a4Name])
		-- 		end
		-- 	end
		-- end
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
	function ExecuteFunctions:getExecuteFunction(size)
		local name = "execute" .. size
		return name and self[name] or self:generateExecuteFunction(size, name)
	end

	-- setmetatable(self,
	-- 	{
	-- 		__newindex = function(self, name, v)
	-- 			local func = self:generateExecuteFunction(self.size, name)
	-- 			print(name, v, "jnoipomknjoijpkl")
	-- 			return func
	-- 		end;
	-- 		__index = function(self, key)
	-- 			print(self, key, "knlmknnkln;k")
	-- 			return rawget(self, key)
	-- 		end
	-- 	}
	-- )
end

return ExecuteFunctions
