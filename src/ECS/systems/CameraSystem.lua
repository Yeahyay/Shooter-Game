local System = Feint.ECS.System
local World = Feint.ECS.World
local Graphics = Feint.Core.Graphics

local CameraSystem = System:new("CameraSystem")
function CameraSystem:init()
end
function CameraSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	local Camera = world:getComponent("Camera")
	local archetype = EntityManager:newArchetypeFromComponents{Transform, Physics, Camera}
	for i = 1, 1, 1 do
		EntityManager:createEntityFromArchetype(archetype)
	end
end

local focus
function CameraSystem:update(EntityManager)
	EntityManager:forEachNotParallel("CameraSystem_getEntity", function()
		local execute = function(Entity, CameraFocus)
			focus = Entity
		end
		return execute
	end)
	-- print(focus, type(focus), "jnooiompk")
	EntityManager:forEachNotParallel("CameraSystem_update", function()
		local execute = function(Entity, Transform, Physics, Camera)
			-- print(Camera)
			local mousePosX, mousePosY = Feint.Core.Input.Mouse.Position:split()
			if focus then
				print(focus)
				Camera.target = Feint.Core.FFI.cstring(focus)
				local data = EntityManager:getEntityDataFromID(Camera.target)
				if data then
					Graphics.Camera:setPosition(
						data.Transform.x + mousePosX * 0.5 + data.Physics.accX * 0.1,
						data.Transform.y + mousePosY * 0.5 + data.Physics.accY * 0.1
					)
				end
			end
		end
		return execute
	end)
end

return CameraSystem
