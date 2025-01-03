; initialize system
;
; input    :
; output   :
; modifies :
sysinit:
        ori.w   #$0700, sr                      ; disable interrupts
        jsr     scrinit
        jsr     kbdinit
        jsr     mouseinit
        jsr     sndinit
        jsr     sncinit

        ; do not enter user because of Eeasy68k auto interrupt bug;
        ; SR's interrupt mask block's SCN_EXC and superuser mode activated
        ; again, so we'll end up in superuser mode anyway...

        ; ; switch to user mode
        ; move.w  sr, -(a7)
        ; andi.w  #$d8ff, (a7)
        ; rte
        rts

; enable sync timer
;
; input    :
; output   :
; modifies :
sncenable: macro
        move.l  #sncupd, ($60+SNC_EXC*4)
        endm

; disable sync timer
;
; input    :
; output   :
; modifies :
sncdisable: macro
        move.l  #sncskip, ($60+SNC_EXC*4)
        endm

sncskip:
        rte

sncupd:
        addq.b  #1, (SNC_PLOT)
        subq.l  #1, (SNC_CNT_DOWN)
        rte

; initialize sync timer
;
; input    :
; output   :
; modifies :
sncinit:
        move.b  #0, (SNC_PLOT)
        move.l  (SNC_PIECE_TIME), (SNC_CNT_DOWN)
        sncenable
        ; enable exceptions
        move.b  #32, d0
        move.b  #5, d1
        trap    #15
        ; create timer
        move.b  #6, d1
        move.b  #$80|SNC_EXC, d2
        move.l  #SNC_TIME, d3
        trap    #15
        rts

; initialize screen
;
; input    :
; output   :
; modifies :
scrinit:
        movem.l d0-d1, -(a7)
        ; set screen resolution
        move.b  #33, d0
        move.l  #SCR_WIDTH<<16|SCR_HEIGHT, d1
        trap    #15
        ; set windowed mode
        move.l  #1, d1
        trap    #15
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15
        ; enable double buffer
        move.b  #92, d0
        move.b  #17, d1
        trap    #15

        ; move.l  #scrplot, ($80+SCR_TRAP*4)

        movem.l (a7)+, d0-d1
        rts

; clear screen
;
; input    :
; output   :
; modifies :
scrclr:
        movem.w d0-d1, -(a7)
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15
        movem.w (a7)+, d0-d1
        rts

; update double buffer; show changes on screen
;
; input    :
; output   :
; modifies :
scrplot:
        move.w  d0, -(a7)
        ; switch buffers
        move.b  #94, d0
        trap    #15
        move.w  (a7)+, d0
        rts

; initialize keyboard
;
; input    :
; output   :
; modifies :
kbdinit:
        clr.b   (KBD_VAL)
        clr.b   (KBD_EDGE)
        ; move.l  #kbdupd, ($80+KBD_TRAP*4)
        rts

; update keyboard data
;
; input    :
; output   :
; modifies :
kbdupd:
        movem.l d0-d3, -(a7)

        ; read first part
        move.b  #19, d0
        move.l  #KBD_ENTER<<24|KBD_CTRL<<16|KBD_ESC<<8|KBD_SPBAR, d1
        trap    #15

        ; convert to desired format
        jsr     .pack

        ; read second part
        move.l  #KBD_DOWN<<24|KBD_RIGHT<<16|KBD_UP<<8|KBD_LEFT, d1
        trap    #15

        ; convert to desired format
        jsr     .pack

        ; compute kbdedge
        move.b  (KBD_VAL), d0
        not.b   d0
        and.b   d2, d0
        move.b  d0, (KBD_EDGE)

        ; store kbdval
        move.b  d2, (KBD_VAL)

        movem.l (a7)+, d0-d3
        rts

.pack:  move.w  #3, d3
.loop:  lsl.l   #8, d1
        roxl.b  #1, d2
        dbra.w  d3, .loop
        rts

; initialize mouse
;
; input    :
; output   :
; modifies :
mouseinit:
        move.b  #0, (MOUSE_VAL)
        move.w  #0, (MOUSE_POS_X)
        move.w  #0, (MOUSE_POS_Y)
        ; move.l  #mouseupd, ($80+MOUSE_TRAP*4)
        rts

; check mouse info and update button state
;
; input    :
; output   :
; modifies :
mouseupd:
        movem.l d0-d4, -(a7)

        moveq.l #0, d0
        moveq.l #0, d1
        moveq.l #0, d2
        moveq.l #0, d3
        moveq.l #0, d4

        move.b  #0, (BUTT_PRESS)                ; resets button status

        ; read current state of mouse and change mouse coordinates
        move.b  #61, d0
        move.b  #00, d1
        trap    #15

        ; compute mousedge
        move.b  (MOUSE_VAL), d3
        not.b   d3
        and.b   #%00000001, d0                  ; filters only left click
        and.b   d0, d3
        move.b  d3, (MOUSE_EDGE)

        ; store mouseval & mouse x coordinate
        move.b  d0, (MOUSE_VAL)
        move.w  d1, (MOUSE_POS_X)
        move.w  d1, d0

        moveq.l #15, d4
.loop:  lsl.l   #1, d1
        addx.w  d2, d2
        dbra    d4, .loop

        ; store mouse y coordinate
        move.w  d2, (MOUSE_POS_Y)

        ; if left click pressed and it's inside the button add 1
        btst.l  #0, d3
        beq     .noclick 

        move.w  #(BUTT_POS_X*TILE_MULT)-(BUTT_WIDTH*TILE_MULT)/2, d1 
        cmp.w   d0, d1
        bge     .noclick

        move.w  #(BUTT_POS_Y*TILE_MULT)-(BUTT_HEIGHT*TILE_MULT)/2, d1
        cmp.w   d2, d1
        bge     .noclick

        move.w  #(BUTT_POS_X*TILE_MULT)+(BUTT_WIDTH*TILE_MULT)/2, d1
        cmp.w   d0, d1
        ble     .noclick

        move.w  #(BUTT_POS_Y*TILE_MULT)+(BUTT_HEIGHT*TILE_MULT)/2, d1
        cmp.w   d2, d1
        ble     .noclick
        
        add.b   #1, (BUTT_PRESS)
.noclick:
        movem.l (a7)+, d0-d4
        rts

; sound system init
;
; input    : none
; output   : none
; modifies : none
sndinit:
        movem.l d0-d1/a0-a1, -(a7)
        clr.b   d1
        lea     .list, a0
.loop:  move.l  (a0)+, d0
        beq     .done
        move.l  d0, a1
        move.b  #SND_LOADERTSK, d0
        trap    #15
        addq.b  #1, d1
        bra     .loop
.done:  movem.l (a7)+, d0-d1/a0-a1
        rts
.music1: dc.b   'snd/1-MUSIC1.wav',0            ; music 1
.music2: dc.b   'snd/2-MUSIC2.wav',0            ; music 2 
.music3: dc.b   'snd/3-MUSIC3.wav',0            ; music 3
.btypsuc: dc.b  'snd/4-BTYPESUCCESS.wav',0      ; b-type goal achieved (lines completed)
.endmusic: dc.b 'snd/5-ENDING.wav',0            ; a-type & b-type ending music
.highscore: dc.b 'snd/6-HIGHSCORE.wav',0        ; high score screen music
.music1fst: dc.b 'snd/8-TRACK8.wav',0           ; music 1 allegro
.music2fst: dc.b 'snd/9-TRACK9.wav',0           ; music 2 allegro
.music3fst: dc.b 'snd/10-TRACK10.wav',0         ; music 3 allegro
.menuslct: dc.b 'snd/SFX2.wav',0                ; lvl selection & username key sound effect
.menuslctd: dc.b 'snd/SFX3.wav',0               ; lvl selected sound effect
.shftpiece: dc.b 'snd/SFX4.wav',0               ; shifting piece sideways sound effect
.rotpiece: dc.b 'snd/SFX6.wav',0                ; rotating piece sound effect
.levelup: dc.b  'snd/SFX7.wav',0                ; level up sound effect
.piecelock: dc.b 'snd/SFX8.wav',0               ; lock piece (final position) sound effect
.tetrisach: dc.b 'snd/SFX10.wav',0              ; tetris achieved (4-lines clear) sound effect
.linecompl: dc.b 'snd/SFX11.wav',0              ; line completed sound effect
.death: dc.b    'snd/SFX14.wav',0               ; death sound sound effect
.endrckt: dc.b  'snd/SFX15.wav',0               ; ending rocket sound effect
        ds.w    0
.list:  dc.l    .music1,.music2,.music3
        dc.l    .btypsuc,.endmusic,.highscore
        dc.l    .music1fst,.music2fst,.music3fst
        dc.l    .menuslct,.menuslctd,.shftpiece
        dc.l    .rotpiece,.levelup,.piecelock
        dc.l    .tetrisach,.linecompl,.death,.endrckt,0

; play sound
;
; input : \1 - sound id to play
;         \2 - action (SND_LOOP, SND_STOP)
sndplay: macro
        ifc     '\2','SND_LOOP'
        ifeq    SND_DIRECTX
        mexit
        endc
        endc

        ifc     '\1','SND_STOP_ALL'
        movem.l d0/d2, -(a7)
        move.l  #3, d2
        move.b  #SND_PLAYERTSK, d0
        trap    #15
        movem.l (a7)+, d0/d2
        mexit
        endc

        movem.l d0-d2, -(a7)
        move.b  \1, d1
        ifnc    '\2',''
        move.l  \2, d2
        endc

        ifc     '\2',''
        moveq.l #0, d2
        endc

        move.b  #SND_PLAYERTSK, d0
        trap    #15
        movem.l (a7)+, d0-d2
        endm
