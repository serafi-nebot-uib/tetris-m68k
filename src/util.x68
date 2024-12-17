; convert number to bcd
;
; input    : d0.l - number to convert
;            d1.l - target digit array size
;            a0.l - target digit array address
; output   :
; modifies :
bcd:
        ; code sourced from perplexity.ai: "easy68k binary to bcd"
        movem.l d0-d2, -(a7)
        subq.l  #1, d1
.loop:
        divu.w  #10, d0
        move.l  d0, d2
        swap    d2
        move.b  d2, (a0,d1)
        and.l   #$ffff, d0
        dbra    d1, .loop
        movem.l (a7)+, d0-d2
        rts
