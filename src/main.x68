        opt     mex
        org     $1000

        include 'const.x68'
        include 'sysconst.x68'
        include 'vars.x68'
        include 'sysvars.x68'
        include 'system.x68'

        include 'bg/game-32.x68'
        include 'tile-table-32.x68'
        include 'tile.x68'

        include 'piece.x68'
        include 'board.x68'

start:
; --- initialization -----------------------------------------------------------
        jsr     sysinit

        lea.l   game32, a1
        jsr     drawmap
        move.l  #5<<8|0, d0
        move.l  #0, d1
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
