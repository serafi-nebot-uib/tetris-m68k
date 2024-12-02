; --- global -------------------------------------------------------------------
GLB_SCALE_SMALL: equ 0
GLB_SCALE_BIG: equ 1
GLB_SCALE: equ  GLB_SCALE_SMALL

; --- sync ---------------------------------------------------------------------
SNC_EXC: equ    1
SNC_PIECE_TIME: equ 10

; --- screen -------------------------------------------------------------------
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
SCR_WIDTH: equ  640                             ; screen width in pixels
SCR_HEIGHT: equ 480                             ; screen height in pixels
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
SCR_WIDTH: equ  1280                            ; screen width in pixels
SCR_HEIGHT: equ 1024                            ; screen height in pixels
        endc
SCR_TRAP: equ   0

; --- keyboard -----------------------------------------------------------------
KBD_TRAP: equ   1
KBD_LEFT: equ   $25
KBD_UP: equ     $26
KBD_RIGHT: equ  $27
KBD_DOWN: equ   $28
KBD_ESC: equ    $1b
KBD_CTRL equ    $11
KBD_SPBAR: equ  $20
KBD_SHIFT: equ  $10
