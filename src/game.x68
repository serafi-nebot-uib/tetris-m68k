GAME_STATE: ds.l 1

screen_game:
; --- init ---------------------------------------------------------------------
        move.w  #0, (levelcnt)
        move.b  #0, (levelnum)
        move.w  #0, (linecount)
        move.w  #0, (score)
        ; clear piecestats
        lea.l   piecestats, a0
        moveq.l #6, d0
.piecestats:
        move.b  #0, (a0)+
        dbra    d0, .piecestats
        ; reset scoretable
        lea.l   scorevals, a0
        lea.l   scoretable, a1
        moveq.l #3, d0
.scoretable:
        move.w  (a0)+, (a1)+
        dbra    d0, .scoretable
        ; TODO: get values from RNG
        move.b  #0, (piecenum)
        move.b  #1, (piecenumn)
        ; -------------------------
        jsr     boarddropupd
        jsr     game_plot
        move.l  #game_spawn, (GAME_STATE)
.loop:
; --- update -------------------------------------------------------------------
        jsr     kbdupd
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

game_plot:
        movem.l d0-d2/d5-d6/a0, -(a7)
        ; draw screen background
        jsr     scrclr
        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        ; update statistics box
        move.w  #0, (levelcnt)
        move.b  #0, (levelnum)
        jsr     boardlvlupd

        moveq.l #0, d0
        moveq.l #6, d2
        lea.l   piecestats, a0
.statupd:
        move.l  d2, d1
        lsl.l   #1, d1
        move.b  #0, (a0,d1)
        jsr     boardstatupd
        dbra    d2, .statupd

        jsr     scrplot

        movem.l (a7)+, d0-d2/d5-d6/a0
        rts

game_spawn:
        movem.l d0/d2, -(a7)

        ; TODO: get next piece by number generator
        moveq.l #0, d0
        move.b  (piecenumn), d0
        addq.l  #1, d0
        divu    #7, d0
        swap    d0
        andi.l  #$ffff, d0
        ;-----------------------------------------------------------------------

        ; ; TODO: get next piece by number generator
        ; move.l  d0, d2
        ; addq.l  #1, d2
        ; divu    #7, d2
        ; swap    d2
        ; andi.l  #$ffff, d2
        ; ;-----------------------------------------------------------------------

        ; boardnextupd is called first so that the color profile for the
        ; current piece isn't changed
        jsr     boardnextupd
        jsr     pieceinit
        jsr     piececoll
        tst.b   d0
        bne     .collision
        move.l  #game_player, (GAME_STATE)
        move.l  (SNC_PIECE_TIME), (SNC_CNT_DOWN) ; reset piece sync counter
        bra     .done
.collision:
        move.l  #game_over, (GAME_STATE)
.done:
        movem.l (a7)+, d0/d2
        rts

game_player:
        movem.l d0-d1, -(a7)
        ; check if piece should be moved down
        move.l  (SNC_CNT_DOWN), d0
        bgt     .upd
        move.l  (SNC_PIECE_TIME), (SNC_CNT_DOWN)
        piecemovd #1
        jsr     piececoll
        cmp.b   #0, d0
        bne     .release
        jsr     piececlr
        jsr     pieceplot
        piececommit
        bra     .done
.release:
        piecerollback
        move.l  #game_drop, (GAME_STATE)
        bra     .done
.upd:
        move.b  (KBD_EDGE), d0
        move.b  (KBD_VAL), d1
.chkdown:
        btst    #KBD_DOWN_POS, d0
        beq     .chkleft
        piecemovd #1
        move.l  (SNC_PIECE_TIME), (SNC_CNT_DOWN)
        bra     .chkcol
.chkleft:
        btst    #KBD_LEFT_POS, d0
        beq     .chkright
        piecemovl #1
        bra     .chkcol
.chkright:
        btst    #KBD_RIGHT_POS, d0
        beq     .chkup
        piecemovr #1
        bra     .chkcol
.chkup:
        btst    #KBD_UP_POS, d0
        beq     .chkspbar
        jsr     piecerotr
        bra     .chkcol
.chkspbar:
        btst    #KBD_SPBAR_POS, d0
        beq     .chkesc
        move.l  #game_drop, (GAME_STATE)
        bra     .done
.chkesc:
        btst    #KBD_ESC_POS, d0
        beq     .chkenter
        move.l  #game_pause, (GAME_STATE)
        bra     .done

; -----------------------------
; TODO: remove this as it is only for testing
.chkenter:
        btst    #KBD_ENTER_POS, d0
        beq     .chkctrl
        move.l  #game_inc_level, (GAME_STATE)
        bra     .done
.chkctrl:
        btst    #KBD_CTRL_POS, d0
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
        movem.l d0-d2/a0, -(a7)
        ; move the piece down until a collision is found
.drop:
        piecemovd #1
        jsr     piececoll
        tst.b   d0
        beq     .drop
        piecemovu #1
        ; release piece to the board
        jsr     piecerelease
        ; increment stats for current piece
        moveq.l #0, d2
        move.b  (piecenum), d2
        move.l  d2, d1
        lsl.l   #1, d1
        lea.l   (piecestats), a0
        move.w  (a0,d1), d0
        addq.w  #1, d0
        move.w  d0, (a0,d1)
        jsr     boardstatupd

        jsr     boardplot
        move.l  #game_clr_rows, (GAME_STATE)
        movem.l (a7)+, d0-d2/a0
        rts

game_inc_level:
        move.l  d0, -(a7)
        ; increase current level
        moveq.l #0, d0
        move.b  (levelnum), d0
        addq.l  #1, d0
        divu    #10, d0
        swap    d0
        move.b  d0, (levelnum)
        add.w   #1, (levelcnt)

        ; update level box pieces
        jsr     boardlvlupd
        ; update drop rate
        jsr     boarddropupd
        ; increase score count
        jsr     boardscoreinc
        ; update next piece box
        moveq.l #0, d0
        move.b  (piecenumn), d0
        jsr     boardnextupd
        ; update board pieces
        jsr     boardplot
        jsr     pieceplot
        move.l  #game_player, (GAME_STATE)
        move.l  (a7)+, d0
        rts

game_clr_rows:
        movem.l d0-d2/d4, -(a7)
        ; d0.l -> piece y coord
        moveq.l #0, d0
        move.b  (piece+1), d0

        ; d1.l -> piece height (capped so that: y coord + height < BRD_HEIGHT)
        moveq.l #0, d1
        move.w  (piece+2), d1
        pdim    d1, d1
        andi.w  #$00ff, d1
        move.l  d1, d2
        add.l   d0, d2
        sub.l   #BRD_HEIGHT, d2
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

        move.w  #BRD_WIDTH/2-1, d0
        move.b  #0, (SNC_PLOT)

.clr:
        jsr     boardclrfill
        add.w   #1, (a7)
.sync:
        cmp.b   #4, (SNC_PLOT)
        blo     .sync
        jsr     scrplot
        move.b  #0, (SNC_PLOT)

        dbra.w  d0, .clr
        addq.l  #8, a7

        moveq.l #0, d0
        move.l  #4, d1                          ; will never be > max(PIECE_HEIGHT, PIECE_WIDTH)
.cntloop:
        lsr.l   #1, d4
        bcc     .skip
        addq.l  #1, d0
.skip:
        dbra    d1, .cntloop
        jsr     boardlineinc
        jsr     boardscoreupd

.done:
        move.l  #game_spawn, (GAME_STATE)
        movem.l (a7)+, d0-d2/d4
        rts

game_pause:
        movem.l d1-d2/d5-d6, -(a7)

        sncdisable
        jsr     scrclr
        move.l  #$00f89568, d1
        move.w  #SCR_WIDTH/2/TILE_SIZE-3, d5
        move.w  #SCR_HEIGHT/2/TILE_SIZE-1, d6
        lea.l   .pause_str, a1
        jsr     drawstrcol
        jsr     scrplot
.chk:
        jsr     kbdupd
        btst    #KBD_ESC_POS, (KBD_EDGE)
        beq     .chk
.done:
        jsr     game_plot
        jsr     pieceplot
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
        movem.l d0-d6/a0, -(a7)

        ; get color scheme based on current level and push them to the stack
        lea.l   piece_colmap, a0
        moveq.l #0, d0
        move.b  (levelnum), d0
        lsl.l   #3, d0
        add.l   d0, a0
        move.l  (a0)+, -(a7)                    ; third color to be drawn
        move.l  #$00ffffff, -(a7)               ; second color to be drawn
        move.l  (a0)+, -(a7)                    ; first color to be drawn

        ; draw rectangle parameters
        ; (except d1 which will be ovewritten by color trap 14 call)
        move.l  #(BRD_BASE_X+BRD_WIDTH)<<TILE_SHIFT-1-BRD_GO_PADDING, d3
        move.l  #BRD_BASE_Y<<TILE_SHIFT, d2
        move.l  d2, d4
        add.l   #4*TILE_MULT, d4

        ; TODO: optimize plot loop (e.g. put bar height in stack)
        move.l  #BRD_HEIGHT-1, d6
.loop:
        move.l  (a7), d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        move.b  #87, d0
        move.l  #BRD_BASE_X<<TILE_SHIFT, d1
        trap    #15
        add.l   #4*TILE_MULT, d2
        add.l   #6*TILE_MULT, d4
.sync1:
        move.l  (SNC_CNT_DOWN), d0
        bgt     .sync1
        jsr     scrplot
        move.l  #3, (SNC_CNT_DOWN)              ; plot every 3*10ms

        move.l  4(a7), d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        move.b  #87, d0
        move.l  #BRD_BASE_X<<TILE_SHIFT, d1
        trap    #15
        add.l   #6*TILE_MULT, d2
        add.l   #4*TILE_MULT, d4
.sync2:
        move.l  (SNC_CNT_DOWN), d0
        bgt     .sync2
        jsr     scrplot
        move.l  #3, (SNC_CNT_DOWN)              ; plot every 3*10ms

        move.l  8(a7), d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        move.b  #87, d0
        move.l  #BRD_BASE_X<<TILE_SHIFT, d1
        trap    #15
        add.l   #6*TILE_MULT, d2
        add.l   #6*TILE_MULT, d4
.sync3:
        move.l  (SNC_CNT_DOWN), d0
        bgt     .sync3
        jsr     scrplot
        move.l  #3, (SNC_CNT_DOWN)              ; plot every 3*10ms

        dbra    d6, .loop

        add.l   #3*4, a7                        ; pop color scheme from stack
        move.l  #game_halt, (GAME_STATE)

        movem.l (a7)+, d0-d6/a0
        rts

game_halt:
.halt:  bra     .halt
        rts
