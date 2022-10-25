  // File Comments
/// @file
/// Provides provide console input/output
///
/// Implements similar functions as conio.h from CC65 for compatibility
/// See https://github.com/cc65/cc65/blob/master/include/conio.h
//
/// Currently CX16/C64/PLUS4/VIC20 platforms are supported
  // Upstart
.cpu _65c02
  // Commodore 64 PRG executable file
.file [name="cx16-mouse - close only.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(__start)
  // Global Constants & labels
  .const WHITE = 1
  .const BLUE = 6
  .const VERA_INC_1 = $10
  .const VERA_ADDRSEL = 1
  .const VERA_LAYER_WIDTH_128 = $20
  .const VERA_LAYER_WIDTH_MASK = $30
  .const VERA_LAYER_HEIGHT_64 = $40
  .const VERA_LAYER_HEIGHT_MASK = $c0
  .const VERA_LAYER_COLOR_DEPTH_MASK = 3
  .const VERA_LAYER_CONFIG_256C = 8
  .const VERA_TILEBASE_WIDTH_MASK = 1
  .const VERA_TILEBASE_HEIGHT_MASK = 2
  .const VERA_LAYER_TILEBASE_MASK = $fc
  // Common CBM Kernal Routines
  .const CBM_SETNAM = $ffbd
  ///< Set the name of a file.
  .const CBM_SETLFS = $ffba
  ///< Set the logical file.
  .const CBM_OPEN = $ffc0
  ///< Read a character from the current channel for input.
  .const CBM_CLOSE = $ffc3
  ///< Load a logical file.
  .const CBM_PLOT = $fff0
  .const OFFSET_STRUCT_CX16_CONIO_WIDTH = 4
  .const OFFSET_STRUCT_CX16_CONIO_HEIGHT = 5
  // CX16 CBM Mouse Routines
  .const CX16_MOUSE_CONFIG = $ff68
  // ISR routine to scan the mouse state.
  .const CX16_MOUSE_GET = $ff6b
  .const OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS = 1
  .const OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET = 1
  .const OFFSET_STRUCT_CX16_CONIO_COLOR = $e
  .const OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT = 8
  .const OFFSET_STRUCT_CX16_CONIO_MAPWIDTH = 6
  .const OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK = 3
  .const OFFSET_STRUCT_CX16_CONIO_CURSOR_X = $f
  .const OFFSET_STRUCT_CX16_CONIO_CURSOR_Y = $10
  .const OFFSET_STRUCT_CX16_CONIO_LINE = $11
  .const OFFSET_STRUCT_CX16_CONIO_ROWSKIP = $b
  .const OFFSET_STRUCT_CX16_CONIO_ROWSHIFT = $a
  .const OFFSET_STRUCT_CX16_CONIO_SCROLL = $13
  .const OFFSET_STRUCT_CX16_CONIO_CURSOR = $d
  .const STACK_BASE = $103
  .const SIZEOF_STRUCT_CX16_CONIO = $15
  .const SIZEOF_STRUCT_PRINTF_BUFFER_NUMBER = $c
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
  /// $9F36	L1_TILEBASE	    Layer 1 Tile Base
  /// Bit 2-7: Tile Base Address (16:11)
  /// Bit 1:   Tile Height (0:8 pixels, 1:16 pixels)
  /// Bit 0:	Tile Width (0:8 pixels, 1:16 pixels)
  .label VERA_L1_TILEBASE = $9f36
  .label BRAM = 0
.segment Code
  // __start
__start: {
    // __start::__init1
    // __address(0) char BRAM
    // [1] BRAM = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z BRAM
    // #pragma constructor_for(conio_x16_init, cputc, clrscr, cscroll)
    // [2] call conio_x16_init
    jsr conio_x16_init
    // [3] phi from __start::__init1 to __start::@1 [phi:__start::__init1->__start::@1]
    // __start::@1
    // [4] call main
    // [78] phi from __start::@1 to main [phi:__start::@1->main]
    jsr main
    // __start::@return
    // [5] return 
    rts
}
  // conio_x16_init
// Set initial cursor position
conio_x16_init: {
    // Position cursor at current line
    .label BASIC_CURSOR_LINE = $d6
    .label __8 = $53
    .label __9 = $67
    .label __10 = $53
    .label __11 = $68
    .label line = $72
    // char line = *BASIC_CURSOR_LINE
    // [6] conio_x16_init::line#0 = *conio_x16_init::BASIC_CURSOR_LINE -- vbuz1=_deref_pbuc1 
    lda.z BASIC_CURSOR_LINE
    sta.z line
    // *VERA_L1_CONFIG &= ~VERA_LAYER_COLOR_DEPTH_MASK
    // [7] *VERA_L1_CONFIG = *VERA_L1_CONFIG & ~VERA_LAYER_COLOR_DEPTH_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    // color depth
    lda #VERA_LAYER_COLOR_DEPTH_MASK^$ff
    and VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG |= VERA_LAYER_COLOR_DEPTH_1BPP
    // [8] *VERA_L1_CONFIG = *VERA_L1_CONFIG -- _deref_pbuc1=_deref_pbuc1 
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG &= ~VERA_LAYER_WIDTH_MASK
    // [9] *VERA_L1_CONFIG = *VERA_L1_CONFIG & ~VERA_LAYER_WIDTH_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    // map width
    lda #VERA_LAYER_WIDTH_MASK^$ff
    and VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG |= VERA_LAYER_WIDTH_128
    // [10] *VERA_L1_CONFIG = *VERA_L1_CONFIG | VERA_LAYER_WIDTH_128 -- _deref_pbuc1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_LAYER_WIDTH_128
    ora VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG &= ~VERA_LAYER_HEIGHT_MASK
    // [11] *VERA_L1_CONFIG = *VERA_L1_CONFIG & ~VERA_LAYER_HEIGHT_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    // map height
    lda #VERA_LAYER_HEIGHT_MASK^$ff
    and VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG |= VERA_LAYER_HEIGHT_64
    // [12] *VERA_L1_CONFIG = *VERA_L1_CONFIG | VERA_LAYER_HEIGHT_64 -- _deref_pbuc1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_LAYER_HEIGHT_64
    ora VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_MAPBASE = ((1 << 7) | BYTE1((word)0xB000)>>1)
    // [13] *VERA_L1_MAPBASE = 1<<7|byte1 $b000>>1 -- _deref_pbuc1=vbuc2 
    // map base
    lda #1<<7|(>$b000)>>1
    sta VERA_L1_MAPBASE
    // *VERA_L1_TILEBASE &= ~VERA_LAYER_TILEBASE_MASK
    // [14] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE & ~VERA_LAYER_TILEBASE_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_TILEBASE_MASK^$ff
    and VERA_L1_TILEBASE
    sta VERA_L1_TILEBASE
    // *VERA_L1_TILEBASE |= ((1 << 7) | BYTE1((word)0xF000)>>1)
    // [15] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE | 1<<7|byte1 $f000>>1 -- _deref_pbuc1=_deref_pbuc1_bor_vbuc2 
    lda #1<<7|(>$f000)>>1
    ora VERA_L1_TILEBASE
    sta VERA_L1_TILEBASE
    // *VERA_L1_TILEBASE &= ~VERA_TILEBASE_WIDTH_MASK
    // [16] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE & ~VERA_TILEBASE_WIDTH_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_TILEBASE_WIDTH_MASK^$ff
    and VERA_L1_TILEBASE
    sta VERA_L1_TILEBASE
    // *VERA_L1_TILEBASE |= VERA_TILEBASE_WIDTH_8
    // [17] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE -- _deref_pbuc1=_deref_pbuc1 
    sta VERA_L1_TILEBASE
    // *VERA_L1_TILEBASE &= ~VERA_TILEBASE_HEIGHT_MASK
    // [18] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE & ~VERA_TILEBASE_HEIGHT_MASK -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_TILEBASE_HEIGHT_MASK^$ff
    and VERA_L1_TILEBASE
    sta VERA_L1_TILEBASE
    // *VERA_L1_TILEBASE |= VERA_TILEBASE_HEIGHT_8
    // [19] *VERA_L1_TILEBASE = *VERA_L1_TILEBASE -- _deref_pbuc1=_deref_pbuc1 
    sta VERA_L1_TILEBASE
    // *VERA_L1_CONFIG &= ~VERA_LAYER_CONFIG_256C
    // [20] *VERA_L1_CONFIG = *VERA_L1_CONFIG & ~VERA_LAYER_CONFIG_256C -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_CONFIG_256C^$ff
    and VERA_L1_CONFIG
    sta VERA_L1_CONFIG
    // *VERA_L1_CONFIG |= VERA_LAYER_CONFIG_16C
    // [21] *VERA_L1_CONFIG = *VERA_L1_CONFIG -- _deref_pbuc1=_deref_pbuc1 
    sta VERA_L1_CONFIG
    // screensize(&__conio.width, &__conio.height)
    // [22] call screensize
    jsr screensize
    // [23] phi from conio_x16_init to conio_x16_init::@3 [phi:conio_x16_init->conio_x16_init::@3]
    // conio_x16_init::@3
    // screenlayer1()
    // [24] call screenlayer1
    // TODO, this should become a ROM call for the CX16.
    jsr screenlayer1
    // [25] phi from conio_x16_init::@3 to conio_x16_init::@4 [phi:conio_x16_init::@3->conio_x16_init::@4]
    // conio_x16_init::@4
    // textcolor(WHITE)
    // [26] call textcolor
    jsr textcolor
    // [27] phi from conio_x16_init::@4 to conio_x16_init::@5 [phi:conio_x16_init::@4->conio_x16_init::@5]
    // conio_x16_init::@5
    // bgcolor(BLUE)
    // [28] call bgcolor
    jsr bgcolor
    // [29] phi from conio_x16_init::@5 to conio_x16_init::@6 [phi:conio_x16_init::@5->conio_x16_init::@6]
    // conio_x16_init::@6
    // cursor(0)
    // [30] call cursor
    jsr cursor
    // conio_x16_init::@7
    // if(line>=__conio.height)
    // [31] if(conio_x16_init::line#0<*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT)) goto conio_x16_init::@1 -- vbuz1_lt__deref_pbuc1_then_la1 
    lda.z line
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    // [32] phi from conio_x16_init::@7 to conio_x16_init::@2 [phi:conio_x16_init::@7->conio_x16_init::@2]
    // conio_x16_init::@2
    // [33] phi from conio_x16_init::@2 conio_x16_init::@7 to conio_x16_init::@1 [phi:conio_x16_init::@2/conio_x16_init::@7->conio_x16_init::@1]
    // conio_x16_init::@1
    // cbm_k_plot_get()
    // [34] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [35] cbm_k_plot_get::return#2 = cbm_k_plot_get::return#0
    // conio_x16_init::@8
    // [36] conio_x16_init::$8 = cbm_k_plot_get::return#2
    // BYTE1(cbm_k_plot_get())
    // [37] conio_x16_init::$9 = byte1  conio_x16_init::$8 -- vbuz1=_byte1_vwuz2 
    lda.z __8+1
    sta.z __9
    // __conio.cursor_x = BYTE1(cbm_k_plot_get())
    // [38] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = conio_x16_init::$9 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // cbm_k_plot_get()
    // [39] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [40] cbm_k_plot_get::return#3 = cbm_k_plot_get::return#0
    // conio_x16_init::@9
    // [41] conio_x16_init::$10 = cbm_k_plot_get::return#3
    // BYTE0(cbm_k_plot_get())
    // [42] conio_x16_init::$11 = byte0  conio_x16_init::$10 -- vbuz1=_byte0_vwuz2 
    lda.z __10
    sta.z __11
    // __conio.cursor_y = BYTE0(cbm_k_plot_get())
    // [43] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) = conio_x16_init::$11 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    // gotoxy(__conio.cursor_x, __conio.cursor_y)
    // [44] gotoxy::x#1 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) -- vbuz1=_deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    sta.z gotoxy.x
    // [45] gotoxy::y#1 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) -- vbuz1=_deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    sta.z gotoxy.y
    // [46] call gotoxy
    // [223] phi from conio_x16_init::@9 to gotoxy [phi:conio_x16_init::@9->gotoxy]
    // [223] phi gotoxy::x#10 = gotoxy::x#1 [phi:conio_x16_init::@9->gotoxy#0] -- register_copy 
    // [223] phi gotoxy::y#7 = gotoxy::y#1 [phi:conio_x16_init::@9->gotoxy#1] -- register_copy 
    jsr gotoxy
    // conio_x16_init::@return
    // }
    // [47] return 
    rts
}
  // cputc
// Output one character at the current cursor position
// Moves the cursor forward. Scrolls the entire screen if needed
// void cputc(__zp($32) char c)
cputc: {
    .const OFFSET_STACK_C = 0
    .label __1 = $3f
    .label __3 = $40
    .label __4 = $41
    .label __5 = $42
    .label __14 = $44
    .label c = $32
    .label color = $4b
    .label mapbase_offset = $26
    .label mapwidth = $4c
    .label conio_addr = $26
    .label scroll_enable = $43
    // [48] cputc::c#0 = stackidx(char,cputc::OFFSET_STACK_C) -- vbuz1=_stackidxbyte_vbuc1 
    tsx
    lda STACK_BASE+OFFSET_STACK_C,x
    sta.z c
    // char color = __conio.color
    // [49] cputc::color#0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) -- vbuz1=_deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    sta.z color
    // unsigned int mapbase_offset = __conio.mapbase_offset
    // [50] cputc::mapbase_offset#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET
    sta.z mapbase_offset
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET+1
    sta.z mapbase_offset+1
    // unsigned int mapwidth = __conio.mapwidth
    // [51] cputc::mapwidth#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH
    sta.z mapwidth
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH+1
    sta.z mapwidth+1
    // unsigned int conio_addr = mapbase_offset + __conio.line
    // [52] cputc::conio_addr#0 = cputc::mapbase_offset#0 + *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z conio_addr
    adc __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    sta.z conio_addr
    lda.z conio_addr+1
    adc __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    sta.z conio_addr+1
    // __conio.cursor_x << 1
    // [53] cputc::$1 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) << 1 -- vbuz1=_deref_pbuc1_rol_1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    asl
    sta.z __1
    // conio_addr += __conio.cursor_x << 1
    // [54] cputc::conio_addr#1 = cputc::conio_addr#0 + cputc::$1 -- vwuz1=vwuz1_plus_vbuz2 
    clc
    adc.z conio_addr
    sta.z conio_addr
    bcc !+
    inc.z conio_addr+1
  !:
    // if(c=='\n')
    // [55] if(cputc::c#0==' ') goto cputc::@1 -- vbuz1_eq_vbuc1_then_la1 
    lda #'\n'
    cmp.z c
    beq __b1
    // cputc::@2
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [56] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(conio_addr)
    // [57] cputc::$3 = byte0  cputc::conio_addr#1 -- vbuz1=_byte0_vwuz2 
    lda.z conio_addr
    sta.z __3
    // *VERA_ADDRX_L = BYTE0(conio_addr)
    // [58] *VERA_ADDRX_L = cputc::$3 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_L
    // BYTE1(conio_addr)
    // [59] cputc::$4 = byte1  cputc::conio_addr#1 -- vbuz1=_byte1_vwuz2 
    lda.z conio_addr+1
    sta.z __4
    // *VERA_ADDRX_M = BYTE1(conio_addr)
    // [60] *VERA_ADDRX_M = cputc::$4 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // __conio.mapbase_bank | VERA_INC_1
    // [61] cputc::$5 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK) | VERA_INC_1 -- vbuz1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK
    sta.z __5
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [62] *VERA_ADDRX_H = cputc::$5 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_H
    // *VERA_DATA0 = c
    // [63] *VERA_DATA0 = cputc::c#0 -- _deref_pbuc1=vbuz1 
    lda.z c
    sta VERA_DATA0
    // *VERA_DATA0 = color
    // [64] *VERA_DATA0 = cputc::color#0 -- _deref_pbuc1=vbuz1 
    lda.z color
    sta VERA_DATA0
    // __conio.cursor_x++;
    // [65] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = ++ *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) -- _deref_pbuc1=_inc__deref_pbuc1 
    inc __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // unsigned char scroll_enable = __conio.scroll[__conio.layer]
    // [66] cputc::scroll_enable#0 = ((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_SCROLL)[*((char *)&__conio)] -- vbuz1=pbuc1_derefidx_(_deref_pbuc2) 
    ldy __conio
    lda __conio+OFFSET_STRUCT_CX16_CONIO_SCROLL,y
    sta.z scroll_enable
    // if(scroll_enable)
    // [67] if(0!=cputc::scroll_enable#0) goto cputc::@5 -- 0_neq_vbuz1_then_la1 
    bne __b5
    // cputc::@3
    // (unsigned int)__conio.cursor_x == mapwidth
    // [68] cputc::$14 = (unsigned int)*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) -- vwuz1=_word__deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    sta.z __14
    lda #0
    sta.z __14+1
    // if((unsigned int)__conio.cursor_x == mapwidth)
    // [69] if(cputc::$14!=cputc::mapwidth#0) goto cputc::@return -- vwuz1_neq_vwuz2_then_la1 
    cmp.z mapwidth+1
    bne __breturn
    lda.z __14
    cmp.z mapwidth
    bne __breturn
    // [70] phi from cputc::@3 to cputc::@4 [phi:cputc::@3->cputc::@4]
    // cputc::@4
    // cputln()
    // [71] call cputln
    jsr cputln
    // cputc::@return
  __breturn:
    // }
    // [72] return 
    rts
    // cputc::@5
  __b5:
    // if(__conio.cursor_x == __conio.width)
    // [73] if(*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X)!=*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_WIDTH)) goto cputc::@return -- _deref_pbuc1_neq__deref_pbuc2_then_la1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_WIDTH
    bne __breturn
    // [74] phi from cputc::@5 to cputc::@6 [phi:cputc::@5->cputc::@6]
    // cputc::@6
    // cputln()
    // [75] call cputln
    jsr cputln
    rts
    // [76] phi from cputc to cputc::@1 [phi:cputc->cputc::@1]
    // cputc::@1
  __b1:
    // cputln()
    // [77] call cputln
    jsr cputln
    rts
}
  // main
main: {
    // get the mouse status, which puts the x and y coordinates in zero page $22
    .label addr_22 = $22
    .label addr_23 = $23
    .label addr_24 = $24
    .label addr_25 = $25
    // get the mouse status, which puts the x and y coordinates in zero page $22
    .label addr_221 = $22
    .label addr_231 = $23
    .label addr_241 = $24
    .label addr_251 = $25
    .label __14 = $3b
    .label __19 = $3b
    .label status = $5f
    .label status_1 = $3a
    // clrscr()
    // [79] call clrscr
    jsr clrscr
    // main::@7
    // cx16_mouse_config(0xFF, 80, 60)
    // [80] cx16_mouse_config::visible = $ff -- vbuz1=vbuc1 
    lda #$ff
    sta.z cx16_mouse_config.visible
    // [81] cx16_mouse_config::scalex = $50 -- vbuz1=vbuc1 
    lda #$50
    sta.z cx16_mouse_config.scalex
    // [82] cx16_mouse_config::scaley = $3c -- vbuz1=vbuc1 
    lda #$3c
    sta.z cx16_mouse_config.scaley
    // [83] call cx16_mouse_config
    jsr cx16_mouse_config
    // [84] phi from main::@7 to main::@8 [phi:main::@7->main::@8]
    // main::@8
    // printf("move the mouse, and check the registers updating correctly. press any key ...\n")
    // [85] call printf_str
    // [269] phi from main::@8 to printf_str [phi:main::@8->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@8->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s [phi:main::@8->printf_str#1] -- pbuz1=pbuc1 
    lda #<s
    sta.z printf_str.s
    lda #>s
    sta.z printf_str.s+1
    jsr printf_str
    // [86] phi from main::@18 main::@8 to main::@2 [phi:main::@18/main::@8->main::@2]
    // main::@2
  __b2:
    // getin()
    // [87] call getin
    jsr getin
    // [88] getin::return#2 = getin::return#1
    // main::@9
    // [89] main::$14 = getin::return#2
    // while(!getin())
    // [90] if(0==main::$14) goto main::@3 -- 0_eq_vbuz1_then_la1 
    lda.z __14
    bne !__b3+
    jmp __b3
  !__b3:
    // [91] phi from main::@9 to main::@4 [phi:main::@9->main::@4]
    // main::@4
    // gotoxy(0,2)
    // [92] call gotoxy
    // [223] phi from main::@4 to gotoxy [phi:main::@4->gotoxy]
    // [223] phi gotoxy::x#10 = 0 [phi:main::@4->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    // [223] phi gotoxy::y#7 = 2 [phi:main::@4->gotoxy#1] -- vbuz1=vbuc1 
    lda #2
    sta.z gotoxy.y
    jsr gotoxy
    // [93] phi from main::@4 to main::@19 [phi:main::@4->main::@19]
    // main::@19
    // printf("opening the file and closing the file, no reading occurring ...\n")
    // [94] call printf_str
    // [269] phi from main::@19 to printf_str [phi:main::@19->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@19->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s5 [phi:main::@19->printf_str#1] -- pbuz1=pbuc1 
    lda #<s5
    sta.z printf_str.s
    lda #>s5
    sta.z printf_str.s+1
    jsr printf_str
    // main::@20
    // cbm_k_setnam("FILE")
    // [95] cbm_k_setnam::filename = main::filename -- pbuz1=pbuc1 
    lda #<filename
    sta.z cbm_k_setnam.filename
    lda #>filename
    sta.z cbm_k_setnam.filename+1
    // [96] call cbm_k_setnam
    jsr cbm_k_setnam
    // main::@21
    // cbm_k_setlfs(1, 8, 8)
    // [97] cbm_k_setlfs::channel = 1 -- vbuz1=vbuc1 
    lda #1
    sta.z cbm_k_setlfs.channel
    // [98] cbm_k_setlfs::device = 8 -- vbuz1=vbuc1 
    lda #8
    sta.z cbm_k_setlfs.device
    // [99] cbm_k_setlfs::command = 8 -- vbuz1=vbuc1 
    sta.z cbm_k_setlfs.command
    // [100] call cbm_k_setlfs
    // File name on the disk
    jsr cbm_k_setlfs
    // [101] phi from main::@21 to main::@22 [phi:main::@21->main::@22]
    // main::@22
    // char status = cbm_k_open()
    // [102] call cbm_k_open
    // set the channel to be a file loaded from disk
    jsr cbm_k_open
    // [103] cbm_k_open::return#2 = cbm_k_open::return#1
    // main::@23
    // [104] main::status#0 = cbm_k_open::return#2
    // printf("open status=%u\n", status)
    // [105] call printf_str
    // [269] phi from main::@23 to printf_str [phi:main::@23->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@23->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s6 [phi:main::@23->printf_str#1] -- pbuz1=pbuc1 
    lda #<s6
    sta.z printf_str.s
    lda #>s6
    sta.z printf_str.s+1
    jsr printf_str
    // main::@24
    // printf("open status=%u\n", status)
    // [106] printf_uchar::uvalue#4 = main::status#0 -- vbuz1=vbuz2 
    lda.z status
    sta.z printf_uchar.uvalue
    // [107] call printf_uchar
    // [300] phi from main::@24 to printf_uchar [phi:main::@24->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 0 [phi:main::@24->printf_uchar#0] -- vbuz1=vbuc1 
    lda #0
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#4 [phi:main::@24->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [108] phi from main::@24 to main::@25 [phi:main::@24->main::@25]
    // main::@25
    // printf("open status=%u\n", status)
    // [109] call printf_str
    // [269] phi from main::@25 to printf_str [phi:main::@25->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@25->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s7 [phi:main::@25->printf_str#1] -- pbuz1=pbuc1 
    lda #<s7
    sta.z printf_str.s
    lda #>s7
    sta.z printf_str.s+1
    jsr printf_str
    // main::@26
    // if(status!=0x0)
    // [110] if(main::status#0==0) goto main::@1 -- vbuz1_eq_0_then_la1 
    lda.z status
    beq __b1
    // main::@return
    // }
    // [111] return 
    rts
    // main::@1
  __b1:
    // cbm_k_close(1)
    // [112] cbm_k_close::channel = 1 -- vbuz1=vbuc1 
    lda #1
    sta.z cbm_k_close.channel
    // [113] call cbm_k_close
    jsr cbm_k_close
    // [114] cbm_k_close::return#2 = cbm_k_close::return#1
    // main::@27
    // status = cbm_k_close(1)
    // [115] main::status#1 = cbm_k_close::return#2
    // printf("close status=%u\n", status)
    // [116] call printf_str
    // [269] phi from main::@27 to printf_str [phi:main::@27->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@27->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s8 [phi:main::@27->printf_str#1] -- pbuz1=pbuc1 
    lda #<s8
    sta.z printf_str.s
    lda #>s8
    sta.z printf_str.s+1
    jsr printf_str
    // main::@28
    // printf("close status=%u\n", status)
    // [117] printf_uchar::uvalue#5 = main::status#1
    // [118] call printf_uchar
    // [300] phi from main::@28 to printf_uchar [phi:main::@28->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 0 [phi:main::@28->printf_uchar#0] -- vbuz1=vbuc1 
    lda #0
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#5 [phi:main::@28->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [119] phi from main::@28 to main::@29 [phi:main::@28->main::@29]
    // main::@29
    // printf("close status=%u\n", status)
    // [120] call printf_str
    // [269] phi from main::@29 to printf_str [phi:main::@29->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@29->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s7 [phi:main::@29->printf_str#1] -- pbuz1=pbuc1 
    lda #<s7
    sta.z printf_str.s
    lda #>s7
    sta.z printf_str.s+1
    jsr printf_str
    // [121] phi from main::@29 to main::@30 [phi:main::@29->main::@30]
    // main::@30
    // printf("\nnow move the mouse again, and please check the coordinates updating after the\n file open and close, press any key ...\n")
    // [122] call printf_str
    // [269] phi from main::@30 to printf_str [phi:main::@30->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@30->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s10 [phi:main::@30->printf_str#1] -- pbuz1=pbuc1 
    lda #<s10
    sta.z printf_str.s
    lda #>s10
    sta.z printf_str.s+1
    jsr printf_str
    // [123] phi from main::@30 main::@40 to main::@5 [phi:main::@30/main::@40->main::@5]
    // main::@5
  __b5:
    // getin()
    // [124] call getin
    jsr getin
    // [125] getin::return#3 = getin::return#1
    // main::@31
    // [126] main::$19 = getin::return#3
    // while(!getin())
    // [127] if(0==main::$19) goto main::@6 -- 0_eq_vbuz1_then_la1 
    lda.z __19
    beq __b6
    rts
    // [128] phi from main::@31 to main::@6 [phi:main::@31->main::@6]
    // main::@6
  __b6:
    // char cx16_mouse_status = cx16_mouse_get()
    // [129] call cx16_mouse_get
    // loop until a key is pressed
    jsr cx16_mouse_get
    // [130] phi from main::@6 to main::@32 [phi:main::@6->main::@32]
    // main::@32
    // gotoxy(0,20)
    // [131] call gotoxy
    // [223] phi from main::@32 to gotoxy [phi:main::@32->gotoxy]
    // [223] phi gotoxy::x#10 = 0 [phi:main::@32->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    // [223] phi gotoxy::y#7 = $14 [phi:main::@32->gotoxy#1] -- vbuz1=vbuc1 
    lda #$14
    sta.z gotoxy.y
    jsr gotoxy
    // [132] phi from main::@32 to main::@33 [phi:main::@32->main::@33]
    // main::@33
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [133] call printf_str
    // [269] phi from main::@33 to printf_str [phi:main::@33->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@33->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s11 [phi:main::@33->printf_str#1] -- pbuz1=pbuc1 
    lda #<s11
    sta.z printf_str.s
    lda #>s11
    sta.z printf_str.s+1
    jsr printf_str
    // main::@34
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [134] printf_uchar::uvalue#6 = *main::addr_221 -- vbuz1=_deref_pbuc1 
    lda.z addr_221
    sta.z printf_uchar.uvalue
    // [135] call printf_uchar
    // [300] phi from main::@34 to printf_uchar [phi:main::@34->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@34->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#6 [phi:main::@34->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [136] phi from main::@34 to main::@35 [phi:main::@34->main::@35]
    // main::@35
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [137] call printf_str
    // [269] phi from main::@35 to printf_str [phi:main::@35->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@35->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s2 [phi:main::@35->printf_str#1] -- pbuz1=pbuc1 
    lda #<s2
    sta.z printf_str.s
    lda #>s2
    sta.z printf_str.s+1
    jsr printf_str
    // main::@36
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [138] printf_uchar::uvalue#7 = *main::addr_231 -- vbuz1=_deref_pbuc1 
    lda.z addr_231
    sta.z printf_uchar.uvalue
    // [139] call printf_uchar
    // [300] phi from main::@36 to printf_uchar [phi:main::@36->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@36->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#7 [phi:main::@36->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [140] phi from main::@36 to main::@37 [phi:main::@36->main::@37]
    // main::@37
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [141] call printf_str
    // [269] phi from main::@37 to printf_str [phi:main::@37->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@37->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s3 [phi:main::@37->printf_str#1] -- pbuz1=pbuc1 
    lda #<s3
    sta.z printf_str.s
    lda #>s3
    sta.z printf_str.s+1
    jsr printf_str
    // main::@38
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [142] printf_uchar::uvalue#8 = *main::addr_241 -- vbuz1=_deref_pbuc1 
    lda.z addr_241
    sta.z printf_uchar.uvalue
    // [143] call printf_uchar
    // [300] phi from main::@38 to printf_uchar [phi:main::@38->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@38->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#8 [phi:main::@38->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [144] phi from main::@38 to main::@39 [phi:main::@38->main::@39]
    // main::@39
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [145] call printf_str
    // [269] phi from main::@39 to printf_str [phi:main::@39->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@39->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s4 [phi:main::@39->printf_str#1] -- pbuz1=pbuc1 
    lda #<s4
    sta.z printf_str.s
    lda #>s4
    sta.z printf_str.s+1
    jsr printf_str
    // main::@40
    // printf("after open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [146] printf_uchar::uvalue#9 = *main::addr_251 -- vbuz1=_deref_pbuc1 
    lda.z addr_251
    sta.z printf_uchar.uvalue
    // [147] call printf_uchar
    // [300] phi from main::@40 to printf_uchar [phi:main::@40->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@40->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#9 [phi:main::@40->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    jmp __b5
    // [148] phi from main::@9 to main::@3 [phi:main::@9->main::@3]
    // main::@3
  __b3:
    // char cx16_mouse_status = cx16_mouse_get()
    // [149] call cx16_mouse_get
    // loop until a key is pressed
    jsr cx16_mouse_get
    // [150] phi from main::@3 to main::@10 [phi:main::@3->main::@10]
    // main::@10
    // gotoxy(0,19)
    // [151] call gotoxy
    // [223] phi from main::@10 to gotoxy [phi:main::@10->gotoxy]
    // [223] phi gotoxy::x#10 = 0 [phi:main::@10->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    // [223] phi gotoxy::y#7 = $13 [phi:main::@10->gotoxy#1] -- vbuz1=vbuc1 
    lda #$13
    sta.z gotoxy.y
    jsr gotoxy
    // [152] phi from main::@10 to main::@11 [phi:main::@10->main::@11]
    // main::@11
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [153] call printf_str
    // [269] phi from main::@11 to printf_str [phi:main::@11->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@11->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s1 [phi:main::@11->printf_str#1] -- pbuz1=pbuc1 
    lda #<s1
    sta.z printf_str.s
    lda #>s1
    sta.z printf_str.s+1
    jsr printf_str
    // main::@12
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [154] printf_uchar::uvalue#0 = *main::addr_22 -- vbuz1=_deref_pbuc1 
    lda.z addr_22
    sta.z printf_uchar.uvalue
    // [155] call printf_uchar
    // [300] phi from main::@12 to printf_uchar [phi:main::@12->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@12->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#0 [phi:main::@12->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [156] phi from main::@12 to main::@13 [phi:main::@12->main::@13]
    // main::@13
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [157] call printf_str
    // [269] phi from main::@13 to printf_str [phi:main::@13->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@13->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s2 [phi:main::@13->printf_str#1] -- pbuz1=pbuc1 
    lda #<s2
    sta.z printf_str.s
    lda #>s2
    sta.z printf_str.s+1
    jsr printf_str
    // main::@14
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [158] printf_uchar::uvalue#1 = *main::addr_23 -- vbuz1=_deref_pbuc1 
    lda.z addr_23
    sta.z printf_uchar.uvalue
    // [159] call printf_uchar
    // [300] phi from main::@14 to printf_uchar [phi:main::@14->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@14->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#1 [phi:main::@14->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [160] phi from main::@14 to main::@15 [phi:main::@14->main::@15]
    // main::@15
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [161] call printf_str
    // [269] phi from main::@15 to printf_str [phi:main::@15->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@15->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s3 [phi:main::@15->printf_str#1] -- pbuz1=pbuc1 
    lda #<s3
    sta.z printf_str.s
    lda #>s3
    sta.z printf_str.s+1
    jsr printf_str
    // main::@16
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [162] printf_uchar::uvalue#2 = *main::addr_24 -- vbuz1=_deref_pbuc1 
    lda.z addr_24
    sta.z printf_uchar.uvalue
    // [163] call printf_uchar
    // [300] phi from main::@16 to printf_uchar [phi:main::@16->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@16->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#2 [phi:main::@16->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    // [164] phi from main::@16 to main::@17 [phi:main::@16->main::@17]
    // main::@17
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [165] call printf_str
    // [269] phi from main::@17 to printf_str [phi:main::@17->printf_str]
    // [269] phi printf_str::putc#18 = &cputc [phi:main::@17->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = main::s4 [phi:main::@17->printf_str#1] -- pbuz1=pbuc1 
    lda #<s4
    sta.z printf_str.s
    lda #>s4
    sta.z printf_str.s+1
    jsr printf_str
    // main::@18
    // printf("before open : $22=%3u, $23=%3u, $24=%3u, $25=%3u", *addr_22, *addr_23, *addr_24, *addr_25)
    // [166] printf_uchar::uvalue#3 = *main::addr_25 -- vbuz1=_deref_pbuc1 
    lda.z addr_25
    sta.z printf_uchar.uvalue
    // [167] call printf_uchar
    // [300] phi from main::@18 to printf_uchar [phi:main::@18->printf_uchar]
    // [300] phi printf_uchar::format_min_length#10 = 3 [phi:main::@18->printf_uchar#0] -- vbuz1=vbuc1 
    lda #3
    sta.z printf_uchar.format_min_length
    // [300] phi printf_uchar::uvalue#10 = printf_uchar::uvalue#3 [phi:main::@18->printf_uchar#1] -- register_copy 
    jsr printf_uchar
    jmp __b2
  .segment Data
    s: .text @"move the mouse, and check the registers updating correctly. press any key ...\n"
    .byte 0
    s1: .text "before open : $22="
    .byte 0
    s2: .text ", $23="
    .byte 0
    s3: .text ", $24="
    .byte 0
    s4: .text ", $25="
    .byte 0
    s5: .text @"opening the file and closing the file, no reading occurring ...\n"
    .byte 0
    filename: .text "FILE"
    .byte 0
    s6: .text "open status="
    .byte 0
    s7: .text @"\n"
    .byte 0
    s8: .text "close status="
    .byte 0
    s10: .text @"\nnow move the mouse again, and please check the coordinates updating after the\n file open and close, press any key ...\n"
    .byte 0
    s11: .text "after open : $22="
    .byte 0
}
.segment Code
  // screensize
// Return the current screen size.
// void screensize(char *x, char *y)
screensize: {
    .label x = __conio+OFFSET_STRUCT_CX16_CONIO_WIDTH
    .label y = __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    .label __1 = $5a
    .label __3 = $5b
    .label hscale = $5a
    .label vscale = $5b
    // char hscale = (*VERA_DC_HSCALE) >> 7
    // [168] screensize::hscale#0 = *VERA_DC_HSCALE >> 7 -- vbuz1=_deref_pbuc1_ror_7 
    // VERA returns in VERA_DC_HSCALE the value of 128 when 80 columns is used in text mode,
    // and the value of 64 when 40 columns is used in text mode.
    // Basically, 40 columns mode in the VERA is a double scan mode.
    // Same for the VERA_DC_VSCALE mode, but then the subdivision is 60 or 30 rows.
    // I still need to test the other modes, but this will suffice for now for the pure text modes.
    lda VERA_DC_HSCALE
    rol
    rol
    and #1
    sta.z hscale
    // 40 << hscale
    // [169] screensize::$1 = $28 << screensize::hscale#0 -- vbuz1=vbuc1_rol_vbuz1 
    lda #$28
    ldy.z __1
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta.z __1
    // *x = 40 << hscale
    // [170] *screensize::x#0 = screensize::$1 -- _deref_pbuc1=vbuz1 
    sta x
    // char vscale = (*VERA_DC_VSCALE) >> 7
    // [171] screensize::vscale#0 = *VERA_DC_VSCALE >> 7 -- vbuz1=_deref_pbuc1_ror_7 
    lda VERA_DC_VSCALE
    rol
    rol
    and #1
    sta.z vscale
    // 30 << vscale
    // [172] screensize::$3 = $1e << screensize::vscale#0 -- vbuz1=vbuc1_rol_vbuz1 
    lda #$1e
    ldy.z __3
    cpy #0
    beq !e+
  !:
    asl
    dey
    bne !-
  !e:
    sta.z __3
    // *y = 30 << vscale
    // [173] *screensize::y#0 = screensize::$3 -- _deref_pbuc1=vbuz1 
    sta y
    // screensize::@return
    // }
    // [174] return 
    rts
}
  // screenlayer1
// Set the layer with which the conio will interact.
// - layer: value of 0 or 1.
screenlayer1: {
    .label __0 = $5a
    .label __1 = $5b
    .label __2 = $60
    .label __3 = $55
    .label __4 = $55
    .label __5 = $56
    .label __6 = $56
    .label __7 = $5c
    .label __8 = $5c
    .label __9 = $5c
    .label __10 = $5d
    .label __11 = $5d
    .label __12 = $53
    .label __13 = $62
    .label __14 = $53
    .label __15 = $63
    .label __16 = $55
    .label __17 = $56
    .label __18 = $5d
    // __conio.layer = 1
    // [175] *((char *)&__conio) = 1 -- _deref_pbuc1=vbuc2 
    lda #1
    sta __conio
    // (*VERA_L1_MAPBASE)>>7
    // [176] screenlayer1::$0 = *VERA_L1_MAPBASE >> 7 -- vbuz1=_deref_pbuc1_ror_7 
    lda VERA_L1_MAPBASE
    rol
    rol
    and #1
    sta.z __0
    // __conio.mapbase_bank = (*VERA_L1_MAPBASE)>>7
    // [177] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK) = screenlayer1::$0 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK
    // (*VERA_L1_MAPBASE)<<1
    // [178] screenlayer1::$1 = *VERA_L1_MAPBASE << 1 -- vbuz1=_deref_pbuc1_rol_1 
    lda VERA_L1_MAPBASE
    asl
    sta.z __1
    // MAKEWORD((*VERA_L1_MAPBASE)<<1,0)
    // [179] screenlayer1::$2 = screenlayer1::$1 w= 0 -- vwuz1=vbuz2_word_vbuc1 
    lda #0
    ldy.z __1
    sty.z __2+1
    sta.z __2
    // __conio.mapbase_offset = MAKEWORD((*VERA_L1_MAPBASE)<<1,0)
    // [180] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET) = screenlayer1::$2 -- _deref_pwuc1=vwuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET
    tya
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET+1
    // *VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK
    // [181] screenlayer1::$3 = *VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_WIDTH_MASK
    and VERA_L1_CONFIG
    sta.z __3
    // (*VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK) >> 4
    // [182] screenlayer1::$4 = screenlayer1::$3 >> 4 -- vbuz1=vbuz1_ror_4 
    lda.z __4
    lsr
    lsr
    lsr
    lsr
    sta.z __4
    // __conio.mapwidth = VERA_LAYER_WIDTH[ (*VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK) >> 4]
    // [183] screenlayer1::$16 = screenlayer1::$4 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __16
    // [184] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH) = VERA_LAYER_WIDTH[screenlayer1::$16] -- _deref_pwuc1=pwuc2_derefidx_vbuz1 
    ldy.z __16
    lda VERA_LAYER_WIDTH,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH
    lda VERA_LAYER_WIDTH+1,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH+1
    // *VERA_L1_CONFIG & VERA_LAYER_HEIGHT_MASK
    // [185] screenlayer1::$5 = *VERA_L1_CONFIG & VERA_LAYER_HEIGHT_MASK -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_HEIGHT_MASK
    and VERA_L1_CONFIG
    sta.z __5
    // (*VERA_L1_CONFIG & VERA_LAYER_HEIGHT_MASK) >> 6
    // [186] screenlayer1::$6 = screenlayer1::$5 >> 6 -- vbuz1=vbuz1_ror_6 
    lda.z __6
    rol
    rol
    rol
    and #3
    sta.z __6
    // __conio.mapheight = VERA_LAYER_HEIGHT[ (*VERA_L1_CONFIG & VERA_LAYER_HEIGHT_MASK) >> 6]
    // [187] screenlayer1::$17 = screenlayer1::$6 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __17
    // [188] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT) = VERA_LAYER_HEIGHT[screenlayer1::$17] -- _deref_pwuc1=pwuc2_derefidx_vbuz1 
    ldy.z __17
    lda VERA_LAYER_HEIGHT,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT
    lda VERA_LAYER_HEIGHT+1,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT+1
    // (*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK
    // [189] screenlayer1::$7 = *VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_WIDTH_MASK
    and VERA_L1_CONFIG
    sta.z __7
    // ((*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK)>>4
    // [190] screenlayer1::$8 = screenlayer1::$7 >> 4 -- vbuz1=vbuz1_ror_4 
    lda.z __8
    lsr
    lsr
    lsr
    lsr
    sta.z __8
    // (((*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK)>>4)+6
    // [191] screenlayer1::$9 = screenlayer1::$8 + 6 -- vbuz1=vbuz1_plus_vbuc1 
    lda #6
    clc
    adc.z __9
    sta.z __9
    // __conio.rowshift = (((*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK)>>4)+6
    // [192] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT) = screenlayer1::$9 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT
    // (*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK
    // [193] screenlayer1::$10 = *VERA_L1_CONFIG & VERA_LAYER_WIDTH_MASK -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #VERA_LAYER_WIDTH_MASK
    and VERA_L1_CONFIG
    sta.z __10
    // ((*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK)>>4
    // [194] screenlayer1::$11 = screenlayer1::$10 >> 4 -- vbuz1=vbuz1_ror_4 
    lda.z __11
    lsr
    lsr
    lsr
    lsr
    sta.z __11
    // __conio.rowskip = VERA_LAYER_SKIP[((*VERA_L1_CONFIG)&VERA_LAYER_WIDTH_MASK)>>4]
    // [195] screenlayer1::$18 = screenlayer1::$11 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __18
    // [196] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP) = VERA_LAYER_SKIP[screenlayer1::$18] -- _deref_pwuc1=pwuc2_derefidx_vbuz1 
    ldy.z __18
    lda VERA_LAYER_SKIP,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP
    lda VERA_LAYER_SKIP+1,y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP+1
    // cbm_k_plot_get()
    // [197] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [198] cbm_k_plot_get::return#4 = cbm_k_plot_get::return#0
    // screenlayer1::@1
    // [199] screenlayer1::$12 = cbm_k_plot_get::return#4
    // BYTE1(cbm_k_plot_get())
    // [200] screenlayer1::$13 = byte1  screenlayer1::$12 -- vbuz1=_byte1_vwuz2 
    lda.z __12+1
    sta.z __13
    // __conio.cursor_x = BYTE1(cbm_k_plot_get())
    // [201] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = screenlayer1::$13 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // cbm_k_plot_get()
    // [202] call cbm_k_plot_get
    jsr cbm_k_plot_get
    // [203] cbm_k_plot_get::return#10 = cbm_k_plot_get::return#0
    // screenlayer1::@2
    // [204] screenlayer1::$14 = cbm_k_plot_get::return#10
    // BYTE0(cbm_k_plot_get())
    // [205] screenlayer1::$15 = byte0  screenlayer1::$14 -- vbuz1=_byte0_vwuz2 
    lda.z __14
    sta.z __15
    // __conio.cursor_y = BYTE0(cbm_k_plot_get())
    // [206] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) = screenlayer1::$15 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    // screenlayer1::@return
    // }
    // [207] return 
    rts
}
  // textcolor
// Set the front color for text output. The old front text color setting is returned.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char textcolor(char color)
textcolor: {
    .label __0 = $55
    .label __1 = $55
    // __conio.color & 0xF0
    // [208] textcolor::$0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) & $f0 -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #$f0
    and __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    sta.z __0
    // __conio.color & 0xF0 | color
    // [209] textcolor::$1 = textcolor::$0 | WHITE -- vbuz1=vbuz1_bor_vbuc1 
    lda #WHITE
    ora.z __1
    sta.z __1
    // __conio.color = __conio.color & 0xF0 | color
    // [210] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) = textcolor::$1 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    // textcolor::@return
    // }
    // [211] return 
    rts
}
  // bgcolor
// Set the back color for text output. The old back text color setting is returned.
// - color: a 4 bit value ( decimal between 0 and 15).
//   This will only work when the VERA is in 16 color mode!
//   Note that on the VERA, the transparent color has value 0.
// char bgcolor(char color)
bgcolor: {
    .label __0 = $56
    .label __2 = $56
    // __conio.color & 0x0F
    // [212] bgcolor::$0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) & $f -- vbuz1=_deref_pbuc1_band_vbuc2 
    lda #$f
    and __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    sta.z __0
    // __conio.color & 0x0F | color << 4
    // [213] bgcolor::$2 = bgcolor::$0 | BLUE<<4 -- vbuz1=vbuz1_bor_vbuc1 
    lda #BLUE<<4
    ora.z __2
    sta.z __2
    // __conio.color = __conio.color & 0x0F | color << 4
    // [214] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) = bgcolor::$2 -- _deref_pbuc1=vbuz1 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    // bgcolor::@return
    // }
    // [215] return 
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
    // [216] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR) = cursor::onoff#0 -- _deref_pbuc1=vbuc2 
    lda #onoff
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR
    // cursor::@return
    // }
    // [217] return 
    rts
}
  // cbm_k_plot_get
/**
 * @brief Get current x and y cursor position.
 * @return An unsigned int where the hi byte is the x coordinate and the low byte is the y coordinate of the screen position.
 */
cbm_k_plot_get: {
    .label x = $59
    .label y = $57
    .label return = $53
    // unsigned char x
    // [218] cbm_k_plot_get::x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z x
    // unsigned char y
    // [219] cbm_k_plot_get::y = 0 -- vbuz1=vbuc1 
    sta.z y
    // kickasm
    // kickasm( uses cbm_k_plot_get::x uses cbm_k_plot_get::y uses CBM_PLOT) {{ sec         jsr CBM_PLOT         stx y         sty x      }}
    sec
        jsr CBM_PLOT
        stx y
        sty x
    
    // MAKEWORD(x,y)
    // [221] cbm_k_plot_get::return#0 = cbm_k_plot_get::x w= cbm_k_plot_get::y -- vwuz1=vbuz2_word_vbuz3 
    lda.z x
    sta.z return+1
    lda.z y
    sta.z return
    // cbm_k_plot_get::@return
    // }
    // [222] return 
    rts
}
  // gotoxy
// Set the cursor to the specified position
// void gotoxy(__zp($38) char x, __zp($39) char y)
gotoxy: {
    .label __5 = $36
    .label line_offset = $36
    .label x = $38
    .label y = $39
    // if(y>__conio.height)
    // [224] if(gotoxy::y#7<=*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT)) goto gotoxy::@3 -- vbuz1_le__deref_pbuc1_then_la1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    cmp.z y
    bcs __b1
    // [226] phi from gotoxy to gotoxy::@1 [phi:gotoxy->gotoxy::@1]
    // [226] phi gotoxy::y#10 = 0 [phi:gotoxy->gotoxy::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z y
    // [225] phi from gotoxy to gotoxy::@3 [phi:gotoxy->gotoxy::@3]
    // gotoxy::@3
    // [226] phi from gotoxy::@3 to gotoxy::@1 [phi:gotoxy::@3->gotoxy::@1]
    // [226] phi gotoxy::y#10 = gotoxy::y#7 [phi:gotoxy::@3->gotoxy::@1#0] -- register_copy 
    // gotoxy::@1
  __b1:
    // if(x>=__conio.width)
    // [227] if(gotoxy::x#10<*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_WIDTH)) goto gotoxy::@4 -- vbuz1_lt__deref_pbuc1_then_la1 
    lda.z x
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_WIDTH
    bcc __b2
    // [229] phi from gotoxy::@1 to gotoxy::@2 [phi:gotoxy::@1->gotoxy::@2]
    // [229] phi gotoxy::x#8 = 0 [phi:gotoxy::@1->gotoxy::@2#0] -- vbuz1=vbuc1 
    lda #0
    sta.z x
    // [228] phi from gotoxy::@1 to gotoxy::@4 [phi:gotoxy::@1->gotoxy::@4]
    // gotoxy::@4
    // [229] phi from gotoxy::@4 to gotoxy::@2 [phi:gotoxy::@4->gotoxy::@2]
    // [229] phi gotoxy::x#8 = gotoxy::x#10 [phi:gotoxy::@4->gotoxy::@2#0] -- register_copy 
    // gotoxy::@2
  __b2:
    // __conio.cursor_x = x
    // [230] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = gotoxy::x#8 -- _deref_pbuc1=vbuz1 
    lda.z x
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // __conio.cursor_y = y
    // [231] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) = gotoxy::y#10 -- _deref_pbuc1=vbuz1 
    lda.z y
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    // unsigned int line_offset = (unsigned int)y << __conio.rowshift
    // [232] gotoxy::$5 = (unsigned int)gotoxy::y#10 -- vwuz1=_word_vbuz2 
    lda.z y
    sta.z __5
    lda #0
    sta.z __5+1
    // [233] gotoxy::line_offset#0 = gotoxy::$5 << *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT) -- vwuz1=vwuz1_rol__deref_pbuc1 
    ldy __conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT
    beq !e+
  !:
    asl.z line_offset
    rol.z line_offset+1
    dey
    bne !-
  !e:
    // __conio.line = line_offset
    // [234] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) = gotoxy::line_offset#0 -- _deref_pwuc1=vwuz1 
    lda.z line_offset
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    lda.z line_offset+1
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    // gotoxy::@return
    // }
    // [235] return 
    rts
}
  // cputln
// Print a newline
cputln: {
    .label temp = $3c
    // unsigned int temp = __conio.line
    // [236] cputln::temp#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) -- vwuz1=_deref_pwuc1 
    // TODO: This needs to be optimized! other variations don't compile because of sections not available!
    lda __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    sta.z temp
    lda __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    sta.z temp+1
    // temp += __conio.rowskip
    // [237] cputln::temp#1 = cputln::temp#0 + *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z temp
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP
    sta.z temp
    lda.z temp+1
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP+1
    sta.z temp+1
    // __conio.line = temp
    // [238] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) = cputln::temp#1 -- _deref_pwuc1=vwuz1 
    lda.z temp
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    lda.z temp+1
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    // __conio.cursor_x = 0
    // [239] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // __conio.cursor_y++;
    // [240] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) = ++ *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) -- _deref_pbuc1=_inc__deref_pbuc1 
    inc __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    // cscroll()
    // [241] call cscroll
    jsr cscroll
    // cputln::@return
    // }
    // [242] return 
    rts
}
  // clrscr
// clears the screen and moves the cursor to the upper left-hand corner of the screen.
clrscr: {
    .label __1 = $4e
    .label __2 = $52
    .label __3 = $3e
    .label line_text = $49
    .label color = $48
    .label mapheight = $4f
    .label mapwidth = $46
    .label c = $51
    .label l = $3a
    // unsigned int line_text = __conio.mapbase_offset
    // [243] clrscr::line_text#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET
    sta.z line_text
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET+1
    sta.z line_text+1
    // char color = __conio.color
    // [244] clrscr::color#0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) -- vbuz1=_deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    sta.z color
    // unsigned int mapheight = __conio.mapheight
    // [245] clrscr::mapheight#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT
    sta.z mapheight
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPHEIGHT+1
    sta.z mapheight+1
    // unsigned int mapwidth = __conio.mapwidth
    // [246] clrscr::mapwidth#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH
    sta.z mapwidth
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPWIDTH+1
    sta.z mapwidth+1
    // [247] phi from clrscr to clrscr::@1 [phi:clrscr->clrscr::@1]
    // [247] phi clrscr::line_text#2 = clrscr::line_text#0 [phi:clrscr->clrscr::@1#0] -- register_copy 
    // [247] phi clrscr::l#2 = 0 [phi:clrscr->clrscr::@1#1] -- vbuz1=vbuc1 
    lda #0
    sta.z l
    // clrscr::@1
  __b1:
    // for( char l=0;l<mapheight; l++ )
    // [248] if(clrscr::l#2<clrscr::mapheight#0) goto clrscr::@2 -- vbuz1_lt_vwuz2_then_la1 
    lda.z mapheight+1
    bne __b2
    lda.z l
    cmp.z mapheight
    bcc __b2
    // clrscr::@3
    // __conio.cursor_x = 0
    // [249] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // __conio.cursor_y = 0
    // [250] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) = 0 -- _deref_pbuc1=vbuc2 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    // __conio.line = 0
    // [251] *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) = 0 -- _deref_pwuc1=vbuc2 
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    sta __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    // clrscr::@return
    // }
    // [252] return 
    rts
    // clrscr::@2
  __b2:
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [253] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    // Select DATA0
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(ch)
    // [254] clrscr::$1 = byte0  clrscr::line_text#2 -- vbuz1=_byte0_vwuz2 
    lda.z line_text
    sta.z __1
    // *VERA_ADDRX_L = BYTE0(ch)
    // [255] *VERA_ADDRX_L = clrscr::$1 -- _deref_pbuc1=vbuz1 
    // Set address
    sta VERA_ADDRX_L
    // BYTE1(ch)
    // [256] clrscr::$2 = byte1  clrscr::line_text#2 -- vbuz1=_byte1_vwuz2 
    lda.z line_text+1
    sta.z __2
    // *VERA_ADDRX_M = BYTE1(ch)
    // [257] *VERA_ADDRX_M = clrscr::$2 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // __conio.mapbase_bank | VERA_INC_1
    // [258] clrscr::$3 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK) | VERA_INC_1 -- vbuz1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_INC_1
    ora __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_BANK
    sta.z __3
    // *VERA_ADDRX_H = __conio.mapbase_bank | VERA_INC_1
    // [259] *VERA_ADDRX_H = clrscr::$3 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_H
    // [260] phi from clrscr::@2 to clrscr::@4 [phi:clrscr::@2->clrscr::@4]
    // [260] phi clrscr::c#2 = 0 [phi:clrscr::@2->clrscr::@4#0] -- vbuz1=vbuc1 
    lda #0
    sta.z c
    // clrscr::@4
  __b4:
    // for( char c=0;c<mapwidth; c++ )
    // [261] if(clrscr::c#2<clrscr::mapwidth#0) goto clrscr::@5 -- vbuz1_lt_vwuz2_then_la1 
    lda.z mapwidth+1
    bne __b5
    lda.z c
    cmp.z mapwidth
    bcc __b5
    // clrscr::@6
    // line_text += __conio.rowskip
    // [262] clrscr::line_text#1 = clrscr::line_text#2 + *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP) -- vwuz1=vwuz1_plus__deref_pwuc1 
    clc
    lda.z line_text
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP
    sta.z line_text
    lda.z line_text+1
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP+1
    sta.z line_text+1
    // for( char l=0;l<mapheight; l++ )
    // [263] clrscr::l#1 = ++ clrscr::l#2 -- vbuz1=_inc_vbuz1 
    inc.z l
    // [247] phi from clrscr::@6 to clrscr::@1 [phi:clrscr::@6->clrscr::@1]
    // [247] phi clrscr::line_text#2 = clrscr::line_text#1 [phi:clrscr::@6->clrscr::@1#0] -- register_copy 
    // [247] phi clrscr::l#2 = clrscr::l#1 [phi:clrscr::@6->clrscr::@1#1] -- register_copy 
    jmp __b1
    // clrscr::@5
  __b5:
    // *VERA_DATA0 = ' '
    // [264] *VERA_DATA0 = ' ' -- _deref_pbuc1=vbuc2 
    lda #' '
    sta VERA_DATA0
    // *VERA_DATA0 = color
    // [265] *VERA_DATA0 = clrscr::color#0 -- _deref_pbuc1=vbuz1 
    lda.z color
    sta VERA_DATA0
    // for( char c=0;c<mapwidth; c++ )
    // [266] clrscr::c#1 = ++ clrscr::c#2 -- vbuz1=_inc_vbuz1 
    inc.z c
    // [260] phi from clrscr::@5 to clrscr::@4 [phi:clrscr::@5->clrscr::@4]
    // [260] phi clrscr::c#2 = clrscr::c#1 [phi:clrscr::@5->clrscr::@4#0] -- register_copy 
    jmp __b4
}
  // cx16_mouse_config
/**
 * @brief Configures the mouse pointer.
 * 
 * 
 * @param visible Turn the mouse pointer on or off.
 * @param scalex Specify x axis screen resolution in 8 pixel increments.
 * @param scaley Specify y axis screen resolution in 8 pixel increments.
 * 
 */
// void cx16_mouse_config(__zp($70) volatile char visible, __zp($6d) volatile char scalex, __zp($6b) volatile char scaley)
cx16_mouse_config: {
    .label visible = $70
    .label scalex = $6d
    .label scaley = $6b
    // asm
    // asm { ldavisible ldxscalex ldyscaley jsrCX16_MOUSE_CONFIG  }
    lda visible
    ldx scalex
    ldy scaley
    jsr CX16_MOUSE_CONFIG
    // cx16_mouse_config::@return
    // }
    // [268] return 
    rts
}
  // printf_str
/// Print a NUL-terminated string
// void printf_str(__zp($49) void (*putc)(char), __zp($46) const char *s)
printf_str: {
    .label c = $48
    .label s = $46
    .label putc = $49
    // [270] phi from printf_str printf_str::@2 to printf_str::@1 [phi:printf_str/printf_str::@2->printf_str::@1]
    // [270] phi printf_str::s#17 = printf_str::s#18 [phi:printf_str/printf_str::@2->printf_str::@1#0] -- register_copy 
    // printf_str::@1
  __b1:
    // while(c=*s++)
    // [271] printf_str::c#1 = *printf_str::s#17 -- vbuz1=_deref_pbuz2 
    ldy #0
    lda (s),y
    sta.z c
    // [272] printf_str::s#0 = ++ printf_str::s#17 -- pbuz1=_inc_pbuz1 
    inc.z s
    bne !+
    inc.z s+1
  !:
    // [273] if(0!=printf_str::c#1) goto printf_str::@2 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b2
    // printf_str::@return
    // }
    // [274] return 
    rts
    // printf_str::@2
  __b2:
    // putc(c)
    // [275] stackpush(char) = printf_str::c#1 -- _stackpushbyte_=vbuz1 
    lda.z c
    pha
    // [276] callexecute *printf_str::putc#18  -- call__deref_pprz1 
    jsr icall1
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    jmp __b1
    // Outside Flow
  icall1:
    jmp (putc)
}
  // getin
/**
 * @brief Get a character from keyboard.
 * 
 * @return char The character read.
 */
getin: {
    .const bank_set_bram1_bank = 0
    .label ch = $5e
    .label bank_get_bram1_return = $4e
    .label return = $3b
    // char ch
    // [278] getin::ch = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z ch
    // getin::bank_get_bram1
    // return BRAM;
    // [279] getin::bank_get_bram1_return#0 = BRAM -- vbuz1=vbuz2 
    lda.z BRAM
    sta.z bank_get_bram1_return
    // getin::bank_set_bram1
    // BRAM = bank
    // [280] BRAM = getin::bank_set_bram1_bank#0 -- vbuz1=vbuc1 
    lda #bank_set_bram1_bank
    sta.z BRAM
    // getin::@1
    // asm
    // asm { jsr$ffe4 stach  }
    jsr $ffe4
    sta ch
    // getin::bank_set_bram2
    // BRAM = bank
    // [282] BRAM = getin::bank_get_bram1_return#0 -- vbuz1=vbuz2 
    lda.z bank_get_bram1_return
    sta.z BRAM
    // getin::@2
    // return ch;
    // [283] getin::return#0 = getin::ch -- vbuz1=vbuz2 
    lda.z ch
    sta.z return
    // getin::@return
    // }
    // [284] getin::return#1 = getin::return#0
    // [285] return 
    rts
}
  // cbm_k_setnam
/**
 * @brief Sets the name of the file before opening.
 * 
 * @param filename The name of the file.
 */
// void cbm_k_setnam(__zp($69) char * volatile filename)
cbm_k_setnam: {
    .label filename = $69
    .label filename_len = $64
    .label __0 = $49
    // strlen(filename)
    // [286] strlen::str#0 = cbm_k_setnam::filename -- pbuz1=pbuz2 
    lda.z filename
    sta.z strlen.str
    lda.z filename+1
    sta.z strlen.str+1
    // [287] call strlen
    // [328] phi from cbm_k_setnam to strlen [phi:cbm_k_setnam->strlen]
    // [328] phi strlen::str#5 = strlen::str#0 [phi:cbm_k_setnam->strlen#0] -- register_copy 
    jsr strlen
    // strlen(filename)
    // [288] strlen::return#0 = strlen::len#2
    // cbm_k_setnam::@1
    // [289] cbm_k_setnam::$0 = strlen::return#0
    // char filename_len = (char)strlen(filename)
    // [290] cbm_k_setnam::filename_len = (char)cbm_k_setnam::$0 -- vbuz1=_byte_vwuz2 
    lda.z __0
    sta.z filename_len
    // asm
    // asm { ldafilename_len ldxfilename ldyfilename+1 jsrCBM_SETNAM  }
    ldx filename
    ldy filename+1
    jsr CBM_SETNAM
    // cbm_k_setnam::@return
    // }
    // [292] return 
    rts
}
  // cbm_k_setlfs
/**
 * @brief Sets the logical file channel.
 * 
 * @param channel the logical file number.
 * @param device the device number.
 * @param command the command.
 */
// void cbm_k_setlfs(__zp($71) volatile char channel, __zp($6e) volatile char device, __zp($6c) volatile char command)
cbm_k_setlfs: {
    .label channel = $71
    .label device = $6e
    .label command = $6c
    // asm
    // asm { ldxdevice ldachannel ldycommand jsrCBM_SETLFS  }
    ldx device
    lda channel
    ldy command
    jsr CBM_SETLFS
    // cbm_k_setlfs::@return
    // }
    // [294] return 
    rts
}
  // cbm_k_open
/**
 * @brief Open a logical file.
 * 
 * @return char The status.
 */
cbm_k_open: {
    .label status = $65
    .label return = $5f
    // char status
    // [295] cbm_k_open::status = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z status
    // asm
    // asm { jsrCBM_OPEN stastatus  }
    jsr CBM_OPEN
    sta status
    // return status;
    // [297] cbm_k_open::return#0 = cbm_k_open::status -- vbuz1=vbuz2 
    sta.z return
    // cbm_k_open::@return
    // }
    // [298] cbm_k_open::return#1 = cbm_k_open::return#0
    // [299] return 
    rts
}
  // printf_uchar
// Print an unsigned char using a specific format
// void printf_uchar(void (*putc)(char), __zp($3a) char uvalue, __zp($51) char format_min_length, char format_justify_left, char format_sign_always, char format_zero_padding, char format_upper_case, char format_radix)
printf_uchar: {
    .label uvalue = $3a
    .label format_min_length = $51
    // printf_uchar::@1
    // printf_buffer.sign = format.sign_always?'+':0
    // [301] *((char *)&printf_buffer) = 0 -- _deref_pbuc1=vbuc2 
    // Handle any sign
    lda #0
    sta printf_buffer
    // uctoa(uvalue, printf_buffer.digits, format.radix)
    // [302] uctoa::value#1 = printf_uchar::uvalue#10
    // [303] call uctoa
  // Format number into buffer
    // [334] phi from printf_uchar::@1 to uctoa [phi:printf_uchar::@1->uctoa]
    jsr uctoa
    // printf_uchar::@2
    // printf_number_buffer(putc, printf_buffer, format)
    // [304] printf_number_buffer::buffer_sign#0 = *((char *)&printf_buffer) -- vbuz1=_deref_pbuc1 
    lda printf_buffer
    sta.z printf_number_buffer.buffer_sign
    // [305] printf_number_buffer::format_min_length#0 = printf_uchar::format_min_length#10
    // [306] call printf_number_buffer
    // Print using format
    jsr printf_number_buffer
    // printf_uchar::@return
    // }
    // [307] return 
    rts
}
  // cbm_k_close
/**
 * @brief Close a logical file.
 * 
 * @param channel The channel to close.
 * @return char Status.
 */
// __zp($3a) char cbm_k_close(__zp($6f) volatile char channel)
cbm_k_close: {
    .label channel = $6f
    .label status = $66
    .label return = $3a
    // char status
    // [308] cbm_k_close::status = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z status
    // asm
    // asm { ldachannel jsrCBM_CLOSE stastatus  }
    lda channel
    jsr CBM_CLOSE
    sta status
    // return status;
    // [310] cbm_k_close::return#0 = cbm_k_close::status -- vbuz1=vbuz2 
    sta.z return
    // cbm_k_close::@return
    // }
    // [311] cbm_k_close::return#1 = cbm_k_close::return#0
    // [312] return 
    rts
}
  // cx16_mouse_get
/**
 * @brief Retrieves the status of the mouse pointer and will fill the mouse position in the defined mouse registers.
 * 
 * @return char Current mouse status.
 * 
 * The pre-defined variables cx16_mousex and cx16_mousey contain the position of the mouse pointer.
 * 
 *     __address(0x22) int cx16_mousex = 0;
 *     __address(0x24) int cx16_mousey = 0;
 * 
 * The state of the mouse buttons is returned:
 * 
 *   |Bit|Description|
 *   |---|-----------|
 *   |0|Left Button|
 *   |1|Right Button|
 *   |2|Middle Button|
 * 
 *   If a button is pressed, the corresponding bit is set.
 */
cx16_mouse_get: {
    .label status = $58
    // char status
    // [313] cx16_mouse_get::status = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z status
    // asm
    // asm { ldx#$22 jsrCX16_MOUSE_GET stastatus  }
    ldx #$22
    jsr CX16_MOUSE_GET
    sta status
    // cx16_mouse_get::@return
    // }
    // [315] return 
    rts
}
  // cscroll
// Scroll the entire screen if the cursor is beyond the last line
cscroll: {
    // if(__conio.cursor_y>=__conio.height)
    // [316] if(*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y)<*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT)) goto cscroll::@return -- _deref_pbuc1_lt__deref_pbuc2_then_la1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    bcc __breturn
    // cscroll::@1
    // if(__conio.scroll[__conio.layer])
    // [317] if(0!=((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_SCROLL)[*((char *)&__conio)]) goto cscroll::@4 -- 0_neq_pbuc1_derefidx_(_deref_pbuc2)_then_la1 
    ldy __conio
    lda __conio+OFFSET_STRUCT_CX16_CONIO_SCROLL,y
    cmp #0
    bne __b4
    // cscroll::@2
    // if(__conio.cursor_y>=__conio.height)
    // [318] if(*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y)<*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT)) goto cscroll::@return -- _deref_pbuc1_lt__deref_pbuc2_then_la1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    bcc __breturn
    // [319] phi from cscroll::@2 to cscroll::@3 [phi:cscroll::@2->cscroll::@3]
    // cscroll::@3
    // gotoxy(0,0)
    // [320] call gotoxy
    // [223] phi from cscroll::@3 to gotoxy [phi:cscroll::@3->gotoxy]
    // [223] phi gotoxy::x#10 = 0 [phi:cscroll::@3->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    // [223] phi gotoxy::y#7 = 0 [phi:cscroll::@3->gotoxy#1] -- vbuz1=vbuc1 
    sta.z gotoxy.y
    jsr gotoxy
    // cscroll::@return
  __breturn:
    // }
    // [321] return 
    rts
    // [322] phi from cscroll::@1 to cscroll::@4 [phi:cscroll::@1->cscroll::@4]
    // cscroll::@4
  __b4:
    // insertup()
    // [323] call insertup
    jsr insertup
    // cscroll::@5
    // gotoxy( 0, __conio.height-1)
    // [324] gotoxy::y#2 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT) - 1 -- vbuz1=_deref_pbuc1_minus_1 
    ldx __conio+OFFSET_STRUCT_CX16_CONIO_HEIGHT
    dex
    stx.z gotoxy.y
    // [325] call gotoxy
    // [223] phi from cscroll::@5 to gotoxy [phi:cscroll::@5->gotoxy]
    // [223] phi gotoxy::x#10 = 0 [phi:cscroll::@5->gotoxy#0] -- vbuz1=vbuc1 
    lda #0
    sta.z gotoxy.x
    // [223] phi gotoxy::y#7 = gotoxy::y#2 [phi:cscroll::@5->gotoxy#1] -- register_copy 
    jsr gotoxy
    // [326] phi from cscroll::@5 to cscroll::@6 [phi:cscroll::@5->cscroll::@6]
    // cscroll::@6
    // clearline()
    // [327] call clearline
    jsr clearline
    rts
}
  // strlen
// Computes the length of the string str up to but not including the terminating null character.
// __zp($49) unsigned int strlen(__zp($46) char *str)
strlen: {
    .label str = $46
    .label return = $49
    .label len = $49
    // [329] phi from strlen to strlen::@1 [phi:strlen->strlen::@1]
    // [329] phi strlen::len#2 = 0 [phi:strlen->strlen::@1#0] -- vwuz1=vwuc1 
    lda #<0
    sta.z len
    sta.z len+1
    // [329] phi strlen::str#3 = strlen::str#5 [phi:strlen->strlen::@1#1] -- register_copy 
    // strlen::@1
  __b1:
    // while(*str)
    // [330] if(0!=*strlen::str#3) goto strlen::@2 -- 0_neq__deref_pbuz1_then_la1 
    ldy #0
    lda (str),y
    cmp #0
    bne __b2
    // strlen::@return
    // }
    // [331] return 
    rts
    // strlen::@2
  __b2:
    // len++;
    // [332] strlen::len#1 = ++ strlen::len#2 -- vwuz1=_inc_vwuz1 
    inc.z len
    bne !+
    inc.z len+1
  !:
    // str++;
    // [333] strlen::str#1 = ++ strlen::str#3 -- pbuz1=_inc_pbuz1 
    inc.z str
    bne !+
    inc.z str+1
  !:
    // [329] phi from strlen::@2 to strlen::@1 [phi:strlen::@2->strlen::@1]
    // [329] phi strlen::len#2 = strlen::len#1 [phi:strlen::@2->strlen::@1#0] -- register_copy 
    // [329] phi strlen::str#3 = strlen::str#1 [phi:strlen::@2->strlen::@1#1] -- register_copy 
    jmp __b1
}
  // uctoa
// Converts unsigned number value to a string representing it in RADIX format.
// If the leading digits are zero they are not included in the string.
// - value : The number to be converted to RADIX
// - buffer : receives the string representing the number and zero-termination.
// - radix : The radix to convert the number to (from the enum RADIX)
// void uctoa(__zp($3a) char value, __zp($49) char *buffer, char radix)
uctoa: {
    .label digit_value = $3e
    .label buffer = $49
    .label digit = $4e
    .label value = $3a
    .label started = $48
    // [335] phi from uctoa to uctoa::@1 [phi:uctoa->uctoa::@1]
    // [335] phi uctoa::buffer#11 = (char *)&printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS [phi:uctoa->uctoa::@1#0] -- pbuz1=pbuc1 
    lda #<printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    sta.z buffer
    lda #>printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    sta.z buffer+1
    // [335] phi uctoa::started#2 = 0 [phi:uctoa->uctoa::@1#1] -- vbuz1=vbuc1 
    lda #0
    sta.z started
    // [335] phi uctoa::value#2 = uctoa::value#1 [phi:uctoa->uctoa::@1#2] -- register_copy 
    // [335] phi uctoa::digit#2 = 0 [phi:uctoa->uctoa::@1#3] -- vbuz1=vbuc1 
    sta.z digit
    // uctoa::@1
  __b1:
    // for( char digit=0; digit<max_digits-1; digit++ )
    // [336] if(uctoa::digit#2<3-1) goto uctoa::@2 -- vbuz1_lt_vbuc1_then_la1 
    lda.z digit
    cmp #3-1
    bcc __b2
    // uctoa::@3
    // *buffer++ = DIGITS[(char)value]
    // [337] *uctoa::buffer#11 = DIGITS[uctoa::value#2] -- _deref_pbuz1=pbuc1_derefidx_vbuz2 
    ldy.z value
    lda DIGITS,y
    ldy #0
    sta (buffer),y
    // *buffer++ = DIGITS[(char)value];
    // [338] uctoa::buffer#3 = ++ uctoa::buffer#11 -- pbuz1=_inc_pbuz1 
    inc.z buffer
    bne !+
    inc.z buffer+1
  !:
    // *buffer = 0
    // [339] *uctoa::buffer#3 = 0 -- _deref_pbuz1=vbuc1 
    lda #0
    tay
    sta (buffer),y
    // uctoa::@return
    // }
    // [340] return 
    rts
    // uctoa::@2
  __b2:
    // unsigned char digit_value = digit_values[digit]
    // [341] uctoa::digit_value#0 = RADIX_DECIMAL_VALUES_CHAR[uctoa::digit#2] -- vbuz1=pbuc1_derefidx_vbuz2 
    ldy.z digit
    lda RADIX_DECIMAL_VALUES_CHAR,y
    sta.z digit_value
    // if (started || value >= digit_value)
    // [342] if(0!=uctoa::started#2) goto uctoa::@5 -- 0_neq_vbuz1_then_la1 
    lda.z started
    bne __b5
    // uctoa::@7
    // [343] if(uctoa::value#2>=uctoa::digit_value#0) goto uctoa::@5 -- vbuz1_ge_vbuz2_then_la1 
    lda.z value
    cmp.z digit_value
    bcs __b5
    // [344] phi from uctoa::@7 to uctoa::@4 [phi:uctoa::@7->uctoa::@4]
    // [344] phi uctoa::buffer#14 = uctoa::buffer#11 [phi:uctoa::@7->uctoa::@4#0] -- register_copy 
    // [344] phi uctoa::started#4 = uctoa::started#2 [phi:uctoa::@7->uctoa::@4#1] -- register_copy 
    // [344] phi uctoa::value#6 = uctoa::value#2 [phi:uctoa::@7->uctoa::@4#2] -- register_copy 
    // uctoa::@4
  __b4:
    // for( char digit=0; digit<max_digits-1; digit++ )
    // [345] uctoa::digit#1 = ++ uctoa::digit#2 -- vbuz1=_inc_vbuz1 
    inc.z digit
    // [335] phi from uctoa::@4 to uctoa::@1 [phi:uctoa::@4->uctoa::@1]
    // [335] phi uctoa::buffer#11 = uctoa::buffer#14 [phi:uctoa::@4->uctoa::@1#0] -- register_copy 
    // [335] phi uctoa::started#2 = uctoa::started#4 [phi:uctoa::@4->uctoa::@1#1] -- register_copy 
    // [335] phi uctoa::value#2 = uctoa::value#6 [phi:uctoa::@4->uctoa::@1#2] -- register_copy 
    // [335] phi uctoa::digit#2 = uctoa::digit#1 [phi:uctoa::@4->uctoa::@1#3] -- register_copy 
    jmp __b1
    // uctoa::@5
  __b5:
    // uctoa_append(buffer++, value, digit_value)
    // [346] uctoa_append::buffer#0 = uctoa::buffer#11 -- pbuz1=pbuz2 
    lda.z buffer
    sta.z uctoa_append.buffer
    lda.z buffer+1
    sta.z uctoa_append.buffer+1
    // [347] uctoa_append::value#0 = uctoa::value#2
    // [348] uctoa_append::sub#0 = uctoa::digit_value#0
    // [349] call uctoa_append
    // [408] phi from uctoa::@5 to uctoa_append [phi:uctoa::@5->uctoa_append]
    jsr uctoa_append
    // uctoa_append(buffer++, value, digit_value)
    // [350] uctoa_append::return#0 = uctoa_append::value#2
    // uctoa::@6
    // value = uctoa_append(buffer++, value, digit_value)
    // [351] uctoa::value#0 = uctoa_append::return#0
    // value = uctoa_append(buffer++, value, digit_value);
    // [352] uctoa::buffer#4 = ++ uctoa::buffer#11 -- pbuz1=_inc_pbuz1 
    inc.z buffer
    bne !+
    inc.z buffer+1
  !:
    // [344] phi from uctoa::@6 to uctoa::@4 [phi:uctoa::@6->uctoa::@4]
    // [344] phi uctoa::buffer#14 = uctoa::buffer#4 [phi:uctoa::@6->uctoa::@4#0] -- register_copy 
    // [344] phi uctoa::started#4 = 1 [phi:uctoa::@6->uctoa::@4#1] -- vbuz1=vbuc1 
    lda #1
    sta.z started
    // [344] phi uctoa::value#6 = uctoa::value#0 [phi:uctoa::@6->uctoa::@4#2] -- register_copy 
    jmp __b4
}
  // printf_number_buffer
// Print the contents of the number buffer using a specific format.
// This handles minimum length, zero-filling, and left/right justification from the format
// void printf_number_buffer(void (*putc)(char), __zp($52) char buffer_sign, char *buffer_digits, __zp($51) char format_min_length, char format_justify_left, char format_sign_always, char format_zero_padding, char format_upper_case, char format_radix)
printf_number_buffer: {
    .label buffer_digits = printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    .label putc = cputc
    .label __19 = $49
    .label buffer_sign = $52
    .label format_min_length = $51
    .label len = $4e
    .label padding = $4e
    // if(format.min_length)
    // [353] if(0==printf_number_buffer::format_min_length#0) goto printf_number_buffer::@1 -- 0_eq_vbuz1_then_la1 
    lda.z format_min_length
    beq __b4
    // [354] phi from printf_number_buffer to printf_number_buffer::@4 [phi:printf_number_buffer->printf_number_buffer::@4]
    // printf_number_buffer::@4
    // strlen(buffer.digits)
    // [355] call strlen
    // [328] phi from printf_number_buffer::@4 to strlen [phi:printf_number_buffer::@4->strlen]
    // [328] phi strlen::str#5 = printf_number_buffer::buffer_digits#0 [phi:printf_number_buffer::@4->strlen#0] -- pbuz1=pbuc1 
    lda #<buffer_digits
    sta.z strlen.str
    lda #>buffer_digits
    sta.z strlen.str+1
    jsr strlen
    // strlen(buffer.digits)
    // [356] strlen::return#3 = strlen::len#2
    // printf_number_buffer::@9
    // [357] printf_number_buffer::$19 = strlen::return#3
    // signed char len = (signed char)strlen(buffer.digits)
    // [358] printf_number_buffer::len#0 = (signed char)printf_number_buffer::$19 -- vbsz1=_sbyte_vwuz2 
    // There is a minimum length - work out the padding
    lda.z __19
    sta.z len
    // if(buffer.sign)
    // [359] if(0==printf_number_buffer::buffer_sign#0) goto printf_number_buffer::@8 -- 0_eq_vbuz1_then_la1 
    lda.z buffer_sign
    beq __b8
    // printf_number_buffer::@5
    // len++;
    // [360] printf_number_buffer::len#1 = ++ printf_number_buffer::len#0 -- vbsz1=_inc_vbsz1 
    inc.z len
    // [361] phi from printf_number_buffer::@5 printf_number_buffer::@9 to printf_number_buffer::@8 [phi:printf_number_buffer::@5/printf_number_buffer::@9->printf_number_buffer::@8]
    // [361] phi printf_number_buffer::len#2 = printf_number_buffer::len#1 [phi:printf_number_buffer::@5/printf_number_buffer::@9->printf_number_buffer::@8#0] -- register_copy 
    // printf_number_buffer::@8
  __b8:
    // padding = (signed char)format.min_length - len
    // [362] printf_number_buffer::padding#1 = (signed char)printf_number_buffer::format_min_length#0 - printf_number_buffer::len#2 -- vbsz1=vbsz2_minus_vbsz1 
    lda.z format_min_length
    sec
    sbc.z padding
    sta.z padding
    // if(padding<0)
    // [363] if(printf_number_buffer::padding#1>=0) goto printf_number_buffer::@11 -- vbsz1_ge_0_then_la1 
    cmp #0
    bpl __b1
    // [365] phi from printf_number_buffer printf_number_buffer::@8 to printf_number_buffer::@1 [phi:printf_number_buffer/printf_number_buffer::@8->printf_number_buffer::@1]
  __b4:
    // [365] phi printf_number_buffer::padding#10 = 0 [phi:printf_number_buffer/printf_number_buffer::@8->printf_number_buffer::@1#0] -- vbsz1=vbsc1 
    lda #0
    sta.z padding
    // [364] phi from printf_number_buffer::@8 to printf_number_buffer::@11 [phi:printf_number_buffer::@8->printf_number_buffer::@11]
    // printf_number_buffer::@11
    // [365] phi from printf_number_buffer::@11 to printf_number_buffer::@1 [phi:printf_number_buffer::@11->printf_number_buffer::@1]
    // [365] phi printf_number_buffer::padding#10 = printf_number_buffer::padding#1 [phi:printf_number_buffer::@11->printf_number_buffer::@1#0] -- register_copy 
    // printf_number_buffer::@1
  __b1:
    // printf_number_buffer::@10
    // if(!format.justify_left && !format.zero_padding && padding)
    // [366] if(0!=printf_number_buffer::padding#10) goto printf_number_buffer::@6 -- 0_neq_vbsz1_then_la1 
    lda.z padding
    cmp #0
    bne __b6
    jmp __b2
    // printf_number_buffer::@6
  __b6:
    // printf_padding(putc, ' ',(char)padding)
    // [367] printf_padding::length#0 = (char)printf_number_buffer::padding#10
    // [368] call printf_padding
    // [415] phi from printf_number_buffer::@6 to printf_padding [phi:printf_number_buffer::@6->printf_padding]
    jsr printf_padding
    // printf_number_buffer::@2
  __b2:
    // if(buffer.sign)
    // [369] if(0==printf_number_buffer::buffer_sign#0) goto printf_number_buffer::@3 -- 0_eq_vbuz1_then_la1 
    lda.z buffer_sign
    beq __b3
    // printf_number_buffer::@7
    // putc(buffer.sign)
    // [370] stackpush(char) = printf_number_buffer::buffer_sign#0 -- _stackpushbyte_=vbuz1 
    pha
    // [371] callexecute cputc  -- call_vprc1 
    jsr cputc
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    // [373] phi from printf_number_buffer::@2 printf_number_buffer::@7 to printf_number_buffer::@3 [phi:printf_number_buffer::@2/printf_number_buffer::@7->printf_number_buffer::@3]
    // printf_number_buffer::@3
  __b3:
    // printf_str(putc, buffer.digits)
    // [374] call printf_str
    // [269] phi from printf_number_buffer::@3 to printf_str [phi:printf_number_buffer::@3->printf_str]
    // [269] phi printf_str::putc#18 = printf_number_buffer::putc#0 [phi:printf_number_buffer::@3->printf_str#0] -- pprz1=pprc1 
    lda #<putc
    sta.z printf_str.putc
    lda #>putc
    sta.z printf_str.putc+1
    // [269] phi printf_str::s#18 = printf_number_buffer::buffer_digits#0 [phi:printf_number_buffer::@3->printf_str#1] -- pbuz1=pbuc1 
    lda #<buffer_digits
    sta.z printf_str.s
    lda #>buffer_digits
    sta.z printf_str.s+1
    jsr printf_str
    // printf_number_buffer::@return
    // }
    // [375] return 
    rts
}
  // insertup
// Insert a new line, and scroll the upper part of the screen up.
insertup: {
    .label __3 = $33
    .label cy = $35
    .label width = $34
    .label line = $2e
    .label start = $2e
    .label i = $32
    // unsigned char cy = __conio.cursor_y
    // [376] insertup::cy#0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y) -- vbuz1=_deref_pbuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_Y
    sta.z cy
    // unsigned char width = __conio.width * 2
    // [377] insertup::width#0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_WIDTH) << 1 -- vbuz1=_deref_pbuc1_rol_1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_WIDTH
    asl
    sta.z width
    // [378] phi from insertup to insertup::@1 [phi:insertup->insertup::@1]
    // [378] phi insertup::i#2 = 1 [phi:insertup->insertup::@1#0] -- vbuz1=vbuc1 
    lda #1
    sta.z i
    // insertup::@1
  __b1:
    // for(unsigned char i=1; i<=cy; i++)
    // [379] if(insertup::i#2<=insertup::cy#0) goto insertup::@2 -- vbuz1_le_vbuz2_then_la1 
    lda.z cy
    cmp.z i
    bcs __b2
    // [380] phi from insertup::@1 to insertup::@3 [phi:insertup::@1->insertup::@3]
    // insertup::@3
    // clearline()
    // [381] call clearline
    jsr clearline
    // insertup::@return
    // }
    // [382] return 
    rts
    // insertup::@2
  __b2:
    // i-1
    // [383] insertup::$3 = insertup::i#2 - 1 -- vbuz1=vbuz2_minus_1 
    ldx.z i
    dex
    stx.z __3
    // unsigned int line = (i-1) << __conio.rowshift
    // [384] insertup::line#0 = insertup::$3 << *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT) -- vwuz1=vbuz2_rol__deref_pbuc1 
    txa
    ldy __conio+OFFSET_STRUCT_CX16_CONIO_ROWSHIFT
    sta.z line
    lda #0
    sta.z line+1
    cpy #0
    beq !e+
  !:
    asl.z line
    rol.z line+1
    dey
    bne !-
  !e:
    // unsigned int start = __conio.mapbase_offset + line
    // [385] insertup::start#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET) + insertup::line#0 -- vwuz1=_deref_pwuc1_plus_vwuz1 
    clc
    lda.z start
    adc __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET
    sta.z start
    lda.z start+1
    adc __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET+1
    sta.z start+1
    // memcpy_vram_vram_inc(0, start, VERA_INC_1, 0, start+__conio.rowskip, VERA_INC_1, width)
    // [386] memcpy_vram_vram_inc::soffset_vram#0 = insertup::start#0 + *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP) -- vwuz1=vwuz2_plus__deref_pwuc1 
    lda.z start
    clc
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP
    sta.z memcpy_vram_vram_inc.soffset_vram
    lda.z start+1
    adc __conio+OFFSET_STRUCT_CX16_CONIO_ROWSKIP+1
    sta.z memcpy_vram_vram_inc.soffset_vram+1
    // [387] memcpy_vram_vram_inc::doffset_vram#0 = insertup::start#0
    // [388] memcpy_vram_vram_inc::num#0 = insertup::width#0 -- vwuz1=vbuz2 
    lda.z width
    sta.z memcpy_vram_vram_inc.num
    lda #0
    sta.z memcpy_vram_vram_inc.num+1
    // [389] call memcpy_vram_vram_inc
    // [423] phi from insertup::@2 to memcpy_vram_vram_inc [phi:insertup::@2->memcpy_vram_vram_inc]
    jsr memcpy_vram_vram_inc
    // insertup::@4
    // for(unsigned char i=1; i<=cy; i++)
    // [390] insertup::i#1 = ++ insertup::i#2 -- vbuz1=_inc_vbuz1 
    inc.z i
    // [378] phi from insertup::@4 to insertup::@1 [phi:insertup::@4->insertup::@1]
    // [378] phi insertup::i#2 = insertup::i#1 [phi:insertup::@4->insertup::@1#0] -- register_copy 
    jmp __b1
}
  // clearline
clearline: {
    .label __1 = $2b
    .label __2 = $2c
    .label mapbase_offset = $30
    .label conio_line = $28
    .label addr = $30
    .label color = $2a
    .label c = $26
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [391] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    // Select DATA0
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // unsigned int mapbase_offset =  (unsigned int)__conio.mapbase_offset
    // [392] clearline::mapbase_offset#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET) -- vwuz1=_deref_pwuc1 
    // Set address
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET
    sta.z mapbase_offset
    lda __conio+OFFSET_STRUCT_CX16_CONIO_MAPBASE_OFFSET+1
    sta.z mapbase_offset+1
    // unsigned int conio_line = __conio.line
    // [393] clearline::conio_line#0 = *((unsigned int *)&__conio+OFFSET_STRUCT_CX16_CONIO_LINE) -- vwuz1=_deref_pwuc1 
    lda __conio+OFFSET_STRUCT_CX16_CONIO_LINE
    sta.z conio_line
    lda __conio+OFFSET_STRUCT_CX16_CONIO_LINE+1
    sta.z conio_line+1
    // mapbase_offset + conio_line
    // [394] clearline::addr#0 = clearline::mapbase_offset#0 + clearline::conio_line#0 -- vwuz1=vwuz1_plus_vwuz2 
    clc
    lda.z addr
    adc.z conio_line
    sta.z addr
    lda.z addr+1
    adc.z conio_line+1
    sta.z addr+1
    // BYTE0(addr)
    // [395] clearline::$1 = byte0  (char *)clearline::addr#0 -- vbuz1=_byte0_pbuz2 
    lda.z addr
    sta.z __1
    // *VERA_ADDRX_L = BYTE0(addr)
    // [396] *VERA_ADDRX_L = clearline::$1 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_L
    // BYTE1(addr)
    // [397] clearline::$2 = byte1  (char *)clearline::addr#0 -- vbuz1=_byte1_pbuz2 
    lda.z addr+1
    sta.z __2
    // *VERA_ADDRX_M = BYTE1(addr)
    // [398] *VERA_ADDRX_M = clearline::$2 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // *VERA_ADDRX_H = VERA_INC_1
    // [399] *VERA_ADDRX_H = VERA_INC_1 -- _deref_pbuc1=vbuc2 
    lda #VERA_INC_1
    sta VERA_ADDRX_H
    // char color = __conio.color
    // [400] clearline::color#0 = *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_COLOR) -- vbuz1=_deref_pbuc1 
    // TODO need to check this!
    lda __conio+OFFSET_STRUCT_CX16_CONIO_COLOR
    sta.z color
    // [401] phi from clearline to clearline::@1 [phi:clearline->clearline::@1]
    // [401] phi clearline::c#2 = 0 [phi:clearline->clearline::@1#0] -- vwuz1=vwuc1 
    lda #<0
    sta.z c
    sta.z c+1
    // clearline::@1
  __b1:
    // for( unsigned int c=0;c<__conio.width; c++ )
    // [402] if(clearline::c#2<*((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_WIDTH)) goto clearline::@2 -- vwuz1_lt__deref_pbuc1_then_la1 
    lda.z c+1
    bne !+
    lda.z c
    cmp __conio+OFFSET_STRUCT_CX16_CONIO_WIDTH
    bcc __b2
  !:
    // clearline::@3
    // __conio.cursor_x = 0
    // [403] *((char *)&__conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X) = 0 -- _deref_pbuc1=vbuc2 
    lda #0
    sta __conio+OFFSET_STRUCT_CX16_CONIO_CURSOR_X
    // clearline::@return
    // }
    // [404] return 
    rts
    // clearline::@2
  __b2:
    // *VERA_DATA0 = ' '
    // [405] *VERA_DATA0 = ' ' -- _deref_pbuc1=vbuc2 
    // Set data
    lda #' '
    sta VERA_DATA0
    // *VERA_DATA0 = color
    // [406] *VERA_DATA0 = clearline::color#0 -- _deref_pbuc1=vbuz1 
    lda.z color
    sta VERA_DATA0
    // for( unsigned int c=0;c<__conio.width; c++ )
    // [407] clearline::c#1 = ++ clearline::c#2 -- vwuz1=_inc_vwuz1 
    inc.z c
    bne !+
    inc.z c+1
  !:
    // [401] phi from clearline::@2 to clearline::@1 [phi:clearline::@2->clearline::@1]
    // [401] phi clearline::c#2 = clearline::c#1 [phi:clearline::@2->clearline::@1#0] -- register_copy 
    jmp __b1
}
  // uctoa_append
// Used to convert a single digit of an unsigned number value to a string representation
// Counts a single digit up from '0' as long as the value is larger than sub.
// Each time the digit is increased sub is subtracted from value.
// - buffer : pointer to the char that receives the digit
// - value : The value where the digit will be derived from
// - sub : the value of a '1' in the digit. Subtracted continually while the digit is increased.
//        (For decimal the subs used are 10000, 1000, 100, 10, 1)
// returns : the value reduced by sub * digit so that it is less than sub.
// __zp($3a) char uctoa_append(__zp($4f) char *buffer, __zp($3a) char value, __zp($3e) char sub)
uctoa_append: {
    .label buffer = $4f
    .label value = $3a
    .label sub = $3e
    .label return = $3a
    .label digit = $3b
    // [409] phi from uctoa_append to uctoa_append::@1 [phi:uctoa_append->uctoa_append::@1]
    // [409] phi uctoa_append::digit#2 = 0 [phi:uctoa_append->uctoa_append::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z digit
    // [409] phi uctoa_append::value#2 = uctoa_append::value#0 [phi:uctoa_append->uctoa_append::@1#1] -- register_copy 
    // uctoa_append::@1
  __b1:
    // while (value >= sub)
    // [410] if(uctoa_append::value#2>=uctoa_append::sub#0) goto uctoa_append::@2 -- vbuz1_ge_vbuz2_then_la1 
    lda.z value
    cmp.z sub
    bcs __b2
    // uctoa_append::@3
    // *buffer = DIGITS[digit]
    // [411] *uctoa_append::buffer#0 = DIGITS[uctoa_append::digit#2] -- _deref_pbuz1=pbuc1_derefidx_vbuz2 
    ldy.z digit
    lda DIGITS,y
    ldy #0
    sta (buffer),y
    // uctoa_append::@return
    // }
    // [412] return 
    rts
    // uctoa_append::@2
  __b2:
    // digit++;
    // [413] uctoa_append::digit#1 = ++ uctoa_append::digit#2 -- vbuz1=_inc_vbuz1 
    inc.z digit
    // value -= sub
    // [414] uctoa_append::value#1 = uctoa_append::value#2 - uctoa_append::sub#0 -- vbuz1=vbuz1_minus_vbuz2 
    lda.z value
    sec
    sbc.z sub
    sta.z value
    // [409] phi from uctoa_append::@2 to uctoa_append::@1 [phi:uctoa_append::@2->uctoa_append::@1]
    // [409] phi uctoa_append::digit#2 = uctoa_append::digit#1 [phi:uctoa_append::@2->uctoa_append::@1#0] -- register_copy 
    // [409] phi uctoa_append::value#2 = uctoa_append::value#1 [phi:uctoa_append::@2->uctoa_append::@1#1] -- register_copy 
    jmp __b1
}
  // printf_padding
// Print a padding char a number of times
// void printf_padding(void (*putc)(char), char pad, __zp($4e) char length)
printf_padding: {
    .label i = $48
    .label length = $4e
    // [416] phi from printf_padding to printf_padding::@1 [phi:printf_padding->printf_padding::@1]
    // [416] phi printf_padding::i#2 = 0 [phi:printf_padding->printf_padding::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z i
    // printf_padding::@1
  __b1:
    // for(char i=0;i<length; i++)
    // [417] if(printf_padding::i#2<printf_padding::length#0) goto printf_padding::@2 -- vbuz1_lt_vbuz2_then_la1 
    lda.z i
    cmp.z length
    bcc __b2
    // printf_padding::@return
    // }
    // [418] return 
    rts
    // printf_padding::@2
  __b2:
    // putc(pad)
    // [419] stackpush(char) = ' ' -- _stackpushbyte_=vbuc1 
    lda #' '
    pha
    // [420] callexecute cputc  -- call_vprc1 
    jsr cputc
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    // printf_padding::@3
    // for(char i=0;i<length; i++)
    // [422] printf_padding::i#1 = ++ printf_padding::i#2 -- vbuz1=_inc_vbuz1 
    inc.z i
    // [416] phi from printf_padding::@3 to printf_padding::@1 [phi:printf_padding::@3->printf_padding::@1]
    // [416] phi printf_padding::i#2 = printf_padding::i#1 [phi:printf_padding::@3->printf_padding::@1#0] -- register_copy 
    jmp __b1
}
  // memcpy_vram_vram_inc
/**
 * @brief Copy block of memory from vram to vram with specified vera increments/decrements.
 * Copies num bytes from the source vram bank/offset to the destination vram bank/offset, with specified increment/decrement.
 *
 * @param dbank_vram Destination vram bank.
 * @param doffset_vram Destination vram offset.
 * @param dinc Destination vram increment/decrement.
 * @param sbank_vram Source vram bank.
 * @param soffset_vram Source vram offset.
 * @param sinc Source vram increment/decrement.
 * @param num Amount of bytes to copy.
 */
// void memcpy_vram_vram_inc(char dbank_vram, __zp($2e) unsigned int doffset_vram, char dinc, char sbank_vram, __zp($30) unsigned int soffset_vram, char sinc, __zp($28) unsigned int num)
memcpy_vram_vram_inc: {
    .label vera_vram_data0_bank_offset1___0 = $2b
    .label vera_vram_data0_bank_offset1___1 = $2c
    .label vera_vram_data1_bank_offset1___0 = $2a
    .label vera_vram_data1_bank_offset1___1 = $2d
    .label i = $26
    .label doffset_vram = $2e
    .label soffset_vram = $30
    .label num = $28
    // memcpy_vram_vram_inc::vera_vram_data0_bank_offset1
    // *VERA_CTRL &= ~VERA_ADDRSEL
    // [424] *VERA_CTRL = *VERA_CTRL & ~VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_band_vbuc2 
    lda #VERA_ADDRSEL^$ff
    and VERA_CTRL
    sta VERA_CTRL
    // BYTE0(offset)
    // [425] memcpy_vram_vram_inc::vera_vram_data0_bank_offset1_$0 = byte0  memcpy_vram_vram_inc::soffset_vram#0 -- vbuz1=_byte0_vwuz2 
    lda.z soffset_vram
    sta.z vera_vram_data0_bank_offset1___0
    // *VERA_ADDRX_L = BYTE0(offset)
    // [426] *VERA_ADDRX_L = memcpy_vram_vram_inc::vera_vram_data0_bank_offset1_$0 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_L
    // BYTE1(offset)
    // [427] memcpy_vram_vram_inc::vera_vram_data0_bank_offset1_$1 = byte1  memcpy_vram_vram_inc::soffset_vram#0 -- vbuz1=_byte1_vwuz2 
    lda.z soffset_vram+1
    sta.z vera_vram_data0_bank_offset1___1
    // *VERA_ADDRX_M = BYTE1(offset)
    // [428] *VERA_ADDRX_M = memcpy_vram_vram_inc::vera_vram_data0_bank_offset1_$1 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // *VERA_ADDRX_H = bank | inc_dec
    // [429] *VERA_ADDRX_H = VERA_INC_1 -- _deref_pbuc1=vbuc2 
    lda #VERA_INC_1
    sta VERA_ADDRX_H
    // memcpy_vram_vram_inc::vera_vram_data1_bank_offset1
    // *VERA_CTRL |= VERA_ADDRSEL
    // [430] *VERA_CTRL = *VERA_CTRL | VERA_ADDRSEL -- _deref_pbuc1=_deref_pbuc1_bor_vbuc2 
    lda #VERA_ADDRSEL
    ora VERA_CTRL
    sta VERA_CTRL
    // BYTE0(offset)
    // [431] memcpy_vram_vram_inc::vera_vram_data1_bank_offset1_$0 = byte0  memcpy_vram_vram_inc::doffset_vram#0 -- vbuz1=_byte0_vwuz2 
    lda.z doffset_vram
    sta.z vera_vram_data1_bank_offset1___0
    // *VERA_ADDRX_L = BYTE0(offset)
    // [432] *VERA_ADDRX_L = memcpy_vram_vram_inc::vera_vram_data1_bank_offset1_$0 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_L
    // BYTE1(offset)
    // [433] memcpy_vram_vram_inc::vera_vram_data1_bank_offset1_$1 = byte1  memcpy_vram_vram_inc::doffset_vram#0 -- vbuz1=_byte1_vwuz2 
    lda.z doffset_vram+1
    sta.z vera_vram_data1_bank_offset1___1
    // *VERA_ADDRX_M = BYTE1(offset)
    // [434] *VERA_ADDRX_M = memcpy_vram_vram_inc::vera_vram_data1_bank_offset1_$1 -- _deref_pbuc1=vbuz1 
    sta VERA_ADDRX_M
    // *VERA_ADDRX_H = bank | inc_dec
    // [435] *VERA_ADDRX_H = VERA_INC_1 -- _deref_pbuc1=vbuc2 
    lda #VERA_INC_1
    sta VERA_ADDRX_H
    // [436] phi from memcpy_vram_vram_inc::vera_vram_data1_bank_offset1 to memcpy_vram_vram_inc::@1 [phi:memcpy_vram_vram_inc::vera_vram_data1_bank_offset1->memcpy_vram_vram_inc::@1]
    // [436] phi memcpy_vram_vram_inc::i#2 = 0 [phi:memcpy_vram_vram_inc::vera_vram_data1_bank_offset1->memcpy_vram_vram_inc::@1#0] -- vwuz1=vwuc1 
    lda #<0
    sta.z i
    sta.z i+1
  // Transfer the data
    // memcpy_vram_vram_inc::@1
  __b1:
    // for(unsigned int i=0; i<num; i++)
    // [437] if(memcpy_vram_vram_inc::i#2<memcpy_vram_vram_inc::num#0) goto memcpy_vram_vram_inc::@2 -- vwuz1_lt_vwuz2_then_la1 
    lda.z i+1
    cmp.z num+1
    bcc __b2
    bne !+
    lda.z i
    cmp.z num
    bcc __b2
  !:
    // memcpy_vram_vram_inc::@return
    // }
    // [438] return 
    rts
    // memcpy_vram_vram_inc::@2
  __b2:
    // *VERA_DATA1 = *VERA_DATA0
    // [439] *VERA_DATA1 = *VERA_DATA0 -- _deref_pbuc1=_deref_pbuc2 
    lda VERA_DATA0
    sta VERA_DATA1
    // for(unsigned int i=0; i<num; i++)
    // [440] memcpy_vram_vram_inc::i#1 = ++ memcpy_vram_vram_inc::i#2 -- vwuz1=_inc_vwuz1 
    inc.z i
    bne !+
    inc.z i+1
  !:
    // [436] phi from memcpy_vram_vram_inc::@2 to memcpy_vram_vram_inc::@1 [phi:memcpy_vram_vram_inc::@2->memcpy_vram_vram_inc::@1]
    // [436] phi memcpy_vram_vram_inc::i#2 = memcpy_vram_vram_inc::i#1 [phi:memcpy_vram_vram_inc::@2->memcpy_vram_vram_inc::@1#0] -- register_copy 
    jmp __b1
}
  // File Data
.segment Data
  VERA_LAYER_WIDTH: .word $20, $40, $80, $100
  VERA_LAYER_HEIGHT: .word $20, $40, $80, $100
  VERA_LAYER_SKIP: .word $40, $80, $100, $200
  // The digits used for numbers
  DIGITS: .text "0123456789abcdef"
  // Values of decimal digits
  RADIX_DECIMAL_VALUES_CHAR: .byte $64, $a
  __conio: .fill SIZEOF_STRUCT_CX16_CONIO, 0
  // Buffer used for stringified number being printed
  printf_buffer: .fill SIZEOF_STRUCT_PRINTF_BUFFER_NUMBER, 0
