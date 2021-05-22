local System = Feint.ECS.System
local World = Feint.ECS.World
local Graphics = Feint.Core.Graphics

local RenderSystem = System:new("RenderSystem")
function RenderSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	for i = 1, 25, 1 do
		EntityManager:createEntityFromComponents{Renderer, Transform, Physics}
	end

	EntityManager:forEachNotParallel("rendersystem_start", function()
		local graphics = Feint.Core.Graphics

		local function execute(Entity, Renderer, Transform)
			Transform.trueSizeX = Transform.scaleX / Transform.sizeX
			Transform.trueSizeY = Transform.scaleY / Transform.sizeY
			local trueSizeX = Transform.trueSizeX
			local trueSizeY = Transform.trueSizeY

			-- Renderer.texture = Feint.Core.FFI.cstring("walking1.png")
			Renderer.id = graphics:addRectangle(
				Renderer.texture,-- Renderer.textureLength,
				Transform.x - trueSizeX / 2, Transform.y - trueSizeY / 2, Transform.angle, trueSizeX, trueSizeY,
				Transform.sizeX / 2, Transform.sizeY / 2
			)
		end
		return execute
	end)
end

function RenderSystem:update(EntityManager, dt)
	EntityManager:forEachNotParallel("RenderSystem_PlayerName_update", function()

		local function execute(Entity, Player, Transform, Renderer)
			local string = tostring(Player.Name)
			Graphics:queueText(string, Transform.x, Transform.y - 50, Transform.angle, 1, 1, 0, 0, 0, 0)
		end
		return execute
	end)

	EntityManager:forEachNotParallel("RenderSystem_update", function()
		local graphics = Feint.Core.Graphics

		local function execute(Entity, Renderer, Transform)
			graphics:modify(
				Renderer.texture,
				Renderer.id,
				Transform.x,
				Transform.y,
				Transform.angle,
				Transform.trueSizeX,
				Transform.trueSizeY
			)
		end
		return execute
	end)
end

return RenderSystem
