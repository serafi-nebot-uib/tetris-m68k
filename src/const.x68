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
