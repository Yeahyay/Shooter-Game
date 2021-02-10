local tableUtilities = {
	depends = {"Util"}
}

function tableUtilities:load()
-- do
-- 	local lastEnv = getfenv(1)
-- 	tableUtilities._ENV = tableUtilities
-- 	tableUtilities._ENV_LAST = lastEnv
-- 	tableUtilities._TYPE = "MODULE"
-- 	tableUtilities._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
-- 	tableUtilities._NAME = "UTILITIES"
-- 	-- set the table tableUtilities to refer to the main program's _G
-- 	setmetatable(tableUtilities, {__index = lastEnv})
-- end
local load_ = Feint.Util.Memoize(load)
self.preallocate = --[[Feint.Util.Memoize]](function(arraylength, hashLength)
	local t = load_("return {" .. ("1, "):rep(arraylength or 0) .. ("a = 1,"):rep(hashLength or 0) .. "}")();
	for k in pairs(t) do
		t[k] = nil
	end
	return t;
end)

function self.readOnlyTable(table)
	return setmetatable({}, {
		-- __index = table,
		__newindex = function(t, k, v)
			error("attempt to modify read-only table", 2)
		end,
		__metatable = false
	})
end

-- luacheck:push ignore
function self.formatTableString(table)
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
-- luacheck: pop ignore

function self.makeTableReadOnly(table, callback)
	assert(getmetatable(table), "table must have a metatable", 2)
	local mt = getmetatable(table)
	if mt then
		mt.__newindex = function(t, k, v)
			printf("%s %s %s\n", t, k, v)
			error(callback(t, k, v) or "attempt to modify read-only table", 2)
		end
		mt.__metatable = false
	else
		printf("no metatable\n")
	end
end

-- function self.INSTANCE_OF_INFO(class, name, string)
-- 	return string.format("instance of %s \"%s\" (%s)", class.Name, name, string)
-- end
--
-- function self.BAD_ARG_ERROR(argNum, funcParameter, expectedType, recievedType)
-- 	return string.format("bad argument #%d to '%s' (%s expected, got %s)'", argNum, funcParameter, expectedType, recievedType)
-- end
-- function self.READ_ONLY_MODIFICATION_ERROR(table, key)
-- 	return string.format("attempt to modify %s by accessing key %s", table, key)
-- end

function self.deepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function self.deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

end

return tableUtilities
