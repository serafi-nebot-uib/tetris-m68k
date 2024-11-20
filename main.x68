        org     $1000

        include 'board.x68'
        include 'piece.x68'
        include 'tile-table.x68'
        include 'bg-home.x68'
        include 'bg-game.x68'
        include 'bg-score.x68'
        include 'tile.x68'

; TODO: move constants to dedicated file
TILESIZE: equ   16
TILELEN: equ    TILESIZE*TILESIZE
SCRWIDTH: equ   640
SCRHEIGHT: equ  480

start:
        lea.l   bgscore, a0
        jsr     drawmap

        move.b  #21, d0
        move.l  #$00ffffff, d1
        move.l  #$071b0001, d2
        trap    #15

        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15

        move.b  #11, d0
        move.w  #$0b08, d1
        trap    #15

        lea.l   .lvltext, a1
        move.b  #14, d0
        trap    #15

.lvltext: dc.b  'LEVEL',0

; --- collisions ---------------------------------------------------------------
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

        end     start
