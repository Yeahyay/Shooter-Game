local audio = {}

function audio:load()
	-- PARSING
	Feint.Core.Paths.Add("Audio", Feint.Core.Paths.Modules .. "audio")

	self.Slam = require(Feint.Core.Paths.Lib .. "slam-master.slam")
end

return audio
