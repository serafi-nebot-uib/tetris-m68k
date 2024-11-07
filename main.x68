        org     $1000

        include 'board.x68'
        include 'piece.x68'

start:
        move.w  #8<<8|1, d0                     ; x << 8 | y
        lea.l   pieceT, a0
        jsr     pieceinit
        jsr     piecerotr
        jsr     piecerotr
        jsr     pieceplot
        jsr     piececoll

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
