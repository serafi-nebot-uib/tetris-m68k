PIECE_WIDTH: equ 4
PIECE_HEIGHT: equ 2

SCO_SINGLE: equ 40
SCO_DOUBLE: equ 100
SCO_TRIPLE: equ 300
SCO_TETRIS: equ 1200

; TODO: move variables to game vars (necessary?)
levelcnt: dc.w  0                               ; current total level
levelnum: dc.b  0                               ; current piece color level
piecenum: dc.b  0
piecenumn: dc.b 0
        ds.w    0
piecestats: dc.w 0,0,0,0,0,0,0
linecount: dc.w 0
score:  dc.l    0
scorevals: dc.w SCO_SINGLE, SCO_DOUBLE, SCO_TRIPLE, SCO_TETRIS
scoretable: dc.w SCO_SINGLE, SCO_DOUBLE, SCO_TRIPLE, SCO_TETRIS
; drop table in drops/(ms/10)
droptable:
        dc.b    80, 71, 63, 55, 46, 38, 30, 21, 13, 10
        dc.b    8, 8, 8, 6, 6, 6, 5, 5, 5
        dc.b    3, 3, 3, 3, 3, 3, 3, 3, 3
        dc.b    2
        ds.w    0

;--- logic ---------------------------------------------------------------------

; current (falling) piece data structure
piece:
        dc.b    0                               ; x
        dc.b    0                               ; y
        dc.b    0                               ; drop y
        dc.b    0                               ; orientation index
        dc.l    pieceT                          ; piece address

; copy of current piece data structure; allows to rollback any changes
pieceprev:
        dc.b    0                               ; x
        dc.b    0                               ; y
        dc.b    0                               ; drop y
        dc.b    0                               ; orientation index
        dc.l    pieceT                          ; piece address

; board representation as a matrix
board:
        ; ds.b    BRD_WIDTH*BRD_HEIGHT
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
pieceoff: macro
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

; get piece color & pattern from piece address
;
; input    : \1 piece address
; output   : \2 piece color
;            \3 piece pattern
; modifies :
piececolptrn: macro
        move.w  -2(\1), \2
        move.b  \2, \3
        lsr.l   #8, \2
        andi.l  #$0000000f, \2
        andi.l  #$0000000f, \3
        endm

; initialize piece stored in piecenumn and set next piece number
;
; input    : d0.b - next piece number lo load
; output   :
; modifies :
pieceinit:
        movem.l d0-d2/a0, -(a7)

        move.b  #0, (piece+3)                   ; reset orientation index to 0

        moveq.l #0, d1
        move.b  (piecenumn), d1
        move.b  d1, (piecenum)
        move.b  d0, (piecenumn)

        ; andi.l  #$000000ff, d1
        ; divu    #7, d1
        ; swap    d1
        ; andi.l  #$ffff, d1
        ; move.b  d1, (piecenum)                  ; store new piecenum

        ; get piece matrix data address with piece number
        lsl.l   #2, d1
        lea.l   piece_table, a0
        move.l  (a0,d1), a0

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
        piececolptrn a0, d0, d1
        jsr     pieceupdcol
        ; boardplot is called here so that when a piece is released into the
        ; board it is automatically re-drawn (to avoid game loop complexity)
        jsr     boardplot
        jsr     pieceplot
        ; jsr     piecedropfind

        movem.l (a7)+, d0-d2/a0
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
        move.l  d2, (piece_ptrn1sm+(3*4))
        move.l  d2, (piece_ptrn1sm+(12*4))
        move.l  d2, (piece_ptrn2+(3*4))
        move.l  d2, (piece_ptrn2sm+(3*4))

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
        move.b  (piece+3), d0                   ; orientation index
        pieceoff d0, d1

        move.l  (piece+4), a0                   ; piece matrix address
        move.w  (a0,d0), d1                     ; get current x,y offset
        add.b   d1, (piece+1)                   ; remove y offset
        lsr.w   #8, d1
        add.b   d1, (piece)                     ; remove x offset

        ; cycle to next piece address
        moveq.l #0, d0
        move.b  (piece+3), d0                   ; orientation index
        addq.w  #1, d0                          ; increment orientation index
        ; wrap around every 4 (faster than getting the modulus)
        cmp.w   #4, d0
        blo     .off
        moveq.l #0, d0                          ; reset to 0 if d0 >= 4
.off:
        move.b  d0, (piece+3)
        pieceoff d0, d1

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
        move.b  (piece+3), d0                   ; orientation index
        pieceoff d0, d1

        move.l  (piece+4), a0                   ; piece matrix address
        move.w  (a0,d0), d1                     ; get current x,y offset
        add.b   d1, (piece+1)                   ; remove y offset
        lsr.w   #8, d1
        add.b   d1, (piece)                     ; remove x offset

        ; cycle to next piece address
        moveq.l #0, d0
        move.b  (piece+3), d0                   ; orientation index
        subq.w  #1, d0                          ; decrement orientation index
        ; wrap around every 4 (faster than getting the modulus)
        bge     .off
        moveq.l #3, d0                          ; reset to 3 if d0 < 0
.off:
        move.b  d0, (piece+3)
        pieceoff d0, d1

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
        move.b  (piece+3), d0                   ; orientation index
        pdim    d0, d4                          ; matrix dimensions (d3 width, d4 height)
        move.w  d4, d3
        lsr.w   #8, d3
        pieceoff d0, d1                         ; calculate array offset
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
        cmp.b   #BRD_WIDTH, d2                  ; is current x > board width?
        bge     .collision
.chky:
        ; y idx + y coord
        move.b  d1, d2                          ; y idx
        add.b   (piece+1), d2                   ; y idx + y coord
        bmi     .collision                      ; is current y < 0?
        cmp.b   #BRD_HEIGHT, d2                 ; is current y > board height?
        bge     .collision
        ; check block collision
        ; idx = x + piece x + (y + piece y) * BRD_WIDTH
        ; multiply d2 by BRD_WIDTH
        ; d2*10 = d2*(8+2) = d2*8 + d2*2 = d2<<3 + d2<<1
        move.w  d2, d5
        lsl.w   #3, d2                          ; multiply by 8
        lsl.w   #1, d5                          ; multiply by 2
        add.w   d5, d2                          ; (y + piece y) * BRD_WIDTH
        add.b   d0, d2                          ; (y + piece y) * BRD_WIDTH + x
        add.b   (piece), d2                     ; (y + piece y) * BRD_WIDTH + x + piece x
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
        move.b  (piece+3), d0                   ; orientation index
        moveq.l #0, d2
        moveq.l #0, d3
        pdim    d0, d2
        move.b  d2, d3
        lsr.l   #8, d2
        pieceoff d0, d1                         ; calculate array offset
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
        muls    #BRD_WIDTH, d5                  ; y*width
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

        add.l   #BRD_WIDTH, a1                  ; go down one row
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
        mulu    #BRD_WIDTH, d1                  ; i = y*width
        add.l   d1, a0
        move.l  a0, a1

        ; d1.w -> width loop counter
        move.w  #BRD_WIDTH-1, d1
        lsl.l   #1, d4                          ; shift fill status
.loopx:
        move.b  (a0)+, d3
        cmp.b   #$ff, d3
        beq     .nitr
        dbra.w  d1, .loopx

        ; clear row
        move.w  #BRD_WIDTH-1, d1
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

piecedropfind:
        move.l  d0, -(a7)
.drop:
        piecemovd #1
        jsr     piececoll
        tst.b   d0
        beq     .drop
        piecemovu #1
        move.b  (piece+1), d0
        piecerollback
        move.b  d0, (piece+2)
        move.l  (a7)+, d0
        rts

; drop non-filled rows according to row shift status
;
; input    : d0.l - start y board coordinate
;            d1.l - number of rows in row status
;            d4.l - row fill status
; output   :
; modifies :
boarddropdown:
        movem.l d0-d2/d4/a0-a1, -(a7)
        ; d0.l -> board bottom row coordinate
        add.l   d1, d0
        subq.l  #1, d0
        ; a0.l -> board dst row address
        ; a1.l -> board src row address
        lea.l   board, a0
        move.l  d0, d1                          ; board base row
        mulu    #BRD_WIDTH, d1                  ; board base row offset
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

        move.l  #BRD_WIDTH-1, d2                ; copy loop counter & offset
.copy:
        move.b  (a1,d2.l), (a0,d2.l)            ; copy src to dst row
        move.b  #$ff, (a1,d2.l)                 ; clear src row
        dbra    d2, .copy
.skip:
        sub.l   #BRD_WIDTH, a0                  ; move dst up one row
.nitr:
        sub.l   #BRD_WIDTH, a1                  ; move src up one row
        lsr.l   #1, d4
        dbra    d0, .loop
.done:
        movem.l (a7)+, d0-d2/d4/a0-a1
        rts

boardclrfill:
; sp+0 -> column count [1, BRD_WIDTH/2]
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
        move.w  #BRD_WIDTH/2, d1
        sub.w   d0, d1                          ; start count
        lsl.w   #1, d0                          ; column count * 2
        move.w  d1, d3
        add.w   d0, d3                          ; end column
        add.w   #BRD_BASE_X, d1                 ; tile start x
        add.w   #BRD_BASE_X, d3                 ; tile end x
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
        add.b   #BRD_BASE_Y, d2                 ; current tile y coord
        lsl.w   #TILE_SHIFT, d2                 ; start y pixel
        move.w  d2, d4
        add.w   #TILE_SIZE-1, d4                ; end y pixel
        trap    #15
.nitr:
        lsr.l   #1, d6
        dbra.w  d5, .loop

        movem.l (a7)+, d0-d6
        rts

; update drop rate according to current level
;
; input    :
; output   :
; modifies :
boarddropupd:
        movem.l d0/a0, -(a7)

        moveq.l #0, d0
        move.w  (levelcnt), d0
        cmp.w   #28, d0
        bls     .upd
        move.w  #28, d0
.upd:
        lea.l   droptable, a0
        move.b  (a0,d0), d0
        andi.l  #$ff, d0
        move.l  d0, (SNC_PIECE_TIME)

        movem.l (a7)+, d0/a0
        rts

; update piece colors based on current level
;
; input    :
; output   :
; modifies :
boardlvlupd:
        movem.l d0-d7/a0-a4, -(a7)
        ; clear previous level number
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #BRD_LVL_BASE_X<<TILE_SHIFT, d1
        move.w  #BRD_LVL_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BRD_LVL_BASE_X+3)<<TILE_SHIFT-1, d3
        move.w  #(BRD_LVL_BASE_Y+1)<<TILE_SHIFT-1, d4
        trap    #15

        ; convert current level number to bcd
        moveq.l #0, d0
        move.w  (levelcnt), d0
        moveq.l #3, d1
        lea.l   .lvldigits, a0
        jsr     bcd

        ; plot number from bcd result
        moveq.l #1, d3
        move.w  #BRD_LVL_SIZE, d4
        move.w  #BRD_LVL_BASE_X, d5
        move.w  #BRD_LVL_BASE_Y, d6
        move.l  a0, a1
        jsr     drawnum

        moveq.l #PIECE_WIDTH, d2
        moveq.l #PIECE_HEIGHT, d3
        move.w  #BRD_STAT_BASE_Y+(6*3+1), d6
        lea.l   piece_table, a2
        lea.l   .statoff, a3
        lea.l   .spacing+28, a4
        moveq.l #6, d7
.loop:
        ; a1.l - piece address
        move.l  a2, a1
        move.l  d7, d0
        moveq.l #0, d1
        move.b  (a3,d0), d1
        move.w  #BRD_STAT_BASE_X, d5
        add.w   d1, d5
        lsl.l   #2, d0
        move.l  (a1,d0), a1
        piececolptrn a1, d0, d1
        jsr     pieceupdcol

        btst    #0, d1                          ; mira el bit de patró de la peça (0: patró 1/ 1: patró 2)
        bne     .isptrn2                        ; si el bit de patró és 1 -> jumps .isptrn2
        addi.l  #64, (piece_ptrn)               ; suma el desplaçament per a situarse sobre piece_ptrn1sm
        bra     .nxtstep
.isptrn2:
        addi.l  #52, (piece_ptrn)               ; suma el desplaçament per a situarse sobre piece_ptrn2sm
.nxtstep:
        move.l  (piece_ptrn), a0
        addq.l  #2, a1

        move.l  -(a4), (tileoffset)
        jsr     piecematplotsm
        subq.w  #3, d6

        dbra    d7, .loop
        move.l  #0, (tileoffset)                ; resets tileoffset
        jsr     boardplot

        movem.l (a7)+, d0-d7/a0-a4
        rts

.spacing:
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
        dc.l    $00040014, $0004001a, $0004001c, $0009001e, $00040022, $00040028, $00090025
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
        dc.l    $00000014, $0000001a, $0000001d, $000a0022, $00000026, $00000031, $00050026
        endc

.statoff: dc.b  1,1,1,2,1,1,1
.lvldigits: dc.b 0,0,0
        ds.w    0

; --- plotting -----------------------------------------------------------------

; piece color map by level
piece_colmap:
        * ---    color1   color2     --- *
        dc.l    $ec3820, $fcbc3c                ; level0
        dc.l    $00a800, $10d080                ; level1
        dc.l    $cc00d8, $f878f8                ; level2
        dc.l    $f85800, $54d858                ; level3
        dc.l    $5800e4, $98f858                ; level4
        dc.l    $98f858, $fc8868                ; level5
        dc.l    $0038f8, $7c7c7c                ; level6
        dc.l    $fc4468, $2000a8                ; level7
        dc.l    $f85800, $0038f8                ; level8
        dc.l    $0038f8, $44a0fc                ; level9

piece_ptrn:
        dc.l    $00000000                       ; current piece pattern address

        ifeq    GLB_SCALE-GLB_SCALE_SMALL
piece_ptrn0:
        dc.l    $00000000, $00000000, $000f000f
        dc.l    $ffffffff
piece_ptrn1:
        dc.l    $00000000, $00000000, $000f000f
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $000e000e
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $000d000d
        endc
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $00050005
        dc.l    $000038f8, $00040004, $00060006
        dc.l    $ffffffff
piece_ptrn1sm:                                  ;***MINI TILES, ACTUAL:-4, 16*0,21=3,37 -> 4
        dc.l    $00000000, $00000000, $000b000b 
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $000a000a
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $00090009
        endc
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $00050005
        dc.l    $000038f8, $00040004, $00060006
        dc.l    $ffffffff
piece_ptrn2:
        dc.l    $00000000, $00000000, $000f000f
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $000e000e
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $000c000c
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $000d000d
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $000b000b
        endc
        dc.l    $ffffffff
piece_ptrn2sm:
        dc.l    $00000000, $00000000, $000b000b
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $000a000a
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $00080008 
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $00090009
        dc.l    $00ffffff, $00000000, $00010001
        dc.l    $00ffffff, $00020002, $00070007
        endc
        dc.l    $ffffffff
        endc

        ifeq    GLB_SCALE-GLB_SCALE_BIG
piece_ptrn0:
        dc.l    $00000000, $00000000, $001e001e
        dc.l    $ffffffff
piece_ptrn1:
        dc.l    $00000000, $00000000, $001e001e
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $001c001c
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $001b001b
        endc
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $000a000a
        dc.l    $000038f8, $00070007, $000c000c
        dc.l    $ffffffff
piece_ptrn1sm:                                  ***MINI TILES, ACTUAL: -7  32*0,21=6,75 -> 7
        dc.l    $00000000, $00000000, $00150015
        ifeq    GLB_VER-GLB_VER_HIGHRES
        dc.l    $000038f8, $00000000, $00130013
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $00120012
        endc
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $000a000a 
        dc.l    $000038f8, $00070007, $000c000c
        dc.l    $ffffffff
piece_ptrn2:
        dc.l    $00000000, $00000000, $001e001e
        ifeq    GLB_VER-GLB_VER_HIGHRES 
        dc.l    $000038f8, $00000000, $001c001c
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $00180018
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $001b001b
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $00170017
        endc
        dc.l    $ffffffff
piece_ptrn2sm:
        dc.l    $00000000, $00000000, $00150015
        ifeq    GLB_VER-GLB_VER_HIGHRES 
        dc.l    $000038f8, $00000000, $00130013
        endc
        ifeq    GLB_VER-GLB_VER_ORIGINAL
        dc.l    $000038f8, $00000000, $00120012
        endc
        dc.l    $00ffffff, $00000000, $00020002
        dc.l    $00ffffff, $00040004, $000f000f
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
        move.b  3(a2), d0                       ; orientation index
        moveq.l #0, d2
        moveq.l #0, d3
        pdim    d0, d2
        move.b  d2, d3
        lsr.l   #8, d2
        pieceoff d0, d1                         ; calculate array offset
        add.l   d0, a1                          ; offset a1 to point to current orientation matrix
        addq.l  #2, a1                          ; offset a1 to point to piece matrix (skip rx, ry)

        ; d5.l -> tile x coord (relative to screen)
        move.l  #BRD_BASE_X, d5
        move.b  (a2), d1
        ext.w   d1
        add.w   d1, d5
        ; d6.l -> tile y coord (relative to screen)
        move.l  #BRD_BASE_Y, d6
;         tst.b   d4
;         bne     .alty
        move.b  1(a2), d1
        ext.w   d1
        add.w   d1, d6
;         bra     .plot
; .alty:
;         add.w   d4, d6
; .plot:
        jsr     piecematplot

        movem.l (a7)+, d0-d3/d5-d6/a0-a2
        rts

; plots small piece matrix
;
; input    : d2.l - piece matrix width
;            d3.l - piece matrix height
;            d5.l - tile x coord
;            d6.l - tile y coord
;            a0.l - piece pattern address
;            a1.l - piece matrix address
; output   :
; modifies :
piecematplotsm:
        movem.l d0-d1/d5-d6/a1-a2, -(a7)
        
        cmp.l   #0, (tileoffset)
        beq     .notileoff
        lea.l   drawtileoffsm, a2
        bra     _piecematplot    
.notileoff:
        lea.l   drawtilesm, a2
        bra     _piecematplot  
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
        movem.l d0-d1/d5-d6/a1-a2, -(a7)

        cmp.l   #0, (tileoffset)
        beq     .notileoff
        lea.l   drawtileoff, a2
        bra     _piecematplot
.notileoff:
        lea.l   drawtile, a2         
_piecematplot:
        ; d0.b -> matrix x index (only used as loop counter)
        moveq.l #0, d0
        ; d1.b -> matrix y index (only used as loop counter)
        moveq.l #0, d1
.loop:
        btst    #0, (a1)+
        beq     .nitr                           ; skip plot if empty cell       
        jsr     (a2)
.nitr:   
        addq.w  #1, d5                          ; increment tile x coord    
    
        addq.l  #1, d0                          ; increment matrix x index
        cmp.b   d2, d0                          ; compare matrix x index with matrix width
        blo     .loop

        moveq.l #0, d0                          ; reset matrix x index
        
        sub.w   d2, d5                          ; reset tile x coord to start position
        addq.w  #1, d6                          ; increment tile y coord
        
        addq.l  #1, d1                          ; increment matrix y index
        cmp.b   d3, d1                          ; compare matrix y index with matrix height
        blo     .loop
.done:
        movem.l (a7)+, d0-d1/d5-d6/a1-a2
        rts

; increase and plot line count
;
; input    : d0.l - increment amount
; output   :
; modifies :
boardlineinc:
        movem.l d0-d6/a0-a1, -(a7)

        add.w   (linecount), d0
        move.w  d0, (linecount)

        moveq.l #BRD_LINE_CNT_SIZE, d1
        lea.l   .digits, a0
        jsr     bcd

        ; clear previous line count
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #BRD_LINE_CNT_BASE_X<<TILE_SHIFT, d1
        move.w  #BRD_LINE_CNT_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BRD_LINE_CNT_BASE_X+BRD_LINE_CNT_SIZE)<<TILE_SHIFT-1, d3
        move.w  #(BRD_LINE_CNT_BASE_Y+1)<<TILE_SHIFT-1, d4
        trap    #15

        moveq.l #1, d3
        move.w  #BRD_LINE_CNT_SIZE, d4
        move.l  #BRD_LINE_CNT_BASE_X, d5
        move.l  #BRD_LINE_CNT_BASE_Y, d6
        move.l  a0, a1
        jsr     drawnum

        movem.l (a7)+, d0-d6/a0-a1
        rts
.digits:
        dc.b    0,0,0
        ds.w    0

; increase score table by one level
;
; input    :
; output   :
; modifies :
boardscoreinc:
        movem.l d0-d1/a0, -(a7)
        ; a0.l -> scorevals address
        ; a1.l -> scoretable address
        lea.l   scorevals, a0
        lea.l   scoretable, a1
        ; d0.l -> scoretable offset
        moveq.l #0, d0
.loop:
        move.w  (a0,d0), d1
        add.w   (a1,d0), d1
        move.w  d1, (a1,d0)
        addq.l  #2, d0                          ; move offset to next word
        cmp.l   #4*2, d0
        blo     .loop
        movem.l (a7)+, d0-d1/a0
        rts

; increase score by line clear count & plot changes
;
; input    : d0.l - line clear count (must be between [1,4])
; output   :
; modifies :
boardscoreupd:
        movem.l d0-d6/a0-a1, -(a7)

        ; update score by line clear count
        subq.l  #1, d0
        lsl.l   #1, d0
        lea.l   scoretable, a0
        move.w  (a0,d0), d0
        add.l   (score), d0
        move.l  d0, (score)

        moveq.l #BRD_SCO_SIZE, d1
        lea.l   .digits, a0
        jsr     bcd

        ; clear previous score
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #BRD_SCO_BASE_X<<TILE_SHIFT, d1
        move.w  #BRD_SCO_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BRD_SCO_BASE_X+BRD_SCO_SIZE)<<TILE_SHIFT-1, d3
        move.w  #(BRD_SCO_BASE_Y+1)<<TILE_SHIFT-1, d4
        trap    #15

        moveq.l #1, d3
        move.w  #BRD_SCO_SIZE, d4
        move.w  #BRD_SCO_BASE_X, d5
        move.w  #BRD_SCO_BASE_Y, d6
        move.l  a0, a1
        jsr     drawnum

        movem.l (a7)+, d0-d6/a0-a1
        rts
.digits:
        dc.b    0,0,0,0,0
        ds.w    0

; save and plot next piece in the next box
;
; input    : d0.l - piece number
; output   :
; modifies :
boardnextupd:
        movem.l d0-d6/a0-a1, -(a7)

        ;checks if piece is O or I, can be optimised. (?)
        cmp.l   #3, d0
        beq     .isOorI
        cmp.l   #6, d0
        beq     .isOorI

        ;sets an offset to center the piece on next square
        move.l  #$00080000, (tileoffset)
        bra     .nxtstep
.isOorI:
        move.l  #$00000000, (tileoffset)
.nxtstep:
        move.b  d0, d5
        lsl.l   #2, d0
        lea.l   piece_table, a1
        move.l  (a1,d0), a1
        piececolptrn a1, d0, d1
        jsr     pieceupdcol
        move.l  (piece_ptrn), a0
        addq.l  #2, a1

        ; clear next box
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.w  #BRD_NEXT_BASE_X<<TILE_SHIFT, d1
        move.w  #BRD_NEXT_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BRD_NEXT_BASE_X+4)<<TILE_SHIFT-1, d3
        move.w  #(BRD_NEXT_BASE_Y+2)<<TILE_SHIFT-1, d4
        trap    #15

        moveq.l #PIECE_WIDTH, d2
        moveq.l #PIECE_HEIGHT, d3
        move.l  #BRD_NEXT_BASE_Y, d6
        cmp     #6, d5
        beq     .line
        move.l  #BRD_NEXT_BASE_X+1, d5
        bra     .plot
.line:
        move.l  #BRD_NEXT_BASE_X, d5
.plot:
        jsr     piecematplot
        move.l  #0, (tileoffset)

        ; restore piece color & pattern
        move.l  (piece+4), a0
        piececolptrn a0, d0, d1
        jsr     pieceupdcol
        movem.l (a7)+, d0-d6/a0-a1
        rts

; update piece statistic
;
; input    : d0.l - new statistic number
;            d2.l - piece number
; output   :
; modifies :
boardstatupd:
        movem.l d0-d6/a0-a1, -(a7)
        ; convert number to bcd
        moveq.l #3, d1
        lea.l   .digits, a0
        jsr     bcd

        move.l  #BRD_STAT_BASE_X+1, d5
        ; tile y coord = piece number * 3 + BRD_STAT_BASE_Y
        move.l  d2, d6
        lsl.l   #1, d6
        add.l   #BRD_STAT_BASE_Y-4, d6

        ; clear current number
        ; set color
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15
        ; draw rectangle
        move.b  #87, d0
        move.l  d5, d1
        move.l  d5, d3
        addq.l  #3, d3
        move.l  d6, d2
        move.l  d6, d4
        addq.l  #1, d4
        lsl.l   #TILE_SHIFT, d1
        lsl.l   #TILE_SHIFT, d2
        lsl.l   #TILE_SHIFT, d3
        lsl.l   #TILE_SHIFT, d4
        trap    #15

        ; plot number from bcd result
        moveq.l #1, d3
        move.w  #BRD_STAT_SIZE, d4
        move.l  #$000019bc, d1
        move.l  a0, a1
        jsr     drawnumcol

        movem.l (a7)+, d0-d6/a0-a1
        rts
.digits: ds.b   3
        ds.w    0

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
        move.w  #BRD_BASE_X<<TILE_SHIFT, d1
        move.w  #BRD_BASE_Y<<TILE_SHIFT, d2
        move.w  #(BRD_BASE_X+BRD_WIDTH)<<TILE_SHIFT-1, d3
        move.w  #(BRD_BASE_Y+BRD_HEIGHT)<<TILE_SHIFT-1, d4
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
        move.l  #BRD_BASE_X, d5
        move.l  #BRD_BASE_Y, d6
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
        cmp.b   #BRD_WIDTH, d2
        blo     .loop

        moveq.l #0, d2                          ; reset x index
        move.l  #BRD_BASE_X, d5                 ; reset tile x coord
        addq.l  #1, d3                          ; increment y coord
        addq.l  #1, d6                          ; increment tile y coord
        cmp.b   #BRD_HEIGHT, d3
        blo     .loop
.done:
        ; restore piece color & pattern
        move.l  (piece+4), a0
        piececolptrn a0, d0, d1
        jsr     pieceupdcol

        movem.l (a7)+, d0-d3/d5-d6/a0-a1
        rts
