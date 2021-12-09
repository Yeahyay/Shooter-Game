local cute = require("Cute-0_4_0.cute")

cute.notion("Component creation with no members fails", function()
	cute.check(pcall(Feint.ECS.Component.new, Feint.ECS.Component, "COMPONENT_EMPTY_TEST", {})).is(false)
end)

cute.notion("Component creation with basic types works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_BASIC_TYPE_TEST", {
		a = 0;
		b = false;
		c = "Hello";
		d = -0.5;
	})
	cute.check(Component).isNot(nil)
	cute.check(Component.numMembers).is(4)

	cute.check(Component.members.a).is(0)
	cute.check(Component.members.b).is(false)
	cute.check(Component.members.c).is("Hello")
	cute.check(Component.members.d).is(-0.5)
	cute.check(Component.numMembers).is(4)
end)

cute.notion("Component handles number attributes", function()
	local Component = Feint.ECS.Component:new("COMPONENT_NUMBER_ATTRIBUTE_TEST", {
		a = {"int", 0};
		b = {"double", 1};
		c = {"float", 4.5};
	})
	cute.check(Component).isNot(nil)
	cute.check(Component.numMembers).is(3)

	cute.check(Component.members.a).shallowMatches{"int", 0}
	cute.check(Component.members.b).shallowMatches{"double", 1}
	cute.check(Component.members.c).shallowMatches{"float", 4.5}

	cute.check(Component.initValues.a).is(0)
	cute.check(Component.initValues.b).is(1)
	cute.check(Component.initValues.c).is(4.5)
end)

cute.notion("Component ARRAY function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_ARRAY_TEST", {
		a = Feint.ECS.Component.ARRAY{1, 3, 7, 2};
		b = Feint.ECS.Component.ARRAY("double", {5, 9});
	})
	cute.check(Component).isNot(nil)
	cute.check(Component.numMembers).is(2)

	cute.check(Component.members.a.ARRAY_TYPE).is(true)
	cute.check(Component.members.a.data).shallowMatches{1, 3, 7, 2}
	cute.check(Component.initValues.a).shallowMatches{1, 3, 7, 2}
	cute.check(Component.members.a.size).is(4)
	cute.check(Component.members.a.type).is("float")

	cute.check(Component.members.b.ARRAY_TYPE).is(true)
	cute.check(Component.members.b.data).shallowMatches{5, 9}
	cute.check(Component.initValues.b).shallowMatches{5, 9}
	cute.check(Component.members.b.size).is(2)
	cute.check(Component.members.b.type).is("double")
end)

cute.notion("Component LIST function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_LIST_TEST", {
		a = Feint.ECS.Component.LIST{1, 3, 7, 2};
		b = Feint.ECS.Component.LIST("int", {5, 9});
	})
	cute.check(Component).isNot(nil)
	cute.check(Component.numMembers).is(2)

	cute.check(Component.members.a.LIST_TYPE).is(true)
	cute.check(Component.members.a.data).shallowMatches{1, 3, 7, 2}
	cute.check(Component.initValues.a).shallowMatches{1, 3, 7, 2}
	cute.check(Component.members.a.size).is(4)
	cute.check(Component.members.a.type).is("float")

	cute.check(Component.members.b.LIST_TYPE).is(true)
	cute.check(Component.members.b.data).shallowMatches{5, 9}
	cute.check(Component.initValues.b).shallowMatches{5, 9}
	cute.check(Component.members.b.size).is(2)
	cute.check(Component.members.b.type).is("int")
end)

cute.notion("Component LIST_MIXED function works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_LIST_MIXED_TEST", {
		a = Feint.ECS.Component.LIST_MIXED{1};
		b = Feint.ECS.Component.LIST_MIXED{1, 2, 5, "what"};
	})
	cute.check(Component).isNot(nil)
	cute.check(Component.numMembers).is(2)

	cute.check(Component.members.a.LIST_MIXED_TYPE).is(true)
	cute.check(Component.members.a.data).shallowMatches{1}
	cute.check(Component.initValues.a).shallowMatches{1}
	cute.check(Component.members.a.size).is(1)

	cute.check(Component.members.b.LIST_MIXED_TYPE).is(true)
	cute.check(Component.members.b.data).shallowMatches{1, 2, 5, "what"}
	cute.check(Component.initValues.b).shallowMatches{1, 2, 5, "what"}
	cute.check(Component.members.b.size).is(4)
end)

cute.notion("Component mixed array types works", function()
	local Component = Feint.ECS.Component:new("COMPONENT_MIXED_ARRAY_TYPES_TEST", {
		a = Feint.ECS.Component.ARRAY{1, 3, 7, 2};
		b = Feint.ECS.Component.ARRAY("double", {5, 9});
		c = Feint.ECS.Component.LIST{1, 3, 7, 2};
		d = Feint.ECS.Component.LIST("int", {5, 9});
		e = Feint.ECS.Component.LIST_MIXED{1};
		f = Feint.ECS.Component.LIST_MIXED{1, 2, 5, "what"};
	})

	cute.check(Component.members.a.ARRAY_TYPE).is(true)
	cute.check(Component.members.a.data).shallowMatches{1, 3, 7, 2}
	cute.check(Component.initValues.a).shallowMatches{1, 3, 7, 2}
	cute.check(Component.members.a.size).is(4)
	cute.check(Component.members.a.type).is("float")

	cute.check(Component.members.b.ARRAY_TYPE).is(true)
	cute.check(Component.members.b.data).shallowMatches{5, 9}
	cute.check(Component.initValues.b).shallowMatches{5, 9}
	cute.check(Component.members.b.size).is(2)
	cute.check(Component.members.b.type).is("double")


	cute.check(Component.members.c.LIST_TYPE).is(true)
	cute.check(Component.members.c.data).shallowMatches{1, 3, 7, 2}
	cute.check(Component.initValues.c).shallowMatches{1, 3, 7, 2}
	cute.check(Component.members.c.size).is(4)
	cute.check(Component.members.c.type).is("float")

	cute.check(Component.members.d.LIST_TYPE).is(true)
	cute.check(Component.members.d.data).shallowMatches{5, 9}
	cute.check(Component.initValues.d).shallowMatches{5, 9}
	cute.check(Component.members.d.size).is(2)
	cute.check(Component.members.d.type).is("int")


	cute.check(Component.members.e.LIST_MIXED_TYPE).is(true)
	cute.check(Component.members.e.data).shallowMatches{1}
	cute.check(Component.initValues.e).shallowMatches{1}
	cute.check(Component.members.e.size).is(1)

	cute.check(Component.members.f.LIST_MIXED_TYPE).is(true)
	cute.check(Component.members.f.data).shallowMatches{1, 2, 5, "what"}
	cute.check(Component.initValues.f).shallowMatches{1, 2, 5, "what"}
	cute.check(Component.members.f.size).is(4)
end)

cute.notion("Component initialization with a non-table fails", function()
	local status, message -- luacheck: ignore
	status, message = pcall(Feint.ECS.Component.new, Feint.ECS.Component, "COMPONENT_NUMBER_FAIL", 0)
	print(message)
	cute.check(status).is(false)

	status, message = pcall(Feint.ECS.Component.new, Feint.ECS.Component, "COMPONENT_BOOLEAN_FAIL", true)
	print(message)
	cute.check(status).is(false)

	status, message = pcall(Feint.ECS.Component.new, Feint.ECS.Component, "COMPONENT_FUNCTION_FAIL", function() end)
	print(message)
	cute.check(status).is(false)
end)
