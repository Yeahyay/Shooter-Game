local System = Feint.ECS.System
local fmath = Feint.Math

local PhysicsSystem = System:new("PhysicsSystem")
function PhysicsSystem:init()
end

function PhysicsSystem:start(EntityManager)
	EntityManager:forEachNotParallel("PhysicsSystem_start", function()
		local function execute(Entity, Physics, Transform)
			Physics.accX = 10
			local s = 0.25
			Transform.x = fmath.random2(-Feint.Core.Graphics.RenderSize.x * s, Feint.Core.Graphics.RenderSize.x * s)
			Transform.y = fmath.random2(-Feint.Core.Graphics.RenderSize.y * s, Feint.Core.Graphics.RenderSize.y * s)
		end
		return execute
	end)
end

function PhysicsSystem:update(EntityManager)
	local dt = 1 / 60
	local mouse = Feint.Core.Input.Mouse
	mouse.ObjectHovered = false
	EntityManager:forEachNotParallel("PhysicsSystem_mouse_update", function()
		local execute = function(Entity, Physics, Transform, Renderer)
			if Renderer.visible then
				local mousePos = Feint.Core.Graphics.Camera:getMousePosition()
				if mousePos.x > Transform.x - Transform.sizeX * 0.5 and mousePos.x < Transform.x + Transform.sizeX * 0.5 and
					mousePos.y > Transform.y - Transform.sizeY * 0.5 and mousePos.y < Transform.y + Transform.sizeY * 0.5 then
						mouse.ObjectHovered = Entity
				end
			end
		end
		return execute
	end)
	EntityManager:forEachNotParallel("PhysicsSystem_update", function()
			local execute = function(Entity, Physics, Transform)
				Physics.posXOld = Transform.x
				Physics.posYOld = Transform.y

				local posX, posY = Transform.x, Transform.y
				local lastPosX, lastPosY = Physics.posXOld, Physics.posYOld
				local accX, accY = Physics.accX, Physics.accY
				accX = accX - accX * Physics.drag
				accY = accY - accY * Physics.drag
				Physics.accX, Physics.accY = math.min(accX, Physics.accCapX), math.min(accY, Physics.accCapY)

				local velX = posX - lastPosX
				local velY = posY - lastPosY

				local nextPosX = posX + velX + accX * (dt * dt) * 100
				local nextPosY = posY + velY + accY * (dt * dt) * 100

				Transform.x = nextPosX
				Transform.y = nextPosY
			end
			return execute
		end
	)
end

return PhysicsSystem
