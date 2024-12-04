NET_BUFFER_LEN: equ 1024
NET_SERVER_HOST: equ '127.0.0.1'
NET_SERVER_PORT: equ 6969

server_port: dc.w NET_SERVER_PORT
server_host: dc.b NET_SERVER_HOST,0
        ds.w    0

netbuff: ds.b   NET_BUFFER_LEN
        ds.w    0

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

; request scores ordered in descending order with a limit
;
; input    : sp+0 - max number of scores to retrieve
; output   : sp+0 - number of scores retrieved
; modifies :
netscorereq:
.base:  equ     4                               ; pc
        ; build data frame
        lea.l   netbuff, a0
        move.b  #$04, (a0)+
        move.w  .base(a7), (a0)+
        rts
