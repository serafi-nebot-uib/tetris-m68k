; --- sync ---------------------------------------------------------------------
SNC_PLOT: ds.b  1
SNC_CNT_DOWN: ds.l 1
SNC_PIECE_TIME: dc.l SNC_TIME_S*1

; --- keyboard -----------------------------------------------------------------
KBD_VAL: ds.b   1                               ; key state
KBD_EDGE: ds.b  1                               ; key edge

; --- mouse --------------------------------------------------------------------
MOUSE_VAL: ds.b 1                               ; mouse click state
MOUSE_POS_X: ds.w 1                             ; mouse x coordinate
MOUSE_POS_Y: ds.w 1                             ; mouse y coordinate

        ds.w    0
