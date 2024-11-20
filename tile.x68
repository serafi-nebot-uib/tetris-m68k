drawtile:
; arguments:
;       sp+0 (x pos)                    -> d3
;       sp+2 (y pos)                    -> d4
;       sp+4 (bitmap address high word) -> a0
;       sp+6 (bitmap address low word)  -> a0
        movem.w d0-d6, -(a7)
        move.l  a0, -(a7)

; 1*4 (PC) + 7*2=14 (dx save) + 1*4=4 (a0) = 22
.base:  equ     22

        ; get subroutine arguments
        movem.w .base+0(a7), d5-d6
        move.l  .base+4(a7), a0
        ; multiply x/y coords by 16 (tile size)
        lsl.l   #4, d5
        lsl.l   #4, d6
.loop:
        ; set fill color
        move.l  (a0)+, d1
        move.l  d1, d2
        eor.l   #$ffffffff, d2                  ; detect end sequence
        beq     .done
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
        move.l  (a7)+, a0
        movem.w (a7)+, d0-d6
        rts

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

        ; call drawtile
        move.l  a2, -(a7)                       ; tile address
        move.w  d2, -(a7)                       ; y pos
        move.w  d1, -(a7)                       ; x pos
        jsr     drawtile
        addq.w  #8, a7                          ; pop arguments
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
