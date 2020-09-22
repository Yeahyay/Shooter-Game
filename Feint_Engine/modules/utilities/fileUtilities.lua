local fileUtilities = {}

function fileUtilities.save(level)
	printf("SAVING LEVEL %s\n", level)
	levelParser:save(level)
end
function fileUtilities.load(level)
	printf("LOADING LEVEL %s\n", level)
	GameInstance:clear()
	levelParser:load(level)
end
function fileUtilities.getCurrentFolder(path)
	return path:match("(.-)[^%.]+$")
end

return fileUtilities
