local Messenger = ECSUtils.newClass("Messenger")
function Messenger:init(lenient)
	self.events = {}
	self.lenient = lenient or false
end
function Messenger:dispatch(message, ...)
	assert(message and type(message) == "string", util.BAD_ARG_ERROR(1, "Messenger:dispatch", "String", type(filter)))

	local args = {...}
	local listeners = self.events[message]
	local returnValues = {}
	if listeners then
		for _, event in pairs(listeners) do
			returnValues = {event.func(event.self, ...)}
		end
	else
		error("callback: "..tostring(message).." not found")
	end
	return returnValues[1], returnValues[2], returnValues[3], returnValues[4], returnValues[5], returnValues[6]
end
--[[
{
	["message1"] = {size = 1}
}
]]
function Messenger:newEvent(messageName)
	assert(not self.events[messageName])
	self.events[messageName] = {size = 0}
end
function Messenger:listen(object, messageName, funcName)
	-- assert(type(object) == "", util.BAD_ARG_ERROR(2, "Messenger:listen", "function", type(func)))
	if not self.lenient then
		assert(self.events[messageName], string.format("attempt to listen to nil event %s", messageName))
	end
	assert(type(funcName) == "string", util.BAD_ARG_ERROR(3, "Messenger:listen (funcName)", "string", type(funcName)))

	local func = object[funcName]

	if not self.lenient then
		assert(type(func) == "function", string.format("function expected at index '%s' of %s got %s", funcName, object, type(func)))
	end
	if func then
		local events = self.events
		events[messageName].size = events[messageName].size + 1
		events[messageName][events[messageName].size] = {self = object, func = func}
	end
end
function Messenger:listenCallback(messageName, callback)
	assert(self.events[messageName], string.format("attempt to listen to nil event %s", messageName))
	assert(type(callback) == "function", util.BAD_ARG_ERROR(2, "Messenger:listen", "function", type(callback)))
	self.events[messageName][#self.events[messageName] + 1] = callback
end

util.makeTableReadOnly(Messenger, function(self, k)
	return util.READ_ONLY_MODIFICATION_ERROR(self, k)
end)
return Messenger
