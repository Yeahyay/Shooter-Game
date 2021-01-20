local parsing = {
	depends = {"Core.Paths"}
}

function parsing:load()
	-- PARSING
	Feint.Core.Paths:Add("Parsing", Feint.Core.Paths.Modules .. "parsing")
end

return parsing
