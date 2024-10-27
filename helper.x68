minl:
        cmp.l   d0, d1
        bgt     .done
        move.l  d1, d0
.done:
        rts

maxl:
        cmp.l   d0, d1
        blt     .done
        move.l  d1, d0
.done:
        rts

minw:
        cmp.w   d0, d1
        bgt     .done
        move.w  d1, d0
.done:
        rts

maxw:
        cmp.w   d0, d1
        blt     .done
        move.w  d1, d0
.done:
        rts

polyinter:
; 2 words for d0-d1 + 2 words for PC -> 6 bytes
.base:  equ     8
; sp+0: x1 start | x2 start
; sp+2: y1 start | y2 start
; sp+4: x1 end | x2 end
; sp+6: y1 end | y2 end
        movem.w d0-d1, -(a7)
        clr.w   d1

        ; TODO: join 4 identical code blocks in a loop
        move.w  .base+0(a7), d0
        move.b  d0, d1
        lsr.w   #8, d0
        jsr     maxw
        move.w  d0, .base+0(a7)

        move.w  .base+2(a7), d0
        move.b  d0, d1
        lsr.w   #8, d0
        jsr     maxw
        move.w  d0, .base+2(a7)

        move.w  .base+4(a7), d0
        move.b  d0, d1
        lsr.w   #8, d0
        jsr     minw
        move.w  d0, .base+4(a7)

        move.w  .base+6(a7), d0
        move.b  d0, d1
        lsr.w   #8, d0
        jsr     minw
        move.w  d0, .base+6(a7)

        movem.w (a7)+, d0-d1
        rts
