; The sound effects are copied onto of the option menu code, once that one ran at launch

.include "DrCreep.inc"

; This is NASTY! With some linker trickery, it might be solvable…
;
; The optionsMenu and the sound effects are compiled to the _same_ base address.
; During initialization the option menu is build and then the code is replaced by the
; sound effect code, which in the binary is stored just behind it.
; This saves some needed memory. For now I compile the option menu at the correct address
; and create another code block with just the sound effects for the same address.
; The make script then appends it to the object.prg. That all works fine,
; _but_ the entry point and all patches to the note values during the runtime are
; now hardcoded in the table below. Any changes in the sound effects and these addresses
; need to be corrected. AFAIK the KickAssembler can do this: compile code for a different
; address than where it ends up. CA65 doesn't seem to have an easy way to do this.
; And because I want to move on and probably patching the sound effects is rare, I
; just created this table of pointers.

; Code entriess for the sound effects, which is an overlay
; SNDEFFECT_DOOR_OPEN_NOTE := $75B7
; SNDEFFECT_FORCEFIELD_TIMER_NOTE := $75AB
; SNDEFFECT_LASER_FIRED_NOTE := $7593
; SNDEFFECT_LIGHTNING_SWITCHED_NOTE := $75E7
; SNDEFFECT_MOVINGSIDEWALK_SWITCH_NOTE := $7624
; SNDEFFECT_MUMMY_RELEASE_NOTE := $7630
; SNDEFFECT_SPRITE_FLASH_NOTE := $760C
; SNDEFFECT_TABLE := $7572
; SNDEFFECT_TELEPORT_CHANGE_NOTE := $75DB
; SNDEFFECT_TELEPORT_NOTE := $75CF
; SNDEFFECT_TRAPDOOR_SWITCHED_NOTE := $759F


				.CODE
				.ORG OPTION_MENU_START
SNDEFFECT_TABLE:.addr SNDEFFECT_LASER_FIRED; 0
                .addr SNDEFFECT_TRAPDOOR_SWITCHED; 1
                .addr SNDEFFECT_FORCEFIELD_TIMER; 2
                .addr SNDEFFECT_DOOR_OPEN; 3
                .addr SNDEFFECT_TELEPORT; 4
                .addr SNDEFFECT_TELEPORT_CHANGE; 5
                .addr SNDEFFECT_LIGHTNING_SWITCHED; 6
                .addr SNDEFFECT_FRANKENSTEIN_WAKEUP; 7
                .addr SNDEFFECT_SPRITE_FLASH; 8
                .addr SNDEFFECT_MAP_CLOSE; 9
                .addr SNDEFFECT_MOVINGSIDEWALK_SWITCH; 10
                .addr SNDEFFECT_MUMMY_RELEASE; 11
                .addr SNDEFFECT_KEY_PICKUP; 12

SNDEFFECT_LASER_FIRED:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $80, $A, $A
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_LASER_FIRED_NOTE:.BYTE 177
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_TRAPDOOR_SWITCHED:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $20, $A, $A
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_TRAPDOOR_SWITCHED_NOTE:.BYTE 137
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_FORCEFIELD_TIMER:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $10, $A, $A
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_FORCEFIELD_TIMER_NOTE:.BYTE 133
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_DOOR_OPEN:.BYTE SOUND_CMDS::SET_ADSR_etc|2
                _SID_ADSR 128, $40, $A, $A
                .BYTE SOUND_CMDS::PLAY_NOTE|2
SNDEFFECT_DOOR_OPEN_NOTE:.BYTE 165
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY|2
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_TELEPORT:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $14, $C, $C
                .BYTE SOUND_CMDS::SET_ADSR_etc|1
                _SID_ADSR 0, $14, $C, $C
                .BYTE SOUND_CMDS::SET_ADSR_etc|2
                _SID_ADSR 0, $14, $C, $C
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_TELEPORT_NOTE:.BYTE 160
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_TELEPORT_CHANGE:.BYTE SOUND_CMDS::SET_ADSR_etc|1
                _SID_ADSR 384, $40, $80, 0
                .BYTE SOUND_CMDS::PLAY_NOTE|1
SNDEFFECT_TELEPORT_CHANGE_NOTE:.BYTE 176
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 18
                .BYTE SOUND_CMDS::START_PLAY|1
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_LIGHTNING_SWITCHED:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $80, 8, 8
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_LIGHTNING_SWITCHED_NOTE:.BYTE 160
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_FRANKENSTEIN_WAKEUP:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $80, $C, $C
                .BYTE SOUND_CMDS::SET_ADSR_etc|1
                _SID_ADSR 64, $40, $C, $C
                .BYTE SOUND_CMDS::SET_TRANSPOSE
                .BYTE SID_NOTE::C0
                .BYTE SOUND_CMDS::SET_TRANSPOSE|1
                .BYTE SID_NOTE::C0
                .BYTE SOUND_CMDS::PLAY_NOTE
                .BYTE SID_NOTE::C0
                .BYTE SOUND_CMDS::PLAY_NOTE|1
                .BYTE SID_NOTE::C1
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::START_PLAY|1
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_SPRITE_FLASH:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $10, 6, 6
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_SPRITE_FLASH_NOTE:.BYTE 150
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_MAP_CLOSE:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $10, $B, $B
                .BYTE SOUND_CMDS::PLAY_NOTE
                .BYTE SID_NOTE::G3
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_MOVINGSIDEWALK_SWITCH:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $80, 9, 9
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_MOVINGSIDEWALK_SWITCH_NOTE:.BYTE 160
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_MUMMY_RELEASE:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $80, 9, 9
                .BYTE SOUND_CMDS::PLAY_NOTE
SNDEFFECT_MUMMY_RELEASE_NOTE:.BYTE 128
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

SNDEFFECT_KEY_PICKUP:.BYTE SOUND_CMDS::SET_ADSR_etc
                _SID_ADSR 0, $10, 9, 9
                .BYTE SOUND_CMDS::PLAY_NOTE
                .BYTE SID_NOTE::Ds5
                .BYTE SOUND_CMDS::SET_DURATION_MSB
                .BYTE 2
                .BYTE SOUND_CMDS::START_PLAY
                .BYTE SOUND_CMDS::EOF

				.BYTE $6D
SNDEFFECT_TABLE_INIT:
