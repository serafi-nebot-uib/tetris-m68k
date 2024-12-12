gameupd:
        movem.l d0-d1, -(a7)
        ; d0.l -> kbdedge
        moveq.l #0, d0
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
; -----------------------------
; TODO: remove this as it is only for testing
.chkspbar:
        btst    #4, d0
        beq     .chkenter
        piecemovu #1
        bra     .chkcol
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
        beq     .chkesc
.npiece:
        jsr     piececlr
        move.b  (piecenum), d0
        addq.l  #1, d0
        divu    #7, d0
        swap    d0
        andi.l  #$ffff, d0
        jsr     pieceinit
        bra     .done
.chkesc:
        btst    #5, d0
        beq     .done
        jsr     piecerelease
        bra     .npiece
; -----------------------------
.chkcol:
        jsr     piececoll
        cmp.b   #0, d0
        beq     .done
.rollback:
        piecerollback
.done:
        movem.l (a7)+, d0-d1
        rts

screen_game:
; --- init ---------------------------------------------------------------------
        jsr     scrclr
        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        move.l  #0, d0                          ; piece number
        jsr     pieceinit

        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN) ; reset piece sync counter
.loop:
; --- update -------------------------------------------------------------------
        jsr     kbdupd                          ; update keyboard values

        ; check if piece should be moved down
        move.l  (SNC_CNT_DOWN), d0
        bgt     .upd
        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN)
        piecemovd #1
        jsr     piececoll
        cmp.b   #0, d0
        beq     .plot
.collision:
        piecerollback
        bra     .plot
.upd:
        jsr     gameupd

; --- sync ---------------------------------------------------------------------
.plot:
        ; TODO: variable to determine if a change has occurred? (avoid unnecessary plots)
        jsr     piececlr
        jsr     pieceplot
        piececommit
.sync:
        move.b  (SNC_PLOT), d0
        beq     .sync
        move.b  #0, (SNC_PLOT)

; --- plot ---------------------------------------------------------------------
        jsr     scrplot

        bra     .loop
        rts

_game:
