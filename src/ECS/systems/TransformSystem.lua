-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math
local random2 = fmath.random2

local TransformSystem = System:new("TransformSystem")
function TransformSystem:init(...)
end

function TransformSystem:start(EntityManager)
	EntityManager:forEachNotParallel("TransformSystem_start", function()
		local function execute(Entity, Renderer, Transform)
			Transform.x = fmath.random2(-Feint.Core.Graphics.ScreenSize.x, Feint.Core.Graphics.ScreenSize.x)
			Transform.y = fmath.random2(-Feint.Core.Graphics.ScreenSize.y, Feint.Core.Graphics.ScreenSize.y)
		end
		return execute
	end)
end

function TransformSystem:update(EntityManager, dt)
	EntityManager:forEachNotParallel("TransformSystem_update", function()
			local pi = math.pi
			-- local graphics = Feint.Core.Graphics
			local time = Feint.Core.Time:getTime()
			-- local speed = Feint.Core.Time:getSpeed()
			local oscillate = Feint.Math.oscillateManualSigned--triangle
			local RenderSizeX = Feint.Core.Graphics.RenderSize.x / 2
			local RenderSizeY = Feint.Core.Graphics.RenderSize.y / 2
			local execute = function(Entity, Transform)
				-- print(Entity, Transform.x, Transform.y)
				local offsetX = oscillate(time, RenderSizeX, 2, Entity)
				local offsetY = oscillate(time, RenderSizeY, 2, (Entity * Entity))
				-- print(Entity)

				Transform.x = offsetX
				Transform.y = offsetY
				print(Transform.x, Transform.y, Transform)
				Transform.angle = (time + Entity / 10) * pi -- + Entity * 6
			end

			return execute
		end
	)
end

return TransformSystem
