.include "C64_IO_REGS.inc"
.include "C64_KERNAL.inc"

; activate standard ASCII encoding
.MACPACK cbm
	scrcode

; set a pointer to an address
.macro SetPtr ptr,addr
	lda     #<(addr)
	sta     ptr
	lda     #>(addr)
	sta     ptr+1
.endmacro

; ################################################################################
; ### Global addresses
; ################################################################################

SCREENRAM           := $0400 ; original video base address for the text screen
START               := $0800 ; base for the application
CREEPLOAD_START     := $C000 ; code to load the title screen

CASTLE              := $7800 ; Castle structure
ROOM_BASE           := $7900 ; Array of all rooms in the castle
SAVE_GAME_MEMORY    := $9800 ; Backup of the castle
HIGHSCORES          := $B800 ; Highscores
GAME_MENU           := $BA00 ; Game menu with all available castles
BITMAP_ADR_TABLE_MSB := $BB00 ; MSB of the bitmap multiplication table
BITMAP_ADR_TABLE_LSB := $BC00 ; LSB of the bitmap multiplication table
mSprites            := $BD00 ; 8 structures for the sprites
mObjectsVars        := $BE00 ; 32 structures for the additional objects variables
mObjects            := $BF00 ; 32 structures for the objects
SCR_DIR_2K_BUF      := $C000 ; 40*25*2 (2000 bytes) buffer for the screen containing info about the blocks on the screen
TOP_SPRITEBASE_1	:= $C800 ; Sprite base 1
TOP_SPRITEBASE_2	:= $CA00 ; Sprite base 2 (for double buffering)
; the VIC is mapped to the upper 16kb
TOP_SCREENRAM       := $CC00 ; video memory, in highres multicolor mode the additional colors
TOP_HIGHRESVIDEORAM := $E000 ; address of the 8kb highres video data

; ################################################################################
; ### Enums
; ################################################################################

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

; ################################################################################
; ### Structs
; ################################################################################

; ===========================================================================
; === 32 bytes for the up to 8 sprites
; ===========================================================================

.struct CreepSprite
	spriteType     .byte   ; enum SPRITE_TYPE
	XPos           .byte   ; 
	YPos           .byte   ; 
	gfxID          .byte   ; enum GfxID
	state          .byte   ; enum SPRITE_STATE
	phase_counter  .byte   ; Only execute background collision and execute function at phase 0
	anim_phases    .byte   ; Number of phases for the animation
                    .byte  ; empty space
	flickerCounter .byte   ; 
	spriteFlagsColor.byte  ; 
	widthInPixels  .byte   ; 
	heightInPixels .byte   ; 
	xOffset        .byte   ; X-Offset for collision testing
	yOffset        .byte   ; Y-Offset to define the baseline of the sprite
				   .byte
				   .byte
				   .byte
				   .byte
				   .byte   ; empty space
				   .byte
				   .byte
				   .byte
				   .byte
				   .byte
	.union
		player 		.struct CreepSprite_Player
						dirAllow       		 .byte
						trapdoorCurrentState .byte
						trapdoorNextState    .byte
						exitEntryAnimState   .byte
						playerNumber   	     .byte
						joystickButton       .byte
						joystickDirections   .byte ; enum JOYSTICK_DIRECTION
						selectedDir          .byte
					.endstruct
		frankenstein   .struct CreepSprite_Frankenstein
						field_0              .byte
						field_1              .byte
						trapdoorCurrentState .byte
						trapdoorNextState    .byte
						dirAllow             .byte ; enum DIR_ALLOW
						direction            .byte ; enum JOYSTICK_DIRECTION
						flags                .byte
						id                   .byte
					.endstruct

		mummy          .struct CreepSprite_Mummy
							field_0                .byte
							field_1                .byte
							field_2                .byte
							trapdoorCurrentState   .byte
							trapdoorNextState      .byte
							id                     .byte
							flag                   .byte
							slideOutAnimationIndex .byte ; Animation phase of Mummy sliding out of the tomb
						.endstruct

		raygun         .struct CreepSprite_RayGun
							field_0        .byte
							field_1        .byte
							field_2        .byte
							field_3        .byte
							field_4        .byte
							field_5        .byte
							shotRayGunId   .byte
							shotXSpeed     .byte
						.endstruct

		forcefield     .struct CreepSprite_Forcefield
							field_0        .byte
							field_1        .byte
							field_2        .byte
							field_3        .byte
							field_4        .byte
							field_5        .byte
							flag           .byte
							id             .byte
						.endstruct

		lightning      .struct CreepSprite_Lightning
						field_0        .byte
						field_1        .byte
						field_2        .byte
						field_3        .byte
						field_4        .byte
						field_5        .byte
						field_6        .byte
						id             .byte
					.endstruct
	.endunion
.endstruct
.assert .sizeof(CreepSprite)=32,error

; ===========================================================================
; === 8 bytes per object for the up to 32 objects in a room
; ===========================================================================

.struct CreepObject
	objectType     .byte   ; enum OBJECT_TYPE
	XPos           .byte
	YPos           .byte
	gfxID          .byte   ; enum GfxID
	flags          .byte
	width          .byte
	height         .byte
	_unused_7_     .byte
.endstruct
.assert .sizeof(CreepObject)=8,error

; ===========================================================================
; === 8 bytes of additional variables for the up to 32 objects in a room
; ===========================================================================

.union CreepObjectVars
mattertransmitter .struct CreepObjectVars_MatterTransmitter
					objectPtr      .addr
					color          .byte ; enum C64_COLORS
					flickerCount   .byte
					XPos           .byte
					YPos           .byte
					unused_6       .byte
					unused_7       .byte
				  .endstruct

door           .struct CreepObjectVars_Door
					id             .byte
					doorIsOpen     .byte
					openingCount   .byte
					color          .byte ; enum C64_COLORS
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

lightningmachine .struct CreepObjectVars_LightningMachine
					id             .byte
					lightningIsActive .byte ; Lightning flash sprite is on
					phase          .byte ; Phase 0-2 if lightning machine is active
					length         .byte ; Length of the pole of the lightning machine
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

forcefield_button .struct CreepObjectVars_Forcefield_Button
					id             .byte
					timerTicks     .byte
					remainingTime  .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

ankh            .struct CreepObjectVars_Ankh
					id               .byte
					awakeningCounter .byte
					ankh_color       .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

trapdoor_switch .struct CreepObjectVars_TrapDoor_Switch
					id             .byte
					doorIsOpen     .byte
					gfxID          .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

movingsidewalk_button .struct CreepObjectVars_MovingSidewalk_Button
							id             .byte
							field_1        .byte
							field_2        .byte
							field_3        .byte
							field_4        .byte
							field_5        .byte
							field_6        .byte
							field_7        .byte
						.endstruct

raygun          .struct CreepObjectVars_RayGun
					id             .byte
					YPos           .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

key            .struct CreepObjectVars_Key
					id             .byte
					field_1        .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

key_lock       .struct CreepObjectVars_Key_Lock
					keyId          .byte
					doorId         .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

doorbell       .struct CreepObjectVars_Doorbell
					keyId          .byte
					doorId         .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

raygun_controller .struct CreepObjectVars_RayGun_Controller
						id             .byte
						field_1        .byte
						field_2        .byte
						field_3        .byte
						field_4        .byte
						field_5        .byte
						field_6        .byte
						field_7        .byte
					.endstruct

trapdoor       .struct CreepObjectVars_TrapDoor
					id             .byte
					field_1        .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

lightningmachine_switch .struct CreepObjectVars_LightningMachine_Switch
							field_0        .byte
							field_1        .byte
							field_2        .byte
							field_3        .byte
							field_4        .byte
							field_5        .byte
							field_6        .byte
							field_7        .byte
						.endstruct

movingsidewalk  .struct CreepObjectVars_MovingSidewalk
					id             .byte
					field_1        .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct

frankenstein   .struct CreepObjectVars_Frankenstein
					field_0        .byte
					field_1        .byte
					field_2        .byte
					field_3        .byte
					field_4        .byte
					field_5        .byte
					field_6        .byte
					field_7        .byte
				.endstruct
.endunion
.assert .sizeof(CreepObjectVars)=8,error


; ===========================================================================
; === 256 Byte header for the castle file
; ===========================================================================

.struct CreepPlayerData
	player_1       .byte
	player_2       .byte
.endstruct

.struct CreepPlayerTime
	player_1       .byte
				   .byte
				   .byte
				   .byte
	player_2       .byte
				   .byte
				   .byte
				   .byte
.endstruct
.assert .sizeof(CreepPlayerTime)=8,error

.struct CreepPlayerKeys
	player_1   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
	player_2   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
			   .byte
.endstruct
.assert .sizeof(CreepPlayerKeys)=64,error

.struct CreepCastle
size                 .word ; size of the castle structure in bytes
flags                .byte
playerStartRoom      .tag CreepPlayerData
playerStartDoor      .tag CreepPlayerData
playerRemainingLives .tag CreepPlayerData
playerCurrentRoom    .tag CreepPlayerData
playerCurrentDoor    .tag CreepPlayerData
playerState          .tag CreepPlayerData
playerIsAlive        .tag CreepPlayerData
firstPlayerIndexInRoom .byte
playerCount          .byte
playerKeyCount       .tag CreepPlayerData
playerKeys           .tag CreepPlayerKeys
playerTimer          .tag CreepPlayerTime
playerHasEscaped     .tag CreepPlayerData
escapeCastleOutsidePtr .addr
_unused_field_61 .byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
		.byte
.endstruct
.assert .sizeof(CreepCastle)=256,error

; ===========================================================================
; === Description of a single room in a castle
; ===========================================================================

.struct CreepRoom
	flagsColor     .byte   ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
	XPos           .byte   ; X position of the room on the map
	YPos           .byte   ; Y position of the room on the map
	widthHeight    .byte   ; Bit 0-2: height, Bit 3-5: width on the map
	doorsPtr       .addr   ; Position of the doors in the room
	objectPtr      .addr   ; Objects within the room
.endstruct
.assert .sizeof(CreepRoom)=8,error

; ===========================================================================
; === Objects in the castle file
; ===========================================================================

.struct CreepObj_Door
	XPos           .byte
	YPos           .byte
	Flags          .byte
	DestinationRoom .byte
	DestinationDoor .byte
	mapDoorXOffset .byte
	mapDoorYOffset .byte
	Typ            .byte
.endstruct

.struct CreepObj_Walkway
	Length         .byte
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_SlidingPole
	Length         .byte
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_Ladder
	Length         .byte
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_DoorBell
	XPos           .byte
	YPos           .byte
	doorNumber     .byte
.endstruct

.struct CreepObj_Lightning
	Flags          .byte
	XPos           .byte
	YPos           .byte
	Length         .byte
	switchedIds    .byte
				   .byte
				   .byte
				   .byte
.endstruct

.struct CreepObj_Forcefield
	XPos           .byte
	YPos           .byte
	XPosController .byte
	YPosController .byte
.endstruct

.struct CreepObj_Mummy
	Type           .byte
	XPos           .byte
	YPos           .byte
	mummyXPos      .byte
	mummyYPos      .byte
	savedXPos      .byte
	savedYPos      .byte
.endstruct

.struct CreepObj_Key
	id             .byte
	GfxID          .byte ; Graphics for the key, 0 = key was picked up
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_DoorLock
	keyId          .byte
	field_1        .byte
	doorId         .byte
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_MultiDraw
	Repeat         .byte
	gfxID          .byte
	XPos           .byte
	YPos           .byte
	xOffset        .byte
	yOffset        .byte
.endstruct

.struct CreepObj_Raygun
	Flags          .byte
	XPos           .byte
	YPos           .byte
	Length         .byte
	gunYPos        .byte
	XPosController .byte
	YPosController .byte
.endstruct

.struct CreepObj_MatterTransmitter_Destinations
	XPos           .byte
	YPos           .byte
.endstruct

.struct CreepObj_MatterTransmitter
	XPos           .byte
	YPos           .byte
	Color          .byte                 ; enum C64_COLORS
	destinations   .tag CreepObj_MatterTransmitter_Destinations
				   .tag CreepObj_MatterTransmitter_Destinations
.endstruct

.struct CreepObj_Trapdoor
	Flags          .byte
	XPos           .byte
	YPos           .byte
	XPosController .byte
	YPosController .byte
.endstruct

.struct CreepObj_MovingSidewalk
	Flags          .byte
	XPos           .byte
	YPos           .byte
	XPosController .byte
	YPosController .byte
.endstruct

.struct CreepObj_Frankenstein
	Flags          .byte
	XPos           .byte
	YPos           .byte
	frankensteinXPos .byte
	frankensteinYPos .byte
	frankensteinGfxID .byte               ; enum GfxID
	frankensteinDirection .byte           ; enum JOYSTICK_DIRECTION
.endstruct

.struct CreepObj_Text
	XPos           .byte
	YPos           .byte
	Color          .byte                 ; enum C64_COLORS
	Font           .byte                 ; enum TEXTFONT
.endstruct

.struct CreepObj_Image
	Width          .byte
	Height         .byte
	field_2        .byte
.endstruct

; ===========================================================================

.struct CreepScreenState
	dirFlags       .byte ; enum DIR_ALLOW
	field_1        .byte
.endstruct

.struct CreepState
	xOffset        .byte
	yOffset        .byte
	gfxID          .byte   ; enum GfxID
	nextState      .byte   ; enum PLAYER_STATE
.endstruct

.struct CreepEscapeState
	XPos           .byte
	nextState      .byte ; enum ESCAPE_CASTLE_STATES
.endstruct

.struct CreepIMG_Header
	widthInBytes   .byte
	heightInPixels .byte
	spriteFlagsColor .byte ; enum IMG_FLAGS
.endstruct

.struct CreepOptionsMenu
	XPos           .byte
	YPos           .byte
	action         .byte ; enum OPTION_ACTION
.endstruct

.struct CreepHighscoreEntry
name           .byte
			   .byte
			   .byte
time           .byte
			   .byte
			   .byte
.endstruct

.struct CreepFrankensteinPlayerDelta
	negativeY      .byte
	positiveX      .byte
	postiveY       .byte
	negativeX      .byte
.endstruct

.struct SID_ADSR
	pulseWidth     .word
	cr             .byte
	attackDecay    .byte
	sustainRelease .byte
.endstruct

.struct RASTER_LINE_INFO
	color          .byte  ; enum C64_COLORS
	rasterLine     .byte
.endstruct

; ################################################################################
; ### Zero-page variables
; ################################################################################

	.zeropage
	.org $10
; VIC mirrow registers to be set during the IRQ
IRQ_VIC_MnX:       .byte 0,0,0,0,0,0,0,0 ; X Coordinate Sprite 0
IRQ_VIC_MnY:       .byte 0,0,0,0,0,0,0,0 ; Y Coordinate Sprite 0
IRQ_VIC_MSIGX:     .byte 0 ; MSBs of X coordinates
IRQ_VIC_ME:        .byte 0 ; Sprite enabled
IRQ_VIC_VM_CB:     .byte 0 ; Memory pointers
IRQ_VIC_EC_BORDER: .byte 0 ; Border color
                   .byte 0 ; uninited & unexplored
IRQ_VIC_CR2:       .byte 0 ; Control register 2
IRQ_VIC_SPRITE_ADR:.byte 0,0,0,0,0,0,0,0
                   .byte 0,0 ; (uninited)
.assert * = $30, error, "VIC mirror registers are not 32 bytes long"

; zero-page pointers to various data
PP_A:			.addr $0000
PP_B:			.addr $0000
screenDraw_BitmapLineAdr: .addr $0000
_screenDraw_Current_BitmapAdr: .addr $0000
screenDraw_PTR:  .addr $0000
                .addr $0000 ; unused
ScreenDirectionAddr: .addr $0000
object_Ptr:      .addr $0000
mVObjectPtr:     .addr $0000
mRoomPtr:        .addr $0000

SND_PTR:         .addr $0000
SND_VoiceBaseRegAddr: .addr $0000
SND_VoiceBaseRegMirrorAddr: .addr $0000

.assert * = $4A, error, "VIC mirror registers are not 13 addresses long"

	.org $FB
PROTECTION_INDEX: .byte 0 ; copy protection

; ################################################################################
