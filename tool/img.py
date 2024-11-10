#!/usr/bin/env python3

from __future__ import annotations

import numpy as np
from collections import deque
from PIL import Image, ImageDraw
from argparse import ArgumentParser

def img_to_mat(path: str, bsize: int, width: int | None = None, height: int | None = None) -> tuple:
  img = Image.open(path)
  # resize width and height to be a multiple of bsize
  size = s if None not in (s := (width, height)) else img.size
  width, height = (x // bsize * bsize for x in size) # type: ignore[operator]
  arr = np.array(img.resize((width, height), Image.Resampling.LANCZOS).convert("RGBA"))
  mat = []
  for y in range(0, height, bsize):
    row = []
    for x in range(0, width, bsize):
      block = arr[y:y+bsize, x:x+bsize]
      avgc = np.mean(block, axis=(0, 1)).astype(int)
      row.append(avgc.tolist())
    mat.append(row)
  return mat, width, height

def mat_to_img(mat: list, bsize: int):
  width, height = len(mat[0]) * bsize, len(mat) * bsize
  img = Image.new("RGBA", (width, height))
  draw = ImageDraw.Draw(img)
  for y, row in enumerate(mat):
    for x, color in enumerate(row):
      draw.rectangle((x*bsize, y*bsize, (x+1)*bsize, (y+1)*bsize), fill=tuple(color))
  return img

def rec_to_img(rec: list, width: int, height: int):
  img = Image.new("RGBA", (width, height))
  draw = ImageDraw.Draw(img)
  for c, r in rec: draw.rectangle(r, fill=tuple(c))
  return img

def mat_to_rec(mat: list, bsize: int) -> list:
  rows, cols = len(mat), len(mat[0])
  vis = [[False for _ in range(cols)] for _ in range(rows)]

  def flood_fill(x, y, color):
    q = deque([(x, y)])
    min_x, min_y, max_x, max_y = x, y, x, y
    while q:
      curr_x, curr_y = q.popleft()
      if 0 <= curr_x < cols and 0 <= curr_y < rows and not vis[curr_y][curr_x] and mat[curr_y][curr_x] == color:
        vis[curr_y][curr_x] = True
        min_x, min_y = min(min_x, curr_x), min(min_y, curr_y)
        max_x, max_y = max(max_x, curr_x), max(max_y, curr_y)
        for dx, dy in ((0, 1), (1, 0), (0, -1), (-1, 0)): q.append((curr_x + dx, curr_y + dy))
    return tuple(x*bsize for x in (min_x, min_y, max_x+1, max_y+1))

  return [(mat[y][x], flood_fill(x, y, mat[y][x])) for y in range(rows) for x in range(cols) if not vis[y][x] and mat[y][x][3] > 128]

def rec_m68k_enc(color: list, coords: list) -> str:
  r, g, b, *_ = color
  sx, sy, ex, ey, *_ = coords
  return f"dc.l  $00{b:02x}{g:02x}{r:02x}, ${sx:04x}{sy:04x}, ${ex:04x}{ey:04x}"

def rec_to_m68k(rec: list) -> list: return [rec_m68k_enc(color, coords) for color, coords in rec]

if __name__ == "__main__":
  parser = ArgumentParser()
  parser.add_argument("path", help="source image path")
  parser.add_argument("-b", "--block-size", required=True, type=int, help="matrix cell block size in pixels (--block-size 4 -> each matrix cell will be 4x4 pixels)")
  parser.add_argument("-s", "--size",
                      help="""output image size as <width>x<height> in pixels (both width and height should be a multiple of --block-size in order to work properly)""")
  parser.add_argument("--show", action="store_true", help="show output image")
  parser.add_argument("--m68k", action="store_true", help="print data as m68k assembly constants")

  args = parser.parse_args()
  size = tuple(map(int, args.size.split("x"))) if args.size is not None else (None, None)
  mat, width, height = img_to_mat(args.path, args.block_size, *size)
  rec = mat_to_rec(mat, args.block_size)
  if args.show: rec_to_img(rec, width, height).show()
  if args.m68k: print("\t" + "\n\t".join(rec_to_m68k(rec)))
