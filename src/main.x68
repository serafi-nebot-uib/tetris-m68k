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

start:
; --- tests --------------------------------------------------------------------
        jsr     sysinit

        move.l  #0, d0                          ; piece number
        jsr     pieceinit
        jsr     boardplot
        trap    #SCR_TRAP

        move.l  #BOARD_HEIGHT-5, d0
        move.l  #5, d1
        jsr     boardchkfill

;         ; ----- clear rows -----------
;
;         ; a0.l -> tile clear pattern
;         lea.l   piece_ptrn0, a0
;         move.l  #BOARD_BASE_Y, d6
;         add.l   d0, d6
;         add.l   d1, d6
;
;         subq.l  #1, d1                          ; iteration counter (row count)
; .clrloop:
;         subq.l  #1, d6
;         dbra.w  d1, .clrloop

        simhalt



; --- initialization -----------------------------------------------------------
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
.sync:
        move.b  (SNC_PLOT), d0
        beq     .sync

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
        move.b  #0, (SNC_PLOT)
        jsr     pieceplot

; --- plot ---------------------------------------------------------------------
        trap    #SCR_TRAP

        bra     .loop

        ; halt simulator
        move.b  #9, d0
        trap    #15

        end     start
