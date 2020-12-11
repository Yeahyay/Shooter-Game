local core = {}

function core:load()
	self.Name = "Core"
	self.Modules = {}

	do
		local printOld = print
		function print(...) -- luacheck: ignore
			printOld("OLD PRINT", ...)
		end
	end
	function printf(format, ...)
		if format then
			io.write(string.format(format or "", ...))
		else
			io.write("")
		end
	end

	-- luacheck: push ignore
	do
		local _assert = assert
		function assert(condition, message, level)
			if level ~= nil and type(level) ~= "number" then
				error(Feint.Util.Exceptions.BAD_ARG_ERROR(1, "level", "number", type(level)), 2)
			end
			if not condition then
				error(message, level or 2)
			end
		end

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
			local data = core.requireEnv(_G, path, ...)

			return data--unpack(ret)
		end
	end
	-- luacheck: pop ignore
	function core.requireEnv(env, directory, ...)
		local data
		if not package.loaded[directory] then -- if not loaded yet, load the file
			local loader = nil
			for _, loaderFunction in pairs(package.loaders) do
				loader = loaderFunction(directory)
				if type(loader) == "function" then break end
			end
			assert(type(loader) == "function", loader or "cannot find file", 3)
			local status, msg = pcall(function()
				setfenv(loader, env)
			end)
			if not status then
				printf("Error in requireEnv: %s. It's probably a thread.\n", msg)
			end
			data = loader(directory, ...)
			-- data = coreUtilities.loadChunk(env, directory)()
			package.loaded[directory] = data
		else
			data = package.loaded[directory] -- if loaded, get the cached value
		end

		return data
	end

	-- require("Feint_Engine.modules.core.globals", core)
end

return core
