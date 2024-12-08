gameupd:
        movem.l d0-d1, -(a7)
        ; d0.l -> kbdedge
        moveq.l #0, d0
        move.b  (KBD_EDGE), d0
        move.b  (KBD_VAL), d1
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
        ; TODO: disable up
.chkup:
        btst    #1, d0
        beq     .chkdown
        piecemovu #1
        bra     .chkcol
.chkdown:
        btst    #3, d0
        beq     .chkspbar
        piecemovd #1
        move.b  #SNC_PIECE_TIME, (SNC_PIECE)
        bra     .chkcol
.chkspbar:
        btst    #4, d0
        beq     .chkshift
        jsr     piecerotr
        bra     .chkcol
; -----------------------------
; TODO: remove this as it is only for testing
.chkshift:
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
        bra     .chkcol
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
        bra     .chkcol
.chkesc:
        btst    #5, d0
        beq     .chkcol
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

game:
; ; --- test ---------------------------------------------------------------------
;         move.l  #0, d0                          ; piece number
;         jsr     pieceinit
;
;         jsr     boardplot
;         trap    #SCR_TRAP
;
;         move.l  #BOARD_HEIGHT-1, d0             ; board base y coord
;         move.l  #%01111101110011100101, d4      ; row fill status
;         jsr     boarddropdown
;
;         move.b  #11, d0
;         move.l  #$ff00, d1
;         trap    #15
;         jsr     boardplot
;         trap    #SCR_TRAP
;
;         simhalt

; --- init ---------------------------------------------------------------------
        lea.l   bggame, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        move.l  #0, d0                          ; piece number
        jsr     pieceinit

        move.b  #SNC_PIECE_TIME, (SNC_PIECE)    ; reset piece sync counter
.loop:
; --- update -------------------------------------------------------------------
        trap    #KBD_TRAP                       ; update keyboard values

        ; check if piece should be moved down
        move.b  (SNC_PIECE), d0
        bgt     .upd
        move.b  #SNC_PIECE_TIME, (SNC_PIECE)
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
        move.b  (SNC_PLOT), d0
        beq     .plot
        move.b  #0, (SNC_PLOT)

; --- plot ---------------------------------------------------------------------
        trap    #SCR_TRAP

        bra     .loop
        rts
