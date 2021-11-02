local System = Feint.ECS.System
local GUI = Feint.Core.Graphics.UI.Immediate
local Mouse = Feint.Core.Input.Mouse
local typeEnums = Feint.Core.FFI.typeEnums

local lastSelected
local EntityPropertiesWindow
local InputDebugWindow
local componentLeaves
local abb

local GUISystem = System:new("GUISystem")

function GUISystem:init()
end
function GUISystem:start()
	EntityPropertiesWindow = {
		Title = "EntityProperties";
		X = 0, Y = 0;
		NoSavedSettings = true;
		AllowMove = true;
		AllowResize = false;
		IsOpen = true;
	}
	InputDebugWindow = {
		Title = "InputDebug";
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

local EntityProperties
local InputDebug
function GUISystem:IMGUI(EntityManager)
	-- local ratio = Feint.Core.Graphics.ScreenToRenderRatio
	-- local screenSize = Feint.Core.Graphics.ScreenSize
	EntityProperties(EntityManager)
	InputDebug(EntityManager)
end

function InputDebug(EntityManager)
	GUI.BeginWindow("InputDebug", InputDebugWindow)
	-- GUI.Text("Input Debug", {NoSavedSettings = true})

	local Input = Feint.Core.Input
	local Gamepad = Input.Gamepad
		-- local id = joystick:getID()
	for k, joystick in pairs(Input.joysticks) do
		local id = joystick:getID()
		local gamepad = Gamepad[id]
		if GUI.BeginTree("Joystick " .. id, {Title = k, IsLeaf = false, NoSavedSettings = true, IsOpen = true}) then
			-- print(k, Gamepad, gamepad)
			for buttonGroupName, buttonGroup in pairs(gamepad) do
				if buttonGroupName ~= "mappingIndex" and GUI.BeginTree(buttonGroupName, {IsLeaf = false, NoSavedSettings = true, IsOpen = true}) then
					-- local componentLeaf = {IsLeaf = true, NoSavedSettings = true}
					for k, v in pairs(buttonGroup) do
						if type(v) == "number" then
							GUI.BeginTree(string.format("%s, %12f", k, v), {IsLeaf = true, NoSavedSettings = true})
						else
							GUI.BeginTree(string.format("%s, %s", k, v), {IsLeaf = true, NoSavedSettings = true})
						end
					end
					GUI.EndTree()
				end
			end
			GUI.EndTree()
		end
	end
	GUI.EndWindow()
end

function EntityProperties(EntityManager)
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
	if Mouse.ObjectSelected then
		-- local data = EntityManager:getEntityDataFromID(Mouse.ObjectSelected)
		local name = "Entity " .. Mouse.ObjectSelected
		if GUI.BeginContextMenuWindow(2) then
			if GUI.MenuItem("Delete") then
				printf("Deleting %s\n", name)
				EntityManager:deleteEntityFromID(Mouse.ObjectSelected)
			end
			GUI.EndContextMenu()
		end
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
			local fmt1 = "%-" .. memberWidth .. "s: %" .. valueWidth .. "f"
			local fmt2 = "%-" .. memberWidth .. "s: %" .. valueWidth .. "s"
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
						GUI.BeginTree(string.format(fmt1, k, v), componentLeaf)
					else
						GUI.BeginTree(string.format(fmt2, k, v), componentLeaf)
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
