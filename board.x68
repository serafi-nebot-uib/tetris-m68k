PWIDTH: equ     4
PHEIGHT: equ    2
PSIZE:  equ     PWIDTH*PHEIGHT

BOARDWIDTH: equ 10
BOARDHEIGHT: equ 20
BOARDSIZE: equ  BOARDWIDTH*BOARDHEIGHT

piece:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.w    1                               ; orientation index
        ds.l    1                               ; piece address

board:
        ; ds.b    BOARDWIDTH*BOARDHEIGHT
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        ds.w    0

; get piece matrix dimensions from an orientation index
; \1 -> orientation index
; \2 -> result (width << 8 | height)
pdim:   macro
        btst    #0, \1
        beq     .pdim_mult2
        move.w  #PHEIGHT<<8|PWIDTH, \2
        bra     .pdim_done
.pdim_mult2:
        move.w  #PWIDTH<<8|PHEIGHT, \2
.pdim_done:
        endm

; get piece orientation offset for the piece orientation matrix
; \1 -> orientation index & result
; \2 -> accumulator to perform calculations
poff:   macro
        ; multiply orientation index by PSIZE+2 to get array offset
        move.l  \1, \2
        lsl.l   #3, \1                          ; multiply by 8 (PSIZE)
        lsl.l   #1, \2                          ; multiply by 2 (rx,ry offset)
        add.l   \2, \1
        endm

pieceinit:
; d0 -> x << 8 | y (relative to the board)
; a0 -> piece matrix address
        move.w  d1, -(a7)

        clr.w   (piece+2)                       ; reset orientation index to 0
        move.l  a0, (piece+4)                   ; copy piece matrix address
        ; adjust piece matrix x,y so that the orientation x,y offsets match
        move.w  (a0), d1
        sub.b   d1, d0
        move.b  d0, (piece+1)                   ; adjusted y
        lsr.w   #8, d0
        lsr.w   #8, d1
        sub.b   d1, d0
        move.b  d0, (piece)                     ; adjusted x

        move.w  (a7)+, d1
        rts

piecerotr:
        movem.l d0-d1/a0, -(a7)

        ; remove current x,y offset
        moveq.l #0, d0
        move.w  (piece+2), d0                   ; orientation index
        poff    d0, d1

        move.l  (piece+4), a0                   ; piece matrix address
        move.w  (a0,d0), d1                     ; get current x,y offset
        add.b   d1, (piece+1)                   ; remove y offset
        lsr.w   #8, d1
        add.b   d1, (piece)                     ; remove x offset

        ; cycle to next piece address
        moveq.l #0, d0
        move.w  (piece+2), d0                   ; orientation index
        addq.w  #1, d0                          ; increment orientation index
        ; wrap around every 4 (faster than getting the modulus)
        cmp.w   #4, d0
        blo     .off
        moveq.l #0, d0                          ; reset to 0 if d0 >= 4
.off:
        move.w  d0, (piece+2)
        poff    d0, d1

        ; adjust new x,y offset
        move.w  (a0,d0), d1                     ; get new x,y offset
        sub.b   d1, (piece+1)                   ; add y offset
        lsr.w   #8, d1
        sub.b   d1, (piece)                     ; add x offset

        movem.l (a7)+, d0-d1/a0
        rts

; TODO: implement piecerotl

piececoll:
; result is stored in d0
        movem.l d1-d5/a0, -(a7)

        lea.l   board, a2
        moveq.l #0, d0
        move.l  (piece+4), a0                   ; piece address
        move.w  (piece+2), d0                   ; orientation index
        pdim    d0, d4                          ; matrix dimensions (d3 width, d4 height)
        move.w  d4, d3
        lsr.w   #8, d3
        poff    d0, d1                          ; calculate array offset
        add.l   d0, a0                          ; offset a0 to point to the correct matrix
        add.l   #2, a0                          ; offset a0 to point to piece matrix (skip rx, ry)

        moveq.l #0, d0                          ; x index
        moveq.l #0, d1                          ; y index
        moveq.l #0, d2                          ; accumulator
.loop:
        ; check block bounds
        move.b  d1, d2                          ; y
        ; TODO: optimize mulu (lsl?)
        mulu    d3, d2                          ; y * width
        add.b   d0, d2                          ; y * width + x
        move.b  (a0,d2), d5                     ; get current piece block
        ; if current piece block is empty there's nothing else to check
        beq     .nitr
        ; check if current piece position is out of board bounds (for x & y)
.chkx:
        ; x idx + x coord
        move.b  d0, d2                          ; x idx
        add.b   (piece), d2                     ; x idx + x coord
        bmi     .collision                      ; is current x < 0?
        cmp.b   #BOARDWIDTH, d2                 ; is current x > board width?
        bge     .collision
.chky:
        ; y idx + y coord
        move.b  d1, d2                          ; y idx
        add.b   (piece+1), d2                   ; y idx + y coord
        ; sub.b   -1(a0), d2                      ; y idx + y coord
        bmi     .collision                      ; is current y < 0?
        cmp.b   #BOARDHEIGHT, d2                ; is current y > board height?
        bge     .collision
        ; check block collision
        ; idx = x + piece x + (y + piece y) * BOARDWIDTH
        ; multiply d2 by BOARDWIDTH
        ; d2*10 = d2*(8+2) = d2*8 + d2*2 = d2<<3 + d2<<1
        move.w  d2, d5
        lsl.w   #3, d2                          ; multiply by 8
        lsl.w   #1, d5                          ; multiply by 2
        add.w   d5, d2                          ; (y + piece y) * BOARDWIDTH
        add.b   d0, d2                          ; (y + piece y) * BOARDWIDTH + x
        add.b   (piece), d2                     ; (y + piece y) * BOARDWIDTH + x + piece x
        move.b  (a2,d2), d2                     ; get current piece block
        bne     .collision                      ; check if current piece block is occupied
.nitr:
        addq.b  #1, d0                          ; increment x index
        cmp.b   d3, d0                          ; compare with matrix width
        blo     .loop
        moveq.l #0, d0                          ; reset x index
        addq.b  #1, d1                          ; increment y index
        cmp.b   d4, d1                          ; compare with matrix height
        blo     .loop
        moveq.l #0, d0                          ; store result (no collision)
        bra     .done
.collision:
        move.w  #1, d0                          ; store result
.done:
        movem.l (a7)+, d1-d5/a0
        rts


; piececol:
; ; --- COLLISION DETECTION ------------------------------------------------------
; ; result is stored in d0
;         movem.l d1-d4/a0-a2, -(a7)
;
;         lea.l   piece, a0                       ; piece address
;         move.l  2(a0), a1                       ; current matrix address
;         lea.l   board, a2                       ; board matrix address
;
;         clr.w   d0                              ; x
;         clr.w   d1                              ; y
;         clr.w   d2
;         clr.w   d3
;         move.b  -2(a1), d3                      ; piece width
; .loop:
;         ; check block bounds
;         ; idx = x + y*width
;         move.b  d1, d2                          ; y
;         mulu    d3, d2                          ; y * width
;         add.b   d0, d2                          ; y * width + x
;         move.b  (a1,d2), d4                     ; get current piece block
;         ; if current piece block is empty there's nothing else to check
;         beq     .nitr
;         ; check if current piece position is out of board bounds (for x & y)
; .chkx:
;         move.b  d0, d2                          ; x idx
;         add.b   (a0), d2                        ; x idx + x piece coordinate
;         bmi     .collision                      ; is current x < 0?
;         cmp.b   #BOARDWIDTH, d2                 ; is current x > board width?
;         bge     .collision
; .chky:
;         move.b  d1, d2                          ; y idx
;         add.b   1(a0), d2                       ; y idx + y piece coordinate
;         bmi     .collision                      ; is current y < 0?
;         cmp.b   #BOARDHEIGHT, d2                ; is current y > board height?
;         bge     .collision
;         ; check block collision
;         ; idx = x + piece x + (y + piece y)*BOARDWIDTH
;         move.b  d1, d2                          ; y
;         add.b   1(a0), d2                       ; y + piece y
;         mulu    #BOARDWIDTH, d2                 ; (y + piece y) * width
;         add.b   d0, d2                          ; (y + piece y) * width + x
;         add.b   (a0), d2                        ; (y + piece y) * width + x + piece x
;         move.b  (a2,d2), d2                     ; get current piece block
;         and.b   d2, d4                          ; check if both are 1
;         bne     .collision
; .nitr:
;         addq.b  #1, d0                          ; increment x index
;         cmp.b   d3, d0                          ; compare with piece width
;         blo     .loop
;         clr.b   d0                              ; reset x index
;         addq.b  #1, d1                          ; increment y index
;         cmp.b   -1(a1), d1                      ; compare with piece height
;         blo     .loop
;         move.w  #0, d0                          ; store result
;         bra     .done
; .collision:
;         move.w  #1, d0                          ; store result
; .done:
;         movem.l (a7)+, d1-d4/a0-a2
;         rts
























; TODO: delete this; only for testing
pieceplot:
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; draw board
        move.b  #81, d0
        move.l  #$00000000, d1
        trap    #15

        move.b  #80, d0
        move.l  #$00ff0000, d1
        trap    #15

        ; draw rectangle
        move.b  #87, d0
        move.l  #0, d1
        move.l  #0, d2
        move.l  #10*20, d3
        move.l  #20*20, d4
        trap    #15

        ; draw current piece
        move.b  #80, d0
        move.l  #$00000000, d1
        trap    #15

        move.b  #81, d0
        move.l  #$0000ff00, d1
        trap    #15

        clr.l   d0
        lea.l   piece, a0                       ; piece address
        move.l  4(a0), a0                       ; piece matrix address
        move.w  (piece+2), d0                   ; piece orientation index
        mulu    #PSIZE+2, d0                    ; get current orientation offset
        addq.l  #2, a0                          ; offset x,y offsets
        add.l   d0, a0

        clr.w   d5                              ; piece matrix index

        ; get current piece width and height
        move.w  (piece+2), d0                   ; piece orientation index
        divu    #2, d0
        swap    d0
        cmp.w   #0, d0
        bne     .vert
        move.w  #PWIDTH, d6                     ; width
        bra     .loop
.vert:
        move.w  #PHEIGHT, d6                    ; width

.loop:
        cmp.b   #0, (a0,d5)
        beq     .nitr

        ; x = i mod w
        clr.l   d1
        move.w  d5, d1
        divu    d6, d1
        swap    d1

        ; y = (i - x) / w
        move.w  d5, d2
        sub.w   d1, d2
        divu    d6, d2

        clr.w   d3
        clr.w   d4
        move.b  (piece), d3
        move.b  (piece+1), d4
        add.w   d3, d1
        add.w   d4, d2

        ; draw rectangle
        move.b  #87, d0
        mulu    #20, d1
        move.w  d1, d3
        add.w   #20, d3
        mulu    #20, d2
        move.w  d2, d4
        add.w   #20, d4
        trap    #15
.nitr:
        ; next iteration
        addq.w  #1, d5
        cmp     #PSIZE, d5
        blo     .loop
        rts
