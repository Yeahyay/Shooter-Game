-- luacheck: ignore

local AssetManager = ECSUtils.newClass("AssetManager")--, {"General"})
function AssetManager:init()
	self.Assets = {}
	self:newAssetCategory("Image", love.graphics.newImage("sprites/Test Texture 1.png"))
	self:newAssetCategory("Sprite", false)
	self:newAssetCategory("String", "DEFAULT_STRING")
	self:newAssetCategory("Sound", love.audio.newSource("sound/hurt.wav", "stream"))
	self:newAssetCategory(
		"SpriteBatch",
		love.graphics.newSpriteBatch(love.graphics.newImage("sprites/Test Texture 1.png"), 1000, "dynamic")
	)
	-- self:newAssetCategory("Quad", love.graphics.newQuad(0, 0, 32, 32, sw, sh)
	-- bitser.register("SOUNDASSET", love.audio.newSource)
	-- bitser.register("SPRITEASSET", love.graphics.newImage)
end
function AssetManager:newAssetCategory(category, defaultAsset)
	self.Assets[category] = {}
	self:addAsset(category, "default", defaultAsset)
end
--INIT EXTERNAL RESOURCES
-- do
-- 	fonts = {}
-- 	fonts.default = love.graphics.setNewFont(100)
-- 	local dir = love.filesystem.getDirectoryItems("fonts")
-- 	for k, v in pairs(dir) do
-- 		local string = "fonts/"..v
-- 		if not v:find(".zip") then --ignore zip files
-- 			stringRaw = v:gsub(".ttf", "")
-- 			stringRaw = stringRaw:gsub("-", "")
-- 			fonts[stringRaw] = love.graphics.newFont(string, 100)
-- 		end
-- 	end
-- 	fonts.current = fonts.default
-- end
function AssetManager:update(dt)

end
function AssetManager:draw()

end
function AssetManager:addAsset(type, name, asset)
	assert(type == nil or self.Assets[type], "ASSET TYPE "..tostring(type).." DOES NOT EXIST")
	-- bitser.register(type.."."..name, asset)
	--print("Added Asset: "..tostring(asset).." Type: "..tostring(type)..", Name: "..tostring(name))
	self.Assets[type][name] = asset
end
function AssetManager:requestAsset(type, name)
	assert(self.Assets[type], "ASSET TYPE "..tostring(type).." DOES NOT EXIST")
	local asset = nil--self.Assets[type].default
	-- local name = name or "default"
	if self.Assets[type] then
		if self.Assets[type][name] then
			asset = self.Assets[type][name]
		end
	end
	if not asset then
		-- asset = self.Assets[type].default
		-- name = "default"
		error("ASSET "..name.." DOES NOT EXIST")
	end
	--print("Requested Asset: "..tostring(asset).." Type: "..tostring(type)..", Name: "..tostring(name).." at time: "..timer)
	return asset, name
end
-- memoize(AssetManager.requestAsset)

util.makeTableReadOnly(AssetManager, function(self, k)
	return util.READ_ONLY_MODIFICATION_ERROR(self, k)
end)
return AssetManager
