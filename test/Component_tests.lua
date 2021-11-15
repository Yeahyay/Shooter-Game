local cute = require("Cute-0_4_0.cute")

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
end)

cute.notion("Component creation is correct", function()
	local Component = Feint.ECS.Component:new("Test1", {
		a = 0;
		b = 1;
		c = "foo";
		d = "bar";
		e = {};
		f = {1, 2, 5, "what"};
	})
	cute.check(Component ~= nil).is(true)
	cute.check(Component.numMembers).is(6)

	cute.check(Component.members.a).is(0)
	cute.check(Component.members.b).is(1)
	cute.check(Component.members.c).is("foo")
	cute.check(Component.members.d).is("bar")
	cute.check(Component.members.e).shallowMatches({})
	cute.check(Component.members.f).shallowMatches({1, 2, 5, "what"})
end)
