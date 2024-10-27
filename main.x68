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

        jsr     piecefwd                        ; rotate piece right
        jsr     piecebak                        ; rotate piece left

        ; detect collisions
        subq.l  #2, a7                          ; reserve space for return value
        jsr     boardcol
        move.w  (a7)+, d1

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
