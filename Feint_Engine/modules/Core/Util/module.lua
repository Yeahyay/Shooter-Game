local coreUtil = {
	-- depends = {"Core.Run"}
}

function coreUtil:load()

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

	local div1024 = 1 / 1024
	local div1000 = 1 / 1000
	function self:getMemoryUsageBytes()
		return collectgarbage("count") * 1024
	end
	function self:getMemoryUsageKiB()
		return self:getMemoryUsageBytes() * div1024
	end
	function self:getMemoryUsageKb()
		return self:getMemoryUsageBytes() * div1000
	end
end

return coreUtil
