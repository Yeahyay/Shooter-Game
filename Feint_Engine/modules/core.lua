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
setmetatable(core, {
	__index = private,
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

function log(...)
	printf("%s: ", _ENV._NAME)
	printf(...)
end

function private.LoadModule(name)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	local module = private.Modules[name]
	if module then
		log("Loading module %s\n", name)
		module.setup()
		Feint[name] = private.Modules[name]
	else
		log("Failed to load module %s\n", name)
	end
end
function private.AddModule(name, privateData, setupFunc)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	-- log("Adding module %s\n", name)
	local newModule = {
		Name = name,
	}
	local newPrivate = privateData or {} -- closure to a module's private state
	newPrivate.private = newPrivate

	function newPrivate.Finalize()
		-- getmetatable(newModule).__newindex = function(t, k, v)
		-- 	if t[k] then
		-- 		t[k] = v
		-- 	else
		-- 		-- newPrivate[k] = v
		-- 		error(exceptions.READ_ONLY_MODIFICATION_ERROR(t, k))
		-- 	end
		-- end
	end
	-- newPrivate.AddModule = self.AddModule

	function newPrivate.setup(...)
		if setupFunc then
			setupFunc(newModule, ...)
		end
	end

	setmetatable(newModule, {
		__index = newPrivate,
		__tostring = function() return string.format("Feint \"%s\" Module", name) end,
	})

	-- if setupFunc then
	-- 	setupFunc(newModule)
	-- end

	private.Modules[name] = newModule
	Feint[name] = {}
	return newModule
end

return core
