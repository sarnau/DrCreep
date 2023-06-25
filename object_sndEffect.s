; The sound effects are copied onto of the option menu code, once that one ran at launch

.include "DrCreep.inc"

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
