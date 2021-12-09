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
local TestArchetype1 = Feint.ECS.Archetype:new{TestComponent1, TestComponent2, TestComponent3}

cute.notion("ArchetypeChunk creation with no archetype fails", function()
	cute.check(pcall(Feint.ECS.ArchetypeChunk.new)).is(false)
end)

cute.notion("ArchetypeChunk creation works", function()
	Feint.ECS.ArchetypeChunk:new(TestArchetype1)
end)
