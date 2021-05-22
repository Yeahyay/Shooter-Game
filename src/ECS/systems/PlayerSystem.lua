local System = Feint.ECS.System
local World = Feint.ECS.World

local down

local PlayerSystem = System:new("PlayerSystem")
function PlayerSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	local Player = world:getComponent("Player")
	local Health = world:getComponent("Health")
	local archetype = EntityManager:newArchetypeFromComponents{Renderer, Transform, Physics, Player, Health}
	for i = 1, 1, 1 do
		EntityManager:createEntityFromArchetype(archetype)
	end

	down = {w = false, a = false, s = false, d = false}

	EntityManager:forEachNotParallel("PlayerSystem_start", function()
		local execute = function(Entity, Player, Renderer)
			-- Renderer.texture = Feint.Core.FFI.cstring("walking1.png")--"walking1.png"
		end
		return execute
	end)
end

function PlayerSystem:update(EntityManager)
	local isDown = love.keyboard.isDown
	for k, v in pairs(down) do
		if isDown(k) then
			down[k] = true
		else
			down[k] = false
		end
	end
	EntityManager:forEachNotParallel("PlayerSystem_test_update", function()
		local execute = function(Entity, Player, Renderer)
			-- Renderer.texture = Feint.Core.FFI.cstring("walking1.png")--"walking1.png"
			-- for k, v in pairs(_G.strings) do
			-- 	print(k, v)
			-- end
		end
		return execute
	end)
	EntityManager:forEachNotParallel("PlayerSystem_update", function()
		local execute = function(Entity, Player, Transform, Physics)
			local move = false
			if down.w then
				Physics.accY = Physics.accY + 2000 / 60
				move = true
			end
			if down.a then
				Physics.accX = Physics.accX - 2000 / 60
				move = true
			end
			if down.s then
				Physics.accY = Physics.accY - 2000 / 60
				move = true
			end
			if down.d then
				Physics.accX = Physics.accX + 2000 / 60
				move = true
			end
			if move then
				Physics.drag = 0.1
			else
				Physics.drag = 0.2
			end
		end
		return execute
	end)
end

return PlayerSystem
