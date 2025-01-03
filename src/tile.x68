tileoffset: dc.l $00000000                      ; x << 16 | y

; load tile table from file
;
; input    :
; output   :
; modifies :
tileinit:
        movem.l d0-d2/a1, -(a7)
        ; close all files (recommended by the documentation)
        move.b  #50, d0
        trap    #15

        ; open tileset file
        move.b  #51, d0
        lea.l   .tileset_path, a1
        trap    #15

        ; read first 4 bytes -> number of bytes to read
        move.b  #53, d0
        lea.l   tileaddr, a1
        moveq.l #4, d2
        trap    #15

        ; load the rest of the file
        move.b  #53, d0
        lea.l   tileaddr, a1
        move.l  (a1), d2
        trap    #15

        ; close file
        move.b  #56, d0
        trap    #15

        ; save tile set address
        add.l   #tiletable, (tileaddr)

        movem.l (a7)+, d0-d2/a1
        rts
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
.tileset_path: dc.b 'tile-table-16.bin',0
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
.tileset_path: dc.b 'tile-table-32.bin',0
        endc
        ds.w    0

; draw small tile at x, y coordinates with an offset
;
; input    : d5.w - tile x coordinate
;            d6.w - tile y coordinate
;            a0.l - tile address
; output   :
; modifies :
drawtileoffsm:
        movem.l d0-d7/a0, -(a7)
        move.l  (tileoffset), d7
        mulu    #TILE_SIZE_SM, d6
        sub.w   d7, d6
        swap    d7
        mulu    #TILE_SIZE_SM, d5
        sub.w   d7, d5
        bra     _drawtile
; draw tile at x, y coordinates with an offset
;
; input    : d5.w - tile x coordinate
;            d6.w - tile y coordinate
;            a0.l - tile address
; output   :
; modifies :
drawtileoff:
        movem.l d0-d7/a0, -(a7)
        move.l  (tileoffset), d7
        lsl.l   #TILE_SHIFT, d6
        sub.w   d7, d6
        swap    d7
        lsl.l   #TILE_SHIFT, d5
        sub.w   d7, d5
        bra     _drawtile
; draw small tile at x, y coordinates
;
; input    : d5.w - tile x coordinate
;            d6.w - tile y coordinate
;            a0.l - tile address
; output   :
; modifies :
drawtilesm:
        movem.l d0-d7/a0, -(a7)
        mulu    #TILE_SIZE_SM, d5 
        mulu    #TILE_SIZE_SM, d6
        bra     _drawtile
; draw tile at x, y coordinates
;
; input    : d5.w - tile x coordinate
;            d6.w - tile y coordinate
;            a0.l - tile address
; output   :
; modifies :
drawtile:
        movem.l d0-d7/a0, -(a7)

        ; multiply x/y coords by TILE_SIZE
        lsl.l   #TILE_SHIFT, d5
        lsl.l   #TILE_SHIFT, d6
_drawtile:
.loop:
        ; set fill color
        move.l  (a0)+, d1
        btst.l  #31, d1
        bne     .done
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15

        ; get source coordinates
        move.w  (a0)+, d1
        move.w  (a0)+, d2
        move.w  (a0)+, d3
        move.w  (a0)+, d4

        ; draw rectangle
        move.b  #87, d0
        add.w   d5, d1
        add.w   d5, d3
        add.w   d6, d2
        add.w   d6, d4
        trap    #15
        bra     .loop
.done:
        movem.l (a7)+, d0-d7/a0
        rts

; draw tile at x, y coordinates with color override
; (all rectangles will be drawn with the specified color)
;
; input    : d1.l - override color
;            d5.w - tile x coordinate
;            d6.w - tile y coordinate
;            a0.l - tile address
; output   :
; modifies :
drawtilecol:
; arguments:
; d1.l -> tile color
; d5.w -> x tile coordinate
; d6.w -> y tile coordinate
; a0.l -> tile map address
        movem.l d0-d6/a0, -(a7)

        ; multiply x/y coords by TILE_SIZE
        lsl.l   #TILE_SHIFT, d5
        lsl.l   #TILE_SHIFT, d6
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
.loop:
        ; set fill color
        move.l  (a0)+, d1
        btst.l  #31, d1
        bne     .done

        ; get source coordinates
        move.w  (a0)+, d1
        move.w  (a0)+, d2
        move.w  (a0)+, d3
        move.w  (a0)+, d4

        ; draw rectangle
        move.b  #87, d0
        add.w   d5, d1
        add.w   d5, d3
        add.w   d6, d2
        add.w   d6, d4
        trap    #15
        bra     .loop
.done:
        movem.l (a7)+, d0-d6/a0
        rts

; draw tile map with color override
;
; input    : d1.l - override color
;            d5.w - map start x coordinate
;            d6.w - map start y coordinate
;            a1.l - tile map address
; output   :
; modifies :
drawmapcol:
        movem.l d0-d6/a0-a4, -(a7)
        lea.l   drawtilecol, a3
        bra     _drawmap
; draw tile map
;
; input    : d5.w - map start x coordinate
;            d6.w - map start y coordinate
;            a1.l - tile map address
; output   :
; modifies :
drawmap:
; TODO: do the d5, d6 arguments make sense?
        movem.l d0-d6/a0-a4, -(a7)
        lea.l   drawtile, a3
_drawmap:
        lea.l   tiletable, a2
        move.w  -4(a1), d3                      ; map width
        move.w  -2(a1), d4                      ; map height
        move.l  (tileaddr), a4
.loop:
        moveq.l #0, d0                          ; reset d0 to clear junk
        move.w  (a1)+, d0
        cmp.w   #$ffff, d0                      ; $ffff -> empty tile
        beq     .skip

        ; get current tile
        lsl.l   #2, d0                          ; multiply tile number by 4
        move.l  a4, a0
        add.l   (a2,d0), a0
        jsr     (a3)
.skip:
        addq.w  #1, d5
        cmp.w   d3, d5
        blo     .loop
        moveq.l #0, d5

        addq.w  #1, d6
        cmp.w   d4, d6
        blo     .loop

        movem.l (a7)+, d0-d6/a0-a4
        rts

ASCII_NUM_CNT: equ 10
ASCII_CHR_CNT: equ 26

; draw null terminated string with color override
;
; input    : d1.l - override color
;            d5.w - string start x coordinate
;            d6.w - string start y coordinate
;            a1.l - string address
; output   :
; modifies :
drawstrcol:
        movem.l d3-d5/a0-a4, -(a7)
        lea.l   drawtilecol, a3
        bra     _drawstr
; draw null terminated string with color override
;
; input    : d5.w - string start x coordinate
;            d6.w - string start y coordinate
;            a1.l - string address
; output   :
; modifies :
drawstr:
        movem.l d3-d5/a0-a4, -(a7)
        lea.l   drawtile, a3

_drawstr:
        lea.l   tiletable, a2
        move.l  (tileaddr), a4
.loop:
        move.l  #0, d4                          ; reset d4 to clear junk
        move.b  (a1)+, d4
        beq     .done                           ; end sequence
        ; check for whitespace
        cmp.b   #$20, d4
        beq     .skip
        ; check number
        cmp.b   #'0', d4
        blo     .sym
        cmp.b   #'0'+ASCII_NUM_CNT, d4
        blo     .num
        ; check uppercase letter
        cmp.b   #'A', d4
        blo     .sym
        cmp.b   #'A'+ASCII_CHR_CNT, d4
        blo     .upr
        ; check lowercase letter
        cmp.b   #'a', d4
        blo     .sym
        cmp.b   #'a'+ASCII_CHR_CNT, d4
        blo     .lwr
.sym:
        lea.l   .symtable, a0
.symloop:
        move.w  (a0)+, d3
        beq     .done                           ; symtable end -> invalid character
        cmp.b   d4, d3
        bne     .symloop
        lsr.w   #8, d3
        move.b  d3, d4
        bra     .draw
.num:
        sub.b   #'0', d4
        bra     .draw
.upr:
        sub.b   #'A'-ASCII_NUM_CNT, d4
        bra     .draw
.lwr:
        sub.b   #'a'-ASCII_NUM_CNT, d4
        bra     .draw
.draw:
        ; get current tile
        lsl.l   #2, d4
        move.l  (a2,d4), d4
        move.l  a4, a0
        add.l   d4, a0
        jsr     (a3)
.skip:
        addq.w  #1, d5                          ; increment x coordinate
        bra     .loop
.done:
        movem.l (a7)+, d3-d5/a0-a4
        rts
.symtable:
        dc.b    36, $2d                         ; '-'
        dc.b    39, $2c                         ; ','
        dc.b    40, $2f                         ; '/'
        dc.b    41, $28                         ; '('
        dc.b    42, $29                         ; ')'
        dc.b    43, $22                         ; '"'
        dc.b    44, $21                         ; '!'
        dc.b    45, $3e                         ; '>'
        dc.b    46, $3c                         ; '<'
        dc.b    0, 0

; draw decimal number from digit array with color override
;
; input    : d1.l - override color
;            d3.b - draw leading 0s (flag: 1 -> true, 0 -> false)
;            d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
;            a1.l - number array (in decimal digit form)
; output   :
; modifies :
drawdigitscol:
        movem.l d3-d6/a0-a4, -(a7)
        lea.l   drawtilecol, a3
        bra     _drawdigits
; draw decimal number from digit array
;
; input    : d3.b - draw leading 0s (flag: 1 -> true, 0 -> false)
;            d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
;            a1.l - number array (in decimal digit form)
; output   :
; modifies :
drawdigits:
        movem.l d3-d6/a0-a4, -(a7)
        lea.l   drawtile, a3
_drawdigits:
        move.l  (tileaddr), a4
        lea.l   tiletable, a2
        subq.w  #1, d4
.loop:
        moveq.l #0, d2
        move.b  (a1)+, d2
        bne     .draw
        tst.b   d3
        beq     .skip
.draw:
        moveq.l #1, d3
        cmp.b   #10, d2
        bhs     .done
        lsl.l   #2, d2
        move.l  a4, a0
        add.l   (a2,d2), a0
        jsr     (a3)
.skip:
        addq.w  #1, d5
        dbra.w  d4, .loop
.done:
        movem.l (a7)+, d3-d6/a0-a4
        rts

; draw decimal number
;
; input    : d0.l - number to draw
;            d1.l - override color
;            d3.b - draw leading 0s (flag: 1 -> true, 0 -> false)
;            d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
; output   :
; modifies :
drawnumcol:
        movem.l d4/a1-a2, -(a7)
        lea.l   drawdigitscol, a2
        bra     _drawnum
; draw decimal number
;
; input    : d0.l - number to draw
;            d3.b - draw leading 0s (flag: 1 -> true, 0 -> false)
;            d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
; output   :
; modifies :
drawnum:
        movem.l d4/a1-a2, -(a7)
        lea.l   drawdigits, a2
_drawnum:
        lea.l   .digits, a0
        move.l  d1, -(a7)
        moveq.l #5-1, d1
.clr:
        move.b  #0, (a0,d1.w)
        dbra.w  d1, .clr

        cmp.w   #5, d4
        bls     .bcd
        move.w  #5, d4
.bcd:
        moveq.l #0, d1
        move.w  d4, d1
        jsr     bcd

        move.l a0, a1
        move.l  (a7)+, d1
        jsr     (a2)

        movem.l (a7)+, d4/a1-a2
        rts
.digits:
        ds.b    5
        ds.w    0
