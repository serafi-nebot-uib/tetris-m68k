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

PRNG32: ds.l    1                               ; random number store
PRNBUFFER: ds.l 6
PIECEBUFFER: dc.b 1 
        ds.w    0

; 32 bit prng, uses Galois LFSR feedback method
; original code is from ehbasic68k interpreter by Lee Davison
; http://www.6502.org/users/mycorner/68k/prng/index.html
;
; input    :
; output   : PRNG32
; modifies : d0, d1, d2
randgen:
        moveq.l #18, d2
.ninc0:
        add.l   d0, d0                          ; shift left 1 bit
        bcc.s   .ninc1                          ; branch if bit 32 not set
        eor.b   d1, d0                          ; do Galois LFSR feedback
.ninc1:
        dbf     d2, .ninc0
        move.l  d0, PRNG32                      ; save back to seed word
        rts 

; TODO: move prn_piece to board.x68
; generates a pseudo random number between [0,6]
;
; input    :
; output   : d0 - piecenumber
; modifies :
prn_piece:
        movem.l d0/d2, -(a7)
        move.l  PRNG32, d0
        jsr     randgen
        andi.l  #$7fffffff, d0                  ; asseguram que el nombre és positiu
        mulu    #7, d0                          ; multiplicar per 7
        moveq.l #16, d2                         ; posicions de desplaçament
        lsr.l   d2, d0                          ; número entre 0 - 6
        move.b  d0, (PIECEBUFFER)               ; guarda el resultat
        movem.l (a7)+, d0/d2
        rts
