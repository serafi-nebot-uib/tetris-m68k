piece_list:
        dc.l    pieceT, pieceJ, pieceZ, pieceO, pieceS, pieceL, pieceI

        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceT:
        ; (1)
        dc.b    $01, $00                        ; x, y
        dc.b    $01, $01, $01, $00
        dc.b    $00, $01, $00, $00

        ; (2)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01, $00, $00
        dc.b    $01, $01, $01, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $00, $00

        dc.b    0                               ; color
        dc.b    0                               ; pattern
pieceJ:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $01, $01, $01, $00
        dc.b    $00, $00, $01, $00

        ; (2)
        dc.b    $01, $02                        ; x, y
        dc.b    $00, $01
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00, $00, $00
        dc.b    $01, $01, $01, $00

        ; (4)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $00, $00

        dc.b    1                               ; color
        dc.b    0                               ; pattern
pieceZ:
        ; (1)
        dc.b    $01, $00                        ; x, y
        dc.b    $01, $01, $00, $00
        dc.b    $00, $01, $01, $00

        ; (2)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $01, $00, $00
        dc.b    $00, $01, $01, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $00, $00

        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceO:
        ; (1)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01, $00, $00
        dc.b    $01, $01, $00, $00

        ; (2)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01
        dc.b    $01, $01
        dc.b    $00, $00
        dc.b    $00, $00

        ; (3)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01, $00, $00
        dc.b    $01, $01, $00, $00

        ; (4)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01
        dc.b    $01, $01
        dc.b    $00, $00
        dc.b    $00, $00

        dc.b    0                               ; color
        dc.b    0                               ; pattern
pieceS:
        ; (1)
        dc.b    $01, $00                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $01, $01, $00, $00

        ; (2)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $01, $01, $00, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $00

        dc.b    1                               ; color
        dc.b    0                               ; pattern
pieceL:
        ; (1)
        dc.b    $00, $00                        ; x, y
        dc.b    $01, $01, $01, $00
        dc.b    $01, $00, $00, $00

        ; (2)
        dc.b    $01, $00                        ; x, y
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $02, $01                        ; x, y
        dc.b    $00, $00, $01, $00
        dc.b    $01, $01, $01, $00

        ; (4)
        dc.b    $00, $02                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $00

        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceI:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $01, $01, $01, $01
        dc.b    $00, $00, $00, $00

        ; (2)
        dc.b    $00, $02                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00

        ; (3)
        dc.b    $02, $00                        ; x, y
        dc.b    $01, $01, $01, $01
        dc.b    $00, $00, $00, $00

        ; (4)
        dc.b    $00, $02                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
