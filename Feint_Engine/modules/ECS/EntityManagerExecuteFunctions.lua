local ExecuteFunctions = {
	size = 0
}

function ExecuteFunctions:load(EntityManager)
	function self:getTabs(code)
		local _, count = code:match("([%s]*)%g"):gsub("\t", "__tab;")
		return count
	end
	function self:debugPrint(code)
		local tabString = string.rep("\t", 	4)
		code = code:gsub("([^\n]*)\n", function(match, cap1)
			local s = match:gsub(tabString, "   ")
			return s .. "\n"
		end)
		local c = 0
		code = code:gsub("([^\n]*)\n", function(match)
			c = c + 1
			return string.format("%4d |\t%s\n", c, match)
		end)
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
			local code = [[
				local ffi = require("ffi")
				return function(entityManager, source, arguments, archetype, archetypeChunks, callback)
					assert(archetype, "no archetype given to execute function", 2)
			]]
			.. argsString ..
			[=[
					for i = 1, #archetypeChunks or 0, 1 do
						local archetypeChunk = archetypeChunks[i]
						local data = ffi.cast(archetypeChunk.structDefinition, archetypeChunk.data)

						local idList = archetypeChunk.entityIndexToId
						for j = archetypeChunk.numEntities - 1, 0, -1 do
							callback(archetypeChunk.entityIndexToId[j + 1],
			]=]
			.. loopString ..
			[[
							)
						end
					end
					return 0
				end
			]]

			local chunk = load(code, name)()
			rawset(self, name, chunk)
			return chunk
		else
			print("ALREADY GENERATED CODE FOR: " .. name)
			return self[name]
		end
	end
	for i = 1, 0, 1 do
		ExecuteFunctions:generateExecuteFunction(i, "execute" .. i)
	end

	function ExecuteFunctions:getExecuteFunction(size)
		local name = "execute" .. size
		return name and self[name] or self:generateExecuteFunction(size, name)
	end
end

return ExecuteFunctions
