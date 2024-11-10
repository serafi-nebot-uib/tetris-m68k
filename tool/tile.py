#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image, ImageDraw

def tile_draw(mat: list, bsize: int, size: int):
  assert len(mat) == size*size
  img = Image.new("RGBA", (size, size))
  draw = ImageDraw.Draw(img)
  for y in range(size):
    for x in range(size):
      draw.rectangle((x*bsize, y*bsize, (x+1)*bsize, (y+1)*bsize), fill=tuple(mat[y*size+x]))
  return img

if __name__ == "__main__":
  assert len(sys.argv) > 2, f"usage: {__file__} tile_size src_img_path"
  with Image.open(sys.argv[2]) as img:
    tsize = int(sys.argv[1])
    width, height = img.size
    assert width % tsize == 0 and height % tsize == 0

    pix = img.convert("RGB").load()
    tiles = [[pix[i*tsize+x, y][:3] for y in range(tsize) for x in range(tsize)] for i in range(width // tsize)]
    # print(len(tiles))
    for tile in tiles:
      for i in range(0, len(tile), 8):
        print("        dc.l " + ", ".join(f"$00{b:02x}{g:02x}{r:02x}" for r, g, b in tile[i:i+8]))
      print()
