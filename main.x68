        org     $1000

        include 'board.x68'
        include 'piece.x68'
        include 'helper.x68'

start:
        move.l  #pieceT, -(a7)                  ; source piece layout matrix
        move.w  #0<<8|3, -(a7)                  ; rx, ry
        ; load x and y into d0 before moving to the stack to allow for negative numbers
        move.b  #5, d0                          ; x
        lsl.w   #8, d0
        move.b  #6, d0                          ; y
        move.w  d0, -(a7)
        jsr     pieceinit
        addq.l  #8, a7                          ; pop stack

        ; jsr     piecerotr                       ; rotate piece right
        ; jsr     piecerotl                       ; rotate piece left
        ;
        ; ; detect collisions
        ; subq.l  #2, a7                          ; reserve space for return value
        ; jsr     piececol
        ; move.w  (a7)+, d1

        jsr     pieceplot
        jsr     piecerotr

        jsr     pieceplot
        jsr     piecerotr

        jsr     pieceplot
        jsr     piecerotr

        jsr     pieceplot
        jsr     piecerotr

        jsr     pieceplot

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
