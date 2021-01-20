local util = {
	depends = {"Core.Paths"}
}

function util:load()
	require("love.timer")

	Feint.Core.Paths:Add("Util", Feint.Core.Paths.Modules .. "utilities")

	self.Class = require(Feint.Core.Paths.Lib .. "30log-master.30log-clean")
	self.Memoize = require(Feint.Core.Paths.Lib .. "memoize-master.memoize")
	self.UUID = require(Feint.Core.Paths.Lib .. "uuid-master.src.uuid")

	-- self.Exceptions = require(Feint.Paths.Util .. "exceptions")

	-- self.Core = require(Feint.Paths.Util .. "coreUtilities")
	-- self.Debug = require(Feint.Paths.Util .. "debugUtilities")
	-- self.File = require(Feint.Paths.Util .. "fileUtilities")
	-- self.String = require(Feint.Paths.Util .. "stringUtilities")
	-- self.Table = require(Feint.Paths.Util .. "tableUtilities")
end

return util
