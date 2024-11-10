#!/usr/bin/env python3

from __future__ import annotations

import sys
from collections import deque
from PIL import Image, ImageDraw

def tile_draw(mat: list, bsize: int, size: int):
  assert len(mat) == size and len(mat[0]) == size
  img = Image.new("RGBA", (size, size))
  draw = ImageDraw.Draw(img)
  for y in range(size):
    for x in range(size):
      draw.rectangle((x*bsize, y*bsize, (x+1)*bsize, (y+1)*bsize), fill=tuple(mat[y][x]))
  return img

def flood_fill(mat, x, y):
  min_x, min_y, max_x, max_y = x, y, x, y
  while max_x+1 < len(mat[y]) and mat[y][max_x+1] == mat[y][x]: max_x += 1
  while max_y+1 < len(mat) and all(c == mat[y][x] for c in mat[max_y+1][min_x:max_x+1]): max_y += 1
  return min_x, min_y, max_x, max_y

def mat_to_rec(mat: list):
  rows, cols = len(mat), len(mat[0])
  vis = [[False for _ in range(cols)] for _ in range(rows)]
  rec = []
  for y in range(rows):
    for x in range(cols):
      if not vis[y][x]:
        r = flood_fill(mat, x, y)
        rec.append((mat[y][x], r))
        for i in range(r[1], r[3]+1):
          for j in range(r[0], r[2]+1):
            vis[i][j] = True
  return rec

def rec_to_img(rec: list, width: int, height: int):
  img = Image.new("RGBA", (width, height))
  draw = ImageDraw.Draw(img)
  for c, r in rec: draw.rectangle(r, fill=tuple(c))
  return img

def rec_m68k_enc(color: list, coords: list) -> str:
  r, g, b, *_ = color
  sx, sy, ex, ey, *_ = coords
  return f"dc.l    $00{b:02x}{g:02x}{r:02x}, ${sx:04x}{sy:04x}, ${ex:04x}{ey:04x}"
def rec_to_m68k(rec: list) -> list: return [rec_m68k_enc(color, coords) for color, coords in rec]

if __name__ == "__main__":
  assert len(sys.argv) > 2, f"usage: {__file__} tile_size src_img_path"
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
    print("tiletable:")
    for i in range(0, len(idx), 8): print("\tdc.l    " + ", ".join(f"${x:08x}" for x in idx[i:i+8]))
    print()
    print("tiles:")
    print("\n".join(lines))
