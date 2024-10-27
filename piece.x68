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
        dc.b    $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
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

pieceinit:
; len(d0-d3/a0-a1) = 6 * 4 + len(PC) = 4 -> 28 bytes
.base:  equ     28
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
        movem.l d0-d3/a0-a1, -(a7)

        move.l  .base+0(a7), (piece)
        move.l  .base+4(a7), a0
        move.l  a0, a1
        lea.l   hmat, a2
        clr.l   d0
        clr.l   d1
.hmatcpy:
        ; copy matrix data to hmat
        move.b  (a0)+, d3
        move.b  d3, (a2)+

        ; TODO: does this work with other matrix dimensions?
        ; TODO: this whole calculation can probably be optimised
        ; copy matrix data to vmat
        ; hmat -> vmat:
        ;       vmat[((size) - 1) - ((i % width) * height) - int(i < width)] = hmat[i]
        ; NOTE: magic formula works for 4x2, does it work for other dimensions?
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
        ; TODO: indexed mode possible? to avoid loading a3 everytime
        lea.l   vmat, a3
        ; clear higher word from possible calculation overflow
        andi.l  #$0000ffff, d1
        add.l   d1, a3
        move.b  d3, (a3)

        addq.w  #1, d0
        cmp.w   #PSIZE, d0
        blt     .hmatcpy

        movem.l (a7)+, d0-d3/a0-a1
        rts
