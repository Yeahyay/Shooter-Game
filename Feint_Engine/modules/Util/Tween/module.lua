local tween = {
	depends = {"Core.Paths"}
}

function tween:load()
	-- PARSING
	Feint.Core.Paths:Add("Tween", Feint.Core.Paths.Modules .. "tween")

	self.Flux = require(Feint.Core.Paths.Lib .. "flux-master.flux")
end

return tween
