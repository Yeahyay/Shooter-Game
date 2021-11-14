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
		typedef struct _cstring cstring;
		struct _cstring {
			const char* string;
			uint8_t size;
			uint8_t type;
		};
		]])
		self.typeEnums = {
			cstring = 1;
		}
		for k, v in pairs(self.typeEnums) do
			self.typeEnums[v] = k
		end
		self.typeSize.cstring = ffi.sizeof("cstring")
		local mt = {
			__len = function(self)
				return self.size;
			end;
			__new = function(ct, _string)
				local string = tostring(_string)
				-- print("Initializing " ..tostring(ct) .. " with string " .. string)
				local self = ffi.new(ct)
				-- _G.strings[string] = string--ffi.C.malloc(#string) --ffi.gc(ffi.C.malloc(#string), ffi.C.free)
				self.string = string--_G.strings[string] -- ffi.C.malloc(#string)
				-- ffi.copy(self.string, string)
				self.size = #string
				self.type = FFI.typeEnums["cstring"]
				return self
			end;
			__tostring = function(t)
				return ffi.string(t.string, t.size)
			end;
			-- __gc = function(cObj)
			-- 	print(cObj)
			-- 	ffi.C.free(cObj)
			-- end;
			__eq = function(a, b)
				return a.string == b
			end
		}
		self.cstring = ffi.metatype("cstring", mt)
	end
end

return FFI
