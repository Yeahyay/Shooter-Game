local debug = {
	logLevel = 0
}

function debug:load()
	debug.PRINT_ENV_Level = 3
	function debug.PRINT_ENV(env, verbose, restrict)
		if true then
			local restrict = restrict or defaultAll -- defaultGlobals
			restrict["_ENV"] = env._ENV
			restrict["_ENV_LAST"] = env._ENV_LAST
			restrict["_TYPE"] = env._TYPE
			restrict["_LAYER"] = env._LAYER
			restrict["_REQUIRE_SILENT"] = true
			restrict["_NAME"] = env._NAME
			if debug.logLevel >= debug.PRINT_ENV_Level then
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
						if (not restrict or not restrict[k]) and not k:match("default") then
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

	debug.DEBUG_PRINT_TABLE_Level = 1
	function debug.DEBUG_PRINT_TABLE(table, format)
		if debug.logLevel >= debug.DEBUG_PRINT_TABLE_Level then
			printf("---\n")
			for k, v in pairs(table) do
				-- printf("%s ", k)
				-- printf("%s\n", v)
				printf(format or "%s,  %s (%s)\n", k, v, type(v))
				-- print_old(k, tostring(v))
				-- if type(v) == "table" then
				-- 	print_old(k, v.__tostring and v.__tostring())
				-- end
			end
			printf("---\n")
		end
	end
end

return debug
