#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image
from struct import pack
from pathlib import Path
from imgtool import mat_to_rec

if __name__ == "__main__":
  assert len(sys.argv) > 3, f"usage: {__file__} tile_size src_img_path dst_m68k_tile_path"
  with Image.open(sys.argv[2]) as img:
    tsize = int(sys.argv[1])
    width, height = img.size
    assert width % tsize == 0 and height % tsize == 0

    pix = img.convert("RGB").load()
    tiles = [[[pix[i*tsize+x, y][:3] for x in range(tsize)]for y in range(tsize)] for i in range(width // tsize)]

    idx = [0]
    data = []
    for tile in tiles:
      r = mat_to_rec(tile, ignore_black=True)
      idx.append((len(r)*3+1)*4+idx[-1])
      for col, crd in r:
        data.append(col[2] << 16 | col[1] << 8 | col[0])
        data.append(crd[0]<<16 | crd[1])
        data.append(crd[2]<<16 | crd[3])
      data.append(0xffffffff)

    with Path(sys.argv[3]).open("wb") as dst:
      dst.write(pack(">L", len(idx)*4+len(data)*4+4))
      dst.write(pack(">L", len(idx)*4)) # do not count initial 0
      for i in idx: dst.write(pack(">L", i))
      for v in data: dst.write(pack(">L", v))
