screen_game:
        movem.l d0/a0-a1, -(a7)
; --- init ---------------------------------------------------------------------
        lea.l   board, a0
        move.l  #BRD_SIZE-1, d0
.brdclr:
        move.b  #$ff, (a0)+
        dbra    d0, .brdclr

        move.w  #0, (linecount)
        move.w  #0, (score)
        ; setup selected level
        move.w  (LVL_SEL_FNUM), d0
        move.w  d0, (levelcnt)
        move.b  d0, (levelnum)
        jsr     boarddropupd

        subq.w  #1, d0
        blt     .scolvldone
.scolvl:
        jsr     boardscoreinc
        dbra.w  d0, .scolvl
.scolvldone:

        ; clear piecestats
        lea.l   piecestats, a0
        moveq.l #6, d0
.piecestats:
        move.b  #0, (a0)+
        dbra    d0, .piecestats

        ; TODO: get values from RNG
        move.b  #0, (piecenum)
        move.b  #1, (piecenumn)
        ; -------------------------
        ; check if current game type B
        tst.b   (GME_TYPE)
        beq     .game_plot
        jsr     game_type_b_init
.game_plot:
        jsr     game_plot
        move.l  #game_spawn, (GME_STATE)
.loop:
; --- update -------------------------------------------------------------------
        jsr     kbdupd
        move.l  (GME_STATE), a0
        cmp.l   #0, a0
        beq     .done
        jsr     (a0)
; --- sync ---------------------------------------------------------------------
.sync:
        move.b  (SNC_PLOT), d0
        beq     .sync
        move.b  #0, (SNC_PLOT)
; --- plot ---------------------------------------------------------------------
        jsr     scrplot
        bra     .loop
.done:
        movem.l (a7)+, d0/a0-a1
        rts

game_type_b_init:
        movem.l d0-d2/d6-d7/a0-a2, -(a7)
        ; calculate a board address for tiles to spawn starting from a given height
        lea.l   GME_B_HEIGHT_TABLE, a0
        lea.l   board, a2

        moveq.l #BRD_ROWS, d0
        moveq.l #0, d1
        movea.l a2, a1
        add.l   #BRD_SIZE, a1

        move.w  (HIGH_SEL_FNUM), d1
        move.b  d1, (GME_B_HEIGHT)
        sub.b   (a0,d1.w), d0                   ; N = BRD_ROWS-GME_B_HEIGHT
        mulu    #BRD_COLS, d0                   ; N * BRD_COLS
        adda.l  d0, a2                          ; address on the board, initial tile spawning point
        ; skip PRN generation if total number of rows is 0
        cmp.l   a1, a2
        beq     .done

        ; generate multiple pseudo random numbers
        moveq.l #8, d0
        trap    #15
        move.l  d1, (PRNG32)                    ; set current time as seed
        move.l  #$af-$100, d1                   ; initial mask for PRNG, #$fffffea7, #$b4bcd35c

        lea.l   PRNBUFFER, a0
        moveq.l #5, d7                          ; number of long words to generate
.randlp:
        move.l  (PRNG32), d0
        jsr     randgen
        move.l  (PRNG32), (a0)+
        dbra    d7, .randlp

        ; fill board according to the binary value of the generated PRNs
        lea.l   PRNBUFFER, a3
        movea.l #PRNBUFFER+8, a0
        move.w  #3, d5                          ; 4 PRN; first two are ignored
.loopa:
        move.l  (a0)+, d0
        moveq.l #31, d7
        moveq.l #32, d6
.loopb:
        subq.l  #1, d6
        btst.l  d6, d0
        beq     .bits0                          ; jump if bit is 0
        ; random tile color & pattern
        move.w  d6, d1
        andi.w  #%11, d1
        move.b  (a3,d1.w), d2
        andi.b  #$11, d2
        cmp.b   #$11, d2
        bne     .not11
        moveq.l #0, d2                          ; color 0, patró 0
.not11:
        move.b  d2, (a2)
.bits0:
        addq.l  #1, a2
        cmp.l   a1, a2                          ; a2 - a1
        bge     .done                           ; if (a2 >= a1) -> jump out of loop
        dbra    d7, .loopb
        dbra    d5, .loopa
.done:
        movem.l (a7)+, d0-d2/d6-d7/a0-a2
        rts

game_plot:
        movem.l d0-d6/a0, -(a7)
        ; draw screen background
        jsr     scrclr
        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        ; draw top score
        move.l  (GME_HIGH_SCORE), d0
        move.b  #0, d3
        moveq.l #5, d4
        move.l  #BRD_TOP_SCO_BASE_X, d5
        move.l  #BRD_TOP_SCO_BASE_Y, d6
        jsr     drawnum
        ; update statistics box
        jsr     boardlvlupd

        moveq.l #0, d0
        moveq.l #6, d2
        lea.l   piecestats, a0
.statupd:
        move.l  d2, d1
        lsl.l   #1, d1
        move.b  (a0,d1), d0
        jsr     boardstatupd
        dbra    d2, .statupd

        ; draw b-type
        lea.l   tiletable, a0
        move.w  #10, d0                         ; letter B tile index
        add.b   (GME_TYPE), d0
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0
        move.l  #7, d5
        move.l  #4, d6
        jsr     drawtile

        movem.l (a7)+, d0-d6/a0
        rts

game_spawn:
        movem.l d0-d2, -(a7)

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
        move.l  #game_player, (GME_STATE)
        move.l  (SNC_PIECE_TIME), (SNC_CNT_DOWN) ; reset piece sync counter
        bra     .done
.collision:
        move.l  #game_over, (GME_STATE)
.done:
        ;************** ALLEGRO PLAYER ***************
        move.b  (GME_MUSIC), d1
        cmp.b   #3, d1                          ; if music is OFF skips this part
        beq     .done2

        moveq.l #5, d0                          ; checks if row 5 (height 15) is empty
        jsr     boardchkempty 
        cmp.b   #0, d0
        beq     .emptyrow                       ; if its empty jump

        ; not empty, play allegro version
        cmp.b   #3, d1
        bgt     .done2                          ; exits if current song is already allegro version
        sndplay SND_STOP_ALL
        add.b   #6, (GME_MUSIC)                 ; sets allegro version as the current song
        sndplay (GME_MUSIC), #SND_LOOP

        ; empty, play normal version
.emptyrow:
        cmp.b   #3, d1
        blt     .done2                          ; exits if current song is already normal version
        sndplay SND_STOP_ALL
        sub.b   #6, (GME_MUSIC)                 ; resets allegro version to normal version
        sndplay (GME_MUSIC), #SND_LOOP 
        ;*********************************************
.done2:
        movem.l (a7)+, d0-d2
        rts

game_player:
        movem.l d0-d2, -(a7)
        move.b  #$ff, d2                        ; sound ignore
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
        move.l  #game_drop, (GME_STATE)
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
        move.b  #SND_ROTPIECE, d2
        bra     .chkcol
.chkspbar:
        btst    #KBD_SPBAR_POS, d0
        beq     .chkesc
        move.l  #game_drop, (GME_STATE)
        bra     .done
.chkesc:
        btst    #KBD_ESC_POS, d0
        beq     .chkenter
        move.l  #game_pause, (GME_STATE)
        bra     .done

; -----------------------------
; TODO: remove this as it is only for testing
.chkenter:
        ; btst    #KBD_ENTER_POS, d0
        ; beq     .chkctrl
        ; move.l  #game_inc_level, (GME_STATE)
        ; bra     .done
.chkctrl:
        btst    #KBD_CTRL_POS, d0
        beq     .done
        move.l  #game_spawn, (GME_STATE)
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
        move.b  #$ff, d2
.done:
        cmp.b   #$ff, d2
        beq     .exit
        sndplay d2
.exit:
        movem.l (a7)+, d0-d2
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
        jsr     scrplot
        sndplay #SND_PIECELOCK
        move.l  #game_clr_rows, (GME_STATE)
        movem.l (a7)+, d0-d2/a0
        rts

game_inc_level:
        move.l  d0, -(a7)
        ; play level up sound
        sndplay #SND_LEVELUP
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
        move.l  #game_spawn, (GME_STATE)
        move.l  (a7)+, d0
        rts

game_clr_rows:
        movem.l d0-d2/d4, -(a7)
        move.l  #game_spawn, (GME_STATE)
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

        ; get number of cleared lines
        moveq.l #0, d0
        move.l  #4, d1                          ; will never be > max(PIECE_HEIGHT, PIECE_WIDTH)
.cntloop:
        lsr.l   #1, d4
        bcc     .skip
        addq.l  #1, d0
.skip:
        dbra    d1, .cntloop

        ; update line & core stats
        jsr     boardlineinc
        move.w  (linecount), d1
        divu.w  #10, d1
        swap    d1
        cmp.w   d0, d1
        bhs     .ninc
        move.l  #game_inc_level, (GME_STATE)
.ninc:
        jsr     boardscoreupd

        cmp.b   #4, d0
        bhs     .tetris
        sndplay #SND_LINECOMPL
        bra     .animation
.tetris:
        sndplay #SND_TETRISACH
        ; line clear animation
.animation:
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

        tst.b   (GME_TYPE)
        beq     .done
        ; check type-b success
        cmp.w   #25, (linecount)
        blo     .done
        move.l  #game_type_b_success, (GME_STATE)
.done:
        movem.l (a7)+, d0-d2/d4
        rts

game_type_b_success:
        movem.l d0/d5-d6/a1, -(a7)
        sndplay (GME_MUSIC), #SND_STOP
        sndplay #SND_BTYPESUC

        jsr     boardclr
        lea.l   bgsuccesstypeb, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        jsr     scrplot

        move.l  #0, (GME_STATE)
        jsr     game_chk_top3

        ; 3 second sleep
        move.l  #300, (SNC_CNT_DOWN)
.wait:
        move.l  (SNC_CNT_DOWN), d0
        bgt     .wait

        movem.l (a7)+, d0/d5-d6/a1
        rts

game_pause:
        movem.l d1-d2/d5-d6, -(a7)

        sndplay (GME_MUSIC), #SND_STOP
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

        ; TODO: fix game restore (not everything is restored correctly)
        jsr     game_plot
        jsr     boardplot
        jsr     pieceplot
        move.l  #game_player, (GME_STATE)
        sncenable
        move.b  (GME_MUSIC), d1
        cmp.b   #3, d1
        beq     .done
        sndplay d1, #SND_LOOP
.done:
        movem.l (a7)+, d1-d2/d5-d6
        rts
.pause_str:
        dc.b    'PAUSED',0
        ds.w    0

game_over:
        movem.l d0-d6/a0, -(a7)

        sndplay (GME_MUSIC), #SND_STOP
        sndplay #SND_DEATH

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
        ; (except d1 which will be ovewritten by color trap 15 call)
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

        move.l  #0, (GME_STATE)
        jsr     game_chk_top3
.done:
        movem.l (a7)+, d0-d6/a0
        rts

game_chk_top3:
        movem.l d0-d2, -(a7)
        ; check if score is in top 3
        jsr     netinit
        move.b  (GME_TYPE), d0
        addq.b  #1, d0
        move.l  (score), d1
        move.l  #300, d2
        jsr     netscoreplace
        jsr     netclose

        cmp.l   #3, d1
        bls     .top3
        move.b  #1, (SCR_NUM)
        bra     .done
.top3:
        move.w  d1, (USR_HIGHSCORE_POS)
        move.b  #6, (SCR_NUM)
        move.b  (GME_TYPE), d0
        add.b   d0, (SCR_NUM)
.done:
        movem.l (a7)+, d0-d2
        rts

game_halt:
.halt:  bra     .halt
        rts
