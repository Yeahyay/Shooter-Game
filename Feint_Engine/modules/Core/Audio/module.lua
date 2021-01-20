local audio = {
	depends = {"Core.Paths"}
}

function audio:load()
	-- PARSING
	require("love.audio")
	Feint.Core.Paths:Add("Audio", Feint.Core.Paths.Modules .. "audio")

	self.Slam = require(Feint.Core.Paths.Lib .. "slam-master.slam")
end

return audio
