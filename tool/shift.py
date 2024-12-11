#!/usr/bin/env python3

import sys

# TODO: implement args
if __name__ == "__main__":
  tmap = [[int(x) for x in l.strip().split(",") if x] for l in sys.stdin]
  w, h = len(tmap[0]), len(tmap)
  assert all(len(x) == w for x in tmap), "map width mismatch"
  for y in range(h):
    for x in range(w):
      if tmap[y][x] > 37: tmap[y][x] += 2
    print(",".join(map(str, tmap[y])) + ",")
