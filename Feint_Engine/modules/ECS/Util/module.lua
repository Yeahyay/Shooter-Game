local ECSUtil = {}

function ECSUtil:load()

	function ECSUtil.methodExpects(objectName, value, arg, _type)
		return string.format("method %s%s argument %d expected a %s, got a %s (%s) instead\n", objectName and objectName .. ":" or objectName, debug.getinfo(2).name, arg, _type, type(value), value)
	end

	function ECSUtil.functionExpects(value, _type)
		return string.format("function %s expected a %s, got a %s (%s) instead\n", debug.getinfo(2).name, _type, type(value), value)
	end

end

return ECSUtil
