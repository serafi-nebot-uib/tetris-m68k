        opt     mex
        org     $1000

        include 'sysconst.x68'
        include 'sysvars.x68'
        include 'const.x68'
        include 'vars.x68'
        include 'system.x68'
        include 'util.x68'

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
        include 'screens.x68'
        include 'game.x68'

screens:
        dc.l    screen_legal
        dc.l    screen_start
        dc.l    screen_2
        dc.l    screen_level
        dc.l    screen_game
;         dc.l    screen4
;         dc.l    screen5

start:
; --- initialization -----------------------------------------------------------
        jsr     sysinit

        move.b  #0, (SCR_NUM)
.loop:
        moveq.l #0, d1
        move.b  (SCR_NUM), d1
        lsl.w   #2, d1
        lea.l   screens, a0
        movea.l (a0,d1.w), a1
        jsr     (a1)
        bra     .loop

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
