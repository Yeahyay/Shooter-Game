local core = {
	depends = {"Core.Paths"}
}

local printPrefixStack = {"PRINT: "}
local printPrefixStackPointer = 1
function core:load()
	self.Name = "Core"

	require("love.event")

	Feint.Core.Paths:Add("Core", Feint.Core.Paths.Modules .. "Core")

	do
		local printOld = print
		function print(...) -- luacheck: ignore
			if select("#", ...) > 0 then
				printOld(printPrefixStack[printPrefixStackPointer], ...)
			else
				printOld()
			end
		end
	end
	function printf(format, ...)
		if format then
			io.write(string.format(format or "", ...))
		else
			io.write("")
		end
	end
	function pushPrintPrefix(string, noLocation)
		printPrefixStackPointer = printPrefixStackPointer + 1

		local funcInfo = debug.getinfo(2)
		-- for k, v in pairs(funcInfo) do print(k, v) end

		printPrefixStack[printPrefixStackPointer] = noLocation and funcInfo.short_src .. " " .. string or string
	end
	function popPrintPrefix()
		assert(printPrefixStackPointer > 1)
		local item = printPrefixStack[printPrefixStackPointer]
		printPrefixStack[printPrefixStackPointer] = nil
		printPrefixStackPointer = printPrefixStackPointer - 1
		return item
	end


	-- luacheck: push ignore
	do
		local _assert = assert
		function assert(condition, message, level)
			if level ~= nil and type(level) ~= "number" then
				error(Feint.Util.Exceptions.BAD_ARG_ERROR(1, "level", "number", type(level)), 2)
			end
			if not condition then
				error(message, (level or 1) + 1)
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
			assert(type(loader) == "function", loader or "cannot find file", 4)
			local status, msg = pcall(function()
				setfenv(loader, env)
			end)
			if not status then
				printf("Error in requireEnv: %s. It's probably a thread or socket library.\n", msg)
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
