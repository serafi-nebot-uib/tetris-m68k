; --- global -------------------------------------------------------------------
GLB_SCALE_SMALL: equ 0
GLB_SCALE_BIG: equ 1
GLB_SCALE: equ  GLB_SCALE_SMALL

; --- sync ---------------------------------------------------------------------
; configured to 7 to avoid Easy68K blocking the interrupt
SNC_EXC: equ    7
SNC_TIME: equ   10                              ; 10 milliseconds -> 100 times/second
SNC_TIME_TO_S: equ 1000/SNC_TIME
SNC_PIECE_TIME: equ SNC_TIME_TO_S*1

; --- screen -------------------------------------------------------------------
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
SCR_WIDTH: equ  640                             ; screen width in pixels
SCR_HEIGHT: equ 480                             ; screen height in pixels
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
SCR_WIDTH: equ  1280                            ; screen width in pixels
SCR_HEIGHT: equ 960                             ; screen height in pixels
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
KBD_ENTER: equ  $0d

KBD_LEFT_POS: equ 0
KBD_UP_POS: equ 1
KBD_RIGHT_POS: equ 2
KBD_DOWN_POS: equ 3
KBD_SPBAR_POS: equ 4
KBD_ESC_POS: equ 5
KBD_CTRL_POS: equ 6
KBD_ENTER_POS: equ 7

; --- mouse --------------------------------------------------------------------
MOUSE_TRAP: equ 2
