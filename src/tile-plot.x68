; TODO: what the hell are these constants?
PIXELSIZE equ   TILE_SIZE*14/100
CONTOURSIZE equ 1


COLOR0  equ     $00000000                       ; black (border)
COLOR1  equ     $000038f8                       ; red
COLOR2  equ     $00ffffff                       ; white

pattern1:
        dc.b    0, TILE_SIZE
        dc.b    0, TILE_SIZE-2*PIXELSIZE+CONTOURSIZE
        dc.b    CONTOURSIZE, 2*PIXELSIZE+3*CONTOURSIZE
        dc.b    0, CONTOURSIZE
        dc.b    PIXELSIZE+2*CONTOURSIZE, 2*PIXELSIZE+3*CONTOURSIZE
        ds.w    0

pattern2:
        dc.b    0, TILE_SIZE
        dc.b    0, TILE_SIZE-PIXELSIZE
        dc.b    0, PIXELSIZE
        dc.b    PIXELSIZE+CONTOURSIZE, TILE_SIZE-2*PIXELSIZE
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
; input    : d0 (posx), d1 (posy) 
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        movem.l d0-d7/a0-a2, -(a7) 

        move.l  d0, d5
        move.l  d1, d6
        lea     tilecol1, a0
        lea     pattern1, a1
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

        move.b  (a1), d1                        ; set coordinates
        add.w   d5, d1
        move.b  (a1)+, d2
        add.w   d6, d2

        move.b  (a1), d3
        add.w   d5, d3
        move.b  (a1)+, d4
        add.w   d6, d4

        moveq   #87, d0                         ; draw rectangle
        trap    #15

        dbra    d7, .loop  

        movem.l (a7)+, d0-d7/a0-a2
        rts

tileplot2:
; plot pattern2 tile
; input    : d0 (posx), d1 (posy), d2 (color) 
; output   : none
; modifies : none
; ------------------------------------------------------------------------------     

        movem.l d0-d7/a0-a1, -(a7)
            
        move.l  d0, d5
        move.l  d1, d6
        lea     tilecol2, a0
        lea     pattern2, a1
        clrreg

        moveq   #3, d7
.loop:
        move.l  (a0)+, d1

        moveq   #80, d0                         ; set contour color
        trap    #15
        moveq   #81, d0                         ; set fill color
        trap    #15

        clrreg

        move.b  (a1), d1                        ; set coordinates
        add.w   d5, d1
        move.b  (a1)+, d2
        add.w   d6, d2

        move.b  (a1), d3
        add.w   d5, d3
        move.b  (a1)+, d4
        add.w   d6, d4

        moveq   #87, d0                         ; draw rectangle
        trap    #15

        dbra    d7, .loop

        movem.l (a7)+, d0-d7/a0-a1
        rts
