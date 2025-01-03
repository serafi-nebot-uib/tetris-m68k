        opt     mex

; NOTE: tile table data is declared at the very beginning of the code, so that
; any included file can use its label, but stored at a higher address to avoid
; overwriting code when loading data
; TODO: check if loaded data exceeds maximum permitted size
        org     $20000
tileaddr: ds.l  1
tiletable:

        org     $1000

        include 'sysconst.x68'
        include 'sysvars.x68'
        include 'const.x68'
        include 'vars.x68'
        include 'system.x68'
        include 'util.x68'
        include 'tile.x68'
        include 'piece.x68'
        include 'board.x68'
        include 'screens.x68'
        include 'game.x68'
        include 'network.x68'

        include 'bg/home.x68'
        include 'bg/mode.x68'
        include 'bg/game.x68'
        include 'bg/type-a.x68'
        include 'bg/type-b.x68'
        include 'bg/score-b.x68'
        include 'bg/congratulations-a.x68'

start:
; --- initialization -----------------------------------------------------------
        jsr     sysinit
        jsr     tileinit

        move.l  #1234, d0
        move.b  #0, d3
        moveq.l #5, d4
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawnum
        jsr     scrplot
        simhalt

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
