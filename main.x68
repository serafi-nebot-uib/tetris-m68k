        org     $1000

        include 'board.x68'
        include 'piece.x68'
        ; include 'tiles.x68'
        include 'background.x68'


TILESIZE: equ   16
TILELEN: equ    TILESIZE*TILESIZE
SCRWIDTH: equ   640
SCRHEIGHT: equ  480

tiletable:
        dc.l    $00000000, $00000130, $00000170, $00000294, $000002d4, $00000308, $00000444, $00000484
        dc.l    $0000059c, $00000660, $000006a0, $00000758, $00000798, $000007d8, $00000890, $000008d0
        dc.l    $00000994, $000009c8, $000009f0, $00000a24, $00000a58, $00000a80, $00000ab4, $00000adc
        dc.l    $00000b04, $00000b44, $00000b84, $00000bc4, $00000bf8, $00000c20, $00000c48, $00000c88
        dc.l    $00000cc8, $00000ce4, $00000d18

tiles:
        dc.l    $00000000, $00000000, $000f0001
        dc.l    $00000000, $00000002, $0001000f
        dc.l    $00747474, $00020002, $00050005
        dc.l    $00000000, $00060002, $00070003
        dc.l    $00747474, $00080002, $000f0003
        dc.l    $00747474, $00060004, $00070009
        dc.l    $00000000, $00080004, $00090005
        dc.l    $00747474, $000a0004, $000f0005
        dc.l    $00000000, $00020006, $00030007
        dc.l    $00747474, $00040006, $00090007
        dc.l    $00000000, $000a0006, $000f0007
        dc.l    $00747474, $00020008, $0003000f
        dc.l    $00000000, $00040008, $00050009
        dc.l    $00000000, $00080008, $00090009
        dc.l    $00f0fc9c, $000a0008, $000f0009
        dc.l    $00747474, $0004000a, $0005000f
        dc.l    $00000000, $0006000a, $0007000f
        dc.l    $00f0fc9c, $0008000a, $0009000f
        dc.l    $00000000, $000a000a, $000b000b
        dc.l    $00f0fc9c, $000c000a, $000f000b
        dc.l    $00f0fc9c, $000a000c, $000b000f
        dc.l    $00000000, $000c000c, $000d000d
        dc.l    $00f0fc9c, $000e000c, $000f000d
        dc.l    $00f0fc9c, $000c000e, $000d000f
        dc.l    $00000000, $000e000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $000f0001
        dc.l    $00747474, $00000002, $000f0005
        dc.l    $00000000, $00000006, $000f0007
        dc.l    $00f0fc9c, $00000008, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $000f0001
        dc.l    $00747474, $00000002, $00050003
        dc.l    $00000000, $00060002, $00070003
        dc.l    $00747474, $00080002, $000b0005
        dc.l    $00000000, $000c0002, $000f000f
        dc.l    $00747474, $00000004, $00030005
        dc.l    $00000000, $00040004, $00050005
        dc.l    $00747474, $00060004, $000b0005
        dc.l    $00000000, $00000006, $00030007
        dc.l    $00747474, $00040006, $00090007
        dc.l    $00000000, $000a0006, $000f0007
        dc.l    $00f0fc9c, $00000008, $00030009
        dc.l    $00000000, $00040008, $00050009
        dc.l    $00747474, $00060008, $00070009
        dc.l    $00000000, $00080008, $00090009
        dc.l    $00747474, $000a0008, $000b000f
        dc.l    $00f0fc9c, $0000000a, $0001000b
        dc.l    $00000000, $0002000a, $0003000b
        dc.l    $00f0fc9c, $0004000a, $0005000f
        dc.l    $00000000, $0006000a, $0007000f
        dc.l    $00747474, $0008000a, $000b000f
        dc.l    $00000000, $0000000c, $0001000d
        dc.l    $00f0fc9c, $0002000c, $0005000f
        dc.l    $00f0fc9c, $0000000e, $0005000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $0001000f
        dc.l    $00747474, $00020000, $0005000f
        dc.l    $00000000, $00060000, $0007000f
        dc.l    $00f0fc9c, $00080000, $000d000f
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0005000f
        dc.l    $00000000, $00060000, $0007000f
        dc.l    $00747474, $00080000, $000b000f
        dc.l    $00000000, $000c0000, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $0001000f
        dc.l    $00747474, $00020000, $00050005
        dc.l    $00000000, $00060000, $00070005
        dc.l    $00f0fc9c, $00080000, $000d0001
        dc.l    $00000000, $000e0000, $000f0001
        dc.l    $00f0fc9c, $00080002, $000b0003
        dc.l    $00000000, $000c0002, $000d0003
        dc.l    $00f0fc9c, $000e0002, $000f0007
        dc.l    $00f0fc9c, $00080004, $00090005
        dc.l    $00000000, $000a0004, $000b0005
        dc.l    $00f0fc9c, $000c0004, $000f0007
        dc.l    $00747474, $00020006, $00030007
        dc.l    $00000000, $00040006, $00050007
        dc.l    $00747474, $00060006, $0007000b
        dc.l    $00000000, $00080006, $00090007
        dc.l    $00f0fc9c, $000a0006, $000f0007
        dc.l    $00000000, $00020008, $00030009
        dc.l    $00747474, $00040008, $00090009
        dc.l    $00000000, $000a0008, $000f0009
        dc.l    $00747474, $0002000a, $0007000b
        dc.l    $00000000, $0008000a, $0009000b
        dc.l    $00747474, $000a000a, $000f000d
        dc.l    $00747474, $0002000c, $0005000d
        dc.l    $00000000, $0006000c, $0007000f
        dc.l    $00747474, $0008000c, $000f000d
        dc.l    $00000000, $0002000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $000f0001
        dc.l    $00f0fc9c, $00000002, $000f0007
        dc.l    $00000000, $00000008, $000f0009
        dc.l    $00747474, $0000000a, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $00050001
        dc.l    $00000000, $00060000, $00070005
        dc.l    $00747474, $00080000, $000b0005
        dc.l    $00000000, $000c0000, $000f000f
        dc.l    $00000000, $00000002, $00010003
        dc.l    $00f0fc9c, $00020002, $00050003
        dc.l    $00f0fc9c, $00000004, $00010007
        dc.l    $00000000, $00020004, $00030005
        dc.l    $00f0fc9c, $00040004, $00050005
        dc.l    $00f0fc9c, $00020006, $00030007
        dc.l    $00000000, $00040006, $00050007
        dc.l    $00747474, $00060006, $0007000b
        dc.l    $00000000, $00080006, $00090007
        dc.l    $00747474, $000a0006, $000b0007
        dc.l    $00000000, $00000008, $00030009
        dc.l    $00747474, $00040008, $00090009
        dc.l    $00000000, $000a0008, $000f0009
        dc.l    $00747474, $0000000a, $0003000d
        dc.l    $00000000, $0004000a, $0005000b
        dc.l    $00747474, $0008000a, $000b000d
        dc.l    $00747474, $0004000c, $0005000d
        dc.l    $00000000, $0006000c, $0007000f
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00747474, $00000000, $00070001
        dc.l    $00000000, $00080000, $000f0001
        dc.l    $00747474, $00000002, $00030003
        dc.l    $00000000, $00040002, $00070003
        dc.l    $00747474, $00080002, $000f0005
        dc.l    $00747474, $00000004, $00010007
        dc.l    $00000000, $00020004, $00030007
        dc.l    $00747474, $00040004, $000f0005
        dc.l    $00747474, $00040006, $00070007
        dc.l    $00000000, $00080006, $000f0007
        dc.l    $00000000, $00000008, $0001000f
        dc.l    $00747474, $00020008, $0005000f
        dc.l    $00000000, $00060008, $0007000f
        dc.l    $00f0fc9c, $00080008, $000f0009
        dc.l    $00f0fc9c, $0008000a, $0009000f
        dc.l    $00000000, $000a000a, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $000f0001
        dc.l    $00747474, $00000002, $000f0005
        dc.l    $00000000, $00000006, $000f0007
        dc.l    $00f0fc9c, $00000008, $000f0009
        dc.l    $00000000, $0000000a, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $00070001
        dc.l    $00747474, $00080000, $000f0001
        dc.l    $00747474, $00000002, $00070005
        dc.l    $00000000, $00080002, $000b0003
        dc.l    $00747474, $000c0002, $000f0003
        dc.l    $00747474, $00080004, $000b0007
        dc.l    $00000000, $000c0004, $000d0007
        dc.l    $00747474, $000e0004, $000f0007
        dc.l    $00000000, $00000006, $00070007
        dc.l    $00f0fc9c, $00000008, $00070009
        dc.l    $00000000, $00080008, $0009000f
        dc.l    $00747474, $000a0008, $000d000f
        dc.l    $00000000, $000e0008, $000f000f
        dc.l    $00000000, $0000000a, $0005000f
        dc.l    $00f0fc9c, $0006000a, $0007000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $0001000f
        dc.l    $00747474, $00020000, $0005000f
        dc.l    $00000000, $00060000, $0007000f
        dc.l    $00f0fc9c, $00080000, $0009000f
        dc.l    $00000000, $000a0000, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $0005000f
        dc.l    $00f0fc9c, $00060000, $0007000f
        dc.l    $00000000, $00080000, $0009000f
        dc.l    $00747474, $000a0000, $000d000f
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $00010007
        dc.l    $00747474, $00020000, $00050007
        dc.l    $00000000, $00060000, $00070007
        dc.l    $00f0fc9c, $00080000, $00090007
        dc.l    $00000000, $000a0000, $000f0005
        dc.l    $00f0fc9c, $000a0006, $000f0007
        dc.l    $00747474, $00000008, $0001000f
        dc.l    $00000000, $00020008, $0003000b
        dc.l    $00747474, $00040008, $0007000b
        dc.l    $00000000, $00080008, $000f0009
        dc.l    $00747474, $0008000a, $000f000d
        dc.l    $00747474, $0002000c, $0003000f
        dc.l    $00000000, $0004000c, $0007000d
        dc.l    $00747474, $0004000e, $0007000f
        dc.l    $00000000, $0008000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $000f0005
        dc.l    $00f0fc9c, $00000006, $000f0007
        dc.l    $00000000, $00000008, $000f0009
        dc.l    $00747474, $0000000a, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00000000, $00000000, $00050005
        dc.l    $00f0fc9c, $00060000, $00070007
        dc.l    $00000000, $00080000, $00090007
        dc.l    $00747474, $000a0000, $000d0007
        dc.l    $00000000, $000e0000, $000f0007
        dc.l    $00f0fc9c, $00000006, $00070007
        dc.l    $00000000, $00000008, $00070009
        dc.l    $00747474, $00080008, $000b000b
        dc.l    $00000000, $000c0008, $000d000b
        dc.l    $00747474, $000e0008, $000f000f
        dc.l    $00747474, $0000000a, $000b000b
        dc.l    $00747474, $0000000c, $0007000d
        dc.l    $00000000, $0008000c, $000b000d
        dc.l    $00747474, $000c000c, $000f000f
        dc.l    $00000000, $0000000e, $0007000f
        dc.l    $00747474, $0008000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000f0001
        dc.l    $00f0fc9c, $00000002, $0001000d
        dc.l    $00747474, $00020002, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000f0001
        dc.l    $00747474, $00000002, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000d0001
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00747474, $00000002, $000d000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000d0001
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00f0fc9c, $00000002, $0001000f
        dc.l    $00747474, $00020002, $000d000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0001000f
        dc.l    $00747474, $00020000, $000d000f
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0001000d
        dc.l    $00747474, $00020000, $000d000d
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000f0001
        dc.l    $00f0fc9c, $00000002, $0001000f
        dc.l    $00747474, $00020002, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000d0001
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00747474, $00000002, $000d000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000f0001
        dc.l    $00f0fc9c, $00000002, $0001000f
        dc.l    $00747474, $00020002, $000f000d
        dc.l    $00747474, $0002000e, $000d000f
        dc.l    $00000000, $000e000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000d0001
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00747474, $00000002, $000d000d
        dc.l    $00f0fc9c, $0000000e, $0001000f
        dc.l    $00747474, $0002000e, $000d000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0001000f
        dc.l    $00747474, $00020000, $000d000f
        dc.l    $00f0fc9c, $000e0000, $000f0001
        dc.l    $00747474, $000e0002, $000f000d
        dc.l    $00000000, $000e000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $000f0001
        dc.l    $00747474, $00000002, $000f000d
        dc.l    $00747474, $0000000e, $000d000f
        dc.l    $00000000, $000e000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0001000d
        dc.l    $00747474, $00020000, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00747474, $00000000, $000d000d
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $0001000d
        dc.l    $00747474, $00020000, $000d000d
        dc.l    $00f0fc9c, $000e0000, $000f0001
        dc.l    $00747474, $000e0002, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00f0fc9c, $00000000, $00010001
        dc.l    $00747474, $00020000, $000d000d
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00747474, $00000002, $000d000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00747474, $00000000, $000f000d
        dc.l    $00000000, $0000000e, $000f000f
        dc.l    $ffffffff
        dc.l    $00747474, $00000000, $000d000d
        dc.l    $00000000, $000e0000, $000f000f
        dc.l    $00f0fc9c, $0000000e, $0001000f
        dc.l    $00747474, $0002000e, $000d000f
        dc.l    $ffffffff

drawrec:
; arguments:
;       sp+0 (x pos)                    -> d3
;       sp+2 (y pos)                    -> d4
;       sp+4 (bitmap address high word) -> a0
;       sp+6 (bitmap address low word)  -> a0
        movem.w d0-d6, -(a7)
        move.l  a0, -(a7)

        ; get subroutine arguments
        movem.w 22(a7), d5-d6
        move.l  26(a7), a0
        lsl.l   #4, d5
        lsl.l   #4, d6

.loop:
        ; set fill color
        move.l  (a0)+, d1
        move.l  d1, d2
        eor.l   #$ffffffff, d2                  ; detect end sequence
        beq     .done
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15

        ; get source coordinates
        move.w  (a0)+, d1
        move.w  (a0)+, d2
        move.w  (a0)+, d3
        move.w  (a0)+, d4

        ; draw rectangle
        move.b  #87, d0
        add.w   d5, d1
        add.w   d5, d3
        add.w   d6, d2
        add.w   d6, d4
        trap    #15
        bra     .loop

.done:
        move.l  (a7)+, a0
        movem.w (a7)+, d0-d6
        rts

tileplot:
; d0 -> tile index
; d3 -> tile x coord
; d4 -> tile y coord
        movem.l d0-d7/a0, -(a7)

        lea.l   tiles, a0
        ; TODO: optimize mulu
        lsl.l   #8, d0
        lsl.l   #2, d0                          ; multiply by 4
        add.l   d0, a0
        lsl.l   #4, d3
        lsl.l   #4, d4

        move.l  d3, d7
        move.w  #TILESIZE-1, d5
        move.w  #TILESIZE-1, d6
.draw:
        move.b  #80, d0
        move.l  (a0)+, d1                       ; pixel color
        trap    #15

        move.b  #82, d0
        move.l  d3, d1
        move.l  d4, d2
        trap    #15

        addq.w  #1, d3
        dbra.w  d5, .draw
        move.l  d7, d3                          ; restore x index to start
        move.w  #TILESIZE-1, d5
        addq.w  #1, d4
        dbra.w  d6, .draw

        movem.l (a7)+, d0-d7/a0
        rts

start:
; --- drawrec map --------------------------------------------------------------
        lea.l   background, a0
        lea.l   tiletable, a1
.loop:
        moveq.l #0, d0
        move.b  (a0)+, d0
        cmp.b   #$ff, d0
        beq     .skip

        ; get tile
        lsl.l   #2, d0
        move.l  (a1,d0), d0
        lea.l   tiles, a2
        add.l   d0, a2

        ; call drawrec
        move.l  a2, -(a7)
        move.w  d4, -(a7)                       ; y pos
        move.w  d3, -(a7)                       ; x pos
        jsr     drawrec
        addq.w  #8, a7                          ; pop arguments from stack
.skip:
        addq.l  #1, d3
        cmp     #SCRWIDTH/TILESIZE, d3
        blo     .loop
        moveq.l #0, d3

        addq.l  #1, d4
        cmp     #SCRHEIGHT/TILESIZE, d4
        blo     .loop
        simhalt

; --- bitmap -------------------------------------------------------------------
;         lea.l   background, a0
; .loop:
;         move.b  (a0)+, d0
;         cmp.b   #$ff, d0
;         beq     .skip
;         jsr     tileplot
; .skip:
;         addq.l  #1, d3
;         cmp     #SCRWIDTH/TILESIZE, d3
;         blo     .loop
;         moveq.l #0, d3
;
;         addq.l  #1, d4
;         cmp     #SCRHEIGHT/TILESIZE, d4
;         blo     .loop
;         simhalt

; --- collisions ---------------------------------------------------------------
        ; move.l  #17, d0
        ; moveq.l #0, d3
        ; moveq.l #0, d4
        ; jsr     tileplot

        ; jsr     piececoll
        ;
        ; move.w  #1<<8|1, d0                     ; x << 8 | y
        ; lea.l   pieceT, a0
        ; jsr     pieceinit
        ;
        ; jsr     pieceplot
        ;
        ; move.l  d0, d1

        end     start
