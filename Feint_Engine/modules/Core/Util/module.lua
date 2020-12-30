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

	function self:getMemoryUsageKiB()
		return collectgarbage("count") * (1000 / 1024)
	end
	function self:getMemoryUsageKb()
		return collectgarbage("count")
	end
end

return coreUtil
