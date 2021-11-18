local cute = require("Cute-0_4_0.cute")
local ffi = require("ffi")

cute.notion("Component ARRAY function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_ARRAY_TEST", {
		a = 0;
		b = Feint.ECS.Component.ARRAY{1, 3, 7, 2}
	})
	cute.check(Component ~= nil).is(true)
	cute.check(Component.members.a).is(0)
	cute.check(Component.members.b.ARRAY_TYPE).is(true)
	cute.check(Component.members.b.data[1]).is(1)
	cute.check(Component.members.b.data[2]).is(3)
	cute.check(Component.members.b.data[3]).is(7)
	cute.check(Component.members.b.data[4]).is(2)
	cute.check(Component.members.b.size).is(4)
end)


cute.notion("Component LIST function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_LIST_TEST", {
		a = 0;
		b = Feint.ECS.Component.LIST{1, 3, 7, 2}
	})
	cute.check(Component ~= nil).is(true)
	cute.check(Component.members.a).is(0)
	cute.check(Component.members.b.LIST_TYPE).is(true)
	cute.check(Component.members.b.data[1]).is(1)
	cute.check(Component.members.b.data[2]).is(3)
	cute.check(Component.members.b.data[3]).is(7)
	cute.check(Component.members.b.data[4]).is(2)
	cute.check(Component.members.b.size).is(4)
end)

cute.notion("Component LIST_MIXED function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_LIST_MIXED_TEST", {
		a = 0;
		b = 1;
		c = "foo";
		d = "bar";
		e = Feint.ECS.Component.LIST{1};
		f = Feint.ECS.Component.LIST_MIXED{1, 2, 5, "what"};
	})
	cute.check(Component ~= nil).is(true)
	cute.check(Component.numMembers).is(6)

	cute.check(Component.members.a).is(0)
	cute.check(Component.members.b).is(1)
	cute.check(Component.members.c).is("foo")
	cute.check(Component.members.d).is("bar")
	cute.check(Component.members.e.data).shallowMatches({1})
	cute.check(Component.members.f.data).shallowMatches({1, 2, 5, "what"})
end)

cute.notion("Component handles number attributes", function()
	local Component = Feint.ECS.Component:new("COMPONENT_NUMBER_ATTRIBUTE_TEST", {
		a = {"int", 0};
		b = {"double", 1};
		c = {"float", 4.5};
	})
	cute.check(Component ~= nil).is(true)
	cute.check(Component.members.a).shallowMatches{"int", 0}
	cute.check(Component.members.b).shallowMatches{"double", 1}
	cute.check(Component.members.c).shallowMatches{"float", 4.5}
end)
