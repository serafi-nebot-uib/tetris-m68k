        org     $1000

        include 'board.x68'
        include 'piece.x68'
        include 'tile-table.x68'
        include 'bg-home.x68'
        include 'bg-mode.x68'
        include 'bg-score.x68'
        include 'bg-game.x68'
        include 'tile.x68'

; TODO: move constants to dedicated file
TILESIZE: equ   16
TILELEN: equ    TILESIZE*TILESIZE
SCRWIDTH: equ   640
SCRHEIGHT: equ  480

txttest: dc.b   'This is Tetris M68K',0
        ds.l    0

start:
        ; draw text
        lea.l   txttest, a0                     ; string address
        moveq.l #0, d1                          ; x coordinate
        moveq.l #0, d2                          ; y coordinate
        jsr     drawstr

        ; draw text with color
        lea.l   txttest, a0                     ; string address
        moveq.l #0, d1                          ; x coordinate
        moveq.l #1, d2                          ; y coordinate
        move.l  #$000000ff, d3
        jsr     drawstrcol

        lea.l   txttest, a0                     ; string address
        moveq.l #0, d1                          ; x coordinate
        moveq.l #2, d2                          ; y coordinate
        move.l  #$0000ff00, d3
        jsr     drawstrcol

        lea.l   txttest, a0                     ; string address
        moveq.l #0, d1                          ; x coordinate
        moveq.l #3, d2                          ; y coordinate
        move.l  #$00ff0000, d3
        jsr     drawstrcol
        simhalt

        ; draw all screens
        lea.l   bghome, a0
        jsr     drawmap
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        lea.l   bgmode, a0
        jsr     drawmap
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        lea.l   bgscore, a0
        jsr     drawmap
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        lea.l   bggame, a0
        jsr     drawmap
        simhalt

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
