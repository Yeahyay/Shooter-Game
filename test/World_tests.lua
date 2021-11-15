local cute = require("Cute-0_4_0.cute")

cute.notion("World creation is correct", function()
	for i = 1, 10000, 1 do
		local world = Feint.ECS.World:new("World " .. i)
		cute.check(world.Name).is("World " .. i)
		cute.check(world.systems).shallowMatches({})
		cute.check(world.updateOrder).shallowMatches({})
		cute.check(world.components).shallowMatches({})
	end
	print(Feint.Core.Util:getMemoryUsageKiB())
end)

-- cute.notion("World component adding is correct", function()
-- 	local World = Feint.ECS.World:new("World 1")
--
-- 	cute.minion("addComponent", World, "addComponent")
--
-- 	for i = 1, 1000, 1 do
-- 		World:addComponent(Feint.ECS.Component:new("Test" .. i, {
-- 			a = 0;
-- 			b = 1;
-- 		}))
-- 	end
--
-- 	local report = cute.report("addComponent")
-- 	cute.check(report.calls).is(1000)
-- 	for k, callArgs in pairs(report.args) do
-- 		local class = callArgs[1]
-- 		local component = callArgs[2]
--
-- 		cute.check(class.componentData).is(nil)
-- 		cute.check(component.Name).is("Test" .. k)
-- 		cute.check(component.componentData).is(true)
-- 	end
-- 	cute.check(report.args[1])
-- end)
