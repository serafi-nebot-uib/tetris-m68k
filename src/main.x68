        opt     mex
        org     $1000

        include 'const.x68'
        include 'sysconst.x68'
        include 'vars.x68'
        include 'sysvars.x68'
        include 'system.x68'

        include 'bg/home.x68'
        include 'bg/mode.x68'
        include 'bg/score.x68'
        include 'bg/game.x68'
        include 'tile-table.x68'
        include 'tile.x68'

        include 'piece.x68'
        include 'board.x68'

txttest: dc.b   'This is Tetris M68k',0
        ds.w    0

start:
        lea.l   bggame, a1
        jsr     drawmap
        move.l  #4<<8|4, d0
        lea.l   pieceI, a0
        jsr     pieceinit
        jsr     pieceplot
        jsr     piececlr
        jsr     piecerotr
        jsr     pieceplot
        simhalt
        ; lea.l   txttest, a1                     ; string address
        ; moveq.l #0, d5                          ; x coordinate
        ; moveq.l #0, d6                          ; y coordinate
        ; jsr     drawstr
        ;
        ; addq.l  #1, d6
        ; move.l  #$000000ff, d1
        ; jsr     drawstrcol
        ;
        ; addq.l  #1, d6
        ; move.l  #$0000ff00, d1
        ; jsr     drawstrcol
        ;
        ; addq.l  #1, d6
        ; move.l  #$00ff0000, d1
        ; jsr     drawstrcol
        ; simhalt

; --- initialization -----------------------------------------------------------
        ; jsr     sysinit

; TODO: remove this (for testing)
        ; ; versio drawtile
        ; move.l  #block1, -(a7)
        ; move.w  #0, -(a7)
        ; move.w  #0, -(a7)
        ; jsr     drawtile
        ; addq.l  #8, a7
        ;
        ; move.l  #block2, -(a7)
        ; move.w  #0, -(a7)
        ; move.w  #1, -(a7)
        ; jsr     drawtile
        ; addq.l  #8, a7
        ;
        ; trap    #SCR_TRAP
        ; simhalt
        ;
        ; ; versio jaume
        ; moveq.l #0, d0
        ; moveq.l #0, d1
        ; jsr     pieceplot1
        ; trap    #SCR_TRAP
        ; simhalt

        ; lea.l   bggame, a1
        ; jsr     drawmap
        ; trap    #SCR_TRAP

        simhalt

.loop:
; --- update -------------------------------------------------------------------
        trap    #KBD_TRAP                       ; update keyboard values

; --- sync ---------------------------------------------------------------------
; TODO: implement sync

; --- plot ---------------------------------------------------------------------
        trap    #SCR_TRAP

        bra     .loop

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
