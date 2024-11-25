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

; --- initialization -----------------------------------------------------------
        jsr     sysinit

        lea.l   bggame, a1
        jsr     drawmap
        move.l  #5<<8|0, d0
        lea.l   pieceT, a0
        jsr     pieceinit

.loop:
; --- update -------------------------------------------------------------------
        trap    #KBD_TRAP                       ; update keyboard values
        jsr     piececlr
        jsr     pieceupd
        jsr     pieceplot

; --- sync ---------------------------------------------------------------------
; TODO: implement sync

; --- plot ---------------------------------------------------------------------
        trap    #SCR_TRAP

        bra     .loop

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
