piece_table:
        dc.l    pieceT, pieceJ, pieceZ, pieceO, pieceS, pieceL, pieceI

; NOTE: piece orientation matrices cannot permit the first cell to be out of
; bounds. For example, the following matrix is not valid because it allows the
; left column to be out of bounds:
;       dc.b    $00, $01
;       dc.b    $00, $01
;       dc.b    $00, $01
;       dc.b    $00, $01
; while the following is correct:
;       dc.b    $01, $00
;       dc.b    $01, $00
;       dc.b    $01, $00
;       dc.b    $01, $00
; This can be fixed in piecerelease but would decrease performance. The "fix" is
; perfomed here as it doesn't affect code complexity and does not decrease
; performance.

        dc.b    5                               ; start x
        dc.b    0                               ; start y
        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceT:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $00, $01, $01, $01
        dc.b    $00, $00, $01, $00

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

        dc.b    5                               ; start x
        dc.b    0                               ; start y
        dc.b    0                               ; color
        dc.b    0                               ; pattern
pieceJ:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $00, $01, $01, $01
        dc.b    $00, $00, $00, $01

        ; (2)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $00, $00, $00
        dc.b    $01, $01, $01, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $00, $00

        dc.b    5                               ; start x
        dc.b    1                               ; start y
        dc.b    1                               ; color
        dc.b    0                               ; pattern
pieceZ:
        ; (1)
        dc.b    $02, $01                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $00, $00, $01, $01

        ; (2)
        dc.b    $00, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $00                        ; x, y
        dc.b    $01, $01, $00, $00
        dc.b    $00, $01, $01, $00

        ; (4)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $01
        dc.b    $01, $01
        dc.b    $01, $00
        dc.b    $00, $00

        dc.b    4                               ; start x
        dc.b    0                               ; start y
        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceO:
        ; (1)
        dc.b    $01, $00                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $00, $01, $01, $00

        ; (2)
        dc.b    $00, $01                        ; x, y
        dc.b    $00, $00
        dc.b    $01, $01
        dc.b    $01, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $00                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $00, $01, $01, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $00, $00
        dc.b    $01, $01
        dc.b    $01, $01
        dc.b    $00, $00

        dc.b    5                               ; start x
        dc.b    1                               ; start y
        dc.b    0                               ; color
        dc.b    0                               ; pattern
pieceS:
        ; (1)
        dc.b    $02, $01                        ; x, y
        dc.b    $00, $00, $01, $01
        dc.b    $00, $01, $01, $00

        ; (2)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $00                        ; x, y
        dc.b    $00, $01, $01, $00
        dc.b    $01, $01, $00, $00

        ; (4)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $00

        dc.b    5                               ; start x
        dc.b    0                               ; start y
        dc.b    1                               ; color
        dc.b    0                               ; pattern
pieceL:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $00, $01, $01, $01
        dc.b    $00, $01, $00, $00

        ; (2)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $01
        dc.b    $00, $01
        dc.b    $00, $01
        dc.b    $00, $00

        ; (3)
        dc.b    $01, $01                        ; x, y
        dc.b    $00, $00, $01, $00
        dc.b    $01, $01, $01, $00

        ; (4)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $01
        dc.b    $00, $00

        dc.b    5                               ; start x
        dc.b    0                               ; start y
        dc.b    0                               ; color
        dc.b    1                               ; pattern
pieceI:
        ; (1)
        dc.b    $02, $00                        ; x, y
        dc.b    $01, $01, $01, $01
        dc.b    $00, $00, $00, $00

        ; (2)
        dc.b    $00, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00

        ; (3)
        dc.b    $02, -$01                       ; x, y
        dc.b    $01, $01, $01, $01
        dc.b    $00, $00, $00, $00

        ; (4)
        dc.b    $01, $01                        ; x, y
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
        dc.b    $01, $00
