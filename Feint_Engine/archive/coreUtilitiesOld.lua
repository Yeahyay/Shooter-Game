local coreUtilities = {logLevel = 0}
do
	local lastEnv = getfenv(1)
	-- 	coreUtilities._ENV = coreUtilities
	-- 	coreUtilities._ENV_LAST = lastEnv
	-- 	coreUtilities._TYPE = "MODULE"
	-- 	coreUtilities._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
	-- 	coreUtilities._NAME = "CORE UTILITIES"
	-- 	-- set the table coreUtilities to refer to the main program's _G
	setmetatable(coreUtilities, {__index = lastEnv})
end

function loveType(obj)
	if type(obj) == "userdata" and obj.type then
		return obj:type()
	end
	return nil
end

function printf(format, ...)
	if format then
		io.write(string.format(format or "", ...))
	else
		io.write("")
	end
end

-- make this better lmao
function overloaded()
	local functionSignatures = {}
	local mt = {}

	function mt:__call(...)
		local arg = {...}
		local default = self.default

		local signature = {}
		for i, arg in ipairs {...} do
			signature[i] = type(arg)
		end

		signature = table.concat(signature, ",")

		return (functionSignatures[signature] or self.default)(...)
	end

	function mt:__index(key)
		local signature = {}
		local function __newindex(self, key, value)
			print(key, type(key), value, type(value))
			signature[#signature + 1] = key
			functionSignatures[table.concat(signature, ",")] = value
			print("bind", table.concat(signature, ", "))
		end
		local function __index(self, key)
			print("I", key, type(key))
			signature[#signature + 1] = key
			return setmetatable({}, { __index = __index, __newindex = __newindex })
		end
		return __index(self, key)
	end

	function mt:__newindex(key, value)
		functionSignatures[key] = value
	end

	local function oerror()
		return error("Invalid argument types to overloaded function")
	end

	return setmetatable({ default = oerror }, mt)
end

-- -- LOG
-- do
-- 	if false then
-- 		debug = function(...)
-- 			printf(...)
-- 		end
-- 	else
-- 		debug = function()
-- 		end
-- 	end
-- 	-- print("FUNCTION ENVIRONMENT: "..tostring(getfenv(1)), "DEFAULT: "..tostring(getfenv(0)))
-- end

coreUtilities.PRINT_ENV_Level = 3
function PRINT_ENV(env, verbose, restrict)
	if true then
		local restrict = restrict or defaultGlobal
		restrict["_ENV"] = env._ENV
		restrict["_ENV_LAST"] = env._ENV_LAST
		restrict["_TYPE"] = env._TYPE
		restrict["_LAYER"] = env._LAYER
		restrict["_REQUIRE_SILENT"] = true
		restrict["_NAME"] = env._NAME
		if coreUtilities.logLevel >= coreUtilities.PRINT_ENV_Level then
			printf("_ENV: %s (%s)\n", env._ENV._NAME, env._ENV)
			printf("_ENV_LAST: %s (%s)\n", env._ENV_LAST._NAME, env._ENV_LAST)
			printf("_TYPE: %s\n", env._TYPE)
			printf("_LAYER: %s\n", env._LAYER)
			printf("_REQUIRE_SILENT: %s\n", env._REQUIRE_SILENT)
			printf("_NAME: %s\n", env._NAME)
		end

		if verbose then
			local empty = true;
			for _ in pairs(env) do
				empty = false
				break
			end
			if not empty then
				printf("__ELEMENTS__\n")
				for k, v in pairs(env) do
					if not restrict or not restrict[k] then
						printf("   %s\t%s\n", k, v)
					end
				end
				printf("__ELEMENTS__\n")
			else
				printf("__EMPTY__\n")
			end
		end

		printf()
	end
end

do
	local _require = require
	function requireOld(...)
		_require(...)
	end
end

coreUtilities.requireLevel = 2
function require(directory, env, quiet)
	-- printf("%s %s %s\n", directory, env, quiet)
	local envType = type(env)
	local env = (envType == "table" and env) or ((env == true and getfenv(2)._ENV) or _G)
	-- assert(env and env._ENV, "expected environment given "..tostring(env))

	local function debug(...)
		if not (quiet or env._ENV_LAST._REQUIRE_SILENT) then
			printf(...)
		end
	end

	if coreUtilities.logLevel >= coreUtilities.requireLevel then
		if env ~= _G then
			if envType == "table" then
				debug("PROVIDED REQUIRE ")
			else
				debug("CURRENT  REQUIRE ")
			end
		else
			debug("GLOBAL   REQUIRE ")
		end

		debug("%s INTO %s\n", directory, env._NAME or "?")
	end

	local data = coreUtilities.requireEnv(env, directory)

	if coreUtilities.logLevel >= coreUtilities.requireLevel then
		debug()
	end
	-- local data = coreUtilities.requireEnv(_G, directory)

	return data
end

coreUtilities.newSourceEnvLevel = 2
function coreUtilities.newSourceEnv(name, parent, lastEnv)
	local env = {}
	env._ENV = env
	env._ENV_LAST = lastEnv
	env._TYPE = "SOURCE"
	env._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
	env._REQUIRE_SILENT = false
	env._NAME = name
	if parent then
		setmetatable(env, {
			__index = parent
		})
	end
	if coreUtilities.logLevel >= coreUtilities.newSourceEnvLevel then
		printf("CREATED NEW SOURCE ENVIRONMENT %s (%s)\n", env._NAME, env._ENV)
	end
	return env
end

-- function coreUtilities.newModuleEnv(name, parent, lastEnv)
-- 	local env = {}
-- 	env._ENV = env
-- 	env._ENV_LAST = lastEnv
-- 	env._TYPE = "MODULE"
-- 	env._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
-- 	env._REQUIRE_SILENT = false
-- 	env._NAME = name
-- 	if parent then
-- 		setmetatable(env, {
-- 			__index = parent
-- 		})
-- 	end
-- 	printf("CREATED NEW MODULE ENVIRONMENT %s (%s)\n", env._NAME, env._ENV)
-- 	return env
-- end

-- function coreUtilities.loadChunk(env, dir)
-- 	local chunk = coreUtilities.loadfile(dir)
-- 	if not chunk then chunk = coreUtilities.loadfile(dir..".lua") end
-- 	-- if not chunk then chunk = loadfile(dir) end
-- 	assert(chunk, "failed to load file "..dir)
-- 	-- local env = getfenv(2)._ENV
-- 	-- printf("require in env %s (%s) file %s\n", env._NAME, env, dir)
-- 	setfenv(chunk, env)
--
-- 	return chunk
-- end

function DEBUG_PRINT_TABLE_(env, name, format)
	printf("Printing %s\n", name)
	local t = env[name]
	for k, v in pairs(t) do
		-- tostring(k)
		-- tostring(v)
		-- printf(format or "%s,  %s\n", k or "nil", v or "nil")
	end
	printf("Printing %s\n", name)
end

coreUtilities.DEBUG_PRINT_TABLE_Level = 1
function DEBUG_PRINT_TABLE(table, format)
	if coreUtilities.logLevel >= coreUtilities.DEBUG_PRINT_TABLE_Level then
		printf("---\n")
		for k, v in pairs(table) do
			-- printf("%s ", k)
			-- printf("%s\n", v)
			printf(format or "%.10s,  %s (%s)\n", k, v, type(v))
			-- print_old(k, tostring(v))
			-- if type(v) == "table" then
			-- 	print_old(k, v.__tostring and v.__tostring())
			-- end
		end
		printf("---\n")
	end
end

coreUtilities.newSourceEnvLevel = 2
function coreUtilities.requireEnv(env, directory, ...)
	local data

	if not package.loaded[directory] then -- if not loaded yet, load the file
		local loader
		for k, v in pairs(package.loaders) do
			loader = v(directory)
			if type(loader) == "function" then break end
		end
		assert(type(loader) == "function", loader or "cannot find file")
		local status, msg = pcall(function()
			setfenv(loader, env)
		end)
		if not status then
			printf("Error requiring into %s: %s\n", _ENV._NAME, msg)
		end
		data = loader(directory, ...)
		-- data = coreUtilities.loadChunk(env, directory)()
		package.loaded[directory] = data
	else
		data = package.loaded[directory] -- if loaded, get the cached value
	end

	return data
end

return coreUtilities
