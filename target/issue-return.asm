  // File Comments
/// @file
/// Commodore 64 Registers and Constants
/// @file
/// The MOS 6526 Complex Interface Adapter (CIA)
///
/// http://archive.6502.org/datasheets/mos_6526_cia_recreated.pdf
  // Upstart
  // Commodore 64 PRG executable file
.file [name="issue-return.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(__start)
  // Global Constants & labels
  .const LIGHT_BLUE = $e
  .const OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS = 1
  .const STACK_BASE = $103
  .const SIZEOF_STRUCT_PRINTF_BUFFER_NUMBER = $c
  /// Color Ram
  .label COLORRAM = $d800
  /// Default address of screen character matrix
  .label DEFAULT_SCREEN = $400
  // The number of bytes on the screen
  // The current cursor x-position
  .label conio_cursor_x = $17
  // The current cursor y-position
  .label conio_cursor_y = $12
  // The current text cursor line start
  .label conio_line_text = $15
  // The current color cursor line start
  .label conio_line_color = $13
.segment Code
  // __start
__start: {
    // __start::__init1
    // __ma char conio_cursor_x = 0
    // [1] conio_cursor_x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z conio_cursor_x
    // __ma char conio_cursor_y = 0
    // [2] conio_cursor_y = 0 -- vbuz1=vbuc1 
    sta.z conio_cursor_y
    // __ma char *conio_line_text = CONIO_SCREEN_TEXT
    // [3] conio_line_text = DEFAULT_SCREEN -- pbuz1=pbuc1 
    lda #<DEFAULT_SCREEN
    sta.z conio_line_text
    lda #>DEFAULT_SCREEN
    sta.z conio_line_text+1
    // __ma char *conio_line_color = CONIO_SCREEN_COLORS
    // [4] conio_line_color = COLORRAM -- pbuz1=pbuc1 
    lda #<COLORRAM
    sta.z conio_line_color
    lda #>COLORRAM
    sta.z conio_line_color+1
    // #pragma constructor_for(conio_c64_init, cputc, clrscr, cscroll)
    // [5] call conio_c64_init
    jsr conio_c64_init
    // [6] phi from __start::__init1 to __start::@1 [phi:__start::__init1->__start::@1]
    // __start::@1
    // [7] call main
    // [27] phi from __start::@1 to main [phi:__start::@1->main]
    jsr main
    // __start::@return
    // [8] return 
    rts
}
  // conio_c64_init
// Set initial cursor position
conio_c64_init: {
    // Position cursor at current line
    .label BASIC_CURSOR_LINE = $d6
    .label line = $1e
    // char line = *BASIC_CURSOR_LINE
    // [9] conio_c64_init::line#0 = *conio_c64_init::BASIC_CURSOR_LINE -- vbuz1=_deref_pbuc1 
    lda.z BASIC_CURSOR_LINE
    sta.z line
    // if(line>=CONIO_HEIGHT)
    // [10] if(conio_c64_init::line#0<$19) goto conio_c64_init::@2 -- vbuz1_lt_vbuc1_then_la1 
    cmp #$19
    bcc __b1
    // [12] phi from conio_c64_init to conio_c64_init::@1 [phi:conio_c64_init->conio_c64_init::@1]
    // [12] phi conio_c64_init::line#2 = $19-1 [phi:conio_c64_init->conio_c64_init::@1#0] -- vbuz1=vbuc1 
    lda #$19-1
    sta.z line
    // [11] phi from conio_c64_init to conio_c64_init::@2 [phi:conio_c64_init->conio_c64_init::@2]
    // conio_c64_init::@2
    // [12] phi from conio_c64_init::@2 to conio_c64_init::@1 [phi:conio_c64_init::@2->conio_c64_init::@1]
    // [12] phi conio_c64_init::line#2 = conio_c64_init::line#0 [phi:conio_c64_init::@2->conio_c64_init::@1#0] -- register_copy 
    // conio_c64_init::@1
  __b1:
    // gotoxy(0, line)
    // [13] gotoxy::y#2 = conio_c64_init::line#2
    // [14] call gotoxy
    // [42] phi from conio_c64_init::@1 to gotoxy [phi:conio_c64_init::@1->gotoxy]
    // [42] phi gotoxy::y#4 = gotoxy::y#2 [phi:conio_c64_init::@1->gotoxy#0] -- register_copy 
    jsr gotoxy
    // conio_c64_init::@return
    // }
    // [15] return 
    rts
}
  // cputc
// Output one character at the current cursor position
// Moves the cursor forward. Scrolls the entire screen if needed
// void cputc(__zp(9) char c)
cputc: {
    .const OFFSET_STACK_C = 0
    .label c = 9
    // [16] cputc::c#0 = stackidx(char,cputc::OFFSET_STACK_C) -- vbuz1=_stackidxbyte_vbuc1 
    tsx
    lda STACK_BASE+OFFSET_STACK_C,x
    sta.z c
    // if(c=='\n')
    // [17] if(cputc::c#0==' ') goto cputc::@1 -- vbuz1_eq_vbuc1_then_la1 
    lda #'\n'
    cmp.z c
    beq __b1
    // cputc::@2
    // conio_line_text[conio_cursor_x] = c
    // [18] conio_line_text[conio_cursor_x] = cputc::c#0 -- pbuz1_derefidx_vbuz2=vbuz3 
    lda.z c
    ldy.z conio_cursor_x
    sta (conio_line_text),y
    // conio_line_color[conio_cursor_x] = conio_textcolor
    // [19] conio_line_color[conio_cursor_x] = LIGHT_BLUE -- pbuz1_derefidx_vbuz2=vbuc1 
    lda #LIGHT_BLUE
    sta (conio_line_color),y
    // if(++conio_cursor_x==CONIO_WIDTH)
    // [20] conio_cursor_x = ++ conio_cursor_x -- vbuz1=_inc_vbuz1 
    inc.z conio_cursor_x
    // [21] if(conio_cursor_x!=$28) goto cputc::@return -- vbuz1_neq_vbuc1_then_la1 
    lda #$28
    cmp.z conio_cursor_x
    bne __breturn
    // [22] phi from cputc::@2 to cputc::@3 [phi:cputc::@2->cputc::@3]
    // cputc::@3
    // cputln()
    // [23] call cputln
    jsr cputln
    // cputc::@return
  __breturn:
    // }
    // [24] return 
    rts
    // [25] phi from cputc to cputc::@1 [phi:cputc->cputc::@1]
    // cputc::@1
  __b1:
    // cputln()
    // [26] call cputln
    jsr cputln
    rts
}
  // main
main: {
    .label key_get1_return = $20
    .label i = $1f
    // clrscr()
    // [28] call clrscr
    // [63] phi from main to clrscr [phi:main->clrscr]
    jsr clrscr
    // [29] phi from main to main::@3 [phi:main->main::@3]
    // main::@3
    // gotoxy(0,1)
    // [30] call gotoxy
    // [42] phi from main::@3 to gotoxy [phi:main::@3->gotoxy]
    // [42] phi gotoxy::y#4 = 1 [phi:main::@3->gotoxy#0] -- vbuz1=vbuc1 
    lda #1
    sta.z gotoxy.y
    jsr gotoxy
    // [31] phi from main::@3 to main::@1 [phi:main::@3->main::@1]
    // [31] phi main::i#2 = 5 [phi:main::@3->main::@1#0] -- vbuz1=vbuc1 
    lda #5
    sta.z i
    // [31] phi from main::@6 to main::@1 [phi:main::@6->main::@1]
    // [31] phi main::i#2 = main::i#1 [phi:main::@6->main::@1#0] -- register_copy 
    // main::@1
    // main::key_get1
    // key % 256
    // [32] main::key_get1_return#0 = main::i#2 & $100-1
    // [33] phi from main::key_get1 to main::@2 [phi:main::key_get1->main::@2]
    // main::@2
  __b2:
    // printf("i=%u\n", key_get(i))
    // [34] call printf_str
    // [79] phi from main::@2 to printf_str [phi:main::@2->printf_str]
    // [79] phi printf_str::putc#5 = &cputc [phi:main::@2->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [79] phi printf_str::s#5 = main::s [phi:main::@2->printf_str#1] -- pbuz1=pbuc1 
    lda #<s
    sta.z printf_str.s
    lda #>s
    sta.z printf_str.s+1
    jsr printf_str
    // [35] phi from main::@2 to main::@4 [phi:main::@2->main::@4]
    // main::@4
    // printf("i=%u\n", key_get(i))
    // [36] call printf_uchar
    // [88] phi from main::@4 to printf_uchar [phi:main::@4->printf_uchar]
    jsr printf_uchar
    // [37] phi from main::@4 to main::@5 [phi:main::@4->main::@5]
    // main::@5
    // printf("i=%u\n", key_get(i))
    // [38] call printf_str
    // [79] phi from main::@5 to printf_str [phi:main::@5->printf_str]
    // [79] phi printf_str::putc#5 = &cputc [phi:main::@5->printf_str#0] -- pprz1=pprc1 
    lda #<cputc
    sta.z printf_str.putc
    lda #>cputc
    sta.z printf_str.putc+1
    // [79] phi printf_str::s#5 = main::s1 [phi:main::@5->printf_str#1] -- pbuz1=pbuc1 
    lda #<s1
    sta.z printf_str.s
    lda #>s1
    sta.z printf_str.s+1
    jsr printf_str
    // main::@6
    // i++;
    // [39] main::i#1 = ++ main::i#2 -- vbuz1=_inc_vbuz1 
    inc.z i
    // while(i<10)
    // [40] if(main::i#1<$a) goto main::@1 -- vbuz1_lt_vbuc1_then_la1 
    lda.z i
    cmp #$a
    bcc __b2
    // main::@return
    // }
    // [41] return 
    rts
  .segment Data
    s: .text "i="
    .byte 0
    s1: .text @"\n"
    .byte 0
}
.segment Code
  // gotoxy
// Set the cursor to the specified position
// void gotoxy(char x, __zp($1e) char y)
gotoxy: {
    .label __5 = $1c
    .label __6 = $18
    .label __7 = $18
    .label line_offset = $18
    .label y = $1e
    .label __8 = $1a
    .label __9 = $18
    // if(y>CONIO_HEIGHT)
    // [43] if(gotoxy::y#4<$19+1) goto gotoxy::@3 -- vbuz1_lt_vbuc1_then_la1 
    lda.z y
    cmp #$19+1
    bcc __b2
    // [45] phi from gotoxy to gotoxy::@1 [phi:gotoxy->gotoxy::@1]
    // [45] phi gotoxy::y#5 = 0 [phi:gotoxy->gotoxy::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z y
    // [44] phi from gotoxy to gotoxy::@3 [phi:gotoxy->gotoxy::@3]
    // gotoxy::@3
    // [45] phi from gotoxy::@3 to gotoxy::@1 [phi:gotoxy::@3->gotoxy::@1]
    // [45] phi gotoxy::y#5 = gotoxy::y#4 [phi:gotoxy::@3->gotoxy::@1#0] -- register_copy 
    // gotoxy::@1
    // gotoxy::@2
  __b2:
    // conio_cursor_x = x
    // [46] conio_cursor_x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z conio_cursor_x
    // conio_cursor_y = y
    // [47] conio_cursor_y = gotoxy::y#5 -- vbuz1=vbuz2 
    lda.z y
    sta.z conio_cursor_y
    // unsigned int line_offset = (unsigned int)y*CONIO_WIDTH
    // [48] gotoxy::$7 = (unsigned int)gotoxy::y#5 -- vwuz1=_word_vbuz2 
    lda.z y
    sta.z __7
    lda #0
    sta.z __7+1
    // [49] gotoxy::$8 = gotoxy::$7 << 2 -- vwuz1=vwuz2_rol_2 
    lda.z __7
    asl
    sta.z __8
    lda.z __7+1
    rol
    sta.z __8+1
    asl.z __8
    rol.z __8+1
    // [50] gotoxy::$9 = gotoxy::$8 + gotoxy::$7 -- vwuz1=vwuz2_plus_vwuz1 
    clc
    lda.z __9
    adc.z __8
    sta.z __9
    lda.z __9+1
    adc.z __8+1
    sta.z __9+1
    // [51] gotoxy::line_offset#0 = gotoxy::$9 << 3 -- vwuz1=vwuz1_rol_3 
    asl.z line_offset
    rol.z line_offset+1
    asl.z line_offset
    rol.z line_offset+1
    asl.z line_offset
    rol.z line_offset+1
    // CONIO_SCREEN_TEXT + line_offset
    // [52] gotoxy::$5 = DEFAULT_SCREEN + gotoxy::line_offset#0 -- pbuz1=pbuc1_plus_vwuz2 
    lda.z line_offset
    clc
    adc #<DEFAULT_SCREEN
    sta.z __5
    lda.z line_offset+1
    adc #>DEFAULT_SCREEN
    sta.z __5+1
    // conio_line_text = CONIO_SCREEN_TEXT + line_offset
    // [53] conio_line_text = gotoxy::$5 -- pbuz1=pbuz2 
    lda.z __5
    sta.z conio_line_text
    lda.z __5+1
    sta.z conio_line_text+1
    // CONIO_SCREEN_COLORS + line_offset
    // [54] gotoxy::$6 = COLORRAM + gotoxy::line_offset#0 -- pbuz1=pbuc1_plus_vwuz1 
    lda.z __6
    clc
    adc #<COLORRAM
    sta.z __6
    lda.z __6+1
    adc #>COLORRAM
    sta.z __6+1
    // conio_line_color = CONIO_SCREEN_COLORS + line_offset
    // [55] conio_line_color = gotoxy::$6 -- pbuz1=pbuz2 
    lda.z __6
    sta.z conio_line_color
    lda.z __6+1
    sta.z conio_line_color+1
    // gotoxy::@return
    // }
    // [56] return 
    rts
}
  // cputln
// Print a newline
cputln: {
    // conio_line_text +=  CONIO_WIDTH
    // [57] conio_line_text = conio_line_text + $28 -- pbuz1=pbuz1_plus_vbuc1 
    lda #$28
    clc
    adc.z conio_line_text
    sta.z conio_line_text
    bcc !+
    inc.z conio_line_text+1
  !:
    // conio_line_color += CONIO_WIDTH
    // [58] conio_line_color = conio_line_color + $28 -- pbuz1=pbuz1_plus_vbuc1 
    lda #$28
    clc
    adc.z conio_line_color
    sta.z conio_line_color
    bcc !+
    inc.z conio_line_color+1
  !:
    // conio_cursor_x = 0
    // [59] conio_cursor_x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z conio_cursor_x
    // conio_cursor_y++;
    // [60] conio_cursor_y = ++ conio_cursor_y -- vbuz1=_inc_vbuz1 
    inc.z conio_cursor_y
    // cscroll()
    // [61] call cscroll
    jsr cscroll
    // cputln::@return
    // }
    // [62] return 
    rts
}
  // clrscr
// clears the screen and moves the cursor to the upper left-hand corner of the screen.
clrscr: {
    .label c = 4
    .label line_text = $f
    .label line_cols = $c
    .label l = $11
    // [64] phi from clrscr to clrscr::@1 [phi:clrscr->clrscr::@1]
    // [64] phi clrscr::line_cols#5 = COLORRAM [phi:clrscr->clrscr::@1#0] -- pbuz1=pbuc1 
    lda #<COLORRAM
    sta.z line_cols
    lda #>COLORRAM
    sta.z line_cols+1
    // [64] phi clrscr::line_text#5 = DEFAULT_SCREEN [phi:clrscr->clrscr::@1#1] -- pbuz1=pbuc1 
    lda #<DEFAULT_SCREEN
    sta.z line_text
    lda #>DEFAULT_SCREEN
    sta.z line_text+1
    // [64] phi clrscr::l#2 = 0 [phi:clrscr->clrscr::@1#2] -- vbuz1=vbuc1 
    lda #0
    sta.z l
    // clrscr::@1
  __b1:
    // for( char l=0;l<CONIO_HEIGHT; l++ )
    // [65] if(clrscr::l#2<$19) goto clrscr::@3 -- vbuz1_lt_vbuc1_then_la1 
    lda.z l
    cmp #$19
    bcc __b2
    // clrscr::@2
    // conio_cursor_x = 0
    // [66] conio_cursor_x = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z conio_cursor_x
    // conio_cursor_y = 0
    // [67] conio_cursor_y = 0 -- vbuz1=vbuc1 
    sta.z conio_cursor_y
    // conio_line_text = CONIO_SCREEN_TEXT
    // [68] conio_line_text = DEFAULT_SCREEN -- pbuz1=pbuc1 
    lda #<DEFAULT_SCREEN
    sta.z conio_line_text
    lda #>DEFAULT_SCREEN
    sta.z conio_line_text+1
    // conio_line_color = CONIO_SCREEN_COLORS
    // [69] conio_line_color = COLORRAM -- pbuz1=pbuc1 
    lda #<COLORRAM
    sta.z conio_line_color
    lda #>COLORRAM
    sta.z conio_line_color+1
    // clrscr::@return
    // }
    // [70] return 
    rts
    // [71] phi from clrscr::@1 to clrscr::@3 [phi:clrscr::@1->clrscr::@3]
  __b2:
    // [71] phi clrscr::c#2 = 0 [phi:clrscr::@1->clrscr::@3#0] -- vbuz1=vbuc1 
    lda #0
    sta.z c
    // clrscr::@3
  __b3:
    // for( char c=0;c<CONIO_WIDTH; c++ )
    // [72] if(clrscr::c#2<$28) goto clrscr::@4 -- vbuz1_lt_vbuc1_then_la1 
    lda.z c
    cmp #$28
    bcc __b4
    // clrscr::@5
    // line_text += CONIO_WIDTH
    // [73] clrscr::line_text#1 = clrscr::line_text#5 + $28 -- pbuz1=pbuz1_plus_vbuc1 
    lda #$28
    clc
    adc.z line_text
    sta.z line_text
    bcc !+
    inc.z line_text+1
  !:
    // line_cols += CONIO_WIDTH
    // [74] clrscr::line_cols#1 = clrscr::line_cols#5 + $28 -- pbuz1=pbuz1_plus_vbuc1 
    lda #$28
    clc
    adc.z line_cols
    sta.z line_cols
    bcc !+
    inc.z line_cols+1
  !:
    // for( char l=0;l<CONIO_HEIGHT; l++ )
    // [75] clrscr::l#1 = ++ clrscr::l#2 -- vbuz1=_inc_vbuz1 
    inc.z l
    // [64] phi from clrscr::@5 to clrscr::@1 [phi:clrscr::@5->clrscr::@1]
    // [64] phi clrscr::line_cols#5 = clrscr::line_cols#1 [phi:clrscr::@5->clrscr::@1#0] -- register_copy 
    // [64] phi clrscr::line_text#5 = clrscr::line_text#1 [phi:clrscr::@5->clrscr::@1#1] -- register_copy 
    // [64] phi clrscr::l#2 = clrscr::l#1 [phi:clrscr::@5->clrscr::@1#2] -- register_copy 
    jmp __b1
    // clrscr::@4
  __b4:
    // line_text[c] = ' '
    // [76] clrscr::line_text#5[clrscr::c#2] = ' ' -- pbuz1_derefidx_vbuz2=vbuc1 
    lda #' '
    ldy.z c
    sta (line_text),y
    // line_cols[c] = conio_textcolor
    // [77] clrscr::line_cols#5[clrscr::c#2] = LIGHT_BLUE -- pbuz1_derefidx_vbuz2=vbuc1 
    lda #LIGHT_BLUE
    sta (line_cols),y
    // for( char c=0;c<CONIO_WIDTH; c++ )
    // [78] clrscr::c#1 = ++ clrscr::c#2 -- vbuz1=_inc_vbuz1 
    inc.z c
    // [71] phi from clrscr::@4 to clrscr::@3 [phi:clrscr::@4->clrscr::@3]
    // [71] phi clrscr::c#2 = clrscr::c#1 [phi:clrscr::@4->clrscr::@3#0] -- register_copy 
    jmp __b3
}
  // printf_str
/// Print a NUL-terminated string
// void printf_str(__zp($f) void (*putc)(char), __zp($c) const char *s)
printf_str: {
    .label c = $e
    .label s = $c
    .label putc = $f
    // [80] phi from printf_str printf_str::@2 to printf_str::@1 [phi:printf_str/printf_str::@2->printf_str::@1]
    // [80] phi printf_str::s#4 = printf_str::s#5 [phi:printf_str/printf_str::@2->printf_str::@1#0] -- register_copy 
    // printf_str::@1
  __b1:
    // while(c=*s++)
    // [81] printf_str::c#1 = *printf_str::s#4 -- vbuz1=_deref_pbuz2 
    ldy #0
    lda (s),y
    sta.z c
    // [82] printf_str::s#0 = ++ printf_str::s#4 -- pbuz1=_inc_pbuz1 
    inc.z s
    bne !+
    inc.z s+1
  !:
    // [83] if(0!=printf_str::c#1) goto printf_str::@2 -- 0_neq_vbuz1_then_la1 
    lda.z c
    bne __b2
    // printf_str::@return
    // }
    // [84] return 
    rts
    // printf_str::@2
  __b2:
    // putc(c)
    // [85] stackpush(char) = printf_str::c#1 -- _stackpushbyte_=vbuz1 
    lda.z c
    pha
    // [86] callexecute *printf_str::putc#5  -- call__deref_pprz1 
    jsr icall1
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    jmp __b1
    // Outside Flow
  icall1:
    jmp (putc)
}
  // printf_uchar
// Print an unsigned char using a specific format
// void printf_uchar(void (*putc)(char), char uvalue, char format_min_length, char format_justify_left, char format_sign_always, char format_zero_padding, char format_upper_case, char format_radix)
printf_uchar: {
    .label putc = cputc
    // printf_uchar::@1
    // printf_buffer.sign = format.sign_always?'+':0
    // [89] *((char *)&printf_buffer) = 0 -- _deref_pbuc1=vbuc2 
    // Handle any sign
    lda #0
    sta printf_buffer
    // uctoa(uvalue, printf_buffer.digits, format.radix)
    // [90] uctoa::value#1 = main::key_get1_return#0 -- vbuz1=vbuz2 
    lda.z main.key_get1_return
    sta.z uctoa.value
    // [91] call uctoa
  // Format number into buffer
    // [108] phi from printf_uchar::@1 to uctoa [phi:printf_uchar::@1->uctoa]
    jsr uctoa
    // printf_uchar::@2
    // printf_number_buffer(putc, printf_buffer, format)
    // [92] printf_number_buffer::buffer_sign#0 = *((char *)&printf_buffer) -- vbuz1=_deref_pbuc1 
    lda printf_buffer
    sta.z printf_number_buffer.buffer_sign
    // [93] call printf_number_buffer
  // Print using format
    // [127] phi from printf_uchar::@2 to printf_number_buffer [phi:printf_uchar::@2->printf_number_buffer]
    jsr printf_number_buffer
    // printf_uchar::@return
    // }
    // [94] return 
    rts
}
  // cscroll
// Scroll the entire screen if the cursor is beyond the last line
cscroll: {
    // if(conio_cursor_y==CONIO_HEIGHT)
    // [95] if(conio_cursor_y!=$19) goto cscroll::@return -- vbuz1_neq_vbuc1_then_la1 
    lda #$19
    cmp.z conio_cursor_y
    bne __breturn
    // [96] phi from cscroll to cscroll::@1 [phi:cscroll->cscroll::@1]
    // cscroll::@1
    // memcpy(CONIO_SCREEN_TEXT, CONIO_SCREEN_TEXT+CONIO_WIDTH, CONIO_BYTES-CONIO_WIDTH)
    // [97] call memcpy
    // [135] phi from cscroll::@1 to memcpy [phi:cscroll::@1->memcpy]
    // [135] phi memcpy::destination#2 = (void *)DEFAULT_SCREEN [phi:cscroll::@1->memcpy#0] -- pvoz1=pvoc1 
    lda #<DEFAULT_SCREEN
    sta.z memcpy.destination
    lda #>DEFAULT_SCREEN
    sta.z memcpy.destination+1
    // [135] phi memcpy::source#2 = (void *)DEFAULT_SCREEN+$28 [phi:cscroll::@1->memcpy#1] -- pvoz1=pvoc1 
    lda #<DEFAULT_SCREEN+$28
    sta.z memcpy.source
    lda #>DEFAULT_SCREEN+$28
    sta.z memcpy.source+1
    jsr memcpy
    // [98] phi from cscroll::@1 to cscroll::@2 [phi:cscroll::@1->cscroll::@2]
    // cscroll::@2
    // memcpy(CONIO_SCREEN_COLORS, CONIO_SCREEN_COLORS+CONIO_WIDTH, CONIO_BYTES-CONIO_WIDTH)
    // [99] call memcpy
    // [135] phi from cscroll::@2 to memcpy [phi:cscroll::@2->memcpy]
    // [135] phi memcpy::destination#2 = (void *)COLORRAM [phi:cscroll::@2->memcpy#0] -- pvoz1=pvoc1 
    lda #<COLORRAM
    sta.z memcpy.destination
    lda #>COLORRAM
    sta.z memcpy.destination+1
    // [135] phi memcpy::source#2 = (void *)COLORRAM+$28 [phi:cscroll::@2->memcpy#1] -- pvoz1=pvoc1 
    lda #<COLORRAM+$28
    sta.z memcpy.source
    lda #>COLORRAM+$28
    sta.z memcpy.source+1
    jsr memcpy
    // [100] phi from cscroll::@2 to cscroll::@3 [phi:cscroll::@2->cscroll::@3]
    // cscroll::@3
    // memset(CONIO_SCREEN_TEXT+CONIO_BYTES-CONIO_WIDTH, ' ', CONIO_WIDTH)
    // [101] call memset
    // [145] phi from cscroll::@3 to memset [phi:cscroll::@3->memset]
    // [145] phi memset::c#4 = ' ' [phi:cscroll::@3->memset#0] -- vbuz1=vbuc1 
    lda #' '
    sta.z memset.c
    // [145] phi memset::str#3 = (void *)DEFAULT_SCREEN+(unsigned int)$19*$28-$28 [phi:cscroll::@3->memset#1] -- pvoz1=pvoc1 
    lda #<DEFAULT_SCREEN+$19*$28-$28
    sta.z memset.str
    lda #>DEFAULT_SCREEN+$19*$28-$28
    sta.z memset.str+1
    jsr memset
    // [102] phi from cscroll::@3 to cscroll::@4 [phi:cscroll::@3->cscroll::@4]
    // cscroll::@4
    // memset(CONIO_SCREEN_COLORS+CONIO_BYTES-CONIO_WIDTH, conio_textcolor, CONIO_WIDTH)
    // [103] call memset
    // [145] phi from cscroll::@4 to memset [phi:cscroll::@4->memset]
    // [145] phi memset::c#4 = LIGHT_BLUE [phi:cscroll::@4->memset#0] -- vbuz1=vbuc1 
    lda #LIGHT_BLUE
    sta.z memset.c
    // [145] phi memset::str#3 = (void *)COLORRAM+(unsigned int)$19*$28-$28 [phi:cscroll::@4->memset#1] -- pvoz1=pvoc1 
    lda #<COLORRAM+$19*$28-$28
    sta.z memset.str
    lda #>COLORRAM+$19*$28-$28
    sta.z memset.str+1
    jsr memset
    // cscroll::@5
    // conio_line_text -= CONIO_WIDTH
    // [104] conio_line_text = conio_line_text - $28 -- pbuz1=pbuz1_minus_vbuc1 
    sec
    lda.z conio_line_text
    sbc #$28
    sta.z conio_line_text
    lda.z conio_line_text+1
    sbc #0
    sta.z conio_line_text+1
    // conio_line_color -= CONIO_WIDTH
    // [105] conio_line_color = conio_line_color - $28 -- pbuz1=pbuz1_minus_vbuc1 
    sec
    lda.z conio_line_color
    sbc #$28
    sta.z conio_line_color
    lda.z conio_line_color+1
    sbc #0
    sta.z conio_line_color+1
    // conio_cursor_y--;
    // [106] conio_cursor_y = -- conio_cursor_y -- vbuz1=_dec_vbuz1 
    dec.z conio_cursor_y
    // cscroll::@return
  __breturn:
    // }
    // [107] return 
    rts
}
  // uctoa
// Converts unsigned number value to a string representing it in RADIX format.
// If the leading digits are zero they are not included in the string.
// - value : The number to be converted to RADIX
// - buffer : receives the string representing the number and zero-termination.
// - radix : The radix to convert the number to (from the enum RADIX)
// void uctoa(__zp(4) char value, __zp($f) char *buffer, char radix)
uctoa: {
    .const max_digits = 3
    .label digit_value = 8
    .label buffer = $f
    .label digit = $11
    .label value = 4
    .label started = $e
    // [109] phi from uctoa to uctoa::@1 [phi:uctoa->uctoa::@1]
    // [109] phi uctoa::buffer#11 = (char *)&printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS [phi:uctoa->uctoa::@1#0] -- pbuz1=pbuc1 
    lda #<printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    sta.z buffer
    lda #>printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    sta.z buffer+1
    // [109] phi uctoa::started#2 = 0 [phi:uctoa->uctoa::@1#1] -- vbuz1=vbuc1 
    lda #0
    sta.z started
    // [109] phi uctoa::value#2 = uctoa::value#1 [phi:uctoa->uctoa::@1#2] -- register_copy 
    // [109] phi uctoa::digit#2 = 0 [phi:uctoa->uctoa::@1#3] -- vbuz1=vbuc1 
    sta.z digit
    // uctoa::@1
  __b1:
    // for( char digit=0; digit<max_digits-1; digit++ )
    // [110] if(uctoa::digit#2<uctoa::max_digits#1-1) goto uctoa::@2 -- vbuz1_lt_vbuc1_then_la1 
    lda.z digit
    cmp #max_digits-1
    bcc __b2
    // uctoa::@3
    // *buffer++ = DIGITS[(char)value]
    // [111] *uctoa::buffer#11 = DIGITS[uctoa::value#2] -- _deref_pbuz1=pbuc1_derefidx_vbuz2 
    ldy.z value
    lda DIGITS,y
    ldy #0
    sta (buffer),y
    // *buffer++ = DIGITS[(char)value];
    // [112] uctoa::buffer#3 = ++ uctoa::buffer#11 -- pbuz1=_inc_pbuz1 
    inc.z buffer
    bne !+
    inc.z buffer+1
  !:
    // *buffer = 0
    // [113] *uctoa::buffer#3 = 0 -- _deref_pbuz1=vbuc1 
    lda #0
    tay
    sta (buffer),y
    // uctoa::@return
    // }
    // [114] return 
    rts
    // uctoa::@2
  __b2:
    // unsigned char digit_value = digit_values[digit]
    // [115] uctoa::digit_value#0 = RADIX_DECIMAL_VALUES_CHAR[uctoa::digit#2] -- vbuz1=pbuc1_derefidx_vbuz2 
    ldy.z digit
    lda RADIX_DECIMAL_VALUES_CHAR,y
    sta.z digit_value
    // if (started || value >= digit_value)
    // [116] if(0!=uctoa::started#2) goto uctoa::@5 -- 0_neq_vbuz1_then_la1 
    lda.z started
    bne __b5
    // uctoa::@7
    // [117] if(uctoa::value#2>=uctoa::digit_value#0) goto uctoa::@5 -- vbuz1_ge_vbuz2_then_la1 
    lda.z value
    cmp.z digit_value
    bcs __b5
    // [118] phi from uctoa::@7 to uctoa::@4 [phi:uctoa::@7->uctoa::@4]
    // [118] phi uctoa::buffer#14 = uctoa::buffer#11 [phi:uctoa::@7->uctoa::@4#0] -- register_copy 
    // [118] phi uctoa::started#4 = uctoa::started#2 [phi:uctoa::@7->uctoa::@4#1] -- register_copy 
    // [118] phi uctoa::value#6 = uctoa::value#2 [phi:uctoa::@7->uctoa::@4#2] -- register_copy 
    // uctoa::@4
  __b4:
    // for( char digit=0; digit<max_digits-1; digit++ )
    // [119] uctoa::digit#1 = ++ uctoa::digit#2 -- vbuz1=_inc_vbuz1 
    inc.z digit
    // [109] phi from uctoa::@4 to uctoa::@1 [phi:uctoa::@4->uctoa::@1]
    // [109] phi uctoa::buffer#11 = uctoa::buffer#14 [phi:uctoa::@4->uctoa::@1#0] -- register_copy 
    // [109] phi uctoa::started#2 = uctoa::started#4 [phi:uctoa::@4->uctoa::@1#1] -- register_copy 
    // [109] phi uctoa::value#2 = uctoa::value#6 [phi:uctoa::@4->uctoa::@1#2] -- register_copy 
    // [109] phi uctoa::digit#2 = uctoa::digit#1 [phi:uctoa::@4->uctoa::@1#3] -- register_copy 
    jmp __b1
    // uctoa::@5
  __b5:
    // uctoa_append(buffer++, value, digit_value)
    // [120] uctoa_append::buffer#0 = uctoa::buffer#11 -- pbuz1=pbuz2 
    lda.z buffer
    sta.z uctoa_append.buffer
    lda.z buffer+1
    sta.z uctoa_append.buffer+1
    // [121] uctoa_append::value#0 = uctoa::value#2
    // [122] uctoa_append::sub#0 = uctoa::digit_value#0
    // [123] call uctoa_append
    // [153] phi from uctoa::@5 to uctoa_append [phi:uctoa::@5->uctoa_append]
    jsr uctoa_append
    // uctoa_append(buffer++, value, digit_value)
    // [124] uctoa_append::return#0 = uctoa_append::value#2
    // uctoa::@6
    // value = uctoa_append(buffer++, value, digit_value)
    // [125] uctoa::value#0 = uctoa_append::return#0
    // value = uctoa_append(buffer++, value, digit_value);
    // [126] uctoa::buffer#4 = ++ uctoa::buffer#11 -- pbuz1=_inc_pbuz1 
    inc.z buffer
    bne !+
    inc.z buffer+1
  !:
    // [118] phi from uctoa::@6 to uctoa::@4 [phi:uctoa::@6->uctoa::@4]
    // [118] phi uctoa::buffer#14 = uctoa::buffer#4 [phi:uctoa::@6->uctoa::@4#0] -- register_copy 
    // [118] phi uctoa::started#4 = 1 [phi:uctoa::@6->uctoa::@4#1] -- vbuz1=vbuc1 
    lda #1
    sta.z started
    // [118] phi uctoa::value#6 = uctoa::value#0 [phi:uctoa::@6->uctoa::@4#2] -- register_copy 
    jmp __b4
}
  // printf_number_buffer
// Print the contents of the number buffer using a specific format.
// This handles minimum length, zero-filling, and left/right justification from the format
// void printf_number_buffer(void (*putc)(char), __zp(7) char buffer_sign, char *buffer_digits, char format_min_length, char format_justify_left, char format_sign_always, char format_zero_padding, char format_upper_case, char format_radix)
printf_number_buffer: {
    .label buffer_digits = printf_buffer+OFFSET_STRUCT_PRINTF_BUFFER_NUMBER_DIGITS
    .label buffer_sign = 7
    // printf_number_buffer::@1
    // if(buffer.sign)
    // [128] if(0==printf_number_buffer::buffer_sign#0) goto printf_number_buffer::@2 -- 0_eq_vbuz1_then_la1 
    lda.z buffer_sign
    beq __b2
    // printf_number_buffer::@3
    // putc(buffer.sign)
    // [129] stackpush(char) = printf_number_buffer::buffer_sign#0 -- _stackpushbyte_=vbuz1 
    pha
    // [130] callexecute cputc  -- call_vprc1 
    jsr cputc
    // sideeffect stackpullpadding(1) -- _stackpullpadding_1 
    pla
    // [132] phi from printf_number_buffer::@1 printf_number_buffer::@3 to printf_number_buffer::@2 [phi:printf_number_buffer::@1/printf_number_buffer::@3->printf_number_buffer::@2]
    // printf_number_buffer::@2
  __b2:
    // printf_str(putc, buffer.digits)
    // [133] call printf_str
    // [79] phi from printf_number_buffer::@2 to printf_str [phi:printf_number_buffer::@2->printf_str]
    // [79] phi printf_str::putc#5 = printf_uchar::putc#0 [phi:printf_number_buffer::@2->printf_str#0] -- pprz1=pprc1 
    lda #<printf_uchar.putc
    sta.z printf_str.putc
    lda #>printf_uchar.putc
    sta.z printf_str.putc+1
    // [79] phi printf_str::s#5 = printf_number_buffer::buffer_digits#0 [phi:printf_number_buffer::@2->printf_str#1] -- pbuz1=pbuc1 
    lda #<buffer_digits
    sta.z printf_str.s
    lda #>buffer_digits
    sta.z printf_str.s+1
    jsr printf_str
    // printf_number_buffer::@return
    // }
    // [134] return 
    rts
}
  // memcpy
// Copy block of memory (forwards)
// Copies the values of num bytes from the location pointed to by source directly to the memory block pointed to by destination.
// void * memcpy(__zp(5) void *destination, __zp(2) void *source, unsigned int num)
memcpy: {
    .label src_end = $a
    .label dst = 5
    .label src = 2
    .label source = 2
    .label destination = 5
    // char* src_end = (char*)source+num
    // [136] memcpy::src_end#0 = (char *)memcpy::source#2 + (unsigned int)$19*$28-$28 -- pbuz1=pbuz2_plus_vwuc1 
    lda.z source
    clc
    adc #<$19*$28-$28
    sta.z src_end
    lda.z source+1
    adc #>$19*$28-$28
    sta.z src_end+1
    // [137] memcpy::src#4 = (char *)memcpy::source#2
    // [138] memcpy::dst#4 = (char *)memcpy::destination#2
    // [139] phi from memcpy memcpy::@2 to memcpy::@1 [phi:memcpy/memcpy::@2->memcpy::@1]
    // [139] phi memcpy::dst#2 = memcpy::dst#4 [phi:memcpy/memcpy::@2->memcpy::@1#0] -- register_copy 
    // [139] phi memcpy::src#2 = memcpy::src#4 [phi:memcpy/memcpy::@2->memcpy::@1#1] -- register_copy 
    // memcpy::@1
  __b1:
    // while(src!=src_end)
    // [140] if(memcpy::src#2!=memcpy::src_end#0) goto memcpy::@2 -- pbuz1_neq_pbuz2_then_la1 
    lda.z src+1
    cmp.z src_end+1
    bne __b2
    lda.z src
    cmp.z src_end
    bne __b2
    // memcpy::@return
    // }
    // [141] return 
    rts
    // memcpy::@2
  __b2:
    // *dst++ = *src++
    // [142] *memcpy::dst#2 = *memcpy::src#2 -- _deref_pbuz1=_deref_pbuz2 
    ldy #0
    lda (src),y
    sta (dst),y
    // *dst++ = *src++;
    // [143] memcpy::dst#1 = ++ memcpy::dst#2 -- pbuz1=_inc_pbuz1 
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    // [144] memcpy::src#1 = ++ memcpy::src#2 -- pbuz1=_inc_pbuz1 
    inc.z src
    bne !+
    inc.z src+1
  !:
    jmp __b1
}
  // memset
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// void * memset(__zp(2) void *str, __zp(9) char c, unsigned int num)
memset: {
    .label end = 5
    .label dst = 2
    .label str = 2
    .label c = 9
    // memset::@1
    // char* end = (char*)str + num
    // [146] memset::end#0 = (char *)memset::str#3 + $28 -- pbuz1=pbuz2_plus_vbuc1 
    lda #$28
    clc
    adc.z str
    sta.z end
    lda #0
    adc.z str+1
    sta.z end+1
    // [147] memset::dst#4 = (char *)memset::str#3
    // [148] phi from memset::@1 memset::@3 to memset::@2 [phi:memset::@1/memset::@3->memset::@2]
    // [148] phi memset::dst#2 = memset::dst#4 [phi:memset::@1/memset::@3->memset::@2#0] -- register_copy 
    // memset::@2
  __b2:
    // for(char* dst = str; dst!=end; dst++)
    // [149] if(memset::dst#2!=memset::end#0) goto memset::@3 -- pbuz1_neq_pbuz2_then_la1 
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
    // memset::@return
    // }
    // [150] return 
    rts
    // memset::@3
  __b3:
    // *dst = c
    // [151] *memset::dst#2 = memset::c#4 -- _deref_pbuz1=vbuz2 
    lda.z c
    ldy #0
    sta (dst),y
    // for(char* dst = str; dst!=end; dst++)
    // [152] memset::dst#1 = ++ memset::dst#2 -- pbuz1=_inc_pbuz1 
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
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
// __zp(4) char uctoa_append(__zp($c) char *buffer, __zp(4) char value, __zp(8) char sub)
uctoa_append: {
    .label buffer = $c
    .label value = 4
    .label sub = 8
    .label return = 4
    .label digit = 7
    // [154] phi from uctoa_append to uctoa_append::@1 [phi:uctoa_append->uctoa_append::@1]
    // [154] phi uctoa_append::digit#2 = 0 [phi:uctoa_append->uctoa_append::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z digit
    // [154] phi uctoa_append::value#2 = uctoa_append::value#0 [phi:uctoa_append->uctoa_append::@1#1] -- register_copy 
    // uctoa_append::@1
  __b1:
    // while (value >= sub)
    // [155] if(uctoa_append::value#2>=uctoa_append::sub#0) goto uctoa_append::@2 -- vbuz1_ge_vbuz2_then_la1 
    lda.z value
    cmp.z sub
    bcs __b2
    // uctoa_append::@3
    // *buffer = DIGITS[digit]
    // [156] *uctoa_append::buffer#0 = DIGITS[uctoa_append::digit#2] -- _deref_pbuz1=pbuc1_derefidx_vbuz2 
    ldy.z digit
    lda DIGITS,y
    ldy #0
    sta (buffer),y
    // uctoa_append::@return
    // }
    // [157] return 
    rts
    // uctoa_append::@2
  __b2:
    // digit++;
    // [158] uctoa_append::digit#1 = ++ uctoa_append::digit#2 -- vbuz1=_inc_vbuz1 
    inc.z digit
    // value -= sub
    // [159] uctoa_append::value#1 = uctoa_append::value#2 - uctoa_append::sub#0 -- vbuz1=vbuz1_minus_vbuz2 
    lda.z value
    sec
    sbc.z sub
    sta.z value
    // [154] phi from uctoa_append::@2 to uctoa_append::@1 [phi:uctoa_append::@2->uctoa_append::@1]
    // [154] phi uctoa_append::digit#2 = uctoa_append::digit#1 [phi:uctoa_append::@2->uctoa_append::@1#0] -- register_copy 
    // [154] phi uctoa_append::value#2 = uctoa_append::value#1 [phi:uctoa_append::@2->uctoa_append::@1#1] -- register_copy 
    jmp __b1
}
  // File Data
.segment Data
  // The digits used for numbers
  DIGITS: .text "0123456789abcdef"
  // Values of decimal digits
  RADIX_DECIMAL_VALUES_CHAR: .byte $64, $a
  // Buffer used for stringified number being printed
  printf_buffer: .fill SIZEOF_STRUCT_PRINTF_BUFFER_NUMBER, 0
