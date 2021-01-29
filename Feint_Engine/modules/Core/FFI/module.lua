local FFI = {
	priority = 1
}

_G.strings = {}
local ffi = require("ffi")
function FFI:load()
	FFI.decl = [[
		void* malloc(size_t size);
		int free(void* ptr);
		void* realloc(void* ptr, size_t size);
		size_t strlen(char* restrict str);
		void* calloc(size_t, size_t);
		char* strdup(const char *str1);
	]]
	ffi.cdef(FFI.decl)
	self.typeSize = {
		bool = ffi.sizeof("bool"),
		int8_t = ffi.sizeof("int8_t"),
		int16_t = ffi.sizeof("int16_t"),
		int32_t = ffi.sizeof("int32_t"),
		float = ffi.sizeof("float"),
		double = ffi.sizeof("double")
	}
	-- local strings = {}--setmetatable({}, {__mode = "k"})
	do
		ffi.cdef([[
			typedef struct {
				char* string;
				uint8_t size;
			} cstring;
		]])
		self.typeSize.cstring = ffi.sizeof("cstring")
		local mt = {
			__len = function(t)
				return t.size;
			end,
			__new = function(ct, string)
				-- print("Initializing " ..tostring(ct) .. " with string " .. string)
				local self = ffi.new(ct)
				_G.strings[string] = ffi.C.malloc(#string)-- ffi.gc(ffi.C.malloc(#string), ffi.C.free)
				self.string = _G.strings[string] -- ffi.C.malloc(#string)
				ffi.copy(self.string, string)
				self.size = #string
				return self
			end,
			__tostring = function(t)
				return "cstring: " .. ffi.string(t.string, t.size)
			end,
			-- __eq = function(a, b)
			-- 	return tostring(b) == a
			-- end
		}
		self.cstring = ffi.metatype("cstring", mt)
	end
end

return FFI
