local stringUtilities = {}

function stringUtilities.firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

return stringUtilities
