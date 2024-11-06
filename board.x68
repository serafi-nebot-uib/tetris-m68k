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
        ; multiply d0 by PSIZE+2 to get current orientation offset
        move.w  d0, d1
        lsl.w   #3, d0                          ; multiply by 8 (PSIZE)
        lsl.w   #1, d1                          ; multiply by 2 (rx,ry offset)
        add.w   d1, d0

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
        ; multiply d0 by PSIZE+2 get current orientation offset
        move.w  d0, d1
        lsl.w   #3, d0                          ; multiply by 8 (PSIZE)
        lsl.w   #1, d1                          ; multiply by 2 (rx,ry offset)
        add.w   d1, d0

        ; adjust new x,y offset
        move.w  (a0,d0), d1                     ; get new x,y offset
        sub.b   d1, (piece+1)                   ; add y offset
        lsr.w   #8, d1
        sub.b   d1, (piece)                     ; add x offset

        movem.l (a7)+, d0-d1/a0
        rts

; TODO: implement piecerotl

; piececoll:
;         ; a0 -> current piece orientation matrix address
;         clr.l   a0
;         move.w  (piece+2), a0
;         mulu    #PSIZE+2, a0
;         add.l   #2, a0
;         add.l   (piece+4), a0
;
;         ; d5 -> current piece orientation matrix width
;         move.w  (piece+2), d0
;         divu    #2, d0
;         swap    d0
;         cmp.w   #0, d0
;         bne     .vert
;         move.w  #PWIDTH, d5
;         bra     .loop
; .vert:
;         move.w  #PHEIGHT, d5
;
;         move.w  #PSIZE-1, d0                    ; piece matrix index
; .loop:
;         ; x = i % width
;         move.l  d0, d1
;         divu    d5, d1
;         swap    d1
;
;         ; y = (i - x) / w
;         move.l  d0, d2
;         sub.l   d1, d2
;         divu    d5, d2
;
;         dbra.w  d0, .loop
;
;         rts

























; TODO: delete this; only for testing
pieceplot:
        ; clear screen
        move.b  #11, d0
        move.w  #$ff00, d1
        trap    #15

        ; draw current piece
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

; ; --- piece data structure -----------------------------------------------------
; ; current falling piece data
; piece:
;         ds.b    1                               ; x
;         ds.b    1                               ; y
;         dc.l    hmat                            ; current matrix
;         dc.l    vmat                            ; previous matrix
;
; ; current matrix data
;         ds.b    1                               ; rx (rotate x index)
;         ds.b    1                               ; ry (rotate y index)
;         dc.b    PWIDTH                          ; number of columns (width)
;         dc.b    PHEIGHT                         ; number of rows (height)
; hmat:
;         ds.b    PSIZE                           ; current matrix
;         ds.w    0                               ; align
;
; ; previous matrix data
;         ds.b    1                               ; rx (rotate x index)
;         ds.b    1                               ; ry (rotate y index)
;         dc.b    PHEIGHT                         ; number of columns (width)
;         dc.b    PWIDTH                          ; number of rows (height)
; vmat:
;         ds.b    PSIZE                           ; previous matrix
;         ds.w    0
;
; ; --- board array --------------------------------------------------------------
; ; representation of the game board; each entry indicates what block is in that
; ; board cell
; board:
;         ; ds.b    BOARDWIDTH*BOARDHEIGHT
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         dc.b    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;         ds.w    0
;
; ; --- board update array -------------------------------------------------------
; ; 0xff terminated array where entry indicates the index of the board array whose
; ; block has been updated. used for efficient plotting
; boardupd: 
;         ds.b    BOARDSIZE+1
;         ds.w    0
;
; ; TODO: remove this, this is for testing
;
; boardupdadd:
; ; add index to board upd array
; ; arguments:
; ;    sp+0: index to append to boardupd
;         movem.l d0-d1/a0, -(a7)                 ; 3 * 4 = 12 bytes
; .base:  equ     16                              ; 12 + 4 (PC) = 16
;
;         lea.l   boardupd, a0
;         clr.w   d0                              ; boardupd index
; .loop:
;         ; check if d0 is out of bounds
;         cmp.w   #BOARDSIZE, d0
;         bls     .done
;         ; get current value and increment index
;         move.b  (a0,d0), d1
;         addq.w  #1, d0
;         ; check if current value is terminator sequence
;         eor.b   #$ff, d0
;         bne     .loop
;         ; copy index to update to boardupd
;         move.b  .base+1(a7), (a0,d0)
;         ; add terminator value
;         addq.b  #1, d0
;         move.b  #$ff, (a0,d0)
; .done:
;         movem.l (a7)+, d0-d1/a0
;         rts
;
; piececlr:
; ; add removed piece blocks to boardupd array
; ;    (to clear previous blocks from screen)
; ; arguments:
; ;    d5 -> x coord
; ;    d6 -> y coord
;         movem.l d0-d4/a0, -(a7)
;
;         move.l  (piece+6), a0                   ; load previous matrix address
;         move.b  -2(a0), d3                      ; piece width
;         clr.w   d0                              ; piece matrix x coord
;         clr.w   d1                              ; piece matrix y coord
; .loop:
;         ; check block bounds
;         ; idx = x + y*width
;         move.b  d1, d2                          ; y
;         mulu    d3, d2                          ; y * width
;         add.b   d0, d2                          ; y * width + x
;         move.b  (a0,d2), d4                     ; get current piece block
;         ; if current piece block is empty there's nothing else to check
;         beq     .nitr
;         ; check if current piece position is out of board bounds (for x & y)
; .chkx:
;         move.b  d0, d2                          ; x idx
;         add.b   d5, d2                          ; x idx + x piece coordinate
;         bmi     .nitr                           ; is current x < 0?
;         cmp.b   #BOARDWIDTH, d2                 ; is current x > board width?
;         bge     .nitr
; .chky:
;         move.b  d1, d2                          ; y idx
;         add.b   d6, d2                          ; y idx + y piece coordinate
;         bmi     .nitr                           ; is current y < 0?
;         cmp.b   #BOARDHEIGHT, d2                ; is current y > board height?
;         bge     .nitr
;         ; add piece block index to boardupd array
;         ; idx = x + piece x + (y + piece y)*BOARDWIDTH
;         move.b  d1, d2                          ; y
;         add.b   (piece+1), d2                   ; y + piece y
;         mulu    #BOARDWIDTH, d2                 ; (y + piece y) * width
;         add.b   d0, d2                          ; (y + piece y) * width + x
;         add.b   (piece), d2                     ; (y + piece y) * width + x + piece x
;         move.w  d2, -(a7)                       ; push boardupadd argument
;         jsr     boardupdadd
;         addq.w  #2, a7                          ; pop boardupdadd argument
; .nitr:
;         addq.b  #1, d0                          ; increment x index
;         cmp.b   d3, d0                          ; compare with piece width
;         blo     .loop
;         clr.b   d0                              ; reset x index
;         addq.b  #1, d1                          ; increment y index
;         cmp.b   -1(a0), d1                      ; compare with piece height
;         blo     .loop
; .done:
;         movem.l (a7)+, d0-d4/a0
;         rts
;
; piecedown:
;         movem.w d0/d1, -(a7)
;
;         addq.b  #1, (piece+1)                   ; increment piece y
;         jsr     piececol                        ; check for collisions
;         cmp     #0, d0
;         beq     .upd
;         subq.b  #1, (piece+1)                   ; restore piece to previous location
;         bra     .done
; .upd:
;         ; add previous piece block indeces to boardupd (clear previous blocks)
;         clr.w   d0
;         clr.w   d1
;         move.b  (piece), d0                     ; x coord
;         move.b  (piece+1), d1                   ; y coord
;         subq.b  #1, d1                          ; return to previous y coord
;         jsr     piececlr
; .done:
;         movem.w (a7)+, d0-d1
;         rts
;
; pieceleft:
;         rts
;
; pieceright:
;         rts
;
; piecerotr:
; ; cycle piece forward (rotate right)
; ; TODO: adjust piece to rotatation pivot
; ;    1. get pivot x,y in board
; ;    2. rotate piece
; ;    3. get pivot new x,y in board
; ;    4. adjust pivot new x,y to previous x,y
;         move.l  a0, -(a7)
;
;         ; reverse last matrix
;         move.l  (piece+6), -(a7)                ; push last matrix address
;         move.w  #PSIZE, -(a7)                   ; push matrix size
;         jsr     arrrev                          ; reverse array
;         addq.l  #6, a7                          ; remove arguments from stack
;
;         ; swap current & last matrices
;         move.l  (piece+2), a0
;         move.l  (piece+6), (piece+2)
;         move.l  a0, (piece+6)
;
;         movem.l (a7)+, a0
;         rts
;
; piecerotl:
; ; cycle piece backward (rotate left)
;         move.l  a0, -(a7)
;
;         ; reverse last matrix
;         move.l  (piece+2), -(a7)                ; push current matrix address
;         move.w  #PSIZE, -(a7)                   ; push matrix size
;         jsr     arrrev                          ; reverse array
;         addq.l  #6, a7                          ; remove arguments from stack
;
;         ; swap current & last matrices
;         move.l  (piece+2), a0
;         move.l  (piece+6), (piece+2)
;         move.l  a0, (piece+6)
;
;         movem.l (a7)+, a0
;         rts
;
; pieceinit:
; ; arguments:
; ;       sp+0 (x pos)
; ;       sp+1 (y pos)
; ;       sp+2 (rx idx)
; ;       sp+3 (ry idx)
; ;       sp+4 - sp+7 (src piece matrix address)
; ;---------------------------------------------
; ; d0: loop counter [0..PSIZE-1]
; ; d1: src piece matrix offset for vmat
; ; d2: temporary calculations
; ; d3: current piece matrix cell value (a0+d0)
; ; a0: src piece matrix address
;         movem.l d0-d3/a0-a2, -(a7)              ; (4 + 3) * 4 = 28
; .base:  equ     32                              ; 28 + 4 (PC) =  32
;
;         lea.l   hmat, a1
;         lea.l   vmat, a2
;         move.l  .base+4(a7), a0                 ; load address of current matrix
;         move.w  .base+0(a7), (piece)            ; copy x, y
;         move.w  .base+2(a7), d0
;         move.w  d0, -4(a1)                      ; copy rx, ry to hmat
;
;         ; calculate vmat rx, ry
;         move.b  d0, -4(a2)                      ; copy new rx
;         lsr     #8, d0                          ; rx
;         move.b  -1(a1), d1                      ; hmat h
;         subq.b  #1, d1                          ; hmat h - 1
;         sub.b   d0, d1                          ; hmat h - 1 - rx
;         move.b  d1, -3(a2)                      ; copy new ry
;
;         clr.l   d0
;         clr.l   d1
; .hmatcpy:
;         ; copy matrix data to hmat
;         move.b  (a0)+, d3
;         move.b  d3, (a1)+
;
;         ; copy matrix data to vmat
;         ; hmat -> vmat:
;         ;       vmat[((size) - 1) - ((i % width) * height) - int(i < width)] = hmat[i]
;         ; NOTE: magic formula works for 4x2, not tested for other dimensions
;         ; TODO: this whole calculation can probably be optimised
;         move.w  d0, d1
;         divu    #PWIDTH, d1
;         move.l  #16, d2
;         lsr.l   d2, d1                          ; calculate the remainder
;         mulu.w  #-PHEIGHT, d1
;         add.w   #PSIZE-1, d1
;         cmp.w   #PWIDTH, d0
;         bge     .vmatcpy
;         subq.w  #1, d1
; .vmatcpy:
;         ; clear higher word from possible calculation overflow
;         andi.l  #$0000ffff, d1
;         move.b  d3, (a2,d1)
;
;         addq.w  #1, d0
;         cmp.w   #PSIZE, d0
;         blt     .hmatcpy
;
;         movem.l (a7)+, d0-d3/a0-a2
;         rts
;
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
