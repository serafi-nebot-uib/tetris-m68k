; --- screen -------------------------------------------------------------------
SCR_NUM: ds.b   1                               ; decimal number to select the screen
        ds.w    0

; --- mouse --------------------------------------------------------------------
BUTT_PRESS: ds.w 1                              ; 1 if screen button has been pressed

; --- keyboard -----------------------------------------------------------------
KBD_ENTER_PRESS: ds.w 1                         ; holds 1 if enter has been pressed

; --- type and music selection -------------------------------------------------
GAME_TYPE: ds.b 1
GAME_MUSIC: ds.b 1
        ds.w    0

; --- level selection ----------------------------------------------------------
LVL_SEL_POS_X: ds.w 1                           ; x pos of the selected level square
LVL_SEL_POS_Y: ds.w 1                           ; y pos of the selected level square

LVL_SEL_NUM_POS: ds.w 1                         ; selected number position
LVL_SEL_NUM: ds.w 1                             ; selected number
LVL_SEL_FNUM: ds.w 1                            ; selected final number
