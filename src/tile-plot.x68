COLOR0  equ     $00000000                       ; black (border)
COLOR1  equ     $000038f8                       ; red
COLOR2  equ     $00ffffff                       ; white
CONTOUR_SIZE equ 2

piece_pattern1:
        dc.b    0, TILE_SIZE                    ; black background
        dc.b    0, TILE_SIZE-CONTOUR_SIZE       ; main block
        dc.b    0, CONTOUR_SIZE                 ; small accent
        dc.b    CONTOUR_SIZE, CONTOUR_SIZE+CONTOUR_SIZE*2 ; big accent
        dc.b    CONTOUR_SIZE+CONTOUR_SIZE*2/2, CONTOUR_SIZE+CONTOUR_SIZE*2 ; remove big portion of accent
        ds.w    0


piece_pattern2:
        dc.b    0, TILE_SIZE                    ; black background
        dc.b    0, TILE_SIZE-CONTOUR_SIZE       ; main block
        dc.b    0, CONTOUR_SIZE                 ; small accent
        dc.b    CONTOUR_SIZE, TILE_SIZE-CONTOUR_SIZE*2 ; big accent
        ds.w    0

contourcol1: dc.l COLOR0, COLOR1, COLOR1, COLOR2, COLOR1 ;DEFAULT COLORS OF PATTERN1  
tilecol1: dc.l  COLOR0, COLOR1, COLOR2, COLOR2, COLOR1 ;DEFAULT COLORS OF PATTERN1
tilecol2: dc.l  COLOR0, COLOR1, COLOR2, COLOR2  ;DEFAULT COLORS OF PATTERN2

clrreg  macro
        moveq.l #0, d0
        moveq.l #0, d1
        moveq.l #0, d2
        moveq.l #0, d3
        moveq.l #0, d4
        endm

tileplotinit:
; updates the appropiate color of the tiles when a new piece is selected
; input    : d2 (color)
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        ;init this move.l sequence when starting a new level
        ;using the color associated with the level
        move.l  d2, tilecol2+$4
        move.l  d2, tilecol1+$4
        move.l  d2, tilecol1+$10

        ;if piece is T,O,I this is not needed:
        move.l  d2, contourcol1+$4
        move.l  d2, contourcol1+$10
        move.l  d2, contourcol1+$8

        rts

tileplot1:
; plot pattern1 tile
; input    : d0 (x coord), d1 (y coord)
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        movem.l d0-d7/a0-a2, -(a7) 

        ; TODO: change input to d5,d6 to avoid extra moves
        move.l  d0, d5
        move.l  d1, d6
        ; multiply coordinates by tile size to get actual x/y positions
        lsl.l   #4, d5
        lsl.l   #4, d6

        lea     tilecol1, a0
        lea     piece_pattern1, a1
        lea     contourcol1, a2
        clrreg

        moveq   #4, d7
.loop:
        move.l  (a2)+, d1
        moveq   #80, d0                         ; set contour color
        trap    #15

        move.l  (a0)+, d1
        moveq   #81, d0                         ; set fill color
        trap    #15

        clrreg
        ; set coordinates
        move.b  (a1), d1
        add.w   d5, d1                          ; start x
        move.b  (a1)+, d2
        add.w   d6, d2                          ; start y

        move.b  (a1), d3
        add.w   d5, d3                          ; end x
        move.b  (a1)+, d4
        add.w   d6, d4                          ; end y

        ; draw rectangle
        moveq   #87, d0
        trap    #15

        dbra    d7, .loop

        movem.l (a7)+, d0-d7/a0-a2
        rts

tileplot2:
; plot pattern2 tile
; input    : d0 (x coord), d1 (y coord)
; output   : none
; modifies : none
; ------------------------------------------------------------------------------     

        movem.l d0-d7/a0-a1, -(a7)

        ; TODO: change input to d5,d6 to avoid extra moves
        move.l  d0, d5
        move.l  d1, d6
        ; multiply coordinates by tile size to get actual x/y positions
        lsl.l   #4, d5
        lsl.l   #4, d6

        lea     tilecol2, a0
        lea     piece_pattern2, a1
        clrreg

        moveq   #3, d7
.loop:
        ; set rectangle color
        move.l  (a0)+, d1
        moveq   #80, d0                         ; set contour color
        trap    #15
        moveq   #81, d0                         ; set fill color
        trap    #15

        clrreg
        ; set coordinates
        move.b  (a1), d1
        add.w   d5, d1                          ; start x
        move.b  (a1)+, d2
        add.w   d6, d2                          ; start y

        move.b  (a1), d3
        add.w   d5, d3                          ; end x
        move.b  (a1)+, d4
        add.w   d6, d4                          ; end y

        ; draw rectangle
        moveq   #87, d0
        trap    #15

        dbra    d7, .loop

        movem.l (a7)+, d0-d7/a0-a1
        rts
