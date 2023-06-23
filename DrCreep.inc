.include "C64_IO_REGS.inc"
.include "C64_KERNAL.inc"

SCREENRAM := $0400 ; original video base address
START := $800 ; BASIC memory start, used to load data
CREEPLOAD_START := $C000 ; code to load the title screen

; the VIC is mapped to the upper 16kb
TOP_SCREENRAM := $CC00 ; video memory, in highres multicolor mode the additional colors
TOP_HIGHRESVIDEORAM := $E000 ; address of the 8kb highres video data


; All different sound effects used by Dr Creep
.enum SOUND_EFFECT
	LASER_FIRED
	TRAPDOOR_SWITCHED
	FORCEFIELD_TIMER
	DOOR_OPEN
	TELEPORT
	TELEPORT_CHANGE
	LIGHTNING_SWITCHED
	FRANKENSTEIN_WAKEUP
	SPRITE_FLASH
	MAP_CLOSE
	MOVINGSIDEWALK_SWITCH
	MUMMY_RELEASE
	KEY_PICKUP
.endenum

; SID commands for sound effects and music
.enum SOUND_CMD
	PLAY_NOTE
	START_PLAY
	SET_DURATION_MSB
	SET_DURATION_LSB
	SET_ADSR_etc
	FILTER_AND_VOLUME
	SET_TRANSPOSE
	SET_FILTER
	SET_TIMER
	EOF
.endenum

; Bitmask version of the SOUND_CMD enum
.enum SOUND_CMDS
	PLAY_NOTE = (SOUND_CMD::PLAY_NOTE << 2) ; 2 bytes
	START_PLAY = (SOUND_CMD::START_PLAY << 2) ; 1 byte
	SET_DURATION_MSB = (SOUND_CMD::SET_DURATION_MSB << 2) ; 2 bytes
	SET_DURATION_LSB = (SOUND_CMD::SET_DURATION_LSB << 2) ; 2 bytes
	SET_ADSR_etc = (SOUND_CMD::SET_ADSR_etc << 2) ; 6 bytes
	FILTER_AND_VOLUME = (SOUND_CMD::FILTER_AND_VOLUME << 2) ; 5 bytes
	SET_TRANSPOSE = (SOUND_CMD::SET_TRANSPOSE << 2) ; 2 bytes
	SET_FILTER = (SOUND_CMD::SET_FILTER << 2) ; 2 bytes
	SET_TIMER = (SOUND_CMD::SET_TIMER << 2) ; 2 bytes
	EOF = (SOUND_CMD::EOF << 2) ; 1 byte
.endenum

.enum SCREEN_DRAW_MODE
	SCREEN_DRAW_MODE_Foreground
	SCREEN_DRAW_MODE_Mask
	SCREEN_DRAW_MODE_ForegroundAndMask
.endenum

.enum GfxID
	player_run_left_1
	player_run_left_2
	player_run_left_3
	player_run_right_1
	player_run_right_2
	player_run_right_3
	exit
	metal_gate
	diagonal_exit_path
	button
	roommap_floor_square
	roommap_topButtomEdge
	roommap_leftEdge
	roommap_rightEdge
	roommap_door_topButtomLeft
	roommap_door_topButtomRight
	roommap_door_left
	roommap_door_right
	roommap_arrow_up
	roommap_arrow_right
	roommap_arrow_down
	roommap_arrow_left
	imagedraw_placeholder
	unused_23
	unused_24
	unused_25
	unused_26
	walkway_left
	walkway_center
	walkway_right
	player_run_exit_1
	player_run_exit_2
	player_run_exit_3
	player_run_exit_4
	player_run_exit_5
	player_run_exit_6
	sliding_pole_plain
	sliding_pole_platform_mask
	player_climb_pole
	sliding_pole_empty
	ladder_top
	ladder_bottom_floor
	ladder_bottom_floor_mask
	ladder_middle
	ladder_middle_floor
	ladder_middle_floor_mask
	player_climb_ladder_1
	player_climb_ladder_2
	player_climb_ladder_3
	player_climb_ladder_4
	lightning_lightning_pole
	lightning_globe
	lightning_colormask
	forcefield_anim_1
	lightning_switch
	lightning_switch_on
	lightning_switch_off
	lightning_anim_1
	lightning_anim_2
	lightning_anim_3
	lightning_anim_4
	forcefield_anim_2
	forcefield_gate_top
	forcefield_switch
	forcefield_progress
	forcefield_anim_off
	mummy_casket_bricks
	mummy_casket_open
	ankh
	mummy_slide_1
	mummy_slide_2
	mummy_slide_3
	mummy_slide_4
	mummy_slide_5
	mummy_slide_6
	mummy_left_1
	mummy_left_2
	mummy_left_3
	mummy_right_1
	mummy_right_2
	mummy_right_3
	key_1
	key_2
	key_3
	key_4
	key_5
	key_6
	key_7
	lock
	unused_89
	unused_90
	unused_91
	unused_92
	unused_93
	unused_94
	raygun_track_left
	raygun_track_right
	raygun_facing_right_1
	raygun_facing_right_2
	raygun_facing_right_3
	raygun_facing_right_4
	raygun_facing_left_1
	raygun_facing_left_2
	raygun_facing_left_3
	raygun_facing_left_4
	unused_105
	unused_106
	unused_107
	raygun_shot
	raygun_button
	raygun_button_colormask
	teleport_booth
	teleport_2
	teleport_booth_colormask
	teleport_destination
	trapdoor_1
	trapdoor_2
	trapdoor_3
	trapdoor_4
	trapdoor_5
	trapdoor_6
	trapdoor_7
	trapdoor_controller
	trapdoor_mask
	door
	movingsidewalk_mask
	movingsidewalk_anim_1
	movingsidewalk_anim_2
	movingsidewalk_anim_3
	movingsidewalk_anim_4
	movingsidewalk_controller
	movingsidewalk_7
	frankenstein_right_1
	frankenstein_right_2
	frankenstein_right_3
	frankenstein_left_1
	frankenstein_left_2
	frankenstein_left_3
	frankenstein_slide
	frankenstein_climb_ladder_1
	frankenstein_climb_ladder_2
	frankenstein_climb_ladder_3
	frankenstein_climb_ladder_4
	frankenstein_sleep
	frankenstein_coffin_facing_right
	frankenstein_coffin_facing_left
	frankenstein_coffin_mask
	time_separators
	StringPrint_Mask
	StringPrint_CharacterImage
	house
	player_wave_goodbye_1
	player_wave_goodbye_2
	player_wave_goodbye_3
	player_wave_goodbye_4
	player_wave_goodbye_end_marker
	illegal = $FF
.endenum

.enum CASTLE_FLAGS
	SAVED_GAME = $01
	UNUSED_02  = $02
	UNUSED_04  = $04
	UNUSED_08  = $08
	UNUSED_10  = $10
	UNUSED_20  = $20
	UNUSED_40  = $40
	HAS_ESCAPE = $80
.endenum

.enum TEXTFONT
	ILLEGAL
	s8x8
	s8x16
	s8x24
	LOWERCASE_INVERTED = $10
	UPPERCASE = $20
	UPPERCASE_INVERTED = $30
.endenum

.enum ROOM_FLAGS
	COLOR_MASK = $0F
	STOP_DRAW = $40
	VISIBLE = $80
.endenum

.enum JOYSTICK_DIRECTION
	UP
	UP_RIGHT
	RIGHT
	DOWN_RIGHT
	DOWN
	DOWN_LEFT
	LEFT
	UP_LEFT
	NOTHING = $80
.endenum

.enum DIR_ALLOW
	UP = $01
	UP_RIGHT = $02
	RIGHT = $04
	DOWN_RIGHT = $08
	DOWN = $10
	DOWN_LEFT = $20
	LEFT = $40
	UP_LEFT = $80
.endenum

.enum KEYBOARD_INPUT
	BACKSPACE = $08
	RETURN = $0D
	NOTHING = $80
.endenum

.enum PLAYER_STATE
	IN_ROOM           ; Player is in the current room
	LEFT_ROOM         ; Player has just left a room
	DIEING            ; Player is dieing by collision, trapdoor or pressing RESTORE
	UNUSED_3          ; unused?
	NOT_PLAYING       ; Player #2 is not playing
	MOVING_IN_OUT     ; Player is in the transition to move in or out of a room
	START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
	NEXT_STATE = $FF  ; Skip to the next state
.endenum

.enum OBJECT_TYPE
	DOOR
	DOORBELL
	LIGHTNINGMACHINE
	LIGHTNINGMACHINE_SWITCH
	FORCEFIELD_BUTTON
	ANKH
	KEY
	KEYLOCK
	RAYGUN
	RAYGUN_CONTROLLER
	MATTERTRANSMITTER
	TRAPDOOR
	TRAPDOOR_SWITCH
	MOVINGSIDEWALK
	MOVINGSIDEWALK_BUTTON
	FRANKENSTEIN
.endenum

.enum SPRITE_TYPE
	PLAYER
	LIGHTNING
	FORCEFIELD
	MUMMY
	RAYGUN_SHOT
	FRANKENSTEIN
.endenum

.enum FILETYPE
	CASTLE
	SAVEGAME
	HIGHSCORE
.endenum

.enum OPTION_ACTION
	VIEW_HIGHSCORES
	UNLIMITED_LIVES
	LOAD_CASTLE
	SELECT
	RESUME_GAME
	NONE = $FF
.endenum

.enum FILENAME_MODE
	SAVE
	RESUME
.endenum

.enum DISK_STATUS
	MASTERDISK_DETECTED
	OK
	ERROR
.endenum

.enum READST_ERRORS
	NO_ERROR = $00
	END_OF_FILE = $40
.endenum

.enum ESCAPE_CASTLE_STATES
	RUN_RIGHT
	RUN_LEFT
	WAVE
.endenum

.enum SPRITE_FLAGS
	FLASH_ENABLED = $01
	NO_MULTICOLOR = $10
	NO_PRIORITY = $20
	DOUBLEHEIGHT = $40
	DOUBLEWIDTH = $80
.endenum

.enum SPRITE_STATE
	UNUSED = $01              ; 1, if the sprite slot is unused
	VIC_COLLIDE_SPRITE = $02  ; VIC detected a collision with another sprite
	VIC_COLLIDE_BACKGROUND = $04 ; VIC detected a collision with the background layer
	FREE = $08                ; Free the sprite after the execute and mark UNUSED
	DESTROY = $10             ; Sprite to be destroyed, will be freed in the next execute loop
	DIEING = $20              ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
	SHOULD_DIE = $40          ; Let the sprite die, depending of the type by flashing it
	CREATED = $80             ; Sprite was just created, reset during the first execute call
.endenum

.enum OBJ_DOOR_TYPE
	EXIT
	EXIT_HOUSE
.endenum

.enum OBJ_MUMMY_STATE
	END_OF_LIST
	SLEEPING
	AWAKE
	DIEING
.endenum

.enum IMG_FLAGS
	COLOR_MASK = $0F
	SPRITE_NO_MULTICOLOR = $10
	NO_PRIORITY = $20
	DOUBLEHEIGHT = $40
	DOUBLEWIDTH = $80
.endenum

.enum DOOR_FLAGS
	POSITION_RIGHT
	POSITION_BOTTOM
	POSITION_LEFT
	ISOPEN = $80
.endenum

.enum SID_NOTE
	C0
	Cs0
	D0
	Ds0
	E0
	F0
	Fs0
	G0
	Gs0
	A0
	As0
	B0
	C1
	Cs1
	D1
	Ds1
	E1
	F1
	Fs1
	G1
	Gs1
	A1
	As1
	B1
	C2
	Cs2
	D2
	Ds2
	E2
	F2
	Fs2
	G2
	Gs2
	A2
	As2
	B2
	C3
	Cs3
	D3
	Ds3
	E3
	F3
	Fs3
	G3
	Gs3
	A3
	As3
	B4
	C4
	Cs4
	D4
	Ds4
	E4
	F4
	Fs4
	G4
	Gs4
	A4
	As4
	C5
	Cs5
	D5
	Ds5
	E5
	F5
	Fs5
	G5
	Gs5
	A5
	As5
	B5
	C6
	Cs6
	D6
	Ds6
	E6
	F6
	Fs6
	G6
	Gs6
	A6
	As6
	B6
	C7
	Cs7
	D7
	Ds7
	E7
	F7
	Fs7
	G7
	Gs7
	A7
	As7
	B7
.endenum



; standard ASCII encoding
.MACPACK cbm
	scrcode

; set a pointer to an address
.macro SetPtr ptr,addr
	lda     #<(addr)
	sta     ptr
	lda     #>(addr)
	sta     ptr+1
.endmacro
