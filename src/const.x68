; --- tile ---------------------------------------------------------------------
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
TILE_SIZE: equ  16
TILE_SIZE_SM: equ 12                            ; 12.62 -> 12 o 13
TILE_SHIFT: equ 4
TILE_MULT: equ  1
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
TILE_SIZE: equ  32
TILE_SIZE_SM: equ 23                            ; 25,24 -> 25 o 26
TILE_SHIFT: equ 5
TILE_MULT: equ  2
        endc

; --- board --------------------------------------------------------------------
BRD_COLS: equ   10                              ; number of horizontal tiles
BRD_ROWS: equ   20                              ; number of vertical tiles
BRD_WIDTH: equ  10
BRD_HEIGHT: equ 20
BRD_SIZE: equ   BRD_WIDTH*BRD_HEIGHT
BRD_BASE_X: equ 16
BRD_BASE_Y: equ 6
BRD_NEXT_BASE_X: equ 28
BRD_NEXT_BASE_Y: equ 15
BRD_STAT_BASE_X: equ 9
BRD_STAT_BASE_Y: equ 16
BRD_STAT_SIZE: equ 3
BRD_LVL_BASE_X: equ 29
BRD_LVL_BASE_Y: equ 21
BRD_LVL_SIZE: equ 3
BRD_LINE_CNT_BASE_X: equ 23
BRD_LINE_CNT_BASE_Y: equ 3
BRD_LINE_CNT_SIZE: equ 3
BRD_SCO_BASE_X: equ 29
BRD_SCO_BASE_Y: equ 8
BRD_SCO_SIZE: equ 5
BRD_GO_PADDING: equ 2*TILE_MULT
BRD_TOP_SCO_BASE_X: equ 29
BRD_TOP_SCO_BASE_Y: equ 5

; --- button -------------------------------------------------------------------
BUTT_POS_X: equ 320
BUTT_POS_Y: equ 240
BUTT_WIDTH: equ SCR_WIDTH
BUTT_HEIGHT: equ SCR_HEIGHT
BUTT_PCOL: equ  $00ffffff
BUTT_FCOL: equ  $00000000

; --- button text --------------------------------------------------------------
MSG_FCOL: equ   $00000000                       ; text background color
MSG_LINE1: equ  $0101                           ; first line coordinates
MSG_LINE2: equ  $0102                           ; second line coordinates
MSG_LINE3: equ  $1702                           ; third line coordinates
MSG_FONT: equ   $00000000                       ; default font

; --- type and music selection -------------------------------------------------
TAM_LEFT_ARROW: equ 45
TAM_RIGHT_ARROW: equ 46
TAM_TYPE_POS_X equ 10
TAM_TYPE_POS_Y equ 8
TAM_MUSIC_POS_X equ 15
TAM_MUSIC_POS_Y equ 18

; --- level selection ----------------------------------------------------------
LVL_SEL_BASE_X: equ 183
LVL_SEL_BASE_Y: equ 183
LVL_SEL_COL: equ $003b99f5                      ; fill color of the selection square
LVL_SEL_SIDE: equ 29                            ; side length of the selection square
LVL_SEL_SIDEM: equ 32                           ; number of pixels square is moved to the side
LVL_SEL_BLACK_X: equ 46                         ; number of pixels black square is moved
LVL_SEL_FONT_COL: equ $00ffffff

; --- height selection ---------------------------------------------------------
HIGH_SEL_BASE_X: equ 407
HIGH_SEL_BASE_Y: equ 183

LVL_SEL_NAME_BASE_X: equ 13
LVL_SEL_NAME_BASE_Y: equ 20
LVL_SEL_SCORE_BASE_X: equ 20
LVL_SEL_SCORE_BASE_Y: equ 20
LVL_SEL_SCORE_LEN: equ 5
LVL_SEL_LEVEL_BASE_X: equ 26
LVL_SEL_LEVEL_BASE_Y: equ 20
LVL_SEL_LEVEL_LEN: equ 3

; --- user intro ---------------------------------------------------------------
USR_I_POS_X: equ 12
USR_I_POS_Y: equ 19
USR_MAX_SIZE: equ 6
