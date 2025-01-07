; --- global -------------------------------------------------------------------
GLB_SCALE_SMALL: equ 0
GLB_SCALE_BIG: equ 1
GLB_SCALE: equ  GLB_SCALE_SMALL
GLB_VER_ORIGINAL: equ 0
GLB_VER_HIGHRES: equ 1
GLB_VER: equ GLB_VER_ORIGINAL

; --- sync ---------------------------------------------------------------------
; configured to 7 to avoid Easy68K blocking the interrupt
SNC_EXC: equ    7
SNC_TIME: equ   10                              ; 10 milliseconds -> 100 times/second
SNC_TIME_S: equ 1000/SNC_TIME

; --- network ---------------------------------------------------------------------
NET_BUFFER_LEN: equ 1024

; --- screen -------------------------------------------------------------------
        ifeq    GLB_SCALE-GLB_SCALE_SMALL
SCR_MULT: equ   1
        endc
        ifeq    GLB_SCALE-GLB_SCALE_BIG
SCR_MULT: equ   2
        endc
SCR_WIDTH: equ  640*SCR_MULT                    ; screen width in pixels
SCR_HEIGHT: equ 480*SCR_MULT                    ; screen height in pixels
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

; --- sound --------------------------------------------------------------------
SND_MUSIC1: equ 0
SND_MUSIC2: equ 1
SND_MUSIC3: equ 2
SND_BTYPESUC: equ 3
SND_ENDMUSIC: equ 4
SND_HIGHSCORE: equ 5
SND_MUSIC1FST: equ 6
SND_MUSIC2FST: equ 7
SND_MUSIC3FST: equ 8
SND_MENUSLCT: equ 9
SND_MENUSLCTD: equ 10
SND_SHFTPIECE: equ 11
SND_ROTPIECE: equ 12
SND_LEVELUP: equ 13
SND_PIECELOCK: equ 14
SND_TETRISACH: equ 15
SND_LINECOMPL: equ 16
SND_DEATH: equ  17
SND_ENDRCKT: equ 18

SND_DIRECTX equ 1                               ; use of directx player [0 (std. player) / 1 (directx)]
SND_LOADERTSK equ 3*SND_DIRECTX+71              ; holds task number of the selected play method
SND_PLAYERTSK equ 76+SND_DIRECTX                ; holds task number of the selected player

SND_LOOP: equ   1
SND_STOP: equ   2
SND_STOP_ALL: equ 3
