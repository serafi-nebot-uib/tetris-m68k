GAME_STATE: ds.l 1

screen_game:
; --- init ---------------------------------------------------------------------
        ; draw screen background
        jsr     scrclr
        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        jsr     scrplot

        move.b  #-1, (piecenum)
        move.l  #game_spawn, (GAME_STATE)
.loop:
; --- update -------------------------------------------------------------------
        jsr     kbdupd                          ; update keyboard values
        move.l  (GAME_STATE), a0
        jsr     (a0)
; --- sync ---------------------------------------------------------------------
.sync:
        move.b  (SNC_PLOT), d0
        beq     .sync
        move.b  #0, (SNC_PLOT)

; --- plot ---------------------------------------------------------------------
        jsr     scrplot
        bra     .loop

        rts

game_spawn:
        move.l  d0, -(a7)

        ; TODO: get next piece by number generator
        moveq.l #0, d0
        move.b  (piecenum), d0
        addq.l  #1, d0
        divu    #7, d0
        swap    d0
        andi.l  #$ffff, d0
        ;-----------------------------------------------------------------------

        jsr     pieceinit
        move.l  #game_player, (GAME_STATE)

        move.l  (a7)+, d0
        rts

game_player:
        movem.l d0-d1, -(a7)
        ; check if piece should be moved down
        move.l  (SNC_CNT_DOWN), d0
        bgt     .upd
        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN)
        piecemovd #1
        bra     .chkcol
.upd:
        move.b  (KBD_EDGE), d0
        move.b  (KBD_VAL), d1
.chkdown:
        btst    #3, d0
        beq     .chkleft
        piecemovd #1
        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN)
        bra     .chkcol
.chkleft:
        btst    #0, d0
        beq     .chkright
        piecemovl #1
        bra     .chkcol
.chkright:
        btst    #2, d0
        beq     .chkup
        piecemovr #1
        bra     .chkcol
.chkup:
        btst    #1, d0
        beq     .chkspbar
        jsr     piecerotr
        bra     .chkcol
.chkspbar:
        btst    #4, d0
        beq     .chkesc
        move.l  #game_drop, (GAME_STATE)
        bra     .done
.chkesc:
        btst    #5, d0
        beq     .chkenter
        move.l  #game_pause, (GAME_STATE)
        bra     .done

; -----------------------------
; TODO: remove this as it is only for testing
.chkenter:
        btst    #7, d0
        beq     .chkctrl
        moveq.l #0, d1
        move.b  (levelnum), d1
        addq.b  #1, d1
        divu    #9, d1
        swap    d1
        move.b  d1, (levelnum)

        ; update piece color & pattern
        moveq.l #0, d0
        moveq.l #0, d1
        move.l  (piece+4), a0
        move.w  -2(a0), d0
        move.b  d0, d1
        lsr.l   #8, d0
        jsr     boardplot
        bra     .done
.chkctrl:
        btst    #6, d0
        beq     .done
        move.l  #game_spawn, (GAME_STATE)
        bra     .done
; -----------------------------

.chkcol:
        jsr     piececoll
        cmp.b   #0, d0
        bne     .rollback
        jsr     piececlr
        jsr     pieceplot
        piececommit
        bra     .done
.rollback:
        piecerollback
.done:
        movem.l (a7)+, d0-d1
        rts

game_drop:
        move.l  d0, -(a7)
        ; move the piece down until a collision is found
.drop:
        piecemovd #1
        jsr     piececoll
        tst.b   d0
        beq     .drop
        piecemovu #1
        ; release piece to the board
        jsr     piecerelease
        jsr     boardplot
        move.l  #game_clr_rows, (GAME_STATE)
        move.l  (a7)+, d0
        rts

game_clr_rows:
        movem.l d0-d2/d4, -(a7)
        ; d0.l -> piece y coord
        moveq.l #0, d0
        move.b  (piece+1), d0

        ; d1.l -> piece height (capped so that: y coord + height < BOARD_HEIGHT)
        moveq.l #0, d1
        move.w  (piece+2), d1
        pdim    d1, d1
        andi.w  #$00ff, d1
        move.l  d1, d2
        add.l   d0, d2
        sub.l   #BOARD_HEIGHT, d2
        ble     .chkfill
        sub.l   d2, d1
.chkfill:
        jsr     boardchkfill
        tst.l   d4
        beq     .done
        jsr     boarddropdown

        ; row clear animation
        move.l  d4, -(a7)
        lsl.l   #8, d0
        move.b  d1, d0
        move.w  d0, -(a7)
        move.w  #1, -(a7)

        move.w  #BOARD_WIDTH/2-1, d0
        move.b  #0, (SNC_PLOT)
.clr:
        jsr     boardclrfill
        add.w   #1, (a7)
.sync:
        cmp.b   #8, (SNC_PLOT)
        blo     .sync
        jsr     scrplot
        move.b  #0, (SNC_PLOT)

        dbra.w  d0, .clr
        addq.l  #8, a7
.done:
        move.l  #game_spawn, (GAME_STATE)
        movem.l (a7)+, d0-d2/d4
        rts

game_pause:
        movem.l d1-d2/d5-d6, -(a7)

        sncdisable
        jsr     boardclr
        move.l  #$00ffff00, d1
        move.w  #BOARD_BASE_X+2, d5
        move.w  #BOARD_BASE_Y+(BOARD_HEIGHT/2)-1, d6
        lea.l   .pause_str, a1
        jsr     drawstrcol
        jsr     scrplot
.chk:
        jsr     kbdupd
        btst    #5, (KBD_EDGE)
        beq     .chk
.done:
        jsr     boardplot
        jsr     pieceplot
        jsr     scrplot
        move.l  #game_player, (GAME_STATE)
        sncenable

        movem.l (a7)+, d1-d2/d5-d6
        rts
.pause_str:
        dc.b    'PAUSED',0
        ds.w    0

game_stats:
        rts

game_over:
        rts
