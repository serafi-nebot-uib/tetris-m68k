screen_legal:
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        lea.l   .txt1, a1
        move.w  #.basex, d5
        move.w  #.basey, d6
        jsr     drawstr

        lea.l   .txt2, a2
        move.w  #.basex+9, d5
        jsr     drawstr

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
        add.l   #tiles, a0
        move.l  #.coldarkblue, d1

        move.w  #.basex+7, d5
        move.w  #.basey, d6
        jsr     drawtilecol

        move.w  #.basex-2, d5
        move.w  #.basey+8, d6
        jsr     drawtilecol

        jsr     scrplot

        move.l  #50*5, (SNC_CNT_DOWN)           ; 5 second timer
.loop:
        jsr     kbdupd
        btst.b  #7, (KBD_EDGE)
        bne     .done
        tst.l   (SNC_CNT_DOWN)
        bgt     .loop
.done:
        move.b  #1, (SCR_NUM)

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

screen_start:
        clr.w   (BUTT_PRESS)
        clr.w   (MOUSE_POS_X)
        clr.w   (MOUSE_POS_Y)
        clr.b   (MOUSE_VAL)

        ; --- PAINT SCREEN TO BLACK ---
        jsr     scrclr

        ; --- PAINTING BITMAP ---
        moveq.l #0, d5
        moveq.l #0, d6
        lea.l   bghome, a1
        jsr     drawmap

        jsr     scrplot
        simhalt
;             
; .LOOP:
; ; --- UPDATE -----------------------------------------------------------------
;
; ; READ INPPUT DEVICES
;
;         trap    #0                              ; MOUSE
;             
; ; ----------------------------------------------------------------------------
; ; UPDATE SCREEN 1: MOUSE UPDATE
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;
;             
;
; ; ----------------------------------------------------------------------------
; ; PLOT SCREEN 1
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;             
;             
;             
; *            ADDQ.W  #1,(BUTPRESS)
;             
;
;         move.w  (BUTPRESS), d0
;         cmp.w   #1, d0
;         beq     .FIN
;             
;         bra     .LOOP
;             
; .FIN:        
;         move.w  #3, (SCREENNUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
;         rts
;
;
;
;
;
;
;
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
; ; --- SCREEN 2: Pantalla selecció Type (A/B) - Music(1/2/3) ------------------
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
;
; SCREEN2:
;
;
;
;         rts
;             
;             
;             
;             
;             
;             
;
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
; ; --- SCREEN 3: Pantalla Selecció Nivell A-Type ------------------------------
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
;
; SCREEN3:
; ; ----------------------------------------------------------------------------
; ; INITIALIZE LEVEL SELECTION WINDOW.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;         move.w  #SQRIPOSX, (SQRPOSX)
;         move.w  #SQRIPOSY, (SQRPOSY)
;         move.w  #NUMIPOS1, (NUMPOS)
;         move.w  #0, (NUMSEL)
;         move.w  #-1, (NUMFSEL)
;         move.w  #0, (ENTRPRESS)
;             
;         ; --- PAINT BLACK SCREEN ---
;         move.b  #11, d0
;         move.w  #$ff00, d1
;         trap    #15
;             
;         ; --- PAINTING BITMAP ---
;         lea.l   bgscore, a0
;         jsr     drawmap
;             
;         trap    #2                              ; DOUBLE BUFFER
;
; .LOOP3:
; ; --- UPDATE -----------------------------------------------------------------
;
; ; READ INPPUT DEVICES
;
;         trap    #1                              ; KEYBOARD
;             
; ; ----------------------------------------------------------------------------
; ; UPDATE LEVEL SELECTION SQUARE POSITION.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;
;         movem.l d0-d1, -(a7)
;             
;         ; UPDATE COORDINATE X
;         move.w  (SQRPOSX), d0
;         btst.b  #0, (KBDEDGE)
;         beq     .CHKLFT
;         sub.w   #SQRSIDEM, d0
;         sub.w   #1, (NUMSEL)
; .CHKLFT: btst.b #2, (KBDEDGE)
;         beq     .CONT
;         add.w   #SQRSIDEM, d0
;         add.w   #1, (NUMSEL)
;             
;         ; CHECK COLLISIONS
; .CONT:  cmp.w   #SQRIPOSX, d0
;         bge     .CONT2
;         move.w  #SQRIPOSX, d0
;         add.w   #1, (NUMSEL)
;         bra     .DONE1
; .CONT2: cmp.w   #SQRIPOSX+SQRSIDEM*4, d0
;         ble     .DONE1
;         move.w  #SQRIPOSX+SQRSIDEM*4, d0
;         sub.w   #1, (NUMSEL)
;
;         ; UPDATE VARIABLE
; .DONE1: move.w  d0, (SQRPOSX)
;
;         ; UPDATE COORDINATE Y
;         move.w  (SQRPOSY), d1
;         btst.b  #1, (KBDEDGE)
;         beq     .CHKUP
;         sub.w   #SQRSIDEM, d1
;         sub.w   #5, (NUMSEL)
; .CHKUP: btst.b  #3, (KBDEDGE)
;         beq     .CONT3
;         add.w   #SQRSIDEM, d1
;         add.w   #5, (NUMSEL)
;             
;         ; CHECK COLLISIONS
; .CONT3: cmp.w   #SQRIPOSY, d1
;         bge     .CONT4
;         move.w  #SQRIPOSY, d1
;         add.w   #5, (NUMSEL)
;         bra     .DONE2
; .CONT4: cmp.w   #SQRIPOSY+SQRSIDEM, d1
;         ble     .DONE2
;         move.w  #SQRIPOSY+SQRSIDEM, d1
;         sub.w   #5, (NUMSEL)
;
;         ; UPDATE VARIABLE
; .DONE2: move.w  d1, (SQRPOSY)
;
;         ; CHECK FOR ENTER
;         btst.b  #4, (KBDEDGE)
;         beq     .END
;         move.b  #1, (ENTRPRESS)
;         move.w  (NUMSEL), (NUMFSEL)
; .END:
;
;         movem.l (a7)+, d0-d1
;
; ; ----------------------------------------------------------------------------
; ; PLOT LEVEL SELECTION WINDOW.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;
;         movem.l d0-d5, -(a7)
;             
;         ; --- PAINTING BLACK SQUARES FOR BACKGROUND ----------------------
;             
;         ; SET CONTOUR COLOUR
;         move.b  #80, d0
;         move.l  #BLACK, d1
;         trap    #15
;             
;         ; SET FILL COLOUR
;         move.b  #81, d0
;         move.l  #BLACK, d1
;         trap    #15
;             
;         ; DEFINE INITIAL COORDINATES
;             
;         move.w  #SQRIPOSX, d1
;         move.w  #4, d5
; .LOOP:
;         move.w  #SQRIPOSY, d2
;         ; DEFINE COORDINATES
;         sub.w   #SQRSIDE/2, d1
;         move.w  d1, d3
;         add.w   #SQRSIDE, d3
;
;         sub.w   #SQRSIDE/2, d2
;         move.w  d2, d4
;         add.w   #SQRSIDE, d4
;             
;         ; DRAW SQUARE
;         move.b  #87, d0
;         trap    #15
;             
;         add.w   #SQRMBLACKX, d1
;         dbra    d5, .LOOP
;             
;         move.w  #SQRIPOSX, d1
;         move.w  #4, d5
; .LOOP2:
;         move.w  #SQRIPOSY+32, d2
;         ; DEFINE COORDINATES
;         sub.w   #SQRSIDE/2, d1
;         move.w  d1, d3
;         add.w   #SQRSIDE, d3
;
;         sub.w   #SQRSIDE/2, d2
;         move.w  d2, d4
;         add.w   #SQRSIDE, d4
;             
;         ; DRAW SQUARE
;         move.b  #87, d0
;         trap    #15
;             
;         add.w   #SQRMBLACKX, d1
;         dbra    d5, .LOOP2
;
;             
;             
;         ; --- PAINTING SQUARE FOR LEVEL SELECTION ------------------------
;             
;         ; SET CONTOUR COLOUR
;         move.b  #80, d0
;         move.l  #LVL_SEL_COL, d1
;         trap    #15
;             
;         ; SET FILL COLOUR
;         move.b  #81, d0
;         move.l  #LVL_SEL_COL, d1
;         trap    #15
;             
;         ; DEFINE COORDINATES
;         move.w  (SQRPOSX), d1
;         sub.w   #SQRSIDE/2, d1
;         move.w  d1, d3
;         add.w   #SQRSIDE, d3
;
;         move.w  (SQRPOSY), d2
;         sub.w   #SQRSIDE/2, d2
;         move.w  d2, d4
;         add.w   #SQRSIDE, d4
;             
;         ; DRAW SQUARE
;         move.b  #87, d0
;         trap    #15
;             
;         movem.l (a7)+, d0-d5
;             
;             
;             
;         ; --- PAINTING NUMBERS FOR LEVEL SELECTION (0-4) -----------------
;         move.w  #4, d1
;             
;         move.w  #-1, d2
;         move.w  #9, d3
; .LOOPT:
;         ; paint one tile
;         lea.l   tiletable, a1
;         add.w   #1, d2
;         move.w  d2, d0                          ; tile index
;         lsl.l   #2, d0
;         move.l  (a1,d0), d0
;         lea.l   tiles, a2
;         add.l   d0, a2
;
;         move.l  a2, -(a7)
;         move.w  #11, -(a7)                      ; y pos
;         add.w   #2, d3
;         move.w  d3, -(a7)                       ; x pos
;         move.l  #$000000ff, -(a7)               ; HEX COLOUR
;         jsr     drawtilecol
;         add.w   #12, a7
;
;             
;         dbra    d1, .LOOPT
;             
;             
;         ; --- PAINTING NUMBERS FOR LEVEL SELECTION -----------------------
;         move.w  #4, d1
;             
;         move.w  #4, d2
;         move.w  #9, d3
; .LOOPT2:
;         ; paint one tile
;         lea.l   tiletable, a1
;         add.w   #1, d2
;         move.w  d2, d0                          ; tile index
;         lsl.l   #2, d0
;         move.l  (a1,d0), d0
;         lea.l   tiles, a2
;         add.l   d0, a2
;
;         move.l  a2, -(a7)
;         move.w  #13, -(a7)                      ; y pos
;         add.w   #2, d3
;         move.w  d3, -(a7)                       ; x pos
;         move.l  #$000000ff, -(a7)               ; HEX COLOUR
;         jsr     drawtilecol
;         add.w   #12, a7
;
;             
;         dbra    d1, .LOOPT2
;             
;         ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
;             
;         move.b  (ENTRPRESS), d0
;         cmp.b   #1, d0
;         beq     .FIN31
;             
;         btst.b  #6, (KBDEDGE)
;         bne     .FIN32
;             
;         trap    #2
;
;         bra     .LOOP3
;             
; .FIN32: move.w  #1, (SCREENNUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
;             
;         rts
;             
; .FIN31: move.w  #5, (SCREENNUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
;             
;         rts
;
;
; *            ; paint one tile
; *            lea.l   tiletable,a1
; *            move.w  (A0)+,d0                   ; tile index
; *            lsl.l   #2,d0
; *            move.l  (a1,d0),d0
; *            lea.l   tiles,a2
; *            add.l   d0,a2
;
;
;
;
;
;
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
; ; --- SCREEN 4: Pantalla Selecció Nivell B-Type ------------------------------
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
;
; SCREEN4:
;
;
;
;
;         rts
;
;
;
;
;
;
;
;
;
;
;
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
; ; --- SCREEN 5: Pantalla Username HighScore ----------------------------------
; ; ----------------------------------------------------------------------------
; ; ----------------------------------------------------------------------------
;
; SCREEN5:
;
; ; ----------------------------------------------------------------------------
; ; INITIALIZE HIGHSCORE USER SCREEN.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;         move.w  #0, (ENTRPRESS)
;         move.w  #USRIPOSX, (LETPOSX)
;         move.w  #USRIPOSY, (LETPOSY)
;         lea     USR, a0
;         move.l  a0, (USRLTRPOS)
;         move.w  #USRMAXSIZE-1, d0
; .LOOP:
;         move.w  #36, (a0)+
;         dbra    d0, .LOOP
;             
;         ; --- PAINT SCREEN TO BLACK ---
;             
;         move.b  #11, d0
;         move.w  #$ff00, d1
;         trap    #15
;             
;         ; --- PAINTING BITMAP ---
;         lea.l   bgscore, a0
;         jsr     drawmap
;             
;         trap    #2                              ; DOUBLE BUFFER
;
;             
;
; .LOOP5:
; ; --- UPDATE -----------------------------------------------------------------
;
; ; READ INPPUT DEVICES
;
;         trap    #1                              ; KEYBOARD
;             
; ; ----------------------------------------------------------------------------
; ; UPDATE HIGHSCORE USER SCREEN.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;
;         movem.l d0-d1, -(a7)
;             
;         lea     USR, a0
;               
;         ; PROBLEMA: TIENE QUE ESTAR PULSANDO AMBAS TECLAS PARA MOVERLA
;           
;         ; UPDATE COORDINATE X
;         move.l  (USRLTRPOS), d0
;         btst.b  #0, (KBDEDGE)
;         beq     .CHKLFT
;         sub.l   #2, d0
;         move.l  d0, (USRLTRPOS)
; .CHKLFT: btst.b #2, (KBDEDGE)
;         beq     .CONT
;         add.l   #2, d0
;         move.l  d0, (USRLTRPOS)
;             
;         ; CHECK COLLISIONS
; .CONT:  move.l  a0, d1
;         cmp.w   d1, d0
;         bge     .CONT2
;         move.l  d1, (USRLTRPOS)
;         bra     .DONE1
; .CONT2: add.w   #10, d1
;         cmp.w   d1, d0
;         ble     .DONE1
;         move.l  d1, (USRLTRPOS)
;             
; .DONE1:
;         move.l  USRLTRPOS, a1
;         ; UPDATE COORDINATE Y
;         btst.b  #1, (KBDEDGE)
;         beq     .CHKUP
;         move.w  (a1), d0
;         add.w   #1, d0
;         move.w  d0, (a1)
; .CHKUP: btst.b  #3, (KBDEDGE)
;         beq     .CONT3
;         move.w  (a1), d0
;         sub.w   #1, d0
;         move.w  d0, (a1)
;             
;         ; CHECK COLLISIONS
; .CONT3: move.w  (a1), d0
;         cmp.w   #0, d0
;         bge     .CONT4
;         move.w  #36, (a1)
;         bra     .DONE2
; .CONT4: move.w  (a1), d0
;         cmp.w   #36, d0
;         ble     .DONE2
;         move.w  #0, (a1)
;
; .DONE2:
;
;         ; CHECK FOR ENTER
;         btst.b  #4, (KBDEDGE)
;         beq     .END
;         move.b  #1, (ENTRPRESS)
; .END:
;
;         movem.l (a7)+, d0-d1
;
; ; ----------------------------------------------------------------------------
; ; PLOT HIGHSCORE USER SCREEN.
; ; INPUT    : NONE 
; ; OUTPUT   : NONE
; ; MODIFIES : NONE
; ; ----------------------------------------------------------------------------
;             
;         move.w  #5, d1
;         lea     USR, a0
; .LOOP51:
;         move.l  (USRLTRPOS), d2
;         move.l  a0, d3
;             
;         ; USED: D0,D1,A0,A1,A2
;             
;         ; paint one tile
;         lea.l   tiletable, a1
;         move.w  (a0)+, d0                       ; tile index
;         lsl.l   #2, d0
;         move.l  (a1,d0), d0
;         lea.l   tiles, a2
;         add.l   d0, a2
;             
;         cmp     d2, d3
;         bne     .ISNOTCOL
;             
;             
;         movem.l d0-d4, -(a7)
;             
;         move.b  #80, d0
;         move.l  #BLACK, d1
;         trap    #15
;             
;         move.b  #81, d0
;         move.l  #LVL_SEL_COL, d1
;         trap    #15
;             
;         move.b  #87, d0
;         move.w  (LETPOSX), d1                   ; LX POS
;         lsl.l   #4, d1
;         sub.w   #1, d1
;             
;         move.w  (LETPOSY), d2                   ; UY POS
;         lsl.l   #4, d2
;         sub.w   #1, d2
;             
;         move.w  d1, d3
;         add.w   #16, d3
;             
;         move.w  d2, d4
;         add.w   #16, d4
;             
;         trap    #15
;             
;         trap    #2                              ; IF NOT COMMENTED, THE LETTER BLINKS
;
;         movem.l (a7)+, d0-d4
;             
;         bra     .CONTINUE
;             
; .ISNOTCOL:
;         movem.l d0-d4, -(a7)
;             
;         move.b  #80, d0
;         move.l  #BLACK, d1
;         trap    #15
;             
;         move.b  #81, d0
;         move.l  #BLACK, d1
;         trap    #15
;             
;         move.b  #87, d0
;         move.w  (LETPOSX), d1                   ; LX POS
;         lsl.l   #4, d1
;         sub.w   #1, d1
;             
;         move.w  (LETPOSY), d2                   ; UY POS
;         lsl.l   #4, d2
;         sub.w   #1, d2
;             
;         move.w  d1, d3
;         add.w   #16, d3
;             
;         move.w  d2, d4
;         add.w   #16, d4
;             
;         trap    #15
;             
;         movem.l (a7)+, d0-d4
;             
; .CONTINUE:
;         move.l  a2, -(a7)
;         move.w  (LETPOSY), -(a7)                ; y pos
;         move.w  (LETPOSX), -(a7)                ; x pos
;         jsr     drawtile
;         addq.w  #8, a7
;             
;         add.w   #1, (LETPOSX)
;             
;         dbra    d1, .LOOP51
;             
;         move.w  #USRIPOSX, (LETPOSX)
;             
;
;             
;         move.b  (ENTRPRESS), d0
;         cmp.b   #1, d0
;         beq     .FIN51
;             
;         btst.b  #6, (KBDEDGE)
;         bne     .FIN52
;             
;         trap    #2
;
;         bra     .LOOP5
;             
; .FIN52: move.w  #3, (SCREENNUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
;
;         rts
;             
;             
; .FIN51: move.w  #1, (SCREENNUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
;
;         rts
