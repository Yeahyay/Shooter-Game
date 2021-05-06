local Component = Feint.ECS.Component
local EntityRelation = Component:new("EntityRelation", {
	child = Component.NIL;
	parent = Component.NIL;
})

return EntityRelation
