NET_BUFFER_LEN: equ 1024

server_port: dc.w 6969
server_host: dc.b 'tetris-m68k.westeurope.cloudapp.azure.com',0
        ds.w    0

netbuff: ds.b   NET_BUFFER_LEN
        ds.w    0

; establish TCP connection with (server_host) at (server_port)
;
; input    :
; output   :
; modifies :
netinit:
        movem.l d0-d1/a2, -(a7)
        ; TODO: retry logic
        ; network client init
        move.b  #100, d0
        move.w  (server_port), d1
        swap    d1
        move.w  #1, d1                          ; configure conn as TCP
        lea.l   server_host, a2
        trap    #15
        movem.l (a7)+, d0-d1/a2
        rts

; close connection
;
; input    :
; output   :
; modifies :
netclose:
        move.b  d0, -(a7)
        move.b  #104, d0
        trap    #15
        move.b  (a7)+, d0
        rts

; send d1 bytes from netbuff to the connected host
;
; input    : d1.w - number of bytes to send
; output   :
; modifies :
netsend:
        movem.l d0-d2/a1-a2, -(a7)
        move.b  #106, d0
        andi.l  #$ffff, d1
        move.w  (server_port), d2
        lsl.l   #8, d2
        lsl.l   #8, d2
        or.l    d2, d1
        lea.l   netbuff, a1
        lea.l   server_host, a2
        trap    #15
        movem.l (a7)+, d0-d2/a1-a2
        rts

; send d1 bytes from netbuff to the connected host
;
; input    : d2.l - max retry time in 10s of ms
; output   : d1.w - number of bytes received
; modifies :
netrecv:
        movem.l d0/a1, -(a7)
        move.l  d2, (SNC_CNT_DOWN)
.recv:
        move.b  #107, d0
        move.l  #NET_BUFFER_LEN, d1
        lea.l   netbuff, a1
        trap    #15
        ; retry on empty data
        tst.w   d1                              ; d1 -> number of bytes received
        bne     .done
        tst.l   (SNC_CNT_DOWN)
        bgt     .recv
.done:
        movem.l (a7)+, d0/a1
        rts

; request scores ordered in descending order with a limit
;
; input    : d0.b - game type to retrieve
;                   0 -> any
;                   1 -> type A
;                   2 -> type B
;            d1.w - number of scores to retrieve
;            d2.l - max retry time in 10s of ms
; output   :
; modifies :
netscorereq:
        movem.l d0-d1/a0, -(a7)
        ; build data frame
        lea.l   netbuff, a0
        move.b  #$04, (a0)+
        move.b  d0, (a0)+
        move.w  d1, (a0)+
        move.w  #4, d1                          ; number of bytes to send
        jsr     netsend
        jsr     netrecv
        movem.l (a7)+, d0-d1/a0
        rts




; --- tests --------------------------------------------------------------------
; score list decode
scorelistdec:
        movem.l d0-d2/a0-a1, -(a7)
        lea.l   netbuff, a0
        lea.l   .player, a1
        ; check score list id
        cmp.b   #$03, (a0)+
        bne     .done

        ; number of scores
        move.b  (a0)+, d0
        lsl.w   #8, d0
        move.b  (a0)+, d0

        subq.w  #1, d0
.score_loop:
        ; check score id
        cmp.b   #$02, (a0)+
        bne     .done
        moveq.l #0, d2                          ; player character tmp var
        move.w  #0, d1
.player_cpy:
        move.b  (a0)+, d2
        move.b  d2, (a1,d1.w)
        addq.w  #1, d1
        cmp.w   #6, d1
        blo     .player_cpy

        ; skip game type
        addq.l  #1, a0
        ; player score
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1
        lsl.l   #8, d1
        move.b  (a0)+, d1

        dbra.w  d0, .score_loop
.done:
        movem.l (a7)+, d0-d2/a0-a1
        rts
.player: dc.b   0,0,0,0,0,0
        ds.w    0
