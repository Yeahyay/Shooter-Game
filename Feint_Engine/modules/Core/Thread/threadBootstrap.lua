local args = {...}

local initEnv = loadstring(args[1])
local self = args[2]

initEnv(self.id)

local channel = love.thread.getChannel("thread_data_" .. self.id)

local ffi = require("ffi")
require("Feint_Engine.feintAPI", {Audio = true})
Feint:init(true)
print("s,;m;m")
-- Feint.ECS:init()
pushPrintPrefix("ASS:", true)

for k, v in pairs(Feint.FFI) do
	print(k, v)
end

print("yrterwrgty")

print(Feint.FFI.decl)
print("dk", ffi.C.strlen(ffi.C.strdup("ass")), "djkl")

local d = channel:pop()
print("struct_" .. d.archetypeString .. " *")
print("fkdlkd", ffi.cast("struct archetype_" .. d.archetypeString .. " *", d.entities))

-- send response to main thread
channel:push(true)

local status = channel:demand()
-- wait for acknowledgement

Feint.Log:logln(status)

Feint.Log:logln("thread done")
while true do
	local data = false
	Feint.Log:logln("WAITING FOR FUNCTION")
	repeat
		data = channel:demand()
	until data
	Feint.Log:logln(data)

	if data.go then
		loop.resume(data)
	end
end
