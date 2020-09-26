local log = {}

local time = function()
	return os.date(string.format("[%%y-%%m-%%d;%X]"))
end


function log:log(message)
	printf("%s %s", time(), message or "Empty log")
end

return log
