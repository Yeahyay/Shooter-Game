local ResourceManager = {
	depends = {}
}

local Resource = {}

function Resource:loadScript(name)
end
function Resource:reloadScript(name)
end

function ResourceManager:load(isThread)
	self.Resources = {}

end

return ResourceManager
