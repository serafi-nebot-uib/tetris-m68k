PIECE_WIDTH: equ 4
PIECE_HEIGHT: equ 2
PIECE_SIZE: equ PIECE_WIDTH*PIECE_HEIGHT

BOARD_WIDTH: equ 10
BOARD_HEIGHT: equ 20
BOARD_SIZE: equ BOARD_WIDTH*BOARD_HEIGHT
BOARD_BASE_X: equ 16
BOARD_BASE_Y: equ 6

; TODO: move variables to game vars
levelnum: ds.b  1
; TODO: move piecenum to piece data structure
piecenum: ds.b  1
        ds.w    0

;--- logic ---------------------------------------------------------------------

piece:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.w    1                               ; orientation index
        ds.l    1                               ; piece address

pieceprev:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.w    1                               ; orientation index
        ds.l    1                               ; piece address

board:
        ; ds.b    BOARD_WIDTH*BOARD_HEIGHT
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
        beq     .mult2\@
        move.w  #PIECE_HEIGHT<<8|PIECE_WIDTH, \2
        bra     .done\@
.mult2\@:
        move.w  #PIECE_WIDTH<<8|PIECE_HEIGHT, \2
.done\@:
        endm

; get piece orientation offset for the piece orientation matrix
; \1 -> orientation index & result
; \2 -> accumulator to perform calculations
poff:   macro
        ; multiply orientation index by PIECE_SIZE+2 to get array offset
        move.l  \1, \2
        lsl.l   #3, \1                          ; multiply by 8 (PIECE_SIZE)
        lsl.l   #1, \2                          ; multiply by 2 (rx,ry offset)
        add.l   \2, \1
        endm

piecerollback: macro
        move.l  (pieceprev), (piece)
        move.l  (pieceprev+4), (piece+4)
        endm

pieceinit:
; d0 -> x << 8 | y (relative to the board)
; a0 -> piece matrix address
; initialize a new piece
; input   :
;               d0: x << 8 | y (coords relative to board)
;               a0: piece matrix address
; output  : none
; modifies: d0
; ------------------------------------------------------------------------------
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

        ; TODO: autogenerate the levelnum and piecenum
        move.b  #8, (levelnum)
        move.b  #1, (piecenum)                  ; TODO: is this needed? store in pieceX struct?
        jsr     pieceupdcol

        ; copy data to pieceprev
        move.l  (piece), (pieceprev)
        move.l  (piece+4), (pieceprev+4)

        move.w  (a7)+, d1
        rts

pieceupdcol:
; set the color profile for the selected level
; input   : none
; output  : none
; modifies: none
; ------------------------------------------------------------------------------
        movem.l d1-d3/a0, -(a7)

        moveq.l #0, d1
        moveq.l #0, d2
        moveq.l #0, d3

        ; d1 -> level
        ; d2 -> piece color offset
        ; d3 -> piece pattern offset
        move.b  (levelnum), d1
        move.l  (piece+4), a0                   ; piece matrix
        move.w  -2(a0), d2
        move.b  d2, d3
        bne     .pattern2
        move.l  #piece_ptrn1, (piece_ptrn)
        bra     .color
.pattern2:
        move.l  #piece_ptrn2, (piece_ptrn)
.color:
        lsr.w   #8, d2

        ; a0 -> color map address
        ; d1 -> piece color
        lea.l   piece_colmap, a0
        lsl.l   #1, d1                          ; level*2
        add.l   d2, d1                          ; level*2 + color offset
        lsl.l   #2, d1                          ; (level*2 + color offset)*4
        move.l  (a0,d1.l), d1

        ; copy current color to piece_ptrn
        move.l  d1, (piece_ptrn1+(3*4))
        move.l  d1, (piece_ptrn1+(12*4))
        move.l  d1, (piece_ptrn2+(3*4))

        movem.l (a7)+, d1-d3/a0
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

piecerotl:
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
        subq.w  #1, d0                          ; decrement orientation index
        ; wrap around every 4 (faster than getting the modulus)
        bge     .off
        moveq.l #3, d0                          ; reset to 3 if d0 < 0
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

piecemovu: macro
        subq.b  \1, (piece+1)
        endm

piecemovd: macro
        addq.b  \1, (piece+1)
        endm

piecemovl: macro
        subq.b  \1, (piece)
        endm

piecemovr: macro
        addq.b  \1, (piece)
        endm

piececoll:
; result is stored in d0
        movem.l d1-d5/a0-a1, -(a7)

        lea.l   board, a1
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
        cmp.b   #BOARD_WIDTH, d2                ; is current x > board width?
        bge     .collision
.chky:
        ; y idx + y coord
        move.b  d1, d2                          ; y idx
        add.b   (piece+1), d2                   ; y idx + y coord
        ; sub.b   -1(a0), d2                      ; y idx + y coord
        bmi     .collision                      ; is current y < 0?
        cmp.b   #BOARD_HEIGHT, d2               ; is current y > board height?
        bge     .collision
        ; check block collision
        ; idx = x + piece x + (y + piece y) * BOARD_WIDTH
        ; multiply d2 by BOARD_WIDTH
        ; d2*10 = d2*(8+2) = d2*8 + d2*2 = d2<<3 + d2<<1
        move.w  d2, d5
        lsl.w   #3, d2                          ; multiply by 8
        lsl.w   #1, d5                          ; multiply by 2
        add.w   d5, d2                          ; (y + piece y) * BOARD_WIDTH
        add.b   d0, d2                          ; (y + piece y) * BOARD_WIDTH + x
        add.b   (piece), d2                     ; (y + piece y) * BOARD_WIDTH + x + piece x
        move.b  (a1,d2), d2                     ; get current piece block
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
        movem.l (a7)+, d1-d5/a0-a1
        rts


; --- plotting -----------------------------------------------------------------

piece_colmap:
        * ---    COLOR1   COLOR2     --- *
        dc.l    $ec3820, $fcbc3c                ; LEVEL0
        dc.l    $00a800, $10d080                ; LEVEL1
        dc.l    $cc00d8, $f878f8                ; LEVEL2
        dc.l    $f85800, $54d858                ; LEVEL3
        dc.l    $5800e4, $98f858                ; LEVEL4
        dc.l    $98f858, $fc8868                ; LEVEL5
        dc.l    $0038f8, $7c7c7c                ; LEVEL6
        dc.l    $fc4468, $2000a8                ; LEVEL7
        dc.l    $f85800, $0038f8                ; LEVEL8
        dc.l    $0038f8, $44a0fc                ; LEVEL9

piece_ptrn:
        dc.l    $00000000
piece_ptrn0:
        dc.l    $00000000, $00000000, $00100010
        dc.l    $ffffffff
piece_ptrn1:
        dc.l    $00000000, $00000000, $00100010
        dc.l    $000038f8, $00000000, $000e000e
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00020002, $00060006
        dc.l    $000038f8, $00040004, $00060006
        dc.l    $ffffffff
piece_ptrn2:
        dc.l    $00000000, $00000000, $00100010
        dc.l    $000038f8, $00000000, $000e000e
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00020002, $000c000c
        dc.l    $ffffffff

piececlr:
        movem.l d0-d6/a0-a1, -(a7)
        ; a0.l ->  piece tile pattern
        lea.l   piece_ptrn0, a0
        bra     _pieceplot
pieceplot:
        movem.l d0-d6/a0-a1, -(a7)
        ; a0.l ->  piece tile pattern
        move.l  (piece_ptrn), a0
_pieceplot:
        ; a1.l -> piece matrix
        move.l  (piece+4), a1
        move.w  (piece+2), d0                   ; orientation index
        ; d2.l -> piece matrix width
        ; d3.l -> piece matrix height
        moveq.l #0, d2
        moveq.l #0, d3
        pdim    d0, d2
        move.b  d2, d3
        lsr.l   #8, d2
        poff    d0, d1                          ; calculate array offset
        add.l   d0, a1                          ; offset a1 to point to current orientation matrix
        addq.l  #2, a1                          ; offset a1 to point to piece matrix (skip rx, ry)

        ; d4.l -> piece matrix index
        moveq.l #0, d4
        ; d5.l -> tile x coord (relative to screen)
        move.l  #BOARD_BASE_X, d5
        move.b  (piece), d1
        ext.w   d1
        add.w   d1, d5
        ; d6.l -> tile y coord (relative to screen)
        move.l  #BOARD_BASE_Y, d6
        move.b  (piece+1), d1
        ext.w   d1
        add.w   d1, d6

        ; d0.b -> matrix x index (only used as loop counter)
        moveq.l #0, d0
        ; d1.b -> matrix y index (only used as loop counter)
        moveq.l #0, d1
.loop:
        btst    #0, (a1,d4)
        beq     .nitr
        jsr     drawtile
.nitr:
        addq.l  #1, d4                          ; increment matrix index
        addq.l  #1, d5                          ; increment tile x coord
        addq.l  #1, d0                          ; increment matrix x index
        cmp.b   d2, d0                          ; compare matrix x index with matrix width
        blo     .loop

        moveq.l #0, d0                          ; reset matrix x index
        sub.l   d2, d5                          ; reset tile x coord to start position
        addq.l  #1, d6                          ; increment tile y coord
        addq.l  #1, d1                          ; increment matrix y index
        cmp.b   d3, d1                          ; compare matrix y index with matrix height
        blo     .loop
.done:
        movem.l (a7)+, d0-d6/a0-a1
        rts
