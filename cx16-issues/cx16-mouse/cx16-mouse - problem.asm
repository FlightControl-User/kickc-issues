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
.file [name="cx16-mouse - problem.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(main)
  // Global Constants & labels
  // Common CBM Kernal Routines
  .const CBM_SETNAM = $ffbd
  ///< Set the name of a file.
  .const CBM_SETLFS = $ffba
  ///< Set the logical file.
  .const CBM_OPEN = $ffc0
  ///< Read a character from the current channel for input.
  .const CBM_CLOSE = $ffc3
  // CX16 CBM Mouse Routines
  .const CX16_MOUSE_CONFIG = $ff68
.segment Code
  // main
main: {
    // cx16_mouse_config(0x01, 80, 60)
    // [0] cx16_mouse_config::visible = 1 -- vbuz1=vbuc1 
    lda #1
    sta.z cx16_mouse_config.visible
    // [1] cx16_mouse_config::scalex = $50 -- vbuz1=vbuc1 
    lda #$50
    sta.z cx16_mouse_config.scalex
    // [2] cx16_mouse_config::scaley = $3c -- vbuz1=vbuc1 
    lda #$3c
    sta.z cx16_mouse_config.scaley
    // [3] call cx16_mouse_config
    jsr cx16_mouse_config
    // main::@1
    // cbm_k_setnam("FILE")
    // [4] cbm_k_setnam::filename = main::filename -- pbuz1=pbuc1 
    lda #<filename
    sta.z cbm_k_setnam.filename
    lda #>filename
    sta.z cbm_k_setnam.filename+1
    // [5] call cbm_k_setnam
    jsr cbm_k_setnam
    // main::@2
    // cbm_k_setlfs(1, 8, 0)
    // [6] cbm_k_setlfs::channel = 1 -- vbuz1=vbuc1 
    lda #1
    sta.z cbm_k_setlfs.channel
    // [7] cbm_k_setlfs::device = 8 -- vbuz1=vbuc1 
    lda #8
    sta.z cbm_k_setlfs.device
    // [8] cbm_k_setlfs::command = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z cbm_k_setlfs.command
    // [9] call cbm_k_setlfs
    // File name on the disk
    jsr cbm_k_setlfs
    // [10] phi from main::@2 to main::@3 [phi:main::@2->main::@3]
    // main::@3
    // cbm_k_open()
    // [11] call cbm_k_open
    // set the channel to be a file loaded from disk
    jsr cbm_k_open
    // main::@4
    // cbm_k_close(1)
    // [12] cbm_k_close::channel = 1 -- vbuz1=vbuc1 
    lda #1
    sta.z cbm_k_close.channel
    // [13] call cbm_k_close
    // open the file on the selected channel
    jsr cbm_k_close
    // main::@return
    // }
    // [14] return 
    rts
  .segment Data
    filename: .text "FILE"
    .byte 0
}
.segment Code
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
// void cx16_mouse_config(__zp($30) volatile char visible, __zp($2d) volatile char scalex, __zp($2b) volatile char scaley)
cx16_mouse_config: {
    .label visible = $30
    .label scalex = $2d
    .label scaley = $2b
    // asm
    // asm { ldavisible ldxscalex ldyscaley jsrCX16_MOUSE_CONFIG  }
    lda visible
    ldx scalex
    ldy scaley
    jsr CX16_MOUSE_CONFIG
    // cx16_mouse_config::@return
    // }
    // [16] return 
    rts
}
  // cbm_k_setnam
/**
 * @brief Sets the name of the file before opening.
 * 
 * @param filename The name of the file.
 */
// void cbm_k_setnam(__zp($29) char * volatile filename)
cbm_k_setnam: {
    .label filename = $29
    .label filename_len = $26
    .label __0 = $24
    // strlen(filename)
    // [17] strlen::str#0 = cbm_k_setnam::filename -- pbuz1=pbuz2 
    lda.z filename
    sta.z strlen.str
    lda.z filename+1
    sta.z strlen.str+1
    // [18] call strlen
    // [32] phi from cbm_k_setnam to strlen [phi:cbm_k_setnam->strlen]
    jsr strlen
    // strlen(filename)
    // [19] strlen::return#0 = strlen::len#2
    // cbm_k_setnam::@1
    // [20] cbm_k_setnam::$0 = strlen::return#0
    // char filename_len = (char)strlen(filename)
    // [21] cbm_k_setnam::filename_len = (char)cbm_k_setnam::$0 -- vbuz1=_byte_vwuz2 
    lda.z __0
    sta.z filename_len
    // asm
    // asm { ldafilename_len ldxfilename ldyfilename+1 jsrCBM_SETNAM  }
    ldx filename
    ldy filename+1
    jsr CBM_SETNAM
    // cbm_k_setnam::@return
    // }
    // [23] return 
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
// void cbm_k_setlfs(__zp($31) volatile char channel, __zp($2e) volatile char device, __zp($2c) volatile char command)
cbm_k_setlfs: {
    .label channel = $31
    .label device = $2e
    .label command = $2c
    // asm
    // asm { ldxdevice ldachannel ldycommand jsrCBM_SETLFS  }
    ldx device
    lda channel
    ldy command
    jsr CBM_SETLFS
    // cbm_k_setlfs::@return
    // }
    // [25] return 
    rts
}
  // cbm_k_open
/**
 * @brief Open a logical file.
 * 
 * @return char The status.
 */
cbm_k_open: {
    .label status = $27
    // char status
    // [26] cbm_k_open::status = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z status
    // asm
    // asm { jsrCBM_OPEN stastatus  }
    jsr CBM_OPEN
    sta status
    // cbm_k_open::@return
    // }
    // [28] return 
    rts
}
  // cbm_k_close
/**
 * @brief Close a logical file.
 * 
 * @param channel The channel to close.
 * @return char Status.
 */
// char cbm_k_close(__zp($2f) volatile char channel)
cbm_k_close: {
    .label channel = $2f
    .label status = $28
    // char status
    // [29] cbm_k_close::status = 0 -- vbuz1=vbuc1 
    lda #0
    sta.z status
    // asm
    // asm { ldachannel jsrCBM_CLOSE stastatus  }
    lda channel
    jsr CBM_CLOSE
    sta status
    // cbm_k_close::@return
    // }
    // [31] return 
    rts
}
  // strlen
// Computes the length of the string str up to but not including the terminating null character.
// __zp($24) unsigned int strlen(__zp($22) char *str)
strlen: {
    .label str = $22
    .label return = $24
    .label len = $24
    // [33] phi from strlen to strlen::@1 [phi:strlen->strlen::@1]
    // [33] phi strlen::len#2 = 0 [phi:strlen->strlen::@1#0] -- vwuz1=vwuc1 
    lda #<0
    sta.z len
    sta.z len+1
    // [33] phi strlen::str#2 = strlen::str#0 [phi:strlen->strlen::@1#1] -- register_copy 
    // strlen::@1
  __b1:
    // while(*str)
    // [34] if(0!=*strlen::str#2) goto strlen::@2 -- 0_neq__deref_pbuz1_then_la1 
    ldy #0
    lda (str),y
    cmp #0
    bne __b2
    // strlen::@return
    // }
    // [35] return 
    rts
    // strlen::@2
  __b2:
    // len++;
    // [36] strlen::len#1 = ++ strlen::len#2 -- vwuz1=_inc_vwuz1 
    inc.z len
    bne !+
    inc.z len+1
  !:
    // str++;
    // [37] strlen::str#1 = ++ strlen::str#2 -- pbuz1=_inc_pbuz1 
    inc.z str
    bne !+
    inc.z str+1
  !:
    // [33] phi from strlen::@2 to strlen::@1 [phi:strlen::@2->strlen::@1]
    // [33] phi strlen::len#2 = strlen::len#1 [phi:strlen::@2->strlen::@1#0] -- register_copy 
    // [33] phi strlen::str#2 = strlen::str#1 [phi:strlen::@2->strlen::@1#1] -- register_copy 
    jmp __b1
}
  // File Data
