game:
;         lea.l   bggame, a1
;         moveq.l #0, d5
;         moveq.l #0, d6
;         jsr     drawmap
;         move.l  #0, d0                          ; piece number
;         jsr     pieceinit
;         trap    #SCR_TRAP
;
;         move.l  #BOARD_HEIGHT-5, d0
;         move.l  #5, d1
;         jsr     boardchkfill
;
;         ; move.l  #%10101, d4
;         move.l  d4, -(a7)
;         move.w  #(BOARD_HEIGHT-5)<<8|5, -(a7)
;         move.w  #1, -(a7)
;
;         move.w  #5-1, d0
;         move.b  #0, (SNC_PLOT)
; .animation:
;         jsr     boardclrfill
;         add.w   #1, (a7)
; .async:
;         cmp.b   #4, (SNC_PLOT)
;         blo     .async
;         trap    #SCR_TRAP
;         move.b  #0, (SNC_PLOT)
;
;         dbra.w  d0, .animation
;         addq.l  #8, a7
;         rts

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
        rts
