local args = {...}

local initEnv = loadstring(args[1])
local self = args[2]

initEnv(self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

local ffi = require("ffi")
require("Feint_Engine.feintAPI", {Audio = true})
Feint:init(true)
Feint.ECS:init()
pushPrintPrefix(string.format("THREAD_%02d", self.id), true)

-- send response to main thread
Feint.Log:logln("RESPONDING")
channel:push(1)

-- wait for acknowledgement
local status = channel:demand()
print(Feint.Core.FFI.typeSize.cstring)
print(ffi.alignof("struct component_Transform"))
print(ffi.offsetof("struct component_Transform", "sizeX"))

-- send response to main thread
Feint.Log:logln("RESPONDING")
channel:push(2)

-- function processEntities(data, function)
--
-- end

-- print("yrterwrgty")
--
-- print(Feint.Core.FFI.decl)
-- print("dk", ffi.C.strlen(ffi.C.malloc(1)), "djkl")
--
-- local d = channel:pop()
-- print("struct_" .. d.archetypeString .. "* ")
-- local entities = ffi.cast("struct archetype_" .. d.archetypeString .. "* ", d.entities)
-- -- print("fkdlkd", ffi.cast("struct archetype_" .. d.archetypeString .. "* ", d.entities))
-- for i = 0, d.length - 1, 1 do
-- 	print(entities[i].Transform.x)
-- end

local cstring = ffi.typeof("cstring")
Feint.Log:logln("Thread done")
while true do
	local data
	Feint.Log:logln("Waiting for data")
	repeat
		data = channel:demand()
	until data ~= 0 and type(data) == "table"
	-- Feint.Log:log("RECIEVED %s ", data)
	-- printf("tick: %d\n", data.tick)

	local operation = loadstring(data.operation)

	local e = ffi.new("char[?]", data.sizeBytes)
	ffi.copy(e, data.entities, #data.entities)
	local entities = ffi.cast("struct archetype_" .. data.archetypeString .. "* ", e)

	for i = 0, data.length - 1, 1 do
		operation(entities[i])
		-- print(i, entities[i].Renderer.id)
	end

	data.entities = ffi.string(
		entities,
		data.sizeBytes
	)

	-- love.timer.sleep(0.1)
	Feint.Log:logln("Sending data back")

	channel:push(0)
	channel:supply(data)
-- 	Feint.Log:logln(data)
--
-- 	if data.go then
-- 		loop.resume(data)
-- 	end
end
