local ECS = {
	depends = {"Core.Paths"}
}

local paths
function ECS:load()
	paths = Feint.Core.Paths
end

return ECS
