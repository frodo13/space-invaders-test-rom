;-------------------------------
; Space Invaders Test ROM
;
; version 1.3 by Marc Deslauriers
; 03/27/2019
; version 1.2 by Frederic Rodo
; 10/12/2017
; version 1.1 by Fabrice GIRARDOT
; 09/16/2017
; version 1.0 by Frederic Rodo
; 10/12/2013
; preversion by Timothy Shiels
; 08/2008
; www.outerworldarcade.com
;-------------------------------

            .area    CRC32 (REL)
            .globl print, drawchar, curs_x, curs_y, printword

; crc32:
;
; crc = 0xffffffff
; for (;size > 0; size--) {
;     crc = crc ^ *data++
;     for (i = 8; i > 0; i--) {
;         if (crc & 1)
;             crc = (crc >> 1) ^ 0xEDB88320
;         else
;             crc = crc >> 1;
;     }
; }
; crc = crc ^ 0xffffffff;
;
; HL => address of the parameters's list
;       data addrL (+0), AddrH (+1)
;       data SizeL (+2), SizeH (+3)
;       crc  dataL (+4), dataML(+5)
;       crc  dataMH(+6), dataH (+7)
crc32:
            push     PSW; save context
            push     B               
            push     D
            push     H

            ; load and push rom's address
            mov      A,M
            mov      E,A
            inx      H
            mov      A,M
            mov      D,A
            inx H
            
            ; load and push rom's size
            mov A,M
            mov C,A
            inx H
            mov A,M
            mov B,A
            inx H
            push H; save CRC address
            push B; store size
            
            xchg; put rom's address in H
            
            ; set crc to 0xffffffff
            mvi B,0xFF
            mvi C,0xFF
            mvi D,0xFF
            mvi E,0xFF
            
bytelp:     mov A,M; read rom's data
            inx H
            push H
            
            mvi H,8; rotate 8 times, i = 8
            xra E; CRC = CRC ^ data
            mov E,A

bitlp:      mov A,B
            rar
            mov B,A
            
            mov A,C
            rar
            mov C,A
            
            mov A,D
            rar
            mov D,A
            
            mov A,E
            rar
            mov E,A
            
            jnc ebitlp
            
            mov A,B
            xri 0xED
            mov B,A
            
            mov A,C
            xri 0xB8
            mov C,A
            
            mov A,D
            xri 0x83
            mov D,A
            
            mov A,E
            xri 0x20
            mov E,A

ebitlp:     dcr H; if (--i > 0)
            jnz bitlp; goto bitlp
            
            pop H
            xthl
            dcx H
            mov A,H; if (--size > 0)
            ora L
            xthl
            jnz bytelp; goto bytelp
            
            pop H; restore dummy
            pop H; restore CRC address
            
            ; CRC = CRC ^ 0FFFFFFFFh
            mov A,B;
            xri 0xFF;
            mov M,A;
            inx H;
            
            mov A,C;
            xri 0xFF;
            mov M,A;
            inx H;
            
            mov A,D;
            xri 0xFF;
            mov M,A;
            inx H;
            
            mov A,E;
            xri 0xFF;
            mov M,A;
            
            pop H; restore context
            pop D
            pop B
            pop PSW
            
            ret

test_roms::
            lxi	 H,0x1800
            shld crc_ctx
            lxi H,0x0800
            shld crc_ctx+2
            lxi H,crc_ctx
            call crc32

            lxi d,txtCrc
            lxi h,curs_x     ; print "CRC ROM * = "
            mvi m,4
            lxi h,curs_y
            mvi m,5
            call print
            lxi H,crc_ctx +4
            call printword
            mvi a,0x0E
            lxi h,curs_x
            mvi m,12
            call drawchar

            out 0x06

            lxi	 H,0x1000
            shld crc_ctx
            lxi H,crc_ctx
            call crc32

            lxi d,txtCrc
            lxi h,curs_x     ; print "CRC ROM * = "
            mvi m,4
            lxi h,curs_y
            mvi m,6
            call print
            lxi H,crc_ctx +4
            call printword
            mvi a,0x0F
            lxi h,curs_x
            mvi m,12
            call drawchar

            out 0x06

            lxi	 H,0x800
            shld crc_ctx
            lxi H,crc_ctx
            call crc32

            lxi d,txtCrc
            lxi h,curs_x     ; print "CRC ROM * = "
            mvi m,4
            lxi h,curs_y
            mvi m,7
            call print
            lxi H,crc_ctx +4
            call printword
            mvi a,0x10
            lxi h,curs_x
            mvi m,12
            call drawchar

            out 0x06

            lxi	 H,00
            shld crc_ctx
            lxi H,crc_ctx
            call crc32

            lxi d,txtCrc
            lxi h,curs_x     ; print "CRC ROM * = "
            mvi m,4
            lxi h,curs_y
            mvi m,8
            call print
            lxi H,crc_ctx +4
            call printword
            mvi a,0x11
            lxi h,curs_x
            mvi m,12
            call drawchar

            out 0x06

            ret

txtCrc:
.byte 0x0C, 0x1B, 0x0C, 0x26, 0x1B, 0x18, 0x16, 0x26, 0x28, 0x26, 0x27, 0x26, 0xFF

            .area _DATA (DSEG)
crc_ctx: .ds 8
