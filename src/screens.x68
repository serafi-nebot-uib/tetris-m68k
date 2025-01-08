screens:
        dc.l    screen_legal
        dc.l    screen_start
        dc.l    screen_type
        dc.l    screen_level_a
        dc.l    screen_level_b
        dc.l    screen_game
        dc.l    screen_congrats_a
        dc.l    screen_congrats_b

; TODO: add mouse to legal and start screens

screen_legal:
; --- INITIALIZE LEGAL SCREEN ---
        jsr     mouseinit

        movem.l d0-d1/d5-d6/a0-a1, -(a7)
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        lea.l   .txt1, a1
        move.w  #.basex, d5
        move.w  #.basey, d6
        jsr     drawstr

        lea.l   .txt2, a1
        move.w  #.basex+9, d5
        move.l  #.colblue, d1
        jsr     drawstrcol

        lea.l   .txt3, a1
        move.w  #.basex-4, d5
        move.w  #.basey+2, d6
        move.l  #LVL_SEL_COL, d1
        jsr     drawstrcol

        lea.l   .txt4, a1
        move.w  #.basex+2, d5
        move.w  #.basey+4, d6
        jsr     drawstrcol

        lea.l   .txt5, a1
        move.w  #.basex-6, d5
        move.w  #.basey+6, d6
        move.l  #.colblue, d1
        jsr     drawstrcol

        lea.l   .txt6, a1
        move.w  #.basex+1, d5
        jsr     drawstr

        lea.l   .txt7, a1
        move.w  #.basex+13, d5
        move.l  #LVL_SEL_COL, d1
        jsr     drawstrcol
        move.w  #.basex+5, d5
        move.w  #.basey+8, d6
        jsr     drawstrcol

        lea.l   .txt8, a1
        move.w  #.basex, d5
        move.l  #.colblue, d1
        jsr     drawstrcol

        lea.l   .txt9, a1
        move.w  #.basex-3, d5
        move.w  #.basey+10, d6
        jsr     drawstr

        lea.l   .txt10, a1
        move.w  #.basex-5, d5
        move.w  #.basey+12, d6
        jsr     drawstr

        lea.l   .txt11, a1
        move.w  #.basex+2, d5
        move.w  #.basey+14, d6
        jsr     drawstr

        lea.l   .txt12, a1
        move.w  #.basex-2, d5
        move.w  #.basey+16, d6
        jsr     drawstr

        lea.l   .txt13, a1
        move.w  #.basex+1, d5
        move.l  #LVL_SEL_COL, d1
        jsr     drawstrcol

        move.l  (tiletable+(47<<2)), a0
        add.l   (tileaddr), a0
        move.l  #.coldarkblue, d1

        move.w  #.basex+7, d5
        move.w  #.basey, d6
        jsr     drawtilecol

        move.w  #.basex-2, d5
        move.w  #.basey+8, d6
        jsr     drawtilecol

        jsr     scrplot

; --- UPDATE LEGAL SCREEN ---

        move.l  #SNC_TIME_S*5, (SNC_CNT_DOWN)   ; 5 second timer
.loop:
        jsr     kbdupd
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        bne     .done

        jsr     mouseupd
*        cmp.b   #1, (MOUSE_EDGE)
        cmp.b   #1, (BUTT_PRESS)
        beq     .done

        tst.l   (SNC_CNT_DOWN)
        bgt     .loop
.done:
        ; DON'T PASS THIS STATE TILL CLICK UP
        move.b  #1, (SCR_NUM)

        movem.l (a7)+, d0-d1/d5-d6/a0-a1
        rts

.basex: equ     13
.basey: equ     6
.colblue: equ   $00f6fdb3
.coldarkblue: equ $00f89568
.txt1:  dc.b    'TM AND',0
.txt2:  dc.b    '1987',0
.txt3:  dc.b    'V/O ELECTRONORGTECHNICA',0
.txt4:  dc.b    '("ELORG")',0
.txt5:  dc.b    'TETRIS',0
.txt6:  dc.b    'LICENSED TO ',0
.txt7:  dc.b    'NINTENDO',0
.txt8:  dc.b    '1989',0
.txt9:  dc.b    'ALL RIGHTS RESERVED ',0
.txt10: dc.b    'ORIGINAL CONCEPT,DESIGN',0
.txt11: dc.b    'AND PROGRAM ',0
.txt12: dc.b    'BY',0
.txt13: dc.b    'ALEXEY PAZHITNOV',0

; --- screen start: pantalla start -------------------------------------------
screen_start:
*        MOVE.W   #0,(MOUSE_POS_X)
*        MOVE.W   #0,(MOUSE_POS_Y)
**        move.b   #0, (BUTT_PRESS)
        move.w  #0, (KBD_ENTER_PRESS)
        move.b  #0, (KBD_EDGE)

        jsr     scrclr
        moveq.l #0, d5
        moveq.l #0, d6
        lea.l   bghome, a1
        jsr     drawmap
        jsr     scrplot
.loop:
        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        jsr     kbdupd
        
        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END_KBD
        move.b  #1, (KBD_ENTER_PRESS)

.END_KBD:
        move.b  (KBD_ENTER_PRESS), d0
        cmp.b   #1, d0
        beq     .DONE

        jsr     mouseupd
*        cmp.b   #1, (MOUSE_EDGE)
        cmp.b   #1, (BUTT_PRESS)
        bne     .loop
.done:
        sndplay #SND_MENUSLCT
        SNDPLAY #SND_MUSIC1, #SND_LOOP
        move.b  #2, (SCR_NUM)
        move.b  #0, (GME_TYPE)
        move.b  #0, (GME_MUSIC)
        rts

; --- JSR FOR CHANGING THE MUSIC ---

CHK_MUSIC:
        cmp.b   #3, (GME_MUSIC)
        bge     .OFF_MUSIC

        sndplay SND_STOP_ALL
        sndplay #SND_MENUSLCT
        sndplay (GME_MUSIC), #SND_LOOP
        rts

.OFF_MUSIC:
        sndplay SND_STOP_ALL
        sndplay #SND_MENUSLCT
        rts


; --- screen_type: pantalla de seleccio de type i music ----------------------
screen_type:
; ----------------------------------------------------------------------------
; INITIALIZE TYPE AND MUSIC SELECTION SCREEN.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        move.w  #0, (KBD_ENTER_PRESS)
        move.b  #0, (KBD_EDGE)

        ; --- PAINT BLACK SCREEN ---
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; --- PAINTING BITMAP ---
        lea.l   bgmode, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        jsr     scrplot

.LOOP2:
; --- UPDATE -----------------------------------------------------------------

; READ INPPUT DEVICES
        jsr     kbdupd
; ----------------------------------------------------------------------------
; UPDATE TYPE AND MUSIC SELECTION POSITION.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d1, -(a7)

        ; UPDATE COORDINATE X
        move.b  (GME_TYPE), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT
        sndplay #SND_MENUSLCT
        sub.b   #1, d0
        sub.b   #1, (GME_TYPE)
.CHKLFT:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        sndplay #SND_MENUSLCT
        add.b   #1, d0
        add.b   #1, (GME_TYPE)
            
        ; CHECK COLLISIONS
.CONT:  cmp.b   #0, d0
        bge     .CONT2
        move.b  #0, d0
        move.b  #0, (GME_TYPE)
        bra     .DONE1
.CONT2: cmp.b   #1, d0
        ble     .DONE1
        move.b  #1, d0
        move.b  #1, (GME_TYPE)

        ; UPDATE VARIABLE
.DONE1: move.b  d0, (GME_TYPE)

        ; UPDATE COORDINATE Y
        move.b  (GME_MUSIC), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sub.b   #1, d1
        sub.b   #1, (GME_MUSIC)
        
        jsr     CHK_MUSIC
        
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        add.b   #1, d1
        add.b   #1, (GME_MUSIC)
        
        jsr     CHK_MUSIC
        
        ; CHECK COLLISIONS
.CONT3: cmp.b   #0, d1
        bge     .CONT4
        move.b  #0, d1
        add.b   #1, (GME_MUSIC)
        bra     .DONE2
.CONT4: cmp.b   #3, d1
        ble     .DONE2
        move.b  #3, d1
        sub.b   #1, (GME_MUSIC)

        ; UPDATE VARIABLE
.DONE2: move.b  d1, (GME_MUSIC)

        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END
        sndplay #SND_MENUSLCTD
        move.b  #1, (KBD_ENTER_PRESS)
.END:
        movem.l (a7)+, d0-d1


; ----------------------------------------------------------------------------
; PLOT TYPE AND MUSIC SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        ; --- CLEAR ALL ARROWS TILES -------------------------------------
            
        ; --- LEFT ARROW TYPE ---
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #TAM_TYPE_POS_X<<TILE_SHIFT, d1
        move.w  #TAM_TYPE_POS_Y<<TILE_SHIFT, d2
        move.w  #(TAM_TYPE_POS_X+1)<<TILE_SHIFT, d3
        move.w  #(TAM_TYPE_POS_Y+1)<<TILE_SHIFT, d4
        subq.l  #1, d3
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #(TAM_TYPE_POS_X+12)<<TILE_SHIFT, d1
        move.w  #TAM_TYPE_POS_Y<<TILE_SHIFT, d2
        move.w  #((TAM_TYPE_POS_X+12)+1)<<TILE_SHIFT, d3
        move.w  #(TAM_TYPE_POS_Y+1)<<TILE_SHIFT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

            
        ; --- RIGHT ARROW TYPE ---
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #(TAM_TYPE_POS_X+7)<<TILE_SHIFT, d1
        move.w  #TAM_TYPE_POS_Y<<TILE_SHIFT, d2
        move.w  #((TAM_TYPE_POS_X+7)+1)<<TILE_SHIFT, d3
        move.w  #(TAM_TYPE_POS_Y+1)<<TILE_SHIFT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #(TAM_TYPE_POS_X+19)<<TILE_SHIFT, d1
        move.w  #TAM_TYPE_POS_Y<<TILE_SHIFT, d2
        move.w  #((TAM_TYPE_POS_X+19)+1)<<TILE_SHIFT, d3
        move.w  #(TAM_TYPE_POS_Y+1)<<TILE_SHIFT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        ; --- LEFT ARROW MUSIC ---
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #TAM_MUSIC_POS_X<<TILE_SHIFT, d1
        move.w  #TAM_MUSIC_POS_Y<<TILE_SHIFT, d2
        move.w  #(TAM_MUSIC_POS_X+1)<<TILE_SHIFT, d3
        move.w  #(TAM_MUSIC_POS_Y+7)<<TILE_SHIFT, d4
        subq.l  #1, d3
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #(TAM_MUSIC_POS_X+9)<<TILE_SHIFT, d1
        move.w  #TAM_MUSIC_POS_Y<<TILE_SHIFT, d2
        move.w  #((TAM_MUSIC_POS_X+9)+1)<<TILE_SHIFT, d3
        move.w  #(TAM_MUSIC_POS_Y+7)<<TILE_SHIFT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15


        jsr     SCRPLOT
            
        ; --- PAINTING ARROWS FOR LEVEL TYPE AND MUSIC SELECTION ---------
            
        ; --- TYPE LEFT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_LEFT_ARROW, d0             ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0

        move.w  #TAM_TYPE_POS_Y, d6             ; y pos
        move.w  #TAM_TYPE_POS_X, d5             ; x pos
        cmp.b   #0, (GME_TYPE)
        beq     .typea
        addi.b  #12, d5
.typea:
        jsr     drawtile
            
            
        ; --- TYPE RIGHT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_RIGHT_ARROW, d0            ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0
            
        move.w  #TAM_TYPE_POS_Y, d6             ; y pos
        move.w  #TAM_TYPE_POS_X+7, d5           ; x pos
        cmp.b   #0, (GME_TYPE)
        beq     .typea1
        addi.b  #12, d5
.typea1:
        jsr     drawtile
            
            
        ; --- MUSIC LEFT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_LEFT_ARROW, d0             ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0
            
        move.w  #TAM_MUSIC_POS_Y, d6            ; y pos
        move.w  #TAM_MUSIC_POS_X, d5            ; x pos
        cmp.b   #0, (GME_MUSIC)
        beq     .DONE
        cmp.b   #1, (GME_MUSIC)
        beq     .MUSIC2
        cmp.b   #2, (GME_MUSIC)
        beq     .MUSIC3
        cmp.b   #3, (GME_MUSIC)
        beq     .OFF
.MUSIC2: add.b  #2, d6
        bra     .DONE
.MUSIC3: add.b  #4, d6
        bra     .DONE
.OFF:   add.b   #6, d6
.DONE:
        jsr     drawtile
            
            
        ; --- MUSIC RIGHT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_RIGHT_ARROW, d0            ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0
            
        move.w  #TAM_MUSIC_POS_Y, d6            ; y pos
        move.w  #TAM_MUSIC_POS_X+9, d5          ; x pos
        cmp.b   #0, (GME_MUSIC)
        beq     .DONER
        cmp.b   #1, (GME_MUSIC)
        beq     .MUSIC2R
        cmp.b   #2, (GME_MUSIC)
        beq     .MUSIC3R
        cmp.b   #3, (GME_MUSIC)
        beq     .OFFR
.MUSIC2R: add.b #2, d6
        bra     .DONER
.MUSIC3R: add.b #4, d6
        bra     .DONER
.OFFR:  add.b   #6, d6
.DONER:
        jsr     drawtile

        jsr     SCRPLOT
        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        bne     .FIN2
        
        btst.b  #KBD_ESC_POS, (KBD_EDGE)
        bne     .BACK_TO_SCREEN_START
        
        bra     .LOOP2
        
.BACK_TO_SCREEN_START:
        sndplay (GME_MUSIC), #SND_STOP
        sndplay #SND_MENUSLCTD
        move.b  #1, (SCR_NUM)
        rts

.FIN2:
        btst.b  #0, (GME_TYPE)
        bne     .TYPEB_SCR
        bra     .TYPEA_SCR
        
.TYPEA_SCR: move.b #3, (SCR_NUM)
        rts

.TYPEB_SCR: move.b #4, (SCR_NUM)
        rts




; --- screen 3: pantalla seleccio nivell a-type ------------------------------
screen_level_a:
; ----------------------------------------------------------------------------
; INITIALIZE LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        move.w  #LVL_SEL_BASE_X*TILE_MULT, (LVL_SEL_POS_X)
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, (LVL_SEL_POS_Y)
        move.w  #0, (LVL_SEL_NUM)
        move.w  #-1, (LVL_SEL_FNUM)
        move.w  #0, (KBD_ENTER_PRESS)

        ; --- PAINT BLACK SCREEN ---
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; --- PAINTING BITMAP ---
        lea.l   bgtypea, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap

        ; --- GET TOP 3 PLAYERS FROM SERVER ---
        jsr     netinit
        move.b  #1, d0
        move.w  #3, d1
        move.w  #300, d2                        ; 300*10ms = 3s timeout
        jsr     netscorereq
        jsr     netclose

        lea.l   NET_BUFFER, a0
        lea.l   SCO_NAME, a1
        ; check score list id
        cmp.b   #$03, (a0)+
        bne     .done

        ; number of scores
        move.b  (a0)+, d0
        lsl.w   #8, d0
        move.b  (a0)+, d0

        moveq.l #0, d3                          ; score iteration counter
.score_loop:
        ; check score id
        cmp.b   #$02, (a0)+
        bne     .done
        moveq.l #0, d2                          ; player character tmp var
        move.w  #0, d1
.player_cpy:
        move.b  (a0)+, d2
        move.b  d2, (a1,d1.w)
        addq.w  #1, d1
        cmp.w   #6, d1
        blo     .player_cpy
        move.b  #0, 6(a1)                       ; add trailing 0 to indicate string end

        move.w  #LVL_SEL_NAME_BASE_X, d5
        move.w  #LVL_SEL_NAME_BASE_Y, d6
        move.l  d3, d2
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawstr

        ; skip game type
        addq.l  #1, a0
        ; player score
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1

        tst.b   d3
        bne     .digit
        move.l  d1, (GME_HIGH_SCORE)
.digit:
        ; convert score to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0
        move.l  #LVL_SEL_SCORE_LEN-1, d2
.score_clr:
        move.b  #0, (a0)+
        dbra    d2, .score_clr

        move.l  d1, d0
        move.l  #LVL_SEL_SCORE_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_SCORE_BASE_X, d5
        move.w  #LVL_SEL_SCORE_BASE_Y, d6
        moveq.l #LVL_SEL_SCORE_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0

        ; game level
        moveq.l #0, d1
        move.b  (a0)+, d1
        lsl.w   #8, d1
        move.b  (a0)+, d1
        ; convert level to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0                   ; reuse score array
        move.l  #LVL_SEL_LEVEL_LEN-1, d2
.score_clr2:
        move.b  #0, (a0)+
        dbra    d2, .score_clr2

        move.l  d1, d0
        move.l  #LVL_SEL_LEVEL_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_LEVEL_BASE_X, d5
        move.w  #LVL_SEL_LEVEL_BASE_Y, d6
        moveq.l #LVL_SEL_LEVEL_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0

        addq.l  #1, d3
        cmp.w   d0, d3
        blo     .score_loop
.done:
        jsr     scrplot

.LOOP3:
; --- UPDATE -----------------------------------------------------------------

; READ INPPUT DEVICES

        jsr     kbdupd

; ----------------------------------------------------------------------------
; UPDATE LEVEL SELECTION SQUARE POSITION.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d1, -(a7)
            
        ; UPDATE COORDINATE X
        move.w  (LVL_SEL_POS_X), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        sub.w   #1, (LVL_SEL_NUM)
.CHKLFT:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        add.w   #1, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT:  cmp.w   #LVL_SEL_BASE_X*TILE_MULT, d0
        bge     .CONT2
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d0
        add.w   #1, (LVL_SEL_NUM)
        bra     .DONE1
.CONT2: cmp.w   #(LVL_SEL_BASE_X+LVL_SEL_SIDEM*4)*TILE_MULT, d0
        ble     .DONE1
        move.w  #(LVL_SEL_BASE_X+LVL_SEL_SIDEM*4)*TILE_MULT, d0
        sub.w   #1, (LVL_SEL_NUM)

        ; UPDATE VARIABLE
.DONE1: move.w  d0, (LVL_SEL_POS_X)

        ; UPDATE COORDINATE Y
        move.w  (LVL_SEL_POS_Y), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        sub.w   #5, (LVL_SEL_NUM)
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        add.w   #5, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT3: cmp.w   #LVL_SEL_BASE_Y*TILE_MULT, d1
        bge     .CONT4
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, d1
        add.w   #5, (LVL_SEL_NUM)
        bra     .DONE2
.CONT4: cmp.w   #(LVL_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        ble     .DONE2
        move.w  #(LVL_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        sub.w   #5, (LVL_SEL_NUM)

        ; UPDATE VARIABLE
.DONE2: move.w  d1, (LVL_SEL_POS_Y)

        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END
        move.b  #1, (KBD_ENTER_PRESS)
        move.w  (LVL_SEL_NUM), (LVL_SEL_FNUM)
.END:

        movem.l (a7)+, d0-d1

; ----------------------------------------------------------------------------
; PLOT LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d5, -(a7)
            
        ; --- PAINTING BLACK SQUARES FOR BACKGROUND ----------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE INITIAL COORDINATES
            
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOPw:
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOPw
            
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOP2w:
        move.w  #(LVL_SEL_BASE_Y+32)*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOP2w

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPTw:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #11, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #5, d0
        blo     .LOOPTw
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPTw

        jsr     SCRPLOT
        
        
        movem.l d0-d5, -(a7)
        ; --- PAINTING SQUARE FOR LEVEL SELECTION ------------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
            
        ; DEFINE COORDINATES
*        move.w  (LVL_SEL_POS_X), d1
*        sub.w   #LVL_SEL_SIDE/2, d1
*        move.w  d1, d3
*        add.w   #LVL_SEL_SIDE, d3
*:
*        move.w  (LVL_SEL_POS_Y), d2
*        sub.w   #LVL_SEL_SIDE/2, d2
*        move.w  d2, d4
*        add.w   #LVL_SEL_SIDE, d4

        move.w  (LVL_SEL_POS_X), d1
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        move.w  (LVL_SEL_POS_Y), d2
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPT:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #11, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #5, d0
        blo     .LOOPT
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPT

        jsr     SCRPLOT

        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        move.b  (KBD_ENTER_PRESS), d0
        cmp.b   #1, d0
        beq     .NEXT_SCREEN_A
        
        btst.b  #KBD_ESC_POS, (KBD_EDGE)
        bne     .PAST_SCREEN_A
        
        bra     .LOOP3

.PAST_SCREEN_A:
        move.b  #2, (SCR_NUM)                   ; CHANGE TO DESIRED SCREEN WHEN DONE
        rts
            
.NEXT_SCREEN_A:
        move.b  #5, (SCR_NUM)                   ; CHANGE TO DESIRED SCREEN WHEN DONE
        sndplay #SND_MENUSLCTD
        rts













; --- screen 4: pantalla seleccio nivell B-type ------------------------------
screen_level_b:
; ----------------------------------------------------------------------------
; INITIALIZE LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        move.w  #LVL_SEL_BASE_X*TILE_MULT, (LVL_SEL_POS_X)
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, (LVL_SEL_POS_Y)
        move.w  #0, (LVL_SEL_NUM)
        move.w  #-1, (LVL_SEL_FNUM)
        move.w  #HIGH_SEL_BASE_X*TILE_MULT, (HIGH_SEL_POS_X)
        move.w  #HIGH_SEL_BASE_Y*TILE_MULT, (HIGH_SEL_POS_Y)
        move.w  #0, (HIGH_SEL_NUM)
        move.w  #-1, (HIGH_SEL_FNUM)
        move.w  #0, (KBD_ENTER_PRESS)

        ; --- PAINT BLACK SCREEN ---
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; --- PAINTING BITMAP ---
        lea.l   bgtypeb, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap

        ; --- GET TOP 3 PLAYERS FROM SERVER ---
        jsr     netinit
        move.b  #2, d0
        move.w  #3, d1
        move.w  #300, d2                        ; 300*10ms = 3s timeout
        jsr     netscorereq
        jsr     netclose

        lea.l   NET_BUFFER, a0
        lea.l   SCO_NAME, a1
        ; check score list id
        cmp.b   #$03, (a0)+
        bne     .done

        ; number of scores
        move.b  (a0)+, d0
        lsl.w   #8, d0
        move.b  (a0)+, d0

        moveq.l #0, d3                          ; score iteration counter
.score_loop:
        ; check score id
        cmp.b   #$02, (a0)+
        bne     .done
        moveq.l #0, d2                          ; player character tmp var
        move.w  #0, d1
.player_cpy:
        move.b  (a0)+, d2
        move.b  d2, (a1,d1.w)
        addq.w  #1, d1
        cmp.w   #6, d1
        blo     .player_cpy
        move.b  #0, 6(a1)                       ; add trailing 0 to indicate string end

        move.w  #LVL_SEL_NAME_BASE_X, d5
        move.w  #LVL_SEL_NAME_BASE_Y, d6
        move.l  d3, d2
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawstr

        ; skip game type
        addq.l  #1, a0
        ; player score
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1

        tst.b   d3
        bne     .digit
        move.l  d1, (GME_HIGH_SCORE)
.digit:
        ; convert score to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0
        move.l  #LVL_SEL_SCORE_LEN-1, d2
.score_clr:
        move.b  #0, (a0)+
        dbra    d2, .score_clr

        move.l  d1, d0
        move.l  #LVL_SEL_SCORE_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_SCORE_BASE_X, d5
        move.w  #LVL_SEL_SCORE_BASE_Y, d6
        moveq.l #LVL_SEL_SCORE_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0

        ; game level
        moveq.l #0, d1
        move.b  (a0)+, d1
        lsl.w   #8, d1
        move.b  (a0)+, d1
        ; convert level to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0                   ; reuse score array
        move.l  #LVL_SEL_LEVEL_LEN-1, d2
.score_clr2:
        move.b  #0, (a0)+
        dbra    d2, .score_clr2

        move.l  d1, d0
        move.l  #LVL_SEL_LEVEL_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_LEVEL_BASE_X, d5
        move.w  #LVL_SEL_LEVEL_BASE_Y, d6
        moveq.l #LVL_SEL_LEVEL_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0

        addq.l  #1, d3
        cmp.w   d0, d3
        blo     .score_loop
.done:
        jsr     scrplot

        ; --- PAINTING SQUARE FOR HEIGHT SELECTION -----------------------
        movem.l d0-d5, -(a7)

        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
        
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15

        move.w  #HIGH_SEL_BASE_X*TILE_MULT, d1
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        move.w  #HIGH_SEL_BASE_Y*TILE_MULT, d2
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        movem.l (a7)+, d0-d5
        
        ; --- PAINTING NUMBERS FOR HEIGHT SELECTION ----------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPTh1:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #25, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #3, d0
        blo     .LOOPTh1
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPTh1

        jsr     scrplot

LOOP4_L:
; --- UPDATE -----------------------------------------------------------------

; READ INPPUT DEVICES

        jsr     kbdupd

; ----------------------------------------------------------------------------
; UPDATE LEVEL SELECTION SQUARE POSITION.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d1, -(a7)
            
        ; UPDATE COORDINATE X
        move.w  (LVL_SEL_POS_X), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        sub.w   #1, (LVL_SEL_NUM)
.CHKLFT:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        add.w   #1, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT:  cmp.w   #LVL_SEL_BASE_X*TILE_MULT, d0
        bge     .CONT2
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d0
        add.w   #1, (LVL_SEL_NUM)
        bra     .DONE1
.CONT2: cmp.w   #(LVL_SEL_BASE_X+LVL_SEL_SIDEM*4)*TILE_MULT, d0
        ble     .DONE1
        move.w  #(LVL_SEL_BASE_X+LVL_SEL_SIDEM*4)*TILE_MULT, d0
        sub.w   #1, (LVL_SEL_NUM)

        ; UPDATE VARIABLE
.DONE1: move.w  d0, (LVL_SEL_POS_X)

        ; UPDATE COORDINATE Y
        move.w  (LVL_SEL_POS_Y), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        sub.w   #5, (LVL_SEL_NUM)
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        add.w   #5, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT3: cmp.w   #LVL_SEL_BASE_Y*TILE_MULT, d1
        bge     .CONT4
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, d1
        add.w   #5, (LVL_SEL_NUM)
        bra     .DONE2
.CONT4: cmp.w   #(LVL_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        ble     .DONE2
        move.w  #(LVL_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        sub.w   #5, (LVL_SEL_NUM)

        ; UPDATE VARIABLE
.DONE2: move.w  d1, (LVL_SEL_POS_Y)

        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END
        move.b  #1, (KBD_ENTER_PRESS)
        move.w  (LVL_SEL_NUM), (LVL_SEL_FNUM)
.END:

        movem.l (a7)+, d0-d1

; ----------------------------------------------------------------------------
; PLOT LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d5, -(a7)
            
        ; --- PAINTING BLACK SQUARES FOR BACKGROUND ----------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE INITIAL COORDINATES
            
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOPw:
        move.w  #LVL_SEL_BASE_Y*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOPw
            
        move.w  #LVL_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOP2w:
        move.w  #(LVL_SEL_BASE_Y+32)*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOP2w

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPTw:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #11, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #5, d0
        blo     .LOOPTw
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPTw

        jsr     SCRPLOT
        
        
        movem.l d0-d5, -(a7)
        ; --- PAINTING SQUARE FOR LEVEL SELECTION ------------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
        
        move.w  (LVL_SEL_POS_X), d1
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        move.w  (LVL_SEL_POS_Y), d2
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPT:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #11, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #5, d0
        blo     .LOOPT
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPT

        jsr     SCRPLOT

        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        move.b  (KBD_ENTER_PRESS), d0
        cmp.b   #1, d0
        beq     .FIN_LVL_B
        
        btst.b  #KBD_ESC_POS, (KBD_EDGE)
        bne     .FIN42
        
        bra     LOOP4_L

.FIN42: move.b  #2, (SCR_NUM)                   ; CHANGE TO DESIRED SCREEN WHEN DONE
            
        rts
            
.FIN_LVL_B: sndplay #SND_MENUSLCTD
        bra     SEL_HEIGHT                      ; CHANGE TO DESIRED SCREEN WHEN DONE


; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; --- SECOND PART, HEIGHT SELECTION ------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

SEL_HEIGHT:
        move.w  #0, (KBD_ENTER_PRESS)

.LOOP4_H:
; --- UPDATE -----------------------------------------------------------------

; READ INPPUT DEVICES

        jsr     kbdupd

; ----------------------------------------------------------------------------
; UPDATE LEVEL SELECTION SQUARE POSITION.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d1, -(a7)
            
        ; UPDATE COORDINATE X
        move.w  (HIGH_SEL_POS_X), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT_4H
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        sub.w   #1, (HIGH_SEL_NUM)
.CHKLFT_4H:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT_4H
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d0
        add.w   #1, (HIGH_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT_4H: cmp.w #HIGH_SEL_BASE_X*TILE_MULT, d0
        bge     .CONT2_4H
        move.w  #HIGH_SEL_BASE_X*TILE_MULT, d0
        add.w   #1, (HIGH_SEL_NUM)
        bra     .DONE1_4H
.CONT2_4H: cmp.w #(HIGH_SEL_BASE_X+LVL_SEL_SIDEM*2)*TILE_MULT, d0
        ble     .DONE1_4H
        move.w  #(HIGH_SEL_BASE_X+LVL_SEL_SIDEM*2)*TILE_MULT, d0
        sub.w   #1, (HIGH_SEL_NUM)

        ; UPDATE VARIABLE
.DONE1_4H: move.w d0, (HIGH_SEL_POS_X)

        ; UPDATE COORDINATE Y
        move.w  (HIGH_SEL_POS_Y), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP_4H
        sndplay #SND_MENUSLCT
        sub.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        sub.w   #3, (HIGH_SEL_NUM)
.CHKUP_4H: btst.b #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3_4H
        sndplay #SND_MENUSLCT
        add.w   #LVL_SEL_SIDEM*TILE_MULT, d1
        add.w   #3, (HIGH_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT3_4H: cmp.w #HIGH_SEL_BASE_Y*TILE_MULT, d1
        bge     .CONT4_4H
        move.w  #HIGH_SEL_BASE_Y*TILE_MULT, d1
        add.w   #3, (HIGH_SEL_NUM)
        bra     .DONE2_4H
.CONT4_4H: cmp.w #(HIGH_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        ble     .DONE2_4H
        move.w  #(HIGH_SEL_BASE_Y+LVL_SEL_SIDEM)*TILE_MULT, d1
        sub.w   #3, (HIGH_SEL_NUM)

        ; UPDATE VARIABLE
.DONE2_4H: move.w d1, (HIGH_SEL_POS_Y)

        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END_4H
        move.b  #1, (KBD_ENTER_PRESS)
        move.w  (HIGH_SEL_NUM), (HIGH_SEL_FNUM)
.END_4H:

        movem.l (a7)+, d0-d1

; ----------------------------------------------------------------------------
; PLOT LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d5, -(a7)
            
        ; --- PAINTING BLACK SQUARES FOR BACKGROUND ----------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE INITIAL COORDINATES
            
        move.w  #HIGH_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOPw_4H:
        move.w  #HIGH_SEL_BASE_Y*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOPw_4H
            
        move.w  #HIGH_SEL_BASE_X*TILE_MULT, d1
        move.w  #4, d5
.LOOP2w_4H:
        move.w  #(HIGH_SEL_BASE_Y+32)*TILE_MULT, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        sub.w   #LVL_SEL_SIDE/2*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X*TILE_MULT, d1
        dbra    d5, .LOOP2w_4H

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPTw_4H:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #25, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #3, d0
        blo     .LOOPTw_4H
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPTw_4H

        jsr     SCRPLOT
        
        
        movem.l d0-d5, -(a7)
        ; --- PAINTING SQUARE FOR LEVEL SELECTION ------------------------
            
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
        
        move.w  (HIGH_SEL_POS_X), d1
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE*TILE_MULT, d3

        move.w  (HIGH_SEL_POS_Y), d2
        sub.w   #(LVL_SEL_SIDE/2)*TILE_MULT, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE*TILE_MULT, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        movem.l (a7)+, d0-d5

        ; --- PAINTING NUMBERS FOR LEVEL SELECTION ---------------------------
        ; a1.l -> tiletable address
        lea.l   tiletable, a1

        ; d0.l -> x index
        moveq.l #0, d0
        ; d2.l -> y index
        moveq.l #0, d2
        ; d3.l -> current number
        moveq.l #0, d3

        ; a0.l -> tile address
        ; d1.l -> tile color
        ; d5.l -> tile x coord
        ; d6.l -> tile y coord
        move.l  #$000000ff, d1
.LOOPT_4H:
        move.l  d3, d7
        lsl.l   #2, d7
        move.l  (a1,d7), a0
        add.l   (tileaddr), a0

        move.l  d0, d5
        lsl.l   #1, d5
        add.l   #25, d5

        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #11, d6
        jsr     drawtilecol

        addq.l  #1, d3                          ; increase current number
        addq.l  #1, d0                          ; increase x index
        cmp.l   #3, d0
        blo     .LOOPT_4H
        moveq.l #0, d0                          ; reset x index
        addq.l  #1, d2                          ; increase y index
        cmp.l   #2, d2
        blo     .LOOPT_4H

        jsr     SCRPLOT

        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        move.b  (KBD_ENTER_PRESS), d0
        cmp.b   #1, d0
        beq     .NEXT_SCR_H
        
        btst.b  #KBD_ESC_POS, (KBD_EDGE)
        bne     LOOP4_L
        
        bra     .LOOP4_H
            
.NEXT_SCR_H: sndplay #SND_MENUSLCTD
        move.b  #5, (SCR_NUM)                   ; CHANGE TO DESIRED SCREEN WHEN DONE
            
        rts










; --- screen 6: pantalla celebracio tetris master type-a ---------------------
screen_congrats_a:
; ----------------------------------------------------------------------------
; INITIALIZE CONGRATULATION TYPE-A USER INTRO WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        ; --- PAINT BLACK SCREEN ---
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; --- PAINTING BITMAP ---
        lea.l   bgcongratulationsa, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        
        ; --- DRAW COLOUR STRING (CONGRATULATIONS) ---        
        lea.l   CONGRATULATIONS, a1
        move.w  #CONGRATS_POS_X, d5
        move.w  #CONGRATS_POS_Y, d6
        move.l  #$000000ff, d1
        jsr     drawstrcol

        ; --- PLOT SCREEN ---
        jsr     scrplot
        
        ; --- ENTER USERNAME INTRO UPDATE AND PLOT ---
        jsr     ENTER_NAME

        rts

; --- screen 7: pantalla celebracio tetris master type-b ---------------------
screen_congrats_b:
; ----------------------------------------------------------------------------
; INITIALIZE CONGRATULATION TYPE-B USER INTRO WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        ; --- PAINT BLACK SCREEN ---
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; --- PAINTING BITMAP ---
        lea.l   bgcongratulationsb, a1
        moveq.l #0, d5
        moveq.l #0, d6
        jsr     drawmap
        
        ; --- DRAW COLOUR STRING (CONGRATULATIONS) ---        
        lea.l   CONGRATULATIONS, a1
        move.w  #CONGRATS_POS_X, d5
        move.w  #CONGRATS_POS_Y, d6
        move.l  #$000000ff, d1
        jsr     drawstrcol
        
        ; --- DRAW BLACK SQUARE ON TOP OF LETTER A ---
        
        ; SET CONTOUR COLOUR
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; SET FILL COLOUR
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        ; DEFINE COORDINATES
        move.w  #CONGR_B_POS_X<<TILE_SHIFT, d1
        move.w  #CONGR_B_POS_Y<<TILE_SHIFT, d2
        move.w  #(CONGR_B_POS_X+1)<<TILE_SHIFT, d3
        move.w  #(CONGR_B_POS_Y+1)<<TILE_SHIFT, d4
        subq.l  #1, d3
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15

        
        ; --- DRAW TILE LETTER B ---
        lea.l   tiletable, a0
        move.w  #LETTER_B, d0                   ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0

        move.w  #CONGR_B_POS_X, d5              ; X pos
        move.w  #CONGR_B_POS_Y, d6              ; Y pos
        jsr     drawtile
        
        ; --- PLOT SCREEN ---
        jsr     scrplot

        ; --- ENTER USERNAME INTRO UPDATE AND PLOT ---
        jsr     ENTER_NAME

        rts












; --- SUBRUTINE THAT UPDATES AND PLOTS THE NAME INTRODUCTION OF THE WINNER ---
ENTER_NAME:
        sndplay #SND_HIGHSCORE, #SND_LOOP
        move.w  #USR_I_POS_X, (LETPOSX)
        move.w  #USR_I_POS_Y, (LETPOSY)         ; ADD +2 OR +4 WHEN IT'S TOP 2 OR TOP 3 RESPECTIVELY
        ; adjust y pos for current high score
        move.w  (USR_HIGHSCORE_POS), d0
        subq.w  #2, d0
.LOOP_ENTER_NAME:
        add.w   #2, (LETPOSY)
        dbra.w  d0, .LOOP_ENTER_NAME

        lea     USR, a0
        move.l  a0, (USRLTRPOS)
        move.w  #USR_MAX_SIZE-1, d0
.LOOP_INIT_CGRTS:
        move.w  #36, (a0)+
        dbra    d0, .LOOP_INIT_CGRTS
            
        move.b  #0, (KBD_EDGE)

        ; --- GET TOP 3 PLAYERS FROM SERVER ---
        jsr     netinit
        move.b  (GME_TYPE), d0
        add.b   #1, d0
        move.w  #3, d1
        move.w  #300, d2                        ; 300*10ms = 3s timeout
        jsr     netscorereq
        jsr     netclose

        lea.l   NET_BUFFER, a0
        lea.l   SCO_NAME, a1
        ; check score list id
        cmp.b   #$03, (a0)+
        bne     .score_done

        ; number of scores
        move.b  (a0)+, d0
        lsl.w   #8, d0
        move.b  (a0)+, d0

        moveq.l #0, d3                          ; score iteration counter
.score_loop:
        move.w  (USR_HIGHSCORE_POS), d1
        subq.l  #1, d1
        cmp.w   d1, d3
        beq     .score_nitr
        ; check score id
        cmp.b   #$02, (a0)+
        bne     .score_done
        moveq.l #0, d2                          ; player character tmp var
        move.w  #0, d1
.player_cpy:
        move.b  (a0)+, d2
        move.b  d2, (a1,d1.w)
        addq.w  #1, d1
        cmp.w   #6, d1
        blo     .player_cpy
        move.b  #0, 6(a1)                       ; add trailing 0 to indicate string end

        move.w  #LVL_SEL_NAME_BASE_X, d5
        move.w  #LVL_SEL_NAME_BASE_Y, d6
        move.l  d3, d2
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawstr

        ; skip game type
        addq.l  #1, a0
        ; player score
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1

        ; convert score to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0
        move.l  #LVL_SEL_SCORE_LEN-1, d2
.score_clr:
        move.b  #0, (a0)+
        dbra    d2, .score_clr

        move.l  d1, d0
        move.l  #LVL_SEL_SCORE_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_SCORE_BASE_X, d5
        move.w  #LVL_SEL_SCORE_BASE_Y, d6
        moveq.l #LVL_SEL_SCORE_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0

        ; game level
        moveq.l #0, d1
        move.b  (a0)+, d1
        lsl.w   #8, d1
        move.b  (a0)+, d1
        ; convert level to decimal digit array
        movem.l d0/a0, -(a7)
        lea.l   SCO_SCORE, a0                   ; reuse score array
        move.l  #LVL_SEL_LEVEL_LEN-1, d2
.score_clr2:
        move.b  #0, (a0)+
        dbra    d2, .score_clr2

        move.l  d1, d0
        move.l  #LVL_SEL_LEVEL_LEN, d1
        lea.l   SCO_SCORE, a0
        jsr     bcd
        move.l  a0, a1
        move.w  #LVL_SEL_LEVEL_BASE_X, d5
        move.w  #LVL_SEL_LEVEL_BASE_Y, d6
        moveq.l #LVL_SEL_LEVEL_LEN, d4
        move.l  d3, d2
        move.l  d3, -(a7)
        moveq.l #1, d3
        lsl.l   #1, d2
        add.w   d2, d6
        jsr     drawdigits
        move.l  (a7)+, d3
        movem.l (a7)+, d0/a0
.score_nitr:
        addq.l  #1, d3
        cmp.w   d0, d3
        blo     .score_loop
.score_done:

        move.w  #LVL_SEL_SCORE_BASE_X, d5
        move.w  (LETPOSY), d6
        move.l  (score), d0
        move.b  #1, d3
        move.b  #5, d4
        jsr     drawnum

        move.w  #LVL_SEL_LEVEL_BASE_X, d5
        move.w  (LETPOSY), d6
        moveq.l #0, d0
        move.w  (levelcnt), d0
        move.b  #1, d3
        move.b  #3, d4
        jsr     drawnum

        jsr     scrplot

.LOOP_CONGR:
; --- UPDATE -----------------------------------------------------------------

; READ INPPUT DEVICES
        jsr     kbdupd
; ----------------------------------------------------------------------------
; UPDATE TYPE AND MUSIC SELECTION POSITION.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------

        movem.l d0-d1, -(a7)
            
        lea     USR, a0
                      
        ; UPDATE COORDINATE X
        move.l  (USRLTRPOS), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT
        sndplay #SND_MENUSLCT
        sub.l   #2, d0
        move.l  d0, (USRLTRPOS)
.CHKLFT: btst.b #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        sndplay #SND_MENUSLCT
        add.l   #2, d0
        move.l  d0, (USRLTRPOS)
            
        ; CHECK COLLISIONS
.CONT:  move.l  a0, d1
        cmp.w   d1, d0
        bge     .CONT2
        move.l  d1, (USRLTRPOS)
        bra     .DONE1
.CONT2: add.w   #10, d1
        cmp.w   d1, d0
        ble     .DONE1
        move.l  d1, (USRLTRPOS)
            
.DONE1:
        move.l  USRLTRPOS, a1
        ; UPDATE COORDINATE Y
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sndplay #SND_MENUSLCT
        move.w  (a1), d0
        add.w   #1, d0
        move.w  d0, (a1)
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        sndplay #SND_MENUSLCT
        move.w  (a1), d0
        sub.w   #1, d0
        move.w  d0, (a1)
            
        ; CHECK COLLISIONS
.CONT3: move.w  (a1), d0
        cmp.w   #0, d0
        bge     .CONT4
        move.w  #44, (a1)
        bra     .DONE2
.CONT4: move.w  (a1), d0

        cmp.w   #37, d0
        bne     .MISSCHAR
        move.w  #39, (a1)
.MISSCHAR:
        cmp.w   #38, d0
        bne     .MISSCHAR1
        move.w  #36, (a1)
.MISSCHAR1:
        cmp.w   #44, d0
        ble     .DONE2
        move.w  #0, (a1)

.DONE2:
        movem.l (a7)+, d0-d1

; ----------------------------------------------------------------------------
; PLOT TYPE AND MUSIC SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        
        move.w  #5, d1
        lea     USR, a1
            
        ; --- THIS LOOP PAINTS ALL CARACTERS FROM FIRST TO LAST ---
.LOOP51:
        move.l  (USRLTRPOS), d2
        move.l  a1, d3
            
        ; paint one tile
        lea.l   tiletable, a0
        move.w  (a1)+, d0                       ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   (tileaddr), a0
            
        cmp     d2, d3
        bne     .ISNOTCOL
            
        movem.l d0-d4, -(a7)
            
        ; --- PAINT CARACTER BACKGROUND (SELECTED) ---
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        move.b  #81, d0
        move.l  #LVL_SEL_COL, d1
        trap    #15
            
        move.b  #87, d0
        move.w  (LETPOSX), d1                   ; LX POS
        lsl.l   #4, d1
        sub.w   #1, d1
            
        move.w  (LETPOSY), d2                   ; UY POS
        lsl.l   #4, d2
        sub.w   #1, d2
            
        move.w  d1, d3
        add.w   #16, d3
            
        move.w  d2, d4
        add.w   #16, d4
            
        mulu.w  #TILE_MULT, d1
        mulu.w  #TILE_MULT, d2
        mulu.w  #TILE_MULT, d3
        mulu.w  #TILE_MULT, d4
            
        trap    #15
            
        jsr     scrplot                         ; IF NOT COMMENTED, THE LETTER "BLINKS"

        movem.l (a7)+, d0-d4
            
        bra     .CONTINUE
            
.ISNOTCOL:
        movem.l d0-d4, -(a7)
            
        ; --- PAINT CARACTER BACKGROUND (NOT SELECTED) ---
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15
            
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15
            
        move.b  #87, d0
        move.w  (LETPOSX), d1                   ; LX POS
        lsl.l   #4, d1
        sub.w   #1, d1
            
        move.w  (LETPOSY), d2                   ; UY POS
        lsl.l   #4, d2
        sub.w   #1, d2
            
        move.w  d1, d3
        add.w   #16, d3
            
        move.w  d2, d4
        add.w   #16, d4
            
        mulu.w  #TILE_MULT, d1
        mulu.w  #TILE_MULT, d2
        mulu.w  #TILE_MULT, d3
        mulu.w  #TILE_MULT, d4
            
        trap    #15
            
        movem.l (a7)+, d0-d4
            
.CONTINUE:
        ; --- PAINT CARACTER TILE ---
        move.w  (LETPOSX), d5                   ; x pos
        move.w  (LETPOSY), d6                   ; y pos
        jsr     drawtile
            
        add.w   #1, (LETPOSX)
            
        dbra    d1, .LOOP51
            
        move.w  #USR_I_POS_X, (LETPOSX)
            
            
        jsr     scrplot


        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        bne     .FIN_CONGR
        bra     .LOOP_CONGR
.FIN_CONGR:
        sndplay #SND_MENUSLCTD

        lea.l   USR, a0
        lea.l   .tile2chr, a2
        lea.l   .player_name, a1
        moveq.l #5, d0
.name_loop:
        move.w  (a0), d1
        move.b  (a2,d1.w), d1
        move.b  d1, (a1)+
        addq.l  #2, a0
        dbra    d0, .name_loop

        jsr     netinit

        move.b  (GME_TYPE), d0
        add.b   #1, d0
        move.l  (score), d1
        move.l  #300, d2
        move.w  (levelcnt), d3
        lea.l   .player_name, a1
        jsr     netscorepub
        jsr     netclose

        move.b  #1, (SCR_NUM)
        sndplay #SND_HIGHSCORE, #SND_STOP

        rts
.tile2chr:
        dc.b    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ   ,/()"!'
        ds.w    0
.player_name:
        ds.b    6
        ds.w    0
