        org     $1000

        include 'board.x68'
        include 'piece.x68'

start:
        move.w  #5<<8|5, d0                     ; x << 8 | y
        lea.l   pieceT, a0
        jsr     pieceinit

.loop:
        jsr     pieceplot
        jsr     piecerotr
        bra     .loop

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
