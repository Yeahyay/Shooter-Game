local cute = require("Cute-0_4_0.cute")

local cstring = Feint.Core.FFI.cstring

cute.notion("CString construction and destruction is working as intended", function()
	for runs = 1, 10 do
		local strings = setmetatable({}, {__mode = "kv"})
		printf("run %d\n", runs)
		printf("mem pre    : %d\n", Feint.Core.Util:getMemoryUsageBytes())
		for i = 1, 10000, 1 do
			strings[i] = cstring(string.format("string %d", i))
		end
		printf("mem post   : %d\n", Feint.Core.Util:getMemoryUsageBytes())
		collectgarbage()
		collectgarbage()
		printf("mem collect: %d\n", Feint.Core.Util:getMemoryUsageBytes())
	end
end)
