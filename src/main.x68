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
        include 'screens.x68'
        include 'game.x68'

screens:
        ; test
        dc.l    screen_game

        dc.l    screen_legal
        dc.l    screen_start
        dc.l    screen_2
        dc.l    screen_level
        dc.l    screen_game
;         dc.l    screen4
;         dc.l    screen5

start:
        ; draw bg
        moveq.l #0, d5
        moveq.l #0, d6
        lea.l   bggame, a1
        jsr     drawmap

        moveq.l #0, d0
        jsr     pieceinit

        moveq.l #6, d7
.plotloop:
        moveq.l #4, d2
        moveq.l #2, d3
        move.l  #28, d5
        move.l  #15, d6

        ; moveq.l #0, d0
        move.l  d7, d0
        lsl.l   #2, d0
        move.l  (piece_ptrn), a0
        lea.l   piece_table, a1
        move.l  (a1,d0), a1
        add.b   (a1)+, d5
        addq.l  #1, a1
        ; add.b   (a1)+, d6

        jsr     piecematplot

        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #28<<TILE_SHIFT, d1
        move.w  #15<<TILE_SHIFT, d2
        move.w  #(28+4)<<TILE_SHIFT-1, d3
        move.w  #(15+2)<<TILE_SHIFT-1, d4
        trap    #15

        dbra    d7, .plotloop

        simhalt

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
