local exceptions = {}

function exceptions.INSTANCE_OF_INFO(class, name, string)
	return string.format("instance of %s \"%s\" (%s)", class.Name, name, string)
end

function exceptions.BAD_ARG_ERROR(argNum, funcParameter, expectedType, recievedType)
	return string.format("bad argument #%d to '%s' (%s expected, got %s)'", argNum, funcParameter, expectedType, recievedType)
end
function exceptions.READ_ONLY_MODIFICATION_ERROR(table, key)
	return string.format("attempt to modify %s by accessing key %s", table, key)
end

return exceptions
