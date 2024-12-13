sysinit:
; initialize system
; input   : none
; output  : none
; modifies: none
        ori.w   #$0700, sr                      ; disable interrupts
        jsr     scrinit
        jsr     kbdinit
        jsr     mouseinit
        jsr     sncinit

        ; do not enter user because of Eeasy68k auto interrupt bug;
        ; SR's interrupt mask block's SCN_EXC and superuser mode activated
        ; again, so we'll end up in superuser mode anyway...

        ; ; switch to user mode
        ; move.w  sr, -(a7)
        ; andi.w  #$d8ff, (a7)
        ; rte
        rts

sncenable: macro
        move.l  #sncinc, ($60+SNC_EXC*4)
        endm

sncdisable: macro
        move.l  #sncskip, ($60+SNC_EXC*4)
        endm

sncskip:
        rte

sncinc:
        addq.b  #1, (SNC_PLOT)
        subq.l  #1, (SNC_CNT_DOWN)
        rte

sncinit:
        move.b  #0, (SNC_PLOT)
        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN)
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

scrinit:
; init screen. set screen resolution, set windowed mode, clear screen,
; enable double buffer.
; input    : none
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
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

scrclr:
        movem.w d0-d1, -(a7)
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15
        movem.w (a7)+, d0-d1
        rts

scrplot:
; updates double buffer
; input    : none
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        move.w  d0, -(a7)
        ; switch buffers
        move.b  #94, d0
        trap    #15
        move.w  (a7)+, d0
        rts

kbdinit:
; init keyboard
; input    : none
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        clr.b   (KBD_VAL)
        clr.b   (KBD_EDGE)
        ; move.l  #kbdupd, ($80+KBD_TRAP*4)
        rts

kbdupd:
; update keyboard info.
; 7 -> shift
; 6 -> ctrl
; 5 -> esc
; 4 -> spacebar
; 3 -> down
; 2 -> right
; 1 -> up
; 0 -> left
; input    : none
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
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

mouseinit:
        move.b  #0, (MOUSE_VAL)
        ; move.l  #mouseupd, ($80+MOUSE_TRAP*4)
        rts

mouseupd:
        movem.l d0-d3, -(a7)

        ; read current state of mouse and change mouse coordinates
        move.b  #61, d0
        move.b  #00, d1
        trap    #15

        ; store mouse x coordinate
        move.w  d1, (MOUSE_POS_X)

        move.w  #15, d3
.loop:  lsl.l   #1, d1
        addx.w  d2, d2
        dbra.w  d3, .loop

        ; store mouse y coordinate
        move.w  d2, (MOUSE_POS_Y)

        ; if left click pressed and it's inside the button add 1
        btst    #0, d0
        bne     .lclick
        bra     .noclick
.lclick:
        move.w  #BUTT_POS_X-BUTT_WIDTH/2, d1
        cmp.w   (MOUSE_POS_X), d1
        bge     .noclick

        move.w  #BUTT_POS_Y-BUTT_HEIGHT/2, d1
        cmp.w   (MOUSE_POS_Y), d1
        bge     .noclick

        move.w  #BUTT_POS_X+BUTT_WIDTH/2, d1
        cmp.w   (MOUSE_POS_X), d1
        ble     .noclick

        move.w  #BUTT_POS_Y+BUTT_HEIGHT/2, d1
        cmp.w   (MOUSE_POS_Y), d1
        ble     .noclick

        btst.b  #0, (MOUSE_VAL)
        bne     .noclick
        addq.w  #1, (BUTT_PRESS)
        move.b  #1, (MOUSE_VAL)

        bra     .noclick
.noclick:
        movem.l (a7)+, d0-d3
        rts
