; args: tile address, x coord, y coord, color
drawtile: macro
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

drawmap:
; a0.l -> tile map address
        movem.l d0-d6/a1, -(a7)

        lea.l   tiletable, a1
        move.w  -4(a0), d3                      ; map width
        move.w  -2(a0), d4                      ; map height
        moveq.l #0, d1                          ; x coord
        moveq.l #0, d2                          ; y coord
.loop:
        moveq.l #0, d0                          ; reset d0 to clear junk
        move.w  (a0)+, d0
        cmp.w   #$ffff, d0                      ; $ffff -> empty tile
        beq     .skip

        ; get current tile
        lsl.l   #2, d0                          ; multiply tile number by 4
        move.l  (a1,d0), d0
        lea.l   tiles, a2
        add.l   d0, a2                          ; offset a2
        drawtile a2, d1, d2
.skip:
        addq.w  #1, d1
        cmp.w   d3, d1
        blo     .loop
        moveq.l #0, d1

        addq.w  #1, d2
        cmp.w   d4, d2
        blo     .loop

        movem.l (a7)+, d0-d6/a1
        rts

ASCII_NUM_CNT: equ 10
ASCII_CHR_CNT: equ 26

drawstr:
; a0.l -> string address
; d1.w -> x coordintate
; d2.w -> y coordintate
        movem.l d0/a1-a2, -(a7)

        lea.l   tiletable, a1
.loop:
        move.l  #0, d0                          ; reset d0 to clear junk
        move.b  (a0)+, d0
        beq     .done                           ; end sequence

        ; check for whitespace
        cmp.b   #$20, d0
        beq     .skip

        ; check number
        cmp.b   #'0', d0
        blo     .done
        cmp.b   #'0'+ASCII_NUM_CNT, d0
        blo     .num

        ; check uppercase letter
        cmp.b   #'A', d0
        blo     .done
        cmp.b   #'A'+ASCII_CHR_CNT, d0
        blo     .upr

        ; check lowercase letter
        cmp.b   #'a', d0
        blo     .done
        cmp.b   #'a'+ASCII_CHR_CNT, d0
        blo     .lwr

        bra     .done                           ; invalid character
.num:
        sub.b   #'0', d0
        bra     .draw
.upr:
        sub.b   #'A'-ASCII_NUM_CNT, d0
        bra     .draw
.lwr:
        sub.b   #'a'-ASCII_NUM_CNT, d0
        bra     .draw
.draw:
        ; get current tile
        lsl.l   #2, d0
        move.l  (a1,d0), d0
        lea.l   tiles, a2
        add.l   d0, a2
        drawtile a2, d1, d2
.skip:
        addq.w  #1, d1                          ; increment x coordinate
        bra     .loop
.done:
        movem.l (a7)+, d0/a1-a2
        rts

drawstrcol:
; a0.l -> string address
; d1.w -> x coordintate
; d2.w -> y coordintate
; d3.l -> color
        movem.l d0/a1-a2, -(a7)

        lea.l   tiletable, a1
.loop:
        move.l  #0, d0                          ; reset d0 to clear junk
        move.b  (a0)+, d0
        beq     .done                           ; end sequence

        ; check for whitespace
        cmp.b   #' ', d0
        beq     .skip

        ; check number
        cmp.b   #'0', d0
        blo     .done
        cmp.b   #'0'+ASCII_NUM_CNT, d0
        blo     .num

        ; check uppercase letter
        cmp.b   #'A', d0
        blo     .done
        cmp.b   #'A'+ASCII_CHR_CNT, d0
        blo     .upr

        ; check lowercase letter
        cmp.b   #'a', d0
        blo     .done
        cmp.b   #'a'+ASCII_CHR_CNT, d0
        blo     .lwr

        bra     .done                           ; invalid character
.num:
        sub.b   #'0', d0
        bra     .draw
.upr:
        sub.b   #'A'-ASCII_NUM_CNT, d0
        bra     .draw
.lwr:
        sub.b   #'a'-ASCII_NUM_CNT, d0
        bra     .draw
.draw:
        ; get current tile
        lsl.l   #2, d0
        move.l  (a1,d0), d0
        lea.l   tiles, a2
        add.l   d0, a2

        ; call drawtile
        drawtile a2, d1, d2, d3
.skip:
        addq.w  #1, d1                          ; increment x coordinate
        bra     .loop
.done:
        movem.l (a7)+, d0/a1-a2
        rts
