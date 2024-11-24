; args: tile address, x coord, y coord, color
_drawtile: macro
        movem.l d0-d6/a0, -(a7)
        move.l  \1, a0
        move.w  \2, d5                          ; x coord
        move.w  \3, d6                          ; y coord
        ; multiply x/y coords by 16 (tile size)
        lsl.l   #4, d5
        lsl.l   #4, d6

        ifnc    '\4',''
        ; set fill color
        ; TODO: is setting the outline color necessary? can it be disabled?
        move.l  \4, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        endc
.loop\@:
        move.l  (a0)+, d1
        btst.l  #31, d1
        bne     .done\@
        ifc     '\4',''
        ; set fill color
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        endc
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
        bra     .loop\@
.done\@:
        movem.l (a7)+, d0-d6/a0
        endm

drawtile:
; arguments:
; d5.w -> x tile coordinate
; d6.w -> y tile coordinate
; a0.l -> tile map address
        movem.l d0-d6/a0, -(a7)

        ; multiply x/y coords by 16 (tile size)
        lsl.l   #4, d5
        lsl.l   #4, d6
.loop:
        ; set fill color
        move.l  (a0)+, d1
        btst.l  #31, d1
        bne     .done
        ; TODO: is setting the outline color necessary? can it be disabled?
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
        movem.l (a7)+, d0-d6/a0
        rts

drawtilecol:
; arguments:
; d1.l -> tile color
; d5.w -> x tile coordinate
; d6.w -> y tile coordinate
; a0.l -> tile map address
        movem.l d0-d6/a0, -(a7)

        ; multiply x/y coords by 16 (tile size)
        lsl.w   #4, d5
        lsl.w   #4, d6
        ; TODO: is setting the outline color necessary? can it be disabled?
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

drawmap:
; a1.l -> tile map address
        movem.l d0-d6/a1, -(a7)

        lea.l   tiletable, a2
        move.w  -4(a1), d3                      ; map width
        move.w  -2(a1), d4                      ; map height
        moveq.l #0, d5                          ; x coord
        moveq.l #0, d6                          ; y coord
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
        jsr     drawtile
.skip:
        addq.w  #1, d5
        cmp.w   d3, d5
        blo     .loop
        moveq.l #0, d5

        addq.w  #1, d6
        cmp.w   d4, d6
        blo     .loop

        movem.l (a7)+, d0-d6/a1
        rts

ASCII_NUM_CNT: equ 10
ASCII_CHR_CNT: equ 26

drawstrcol:
; a1.l -> string address
; d5.w -> x coordintate
; d6.w -> y coordintate
; d1.w -> color
        movem.l d4-d5/a0-a3, -(a7)
        lea.l   drawtilecol, a3
        bra     _drawstr
drawstr:
; a1.l -> string address
; d5.w -> x coordintate
; d6.w -> y coordintate
        movem.l d4-d5/a0-a3, -(a7)
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
        blo     .done
        cmp.b   #'0'+ASCII_NUM_CNT, d4
        blo     .num

        ; check uppercase letter
        cmp.b   #'A', d4
        blo     .done
        cmp.b   #'A'+ASCII_CHR_CNT, d4
        blo     .upr

        ; check lowercase letter
        cmp.b   #'a', d4
        blo     .done
        cmp.b   #'a'+ASCII_CHR_CNT, d4
        blo     .lwr

        bra     .done                           ; invalid character
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
        movem.l (a7)+, d4-d5/a0-a3
        rts
