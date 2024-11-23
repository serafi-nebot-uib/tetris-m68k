PIECE_WIDTH: equ 4
PIECE_HEIGHT: equ 2
PIECE_SIZE: equ PIECE_WIDTH*PIECE_HEIGHT

BOARD_WIDTH: equ 10
BOARD_HEIGHT: equ 20
BOARD_SIZE: equ BOARD_WIDTH*BOARD_HEIGHT

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
        move.b  #1, (piecenum)
        jsr     piecelvl

        ; copy data to pieceprev
        move.l  (piece), (pieceprev)
        move.l  (piece+4), (pieceprev+4)

        move.w  (a7)+, d1
        rts

piecelvl:
; set the color profile for the selected level
; input   : none
; output  : none
; modifies: none
; ------------------------------------------------------------------------------
        movem.l d1/a0, -(a7)

        moveq.l #0, d1
        move.b  (levelnum), d1
        lsl.l   #2, d1

        lea.l   piece_colormap, a0
        move.l  (a0,d1.w), piececol1
        addq.l  #4, a0
        move.l  (a0,d1.w), piececol2

        movem.l (a7)+, d1/a0
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

pieceupd:
; rollback piece if collision detected
; otherwise, clear previous piece, plot current piece, and copy current piece to previous piece
        jsr     piececoll
        cmp     #0, d0
        beq     .clear
        piecerollback
        bra     .done
; --- clear previous piece -----------------------------------------------------
.clear:
        moveq.l #0, d0
        move.l  (pieceprev+4), a0               ; piece address
        move.w  (pieceprev+2), d0               ; orientation index
        pdim    d0, d4                          ; matrix dimensions (d3 width, d4 height)
        move.w  d4, d3
        lsr.w   #8, d3
        poff    d0, d1                          ; calculate array offset
        add.l   d0, a0                          ; offset a0 to point to the correct matrix
        add.l   #2, a0                          ; offset a0 to point to piece matrix (skip rx, ry)

        moveq.l #0, d0                          ; x index
        moveq.l #0, d1                          ; y index
        moveq.l #0, d2                          ; accumulator
.clear_loop:
        ; check block bounds
        move.b  d1, d2                          ; y
        ; TODO: optimize mulu (lsl?)
        mulu    d3, d2                          ; y * width
        add.b   d0, d2                          ; y * width + x
        move.b  (a0,d2), d5                     ; get current piece block
        ; if current piece block is empty there's nothing else to check
        beq     .clear_nitr

        ; set block fill & border color to black
        move.l  #$00000000, d1
        move.b  #80, d0
        trap    #15
        move.b  #81, d0
        trap    #15

        ; draw rectangle
        move.b  #87, d0
        trap    #15
.clear_nitr:
        addq.b  #1, d0                          ; increment x index
        cmp.b   d3, d0                          ; compare with matrix width
        blo     .clear_loop
        moveq.l #0, d0                          ; reset x index
        addq.b  #1, d1                          ; increment y index
        cmp.b   d4, d1                          ; compare with matrix height
        blo     .clear_loop
.done:
        rts





; --- plotting -----------------------------------------------------------------

COLOR0  equ     $00000000                       ; black (border)
COLOR1  equ     $000038f8                       ; red
COLOR2  equ     $00ffffff                       ; white
CONTOUR_SIZE equ 2

piece_pattern1:
        dc.b    0, TILE_SIZE                    ; black background
        dc.b    0, TILE_SIZE-CONTOUR_SIZE       ; main block
        dc.b    0, CONTOUR_SIZE                 ; small accent
        dc.b    CONTOUR_SIZE, CONTOUR_SIZE+CONTOUR_SIZE*2 ; big accent
        dc.b    CONTOUR_SIZE+CONTOUR_SIZE*2/2, CONTOUR_SIZE+CONTOUR_SIZE*2 ; remove big portion of accent
        ds.w    0

piece_pattern2:
        dc.b    0, TILE_SIZE                    ; black background
        dc.b    0, TILE_SIZE-CONTOUR_SIZE       ; main block
        dc.b    0, CONTOUR_SIZE                 ; small accent
        dc.b    CONTOUR_SIZE, TILE_SIZE-CONTOUR_SIZE*2 ; big accent
        ds.w    0

contourcol1: dc.l COLOR0, COLOR1, COLOR1, COLOR2, COLOR1 ;DEFAULT COLORS OF PATTERN1  
tilecol1: dc.l  COLOR0, COLOR1, COLOR2, COLOR2, COLOR1 ;DEFAULT COLORS OF PATTERN1
tilecol2: dc.l  COLOR0, COLOR1, COLOR2, COLOR2  ;DEFAULT COLORS OF PATTERN2

piece_colormap:
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

piececol1: dc.l $ec3820                         ; color1 [pattern1: j,s / pattern2: t,o,i]
piececol2: dc.l $fcbc3c                         ; color2 [pattern1: z,l]

pltguide:
        dc.l    pieceplot2                      ; T
        dc.l    pieceplot1                      ; J
        dc.l    pieceplot1                      ; Z
        dc.l    pieceplot2                      ; O
        dc.l    pieceplot1                      ; S
        dc.l    pieceplot1                      ; L
        dc.l    pieceplot2                      ; I

clrguide:
        dc.l    piececol1                       ; T
        dc.l    piececol1                       ; J
        dc.l    piececol2                       ; Z
        dc.l    piececol1                       ; O
        dc.l    piececol1                       ; S
        dc.l    piececol2                       ; L
        dc.l    piececol1                       ; I

clrreg  macro
        moveq.l #0, d0
        moveq.l #0, d1
        moveq.l #0, d2
        moveq.l #0, d3
        moveq.l #0, d4
        endm

pieceplot1:
; plot pattern1 tile
; input    : d0 (x coord), d1 (y coord)
; output   : none
; modifies : none
; ------------------------------------------------------------------------------
        movem.l d0-d7/a0-a2, -(a7) 

        ; TODO: change input to d5,d6 to avoid extra moves
        move.l  d0, d5
        move.l  d1, d6
        ; multiply coordinates by tile size to get actual x/y positions
        lsl.l   #4, d5
        lsl.l   #4, d6

        lea     tilecol1, a0
        lea     piece_pattern1, a1
        lea     contourcol1, a2
        clrreg

        moveq   #4, d7
.loop:
        move.l  (a2)+, d1
        moveq   #80, d0                         ; set contour color
        trap    #15

        move.l  (a0)+, d1
        moveq   #81, d0                         ; set fill color
        trap    #15

        clrreg
        ; set coordinates
        move.b  (a1), d1
        add.w   d5, d1                          ; start x
        move.b  (a1)+, d2
        add.w   d6, d2                          ; start y

        move.b  (a1), d3
        add.w   d5, d3                          ; end x
        move.b  (a1)+, d4
        add.w   d6, d4                          ; end y

        ; draw rectangle
        moveq   #87, d0
        trap    #15

        dbra    d7, .loop

        movem.l (a7)+, d0-d7/a0-a2
        rts

pieceplot2:
; plot pattern2 tile
; input    : d0 (x coord), d1 (y coord)
; output   : none
; modifies : none
; ------------------------------------------------------------------------------     

        movem.l d0-d7/a0-a1, -(a7)

        ; TODO: change input to d5,d6 to avoid extra moves
        move.l  d0, d5
        move.l  d1, d6
        ; multiply coordinates by tile size to get actual x/y positions
        lsl.l   #4, d5
        lsl.l   #4, d6

        lea     tilecol2, a0
        lea     piece_pattern2, a1
        clrreg

        moveq   #3, d7
.loop:
        ; set rectangle color
        move.l  (a0)+, d1
        moveq   #80, d0                         ; set contour color
        trap    #15
        moveq   #81, d0                         ; set fill color
        trap    #15

        clrreg
        ; set coordinates
        move.b  (a1), d1
        add.w   d5, d1                          ; start x
        move.b  (a1)+, d2
        add.w   d6, d2                          ; start y

        move.b  (a1), d3
        add.w   d5, d3                          ; end x
        move.b  (a1)+, d4
        add.w   d6, d4                          ; end y

        ; draw rectangle
        moveq   #87, d0
        trap    #15

        dbra    d7, .loop

        movem.l (a7)+, d0-d7/a0-a1
        rts

pieceplot:
        movem.l d0-d2/a0-a2, -(a7)

        ; get color and pattern for current piece
        moveq   #0, d1
        move.b  (piecenum), d1
        lsl.w   #2, d1
        lea     clrguide, a0
        movea.l (a0,d1.w), a1
        move.l  (a1), d2
        lea     pltguide, a0
        movea.l (a0,d1.w), a1

        ; update current piece color
        ; TODO: only do this when there's a level change
        move.l  d2, tilecol2+$4
        move.l  d2, tilecol1+$4
        move.l  d2, tilecol1+$10

        ;if piece is T,O,I this is not needed:
        move.l  d2, contourcol1+$4
        move.l  d2, contourcol1+$10
        move.l  d2, contourcol1+$8

        moveq.l #0, d0                          ; tile x
        moveq.l #0, d1                          ; tile y
        jsr     (a1)                            ; jump to pattern plot subrouting

        movem.l (a7)+, d0-d2/a0-a2
        rts

























; ; TODO: delete this; only for testing
; pieceplot:
;         ; clear screen
;         move.b  #11, d0
;         move.w  #$ff00, d1
;         trap    #15
;
;         ; draw board
;         move.b  #81, d0
;         move.l  #$00000000, d1
;         trap    #15
;
;         move.b  #80, d0
;         move.l  #$00ff0000, d1
;         trap    #15
;
;         ; draw rectangle
;         move.b  #87, d0
;         move.l  #0, d1
;         move.l  #0, d2
;         move.l  #10*20, d3
;         move.l  #20*20, d4
;         trap    #15
;
;         ; draw current piece
;         move.b  #80, d0
;         move.l  #$00000000, d1
;         trap    #15
;
;         move.b  #81, d0
;         move.l  #$0000ff00, d1
;         trap    #15
;
;         clr.l   d0
;         lea.l   piece, a0                       ; piece address
;         move.l  4(a0), a0                       ; piece matrix address
;         move.w  (piece+2), d0                   ; piece orientation index
;         mulu    #PIECE_SIZE+2, d0                    ; get current orientation offset
;         addq.l  #2, a0                          ; offset x,y offsets
;         add.l   d0, a0
;
;         clr.w   d5                              ; piece matrix index
;
;         ; get current piece width and height
;         move.w  (piece+2), d0                   ; piece orientation index
;         divu    #2, d0
;         swap    d0
;         cmp.w   #0, d0
;         bne     .vert
;         move.w  #PIECE_WIDTH, d6                     ; width
;         bra     .loop
; .vert:
;         move.w  #PIECE_HEIGHT, d6                    ; width
;
; .loop:
;         cmp.b   #0, (a0,d5)
;         beq     .nitr
;
;         ; x = i mod w
;         clr.l   d1
;         move.w  d5, d1
;         divu    d6, d1
;         swap    d1
;
;         ; y = (i - x) / w
;         move.w  d5, d2
;         sub.w   d1, d2
;         divu    d6, d2
;
;         clr.w   d3
;         clr.w   d4
;         move.b  (piece), d3
;         move.b  (piece+1), d4
;         add.w   d3, d1
;         add.w   d4, d2
;
;         ; draw rectangle
;         move.b  #87, d0
;         mulu    #20, d1
;         move.w  d1, d3
;         add.w   #20, d3
;         mulu    #20, d2
;         move.w  d2, d4
;         add.w   #20, d4
;         trap    #15
; .nitr:
;         ; next iteration
;         addq.w  #1, d5
;         cmp     #PIECE_SIZE, d5
;         blo     .loop
;         rts
