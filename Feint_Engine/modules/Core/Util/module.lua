local coreUtil = {
	-- depends = {}
}

function coreUtil:load()
	do
		local socket = require("socket")
		local startTime = love.timer.getTime() - (socket.gettime() % 1)
		function coreUtil.getTime()
			return love.timer.getTime() - startTime
		end
	end

	function self:loveType(obj)
		if type(obj) == "userdata" and obj.type then
			return obj:type()
		end
		return nil
	end

	function self:type(obj)
		local type = type(obj)
		if type == "userdata" and obj.type then
			return obj:type()
		else
			return type
		end
	end

	function self:getMemoryUsageKiB()
		return collectgarbage("count") * (1000 / 1024)
	end
	function self:getMemoryUsageKb()
		return collectgarbage("count")
	end
end

return coreUtil
