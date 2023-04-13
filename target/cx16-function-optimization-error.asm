  // File Comments
  // Upstart
.cpu _65c02
  // Commodore 64 PRG executable file
.file [name="cx16-function-optimization-error.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(main)
  // Global Constants & labels
  .const STAGE_ACTION_MOVE = 2
  .const STAGE_ACTION_TURN = 3
  .const STAGE_ACTION_END = $ff
.segment Code
  // main
main: {
    .label __13 = 7
    .label type = 2
    .label e = 8
    .label a = 6
    // [1] phi from main to main::@1 [phi:main->main::@1]
    // [1] phi main::e#2 = 0 [phi:main->main::@1#0] -- vbuz1=vbuc1 
    lda #0
    sta.z e
    // main::@1
  __b1:
    // for(char e = 0; e<2; e++)
    // [2] if(main::e#2<2) goto main::@2 -- vbuz1_lt_vbuc1_then_la1 
    lda.z e
    cmp #2
    bcc __b3
    // main::@return
    // }
    // [3] return 
    rts
    // [4] phi from main::@1 to main::@2 [phi:main::@1->main::@2]
  __b3:
    // [4] phi main::a#10 = 0 [phi:main::@1->main::@2#0] -- vbuz1=vbuc1 
    lda #0
    sta.z a
    // main::@2
  __b2:
    // for(char a = 0; a<2; a++)
    // [5] if(main::a#10<2) goto main::@7 -- vbuz1_lt_vbuc1_then_la1 
    lda.z a
    cmp #2
    bcc __b7
    // main::@3
    // for(char e = 0; e<2; e++)
    // [6] main::e#1 = ++ main::e#2 -- vbuz1=_inc_vbuz1 
    inc.z e
    // [1] phi from main::@3 to main::@1 [phi:main::@3->main::@1]
    // [1] phi main::e#2 = main::e#1 [phi:main::@3->main::@1#0] -- register_copy 
    jmp __b1
    // main::@7
  __b7:
    // unsigned char type = stage_get_flightpath_type(flightpaths[e], a)
    // [7] main::$13 = main::e#2 << 1 -- vbuz1=vbuz2_rol_1 
    lda.z e
    asl
    sta.z __13
    // [8] stage_get_flightpath_type::flightpath#0 = flightpaths[main::$13] -- pssz1=qssc1_derefidx_vbuz2 
    tay
    lda flightpaths,y
    sta.z stage_get_flightpath_type.flightpath
    lda flightpaths+1,y
    sta.z stage_get_flightpath_type.flightpath+1
    // [9] stage_get_flightpath_type::action#0 = main::a#10 -- vbuz1=vbuz2 
    lda.z a
    sta.z stage_get_flightpath_type.action
    // [10] call stage_get_flightpath_type
    jsr stage_get_flightpath_type
    // [11] stage_get_flightpath_type::return#2 = stage_get_flightpath_type::return#0
    // main::@8
    // [12] main::type#0 = stage_get_flightpath_type::return#2
    // main::@9
    // if(type == STAGE_ACTION_MOVE)
    // [13] if(main::type#0!=STAGE_ACTION_MOVE) goto main::@4 -- vbuz1_neq_vbuc1_then_la1 
    lda #STAGE_ACTION_MOVE
    cmp.z type
    // [14] phi from main::@9 to main::@10 [phi:main::@9->main::@10]
    // main::@10
    // main::@4
    // if(type == STAGE_ACTION_END)
    // [15] if(main::type#0!=STAGE_ACTION_END) goto main::@5 -- vbuz1_neq_vbuc1_then_la1 
    lda #STAGE_ACTION_END
    cmp.z type
    // [16] phi from main::@4 to main::@6 [phi:main::@4->main::@6]
    // main::@6
    // main::@5
    // for(char a = 0; a<2; a++)
    // [17] main::a#1 = ++ main::a#10 -- vbuz1=_inc_vbuz1 
    inc.z a
    // [4] phi from main::@5 to main::@2 [phi:main::@5->main::@2]
    // [4] phi main::a#10 = main::a#1 [phi:main::@5->main::@2#0] -- register_copy 
    jmp __b2
}
  // stage_get_flightpath_type
// __zp(2) char stage_get_flightpath_type(__zp(3) struct $4 *flightpath, __zp(2) char action)
stage_get_flightpath_type: {
    .label __0 = 2
    .label __1 = 3
    .label return = 2
    .label flightpath = 3
    .label action = 2
    .label __3 = 5
    .label __4 = 2
    // unsigned char type = flightpath[action].type
    // [18] stage_get_flightpath_type::$3 = stage_get_flightpath_type::action#0 << 1 -- vbuz1=vbuz2_rol_1 
    lda.z action
    asl
    sta.z __3
    // [19] stage_get_flightpath_type::$4 = stage_get_flightpath_type::$3 + stage_get_flightpath_type::action#0 -- vbuz1=vbuz2_plus_vbuz1 
    lda.z __4
    clc
    adc.z __3
    sta.z __4
    // [20] stage_get_flightpath_type::$0 = stage_get_flightpath_type::$4 << 1 -- vbuz1=vbuz1_rol_1 
    asl.z __0
    // [21] stage_get_flightpath_type::$1 = (char *)stage_get_flightpath_type::flightpath#0 + 4 -- pbuz1=pbuz1_plus_vbuc1 
    lda #4
    clc
    adc.z __1
    sta.z __1
    bcc !+
    inc.z __1+1
  !:
    // [22] stage_get_flightpath_type::return#0 = stage_get_flightpath_type::$1[stage_get_flightpath_type::$0] -- vbuz1=pbuz2_derefidx_vbuz1 
    ldy.z return
    lda (__1),y
    sta.z return
    // stage_get_flightpath_type::@return
    // }
    // [23] return 
    rts
}
  // File Data
.segment Data
  action_flightpath_001: .word $1e0+$40
  .byte $10, 3, STAGE_ACTION_MOVE, 1, $18, 4, 3
  .fill 1, 0
  .byte STAGE_ACTION_TURN, 2, 0
  .fill 3, 0
  .byte STAGE_ACTION_END, 0
  action_flightpath_004: .word $300
  .byte $20, 4, STAGE_ACTION_MOVE, 1, 0
  .fill 3, 0
  .byte STAGE_ACTION_END, 0
  flightpaths: .word action_flightpath_001, action_flightpath_004
