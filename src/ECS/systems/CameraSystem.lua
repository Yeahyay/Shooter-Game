local System = Feint.ECS.System
local World = Feint.ECS.World
local Graphics = Feint.Core.Graphics
local GUI = Feint.Core.Graphics.UI.Immediate
local Mouse = Feint.Core.Input.Mouse
local lastSelected

local CameraSystem = System:new("CameraSystem")

local EntityPropertiesWindow = {
	Title = "EntityProperties";
	X = 0, Y = 0;
	NoSavedSettings = true;
	AllowMove = true;
	AllowResize = false;
	IsOpen = true;
}
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

local typeEnums = Feint.Core.FFI.typeEnums
local componentLeaves = {size = 0}
function CameraSystem:IMGUI(EntityManager)
	-- local ratio = Feint.Core.Graphics.ScreenToRenderRatio
	-- local screenSize = Feint.Core.Graphics.ScreenSize
	local position = Mouse.PositionAbsolute--Feint.Math.Vec2(Mouse.PositionRaw.x * 1 / ratio.x, Mouse.PositionRaw.y * 1 / ratio.y)
	if Mouse.ObjectHovered then
		local data = EntityManager:getEntityDataFromID(Mouse.ObjectHovered)
		local name = "Entity " .. Mouse.ObjectHovered
		GUI.BeginWindow("HoverWindow", {Title = name, X = position.x, Y = 20 - position.y, NoSavedSettings = true})
		for k, v in pairs(data) do
			GUI.Text(v)
		end
		GUI.EndWindow()
	end
	if Mouse.ObjectSelected ~= lastSelected then
		EntityPropertiesWindow.IsOpen = true
	end
	local abb = setmetatable({
		number = "num";
		["function"] = "func";
		["boolean"] = "bool";
		string = "string";
		cdata = "cdata";
		cstring = "cstr";
	}, {
		__index = function(t, k)
			return type(k)
		end
	})
	if Mouse.ObjectSelected then
		lastSelected = Mouse.ObjectSelected
		local data, archetype, index = EntityManager:getEntityDataFromID(Mouse.ObjectSelected)
		local name = "Entity " .. Mouse.ObjectSelected
		-- print(data.Transform.y, data, index)
		GUI.BeginWindow("EntityProperties", EntityPropertiesWindow)
		GUI.Text(name, {NoSavedSettings = true})
		GUI.Separator()
		for i, k, component in pairs(data) do
			if not componentLeaves[k] then
				componentLeaves[k] = {Title = k, IsLeaf = false, NoSavedSettings = true, IsOpen = true}
				componentLeaves.size = componentLeaves.size + 1
			end
			local componentData = componentLeaves[k]
			local memberWidth = 20
			local valueWidth = 12
			if GUI.BeginTree(k, componentData) then
				for i, k, v in pairs(component) do
					local componentLeaf = {IsLeaf = true, NoSavedSettings = true}
					local t
					do
						local rt = type(v)
						t = rt == "cdata" and rt.type or rt
						if rt == "cdata" then
							local cdata = component[k]
							if typeEnums[cdata.type] then
								t = typeEnums[cdata.type]
							end
						end
					end
					k = string.format("%-7s %s", "(" .. abb[t]:sub(1, 5) .. ")", k):sub(1, memberWidth)
					if type(v) == "number" then
						GUI.BeginTree(string.format("%-" .. memberWidth .. "s: %" .. valueWidth .. "f", k, v), componentLeaf)
					else
						GUI.BeginTree(string.format("%-" .. memberWidth .. "s: %" .. valueWidth .. "s", k, v), componentLeaf)
					end
				end
				GUI.EndTree()
				GUI.Button("Remove Component", {NoSavedSettings = true})
			end
		end
		GUI.Button("Add Component", {NoSavedSettings = true})
		GUI.EndWindow()
	end
end
function CameraSystem:update(EntityManager)
	EntityManager:forEachNotParallel("CameraSystem_update", function()
		local execute = function(Entity, Transform, Physics, Camera)
			-- print(Camera.target)
			-- Graphics.Camera:setPosition(Transform)
		end
		return execute
	end)
end

return CameraSystem
