local coreUtilities = {logLevel = 0}
-- do
-- 	local lastEnv = getfenv(1)
-- 	-- 	coreUtilities._ENV = coreUtilities
-- 	-- 	coreUtilities._ENV_LAST = lastEnv
-- 	-- 	coreUtilities._TYPE = "MODULE"
-- 	-- 	coreUtilities._LAYER = lastEnv._LAYER and lastEnv._LAYER + 1 or 0
-- 	-- 	coreUtilities._NAME = "CORE UTILITIES"
-- 	-- 	-- set the table coreUtilities to refer to the main program's _G
-- 	setmetatable(coreUtilities, {__index = lastEnv})
-- end

-- love.timer = require("love.timer")

do
	local socket = require("socket")
	local startTime = love.timer.getTime() - (socket.gettime() % 1)
	function coreUtilities.getTime()
		return love.timer.getTime() - startTime
	end
end

function coreUtilities.loveType(obj)
	if type(obj) == "userdata" and obj.type then
		return obj:type()
	end
	return nil
end

function coreUtilities.type(obj)
	local type = type(obj)
	if type == "userdata" and obj.type then
		return obj:type()
	else
		return type
	end
end

-- make this better lmao
-- luacheck: push ignore
function coreUtilities.overloaded()
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
		local signatureSize = 0
		local function __newindex(self, key, value)
			printf("%s, %s, %s\n", key, type(key), value, type(value))
			signatureSize = signatureSize + 1
			signature[signatureSize] = key
			functionSignatures[table.concat(signature, ",")] = value
			printf("bind %s\n", table.concat(signature, ", "))
		end
		local function __index(self, key)
			printf("I %s, %s\n", key, type(key))
			signatureSize = signatureSize + 1
			signature[signatureSize] = key
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
-- luacheck: pop ignore

do
	local _require = require
	function requireOld(...)
		_require(...)
	end
	function require(path, ...)
		-- printf("Entering %s.lua\n", path)
		-- local m = path:match("%/")
		-- if m then
		-- 	error("use a period")
		-- end
		-- local ret = {_require(path, ...)}
		local data = coreUtilities.requireEnv(_G, path, ...)

		return data--unpack(ret)
	end
end

do
	local _assert = assert
	function assert(condition, message, level)
		if level ~= nil and type(level) ~= "number" then
			error(Feint.Util.Exceptions.BAD_ARG_ERROR(1, "level", "number", type(level)), 2)
		end
		if not condition then
			error(message, level or 1)
		end
	end
end
--[[

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
--]]

--[[
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
--]]

coreUtilities.newSourceEnvLevel = 2
function coreUtilities.requireEnv(env, directory, ...)
	local data = nil
	if not package.loaded[directory] then -- if not loaded yet, load the file
		local loader = nil
		for _, loaderFunction in pairs(package.loaders) do
			loader = loaderFunction(directory)
			if type(loader) == "function" then break end
		end
		assert(type(loader) == "function", loader or "cannot find file", 1)
		local status, msg = pcall(function()
			setfenv(loader, env)
		end)
		if not status then
			log("Error in requireEnv: %s. It's probably a thread.\n", msg)
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
