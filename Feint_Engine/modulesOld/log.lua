local log = {}

local util = Feint.Util.Core

local date = function()
	return os.date(string.format("%%y-%%m-%%d", (util.getTime() % 1) * 1000))
end

local time = function()
	return os.date(string.format("%%I:%%M:%%S:%06d", (util.getTime() % 1) * 1000000))
end

local fullTime = function()
	return os.date(string.format("%%y-%%m-%%d_%%I:%%M:%%S:%03d", (util.getTime() % 1) * 1000))
end

local dir = string.format("%s/logs/%s", love.filesystem.getWorkingDirectory(), string.format("log_%s", time()))

local logFile = nil

function log.log(fmt, ...)
	local output = string.format("%s [%s] %s", _ENV._NAME, time(), fmt or "")
	printf(output, ...)
end
function log.logln(fmt, ...)
	local output = string.format("%s [%s] %s\n", _ENV._NAME, time(), fmt or "\n")
	printf(output, ...)
end
function log.file(fmt, ...)
	local output = string.format("%s [%s] %s\n", _ENV._NAME, fullTime(), fmt and string.format(fmt, ...) or "Empty log")
	print(output)
	if not logFile then
		logFile = io.open(dir, "w")
	end
	logFile:write(output)
	printf(output)
end

return log
