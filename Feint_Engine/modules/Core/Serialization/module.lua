local serialization = {
	depends = {"Core.Paths"}
}

function serialization:load()
	-- PARSING
	Feint.Core.Paths:Add("Serialize", Feint.Core.Paths.Modules .. "serialize")

	self.Bitser = require(Feint.Core.Paths.Lib .. "bitser.bitser")
end

return serialization
