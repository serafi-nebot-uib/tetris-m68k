PRNG16: dc.w    $8795                           ; initial seed
PRNG32: ds.l    1                               ; random number store
PRNBUFFER: ds.l 6
PIECEBUFFER: dc.b 1 
        ds.w    0

; convert number to bcd
;
; input    : d0.l - number to convert
;            d1.l - target digit array size
;            a0.l - target digit array address
; output   :
; modifies :
bcd:
        movem.l d0-d2, -(a7)
        subq.l  #1, d1
.loop:
        divu    #10, d0
        move.l  d0, d2
        swap    d2
        move.b  d2, (a0,d1)
        and.l   #$ffff, d0
        dbra    d1, .loop
        movem.l (a7)+, d0-d2
        rts

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

; generates a pseudo random number between [0,6]
;
; input    :
; output   : d0 - piecenumber
; modifies :
prn_piece:
        move.l  d2, -(a7)
        jsr     randgen2
        moveq.l #0, d0
        move.w  (prng16), d0
        andi.l  #$7fffffff, d0                  ; asseguram que el nombre és positiu
        mulu    #7, d0                          ; multiplicar per 7
        moveq.l #16, d2                         ; posicions de desplaÃÂ§ament
        lsr.l   d2, d0                          ; número entre 0 - 6
        move.b  d0, (PIECEBUFFER)               ; guarda el resultat
        move.l  (a7)+, d2
        rts

; 16 bit prng, LFSR Version 2
;
; input    :
; output   : PRNG16 - piecenumber
; modifies :
randgen2:
        movem.l d0-d2, -(a7)
        moveq.l #0, d0
        moveq.l #0, d1
        moveq.l #0, d2

        move.w  (PRNG16), d0
        move.w  d0, d1
        move.w  d0, d2

        andi.w  #$0200, d1                      ; Màscara del bit 9
        lsr.w   #8, d1                          ; DesplaÃ§a el bit 9 cap al bit 0

        andi.w  #$0002, d2                      ; Màscara del bit 1
        lsr.w   #1, d2                          ; Desplaça el bit 1 fins al bit 0

        eor.w   d2, d1                          ; X-OR entre els bits 9 i 1, el resultat es guarda a d1                  
        andi.w  #1, d1                          ; Asseguram que en d1 nomÃ©s quedi el bit resultant de la X-OR

        lsr.w   #1, d0                          ; desplaça un bit cap a la dreta, introdueix un 0 en el bit 15
        moveq.l #15, d2                         
        lsl.w   d2, d1                          ; prepara el bit de la X-OR al bit 15
        or.w    d1, d0                          
        move.w  d0, (prng16)                    ; emmagatzema el registre "scrambled" a PRNG16

        movem.l (a7)+, d0-d2
        rts
