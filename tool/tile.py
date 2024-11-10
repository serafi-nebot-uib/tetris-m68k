#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image

if __name__ == "__main__":
  assert len(sys.argv) > 2, f"usage: {__file__} tile_size src_img_path"
  with Image.open(sys.argv[2]) as img:
    tsize = int(sys.argv[1])
    width, height = img.size
    assert width % tsize == 0 and height % tsize == 0
