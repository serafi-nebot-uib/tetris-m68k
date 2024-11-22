        opt     mex
        org     $1000

        include "const.x68"
        include "sysconst.x68"
        include "vars.x68"
        include "sysvars.x68"
        include "system.x68"

        include "bg/home.x68"
        include "bg/mode.x68"
        include "bg/score.x68"
        include "bg/game.x68"
        include "tile-table.x68"
        include "tile.x68"

start:
; --- initialization -----------------------------------------------------------
        jsr     sysinit

; TODO: remove this (for testing)
        lea.l   bggame, a0
        jsr     drawmap
        trap    #SCR_TRAP

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
