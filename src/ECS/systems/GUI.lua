local System = Feint.ECS.System
local GUI = Feint.Core.Graphics.UI.Immediate
local Mouse = Feint.Core.Input.Mouse
local typeEnums = Feint.Core.FFI.typeEnums

local GUISystem = System:new("GUISystem")

local lastSelected
local EntityPropertiesWindow
local componentLeaves
local abb

function GUISystem:start()
	EntityPropertiesWindow = {
		Title = "EntityProperties";
		X = 0, Y = 0;
		NoSavedSettings = true;
		AllowMove = true;
		AllowResize = false;
		IsOpen = true;
	}
	componentLeaves = {size = 0}
	abb = setmetatable({
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
end
function GUISystem:update()
end

function GUISystem:IMGUI(EntityManager)
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
	if Mouse.ObjectSelected and EntityPropertiesWindow.IsOpen then
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

return GUISystem
