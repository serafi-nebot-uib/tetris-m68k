        org     $1000

        include 'board.x68'
        include 'helper.x68'

; Z shape for testing
srcmat: dc.b    $01, $01, $00, $00, $00, $01, $01, $00

start:
        move.l  #srcmat, -(a7)                  ; source piece layout matrix
        move.b  #0<<8|0, -(a7)                  ; rx, ry
        ; load x and y into d0 before moving to the stack to allow for negative numbers
        move.b  #0, d0                          ; x
        lsl.w   #8, d0
        move.b  #0, d0                          ; y
        move.w  d0, -(a7)

        jsr     pieceinit
        addq.l  #8, a7                          ; pop stack

; --- COLLISION DETECTION ------------------------------------------------------
        lea.l   piece, a0                       ; piece address
        move.l  4(a0), a1                       ; current matrix address
        lea.l   board, a2                       ; board matrix address

        clr.w   d0
        clr.w   d1
        clr.w   d2
        clr.w   d3
        move.b  -2(a1), d3                      ; piece width
.loop:
        ; idx = x + y*width
        move.b  d1, d2                          ; y
        mulu    d3, d2                          ; y * width
        add.b   d0, d2                          ; y * width + x
        move.b  (a1,d2), d2                     ; get current piece block
        ; if current piece block is empty there's nothing else to check
        beq     .nitr

        ; check if current piece position is out of board bounds (for x & y)
.chkx:
        move.b  d0, d2                          ; x idx
        add.b   (a0), d2                        ; x idx + x piece coordinate
        bmi     .collision                      ; is current x < 0?
        cmp.b   #BOARDWIDTH, d2                 ; is current x > board width?
        bge     .collision
.chky:
        move.b  d1, d2                          ; y idx
        add.b   1(a0), d2                       ; y idx + y piece coordinate
        bmi     .collision                      ; is current y < 0?
        cmp.b   #BOARDHEIGHT, d2                ; is current y > board height?
        bge     .collision

        ; calculate board index
        ; check if both piece and board have a 1
.nitr:
        addq.b  #1, d0                          ; increment x index
        cmp.b   d3, d0                          ; compare with piece width
        blo     .loop
        clr.b   d0                              ; reset x index
        addq.b  #1, d1                          ; increment y index
        cmp.b   -1(a1), d1                      ; compare with piece height
        blo     .loop
        bra     .done

.collision:
        move.l  #1, d5

.done:
        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
