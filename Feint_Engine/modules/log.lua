local log = {}

local util = Feint.Util.Core

local time = function()
	return os.date(string.format("[%%y.%%m.%%d-%%I.%%M.%%S.%03d]", (util.getTime() % 1) * 1000))
end

local dir = string.format("%s/logs/%s", love.filesystem.getWorkingDirectory(), string.format("log_%s", time()))

local logFile = nil

function log.log(fmt, ...)
	local output = string.format("%s %s", time(), fmt or "Empty log")
	printf(output, ...)
end
function log.file(fmt, ...)
	local output = string.format("%s %s\n", time(), fmt and string.format(fmt, ...) or "Empty log")
	print(output)
	if not logFile then
		logFile = io.open(dir, "w")
	end
	logFile:write(output)
	printf(output)
end

return log
