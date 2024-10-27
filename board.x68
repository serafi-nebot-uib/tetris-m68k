PWIDTH: equ     4
PHEIGHT: equ    2
PSIZE:  equ     PWIDTH*PHEIGHT

BOARDWIDTH: equ 10
BOARDHEIGHT: equ 20

piece:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.b    1                               ; rx (rotate x index)
        ds.b    1                               ; ry (rotate y index)
        dc.l    hmat                            ; current matrix
        dc.l    vmat                            ; previous matrix

; current matrix data
        dc.b    PWIDTH                          ; number of columns
        dc.b    PHEIGHT                         ; number of rows
hmat:
        ds.b    PSIZE                           ; current matrix
        ds.w    0                               ; align

; previous matrix data
        dc.b    PHEIGHT                         ; number of columns 
        dc.b    PWIDTH                          ; number of rows
vmat:
        ds.b    PSIZE                           ; previous matrix
        ds.w    0                               ; align

board:
        ; ds.b    BOARDWIDTH*BOARDHEIGHT
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

piecefwd:
; cycle piece forward (rotate right)
        move.l  a0, -(a7)

        ; reverse last matrix
        move.l  (piece+8), -(a7)                ; push current matrix address
        move.w  #PSIZE, -(a7)                   ; push matrix size
        jsr     arrrev                          ; reverse array
        addq.l  #6, a7                          ; remove arguments from stack

        ; swap current & last matrices
        move.l  (piece+4), a0
        move.l  (piece+8), (piece+4)
        move.l  a0, (piece+8)

        movem.l (a7)+, a0
        rts

piecebak:
; cycle piece backward (rotate left)
        move.l  a0, -(a7)

        ; reverse last matrix
        move.l  (piece+4), -(a7)                ; push current matrix address
        move.w  #PSIZE, -(a7)                   ; push matrix size
        jsr     arrrev                          ; reverse array
        addq.l  #6, a7                          ; remove arguments from stack

        ; swap current & last matrices
        move.l  (piece+4), a0
        move.l  (piece+8), (piece+4)
        move.l  a0, (piece+8)

        movem.l (a7)+, a0
        rts

pieceinit:
; arguments:
;       sp+0 (x pos)
;       sp+1 (y pos)
;       sp+2 (rx idx)
;       sp+3 (ry idx)
;       sp+4 - sp+7 (src piece matrix address)
;---------------------------------------------
; d0: loop counter [0..PSIZE-1]
; d1: src piece matrix offset for vmat
; d2: temporary calculations
; d3: current piece matrix cell value (a0+d0)
; a0: src piece matrix address
        movem.l d0-d3/a0-a3, -(a7)              ; (4 + 4) * 4 = 32
.base:  equ     36                              ; 32 + 4 (PC) =  36

        move.l  .base+0(a7), (piece)            ; copy x, y, rx, ry
        move.l  .base+4(a7), a0                 ; load address of current matrix
        lea.l   hmat, a2
        lea.l   vmat, a3
        clr.l   d0
        clr.l   d1
.hmatcpy:
        ; copy matrix data to hmat
        move.b  (a0)+, d3
        move.b  d3, (a2)+

        ; copy matrix data to vmat
        ; hmat -> vmat:
        ;       vmat[((size) - 1) - ((i % width) * height) - int(i < width)] = hmat[i]
        ; NOTE: magic formula works for 4x2, not tested for other dimensions
        ; TODO: this whole calculation can probably be optimised
        move.w  d0, d1
        divu    #PWIDTH, d1
        move.l  #16, d2
        lsr.l   d2, d1                          ; calculate the remainder
        mulu.w  #-PHEIGHT, d1
        add.w   #PSIZE-1, d1
        cmp.w   #PWIDTH, d0
        bge     .vmatcpy
        subq.w  #1, d1
.vmatcpy:
        ; clear higher word from possible calculation overflow
        andi.l  #$0000ffff, d1
        move.b  d3, (a3,d1)

        addq.w  #1, d0
        cmp.w   #PSIZE, d0
        blt     .hmatcpy

        movem.l (a7)+, d0-d3/a0-a3
        rts

boardcol:
; --- COLLISION DETECTION ------------------------------------------------------
; arguments:
;    sp+0: reserved space for result
        movem.l d0-d4/a0-a2, -(a7)              ; (5+3) * 4 = 32
.base   equ     36                              ; 32 + 4 (PC) = 36

        lea.l   piece, a0                       ; piece address
        move.l  4(a0), a1                       ; current matrix address
        lea.l   board, a2                       ; board matrix address

        clr.w   d0
        clr.w   d1
        clr.w   d2
        clr.w   d3
        move.b  -2(a1), d3                      ; piece width
.loop:
        ; check block bounds
        ; idx = x + y*width
        move.b  d1, d2                          ; y
        mulu    d3, d2                          ; y * width
        add.b   d0, d2                          ; y * width + x
        move.b  (a1,d2), d4                     ; get current piece block
        ; if current piece block is empty there's nothing else to check
        beq     .nitr
        ; check if current piece position is out of board bounds (for x & y)
.chkx:
        move.b  d0, d2                          ; x idx
        add.b   (a0), d2                        ; x idx + x piece coordinate
        bmi     .collision                      ; is current x < 0?
        cmp.b   #BOARDWIDTH, d2                 ; is current x > board width?
        bge     .collision
.chky:
        move.b  d1, d2                          ; y idx
        add.b   1(a0), d2                       ; y idx + y piece coordinate
        bmi     .collision                      ; is current y < 0?
        cmp.b   #BOARDHEIGHT, d2                ; is current y > board height?
        bge     .collision
        ; check block collision
        ; idx = x + piece x + (y + piece y)*width
        move.b  d1, d2                          ; y
        add.b   1(a0), d2                       ; y + piece y
        mulu    #BOARDWIDTH, d2                 ; (y + piece y) * width
        add.b   d0, d2                          ; (y + piece y) * width + x
        add.b   (a0), d2                        ; (y + piece y) * width + x + piece x
        move.b  (a2,d2), d2                     ; get current piece block
        and.b   d2, d4                          ; check if both are 1
        bne     .collision
.nitr:
        addq.b  #1, d0                          ; increment x index
        cmp.b   d3, d0                          ; compare with piece width
        blo     .loop
        clr.b   d0                              ; reset x index
        addq.b  #1, d1                          ; increment y index
        cmp.b   -1(a1), d1                      ; compare with piece height
        blo     .loop
        move.w  #0, .base+0(a7)                 ; store result
        bra     .done
.collision:
        move.w  #1, .base+0(a7)                 ; store result
.done:
        movem.l (a7)+, d0-d4/a0-a2
        rts
