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

local private = {}
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

function private.AddModule(name, privateData)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	printf("Adding module %s\n", name)
	local newModule = {}
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

	setmetatable(newModule, {
		__index = newPrivate,
		__tostring = function() return string.format("Feint %s", name) end,
	})

	Feint[name] = newModule
end

return core
