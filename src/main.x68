        opt     mex
        org     $1000

        include 'sysconst.x68'
        include 'sysvars.x68'
        include 'const.x68'
        include 'vars.x68'
        include 'system.x68'

        ifeq    GLB_SCALE-GLB_SCALE_SMALL
        include 'tile-table-16.x68'
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
        include 'tile-table-32.x68'
        endc

        include 'bg/home.x68'
        include 'bg/mode.x68'
        include 'bg/game.x68'
        include 'bg/score.x68'

        include 'tile.x68'
        include 'piece.x68'
        include 'board.x68'
        include 'game.x68'

start:
; --- initialization -----------------------------------------------------------
        jsr     sysinit
        jsr     game

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
