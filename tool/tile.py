#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image
from pathlib import Path
from imgtool import mat_to_rec, rec_to_m68k

if __name__ == "__main__":
  assert len(sys.argv) > 3, f"usage: {__file__} tile_size src_img_path dst_m68k_tile_path"
  with Image.open(sys.argv[2]) as img:
    tsize = int(sys.argv[1])
    width, height = img.size
    assert width % tsize == 0 and height % tsize == 0

    pix = img.convert("RGB").load()
    tiles = [[[pix[i*tsize+x, y][:3] for x in range(tsize)]for y in range(tsize)] for i in range(width // tsize)]

    idx = [0]
    lines = []
    for tile in tiles:
      r = mat_to_rec(tile)
      idx.append((len(r)*3+1)*4+idx[-1])
      lines.append("\t" + "\n\t".join(rec_to_m68k(r)) + "\n\tdc.l    $ffffffff")
    with Path.open(sys.argv[3], "w") as dst:
      dst.write("tiletable:\n")
      for i in range(0, len(idx), 8): dst.write("\tdc.l    " + ", ".join(f"${x:08x}" for x in idx[i:i+8]) + "\n")
      dst.write("\ntiles:\n")
      for l in lines: dst.write(l + "\n")
