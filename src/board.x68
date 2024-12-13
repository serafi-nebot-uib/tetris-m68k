PIECE_WIDTH: equ 4
PIECE_HEIGHT: equ 2
PIECE_SIZE: equ PIECE_WIDTH*PIECE_HEIGHT

BOARD_WIDTH: equ 10
BOARD_HEIGHT: equ 20
BOARD_SIZE: equ BOARD_WIDTH*BOARD_HEIGHT
BOARD_BASE_X: equ 16
BOARD_BASE_Y: equ 6

; TODO: move variables to game vars (necessary?)
levelnum: dc.b  0
piecenum: dc.b  0
        ds.w    0

;--- logic ---------------------------------------------------------------------

; current (falling) piece data structure
piece:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.w    1                               ; orientation index
        ds.l    1                               ; piece address

; copy of current piece data structure; allows to rollback any changes
pieceprev:
        ds.b    1                               ; x
        ds.b    1                               ; y
        ds.w    1                               ; orientation index
        ds.l    1                               ; piece address

; board representation as a matrix
board:
        ; ds.b    BOARD_WIDTH*BOARD_HEIGHT
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        dc.b    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        ds.w    0

; get piece matrix dimensions from an orientation index
;
; input    : \1 - orientation index
; output   : \2 - width << 8 | height
; modifies : \1, \2
pdim:   macro
        btst    #0, \1
        beq     .mult2\@
        move.w  #PIECE_HEIGHT<<8|PIECE_WIDTH, \2
        bra     .done\@
.mult2\@:
        move.w  #PIECE_WIDTH<<8|PIECE_HEIGHT, \2
.done\@:
        endm

; get piece orientation matrix offset for the piece orientation index
;
; input    : \1 - orientation index
;            \2 - accumulator register
; output   : \1 - orientation matrix offset
; modifies : \1, \2
poff:   macro
        ; multiply orientation index by PIECE_SIZE+2 to get array offset
        move.l  \1, \2
        lsl.l   #3, \1                          ; multiply by 8 (PIECE_SIZE)
        lsl.l   #1, \2                          ; multiply by 2 (rx,ry offset)
        add.l   \2, \1
        endm

; rollback any changes done to the piece data structure (copies pieceprev to piece)
;
; input    :
; output   :
; modifies :
piecerollback: macro
        move.l  (pieceprev), (piece)
        move.l  (pieceprev+4), (piece+4)
        endm

; commit any changes done to the piece data structure (copies piece to pieceprev)
; must only be called after the proper checks have been made (e.g. check for collisions)
;
; input    :
; output   :
; modifies :
piececommit: macro
        move.l  (piece), (pieceprev)
        move.l  (piece+4), (pieceprev+4)
        endm

; initialize a new piece
;
; input    : d0.b - piece number lo load
; output   :
; modifies : d0.l
pieceinit:
        movem.w d0-d2/a0, -(a7)

        clr.w   (piece+2)                       ; reset orientation index to 0

        ; get piece matrix data address with piece number
        andi.l  #$000000ff, d0
        divu    #7, d0
        swap    d0
        andi.l  #$ffff, d0
        move.b  d0, (piecenum)                  ; store new piecenum
        lsl.l   #2, d0
        lea.l   piece_table, a0
        move.l  (a0,d0), a0

        move.l  a0, (piece+4)                   ; copy piece matrix address
        ; adjust piece matrix x,y so that the orientation x,y offsets match
        move.w  -4(a0), d1                      ; start x,y
        move.w  (a0), d2                        ; rx,ry
        sub.b   d2, d1
        move.b  d1, (piece+1)                   ; adjusted y
        lsr.w   #8, d1
        lsr.w   #8, d2
        sub.b   d2, d1
        move.b  d1, (piece)                     ; adjusted x
        piececommit

        ; update color & pattern for current piece
        move.w  -2(a0), d0
        move.b  d0, d1
        lsr.l   #8, d0
        andi.l  #$0000000f, d0
        andi.l  #$0000000f, d1
        jsr     pieceupdcol
        ; boardplot is called here so that when a piece is released into the
        ; board it is automatically re-drawn (to avoid game loop complexity)
        jsr     boardplot
        jsr     pieceplot

        move.l  #SNC_PIECE_TIME, (SNC_CNT_DOWN) ; reset piece sync counter

        movem.w (a7)+, d0-d2/a0
        rts

; set the color profile for the current piece and level
;
; input    : d0.l - color
;            d1.l - pattern
; output   :
; modifies :
pieceupdcol:
        movem.l d0-d2/a0, -(a7)

        cmp.b   #0, d1
        bne     .pattern2
        move.l  #piece_ptrn1, (piece_ptrn)
        bra     .color
.pattern2:
        move.l  #piece_ptrn2, (piece_ptrn)
.color:
        ; a0 -> color map address
        ; d2 -> current level
        moveq.l #0, d2
        move.b  (levelnum), d2
        lea.l   piece_colmap, a0
        lsl.l   #1, d2                          ; level*2
        add.l   d0, d2                          ; level*2 + color offset
        lsl.l   #2, d2                          ; (level*2 + color offset)*4
        move.l  (a0,d2), d2

        ; copy current color to piece_ptrnx
        move.l  d2, (piece_ptrn1+(3*4))
        move.l  d2, (piece_ptrn1+(12*4))
        move.l  d2, (piece_ptrn2+(3*4))

        movem.l (a7)+, d0-d2/a0
        rts

; rotate piece right (decrease orientation index by 1)
;
; input    :
; output   :
; modifies :
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

; rotate piece left (decrease orientation index by 1)
;
; input    :
; output   :
; modifies :
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

; move piece up by \1
;
; input    : \1 movement length
; output   :
; modifies :
piecemovu: macro
        subq.b  \1, (piece+1)
        endm

; move piece down by \1
;
; input    : \1 movement length
; output   :
; modifies :
piecemovd: macro
        addq.b  \1, (piece+1)
        endm

; move piece left by \1
;
; input    : \1 movement length
; output   :
; modifies :
piecemovl: macro
        subq.b  \1, (piece)
        endm

; move piece right by \1
;
; input    : \1 movement length
; output   :
; modifies :
piecemovr: macro
        addq.b  \1, (piece)
        endm

; check for out of board bounds piece & collisions with other pieces
;
; input    :
; output   : d0.l -> 1 if collision was detected, 0 otherwise
; modifies : d0.l
piececoll:
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
        cmp.b   #$ff, d2
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

; release current piece to the board
;
; input    :
; output   :
; modifies :
piecerelease:
        movem.l d0-d6/a0-a1, -(a7)

        ; a0.l -> piece matrix
        ; d4.b -> piece color<<4|pattern
        move.l  (piece+4), a0
        move.w  -2(a0), d4
        move.b  d4, d0
        lsr.w   #4, d4
        or.b    d0, d4

        ; a1.l -> piece matrix
        lea.l   board, a1

        ; d2.l -> piece matrix width
        ; d3.l -> piece matrix height
        move.w  (piece+2), d0                   ; orientation index
        moveq.l #0, d2
        moveq.l #0, d3
        pdim    d0, d2
        move.b  d2, d3
        lsr.l   #8, d2
        poff    d0, d1                          ; calculate array offset
        add.l   d0, a0                          ; offset a0 to point to current orientation matrix
        addq.l  #2, a0                          ; offset a0 to point to piece matrix (skip rx, ry)
        move.l  d3, d6                          ; save matrix height for later

        ; d0.l -> piece x coord (within board)
        ; d1.l -> piece y coord (within board)
        moveq.l #0, d0
        moveq.l #0, d1
        move.w  (piece), d0
        move.b  d0, d1
        lsr.w   #8, d0
        ; i = y*width + x
        move.l  d1, d5
        ; TODO: can muls be optimized?
        muls    #BOARD_WIDTH, d5                ; y*width
        add.l   d0, d5                          ; y*width + x
        add.l   d5, a1

        move.l  d2, d5                          ; width loop counter
        subq.l  #1, d5
        subq.l  #1, d3
.loop:
        btst    #0, (a0)+
        beq     .nitr
        move.b  d4, (a1)
.nitr:
        addq.l  #1, a1
        dbra    d5, .loop
        move.l  d2, d5                          ; reset width counter
        subq.l  #1, d5

        add.l   #BOARD_WIDTH, a1                ; go down one row
        sub.l   d2, a1

        dbra    d3, .loop
.done:
        movem.l (a7)+, d0-d6/a0-a1
        rts

; check horizontal fill for x consecutive rows
;
; input    : d0.l - start y board coordinate
;            d1.l - number of rows to check
; output   : d4.l - row shift status
; modifies :
boardchkfill:
        movem.l d0-d3/a0-a1, -(a7)

        ; d2.b -> end y board coordinate
        move.b  d0, d2
        add.b   d1, d2
        subq.b  #1, d2
        ; d4.l -> row fill status
        moveq.l #0, d4
.loopy:
        ; a0.l -> board start address
        lea.l   board, a0
        moveq.l #0, d1
        move.b  d0, d1
        mulu    #BOARD_WIDTH, d1                ; i = y*width
        add.l   d1, a0
        move.l  a0, a1

        ; d1.w -> width loop counter
        move.w  #BOARD_WIDTH-1, d1
        lsl.l   #1, d4                          ; shift fill status
.loopx:
        move.b  (a0)+, d3
        cmp.b   #$ff, d3
        beq     .nitr
        dbra.w  d1, .loopx

        ; clear row
        move.w  #BOARD_WIDTH-1, d1
.loopclr:
        move.b  #$ff, (a1)+
        dbra.w  d1, .loopclr
        ori.l   #1, d4                          ; indicate fill

.nitr:
        addq.b  #1, d0
        cmp.b   d2, d0
        bls     .loopy

        movem.l (a7)+, d0-d3/a0-a1
        rts

; d0.l -> start y board coordinate
; d1.l -> number of rows in row status
; d4.l -> row fill status
boarddropdown:
        movem.l d0-d2/d4/a0-a1, -(a7)
        ; d0.l -> board bottom row coordinate
        add.l   d1, d0
        subq.l  #1, d0
        ; a0.l -> board dst row address
        ; a1.l -> board src row address
        lea.l   board, a0
        move.l  d0, d1                          ; board base row
        mulu    #BOARD_WIDTH, d1                ; board base row offset
        add.l   d1, a0
        move.l  a0, a1
        ; d1.b -> empty row counter
        moveq.l #0, d1
.loop:
        btst.l  #0, d4
        beq     .drop                           ; check if row has to be dropped
        addq.l  #1, d1                          ; increate row counter
        bra     .nitr
.drop:
        tst.l   d1
        beq     .skip
        cmpa.l  a0, a1
        beq     .nitr

        move.l  #BOARD_WIDTH-1, d2              ; copy loop counter & offset
.copy:
        move.b  (a1,d2.l), (a0,d2.l)            ; copy src to dst row
        move.b  #$ff, (a1,d2.l)                 ; clear src row
        dbra    d2, .copy
.skip:
        sub.l   #BOARD_WIDTH, a0                ; move dst up one row
.nitr:
        sub.l   #BOARD_WIDTH, a1                ; move src up one row
        lsr.l   #1, d4
        dbra    d0, .loop
.done:
        movem.l (a7)+, d0-d2/d4/a0-a1
        rts

boardclrfill:
; sp+0 -> column count [1, BOARD_WIDTH/2]
; sp+2 -> board start y coord << 8 | row count
; sp+4 -> row fill status higher word
; sp+6 -> row fill status lower word
        movem.l d0-d6, -(a7)

.base:  equ     32                              ; pc + d0-d6 = 8*4 = 32

        ; set color to black
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15

        ; d1.w -> start x pixel
        ; d3.w -> end x pixel
        move.w  .base+0(a7), d0
        move.w  #BOARD_WIDTH/2, d1
        sub.w   d0, d1                          ; start count
        lsl.w   #1, d0                          ; column count * 2
        move.w  d1, d3
        add.w   d0, d3                          ; end column
        add.w   #BOARD_BASE_X, d1               ; tile start x
        add.w   #BOARD_BASE_X, d3               ; tile end x
        lsl.w   #TILE_SHIFT, d1                 ; pixel start x
        lsl.w   #TILE_SHIFT, d3                 ; pixel end x
        sub.w   #1, d3

        ; d0.b -> trap 15 task number
        move.b  #87, d0

        ; d5.l -> row fill status
        move.l  .base+4(a7), d6

        ; d5.w -> y loop counter
        move.b  .base+3(a7), d5                 ; row count
        subq.b  #1, d5
.loop:
        btst    #0, d6
        beq     .nitr
        moveq.l #0, d2
        move.b  .base+2(a7), d2                 ; board start y coord
        add.b   d5, d2                          ; current board y coord
        add.b   #BOARD_BASE_Y, d2               ; current tile y coord
        lsl.w   #TILE_SHIFT, d2                 ; start y pixel
        move.w  d2, d4
        add.w   #TILE_SIZE-1, d4                ; end y pixel
        trap    #15
.nitr:
        lsr.l   #1, d6
        dbra.w  d5, .loop

        movem.l (a7)+, d0-d6
        rts

; --- plotting -----------------------------------------------------------------

; piece color map by level
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
        dc.l    $00000000                       ; current piece pattern address

        ifeq    GLB_SCALE-GLB_SCALE_SMALL
piece_ptrn0:
        dc.l    $00000000, $00000000, $000f000f
        dc.l    $ffffffff
piece_ptrn1:
        dc.l    $00000000, $00000000, $000f000f
        dc.l    $000038f8, $00000000, $000e000e
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00020002, $00060006
        dc.l    $000038f8, $00040004, $00060006
        dc.l    $ffffffff
piece_ptrn2:
        dc.l    $00000000, $00000000, $000f000f
        dc.l    $000038f8, $00000000, $000e000e
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00020002, $000c000c
        dc.l    $ffffffff
        endc

        ifeq    GLB_SCALE-GLB_SCALE_BIG
piece_ptrn0:
        dc.l    $00000000, $00000000, $001e001e
        dc.l    $ffffffff
piece_ptrn1:
        dc.l    $00000000, $00000000, $001e001e
        dc.l    $000038f8, $00000000, $001c001c
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $000c000c
        dc.l    $000038f8, $00080008, $000c000c
        dc.l    $ffffffff
piece_ptrn2:
        dc.l    $00000000, $00000000, $001e001e
        dc.l    $000038f8, $00000000, $001c001c
        dc.l    $00ffffff, $00000000, $00040004
        dc.l    $00ffffff, $00040004, $00180018
        dc.l    $ffffffff
        endc

; clear previous piece plot
;
; input    :
; output   :
; modifies :
piececlr:
        movem.l d0-d3/d5-d6/a0-a2, -(a7)
        ; a0.l ->  piece tile pattern
        lea.l   piece_ptrn0, a0
        ; a2.l -> piece address
        lea.l   pieceprev, a2
        bra     _pieceplot
; plot piece with the corresponding color & pattern
;
; input    :
; output   :
; modifies :
pieceplot:
        movem.l d0-d3/d5-d6/a0-a2, -(a7)
        ; a0.l ->  piece tile pattern
        move.l  (piece_ptrn), a0
        ; a2.l -> piece address
        lea.l   piece, a2
_pieceplot:
        ; a1.l -> piece matrix
        move.l  4(a2), a1
        ; d2.l -> piece matrix width
        ; d3.l -> piece matrix height
        move.w  2(a2), d0                       ; orientation index
        moveq.l #0, d2
        moveq.l #0, d3
        pdim    d0, d2
        move.b  d2, d3
        lsr.l   #8, d2
        poff    d0, d1                          ; calculate array offset
        add.l   d0, a1                          ; offset a1 to point to current orientation matrix
        addq.l  #2, a1                          ; offset a1 to point to piece matrix (skip rx, ry)

        ; d5.l -> tile x coord (relative to screen)
        move.l  #BOARD_BASE_X, d5
        move.b  (a2), d1
        ext.w   d1
        add.w   d1, d5
        ; d6.l -> tile y coord (relative to screen)
        move.l  #BOARD_BASE_Y, d6
        move.b  1(a2), d1
        ext.w   d1
        add.w   d1, d6

        jsr     piecematplot

        movem.l (a7)+, d0-d3/d5-d6/a0-a2
        rts

; plot piece matrix
;
; input    : d2.l - piece matrix width
;            d3.l - piece matrix height
;            d5.l - tile x coord
;            d6.l - tile y coord
;            a0.l - piece pattern address
;            a1.l - piece matrix address
; output   :
; modifies :
piecematplot:
        movem.l d0-d1/d5-d6/a1, -(a7)
        ; d0.b -> matrix x index (only used as loop counter)
        moveq.l #0, d0
        ; d1.b -> matrix y index (only used as loop counter)
        moveq.l #0, d1
.loop:
        btst    #0, (a1)+
        beq     .nitr                           ; skip plot if empty cell
        jsr     drawtile
.nitr:
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
        movem.l (a7)+, d0-d1/d5-d6/a1
        rts

; clear plotted pieces from board
;
; input    :
; output   :
; modifies :
boardclr:
        movem.l d0-d4, -(a7)
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #BOARD_BASE_X<<TILE_SHIFT, d1
        move.w  #BOARD_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BOARD_BASE_X+BOARD_WIDTH)<<TILE_SHIFT, d3
        move.w  #(BOARD_BASE_Y+BOARD_HEIGHT)<<TILE_SHIFT, d4
        trap    #15
        movem.l (a7)+, d0-d4
        rts

; plot current board pieces with their corresponding color & pattern
; (does not clear pieces; only draws existing ones)
;
; input    :
; output   :
; modifies :
boardplot:
        movem.l d0-d3/d5-d6/a0-a1, -(a7)
        jsr     boardclr
        ; a1.l -> board address
        ; d2.l -> board x index
        ; d3.l -> board y index
        ; d5.l -> board tile x coord
        ; d6.l -> board tile y coord
        lea.l   board, a1
        moveq.l #0, d2
        moveq.l #0, d3
        move.l  #BOARD_BASE_X, d5
        move.l  #BOARD_BASE_Y, d6
.loop:
        move.b  (a1)+, d0
        cmp.b   #$ff, d0
        beq     .nitr                           ; skip plot if empty cell

        ; d0.b -> color
        ; d1.b -> pattern
        move.b  d0, d1
        lsr.b   #4, d0
        andi.l  #$0000000f, d0
        andi.l  #$0000000f, d1
        jsr     pieceupdcol
        move.l  (piece_ptrn), a0
        jsr     drawtile
.nitr:
        addq.l  #1, d2                          ; increment x index
        addq.l  #1, d5                          ; increment tile x coord
        cmp.b   #BOARD_WIDTH, d2
        blo     .loop

        moveq.l #0, d2                          ; reset x index
        move.l  #BOARD_BASE_X, d5               ; reset tile x coord
        addq.l  #1, d3                          ; increment y coord
        addq.l  #1, d6                          ; increment tile y coord
        cmp.b   #BOARD_HEIGHT, d3
        blo     .loop
.done:
        ; restore piece color & pattern
        moveq.l #0, d0
        moveq.l #0, d1
        move.l  (piece+4), a0
        move.w  -2(a0), d0
        move.b  d0, d1
        lsr.l   #8, d0
        jsr     pieceupdcol

        movem.l (a7)+, d0-d3/d5-d6/a0-a1
        rts
