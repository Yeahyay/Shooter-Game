local AssetManager = {
	depends = {}
}

function AssetManager:load(isThread)
	self.assets = {}
	local types = {
		image = true;
		batchSet = true;
		FONT = true;
	}
	setmetatable(self, {
		__index = function(t, k)
			if types[k] then
				return k
			else
				return rawget(t, k)
			end
		end;
	})
	function self:registerAsset(asset, name, type)
		assert(types[type], "type \"" .. type .. "\" is not supported")
		local key = self:getKey(name, type)
		assert(not self.assets[key], "name \"" .. name .. "\" is already in use")
		self.assets[key] = asset
	end
	function self:requestAsset(name, type)
		assert(types[type], "type \"" .. type .. "\" is not supported")
		local key = self:getKey(name, type)
		assert(self.assets[key], "asset \"" .. name .. "\" is not found")
		return self.assets[key]
	end
	function self:getKey(name, type)
		return name .. type
	end
end

return AssetManager
