local cute = require("Cute-0_4_0.cute")

local TestComponent1 = Feint.ECS.Component:new("ARCHETYPE_TEST_COMPONENT_1", {
	a = {"int", 0};
	b = {"double", 1};
	c = {"float", 4.5};
})
local TestComponent2 = Feint.ECS.Component:new("ARCHETYPE_TEST_COMPONENT_2", {
	a = {"int", 0};
	b = {"double", 1};
	c = {"float", 4.5};
})
local TestComponent3 = Feint.ECS.Component:new("ARCHETYPE_TEST_COMPONENT_3", {
	a = {"int", 0};
	b = {"double", 1};
	c = {"float", 4.5};
})

cute.notion("Archetype creation with no archetypes fails", function()
	cute.check(pcall(Feint.ECS.Archetype.new, Feint.ECS.Archetype)).is(false)
end)

cute.notion("Archetype creation with one component works", function()
	local TestArchetype1 = Feint.ECS.Archetype:new{TestComponent1}
	cute.check(TestArchetype1.components[1].members).shallowMatches(TestComponent1.members)
	cute.check(TestArchetype1.signature).is("ARCHETYPE_TEST_COMPONENT_1|_signature")
	cute.check(TestArchetype1.signatureStripped).is("ARCHETYPE_TEST_COMPONENT_1")
	cute.check(TestArchetype1.totalSize).is(TestComponent1.numMembers)
	-- print(TestArchetype1.initValues, next(TestArchetype1.initValues))
	-- for k, v in pairs(TestArchetype1.initValues) do
	-- 	print("oimfiml", k, v)
	-- end
end)

cute.notion("Archetype creation with two components works", function()
	local TestArchetype2 = Feint.ECS.Archetype:new{TestComponent1, TestComponent2}
	cute.check(TestArchetype2.components[1].members).shallowMatches(TestComponent1.members)
	cute.check(TestArchetype2.components[2].members).shallowMatches(TestComponent2.members)
	cute.check(TestArchetype2.signature).is("ARCHETYPE_TEST_COMPONENT_1|ARCHETYPE_TEST_COMPONENT_2|_signature")
	cute.check(TestArchetype2.signatureStripped).is("ARCHETYPE_TEST_COMPONENT_1ARCHETYPE_TEST_COMPONENT_2")
	cute.check(TestArchetype2.totalSize).isNot(TestComponent1.numMembers)
	cute.check(TestArchetype2.totalSize).is(TestComponent1.numMembers + TestComponent2.numMembers)
end)

cute.notion("Archetype creation with three components works", function()
	local TestArchetype3 = Feint.ECS.Archetype:new{TestComponent1, TestComponent2, TestComponent3}
	cute.check(TestArchetype3.components[1].members).shallowMatches(TestComponent1.members)
	cute.check(TestArchetype3.components[2].members).shallowMatches(TestComponent2.members)
	cute.check(TestArchetype3.components[3].members).shallowMatches(TestComponent3.members)
	cute.check(TestArchetype3.signature).is("ARCHETYPE_TEST_COMPONENT_1|ARCHETYPE_TEST_COMPONENT_2|ARCHETYPE_TEST_COMPONENT_3|_signature")
	cute.check(TestArchetype3.signatureStripped).is("ARCHETYPE_TEST_COMPONENT_1ARCHETYPE_TEST_COMPONENT_2ARCHETYPE_TEST_COMPONENT_3")
	cute.check(TestArchetype3.totalSize).isNot(TestComponent1.numMembers + TestComponent2.numMembers)
	cute.check(TestArchetype3.totalSize).is(TestComponent1.numMembers + TestComponent2.numMembers + TestComponent3.numMembers)
end)
