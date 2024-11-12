#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image, ImageDraw
from imgtool import mat_to_rec

if __name__ == "__main__":
  assert len(sys.argv) > 3, f"usage: {__file__} tile_size src_img_path dst_img_path"
  with Image.open(sys.argv[2]) as src:
    tsize = int(sys.argv[1])
    width, height = src.size
    assert width % tsize == 0 and height % tsize == 0

    pix = src.convert("RGB").load()
    tiles = [[[pix[j*tsize+x, i*tsize+y][:3] for x in range(tsize)] for y in range(tsize)] for i in range(height//tsize) for j in range(width//tsize)]

    tilemap = []
    for t in tiles:
      if (r := tuple(mat_to_rec(t))) not in tilemap: tilemap.append(r)

    N = len(tilemap)
    dst = Image.new("RGBA", (N*tsize, tsize))
    draw = ImageDraw.Draw(dst)
    for i, tile in enumerate(tilemap):
      xoff = i*tsize
      for c, r in tile:
        sx, sy, ex, ey = r
        sx, ex = sx+xoff, ex+xoff
        draw.rectangle((sx, sy, ex, ey), fill=tuple(c))
    dst.save(sys.argv[3])
    print(f"{N} tiles created")
