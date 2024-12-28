tileoffset: dc.l $00000000                      ; x << 16 | y

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
        movem.l d0-d6/a0-a3, -(a7)
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
        movem.l d0-d6/a0-a3, -(a7)
        lea.l   drawtile, a3

_drawmap:
        lea.l   tiletable, a2
        move.w  -4(a1), d3                      ; map width
        move.w  -2(a1), d4                      ; map height
.loop:
        moveq.l #0, d0                          ; reset d0 to clear junk
        move.w  (a1)+, d0
        cmp.w   #$ffff, d0                      ; $ffff -> empty tile
        beq     .skip

        ; get current tile
        lsl.l   #2, d0                          ; multiply tile number by 4
        move.l  (a2,d0), d0
        lea.l   tiles, a0
        add.l   d0, a0                          ; offset a0
        jsr     (a3)
.skip:
        addq.w  #1, d5
        cmp.w   d3, d5
        blo     .loop
        moveq.l #0, d5

        addq.w  #1, d6
        cmp.w   d4, d6
        blo     .loop

        movem.l (a7)+, d0-d6/a0-a3
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
        movem.l d3-d5/a0-a3, -(a7)
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
        movem.l d3-d5/a0-a3, -(a7)
        lea.l   drawtile, a3

_drawstr:
        lea.l   tiletable, a2
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
        lea.l   tiles, a0
        add.l   d4, a0
        jsr     (a3)
.skip:
        addq.w  #1, d5                          ; increment x coordinate
        bra     .loop
.done:
        movem.l (a7)+, d3-d5/a0-a3
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
;            d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
;            a1.l - number array (in decimal digit form)
; output   :
; modifies :
drawnumcol:
        movem.l d3-d6/a0-a3, -(a7)
        lea.l   drawtilecol, a3
        bra     _drawnum
; draw decimal number from digit array
;
; input    : d4.w - number of digits to draw
;            d5.w - number start x coordinate
;            d6.w - number start y coordinate
;            a1.l - number array (in decimal digit form)
; output   :
; modifies :
drawnum:
        movem.l d3-d6/a0-a3, -(a7)
        lea.l   drawtile, a3
_drawnum:
        lea.l   tiletable, a2
        moveq.l #0, d3
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
        move.l  (a2,d2), a0
        add.l   #tiles, a0
        jsr     (a3)
.skip:
        addq.w  #1, d5
        dbra.w  d4, .loop
.done:
        movem.l (a7)+, d3-d6/a0-a3
        rts

; TODO: change custom number plot implementation for drawnum
