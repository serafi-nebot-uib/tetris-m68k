#!/usr/bin/env python3

from __future__ import annotations

import sys
from PIL import Image

if __name__ == "__main__":
  assert len(sys.argv) > 3, f"usage: {__file__} resize_factor src_img_path dst_img_path"
  with Image.open(sys.argv[2]) as img:
    img.resize((x*int(sys.argv[1]) for x in img.size), Image.NEAREST).save(sys.argv[3])
