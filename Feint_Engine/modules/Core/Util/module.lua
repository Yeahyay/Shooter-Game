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

	function self:getMemoryUsageBytes()
		return collectgarbage("count") * 1024
	end
	function self:getMemoryUsageKiB()
		return self:getMemoryUsageBytes() / 1024
	end
	function self:getMemoryUsageKb()
		return self:getMemoryUsageBytes() / 1000
	end
end

return coreUtil
