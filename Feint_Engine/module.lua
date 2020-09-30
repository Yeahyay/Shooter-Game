local module = {}

local exceptions = Feint.Util.Exceptions

function module:new(name, private, setupFunc)
	assert(type(name) == "string", exceptions.BAD_ARG_ERROR(1, "name", "string", type(name)))
	local newModule = {}
	newModule.Name = name

	local privateData = private or {}
	privateData.private = privateData
	function privateData.setup(...)
		print("dsfojbnljdsjokn")
		if setupFunc then
			setupFunc(newModule, ...)
		end
	end

	setmetatable(privateData, {
		__index = module
	})

	setmetatable(newModule, {
		__index = newPrivate,
		__tostring = function() return string.format("Feint \"%s\" Module", name) end,
	})

	return newModule
end

function module:Add(name, private)
	self[name] = self:new(name, private)
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
	Feint[name] = newModule
	return newModule
end

setmetatable(module, {
	__index = module,
	__newindex = function(t, k, v)
		if t[k] then
			t[k] = v
		else
			-- newPrivate[k] = v
			error(exceptions.READ_ONLY_MODIFICATION_ERROR(t, k))
		end

	end,
	__tostring = function() return "Feint \"Module Base\" Module" end,
})
return module
