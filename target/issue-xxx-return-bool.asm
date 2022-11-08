  // File Comments
  // Upstart
.cpu _65c02
  // Commander X16 PRG executable file
.file [name="issue-xxx-return-bool.prg", type="prg", segments="Program"]
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
  .const isr_vsync = $314
  .const SIZEOF_STRUCT___0 = $8d
  .const SIZEOF_STRUCT___1 = $384
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
    // [3] phi from __start::__init1 to __start::@2 [phi:__start::__init1->__start::@2]
    // __start::@2
    // #pragma constructor_for(conio_x16_init, cputc, clrscr, cscroll)
    // [4] call conio_x16_init
    // [8] phi from __start::@2 to conio_x16_init [phi:__start::@2->conio_x16_init]
    jsr conio_x16_init
    // [5] phi from __start::@2 to __start::@1 [phi:__start::@2->__start::@1]
    // __start::@1
    // [6] call main
    // [33] phi from __start::@1 to main [phi:__start::@1->main]
    jsr main
    // __start::@return
    // [7] return 
    rts
}
  // conio_x16_init
/// Set initial screen values.
conio_x16_init: {
    .label __4 = $26
    .label __5 = $35
    .label __6 = $26
    .label __7 = $34
    // screenlayer1()
    // [9] call screenlayer1
    jsr screenlayer1
    // [10] phi from conio_x16_init to conio_x16_init::@1 [phi:conio_x16_init->conio_x16_init::@1]
    // conio_x16_init::@1
    // textcolor(CONIO_TEXTCOLOR_DEFAULT)
    // [11] call textcolor
    jsr textcolor
    // [12] phi from conio_x16_init::@1 to conio_x16_init::@2 [phi:conio_x16_init::@1->conio_x16_init::@2]
    // conio_x16_init::@2
    // bgcolor(CONIO_BACKCOLOR_DEFAULT)
    // [13] call bgcolor
    jsr bgcolor
    // [14] phi from conio_x16_init::@2 to conio_x16_init::@3 [phi:conio_x16_init::@2->conio_x16_init::@3]
    // conio_x16_init::@3
    // cursor(0)
    // [15] call cursor
    jsr cursor
    // [16] phi from conio_x16_init::@3 to conio_x16_init::@4 [phi:conio_x16_init::@3->conio_x16_init::@4]
    // conio_x16_init::@4
    // cbm_k_plot_get()
    // [17] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [18] cbm_k_plot_get::return#2 = cbm_k_plot_get::return#0
    // conio_x16_init::@5
    // [19] conio_x16_init::$4 = cbm_k_plot_get::return#2
    // BYTE1(cbm_k_plot_get())
    // [20] conio_x16_init::$5 = byte1  conio_x16_init::$4 -- vbuz1=_byte1_vwuz2 
    lda.z __4+1
    sta.z __5
    // __conio.cursor_x = BYTE1(cbm_k_plot_get())
    // [21] *((char *)&__conio+$d) = conio_x16_init::$5 -- _deref_pbuc1=vbuz1 
    sta __conio+$d
    // cbm_k_plot_get()
    // [22] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [23] cbm_k_plot_get::return#3 = cbm_k_plot_get::return#0
    // conio_x16_init::@6
    // [24] conio_x16_init::$6 = cbm_k_plot_get::return#3
    // BYTE0(cbm_k_plot_get())
    // [25] conio_x16_init::$7 = byte0  conio_x16_init::$6 -- vbuz1=_byte0_vwuz2 
    lda.z __6
    sta.z __7
    // __conio.cursor_y = BYTE0(cbm_k_plot_get())
    // [26] *((char *)&__conio+$e) = conio_x16_init::$7 -- _deref_pbuc1=vbuz1 
    sta __conio+$e
    // gotoxy(__conio.cursor_x, __conio.cursor_y)
    // [27] gotoxy::x#0 = *((char *)&__conio+$d) -- vbuz1=_deref_pbuc1 
    lda __conio+$d
    sta.z gotoxy.x
    // [28] gotoxy::y#0 = *((char *)&__conio+$e) -- vbuz1=_deref_pbuc1 
    lda __conio+$e
    sta.z gotoxy.y
    // [29] call gotoxy
    // [61] phi from conio_x16_init::@6 to gotoxy [phi:conio_x16_init::@6->gotoxy]
    // [61] phi gotoxy::y#2 = gotoxy::y#0 [phi:conio_x16_init::@6->gotoxy#0] -- register_copy 
    // [61] phi gotoxy::x#2 = gotoxy::x#0 [phi:conio_x16_init::@6->gotoxy#1] -- register_copy 
    jsr gotoxy
    // conio_x16_init::@7
    // __conio.scroll[0] = 1
    // [30] *((char *)&__conio+$f) = 1 -- _deref_pbuc1=vbuc2 
    lda #1
    sta __conio+$f
    // __conio.scroll[1] = 1
    // [31] *((char *)&__conio+$f+1) = 1 -- _deref_pbuc1=vbuc2 
    sta __conio+$f+1
    // conio_x16_init::@return
    // }
    // [32] return 
    rts
}
  // main
main: {
    // clrscr()
    // [34] call clrscr
    jsr clrscr
    // [35] phi from main to main::@1 [phi:main->main::@1]
    // main::@1
    // gotoxy(0,1)
    // [36] call gotoxy
    // [61] phi from main::@1 to gotoxy [phi:main::@1->gotoxy]
    // [61] phi gotoxy::y#2 = 1 [phi:main::@1->gotoxy#0] -- vbuz1=vbuc1 
    lda #1
    sta.z gotoxy.y
    // [61] phi gotoxy::x#2 = 0 [phi:main::@1->gotoxy#1] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    jsr gotoxy
    // [37] phi from main::@1 to main::@2 [phi:main::@1->main::@2]
    // main::@2
    // __export vera_sprite_image_offset v1 = sprite_image_cache_vram(1, 2)
    // [38] call sprite_image_cache_vram
    // [99] phi from main::@2 to sprite_image_cache_vram [phi:main::@2->sprite_image_cache_vram]
    jsr sprite_image_cache_vram
    // [39] phi from main::@2 to main::@3 [phi:main::@2->main::@3]
    // main::@3
    // __export vera_sprite_image_offset v2 = sprite_image_cache_vram(2, 4)
    // [40] call sprite_image_cache_vram
    // [99] phi from main::@3 to sprite_image_cache_vram [phi:main::@3->sprite_image_cache_vram]
    jsr sprite_image_cache_vram
    // main::@return
    // }
    // [41] return 
    rts
}
  // screenlayer1
// Set the layer with which the conio will interact.
screenlayer1: {
    // screenlayer(1, *VERA_L1_MAPBASE, *VERA_L1_CONFIG)
    // [42] screenlayer::mapbase#0 = *VERA_L1_MAPBASE -- vbuz1=_deref_pbuc1 
    lda VERA_L1_MAPBASE
    sta.z screenlayer.mapbase
    // [43] screenlayer::config#0 = *VERA_L1_CONFIG -- vbuz1=_deref_pbuc1 
    lda VERA_L1_CONFIG
    sta.z screenlayer.config
    // [44] call screenlayer
    jsr screenlayer
    // screenlayer1::@return
    // }
    // [45] return 
    rts
}
  // textcolor
// Set the front color for text output. The old front text color setting is returned.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char textcolor(char color)
textcolor: {
    .label __0 = $2e
    .label __1 = $2e
    // __conio.color & 0xF0
    // [46] textcolor::$0 = *((char *)&__conio+$b) & $f0 -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #$f0
    and __conio+$b
    sta.z __0
    // __conio.color & 0xF0 | color
    // [47] textcolor::$1 = textcolor::$0 | WHITE -- vbuz1=vbuz1_bor_vbuc1 
    lda #WHITE
    ora.z __1
    sta.z __1
    // __conio.color = __conio.color & 0xF0 | color
    // [48] *((char *)&__conio+$b) = textcolor::$1 -- _deref_pbuc1=vbuz1 
    sta __conio+$b
    // textcolor::@return
    // }
    // [49] return 
    rts
}
  // bgcolor
// Set the back color for text output.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char bgcolor(char color)
bgcolor: {
    .label __0 = $2b
    .label __2 = $2b
    // __conio.color & 0x0F
    // [50] bgcolor::$0 = *((char *)&__conio+$b) & $f -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #$f
    and __conio+$b
    sta.z __0
    // __conio.color & 0x0F | color << 4
    // [51] bgcolor::$2 = bgcolor::$0 | BLUE<<4 -- vbuz1=vbuz1_bor_vbuc1 
    lda #BLUE<<4
    ora.z __2
    sta.z __2
    // __conio.color = __conio.color & 0x0F | color << 4
    // [52] *((char *)&__conio+$b) = bgcolor::$2 -- _deref_pbuc1=vbuz1 
    sta __conio+$b
    // bgcolor::@return
    // }
    // [53] return 
    rts
}
  // cursor
// If onoff is 1, a cursor is displayed when waiting for keyboard input.
// If onoff is 0, the cursor is hidden when waiting for keyboard input.
// The function returns the old cursor setting.
// char cursor(char onoff)
cursor: {
    .const onoff = 0
    // __conio.cursor = onoff
    // [54] *((char *)&__conio+$a) = cursor::onoff#0 -- _deref_pbuc1=vbuc2 
    lda #onoff
    sta __conio+$a
    // cursor::@return
    // }
    // [55] return 
    rts
}
  // cbm_k_plot_get
/**
 * @brief Get current x and y cursor position.
 * @return An unsigned int where the hi byte is the x coordinate and the low byte is the y coordinate of the screen position.
 */
cbm_k_plot_get: {
    .label x = $38
    .label y = $37
    .label return = $26
    // unsigned char x
    // [56] cbm_k_plot_get::x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z x
    // unsigned char y
    // [57] cbm_k_plot_get::y = 0 -- vbuz1=vbuc1 
    sta.z y
    // kickasm
    // kickasm( uses cbm_k_plot_get::x uses cbm_k_plot_get::y uses CBM_PLOT) {{ sec         jsr CBM_PLOT         stx y         sty x      }}
    sec
        jsr CBM_PLOT
        stx y
        sty x
    
    // MAKEWORD(x,y)
    // [59] cbm_k_plot_get::return#0 = cbm_k_plot_get::x w= cbm_k_plot_get::y -- vwuz1=vbuz2_word_vbuz3 
    lda.z x
    sta.z return+1
    lda.z y
    sta.z return
    // cbm_k_plot_get::@return
    // }
    // [60] return 
    rts
}
  // gotoxy
// Set the cursor to the specified position
// void gotoxy(__zp($35) char x, __zp($24) char y)
gotoxy: {
    .label __2 = $35
    .label __3 = $35
    .label __6 = $34
    .label __7 = $34
    .label __8 = $31
    .label __9 = $2f
    .label __10 = $24
    .label x = $35
    .label y = $24
    .label __14 = $34
    // (x>=__conio.width)?__conio.width:x
    // [62] if(gotoxy::x#2>=*((char *)&__conio+4)) goto gotoxy::@1 -- vbuz1_ge__deref_pbuc1_then_la1 
    lda.z x
    cmp __conio+4
    bcs __b1
    // [64] phi from gotoxy gotoxy::@1 to gotoxy::@2 [phi:gotoxy/gotoxy::@1->gotoxy::@2]
    // [64] phi gotoxy::$3 = gotoxy::x#2 [phi:gotoxy/gotoxy::@1->gotoxy::@2#0] -- register_copy 
    jmp __b2
    // gotoxy::@1
  __b1:
    // [63] gotoxy::$2 = *((char *)&__conio+4) -- vbuz1=_deref_pbuc1 
    lda __conio+4
    sta.z __2
    // gotoxy::@2
  __b2:
    // __conio.cursor_x = (x>=__conio.width)?__conio.width:x
    // [65] *((char *)&__conio+$d) = gotoxy::$3 -- _deref_pbuc1=vbuz1 
    lda.z __3
    sta __conio+$d
    // (y>=__conio.height)?__conio.height:y
    // [66] if(gotoxy::y#2>=*((char *)&__conio+5)) goto gotoxy::@3 -- vbuz1_ge__deref_pbuc1_then_la1 
    lda.z y
    cmp __conio+5
    bcs __b3
    // gotoxy::@4
    // [67] gotoxy::$14 = gotoxy::y#2 -- vbuz1=vbuz2 
    sta.z __14
    // [68] phi from gotoxy::@3 gotoxy::@4 to gotoxy::@5 [phi:gotoxy::@3/gotoxy::@4->gotoxy::@5]
    // [68] phi gotoxy::$7 = gotoxy::$6 [phi:gotoxy::@3/gotoxy::@4->gotoxy::@5#0] -- register_copy 
    // gotoxy::@5
  __b5:
    // __conio.cursor_y = (y>=__conio.height)?__conio.height:y
    // [69] *((char *)&__conio+$e) = gotoxy::$7 -- _deref_pbuc1=vbuz1 
    lda.z __7
    sta __conio+$e
    // __conio.cursor_x << 1
    // [70] gotoxy::$8 = *((char *)&__conio+$d) << 1 -- vbuz1=_deref_pbuc1_rol_1 
    lda __conio+$d
    asl
    sta.z __8
    // __conio.offsets[y] + __conio.cursor_x << 1
    // [71] gotoxy::$10 = gotoxy::y#2 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __10
    // [72] gotoxy::$9 = ((unsigned int *)&__conio+$15)[gotoxy::$10] + gotoxy::$8 -- vwuz1=pwuc1_derefidx_vbuz2_plus_vbuz3 
    ldy.z __10
    clc
    adc __conio+$15,y
    sta.z __9
    lda __conio+$15+1,y
    adc #0
    sta.z __9+1
    // __conio.offset = __conio.offsets[y] + __conio.cursor_x << 1
    // [73] *((unsigned int *)&__conio+$13) = gotoxy::$9 -- _deref_pwuc1=vwuz1 
    lda.z __9
    sta __conio+$13
    lda.z __9+1
    sta __conio+$13+1
    // gotoxy::@return
    // }
    // [74] return 
    rts
    // gotoxy::@3
  __b3:
    // (y>=__conio.height)?__conio.height:y
    // [75] gotoxy::$6 = *((char *)&__conio+5) -- vbuz1=_deref_pbuc1 
    lda __conio+5
    sta.z __6
    jmp __b5
}
  // clrscr
// clears the screen and moves the cursor to the upper left-hand corner of the screen.
clrscr: {
    .label __0 = $36
    .label __1 = $32
    .label __2 = $33
    .label line_text = $2c
    .label l = $22
    .label ch = $2c
    .label c = $23
    // unsigned int line_text = __conio.mapbase_offset
    // [76] clrscr::line_text#0 = *((unsigned int *)&__conio+1) -- vwuz1=_deref_pwuc1 
    lda __conio+1
    sta.z line_text
    lda __conio+1+1
    sta.z line_text+1
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [77] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // __conio.mapbase_bank | VERA_INC_1
    // [78] clrscr::$0 = *((char *)&__conio+3) | VERA_INC_1 -- vbuz1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+3
    sta.z __0
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [79] *VERA_ADDRX_H = clrscr::$0 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_H
    // unsigned char l = __conio.mapheight
    // [80] clrscr::l#0 = *((char *)&__conio+7) -- vbuz1=_deref_pbuc1 
    lda __conio+7
    sta.z l
    // [81] phi from clrscr clrscr::@3 to clrscr::@1 [phi:clrscr/clrscr::@3->clrscr::@1]
    // [81] phi clrscr::l#4 = clrscr::l#0 [phi:clrscr/clrscr::@3->clrscr::@1#0] -- register_copy 
    // [81] phi clrscr::ch#0 = clrscr::line_text#0 [phi:clrscr/clrscr::@3->clrscr::@1#1] -- register_copy 
    // clrscr::@1
  __b1:
    // BYTE0(ch)
    // [82] clrscr::$1 = byte0  clrscr::ch#0 -- vbuz1=_byte0_vwuz2 
    lda.z ch
    sta.z __1
    // *VERA_ADDRX_L = BYTE0(ch)
    // [83] *VERA_ADDRX_L = clrscr::$1 -- _deref_pbuc1=vbuz1 
    // Set address
    sta VERA_ADDRX_L
    // BYTE1(ch)
    // [84] clrscr::$2 = byte1  clrscr::ch#0 -- vbuz1=_byte1_vwuz2 
    lda.z ch+1
    sta.z __2
    // *VERA_ADDRX_M = BYTE1(ch)
    // [85] *VERA_ADDRX_M = clrscr::$2 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // unsigned char c = __conio.mapwidth
    // [86] clrscr::c#0 = *((char *)&__conio+6) -- vbuz1=_deref_pbuc1 
    lda __conio+6
    sta.z c
    // [87] phi from clrscr::@1 clrscr::@2 to clrscr::@2 [phi:clrscr::@1/clrscr::@2->clrscr::@2]
    // [87] phi clrscr::c#2 = clrscr::c#0 [phi:clrscr::@1/clrscr::@2->clrscr::@2#0] -- register_copy 
    // clrscr::@2
  __b2:
    // *VERA_DATA0 = ' '
    // [88] *VERA_DATA0 = ' ' -- _deref_pbuc1=vbuc2 
    lda #' '
    sta VERA_DATA0
    // *VERA_DATA0 = __conio.color
    // [89] *VERA_DATA0 = *((char *)&__conio+$b) -- _deref_pbuc1=_deref_pbuc2 
    lda __conio+$b
    sta VERA_DATA0
    // c--;
    // [90] clrscr::c#1 = -- clrscr::c#2 -- vbuz1=_dec_vbuz1 
    dec.z c
    // while(c)
    // [91] if(0!=clrscr::c#1) goto clrscr::@2 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b2
    // clrscr::@3
    // line_text += __conio.rowskip
    // [92] clrscr::line_text#1 = clrscr::ch#0 + *((unsigned int *)&__conio+8) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z line_text
    adc __conio+8
    sta.z line_text
    lda.z line_text+1
    adc __conio+8+1
    sta.z line_text+1
    // l--;
    // [93] clrscr::l#1 = -- clrscr::l#4 -- vbuz1=_dec_vbuz1 
    dec.z l
    // while(l)
    // [94] if(0!=clrscr::l#1) goto clrscr::@1 -- 0_neq_vbuz1_then_la1 
    lda.z l
    bne __b1
    // clrscr::@4
    // __conio.cursor_x = 0
    // [95] *((char *)&__conio+$d) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+$d
    // __conio.cursor_y = 0
    // [96] *((char *)&__conio+$e) = 0 -- _deref_pbuc1=vbuc2 
    sta __conio+$e
    // __conio.offset = __conio.mapbase_offset
    // [97] *((unsigned int *)&__conio+$13) = *((unsigned int *)&__conio+1) -- _deref_pwuc1=_deref_pwuc2 
    lda __conio+1
    sta __conio+$13
    lda __conio+1+1
    sta __conio+$13+1
    // clrscr::@return
    // }
    // [98] return 
    rts
}
  // sprite_image_cache_vram
// unsigned int sprite_image_cache_vram(char fe_sprite_index, char fe_sprite_image_index)
sprite_image_cache_vram: {
    .const bank_push_set_bram1_bank = 1
    .label vram_index2 = $22
    .label vram_index = $22
    // sprite_image_cache_vram::bank_push_set_bram1
    // asm
    // asm { lda$00 pha  }
    lda.z 0
    pha
    // BRAM = bank
    // [101] BRAM = sprite_image_cache_vram::bank_push_set_bram1_bank#0 -- vbuz1=vbuc1 
    lda #bank_push_set_bram1_bank
    sta.z BRAM
    // sprite_image_cache_vram::bank_pull_bram1
    // asm
    // asm { pla sta$00  }
    pla
    sta.z 0
    // [103] phi from sprite_image_cache_vram::bank_pull_bram1 to sprite_image_cache_vram::@2 [phi:sprite_image_cache_vram::bank_pull_bram1->sprite_image_cache_vram::@2]
    // sprite_image_cache_vram::@2
    // __export lru_cache_index_t vram_index2 = lru_cache_index_get(&sprite_cache_vram, 2)
    // [104] call lru_cache_index_get
  // We check if there is a cache hit?
    // [147] phi from sprite_image_cache_vram::@2 to lru_cache_index_get [phi:sprite_image_cache_vram::@2->lru_cache_index_get]
    // [147] phi lru_cache_index_get::key#2 = 2 [phi:sprite_image_cache_vram::@2->lru_cache_index_get#0] -- vwuz1=vbuc1 
    lda #<2
    sta.z lru_cache_index_get.key
    lda #>2
    sta.z lru_cache_index_get.key+1
    jsr lru_cache_index_get
    // __export lru_cache_index_t vram_index2 = lru_cache_index_get(&sprite_cache_vram, 2)
    // [105] lru_cache_index_get::return#3 = lru_cache_index_get::return#2
    // sprite_image_cache_vram::@3
    // [106] sprite_image_cache_vram::vram_index2#0 = lru_cache_index_get::return#3
    // lru_cache_index_t vram_index = lru_cache_index_get(&sprite_cache_vram, 1)
    // [107] call lru_cache_index_get
    // [147] phi from sprite_image_cache_vram::@3 to lru_cache_index_get [phi:sprite_image_cache_vram::@3->lru_cache_index_get]
    // [147] phi lru_cache_index_get::key#2 = 1 [phi:sprite_image_cache_vram::@3->lru_cache_index_get#0] -- vwuz1=vbuc1 
    lda #<1
    sta.z lru_cache_index_get.key
    lda #>1
    sta.z lru_cache_index_get.key+1
    jsr lru_cache_index_get
    // lru_cache_index_t vram_index = lru_cache_index_get(&sprite_cache_vram, 1)
    // [108] lru_cache_index_get::return#4 = lru_cache_index_get::return#2
    // sprite_image_cache_vram::@4
    // [109] sprite_image_cache_vram::vram_index#0 = lru_cache_index_get::return#4
    // if (vram_index != 0xFF)
    // [110] if(sprite_image_cache_vram::vram_index#0==$ff) goto sprite_image_cache_vram::@return -- vbuz1_eq_vbuc1_then_la1 
    lda #$ff
    cmp.z vram_index
    // [111] phi from sprite_image_cache_vram::@4 to sprite_image_cache_vram::@1 [phi:sprite_image_cache_vram::@4->sprite_image_cache_vram::@1]
    // sprite_image_cache_vram::@1
    // sprite_image_cache_vram::@return
    // }
    // [112] return 
    rts
}
  // screenlayer
// --- layer management in VERA ---
// void screenlayer(char layer, __zp($2e) char mapbase, __zp($2b) char config)
screenlayer: {
    .label __0 = $31
    .label __1 = $2e
    .label __2 = $2f
    .label __5 = $2b
    .label __6 = $2b
    .label __7 = $2a
    .label __8 = $2a
    .label __9 = $28
    .label __10 = $28
    .label __11 = $28
    .label __12 = $29
    .label __13 = $29
    .label __14 = $29
    .label __16 = $2a
    .label __17 = $25
    .label __18 = $28
    .label __19 = $29
    .label mapbase_offset = $26
    .label y = $24
    .label mapbase = $2e
    .label config = $2b
    // __mem char vera_dc_hscale_temp = *VERA_DC_HSCALE
    // [113] screenlayer::vera_dc_hscale_temp#0 = *VERA_DC_HSCALE -- vbum1=_deref_pbuc1 
    lda VERA_DC_HSCALE
    sta vera_dc_hscale_temp
    // __mem char vera_dc_vscale_temp = *VERA_DC_VSCALE
    // [114] screenlayer::vera_dc_vscale_temp#0 = *VERA_DC_VSCALE -- vbum1=_deref_pbuc1 
    lda VERA_DC_VSCALE
    sta vera_dc_vscale_temp
    // __conio.layer = 0
    // [115] *((char *)&__conio) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio
    // mapbase >> 7
    // [116] screenlayer::$0 = screenlayer::mapbase#0 >> 7 -- vbuz1=vbuz2_ror_7 
    lda.z mapbase
    rol
    rol
    and #1
    sta.z __0
    // __conio.mapbase_bank = mapbase >> 7
    // [117] *((char *)&__conio+3) = screenlayer::$0 -- _deref_pbuc1=vbuz1 
    sta __conio+3
    // (mapbase)<<1
    // [118] screenlayer::$1 = screenlayer::mapbase#0 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __1
    // MAKEWORD((mapbase)<<1,0)
    // [119] screenlayer::$2 = screenlayer::$1 w= 0 -- vwuz1=vbuz2_word_vbuc1 
    lda #0
    ldy.z __1
    sty.z __2+1
    sta.z __2
    // __conio.mapbase_offset = MAKEWORD((mapbase)<<1,0)
    // [120] *((unsigned int *)&__conio+1) = screenlayer::$2 -- _deref_pwuc1=vwuz1 
    sta __conio+1
    tya
    sta __conio+1+1
    // config & VERA_LAYER_WIDTH_MASK
    // [121] screenlayer::$7 = screenlayer::config#0 & VERA_LAYER_WIDTH_MASK -- vbuz1=vbuz2_band_vbuc1 
    lda #VERA_LAYER_WIDTH_MASK
    and.z config
    sta.z __7
    // (config & VERA_LAYER_WIDTH_MASK) >> 4
    // [122] screenlayer::$8 = screenlayer::$7 >> 4 -- vbuz1=vbuz1_ror_4 
    lda.z __8
    lsr
    lsr
    lsr
    lsr
    sta.z __8
    // __conio.mapwidth = VERA_LAYER_DIM[ (config & VERA_LAYER_WIDTH_MASK) >> 4]
    // [123] *((char *)&__conio+6) = screenlayer::VERA_LAYER_DIM[screenlayer::$8] -- _deref_pbuc1=pbuc2_derefidx_vbuz1 
    tay
    lda VERA_LAYER_DIM,y
    sta __conio+6
    // config & VERA_LAYER_HEIGHT_MASK
    // [124] screenlayer::$5 = screenlayer::config#0 & VERA_LAYER_HEIGHT_MASK -- vbuz1=vbuz1_band_vbuc1 
    lda #VERA_LAYER_HEIGHT_MASK
    and.z __5
    sta.z __5
    // (config & VERA_LAYER_HEIGHT_MASK) >> 6
    // [125] screenlayer::$6 = screenlayer::$5 >> 6 -- vbuz1=vbuz1_ror_6 
    lda.z __6
    rol
    rol
    rol
    and #3
    sta.z __6
    // __conio.mapheight = VERA_LAYER_DIM[ (config & VERA_LAYER_HEIGHT_MASK) >> 6]
    // [126] *((char *)&__conio+7) = screenlayer::VERA_LAYER_DIM[screenlayer::$6] -- _deref_pbuc1=pbuc2_derefidx_vbuz1 
    tay
    lda VERA_LAYER_DIM,y
    sta __conio+7
    // __conio.rowskip = VERA_LAYER_SKIP[(config & VERA_LAYER_WIDTH_MASK)>>4]
    // [127] screenlayer::$16 = screenlayer::$8 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __16
    // [128] *((unsigned int *)&__conio+8) = screenlayer::VERA_LAYER_SKIP[screenlayer::$16] -- _deref_pwuc1=pwuc2_derefidx_vbuz1 
    // __conio.rowshift = ((config & VERA_LAYER_WIDTH_MASK)>>4)+6;
    ldy.z __16
    lda VERA_LAYER_SKIP,y
    sta __conio+8
    lda VERA_LAYER_SKIP+1,y
    sta __conio+8+1
    // vera_dc_hscale_temp == 0x80
    // [129] screenlayer::$9 = screenlayer::vera_dc_hscale_temp#0 == $80 -- vboz1=vbum2_eq_vbuc1 
    lda vera_dc_hscale_temp
    eor #$80
    beq !+
    lda #1
  !:
    eor #1
    sta.z __9
    // 40 << (char)(vera_dc_hscale_temp == 0x80)
    // [130] screenlayer::$18 = (char)screenlayer::$9
    // [131] screenlayer::$10 = $28 << screenlayer::$18 -- vbuz1=vbuc1_rol_vbuz1 
    lda #$28
    ldy.z __10
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta.z __10
    // (40 << (char)(vera_dc_hscale_temp == 0x80))-1
    // [132] screenlayer::$11 = screenlayer::$10 - 1 -- vbuz1=vbuz1_minus_1 
    dec.z __11
    // __conio.width = (40 << (char)(vera_dc_hscale_temp == 0x80))-1
    // [133] *((char *)&__conio+4) = screenlayer::$11 -- _deref_pbuc1=vbuz1 
    lda.z __11
    sta __conio+4
    // vera_dc_vscale_temp == 0x80
    // [134] screenlayer::$12 = screenlayer::vera_dc_vscale_temp#0 == $80 -- vboz1=vbum2_eq_vbuc1 
    lda vera_dc_vscale_temp
    eor #$80
    beq !+
    lda #1
  !:
    eor #1
    sta.z __12
    // 30 << (char)(vera_dc_vscale_temp == 0x80)
    // [135] screenlayer::$19 = (char)screenlayer::$12
    // [136] screenlayer::$13 = $1e << screenlayer::$19 -- vbuz1=vbuc1_rol_vbuz1 
    lda #$1e
    ldy.z __13
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta.z __13
    // (30 << (char)(vera_dc_vscale_temp == 0x80))-1
    // [137] screenlayer::$14 = screenlayer::$13 - 1 -- vbuz1=vbuz1_minus_1 
    dec.z __14
    // __conio.height = (30 << (char)(vera_dc_vscale_temp == 0x80))-1
    // [138] *((char *)&__conio+5) = screenlayer::$14 -- _deref_pbuc1=vbuz1 
    lda.z __14
    sta __conio+5
    // unsigned int mapbase_offset = __conio.mapbase_offset
    // [139] screenlayer::mapbase_offset#0 = *((unsigned int *)&__conio+1) -- vwuz1=_deref_pwuc1 
    lda __conio+1
    sta.z mapbase_offset
    lda __conio+1+1
    sta.z mapbase_offset+1
    // [140] phi from screenlayer to screenlayer::@1 [phi:screenlayer->screenlayer::@1]
    // [140] phi screenlayer::mapbase_offset#2 = screenlayer::mapbase_offset#0 [phi:screenlayer->screenlayer::@1#0] -- register_copy 
    // [140] phi screenlayer::y#2 = 0 [phi:screenlayer->screenlayer::@1#1] -- vbuz1=vbuc1 
    lda #0
    sta.z y
    // screenlayer::@1
  __b1:
    // for(register char y=0; y<__conio.height; y++)
    // [141] if(screenlayer::y#2<*((char *)&__conio+5)) goto screenlayer::@2 -- vbuz1_lt__deref_pbuc1_then_la1 
    lda.z y
    cmp __conio+5
    bcc __b2
    // screenlayer::@return
    // }
    // [142] return 
    rts
    // screenlayer::@2
  __b2:
    // __conio.offsets[y] = mapbase_offset
    // [143] screenlayer::$17 = screenlayer::y#2 << 1 -- vbuz1=vbuz2_rol_1 
    lda.z y
    asl
    sta.z __17
    // [144] ((unsigned int *)&__conio+$15)[screenlayer::$17] = screenlayer::mapbase_offset#2 -- pwuc1_derefidx_vbuz1=vwuz2 
    tay
    lda.z mapbase_offset
    sta __conio+$15,y
    lda.z mapbase_offset+1
    sta __conio+$15+1,y
    // mapbase_offset += __conio.rowskip
    // [145] screenlayer::mapbase_offset#1 = screenlayer::mapbase_offset#2 + *((unsigned int *)&__conio+8) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z mapbase_offset
    adc __conio+8
    sta.z mapbase_offset
    lda.z mapbase_offset+1
    adc __conio+8+1
    sta.z mapbase_offset+1
    // for(register char y=0; y<__conio.height; y++)
    // [146] screenlayer::y#1 = ++ screenlayer::y#2 -- vbuz1=_inc_vbuz1 
    inc.z y
    // [140] phi from screenlayer::@2 to screenlayer::@1 [phi:screenlayer::@2->screenlayer::@1]
    // [140] phi screenlayer::mapbase_offset#2 = screenlayer::mapbase_offset#1 [phi:screenlayer::@2->screenlayer::@1#0] -- register_copy 
    // [140] phi screenlayer::y#2 = screenlayer::y#1 [phi:screenlayer::@2->screenlayer::@1#1] -- register_copy 
    jmp __b1
  .segment Data
    VERA_LAYER_DIM: .byte $1f, $3f, $7f, $ff
    VERA_LAYER_SKIP: .word $40, $80, $100, $200
    vera_dc_hscale_temp: .byte 0
    vera_dc_vscale_temp: .byte 0
}
.segment Code
  // lru_cache_index_get
// __zp($22) char lru_cache_index_get(struct $1 *lru_cache, __zp($2c) unsigned int key)
lru_cache_index_get: {
    .label __4 = $23
    .label index = $22
    .label return = $22
    .label key = $2c
    // lru_cache_index_t index = lru_cache_hash(key)
    // [148] lru_cache_hash::key#0 = lru_cache_index_get::key#2
    // [149] call lru_cache_hash
    jsr lru_cache_hash
    // [150] lru_cache_hash::return#2 = lru_cache_hash::return#0
    // lru_cache_index_get::@4
  __b4:
    // [151] lru_cache_index_get::index#0 = lru_cache_hash::return#2
    // [152] phi from lru_cache_index_get::@3 lru_cache_index_get::@4 to lru_cache_index_get::@1 [phi:lru_cache_index_get::@3/lru_cache_index_get::@4->lru_cache_index_get::@1]
    // [152] phi lru_cache_index_get::index#2 = lru_cache_index_get::index#1 [phi:lru_cache_index_get::@3/lru_cache_index_get::@4->lru_cache_index_get::@1#0] -- register_copy 
  // Search till index == 0xFF, following the links.
    // lru_cache_index_get::@1
    // while (index != LRU_CACHE_INDEX_NULL)
    // [153] if(lru_cache_index_get::index#2!=$ff) goto lru_cache_index_get::@2 -- vbuz1_neq_vbuc1_then_la1 
    lda #$ff
    cmp.z index
    bne __b2
    // [156] phi from lru_cache_index_get::@1 to lru_cache_index_get::@return [phi:lru_cache_index_get::@1->lru_cache_index_get::@return]
    // [156] phi lru_cache_index_get::return#2 = $ff [phi:lru_cache_index_get::@1->lru_cache_index_get::@return#0] -- vbuz1=vbuc1 
    sta.z return
    rts
    // lru_cache_index_get::@2
  __b2:
    // lru_cache->key[index] == key
    // [154] lru_cache_index_get::$4 = lru_cache_index_get::index#2 << 1 -- vbuz1=vbuz2_rol_1 
    lda.z index
    asl
    sta.z __4
    // if (lru_cache->key[index] == key)
    // [155] if(((unsigned int *)&sprite_cache_vram)[lru_cache_index_get::$4]!=lru_cache_index_get::key#2) goto lru_cache_index_get::@3 -- pwuc1_derefidx_vbuz1_neq_vwuz2_then_la1 
    tay
    lda.z key+1
    cmp sprite_cache_vram+1,y
    bne __b3
    lda.z key
    cmp sprite_cache_vram,y
    bne __b3
    // [156] phi from lru_cache_index_get::@2 to lru_cache_index_get::@return [phi:lru_cache_index_get::@2->lru_cache_index_get::@return]
    // [156] phi lru_cache_index_get::return#2 = lru_cache_index_get::index#2 [phi:lru_cache_index_get::@2->lru_cache_index_get::@return#0] -- register_copy 
    // lru_cache_index_get::@return
    // }
    // [157] return 
    rts
    // lru_cache_index_get::@3
  __b3:
    // index = lru_cache->link[index]
    // [158] lru_cache_index_get::index#1 = ((char *)&sprite_cache_vram+$300)[lru_cache_index_get::index#2] -- vbuz1=pbuc1_derefidx_vbuz1 
    ldy.z index
    lda sprite_cache_vram+$300,y
    sta.z index
    jmp __b4
}
  // lru_cache_hash
// __mem unsigned char lru_cache_seed;
// __zp($22) char lru_cache_hash(__zp($2c) unsigned int key)
lru_cache_hash: {
    .label return = $22
    .label key = $2c
    // return (char)key;
    // [159] lru_cache_hash::return#0 = (char)lru_cache_hash::key#0 -- vbuz1=_byte_vwuz2 
    lda.z key
    sta.z return
    // lru_cache_hash::@return
    // }
    // [160] return 
    rts
}
  // File Data
.segment Data
  sprite_bram_handles: .fill 2*$200, 0
  __conio: .fill SIZEOF_STRUCT___0, 0
  sprite_cache_vram: .fill SIZEOF_STRUCT___1, 0
