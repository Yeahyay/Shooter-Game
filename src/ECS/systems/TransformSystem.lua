-- local ECSUtils = Feint.ECS.Util
local System = Feint.ECS.System
local World = Feint.ECS.World

local fmath = Feint.Math
local random2 = fmath.random2

local TransformSystem = System:new("TransformSystem")
function TransformSystem:init(...)
end

function TransformSystem:start(EntityManager)
	EntityManager:forEachNotParallel2("rendersystem_start", function()
		local function execute(Data, Entity, Renderer, Transform)
			Transform.x = fmath.random2(-Feint.Core.Graphics.ScreenSize.x, Feint.Core.Graphics.ScreenSize.x)
			Transform.y = fmath.random2(-Feint.Core.Graphics.ScreenSize.y, Feint.Core.Graphics.ScreenSize.y)
		end
		return execute
	end)
end

function TransformSystem:update(EntityManager, dt)
	-- local sin, cos, pi = math.sin, math.cos, math.pi
	-- -- local graphics = Feint.Core.Graphics
	-- local time = Feint.Core.Time:getTime()
	-- local oscillate = Feint.Math.oscillateManualSigned
	--
	-- EntityManager:forEach("main", function(Data, Entity, Renderer, Transform)
	-- 	Transform.angle = (time + Entity / 10) * pi -- + Entity * 6
	-- 	Transform.x = oscillate(time, 50, 2, Entity)
	-- 	Transform.y = oscillate(time, 50, 2, (Entity * Entity) % (2 * math.pi))
	-- end)
	EntityManager:forEachNotParallel2("transformSystem", function()
			local pi = math.pi
			-- local graphics = Feint.Core.Graphics
			local time = Feint.Core.Time:getTime()
			-- local speed = Feint.Core.Time:getSpeed()
			local oscillate = Feint.Math.oscillateManualSigned--triangle
			local RenderSizeX = Feint.Core.Graphics.RenderSize.x / 2
			local RenderSizeY = Feint.Core.Graphics.RenderSize.y / 2
			local execute = function(Data, Entity, Renderer, Transform)
				-- print(Data, Entity, Renderer, Transform)
				local offsetX = oscillate(time, RenderSizeX, 2, Entity)
				local offsetY = oscillate(time, RenderSizeY, 2, (Entity * Entity))
				-- print(Entity)

				-- Transform.x = offsetX
				-- Transform.y = offsetY
				Transform.angle = (time + Entity / 10) * pi -- + Entity * 6
			end

			return execute
		end
	)
	-- EntityManager:forEachNotParallel("transformSystem", function(Data)
	-- 		Data.pi = math.pi
	-- 		Data.graphics = Feint.Core.Graphics
	-- 		Data.time = Feint.Core.Time:getTime()
	-- 		-- Data.speed = Feint.Core.Time:getSpeed()
	-- 		Data.oscillate = Feint.Math.oscillateManualSigned
	-- 		-- Data.RenderSizeX = Feint.Core.Graphics.RenderSize.x / 2
	-- 		-- Data.RenderSizeY = Feint.Core.Graphics.RenderSize.y / 2
	-- 	end,
	-- 	function(Data, Entity, Renderer, Transform)
	-- 		local time = Data.time
	-- 		-- print(Data, Entity, Renderer, Transform)
	-- 		Transform.angle = (Data.time + Entity / 10) * Data.pi -- + Entity * 6
	-- 		local offsetX = Data.oscillate(time, 2000, 2, Entity)
	-- 		local offsetY = Data.oscillate(time, 2000, 2, (Entity * Entity) % (2 * Data.pi))
	--
	-- 		Transform.x = offsetX
	-- 		Transform.y = offsetY
	-- 	end
	-- )
end

return TransformSystem
