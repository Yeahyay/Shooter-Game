-- luacheck: ignore

LevelParser = class("LevelParser")
function LevelParser:init()
	print("Level parser initialized")
	self.file = ""
	self.levelData = {}
end
function LevelParser:parse(path)
	self.file = path or self.file
	local inBracket = false
	--print(self.file)
	--[[for line in love.filesystem.lines(self.file) do
		--print(line)
		if line:find("LEVEL:") then
			print("efjkon")
		end
		if line:find("%{") then
			inBracket = true
		end
		if inBracket and line:find("%}") then
			inBracket = false
		end
	end]]
end
function LevelParser:luaLoad(name)
	local path = SAVEDIR.."/"..name..".level"
	local file, err = love.filesystem.load(name..".level")
	if file then file(Game, SEED) else print("Failed to load level!") end
end
function LevelParser:luaSave(level, name)
	local level = string.dump(level)
	local path = name..".level"
	local file = love.filesystem.newFile(path, "w")--io.open(path, "w")
	--print("Saving to "..path)
	file:write(level)
	--print(file:write(level))
	--print("Saved!")]]``
end
function LevelParser:load(name)
	local levelName = name..".level"
	local path = SAVEDIR.."/"..levelName
	local file, err = love.filesystem.read(levelName)

	print("ATTEMPTING TO LOAD LEVEL "..levelName)
	local loadStatus = self:repopulateEntities(file)
	if file and loadStatus then
		print("LOADED "..levelName.."!")
	else
		-- love.filesystem.remove(levelName)
		print("Failed to load level!")
	end
end

-- INSTANTIATE ENTITIES FROM DATA
function LevelParser:repopulateEntities(file)
	local status, error = pcall(function() bitser.loads(file) end)
	if status then
		local levelData = bitser.loads(file)
		-- go through every entity stored in the save data
		for index, entityData in pairs(levelData) do
			self:reinitializeEntity(entityData)
		end
		return true
	end
	return false
end

-- REINITIALIZE ENTITIES
function LevelParser:reinitializeEntity(data)
	-- initialize the entity
	local newTestEntity = Entity(unpack(data.EntityInit))

	-- iterate through all component properties that require special initialization and set them up
	-- usually class objects that get serialized as generic tables if not specified
	for componentName, componentData in pairs(data.Components.init) do
		for property, value in pairs(componentData) do
			--	print("", value)
			if type(value) == "table" then
				--	print("", property, value)
				if value[3] == "Vector2" then
					componentData[property] = Vector2.new(unpack(value))
				end
				if value[4] == "Vector3" then
					local newVector3 = Vector3.new(unpack(value))
					componentData[property] = newVector3
				end
				--	print("", componentData[property])
			end
		end
		-- give the entity the component as well as its initialization data
		newTestEntity:give(Game[componentName], unpack(componentData))
	end

	-- iterate through all properties that need to be preserved such as a camera's target or an object's uuid
	-- print("PRESERVED FOR ENTITY "..tostring(unpack(data.EntityInit)))
	for name, componentData in pairs(data.Components.preserve) do
		local component = newTestEntity:get(Game[name])
		--[[for property, value in pairs(component) do
			print("", "", property, value)
		end
		print("", name, "PRESERVE")
		for property, value in pairs(componentData) do
			print("", "", property, value)
		end]]
		for property, value in pairs(componentData) do
			-- set the value to the preserved value
			component[property] = value
		end
	end

	-- apply changes and add to game instace
	newTestEntity:apply()
	GameInstance:addEntity(newTestEntity)
end
function LevelParser:save(name)
	local levelName = name..".level"
	local path = name..".level"

	self.levelData = {}

	print("ATTEMPTING TO SAVE LEVEL "..levelName)
	local currentData = nil
	-- iterate through every entity and set it up for serialization
	-- then store prepared object in a table
	for _, entity in pairs(GameInstance.entities.objects) do
		currentData = self:setUpEntitySerialization(entity)
		self.levelData[#self.levelData + 1] = currentData
	end
	-- check if serialization is valid (kinda slow)
	local serializedLevelData
	local status, error = pcall(function() serializedLevelData = bitser.dumps(self.levelData) end)
	if status then -- if valid, overwrite; if not valid, discard save data
		local file = love.filesystem.newFile(path, "w")--io.open(path, "w")
		file:write(serializedLevelData)
		print("SAVED "..levelName.."!")
	else
		print("FAILED TO SAVE "..levelName.."!")
		print("ERROR:\n"..error)
	end
end

-- NOT USED
local propertyFilter = {
	--Body
	--	"Collider",
	--CameraComponent
	"Target",
	--Inventory
	"Equipped",
	"LastEquipped",
	"Items",
	"ItemsId",
}

-- SETUP FOR SERIALIZATION
function LevelParser:setUpEntitySerialization(entity)
	local newData = {
		EntityInit = {entity.name},
		Components = {}
	}
	local entityComponents = entity.components
	--	print(entity)
	newData.Components = self:prepareComponents(entityComponents)
	--	print("SERIALIZED ENTITY "..tostring(entity).."!")
	return newData
end

-- PREPARE THE COMPONENTS
function LevelParser:prepareComponents(components)
	local initComponentData = {}
	local preserveComponentData = {}
	-- each component has fields to specify initialization values and value to preserve on save
	for name, data in pairs(components) do
		local component = components[name]
		local name = name.name or name
		-- print("", name, data)
		initComponentData[name] = data.SERIALIZE(component)[1]
		preserveComponentData[name] = data.SERIALIZE(component)[2]
	end
	-- convert data so it can be loaded properly
	initComponentData = self:convertData(initComponentData)
	preserveComponentData = self:convertData(preserveComponentData)
	-- print("PREPARATION COMPLETE")
	return {init = initComponentData, preserve = preserveComponentData}
end
function LevelParser:convertData(componentData)
	-- this function is needed to specify special class objects
	-- serialized objects get loaded as default tables with no metatables

	--	print("CONVERTING VECTORS")
	for name, data in pairs(componentData) do
		-- print("", name, data)
		for property, value in pairs(data) do
			if Vector2.isVector(value) then
				data[property] = {value.x, value.y, "Vector2"}
			end
			if Vector3.isVector(value) then
				data[property] = {value.x, value.y, value.z, "Vector3"}
			end
			-- print("", "", property, value)
			--[[if type(data[property]) == "table" then
				print("", "", property, unpack(data[property]))
			else
				print("", "", property, data[property])
			end
			bitser.dumps(data[property])
			--]]
		end
		componentData[name] = data
		--	print("", name)--, data)
		--	bitser.dumps(newComponentData[name])
	end
	return componentData
end

levelParser = LevelParser()

bitser.register("random2", math.random2)
bitser.register("transform", love.math.newTransform)
bitser.register("uuid", uuid)
bitser.register("GameInstanceEmit", GameInstance.emit)
bitser.register("Living", Living)
bitser.register("Metal", Metal)
bitser.register("Bedrock", Bedrock)
bitser.register("anim8newGrid", anim8.newGrid)
bitser.register("VectorHadamard", Vector2.hadamard)
