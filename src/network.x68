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
        move.w  (NET_SERVER_PORT), d1
        swap    d1
        move.w  #1, d1                          ; configure conn as TCP
        lea.l   NET_SERVER_HOST, a2
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

; send d1 bytes from NET_BUFFER to the connected host
;
; input    : d1.w - number of bytes to send
; output   :
; modifies :
netsend:
        movem.l d0-d2/a1-a2, -(a7)
        move.b  #106, d0
        andi.l  #$ffff, d1
        move.w  (NET_SERVER_PORT), d2
        lsl.l   #8, d2
        lsl.l   #8, d2
        or.l    d2, d1
        lea.l   NET_BUFFER, a1
        lea.l   NET_SERVER_HOST, a2
        trap    #15
        movem.l (a7)+, d0-d2/a1-a2
        rts

; send d1 bytes from NET_BUFFER to the connected host
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
        lea.l   NET_BUFFER, a1
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
        lea.l   NET_BUFFER, a0
        move.b  #$04, (a0)+
        move.b  d0, (a0)+
        move.w  d1, (a0)+
        move.w  #4, d1                          ; number of bytes to send
        jsr     netsend
        jsr     netrecv
        movem.l (a7)+, d0-d1/a0
        rts

; request score placement
;
; input    : d0.b - game type to retrieve
;                   0 -> any
;                   1 -> type A
;                   2 -> type B
;            d1.l - score
;            d2.l - max retry time in 10s of ms
; output   : d1.l - placement
; modifies :
netscoreplace:
        movem.l d0/a0, -(a7)
        ; build data frame
        lea.l   NET_BUFFER, a0
        move.b  #$06, (a0)+
        move.b  d0, (a0)+                       ; copy game type
        ; copy score
        move.b  d1, 3(a0)
        lsr.l   #8, d1
        move.b  d1, 2(a0)
        lsr.l   #8, d1
        move.b  d1, 1(a0)
        lsr.l   #8, d1
        move.b  d1, (a0)
        addq.l  #4, a0
        move.w  #6, d1                          ; number of bytes to send
        jsr     netsend
        jsr     netrecv
        lea.l   NET_BUFFER, a0
        add.l   #2, a0
        ; copy result
        move.l  (a0)+, d1
        movem.l (a7)+, d0/a0
        rts

; publish score
;
; input    : d0.b - game type
;                   0 -> any
;                   1 -> type A
;                   2 -> type B
;            d1.l - game score
;            d2.l - max retry time in 10s of ms
;            d3.w - game level
;            a1.l - player name address
; output   :
; modifies :
netscorepub:
        movem.l d0-d1/a0, -(a7)
        ; build data frame
        lea.l   NET_BUFFER, a0
        move.b  #$05, (a0)+                     ; score pub id
        move.b  #$02, (a0)+                     ; score id
        ; copy player name
        move.w  #5, d4
.player_cpy:
        move.b  (a1)+, (a0)+
        dbra.w  d4, .player_cpy
        move.b  d0, (a0)+                       ; copy game type
        ; copy score
        move.b  d1, 3(a0)
        lsr.l   #8, d1
        move.b  d1, 2(a0)
        lsr.l   #8, d1
        move.b  d1, 1(a0)
        lsr.l   #8, d1
        move.b  d1, (a0)
        addq.l  #4, a0
        ; copy game level
        move.b  d3, 1(a0)
        lsr.l   #8, d3
        move.b  d3, (a0)
        addq.l  #2, a0
        move.w  #15, d1                         ; number of bytes to send
        jsr     netsend
        jsr     netrecv
        movem.l (a7)+, d0-d1/a0
        rts




; --- tests --------------------------------------------------------------------
; score list decode
scorelistdec:
        movem.l d0-d2/a0-a1, -(a7)
        lea.l   NET_BUFFER, a0
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
