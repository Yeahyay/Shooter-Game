local core = {
	Name = "Feint API",
	-- Paths = {
	-- 	hidden = {
	-- 		size = 1
	-- 	}
	-- },
	-- ECS = {},
	-- Util = nil,
	-- Math = {},
}

local private = {
	Modules = {},
}
setmetatable(private, {
	__index = private.Modules
})
setmetatable(core, {
	__index = private,
	-- __mode = "kv"
})

local exceptions = require("Feint_Engine.modules.utilities.exceptions")

-- one of the only global variables I need
function printf(format, ...)
	if format then
		io.write(string.format(format or "", ...))
	else
		io.write("")
	end
end

local function log(...)
	printf("core_%s: ", _ENV._NAME:lower())
	printf(...)
end

function private.LoadCore(name)
	print(name)
	assert(type(name) == "string", 2, exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	local module = private.Modules[name] -- checks if module exists
	if module then
		module.setup()
		if module.init then
			module.init()
		end
	end
end

function private.LoadModule(name)
	assert(type(name) == "string", 2, exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	local module = private.Modules[name] -- checks if module exists
	if module then
		log("Loading module %s\n", name)
		module.setup()
		if module.init then
			module.init()
		end
	else
		log("Failed to load module %s\n", name)
	end
end

function private.AddModule(name, setupFunc)
	assert(type(name) == "string", 2, exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	-- log("Adding module %s\n", name)
	local newModule = {
		Name = name,
	}

	local newPrivate = {} -- closure to a module's private state
	newPrivate.require = function(name, ...)
		if getmetatable(newPrivate) then
			error(string.format("Module '%s' is already loaded with data", name))
		else
			assert(type(name) == "string", 2, exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
			newPrivate.private = require(name, ...)
			setmetatable(newPrivate, {
				__index = newPrivate.private,
				__newindex = newPrivate.private
			})
		end
	end

	newPrivate.Finalize = function()
		local mt = getmetatable(newModule)
		mt.__newindex = function(t, k, v)
			if rawget(t, k) then -- does the index exist within the table itself, ignoring all metamethods
				rawset(t, k, v)
			elseif newPrivate[k] then -- if not, access its private table
				-- the private table will access its own __index and _newindex, which are the private table's "private" index
				newPrivate[k] = v
			elseif newPrivate[k] == nil then
				-- if the index is not in the table, its private table, or that private table's private section, then it's an error
				error(exceptions.READ_ONLY_MODIFICATION_ERROR(t, k), 2)
			end
		end
	end

	function newPrivate.setup(...)
		if setupFunc then
			setupFunc(newModule, ...)
		end
	end

	setmetatable(newModule, {
		__index = newPrivate,
		__tostring = function() return string.format("Feint \"%s\" Module", name) end,
	})

	private.Modules[name] = newModule
	return newModule
end

return core
