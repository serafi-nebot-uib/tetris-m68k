        opt     mex
        org     $1000

        include 'sysconst.x68'
        include 'sysvars.x68'
        include 'const.x68'
        include 'vars.x68'
        include 'system.x68'

        ifeq    GLB_SCALE-GLB_SCALE_SMALL
        include 'bg/game-16.x68'
        include 'bg/home-16.x68'
        include 'bg/mode-16.x68'
        include 'bg/score-16.x68'
        include 'tile-table-16.x68'
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
        include 'bg/game-32.x68'
        ; include 'bg/home-16.x68'
        ; include 'bg/mode-16.x68'
        ; include 'bg/score-16.x68'
        include 'tile-table-32.x68'
        endc

        include 'tile.x68'
        include 'piece.x68'
        include 'board.x68'

start:
; --- initialization -----------------------------------------------------------
        ori.w   #$0700, sr                      ; disable interrupts
        jsr     sysinit

        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        move.l  #0, d0                          ; piece number
        jsr     pieceinit

        move.b  #SNC_PIECE_TIME, (SNC_PIECE)
.loop:
; --- update -------------------------------------------------------------------
        trap    #KBD_TRAP                       ; update keyboard values
        jsr     piececlr
        jsr     pieceupd

; --- sync ---------------------------------------------------------------------
        move.b  (SNC_PIECE), d0
        bgt     .plot
        piecemovd #1
        jsr     piececoll
        cmp.b   #0, d0
        bne     .collision
        piececommit
        move.b  #SNC_PIECE_TIME, (SNC_PIECE)
        bra     .plot
.collision:
        piecerollback
.plot:
        jsr     pieceplot

; --- plot ---------------------------------------------------------------------
        trap    #SCR_TRAP

        bra     .loop

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
