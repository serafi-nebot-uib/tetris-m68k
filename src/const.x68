; --- tile ---------------------------------------------------------------------
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
TILE_SIZE: equ  16
TILE_SHIFT: equ 4
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
TILE_SIZE: equ  32
TILE_SHIFT: equ 5
        endc

; --- board --------------------------------------------------------------------
BRD_COLS: equ   10                              ; number of horizontal tiles
BRD_ROWS: equ   20                              ; number of vertical tiles
BRD_WIDTH: equ  10
BRD_HEIGHT: equ 20
BRD_SIZE: equ   BRD_WIDTH*BRD_HEIGHT
BRD_BASE_X: equ 17
BRD_BASE_Y: equ 6
BRD_NEXT_BASE_X: equ 30
BRD_NEXT_BASE_Y: equ 15
BRD_STAT_BASE_X: equ 6
BRD_STAT_BASE_Y: equ 8
BRD_LVL_BASE_X: equ 31
BRD_LVL_BASE_Y: equ 21
BRD_LINE_CNT_BASE_X: equ 24
BRD_LINE_CNT_BASE_Y: equ 3
BRD_SCO_BASE_X: equ 29
BRD_SCO_BASE_Y: equ 8

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

; --- level selection ----------------------------------------------------------
LVL_SEL_BASE_X: equ 183
LVL_SEL_BASE_Y: equ 183
LVL_SEL_COL: equ $003b99f5                      ; fill color of the selection square
LVL_SEL_SIDE: equ 29                            ; side length of the selection square
LVL_SEL_SIDEM: equ 32                           ; number of pixels square is moved to the side
LVL_SEL_BLACK_X: equ 46                         ; number of pixels black square is moved

LVL_SEL_NUM_FCOL: equ $000000ff                 ; number font color
LVL_SEL_NUM_POS1: equ $0a06                     ; numbers initial pos 0 to 4
LVL_SEL_NUM_POS2: equ $0a07                     ; numbers initial pos 5 to 9

LVL_SEL_FONT_SIZE: equ $01090000
LVL_SEL_FONT_COL: equ $00ffffff

LVL_SEL_P: equ  $0000
LVL_SEL_FP: equ $0001

; --- user intro ---------------------------------------------------------------
USR_I_POS_X: equ 12
USR_I_POS_Y: equ 19
USR_MAX_SIZE: equ 6
