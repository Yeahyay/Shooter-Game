local ECSUtils = {}

function ECSUtils:load()
-- print("jiom;knljo")

-- print()
-- print(Feint.Core)
-- for k, v in pairs(Feint.Core) do
-- 	print(k, v)
-- end
-- print(Feint.Core.Paths)
-- for k, v in pairs(Feint.Core.Paths) do
-- 	print(k, v)
-- end
-- print()

function ECSUtils.newClass(name)
	local Class = {}
	Class.Name = name or "?"
	Class.Super = ECSUtils
	Class.Type = "BASE_CLASS"
	Class.string = tostring(Class)
	Class.new = function(BaseClass, name, ...)
		return ECSUtils.new(BaseClass, "class", name, ...)
	end
	local mt = {
		-- when the Class gets called, it creates an Instance of Class
		-- that new Instance is used to make an immutable and runnable instance
		__call = Class.new,--[[function(BaseClass, name, ...)
			return ECSUtils.new(BaseClass, "class", name, ...)
		end,]]
		-- __index = Class,
		__tostring = function()
			return string.format("class %s (%s)", Class.Name, Class.string)
		end
	}
	setmetatable(Class, mt)

	return Class
end

function ECSUtils.instantiateComponent(component)

end

function ECSUtils.new(super, objType, --[[name,]] ...)
	-- constructor for the instance

	local newInstance = {}
	-- assert(name, 2, "no name given")
	-- newInstance.Name = name or "?"
	newInstance.Super = super
	newInstance.string = tostring(newInstance)
	newInstance.Type = objType
	-- assert(
	-- 	type(newInstance.Name) == "string", 2,
	-- 	Feint.Util.Exceptions.BAD_ARG_ERROR(1, "new instance name", "string", type(newInstance.Name))
	-- )

	setmetatable(newInstance, {
		__index = super,
		__call = function(newInstance, --[[name,]] ...)
			return newInstance:new(--[[name,]] ...)
		end,
		__tostring = function()
			return string.format("%s %s (%s)", objType, --[[newInstance.Name]] "nil", newInstance.string)
		end
	})

	newInstance:init(...)
	return newInstance
	-- end

end

-- setmetatable(ECSUtils, {})
-- util.makeTableReadOnly(ECSUtils, function(self, k)
-- 	return util.READ_ONLY_MODIFICATION_ERROR(self, k)
-- end)

end

return ECSUtils
