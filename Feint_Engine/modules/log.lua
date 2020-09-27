local log = {}

local util = Feint.Util.Core

local time = function()
	return os.date(string.format("[%%y.%%m.%%d-%%I.%%M.%%S.%03d]", (util.getTime() % 1) * 1000))
end

local dir = string.format("%s/logs/%s", love.filesystem.getWorkingDirectory(), string.format("log_%s", time()))

local logFile = io.open(dir, "w")
function log.log(message, write)
	local output = string.format("%s %s\n", time(), message or "Empty log")
	if write then
		if not logFile then
			logFile = io.open(dir, "w")
		end
		logFile:write(output)
	end
	printf(output)
end

return log
