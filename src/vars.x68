; --- screen -------------------------------------------------------------------
SCR_NUM: ds.b   1                               ; decimal number to select the screen
        ds.w    0

; --- game ---------------------------------------------------------------------
GME_TYPE: ds.b  1
GME_MUSIC: ds.b 1
GME_B_HEIGHT_TABLE: dc.b 0, 3, 5, 8, 10, 12     ; board height list
; TODO: dynamically initialize GME_B_HEIGHT
GME_B_HEIGHT: dc.b 5                            ; selected height
        ds.w    0
GME_STATE: ds.l 1
GME_HIGH_SCORE: ds.l 1

; --- mouse --------------------------------------------------------------------
BUTT_PRESS: ds.b 1                              ; 1 if screen button has been pressed

; --- keyboard -----------------------------------------------------------------
KBD_ENTER_PRESS: ds.w 1                         ; holds 1 if enter has been pressed

; --- level selection ----------------------------------------------------------
LVL_SEL_POS_X: ds.w 1                           ; x pos of the selected level square
LVL_SEL_POS_Y: ds.w 1                           ; y pos of the selected level square
LVL_SEL_NUM: ds.w 1                             ; selected number for level
LVL_SEL_NUM_POS: ds.w 1                         ; selected number position
LVL_SEL_FNUM: ds.w 1                            ; selected final number

; -- score screen --------------------------------------------------------------
SCO_NAME: ds.b  7
SCO_SCORE: ds.b LVL_SEL_SCORE_LEN+1
        ds.w    0

; --- height selection ---------------------------------------------------------
HIGH_SEL_POS_X: ds.w 1                          ; x pos of the selected level square
HIGH_SEL_POS_Y: ds.w 1                          ; y pos of the selected level square
HIGH_SEL_NUM: ds.w 1                            ; selected number for height
HIGH_SEL_FNUM: ds.w 1                           ; selected final number for height

; --- user intro ---------------------------------------------------------------
USR_HIGHSCORE_POS: ds.w 1
LETPOSX: ds.w   1                               ; POSITION OF THE CURRENT LETTER SELECTION
LETPOSY: ds.w   1
USR:    ds.w    6
USRLTRPOS: ds.l 1
CONGRATULATIONS: dc.b 'CONGRATULATIONS ',0
        ds.w    0
