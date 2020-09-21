local utilities = {}
-- do
-- 	local lastEnv = getfenv(1)
-- 	utilities._ENV = utilities
-- 	utilities._ENV_LAST = lastEnv
-- 	utilities._TYPE = "MODULE"
-- 	utilities._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
-- 	utilities._NAME = "UTILITIES"
-- 	-- set the table utilities to refer to the main program's _G
-- 	setmetatable(utilities, {__index = lastEnv})
-- end

function utilities.readOnlyTable(table)
	return setmetatable({}, {
		__index = table,
		__newindex = function(t, k, v)
			error("attempt to modify read-only table")
		end,
		__metatable = false
	})
end

function utilities.formatTableString(table)
	local mt = getmetatable(table)
	if mt then
	else
		mt = {
			__tostring = function(t)
				for k, v in pairs(t) do
					printf("%s %s\n", k, v)
				end
			end
		}
	end
end

function utilities.makeTableReadOnly(table, callback)
	assert(getmetatable(table), "table must have a metatable")
	local mt = getmetatable(table)
	if mt then
		mt.__newindex = function(t, k, v)
			printf("%s %s %s\n", t, k, v)
			error(callback(t, k, v) or "attempt to modify read-only table")
		end
		mt.__metatable = false
	else
		printf("no metatable\n")
	end
end

-- function utilities.INSTANCE_OF_INFO(class, name, string)
-- 	return string.format("instance of %s \"%s\" (%s)", class.Name, name, string)
-- end
--
-- function utilities.BAD_ARG_ERROR(argNum, funcParameter, expectedType, recievedType)
-- 	return string.format("bad argument #%d to '%s' (%s expected, got %s)'", argNum, funcParameter, expectedType, recievedType)
-- end
-- function utilities.READ_ONLY_MODIFICATION_ERROR(table, key)
-- 	return string.format("attempt to modify %s by accessing key %s", table, key)
-- end

function utilities.save(level)
	printf("SAVING LEVEL %s\n", level)
	levelParser:save(level)
end
function utilities.load(level)
	printf("LOADING LEVEL %s\n", level)
	GameInstance:clear()
	levelParser:load(level)
end
function utilities.getCurrentFolder(path)
	return path:match("(.-)[^%.]+$")
end

return utilities
