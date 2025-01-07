; --- sync ---------------------------------------------------------------------
SNC_PLOT: ds.b  1
SNC_CNT_DOWN: ds.l 1
SNC_PIECE_TIME: dc.l SNC_TIME_S*1

; --- keyboard -----------------------------------------------------------------
KBD_VAL: ds.b   1                               ; key state
KBD_EDGE: ds.b  1                               ; key edge

; --- mouse --------------------------------------------------------------------
MOUSE_VAL: ds.b 1                               ; mouse click state
MOUSE_EDGE: ds.b 1                              ; mouse edge state
MOUSE_POS_X: ds.w 1                             ; mouse x coordinate
MOUSE_POS_Y: ds.w 1                             ; mouse y coordinate

; --- network ------------------------------------------------------------------
NET_SERVER_PORT: dc.w 6969
NET_SERVER_HOST: dc.b 'tetris-m68k.westeurope.cloudapp.azure.com',0
; NET_SERVER_HOST: dc.b '127.0.0.1',0
; NET_SERVER_HOST: dc.b '172.16.39.1',0
        ds.w    0
NET_BUFFER: ds.b NET_BUFFER_LEN
        ds.w    0
