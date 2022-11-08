  // File Comments
  // Upstart
.cpu _65c02
  // Commander X16 PRG executable file
.file [name="issue-802-return.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(__start)
  // Global Constants & labels
  .const WHITE = 1
  .const BLUE = 6
  ///< Load a logical file.
  .const CBM_PLOT = $fff0
  .const VERA_INC_1 = $10
  .const VERA_ADDRSEL = 1
  .const VERA_LAYER_WIDTH_MASK = $30
  .const VERA_LAYER_HEIGHT_MASK = $c0
  .const STACK_BASE = $103
  .const isr_vsync = $314
  .const SIZEOF_STRUCT___0 = $8d
  /// $9F20 VRAM Address (7:0)
  .label VERA_ADDRX_L = $9f20
  /// $9F21 VRAM Address (15:8)
  .label VERA_ADDRX_M = $9f21
  /// $9F22 VRAM Address (7:0)
  /// Bit 4-7: Address Increment  The following is the amount incremented per value value:increment
  ///                             0:0, 1:1, 2:2, 3:4, 4:8, 5:16, 6:32, 7:64, 8:128, 9:256, 10:512, 11:40, 12:80, 13:160, 14:320, 15:640
  /// Bit 3: DECR Setting the DECR bit, will decrement instead of increment by the value set by the 'Address Increment' field.
  /// Bit 0: VRAM Address (16)
  .label VERA_ADDRX_H = $9f22
  /// $9F23	DATA0	VRAM Data port 0
  .label VERA_DATA0 = $9f23
  /// $9F24	DATA1	VRAM Data port 1
  .label VERA_DATA1 = $9f24
  /// $9F25	CTRL Control
  /// Bit 7: Reset
  /// Bit 1: DCSEL
  /// Bit 2: ADDRSEL
  .label VERA_CTRL = $9f25
  /// $9F2A	DC_HSCALE (DCSEL=0)	Active Display H-Scale
  .label VERA_DC_HSCALE = $9f2a
  /// $9F2B	DC_VSCALE (DCSEL=0)	Active Display V-Scale
  .label VERA_DC_VSCALE = $9f2b
  /// $9F34	L1_CONFIG   Layer 1 Configuration
  .label VERA_L1_CONFIG = $9f34
  /// $9F35	L1_MAPBASE	    Layer 1 Map Base Address (16:9)
  .label VERA_L1_MAPBASE = $9f35
  .label BRAM = 0
  .label BROM = 1
  .label count = $35
.segment Code
  // __start
__start: {
    // __start::__init1
    // __export volatile __address(0x00) unsigned char BRAM = 0
    // [1] BRAM = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z BRAM
    // __export volatile __address(0x01) unsigned char BROM = 4
    // [2] BROM = 4 -- vbuz1=vbuc1 
    lda #4
    sta.z BROM
    // volatile unsigned char count = 0
    // [3] count = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z count
    // [4] phi from __start::__init1 to __start::@2 [phi:__start::__init1->__start::@2]
    // __start::@2
    // #pragma constructor_for(conio_x16_init, cputc, clrscr, cscroll)
    // [5] call conio_x16_init
    // [9] phi from __start::@2 to conio_x16_init [phi:__start::@2->conio_x16_init]
    jsr conio_x16_init
    // [6] phi from __start::@2 to __start::@1 [phi:__start::@2->__start::@1]
    // __start::@1
    // [7] call main
    // [61] phi from __start::@1 to main [phi:__start::@1->main]
    jsr main
    // __start::@return
    // [8] return 
    rts
}
  // conio_x16_init
/// Set initial screen values.
conio_x16_init: {
    // screenlayer1()
    // [10] call screenlayer1
    jsr screenlayer1
    // [11] phi from conio_x16_init to conio_x16_init::@1 [phi:conio_x16_init->conio_x16_init::@1]
    // conio_x16_init::@1
    // textcolor(CONIO_TEXTCOLOR_DEFAULT)
    // [12] call textcolor
    jsr textcolor
    // [13] phi from conio_x16_init::@1 to conio_x16_init::@2 [phi:conio_x16_init::@1->conio_x16_init::@2]
    // conio_x16_init::@2
    // bgcolor(CONIO_BACKCOLOR_DEFAULT)
    // [14] call bgcolor
    jsr bgcolor
    // [15] phi from conio_x16_init::@2 to conio_x16_init::@3 [phi:conio_x16_init::@2->conio_x16_init::@3]
    // conio_x16_init::@3
    // cursor(0)
    // [16] call cursor
    jsr cursor
    // [17] phi from conio_x16_init::@3 to conio_x16_init::@4 [phi:conio_x16_init::@3->conio_x16_init::@4]
    // conio_x16_init::@4
    // cbm_k_plot_get()
    // [18] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [19] cbm_k_plot_get::return#2 = cbm_k_plot_get::return#0
    // conio_x16_init::@5
    // [20] conio_x16_init::$4 = cbm_k_plot_get::return#2 -- vwum1=vwuz2 
    lda.z cbm_k_plot_get.return
    sta __4
    lda.z cbm_k_plot_get.return+1
    sta __4+1
    // BYTE1(cbm_k_plot_get())
    // [21] conio_x16_init::$5 = byte1  conio_x16_init::$4 -- vbum1=_byte1_vwum2 
    sta __5
    // __conio.cursor_x = BYTE1(cbm_k_plot_get())
    // [22] *((char *)&__conio+$d) = conio_x16_init::$5 -- _deref_pbuc1=vbum1 
    sta __conio+$d
    // cbm_k_plot_get()
    // [23] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [24] cbm_k_plot_get::return#3 = cbm_k_plot_get::return#0
    // conio_x16_init::@6
    // [25] conio_x16_init::$6 = cbm_k_plot_get::return#3 -- vwum1=vwuz2 
    lda.z cbm_k_plot_get.return
    sta __6
    lda.z cbm_k_plot_get.return+1
    sta __6+1
    // BYTE0(cbm_k_plot_get())
    // [26] conio_x16_init::$7 = byte0  conio_x16_init::$6 -- vbum1=_byte0_vwum2 
    lda __6
    sta __7
    // __conio.cursor_y = BYTE0(cbm_k_plot_get())
    // [27] *((char *)&__conio+$e) = conio_x16_init::$7 -- _deref_pbuc1=vbum1 
    sta __conio+$e
    // gotoxy(__conio.cursor_x, __conio.cursor_y)
    // [28] gotoxy::x#0 = *((char *)&__conio+$d) -- vbuz1=_deref_pbuc1 
    lda __conio+$d
    sta.z gotoxy.x
    // [29] gotoxy::y#0 = *((char *)&__conio+$e) -- vbuz1=_deref_pbuc1 
    lda __conio+$e
    sta.z gotoxy.y
    // [30] call gotoxy
    // [93] phi from conio_x16_init::@6 to gotoxy [phi:conio_x16_init::@6->gotoxy]
    // [93] phi gotoxy::y#10 = gotoxy::y#0 [phi:conio_x16_init::@6->gotoxy#0] -- register_copy 
    // [93] phi gotoxy::x#4 = gotoxy::x#0 [phi:conio_x16_init::@6->gotoxy#1] -- register_copy 
    jsr gotoxy
    // conio_x16_init::@7
    // __conio.scroll[0] = 1
    // [31] *((char *)&__conio+$f) = 1 -- _deref_pbuc1=vbuc2 
    lda #1
    sta __conio+$f
    // __conio.scroll[1] = 1
    // [32] *((char *)&__conio+$f+1) = 1 -- _deref_pbuc1=vbuc2 
    sta __conio+$f+1
    // conio_x16_init::@return
    // }
    // [33] return 
    rts
  .segment Data
    __4: .word 0
    __5: .byte 0
    __6: .word 0
    __7: .byte 0
}
.segment Code
  // cputc
// Output one character at the current cursor position
// Moves the cursor forward. Scrolls the entire screen if needed
// void cputc(__zp($22) char c)
cputc: {
    .const OFFSET_STACK_C = 0
    .label c = $22
    // [34] cputc::c#0 = stackidx(char,cputc::OFFSET_STACK_C) -- vbuz1=_stackidxbyte_vbuc1 
    tsx
    lda STACK_BASE+OFFSET_STACK_C,x
    sta.z c
    // if(c=='\n')
    // [35] if(cputc::c#0==' ') goto cputc::@1 -- vbuz1_eq_vbuc1_then_la1 
    lda #'\n'
    cmp.z c
    beq __b1
    // cputc::@2
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [36] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(__conio.offset)
    // [37] cputc::$1 = byte0  *((unsigned int *)&__conio+$13) -- vbum1=_byte0__deref_pwuc1 
    lda __conio+$13
    sta __1
    // *VERA_ADDRX_L = BYTE0(__conio.offset)
    // [38] *VERA_ADDRX_L = cputc::$1 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_L
    // BYTE1(__conio.offset)
    // [39] cputc::$2 = byte1  *((unsigned int *)&__conio+$13) -- vbum1=_byte1__deref_pwuc1 
    lda __conio+$13+1
    sta __2
    // *VERA_ADDRX_M = BYTE1(__conio.offset)
    // [40] *VERA_ADDRX_M = cputc::$2 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_M
    // __conio.mapbase_bank | VERA_INC_1
    // [41] cputc::$3 = *((char *)&__conio+3) | VERA_INC_1 -- vbum1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+3
    sta __3
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [42] *VERA_ADDRX_H = cputc::$3 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_H
    // *VERA_DATA0 = c
    // [43] *VERA_DATA0 = cputc::c#0 -- _deref_pbuc1=vbuz1 
    lda.z c
    sta VERA_DATA0
    // *VERA_DATA0 = __conio.color
    // [44] *VERA_DATA0 = *((char *)&__conio+$b) -- _deref_pbuc1=_deref_pbuc2 
    lda __conio+$b
    sta VERA_DATA0
    // if(!__conio.hscroll[__conio.layer])
    // [45] if(0==((char *)&__conio+$11)[*((char *)&__conio)]) goto cputc::@5 -- 0_eq_pbuc1_derefidx_(_deref_pbuc2)_then_la1 
    ldy __conio
    lda __conio+$11,y
    cmp #0
    beq __b5
    // cputc::@3
    // if(__conio.cursor_x >= __conio.mapwidth)
    // [46] if(*((char *)&__conio+$d)>=*((char *)&__conio+6)) goto cputc::@6 -- _deref_pbuc1_ge__deref_pbuc2_then_la1 
    lda __conio+$d
    cmp __conio+6
    bcs __b6
    // cputc::@4
    // __conio.cursor_x++;
    // [47] *((char *)&__conio+$d) = ++ *((char *)&__conio+$d) -- _deref_pbuc1=_inc__deref_pbuc1 
    inc __conio+$d
    // cputc::@7
  __b7:
    // __conio.offset++;
    // [48] *((unsigned int *)&__conio+$13) = ++ *((unsigned int *)&__conio+$13) -- _deref_pwuc1=_inc__deref_pwuc1 
    inc __conio+$13
    bne !+
    inc __conio+$13+1
  !:
    // [49] *((unsigned int *)&__conio+$13) = ++ *((unsigned int *)&__conio+$13) -- _deref_pwuc1=_inc__deref_pwuc1 
    inc __conio+$13
    bne !+
    inc __conio+$13+1
  !:
    // cputc::@return
    // }
    // [50] return 
    rts
    // [51] phi from cputc::@3 to cputc::@6 [phi:cputc::@3->cputc::@6]
    // cputc::@6
  __b6:
    // cputln()
    // [52] call cputln
    jsr cputln
    jmp __b7
    // cputc::@5
  __b5:
    // if(__conio.cursor_x >= __conio.width)
    // [53] if(*((char *)&__conio+$d)>=*((char *)&__conio+4)) goto cputc::@8 -- _deref_pbuc1_ge__deref_pbuc2_then_la1 
    lda __conio+$d
    cmp __conio+4
    bcs __b8
    // cputc::@9
    // __conio.cursor_x++;
    // [54] *((char *)&__conio+$d) = ++ *((char *)&__conio+$d) -- _deref_pbuc1=_inc__deref_pbuc1 
    inc __conio+$d
    // __conio.offset++;
    // [55] *((unsigned int *)&__conio+$13) = ++ *((unsigned int *)&__conio+$13) -- _deref_pwuc1=_inc__deref_pwuc1 
    inc __conio+$13
    bne !+
    inc __conio+$13+1
  !:
    // [56] *((unsigned int *)&__conio+$13) = ++ *((unsigned int *)&__conio+$13) -- _deref_pwuc1=_inc__deref_pwuc1 
    inc __conio+$13
    bne !+
    inc __conio+$13+1
  !:
    rts
    // [57] phi from cputc::@5 to cputc::@8 [phi:cputc::@5->cputc::@8]
    // cputc::@8
  __b8:
    // cputln()
    // [58] call cputln
    jsr cputln
    rts
    // [59] phi from cputc to cputc::@1 [phi:cputc->cputc::@1]
    // cputc::@1
  __b1:
    // cputln()
    // [60] call cputln
    jsr cputln
    rts
  .segment Data
    __1: .byte 0
    __2: .byte 0
    __3: .byte 0
}
.segment Code
  // main
main: {
    // clrscr()
    // [62] call clrscr
    jsr clrscr
    // [63] phi from main to main::@5 [phi:main->main::@5]
    // main::@5
    // gotoxy(0,1)
    // [64] call gotoxy
    // [93] phi from main::@5 to gotoxy [phi:main::@5->gotoxy]
    // [93] phi gotoxy::y#10 = 1 [phi:main::@5->gotoxy#0] -- vbuz1=vbuc1 
    lda #1
    sta.z gotoxy.y
    // [93] phi gotoxy::x#4 = 0 [phi:main::@5->gotoxy#1] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    jsr gotoxy
    // [65] phi from main::@5 to main::@1 [phi:main::@5->main::@1]
    // [65] phi main::i#2 = 0 [phi:main::@5->main::@1#0] -- vbum1=vbuc1 
    lda #0
    sta i
    // main::@1
  __b1:
    // for(char i=0;i<20;i++)
    // [66] if(main::i#2<$14) goto main::@2 -- vbum1_lt_vbuc1_then_la1 
    lda i
    cmp #$14
    bcc __b2
    // [67] phi from main::@1 to main::is_max1 [phi:main::@1->main::is_max1]
    // main::is_max1
    // main::@4
    // if(is_maximum)
    // [68] if(count>=$10) goto main::@3 -- vbuz1_ge_vbuc1_then_la1 
    lda.z count
    cmp #$10
    bcs __b3
    rts
    // [69] phi from main::@4 to main::@3 [phi:main::@4->main::@3]
    // main::@3
  __b3:
    // printf("max\n")
    // [70] call printf_str
    // [137] phi from main::@3 to printf_str [phi:main::@3->printf_str]
    jsr printf_str
    // main::@return
    // }
    // [71] return 
    rts
    // main::@2
  __b2:
    // count+=i
    // [72] count = count + main::i#2 -- vbuz1=vbuz1_plus_vbum2 
    lda i
    clc
    adc.z count
    sta.z count
    // for(char i=0;i<20;i++)
    // [73] main::i#1 = ++ main::i#2 -- vbum1=_inc_vbum1 
    inc i
    // [65] phi from main::@2 to main::@1 [phi:main::@2->main::@1]
    // [65] phi main::i#2 = main::i#1 [phi:main::@2->main::@1#0] -- register_copy 
    jmp __b1
  .segment Data
    s: .text @"max\n"
    .byte 0
    i: .byte 0
}
.segment Code
  // screenlayer1
// Set the layer with which the conio will interact.
screenlayer1: {
    // screenlayer(1, *VERA_L1_MAPBASE, *VERA_L1_CONFIG)
    // [74] screenlayer::mapbase#0 = *VERA_L1_MAPBASE -- vbuz1=_deref_pbuc1 
    lda VERA_L1_MAPBASE
    sta.z screenlayer.mapbase
    // [75] screenlayer::config#0 = *VERA_L1_CONFIG -- vbuz1=_deref_pbuc1 
    lda VERA_L1_CONFIG
    sta.z screenlayer.config
    // [76] call screenlayer
    jsr screenlayer
    // screenlayer1::@return
    // }
    // [77] return 
    rts
}
  // textcolor
// Set the front color for text output. The old front text color setting is returned.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char textcolor(char color)
textcolor: {
    // __conio.color & 0xF0
    // [78] textcolor::$0 = *((char *)&__conio+$b) & $f0 -- vbum1=_deref_pbuc1_band_vbuc2 
    lda #$f0
    and __conio+$b
    sta __0
    // __conio.color & 0xF0 | color
    // [79] textcolor::$1 = textcolor::$0 | WHITE -- vbum1=vbum1_bor_vbuc1 
    lda #WHITE
    ora __1
    sta __1
    // __conio.color = __conio.color & 0xF0 | color
    // [80] *((char *)&__conio+$b) = textcolor::$1 -- _deref_pbuc1=vbum1 
    sta __conio+$b
    // textcolor::@return
    // }
    // [81] return 
    rts
  .segment Data
    __0: .byte 0
    .label __1 = __0
}
.segment Code
  // bgcolor
// Set the back color for text output.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char bgcolor(char color)
bgcolor: {
    // __conio.color & 0x0F
    // [82] bgcolor::$0 = *((char *)&__conio+$b) & $f -- vbum1=_deref_pbuc1_band_vbuc2 
    lda #$f
    and __conio+$b
    sta __0
    // __conio.color & 0x0F | color << 4
    // [83] bgcolor::$2 = bgcolor::$0 | BLUE<<4 -- vbum1=vbum1_bor_vbuc1 
    lda #BLUE<<4
    ora __2
    sta __2
    // __conio.color = __conio.color & 0x0F | color << 4
    // [84] *((char *)&__conio+$b) = bgcolor::$2 -- _deref_pbuc1=vbum1 
    sta __conio+$b
    // bgcolor::@return
    // }
    // [85] return 
    rts
  .segment Data
    __0: .byte 0
    .label __2 = __0
}
.segment Code
  // cursor
// If onoff is 1, a cursor is displayed when waiting for keyboard input.
// If onoff is 0, the cursor is hidden when waiting for keyboard input.
// The function returns the old cursor setting.
// char cursor(char onoff)
cursor: {
    .const onoff = 0
    // __conio.cursor = onoff
    // [86] *((char *)&__conio+$a) = cursor::onoff#0 -- _deref_pbuc1=vbuc2 
    lda #onoff
    sta __conio+$a
    // cursor::@return
    // }
    // [87] return 
    rts
}
  // cbm_k_plot_get
/**
 * @brief Get current x and y cursor position.
 * @return An unsigned int where the hi byte is the x coordinate and the low byte is the y coordinate of the screen position.
 */
cbm_k_plot_get: {
    .label x = $34
    .label y = $33
    .label return = $2e
    // unsigned char x
    // [88] cbm_k_plot_get::x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z x
    // unsigned char y
    // [89] cbm_k_plot_get::y = 0 -- vbuz1=vbuc1 
    sta.z y
    // kickasm
    // kickasm( uses cbm_k_plot_get::x uses cbm_k_plot_get::y uses CBM_PLOT) {{ sec         jsr CBM_PLOT         stx y         sty x      }}
    sec
        jsr CBM_PLOT
        stx y
        sty x
    
    // MAKEWORD(x,y)
    // [91] cbm_k_plot_get::return#0 = cbm_k_plot_get::x w= cbm_k_plot_get::y -- vwuz1=vbuz2_word_vbuz3 
    lda.z x
    sta.z return+1
    lda.z y
    sta.z return
    // cbm_k_plot_get::@return
    // }
    // [92] return 
    rts
}
  // gotoxy
// Set the cursor to the specified position
// void gotoxy(__zp($2c) char x, __zp($2d) char y)
gotoxy: {
    .label x = $2c
    .label y = $2d
    // (x>=__conio.width)?__conio.width:x
    // [94] if(gotoxy::x#4>=*((char *)&__conio+4)) goto gotoxy::@1 -- vbuz1_ge__deref_pbuc1_then_la1 
    lda.z x
    cmp __conio+4
    bcs __b1
    // [96] phi from gotoxy to gotoxy::@2 [phi:gotoxy->gotoxy::@2]
    // [96] phi gotoxy::$3 = gotoxy::x#4 [phi:gotoxy->gotoxy::@2#0] -- vbum1=vbuz2 
    sta __3
    jmp __b2
    // gotoxy::@1
  __b1:
    // [95] gotoxy::$2 = *((char *)&__conio+4) -- vbum1=_deref_pbuc1 
    lda __conio+4
    sta __2
    // [96] phi from gotoxy::@1 to gotoxy::@2 [phi:gotoxy::@1->gotoxy::@2]
    // [96] phi gotoxy::$3 = gotoxy::$2 [phi:gotoxy::@1->gotoxy::@2#0] -- register_copy 
    // gotoxy::@2
  __b2:
    // __conio.cursor_x = (x>=__conio.width)?__conio.width:x
    // [97] *((char *)&__conio+$d) = gotoxy::$3 -- _deref_pbuc1=vbum1 
    lda __3
    sta __conio+$d
    // (y>=__conio.height)?__conio.height:y
    // [98] if(gotoxy::y#10>=*((char *)&__conio+5)) goto gotoxy::@3 -- vbuz1_ge__deref_pbuc1_then_la1 
    lda.z y
    cmp __conio+5
    bcs __b3
    // gotoxy::@4
    // [99] gotoxy::$14 = gotoxy::y#10 -- vbum1=vbuz2 
    sta __14
    // [100] phi from gotoxy::@3 gotoxy::@4 to gotoxy::@5 [phi:gotoxy::@3/gotoxy::@4->gotoxy::@5]
    // [100] phi gotoxy::$7 = gotoxy::$6 [phi:gotoxy::@3/gotoxy::@4->gotoxy::@5#0] -- register_copy 
    // gotoxy::@5
  __b5:
    // __conio.cursor_y = (y>=__conio.height)?__conio.height:y
    // [101] *((char *)&__conio+$e) = gotoxy::$7 -- _deref_pbuc1=vbum1 
    lda __7
    sta __conio+$e
    // __conio.cursor_x << 1
    // [102] gotoxy::$8 = *((char *)&__conio+$d) << 1 -- vbum1=_deref_pbuc1_rol_1 
    lda __conio+$d
    asl
    sta __8
    // __conio.offsets[y] + __conio.cursor_x << 1
    // [103] gotoxy::$10 = gotoxy::y#10 << 1 -- vbum1=vbuz2_rol_1 
    lda.z y
    asl
    sta __10
    // [104] gotoxy::$9 = ((unsigned int *)&__conio+$15)[gotoxy::$10] + gotoxy::$8 -- vwum1=pwuc1_derefidx_vbum2_plus_vbum3 
    lda __8
    ldy __10
    clc
    adc __conio+$15,y
    sta __9
    lda __conio+$15+1,y
    adc #0
    sta __9+1
    // __conio.offset = __conio.offsets[y] + __conio.cursor_x << 1
    // [105] *((unsigned int *)&__conio+$13) = gotoxy::$9 -- _deref_pwuc1=vwum1 
    lda __9
    sta __conio+$13
    lda __9+1
    sta __conio+$13+1
    // gotoxy::@return
    // }
    // [106] return 
    rts
    // gotoxy::@3
  __b3:
    // (y>=__conio.height)?__conio.height:y
    // [107] gotoxy::$6 = *((char *)&__conio+5) -- vbum1=_deref_pbuc1 
    lda __conio+5
    sta __6
    jmp __b5
  .segment Data
    .label __2 = __3
    __3: .byte 0
    .label __6 = __7
    __7: .byte 0
    __8: .byte 0
    __9: .word 0
    __10: .byte 0
    .label __14 = __7
}
.segment Code
  // cputln
// Print a newline
cputln: {
    // __conio.cursor_x = 0
    // [108] *((char *)&__conio+$d) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+$d
    // __conio.cursor_y++;
    // [109] *((char *)&__conio+$e) = ++ *((char *)&__conio+$e) -- _deref_pbuc1=_inc__deref_pbuc1 
    inc __conio+$e
    // __conio.offset = __conio.offsets[__conio.cursor_y]
    // [110] cputln::$2 = *((char *)&__conio+$e) << 1 -- vbum1=_deref_pbuc1_rol_1 
    lda __conio+$e
    asl
    sta __2
    // [111] *((unsigned int *)&__conio+$13) = ((unsigned int *)&__conio+$15)[cputln::$2] -- _deref_pwuc1=pwuc2_derefidx_vbum1 
    tay
    lda __conio+$15,y
    sta __conio+$13
    lda __conio+$15+1,y
    sta __conio+$13+1
    // cscroll()
    // [112] call cscroll
    jsr cscroll
    // cputln::@return
    // }
    // [113] return 
    rts
  .segment Data
    __2: .byte 0
}
.segment Code
  // clrscr
// clears the screen and moves the cursor to the upper left-hand corner of the screen.
clrscr: {
    .label line_text = $30
    .label l = $26
    .label ch = $30
    .label c = $22
    // unsigned int line_text = __conio.mapbase_offset
    // [114] clrscr::line_text#0 = *((unsigned int *)&__conio+1) -- vwuz1=_deref_pwuc1 
    lda __conio+1
    sta.z line_text
    lda __conio+1+1
    sta.z line_text+1
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [115] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // __conio.mapbase_bank | VERA_INC_1
    // [116] clrscr::$0 = *((char *)&__conio+3) | VERA_INC_1 -- vbum1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+3
    sta __0
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [117] *VERA_ADDRX_H = clrscr::$0 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_H
    // unsigned char l = __conio.mapheight
    // [118] clrscr::l#0 = *((char *)&__conio+7) -- vbuz1=_deref_pbuc1 
    lda __conio+7
    sta.z l
    // [119] phi from clrscr clrscr::@3 to clrscr::@1 [phi:clrscr/clrscr::@3->clrscr::@1]
    // [119] phi clrscr::l#4 = clrscr::l#0 [phi:clrscr/clrscr::@3->clrscr::@1#0] -- register_copy 
    // [119] phi clrscr::ch#0 = clrscr::line_text#0 [phi:clrscr/clrscr::@3->clrscr::@1#1] -- register_copy 
    // clrscr::@1
  __b1:
    // BYTE0(ch)
    // [120] clrscr::$1 = byte0  clrscr::ch#0 -- vbum1=_byte0_vwuz2 
    lda.z ch
    sta __1
    // *VERA_ADDRX_L = BYTE0(ch)
    // [121] *VERA_ADDRX_L = clrscr::$1 -- _deref_pbuc1=vbum1 
    // Set address
    sta VERA_ADDRX_L
    // BYTE1(ch)
    // [122] clrscr::$2 = byte1  clrscr::ch#0 -- vbum1=_byte1_vwuz2 
    lda.z ch+1
    sta __2
    // *VERA_ADDRX_M = BYTE1(ch)
    // [123] *VERA_ADDRX_M = clrscr::$2 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_M
    // unsigned char c = __conio.mapwidth
    // [124] clrscr::c#0 = *((char *)&__conio+6) -- vbuz1=_deref_pbuc1 
    lda __conio+6
    sta.z c
    // [125] phi from clrscr::@1 clrscr::@2 to clrscr::@2 [phi:clrscr::@1/clrscr::@2->clrscr::@2]
    // [125] phi clrscr::c#2 = clrscr::c#0 [phi:clrscr::@1/clrscr::@2->clrscr::@2#0] -- register_copy 
    // clrscr::@2
  __b2:
    // *VERA_DATA0 = ' '
    // [126] *VERA_DATA0 = ' ' -- _deref_pbuc1=vbuc2 
    lda #' '
    sta VERA_DATA0
    // *VERA_DATA0 = __conio.color
    // [127] *VERA_DATA0 = *((char *)&__conio+$b) -- _deref_pbuc1=_deref_pbuc2 
    lda __conio+$b
    sta VERA_DATA0
    // c--;
    // [128] clrscr::c#1 = -- clrscr::c#2 -- vbuz1=_dec_vbuz1 
    dec.z c
    // while(c)
    // [129] if(0!=clrscr::c#1) goto clrscr::@2 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b2
    // clrscr::@3
    // line_text += __conio.rowskip
    // [130] clrscr::line_text#1 = clrscr::ch#0 + *((unsigned int *)&__conio+8) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z line_text
    adc __conio+8
    sta.z line_text
    lda.z line_text+1
    adc __conio+8+1
    sta.z line_text+1
    // l--;
    // [131] clrscr::l#1 = -- clrscr::l#4 -- vbuz1=_dec_vbuz1 
    dec.z l
    // while(l)
    // [132] if(0!=clrscr::l#1) goto clrscr::@1 -- 0_neq_vbuz1_then_la1 
    lda.z l
    bne __b1
    // clrscr::@4
    // __conio.cursor_x = 0
    // [133] *((char *)&__conio+$d) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+$d
    // __conio.cursor_y = 0
    // [134] *((char *)&__conio+$e) = 0 -- _deref_pbuc1=vbuc2 
    sta __conio+$e
    // __conio.offset = __conio.mapbase_offset
    // [135] *((unsigned int *)&__conio+$13) = *((unsigned int *)&__conio+1) -- _deref_pwuc1=_deref_pwuc2 
    lda __conio+1
    sta __conio+$13
    lda __conio+1+1
    sta __conio+$13+1
    // clrscr::@return
    // }
    // [136] return 
    rts
  .segment Data
    __0: .byte 0
    __1: .byte 0
    __2: .byte 0
}
.segment Code
  // printf_str
/// Print a NUL-terminated string
// void printf_str(void (*putc)(char), __zp($30) const char *s)
printf_str: {
    .label c = $26
    .label s = $30
    // [138] phi from printf_str to printf_str::@1 [phi:printf_str->printf_str::@1]
    // [138] phi printf_str::s#2 = main::s [phi:printf_str->printf_str::@1#0] -- pbuz1=pbuc1 
    lda #<main.s
    sta.z s
    lda #>main.s
    sta.z s+1
    // printf_str::@1
  __b1:
    // while(c=*s++)
    // [139] printf_str::c#1 = *printf_str::s#2 -- vbuz1=_deref_pbuz2 
    ldy #0
    lda (s),y
    sta.z c
    // [140] printf_str::s#0 = ++ printf_str::s#2 -- pbuz1=_inc_pbuz1 
    inc.z s
    bne !+
    inc.z s+1
  !:
    // [141] if(0!=printf_str::c#1) goto printf_str::@2 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b2
    // printf_str::@return
    // }
    // [142] return 
    rts
    // printf_str::@2
  __b2:
    // putc(c)
    // [143] stackpush(char) = printf_str::c#1 -- _stackpushbyte_=vbuz1 
    lda.z c
    pha
    // [144] callexecute cputc  -- call_vprc1 
    jsr cputc
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    // [138] phi from printf_str::@2 to printf_str::@1 [phi:printf_str::@2->printf_str::@1]
    // [138] phi printf_str::s#2 = printf_str::s#0 [phi:printf_str::@2->printf_str::@1#0] -- register_copy 
    jmp __b1
}
  // screenlayer
// --- layer management in VERA ---
// void screenlayer(char layer, __zp($2d) char mapbase, __zp($32) char config)
screenlayer: {
    .label mapbase_offset = $2e
    .label y = $2c
    .label mapbase = $2d
    .label config = $32
    // __mem char vera_dc_hscale_temp = *VERA_DC_HSCALE
    // [146] screenlayer::vera_dc_hscale_temp#0 = *VERA_DC_HSCALE -- vbum1=_deref_pbuc1 
    lda VERA_DC_HSCALE
    sta vera_dc_hscale_temp
    // __mem char vera_dc_vscale_temp = *VERA_DC_VSCALE
    // [147] screenlayer::vera_dc_vscale_temp#0 = *VERA_DC_VSCALE -- vbum1=_deref_pbuc1 
    lda VERA_DC_VSCALE
    sta vera_dc_vscale_temp
    // __conio.layer = 0
    // [148] *((char *)&__conio) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio
    // mapbase >> 7
    // [149] screenlayer::$0 = screenlayer::mapbase#0 >> 7 -- vbum1=vbuz2_ror_7 
    lda.z mapbase
    rol
    rol
    and #1
    sta __0
    // __conio.mapbase_bank = mapbase >> 7
    // [150] *((char *)&__conio+3) = screenlayer::$0 -- _deref_pbuc1=vbum1 
    sta __conio+3
    // (mapbase)<<1
    // [151] screenlayer::$1 = screenlayer::mapbase#0 << 1 -- vbum1=vbuz2_rol_1 
    lda.z mapbase
    asl
    sta __1
    // MAKEWORD((mapbase)<<1,0)
    // [152] screenlayer::$2 = screenlayer::$1 w= 0 -- vwum1=vbum2_word_vbuc1 
    lda #0
    ldy __1
    sty __2+1
    sta __2
    // __conio.mapbase_offset = MAKEWORD((mapbase)<<1,0)
    // [153] *((unsigned int *)&__conio+1) = screenlayer::$2 -- _deref_pwuc1=vwum1 
    sta __conio+1
    tya
    sta __conio+1+1
    // config & VERA_LAYER_WIDTH_MASK
    // [154] screenlayer::$7 = screenlayer::config#0 & VERA_LAYER_WIDTH_MASK -- vbum1=vbuz2_band_vbuc1 
    lda #VERA_LAYER_WIDTH_MASK
    and.z config
    sta __7
    // (config & VERA_LAYER_WIDTH_MASK) >> 4
    // [155] screenlayer::$8 = screenlayer::$7 >> 4 -- vbum1=vbum1_ror_4 
    lda __8
    lsr
    lsr
    lsr
    lsr
    sta __8
    // __conio.mapwidth = VERA_LAYER_DIM[ (config & VERA_LAYER_WIDTH_MASK) >> 4]
    // [156] *((char *)&__conio+6) = screenlayer::VERA_LAYER_DIM[screenlayer::$8] -- _deref_pbuc1=pbuc2_derefidx_vbum1 
    tay
    lda VERA_LAYER_DIM,y
    sta __conio+6
    // config & VERA_LAYER_HEIGHT_MASK
    // [157] screenlayer::$5 = screenlayer::config#0 & VERA_LAYER_HEIGHT_MASK -- vbum1=vbuz2_band_vbuc1 
    lda #VERA_LAYER_HEIGHT_MASK
    and.z config
    sta __5
    // (config & VERA_LAYER_HEIGHT_MASK) >> 6
    // [158] screenlayer::$6 = screenlayer::$5 >> 6 -- vbum1=vbum1_ror_6 
    lda __6
    rol
    rol
    rol
    and #3
    sta __6
    // __conio.mapheight = VERA_LAYER_DIM[ (config & VERA_LAYER_HEIGHT_MASK) >> 6]
    // [159] *((char *)&__conio+7) = screenlayer::VERA_LAYER_DIM[screenlayer::$6] -- _deref_pbuc1=pbuc2_derefidx_vbum1 
    tay
    lda VERA_LAYER_DIM,y
    sta __conio+7
    // __conio.rowskip = VERA_LAYER_SKIP[(config & VERA_LAYER_WIDTH_MASK)>>4]
    // [160] screenlayer::$16 = screenlayer::$8 << 1 -- vbum1=vbum1_rol_1 
    asl __16
    // [161] *((unsigned int *)&__conio+8) = screenlayer::VERA_LAYER_SKIP[screenlayer::$16] -- _deref_pwuc1=pwuc2_derefidx_vbum1 
    // __conio.rowshift = ((config & VERA_LAYER_WIDTH_MASK)>>4)+6;
    ldy __16
    lda VERA_LAYER_SKIP,y
    sta __conio+8
    lda VERA_LAYER_SKIP+1,y
    sta __conio+8+1
    // vera_dc_hscale_temp == 0x80
    // [162] screenlayer::$9 = screenlayer::vera_dc_hscale_temp#0 == $80 -- vbom1=vbum1_eq_vbuc1 
    lda __9
    eor #$80
    beq !+
    lda #1
  !:
    eor #1
    sta __9
    // 40 << (char)(vera_dc_hscale_temp == 0x80)
    // [163] screenlayer::$18 = (char)screenlayer::$9
    // [164] screenlayer::$10 = $28 << screenlayer::$18 -- vbum1=vbuc1_rol_vbum1 
    lda #$28
    ldy __10
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta __10
    // (40 << (char)(vera_dc_hscale_temp == 0x80))-1
    // [165] screenlayer::$11 = screenlayer::$10 - 1 -- vbum1=vbum1_minus_1 
    dec __11
    // __conio.width = (40 << (char)(vera_dc_hscale_temp == 0x80))-1
    // [166] *((char *)&__conio+4) = screenlayer::$11 -- _deref_pbuc1=vbum1 
    lda __11
    sta __conio+4
    // vera_dc_vscale_temp == 0x80
    // [167] screenlayer::$12 = screenlayer::vera_dc_vscale_temp#0 == $80 -- vbom1=vbum1_eq_vbuc1 
    lda __12
    eor #$80
    beq !+
    lda #1
  !:
    eor #1
    sta __12
    // 30 << (char)(vera_dc_vscale_temp == 0x80)
    // [168] screenlayer::$19 = (char)screenlayer::$12
    // [169] screenlayer::$13 = $1e << screenlayer::$19 -- vbum1=vbuc1_rol_vbum1 
    lda #$1e
    ldy __13
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta __13
    // (30 << (char)(vera_dc_vscale_temp == 0x80))-1
    // [170] screenlayer::$14 = screenlayer::$13 - 1 -- vbum1=vbum1_minus_1 
    dec __14
    // __conio.height = (30 << (char)(vera_dc_vscale_temp == 0x80))-1
    // [171] *((char *)&__conio+5) = screenlayer::$14 -- _deref_pbuc1=vbum1 
    lda __14
    sta __conio+5
    // unsigned int mapbase_offset = __conio.mapbase_offset
    // [172] screenlayer::mapbase_offset#0 = *((unsigned int *)&__conio+1) -- vwuz1=_deref_pwuc1 
    lda __conio+1
    sta.z mapbase_offset
    lda __conio+1+1
    sta.z mapbase_offset+1
    // [173] phi from screenlayer to screenlayer::@1 [phi:screenlayer->screenlayer::@1]
    // [173] phi screenlayer::mapbase_offset#2 = screenlayer::mapbase_offset#0 [phi:screenlayer->screenlayer::@1#0] -- register_copy 
    // [173] phi screenlayer::y#2 = 0 [phi:screenlayer->screenlayer::@1#1] -- vbuz1=vbuc1 
    lda #0
    sta.z y
    // screenlayer::@1
  __b1:
    // for(register char y=0; y<__conio.height; y++)
    // [174] if(screenlayer::y#2<*((char *)&__conio+5)) goto screenlayer::@2 -- vbuz1_lt__deref_pbuc1_then_la1 
    lda.z y
    cmp __conio+5
    bcc __b2
    // screenlayer::@return
    // }
    // [175] return 
    rts
    // screenlayer::@2
  __b2:
    // __conio.offsets[y] = mapbase_offset
    // [176] screenlayer::$17 = screenlayer::y#2 << 1 -- vbum1=vbuz2_rol_1 
    lda.z y
    asl
    sta __17
    // [177] ((unsigned int *)&__conio+$15)[screenlayer::$17] = screenlayer::mapbase_offset#2 -- pwuc1_derefidx_vbum1=vwuz2 
    tay
    lda.z mapbase_offset
    sta __conio+$15,y
    lda.z mapbase_offset+1
    sta __conio+$15+1,y
    // mapbase_offset += __conio.rowskip
    // [178] screenlayer::mapbase_offset#1 = screenlayer::mapbase_offset#2 + *((unsigned int *)&__conio+8) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z mapbase_offset
    adc __conio+8
    sta.z mapbase_offset
    lda.z mapbase_offset+1
    adc __conio+8+1
    sta.z mapbase_offset+1
    // for(register char y=0; y<__conio.height; y++)
    // [179] screenlayer::y#1 = ++ screenlayer::y#2 -- vbuz1=_inc_vbuz1 
    inc.z y
    // [173] phi from screenlayer::@2 to screenlayer::@1 [phi:screenlayer::@2->screenlayer::@1]
    // [173] phi screenlayer::mapbase_offset#2 = screenlayer::mapbase_offset#1 [phi:screenlayer::@2->screenlayer::@1#0] -- register_copy 
    // [173] phi screenlayer::y#2 = screenlayer::y#1 [phi:screenlayer::@2->screenlayer::@1#1] -- register_copy 
    jmp __b1
  .segment Data
    VERA_LAYER_DIM: .byte $1f, $3f, $7f, $ff
    VERA_LAYER_SKIP: .word $40, $80, $100, $200
    __0: .byte 0
    __1: .byte 0
    __2: .word 0
    __5: .byte 0
    .label __6 = __5
    __7: .byte 0
    .label __8 = __7
    .label __9 = vera_dc_hscale_temp
    .label __10 = vera_dc_hscale_temp
    .label __11 = vera_dc_hscale_temp
    .label __12 = vera_dc_vscale_temp
    .label __13 = vera_dc_vscale_temp
    .label __14 = vera_dc_vscale_temp
    .label __16 = __7
    __17: .byte 0
    .label __18 = vera_dc_hscale_temp
    .label __19 = vera_dc_vscale_temp
    vera_dc_hscale_temp: .byte 0
    vera_dc_vscale_temp: .byte 0
}
.segment Code
  // cscroll
// Scroll the entire screen if the cursor is beyond the last line
cscroll: {
    // if(__conio.cursor_y>__conio.height)
    // [180] if(*((char *)&__conio+$e)<=*((char *)&__conio+5)) goto cscroll::@return -- _deref_pbuc1_le__deref_pbuc2_then_la1 
    lda __conio+5
    cmp __conio+$e
    bcs __breturn
    // cscroll::@1
    // if(__conio.scroll[__conio.layer])
    // [181] if(0!=((char *)&__conio+$f)[*((char *)&__conio)]) goto cscroll::@4 -- 0_neq_pbuc1_derefidx_(_deref_pbuc2)_then_la1 
    ldy __conio
    lda __conio+$f,y
    cmp #0
    bne __b4
    // cscroll::@2
    // if(__conio.cursor_y>__conio.height)
    // [182] if(*((char *)&__conio+$e)<=*((char *)&__conio+5)) goto cscroll::@return -- _deref_pbuc1_le__deref_pbuc2_then_la1 
    lda __conio+5
    cmp __conio+$e
    bcs __breturn
    // [183] phi from cscroll::@2 to cscroll::@3 [phi:cscroll::@2->cscroll::@3]
    // cscroll::@3
    // gotoxy(0,0)
    // [184] call gotoxy
    // [93] phi from cscroll::@3 to gotoxy [phi:cscroll::@3->gotoxy]
    // [93] phi gotoxy::y#10 = 0 [phi:cscroll::@3->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.y
    // [93] phi gotoxy::x#4 = 0 [phi:cscroll::@3->gotoxy#1] -- vbuz1=vbuc1 
    sta.z gotoxy.x
    jsr gotoxy
    // cscroll::@return
  __breturn:
    // }
    // [185] return 
    rts
    // [186] phi from cscroll::@1 to cscroll::@4 [phi:cscroll::@1->cscroll::@4]
    // cscroll::@4
  __b4:
    // insertup(1)
    // [187] call insertup
    jsr insertup
    // cscroll::@5
    // gotoxy( 0, __conio.height)
    // [188] gotoxy::y#1 = *((char *)&__conio+5) -- vbuz1=_deref_pbuc1 
    lda __conio+5
    sta.z gotoxy.y
    // [189] call gotoxy
    // [93] phi from cscroll::@5 to gotoxy [phi:cscroll::@5->gotoxy]
    // [93] phi gotoxy::y#10 = gotoxy::y#1 [phi:cscroll::@5->gotoxy#0] -- register_copy 
    // [93] phi gotoxy::x#4 = 0 [phi:cscroll::@5->gotoxy#1] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    jsr gotoxy
    // [190] phi from cscroll::@5 to cscroll::@6 [phi:cscroll::@5->cscroll::@6]
    // cscroll::@6
    // clearline()
    // [191] call clearline
    jsr clearline
    rts
}
  // insertup
// Insert a new line, and scroll the upper part of the screen up.
// void insertup(char rows)
insertup: {
    .label width = $2b
    .label y = $26
    // __conio.width+1
    // [192] insertup::$0 = *((char *)&__conio+4) + 1 -- vbum1=_deref_pbuc1_plus_1 
    lda __conio+4
    inc
    sta __0
    // unsigned char width = (__conio.width+1) * 2
    // [193] insertup::width#0 = insertup::$0 << 1 -- vbuz1=vbum2_rol_1 
    asl
    sta.z width
    // [194] phi from insertup to insertup::@1 [phi:insertup->insertup::@1]
    // [194] phi insertup::y#2 = 0 [phi:insertup->insertup::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z y
    // insertup::@1
  __b1:
    // for(unsigned char y=0; y<=__conio.cursor_y; y++)
    // [195] if(insertup::y#2<=*((char *)&__conio+$e)) goto insertup::@2 -- vbuz1_le__deref_pbuc1_then_la1 
    lda __conio+$e
    cmp.z y
    bcs __b2
    // [196] phi from insertup::@1 to insertup::@3 [phi:insertup::@1->insertup::@3]
    // insertup::@3
    // clearline()
    // [197] call clearline
    jsr clearline
    // insertup::@return
    // }
    // [198] return 
    rts
    // insertup::@2
  __b2:
    // y+1
    // [199] insertup::$4 = insertup::y#2 + 1 -- vbum1=vbuz2_plus_1 
    lda.z y
    inc
    sta __4
    // memcpy8_vram_vram(__conio.mapbase_bank, __conio.offsets[y], __conio.mapbase_bank, __conio.offsets[y+1], width)
    // [200] insertup::$6 = insertup::y#2 << 1 -- vbum1=vbuz2_rol_1 
    lda.z y
    asl
    sta __6
    // [201] insertup::$7 = insertup::$4 << 1 -- vbum1=vbum1_rol_1 
    asl __7
    // [202] memcpy8_vram_vram::dbank_vram#0 = *((char *)&__conio+3) -- vbuz1=_deref_pbuc1 
    lda __conio+3
    sta.z memcpy8_vram_vram.dbank_vram
    // [203] memcpy8_vram_vram::doffset_vram#0 = ((unsigned int *)&__conio+$15)[insertup::$6] -- vwuz1=pwuc1_derefidx_vbum2 
    ldy __6
    lda __conio+$15,y
    sta.z memcpy8_vram_vram.doffset_vram
    lda __conio+$15+1,y
    sta.z memcpy8_vram_vram.doffset_vram+1
    // [204] memcpy8_vram_vram::sbank_vram#0 = *((char *)&__conio+3) -- vbuz1=_deref_pbuc1 
    lda __conio+3
    sta.z memcpy8_vram_vram.sbank_vram
    // [205] memcpy8_vram_vram::soffset_vram#0 = ((unsigned int *)&__conio+$15)[insertup::$7] -- vwuz1=pwuc1_derefidx_vbum2 
    ldy __7
    lda __conio+$15,y
    sta.z memcpy8_vram_vram.soffset_vram
    lda __conio+$15+1,y
    sta.z memcpy8_vram_vram.soffset_vram+1
    // [206] memcpy8_vram_vram::num8#1 = insertup::width#0 -- vbuz1=vbuz2 
    lda.z width
    sta.z memcpy8_vram_vram.num8_1
    // [207] call memcpy8_vram_vram
    jsr memcpy8_vram_vram
    // insertup::@4
    // for(unsigned char y=0; y<=__conio.cursor_y; y++)
    // [208] insertup::y#1 = ++ insertup::y#2 -- vbuz1=_inc_vbuz1 
    inc.z y
    // [194] phi from insertup::@4 to insertup::@1 [phi:insertup::@4->insertup::@1]
    // [194] phi insertup::y#2 = insertup::y#1 [phi:insertup::@4->insertup::@1#0] -- register_copy 
    jmp __b1
  .segment Data
    __0: .byte 0
    __4: .byte 0
    __6: .byte 0
    .label __7 = __4
}
.segment Code
  // clearline
clearline: {
    .label addr = $27
    .label c = $22
    // unsigned int addr = __conio.offsets[__conio.cursor_y]
    // [209] clearline::$3 = *((char *)&__conio+$e) << 1 -- vbum1=_deref_pbuc1_rol_1 
    lda __conio+$e
    asl
    sta __3
    // [210] clearline::addr#0 = ((unsigned int *)&__conio+$15)[clearline::$3] -- vwuz1=pwuc1_derefidx_vbum2 
    tay
    lda __conio+$15,y
    sta.z addr
    lda __conio+$15+1,y
    sta.z addr+1
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [211] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(addr)
    // [212] clearline::$0 = byte0  clearline::addr#0 -- vbum1=_byte0_vwuz2 
    lda.z addr
    sta __0
    // *VERA_ADDRX_L = BYTE0(addr)
    // [213] *VERA_ADDRX_L = clearline::$0 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_L
    // BYTE1(addr)
    // [214] clearline::$1 = byte1  clearline::addr#0 -- vbum1=_byte1_vwuz2 
    lda.z addr+1
    sta __1
    // *VERA_ADDRX_M = BYTE1(addr)
    // [215] *VERA_ADDRX_M = clearline::$1 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_M
    // __conio.mapbase_bank | VERA_INC_1
    // [216] clearline::$2 = *((char *)&__conio+3) | VERA_INC_1 -- vbum1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+3
    sta __2
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [217] *VERA_ADDRX_H = clearline::$2 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_H
    // register unsigned char c=__conio.width
    // [218] clearline::c#0 = *((char *)&__conio+4) -- vbuz1=_deref_pbuc1 
    lda __conio+4
    sta.z c
    // [219] phi from clearline clearline::@1 to clearline::@1 [phi:clearline/clearline::@1->clearline::@1]
    // [219] phi clearline::c#2 = clearline::c#0 [phi:clearline/clearline::@1->clearline::@1#0] -- register_copy 
    // clearline::@1
  __b1:
    // *VERA_DATA0 = ' '
    // [220] *VERA_DATA0 = ' ' -- _deref_pbuc1=vbuc2 
    lda #' '
    sta VERA_DATA0
    // *VERA_DATA0 = __conio.color
    // [221] *VERA_DATA0 = *((char *)&__conio+$b) -- _deref_pbuc1=_deref_pbuc2 
    lda __conio+$b
    sta VERA_DATA0
    // c--;
    // [222] clearline::c#1 = -- clearline::c#2 -- vbuz1=_dec_vbuz1 
    dec.z c
    // while(c)
    // [223] if(0!=clearline::c#1) goto clearline::@1 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b1
    // clearline::@return
    // }
    // [224] return 
    rts
  .segment Data
    __0: .byte 0
    __1: .byte 0
    __2: .byte 0
    __3: .byte 0
}
.segment Code
  // memcpy8_vram_vram
/**
 * @brief Copy a block of memory in VRAM from a source to a target destination.
 * This function is designed to copy maximum 255 bytes of memory in one step.
 * If more than 255 bytes need to be copied, use the memcpy_vram_vram function.
 * 
 * @see memcpy_vram_vram
 * 
 * @param dbank_vram Bank of the destination location in vram.
 * @param doffset_vram Offset of the destination location in vram.
 * @param sbank_vram Bank of the source location in vram.
 * @param soffset_vram Offset of the source location in vram.
 * @param num16 Specified the amount of bytes to be copied.
 */
// void memcpy8_vram_vram(__zp($2a) char dbank_vram, __zp($27) unsigned int doffset_vram, __zp($29) char sbank_vram, __zp($24) unsigned int soffset_vram, __zp($23) char num8)
memcpy8_vram_vram: {
    .label num8 = $23
    .label dbank_vram = $2a
    .label doffset_vram = $27
    .label sbank_vram = $29
    .label soffset_vram = $24
    .label num8_1 = $22
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [225] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(soffset_vram)
    // [226] memcpy8_vram_vram::$0 = byte0  memcpy8_vram_vram::soffset_vram#0 -- vbum1=_byte0_vwuz2 
    lda.z soffset_vram
    sta __0
    // *VERA_ADDRX_L = BYTE0(soffset_vram)
    // [227] *VERA_ADDRX_L = memcpy8_vram_vram::$0 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_L
    // BYTE1(soffset_vram)
    // [228] memcpy8_vram_vram::$1 = byte1  memcpy8_vram_vram::soffset_vram#0 -- vbum1=_byte1_vwuz2 
    lda.z soffset_vram+1
    sta __1
    // *VERA_ADDRX_M = BYTE1(soffset_vram)
    // [229] *VERA_ADDRX_M = memcpy8_vram_vram::$1 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_M
    // sbank_vram | VERA_INC_1
    // [230] memcpy8_vram_vram::$2 = memcpy8_vram_vram::sbank_vram#0 | VERA_INC_1 -- vbum1=vbuz2_bor_vbuc1 
    lda #VERA_INC_1
    ora.z sbank_vram
    sta __2
    // *VERA_ADDRX_H = sbank_vram | VERA_INC_1
    // [231] *VERA_ADDRX_H = memcpy8_vram_vram::$2 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_H
    // *VERA_CTRL |= VERA_ADDRSEL
    // [232] *VERA_CTRL = *VERA_CTRL | VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_ADDRSEL
    ora VERA_CTRL
    sta VERA_CTRL
    // BYTE0(doffset_vram)
    // [233] memcpy8_vram_vram::$3 = byte0  memcpy8_vram_vram::doffset_vram#0 -- vbum1=_byte0_vwuz2 
    lda.z doffset_vram
    sta __3
    // *VERA_ADDRX_L = BYTE0(doffset_vram)
    // [234] *VERA_ADDRX_L = memcpy8_vram_vram::$3 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_L
    // BYTE1(doffset_vram)
    // [235] memcpy8_vram_vram::$4 = byte1  memcpy8_vram_vram::doffset_vram#0 -- vbum1=_byte1_vwuz2 
    lda.z doffset_vram+1
    sta __4
    // *VERA_ADDRX_M = BYTE1(doffset_vram)
    // [236] *VERA_ADDRX_M = memcpy8_vram_vram::$4 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_M
    // dbank_vram | VERA_INC_1
    // [237] memcpy8_vram_vram::$5 = memcpy8_vram_vram::dbank_vram#0 | VERA_INC_1 -- vbum1=vbuz2_bor_vbuc1 
    lda #VERA_INC_1
    ora.z dbank_vram
    sta __5
    // *VERA_ADDRX_H = dbank_vram | VERA_INC_1
    // [238] *VERA_ADDRX_H = memcpy8_vram_vram::$5 -- _deref_pbuc1=vbum1 
    sta VERA_ADDRX_H
    // [239] phi from memcpy8_vram_vram memcpy8_vram_vram::@2 to memcpy8_vram_vram::@1 [phi:memcpy8_vram_vram/memcpy8_vram_vram::@2->memcpy8_vram_vram::@1]
  __b1:
    // [239] phi memcpy8_vram_vram::num8#2 = memcpy8_vram_vram::num8#1 [phi:memcpy8_vram_vram/memcpy8_vram_vram::@2->memcpy8_vram_vram::@1#0] -- register_copy 
  // the size is only a byte, this is the fastest loop!
    // memcpy8_vram_vram::@1
    // while(num8--)
    // [240] memcpy8_vram_vram::num8#0 = -- memcpy8_vram_vram::num8#2 -- vbuz1=_dec_vbuz2 
    ldy.z num8_1
    dey
    sty.z num8
    // [241] if(0!=memcpy8_vram_vram::num8#2) goto memcpy8_vram_vram::@2 -- 0_neq_vbuz1_then_la1 
    lda.z num8_1
    bne __b2
    // memcpy8_vram_vram::@return
    // }
    // [242] return 
    rts
    // memcpy8_vram_vram::@2
  __b2:
    // *VERA_DATA1 = *VERA_DATA0
    // [243] *VERA_DATA1 = *VERA_DATA0 -- _deref_pbuc1=_deref_pbuc2 
    lda VERA_DATA0
    sta VERA_DATA1
    // [244] memcpy8_vram_vram::num8#6 = memcpy8_vram_vram::num8#0 -- vbuz1=vbuz2 
    lda.z num8
    sta.z num8_1
    jmp __b1
  .segment Data
    __0: .byte 0
    __1: .byte 0
    __2: .byte 0
    __3: .byte 0
    __4: .byte 0
    __5: .byte 0
}
  // File Data
  __conio: .fill SIZEOF_STRUCT___0, 0
