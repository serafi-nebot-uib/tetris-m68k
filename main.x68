        org     $1000

        include 'piece.x68'
        include 'helper.x68'

; Z shape for testing
srcmat: dc.b    $01, $01, $00, $00, $00, $01, $01, $00

start:
        move.l  #srcmat, -(a7)                  ; source piece layout matrix
        move.w  #1<<8|1, -(a7)                  ; rx, ry
        move.w  #7<<8|19, -(a7)                 ; x, y
        jsr     pieceinit
        addq.l  #8, a7                          ; pop stack

        ; polyinter arguments
        lea.l   piece, a0

        ; piece y end | board y end
        move.b  #PHEIGHT-1, d0
        add.b   1(a0), d0
        lsl.w   #8, d0
        move.b  #BOARDHEIGHT-1, d0
        move.w  d0, -(a7)

        ; piece x end | board x end
        move.b  #PWIDTH-1, d0
        add.b   (a0), d0
        lsl.w   #8, d0
        move.b  #BOARDWIDTH-1, d0
        move.w  d0, -(a7)

        ; piece y start | board y start
        move.b  1(a0), d0
        lsl.w   #8, d0
        move.w  d0, -(a7)

        ; piece x start | board x start
        move.b  (a0), d0
        lsl.w   #8, d0
        move.w  d0, -(a7)

        jsr     polyinter

        ; get results
        movem.w (a7)+, d0-d3

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
