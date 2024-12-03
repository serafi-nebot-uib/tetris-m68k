sysinit:
; initialize system
; input   : none
; output  : none
; modifies: none
        jsr     scrinit
        jsr     kbdinit
        jsr     sncinit

        ; switch to user mode
        move.w  sr, -(a7)
        andi.w  #$d8ff, (a7)
        rte

sncinit:
        clr.b   (SNC_PLOT)
        move.b  #SNC_PIECE_TIME, (SNC_PIECE)

        move.l  #sncinc, ($60+SNC_EXC*4)

        ; enable exceptions
        move.b  #32, d0
        move.b  #5, d1
        trap    #15
        ; create timer
        move.b  #6, d1
        move.b  #$80|SNC_EXC, d2
        move.l  #20, d3
        trap    #15

        rts

sncinc:
        subq.b  #1, (SNC_PIECE)
        rte

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

        move.l  #scrplot, ($80+SCR_TRAP*4)

        movem.l (a7)+, d0-d1
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
        rte

kbdinit:
; init keyboard
; input    : none
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        clr.b   (KBD_VAL)
        clr.b   (KBD_EDGE)
        move.l  #kbdupd, ($80+KBD_TRAP*4)
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
        move.l  #KBD_SHIFT<<24|KBD_CTRL<<16|KBD_ESC<<8|KBD_SPBAR, d1
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
        rte

.pack:  move.w  #3, d3
.loop:  lsl.l   #8, d1
        roxl.b  #1, d2
        dbra.w  d3, .loop
        rts
