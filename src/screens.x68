; TODO: add mouse to legal and start screens

screen_legal:
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
        add.l   #tiles, a0
        move.l  #.coldarkblue, d1

        move.w  #.basex+7, d5
        move.w  #.basey, d6
        jsr     drawtilecol

        move.w  #.basex-2, d5
        move.w  #.basey+8, d6
        jsr     drawtilecol

        jsr     scrplot

        move.l  #SNC_TIME_S*5, (SNC_CNT_DOWN)   ; 5 second timer
.loop:
        jsr     kbdupd
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        bne     .done
        tst.l   (SNC_CNT_DOWN)
        bgt     .loop
.done:
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
        clr.w   (BUTT_PRESS)
        clr.w   (MOUSE_POS_X)
        clr.w   (MOUSE_POS_Y)
        clr.b   (MOUSE_VAL)

        jsr     scrclr
        moveq.l #0, d5
        moveq.l #0, d6
        lea.l   bghome, a1
        jsr     drawmap
        jsr     scrplot
.loop:
        jsr     mouseupd
        btst.b  #0, (MOUSE_VAL)
        beq     .loop
.done:
        move.b  #2, (SCR_NUM)
        rts

; --- screen_type: pantalla de seleccio de type i music ----------------------
screen_type:
; ----------------------------------------------------------------------------
; INITIALIZE TYPE AND MUSIC SELECTION SCREEN.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        move.b  #0, (GAME_TYPE)
        move.b  #0, (GAME_MUSIC)
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
            
        ;; UPDATE COORDINATE X
        move.b  (GAME_TYPE), d0
        btst.b  #KBD_LEFT_POS, (KBD_EDGE)
        beq     .CHKLFT
        sub.b   #1, d0
        sub.b   #1, (GAME_TYPE)
.CHKLFT:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        add.b   #1, d0
        add.b   #1, (GAME_TYPE)
            
        ; CHECK COLLISIONS
.CONT:  cmp.b   #0, d0
        bge     .CONT2
        move.b  #0, d0
        move.b  #0, (GAME_TYPE)
        bra     .DONE1
.CONT2: cmp.b   #1, d0
        ble     .DONE1
        move.b  #1, d0
        move.b  #1, (GAME_TYPE)

        ; UPDATE VARIABLE
.DONE1: move.b  d0, (GAME_TYPE)

        ; UPDATE COORDINATE Y
        move.b  (GAME_MUSIC), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sub.b   #1, d1
        sub.b   #1, (GAME_MUSIC)
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        add.b   #1, d1
        add.b   #1, (GAME_MUSIC)
            
        ; CHECK COLLISIONS
.CONT3: cmp.b   #0, d1
        bge     .CONT4
        move.b  #0, d1
        add.b   #1, (GAME_MUSIC)
        bra     .DONE2
.CONT4: cmp.b   #3, d1
        ble     .DONE2
        move.b  #3, d1
        sub.b   #1, (GAME_MUSIC)

        ; UPDATE VARIABLE
.DONE2: move.b  d1, (GAME_MUSIC)

        ; CHECK FOR ENTER
        btst.b  #KBD_ENTER_POS, (KBD_EDGE)
        beq     .END
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
        add.l   #TILES, a0
            
        move.w  #TAM_TYPE_POS_Y, d6             ; y pos
        move.w  #TAM_TYPE_POS_X, d5             ; x pos
        cmp.b   #0, (GAME_TYPE)
        beq     .typea
        addi.b  #12, d5
.typea:
        jsr     drawtile
            
            
        ; --- TYPE RIGHT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_RIGHT_ARROW, d0            ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   #TILES, a0
            
        move.w  #TAM_TYPE_POS_Y, d6             ; y pos
        move.w  #TAM_TYPE_POS_X+7, d5           ; x pos
        cmp.b   #0, (GAME_TYPE)
        beq     .typea1
        addi.b  #12, d5
.typea1:
        jsr     drawtile
            
            
        ; --- MUSIC LEFT ARROW
        lea.l   tiletable, a0
        move.w  #TAM_LEFT_ARROW, d0             ; tile index
        lsl.l   #2, d0
        move.l  (a0,d0), a0
        add.l   #TILES, a0
            
        move.w  #TAM_MUSIC_POS_Y, d6            ; y pos
        move.w  #TAM_MUSIC_POS_X, d5            ; x pos
        cmp.b   #0, (GAME_MUSIC)
        beq     .DONE
        cmp.b   #1, (GAME_MUSIC)
        beq     .MUSIC2
        cmp.b   #2, (GAME_MUSIC)
        beq     .MUSIC3
        cmp.b   #3, (GAME_MUSIC)
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
        add.l   #TILES, a0
            
        move.w  #TAM_MUSIC_POS_Y, d6            ; y pos
        move.w  #TAM_MUSIC_POS_X+9, d5          ; x pos
        cmp.b   #0, (GAME_MUSIC)
        beq     .DONER
        cmp.b   #1, (GAME_MUSIC)
        beq     .MUSIC2R
        cmp.b   #2, (GAME_MUSIC)
        beq     .MUSIC3R
        cmp.b   #3, (GAME_MUSIC)
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
        bra     .LOOP2

.FIN2:  move.b  #3, (SCR_NUM)
        rts






; --- screen 3: pantalla selecció nivell a-type ------------------------------
screen_level:
; ----------------------------------------------------------------------------
; INITIALIZE LEVEL SELECTION WINDOW.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : NONE
; ----------------------------------------------------------------------------
        move.w  #LVL_SEL_BASE_X, (LVL_SEL_POS_X)
        move.w  #LVL_SEL_BASE_Y, (LVL_SEL_POS_Y)
        move.w  #LVL_SEL_NUM_POS1, (LVL_SEL_NUM_POS)
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
        sub.w   #LVL_SEL_SIDEM, d0
        sub.w   #1, (LVL_SEL_NUM)
.CHKLFT:
        btst.b  #KBD_RIGHT_POS, (KBD_EDGE)
        beq     .CONT
        add.w   #LVL_SEL_SIDEM, d0
        add.w   #1, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT:  cmp.w   #LVL_SEL_BASE_X, d0
        bge     .CONT2
        move.w  #LVL_SEL_BASE_X, d0
        add.w   #1, (LVL_SEL_NUM)
        bra     .DONE1
.CONT2: cmp.w   #LVL_SEL_BASE_X+LVL_SEL_SIDEM*4, d0
        ble     .DONE1
        move.w  #LVL_SEL_BASE_X+LVL_SEL_SIDEM*4, d0
        sub.w   #1, (LVL_SEL_NUM)

        ; UPDATE VARIABLE
.DONE1: move.w  d0, (LVL_SEL_POS_X)

        ; UPDATE COORDINATE Y
        move.w  (LVL_SEL_POS_Y), d1
        btst.b  #KBD_UP_POS, (KBD_EDGE)
        beq     .CHKUP
        sub.w   #LVL_SEL_SIDEM, d1
        sub.w   #5, (LVL_SEL_NUM)
.CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
        beq     .CONT3
        add.w   #LVL_SEL_SIDEM, d1
        add.w   #5, (LVL_SEL_NUM)
            
        ; CHECK COLLISIONS
.CONT3: cmp.w   #LVL_SEL_BASE_Y, d1
        bge     .CONT4
        move.w  #LVL_SEL_BASE_Y, d1
        add.w   #5, (LVL_SEL_NUM)
        bra     .DONE2
.CONT4: cmp.w   #LVL_SEL_BASE_Y+LVL_SEL_SIDEM, d1
        ble     .DONE2
        move.w  #LVL_SEL_BASE_Y+LVL_SEL_SIDEM, d1
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
            
        move.w  #LVL_SEL_BASE_X, d1
        move.w  #4, d5
.LOOP:
        move.w  #LVL_SEL_BASE_Y, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE, d3

        sub.w   #LVL_SEL_SIDE/2, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X, d1
        dbra    d5, .LOOP
            
        move.w  #LVL_SEL_BASE_X, d1
        move.w  #4, d5
.LOOP2:
        move.w  #LVL_SEL_BASE_Y+32, d2
        ; DEFINE COORDINATES
        sub.w   #LVL_SEL_SIDE/2, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE, d3

        sub.w   #LVL_SEL_SIDE/2, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE, d4
            
        ; DRAW SQUARE
        move.b  #87, d0
        trap    #15
            
        add.w   #LVL_SEL_BLACK_X, d1
        dbra    d5, .LOOP2



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
        move.w  (LVL_SEL_POS_X), d1
        sub.w   #LVL_SEL_SIDE/2, d1
        move.w  d1, d3
        add.w   #LVL_SEL_SIDE, d3

        move.w  (LVL_SEL_POS_Y), d2
        sub.w   #LVL_SEL_SIDE/2, d2
        move.w  d2, d4
        add.w   #LVL_SEL_SIDE, d4
            
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
        add.l   #tiles, a0

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

        jsr     scrplot

        ; --- CHECKING IF ENTER BUTTON IS PRESSED ------------------------
        move.b  (KBD_ENTER_PRESS), d0
        cmp.b   #1, d0
        beq     .FIN3
        bra     .LOOP3

.FIN3:  move.b  #4, (SCR_NUM)
        jsr     scrplot
        rts














; ; ; ----------------------------------------------------------------------------
; ; ; ----------------------------------------------------------------------------
; ; ; --- SCREEN 4: Pantalla Selecció Nivell B-Type ------------------------------
; ; ; ----------------------------------------------------------------------------
; ; ; ----------------------------------------------------------------------------
; ;
; ; SCREEN4:
; ;
; ;
; ;
; ;
; ;         rts
; ;
; ; ; ----------------------------------------------------------------------------
; ; ; ----------------------------------------------------------------------------
; ; ; --- SCREEN 5: Pantalla Username HighScore ----------------------------------
; ; ; ----------------------------------------------------------------------------
; ; ; ----------------------------------------------------------------------------
; ;
; ; SCREEN5:
; ;
; ; ; ----------------------------------------------------------------------------
; ; ; INITIALIZE HIGHSCORE USER SCREEN.
; ; ; INPUT    : NONE 
; ; ; OUTPUT   : NONE
; ; ; MODIFIES : NONE
; ; ; ----------------------------------------------------------------------------
; ;         move.w  #0, (KBD_ENTER_PRESS)
; ;         move.w  #USRIPOSX, (LETPOSX)
; ;         move.w  #USRIPOSY, (LETPOSY)
; ;         lea     USR, a0
; ;         move.l  a0, (USRLTRPOS)
; ;         move.w  #USRMAXSIZE-1, d0
; ; .LOOP:
; ;         move.w  #36, (a0)+
; ;         dbra.w    d0, .LOOP
; ;             
; ;         ; --- PAINT SCREEN TO BLACK ---
; ;             
; ;         move.b  #11, d0
; ;         move.w  #$ff00, d1
; ;         trap    #15
; ;             
; ;         ; --- PAINTING BITMAP ---
; ;         lea.l   bgscore, a0
; ;         jsr     drawmap
; ;             
; ;         jsr scrplot
; ;
; ;             
; ;
; ; .LOOP5:
; ; ; --- UPDATE -----------------------------------------------------------------
; ;
; ; ; READ INPPUT DEVICES
; ;
; ;         jsr kbdupd
; ;             
; ; ; ----------------------------------------------------------------------------
; ; ; UPDATE HIGHSCORE USER SCREEN.
; ; ; INPUT    : NONE 
; ; ; OUTPUT   : NONE
; ; ; MODIFIES : NONE
; ; ; ----------------------------------------------------------------------------
; ;
; ;         movem.l d0-d1, -(a7)
; ;             
; ;         lea     USR, a0
; ;               
; ;         ; PROBLEMA: TIENE QUE ESTAR PULSANDO AMBAS TECLAS PARA MOVERLA
; ;           
; ;         ; UPDATE COORDINATE X
; ;         move.l  (USRLTRPOS), d0
; ;         btst.b  #KBD_LEFT_POS, (KBD_EDGE)
; ;         beq     .CHKLFT
; ;         sub.l   #2, d0
; ;         move.l  d0, (USRLTRPOS)
; ; .CHKLFT: btst.b #KBD_RIGHT_POS, (KBD_EDGE)
; ;         beq     .CONT
; ;         add.l   #2, d0
; ;         move.l  d0, (USRLTRPOS)
; ;             
; ;         ; CHECK COLLISIONS
; ; .CONT:  move.l  a0, d1
; ;         cmp.w   d1, d0
; ;         bge     .CONT2
; ;         move.l  d1, (USRLTRPOS)
; ;         bra     .DONE1
; ; .CONT2: add.w   #10, d1
; ;         cmp.w   d1, d0
; ;         ble     .DONE1
; ;         move.l  d1, (USRLTRPOS)
; ;             
; ; .DONE1:
; ;         move.l  USRLTRPOS, a1
; ;         ; UPDATE COORDINATE Y
; ;         btst.b  #KBD_UP_POS, (KBD_EDGE)
; ;         beq     .CHKUP
; ;         move.w  (a1), d0
; ;         add.w   #1, d0
; ;         move.w  d0, (a1)
; ; .CHKUP: btst.b  #KBD_DOWN_POS, (KBD_EDGE)
; ;         beq     .CONT3
; ;         move.w  (a1), d0
; ;         sub.w   #1, d0
; ;         move.w  d0, (a1)
; ;             
; ;         ; CHECK COLLISIONS
; ; .CONT3: move.w  (a1), d0
; ;         cmp.w   #0, d0
; ;         bge     .CONT4
; ;         move.w  #36, (a1)
; ;         bra     .DONE2
; ; .CONT4: move.w  (a1), d0
; ;         cmp.w   #36, d0
; ;         ble     .DONE2
; ;         move.w  #0, (a1)
; ;
; ; .DONE2:
; ;
; ;         ; CHECK FOR ENTER
; ;         btst.b  #KBD_SPBAR_POS, (KBD_EDGE)
; ;         beq     .END
; ;         move.b  #1, (KBD_ENTER_PRESS)
; ; .END:
; ;
; ;         movem.l (a7)+, d0-d1
; ;
; ; ; ----------------------------------------------------------------------------
; ; ; PLOT HIGHSCORE USER SCREEN.
; ; ; INPUT    : NONE 
; ; ; OUTPUT   : NONE
; ; ; MODIFIES : NONE
; ; ; ----------------------------------------------------------------------------
; ;             
; ;         move.w  #5, d1
; ;         lea     USR, a0
; ; .LOOP51:
; ;         move.l  (USRLTRPOS), d2
; ;         move.l  a0, d3
; ;             
; ;         ; USED: D0,D1,A0,A1,A2
; ;             
; ;         ; paint one tile
; ;         lea.l   tiletable, a1
; ;         move.w  (a0)+, d0                       ; tile index
; ;         lsl.l   #2, d0
; ;         move.l  (a1,d0), d0
; ;         lea.l   tiles, a2
; ;         add.l   d0, a2
; ;             
; ;         cmp     d2, d3
; ;         bne     .ISNOTCOL
; ;             
; ;             
; ;         movem.l d0-d4, -(a7)
; ;             
; ;         move.b  #80, d0
; ;         move.l  #$00000000, d1
; ;         trap    #15
; ;             
; ;         move.b  #81, d0
; ;         move.l  #LVL_SEL_COL, d1
; ;         trap    #15
; ;             
; ;         move.b  #87, d0
; ;         move.w  (LETPOSX), d1                   ; LX POS
; ;         lsl.l   #4, d1
; ;         sub.w   #1, d1
; ;             
; ;         move.w  (LETPOSY), d2                   ; UY POS
; ;         lsl.l   #4, d2
; ;         sub.w   #1, d2
; ;             
; ;         move.w  d1, d3
; ;         add.w   #16, d3
; ;             
; ;         move.w  d2, d4
; ;         add.w   #16, d4
; ;             
; ;         trap    #15
; ;             
; ;         jsr scrplot ; IF NOT COMMENTED, THE LETTER BLINKS
; ;
; ;         movem.l (a7)+, d0-d4
; ;             
; ;         bra     .CONTINUE
; ;             
; ; .ISNOTCOL:
; ;         movem.l d0-d4, -(a7)
; ;             
; ;         move.b  #80, d0
; ;         move.l  #$00000000, d1
; ;         trap    #15
; ;             
; ;         move.b  #81, d0
; ;         move.l  #$00000000, d1
; ;         trap    #15
; ;             
; ;         move.b  #87, d0
; ;         move.w  (LETPOSX), d1                   ; LX POS
; ;         lsl.l   #4, d1
; ;         sub.w   #1, d1
; ;             
; ;         move.w  (LETPOSY), d2                   ; UY POS
; ;         lsl.l   #4, d2
; ;         sub.w   #1, d2
; ;             
; ;         move.w  d1, d3
; ;         add.w   #16, d3
; ;             
; ;         move.w  d2, d4
; ;         add.w   #16, d4
; ;             
; ;         trap    #15
; ;             
; ;         movem.l (a7)+, d0-d4
; ;             
; ; .CONTINUE:
; ;         move.l  a2, -(a7)
; ;         move.w  (LETPOSY), -(a7)                ; y pos
; ;         move.w  (LETPOSX), -(a7)                ; x pos
; ;         jsr     drawtile
; ;         addq.w  #8, a7
; ;             
; ;         add.w   #1, (LETPOSX)
; ;             
; ;         dbra    d1, .LOOP51
; ;             
; ;         move.w  #USRIPOSX, (LETPOSX)
; ;             
; ;
; ;             
; ;         move.b  (KBD_ENTER_PRESS), d0
; ;         cmp.b   #1, d0
; ;         beq     .FIN51
; ;             
; ;         btst.b  #KBD_CTRL_POS, (KBD_EDGE)
; ;         bne     .FIN52
; ;             
; ;         jsr scrplot
; ;
; ;         bra     .LOOP5
; ;             
; ; .FIN52: move.b  #3, (SCR_NUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
; ;
; ;         rts
; ;             
; ;             
; ; .FIN51: move.b  #1, (SCR_NUM)                 ; CHANGE TO DESIRED SCREEN WHEN DONE
; ;

