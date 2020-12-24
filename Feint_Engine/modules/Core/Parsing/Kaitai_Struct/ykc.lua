-- This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild
--
-- This file is compatible with Lua 5.3

local class = require("class")
require("kaitaistruct")

Ykc = class.class(KaitaiStruct)

function Ykc:_init(io, parent, root)
  KaitaiStruct._init(self, io)
  self._parent = parent
  self._root = root or self
  self:_read()
end

function Ykc:_read()
  self.magic = self._io:ensure_fixed_contents("\089\075\067\048\048\049\000\000")
  self.magic2 = self._io:ensure_fixed_contents("\024\000\000\000\000\000\000\000")
  self.unknown1 = self._io:read_u4le()
  self.unknown2 = self._io:read_u4le()
end


