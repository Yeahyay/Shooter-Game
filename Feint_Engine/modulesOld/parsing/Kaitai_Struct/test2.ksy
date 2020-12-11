meta:
  id:          ykc
  application: Yuka Engine 2
  endian:      le
seq:
  - id:        magic
    contents:  ["YKC001", 0, 0]
  - id:        magic2
    contents:  [0x18, 0, 0, 0, 0, 0, 0, 0]
  - id:        unknown1
    type:      u4
  - id:        unknown2
    type:      u4
