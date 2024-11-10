        org     $1000

        include 'board.x68'
        include 'piece.x68'
        include 'tiles.x68'
        include 'background.x68'


TILESIZE: equ   16
TILELEN: equ    TILESIZE*TILESIZE
SCRWIDTH: equ   640
SCRHEIGHT: equ  480

tileplot:
; d0 -> tile index
; d3 -> tile x coord
; d4 -> tile y coord
        movem.l d0-d7/a0, -(a7)

        lea.l   tiles, a0
        ; TODO: optimize mulu
        lsl.l   #8, d0
        lsl.l   #2, d0                          ; multiply by 4
        add.l   d0, a0
        lsl.l   #4, d3
        lsl.l   #4, d4

        move.l  d3, d7
        move.w  #TILESIZE-1, d5
        move.w  #TILESIZE-1, d6
.draw:
        move.b  #80, d0
        move.l  (a0)+, d1                       ; pixel color
        trap    #15

        move.b  #82, d0
        move.l  d3, d1
        move.l  d4, d2
        trap    #15

        addq.w  #1, d3
        dbra.w  d5, .draw
        move.l  d7, d3                          ; restore x index to start
        move.w  #TILESIZE-1, d5
        addq.w  #1, d4
        dbra.w  d6, .draw

        movem.l (a7)+, d0-d7/a0
        rts

start:
        ; move.l  #17, d0
        ; moveq.l #1, d3
        ; moveq.l #0, d4
        ; jsr     tileplot
        ; simhalt

        lea.l   background, a0
.loop:
        move.b  (a0)+, d0
        cmp.b   #$ff, d0
        beq     .skip
        jsr     tileplot
.skip:
        addq.l  #1, d3
        cmp     #SCRWIDTH/TILESIZE, d3
        blo     .loop
        moveq.l #0, d3

        addq.l  #1, d4
        cmp     #SCRHEIGHT/TILESIZE, d4
        blo     .loop

        ; move.l  #17, d0
        ; moveq.l #0, d3
        ; moveq.l #0, d4
        ; jsr     tileplot

        ; jsr     piececoll
        ;
        ; move.w  #1<<8|1, d0                     ; x << 8 | y
        ; lea.l   pieceT, a0
        ; jsr     pieceinit
        ;
        ; jsr     pieceplot
        ;
        ; move.l  d0, d1

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
