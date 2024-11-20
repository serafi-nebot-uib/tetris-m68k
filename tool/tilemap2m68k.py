#!/usr/bin/env python3

import sys
from pathlib import Path

if __name__ == "__main__":
  assert len(sys.argv) > 2, f"usage: {__file__} src_tilemap_path dst_tilemap_path"
  with Path.open(sys.argv[1], "r") as src:
    with Path.open(sys.argv[2], "w") as dst:
      tmap = [[int(x) & 0xffff for x in l.strip().split(",")] for l in src]
      w, h = len(tmap[0]), len(tmap)
      assert all(len(x) == w for x in tmap), "map width mismatch"
      dst.write(f"\tdc.w\t${w:04x} ; width\n")
      dst.write(f"\tdc.w\t${h:04x} ; height\n")
      dst.write(f"{Path(dst.name).stem.translate({ord(i): None for i in '-.'})}:\n")
      for t in tmap: dst.write("\tdc.w\t" + ",".join(f"${x:04x}" for x in t) + "\n")
