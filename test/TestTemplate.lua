local cute = require("Cute-0_4_0.cute")

cute.notion("Test", function()
	cute.check("a").is("a")
	cute.check({}).shallowMatches({})
end)
