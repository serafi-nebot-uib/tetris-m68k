; input    : d0.l - number to convert
;            d1.l - target digit array size
;            a0.l - target digit array address
; output   :
; modifies :
bcd:
        ; code sourced from perplexity.ai: "easy68k binary to bcd"
        movem.l d0-d2, -(a7)
        add.l   d1, a0
        addq.l  #1, a0
        subq.l  #1, d1
.loop:
        divu.w  #10, d0
        move.l  d0, d2
        swap    d2
        move.b  d2, -(a0)
        and.l   #$ffff, d0
        dbra    d1, .loop
        ; move.b  d0, -(a0)
        movem.l (a7)+, d0-d2
        rts
