#!/usr/bin/env python3
from os.path import dirname
from sys import argv

from fontTools.subset import Subsetter
from fontTools.ttLib import TTFont

font = TTFont(argv[1])

REPL = 0xFFFD  # unicode replacement character "�"

subsetter = Subsetter()
subsetter.populate(unicodes=(list(range(32, 128)) + [
    0x02190, # ←
    0x02192, # →
    0x02500, # ─
    0x02502, # │
    0x02514, # └
    0x0251C, # ├
    0x0ee73, # 
    0xf01ee, # 󰇮
    0xf066f, # 󰙯
    REPL,
]))
subsetter.subset(font)

glyphs = font["glyf"].glyphs
for table in font["cmap"].tables:
    if table.isUnicode():
        repl = table.cmap.get(REPL)
        if repl != None:
            glyphs[".notdef"] = glyphs[repl]
            break

font.save(argv[2])
