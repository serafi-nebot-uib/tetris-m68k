        org     $1000

        include 'board.x68'
        include 'helper.x68'

; Z shape for testing
srcmat: dc.b    $01, $01, $00, $00, $00, $01, $01, $00

start:
        move.l  #srcmat, -(a7)                  ; source piece layout matrix
        move.w  #0<<8|0, -(a7)                  ; rx, ry
        move.w  #-3<<8|-1, -(a7)                ; x, y
        jsr     pieceinit
        addq.l  #8, a7                          ; pop stack

; --- RECTANGLE INTERECTION ----------------------------------------------------
        lea.l   piece, a0
        ; load current matrix address into a1
        lea.l   piece, a1
        addq.l  #4, a1
        move.l  (a1), a1

        ; piece y end | board y end
        move.b  -1(a1), d0                      ; current piece height
        add.b   1(a0), d0                       ; add current y coordinate to calculate piece y end
        lsl.w   #8, d0                          ; shift left to make space for board y end
        move.b  #BOARDHEIGHT, d0                ; load board y end
        move.w  d0, -(a7)

        ; piece x end | board x end
        move.b  -2(a1), d0                      ; current piece width
        add.b   (a0), d0                        ; add current x coordinate to calcualate piece x end
        lsl.w   #8, d0                          ; shift left to make space for board x end
        move.b  #BOARDWIDTH, d0                 ; load board x end
        move.w  d0, -(a7)

        ; piece y start | board y start
        move.b  1(a0), d0                       ; piece y start
        lsl.w   #8, d0                          ; shift left to load board y start (always a 0)
        move.w  d0, -(a7)

        ; piece x start | board x start
        move.b  (a0), d0                        ; piece x start
        lsl.w   #8, d0                          ; shift left to load board x start (always a 0)
        move.w  d0, -(a7)

        jsr     rectintersect

        ; get rectintersect results
        ;    d0 -> x start
        ;    d1 -> y start
        ;    d2 -> x end
        ;    d3 -> y end
        clr.l   d0
        clr.l   d1
        clr.l   d2
        clr.l   d3
        clr.l   d4
        movem.w (a7)+, d0-d3

; --- COLLISION DETECTION ------------------------------------------------------
        sub.w   d0, d2                          ; d2 -> dx
        sub.w   d1, d3                          ; d3 -> dy

        ; a0 -> piece address (already loaded by rectintersect argument setup)
        ; a1 -> board address
        lea.l   board, a1

; .loop:
;         cmpm.b  (a0)+, (a1)+
;         dbra    d2, .loop                       ; x loop
;         dbra    d3, .loop                       ; y loop

        ; stop simulator
        move.b  #9, d0
        trap    #15

        end     start
