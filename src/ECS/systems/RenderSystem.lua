local System = Feint.ECS.System
local World = Feint.ECS.World
local Graphics = Feint.Core.Graphics

local RenderSystem = System:new("RenderSystem")
function RenderSystem:start(EntityManager)
	local world = World.DefaultWorld
	local Renderer = world:getComponent("Renderer")
	local Transform = world:getComponent("Transform")
	local Physics = world:getComponent("Physics")
	for i = 1, 50000, 1 do
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
				Renderer.texture,
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
		local Graphics = Feint.Core.Graphics

		local function execute(Entity, Renderer, Transform)
			local TLX, TLY, BRX, BRY = Graphics.Camera:getScreenBounds()
			local x, y, sX, sY = Transform.x, Transform.y, Transform.sizeX, Transform.sizeY
			if x > TLX - sX and x < BRX + sX and y < TLY + sY and y > BRY - sY then
				Graphics:modify(
					Renderer.texture,
					Renderer.id,
					Transform.x,
					Transform.y,
					Transform.angle,
					Transform.trueSizeX,
					Transform.trueSizeY
				)
				Renderer.visible = true
			else
				Renderer.visible = false
			end
			Graphics:setVisible(Renderer.texture, Renderer.id, Renderer.visible)
			-- Graphics.visible = math.random(0, 1) > 0.5 and true or false
		end
		return execute
	end)
end

return RenderSystem
