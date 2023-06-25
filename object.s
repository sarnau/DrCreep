; This is the main code for Dr Creep

.include "DrCreep.inc"

		.code
		.org START
CODE_ENTRY:
		JMP     GAME_start
_ObjectDoor:
;		JMP     obj_Door_Object_Setup
		.byte $4C,.LOBYTE(obj_Door_Object_Setup),.HIBYTE(obj_Door_Object_Setup) ^ $32
_ObjectWalkway:
;		JMP     obj_Walkway_Object_Setup
		.byte $4C,.LOBYTE(obj_Walkway_Object_Setup),.HIBYTE(obj_Walkway_Object_Setup) ^ $32
_ObjectSlidingPole:
;		JMP     obj_SlidingPole_Object_Setup
		.byte $4C,.LOBYTE(obj_SlidingPole_Object_Setup),.HIBYTE(obj_SlidingPole_Object_Setup) ^ $37
_ObjectLadder:
		JMP     obj_Ladder_Object_Setup
_ObjectDoorBell:
;		JMP     obj_DoorBell_Object_Setup
		.byte $4C,.LOBYTE(obj_DoorBell_Object_Setup),.HIBYTE(obj_DoorBell_Object_Setup) ^ $37
_ObjectLightning:
		JMP     obj_Lightning_Object_Setup
_ObjectForcefield:
		JMP     obj_Forcefield_Object_Setup
_ObjectMummyTomb:
		JMP     obj_MummyTomb_Object_Setup
_ObjectKey:
		JMP     obj_Key_Object_Setup
_ObjectKeyLock:
		JMP     obj_KeyLock_Object_Setup
_ObjectMultiDraw:
		JMP     obj_MultiDraw_Object_Setup
_ObjectRayGun:
		JMP     obj_RayGun_Object_Setup
_ObjectMatterTransmitter:
		JMP     obj_MatterTransmitter_Object_Setup
_ObjectTrapDoor:
		JMP     obj_TrapDoor_Object_Setup
_ObjectMovingSidewalk:
		JMP     obj_MovingSidewalk_Object_Setup
_ObjectFrankenstein:
		JMP     obj_Frankenstein_Object_Setup
_ObjectText:
		JMP     obj_Text_Object_Setup
_ObjectImage:
		JMP     obj_Image_Object_Setup

; ---------------------------------------------------------------------------
SND_DisableSoundEffects:.BYTE 0  ; Always 0, maybe 1 in the tape version?

                .BYTE $80, $40, $20, $10 ; unused

OBJECT_COUNT:   .BYTE 0

OBJECT_INVISIBLE:.BYTE $80       ; Object is invisible
OBJECT_TRIGGER_EXECUTE:.BYTE $40 ; Trigger execute function for the object
OBJECT_DELETE:  .BYTE $20        ; Delete the object, e.g. after a key was picked

ObjectType_Table:.addr obj_Door_Object_Execute, obj_Door_Object_ObjectCollision
                .addr 0, obj_DoorBell_Object_ObjectCollision
                .addr obj_LightningMachine_Object_Execute, 0
                .addr 0, obj_LightningMachineSwitch_Object_ObjectCollision
                .addr obj_ForcefieldButton_Object_Execute, obj_ForcefieldButton_Object_ObjectCollision
                .addr obj_Ankh_Object_Execute, obj_Ankh_Object_ObjectCollision
                .addr 0, obj_Key_Object_ObjectCollision
                .addr 0, obj_KeyLock_Object_ObjectCollision
                .addr obj_RayGun_Object_Execute, 0
                .addr 0, obj_RayGun_Controller_Object_ObjectCollision
                .addr obj_MatterTransmitter_Object_Execute, obj_MatterTransmitter_Object_ObjectCollision
                .addr obj_TrapDoor_Switch_Object_Execute, 0
                .addr 0, 0
                .addr obj_MovingSidewalk_Object_Execute, obj_MovingSidewalk_Object_ObjectCollision
                .addr 0, obj_MovingSidewalkButton_Object_ObjectCollision
                .addr 0, 0

SPRITE_FLAGS_CREATED:.BYTE SPRITE_STATE::CREATED ; Sprite was just created, reset during the first execute call
SPRITE_FLAGS_SHOULD_DIE:.BYTE SPRITE_STATE::SHOULD_DIE ; Let the sprite die, depending of the type by flashing it
SPRITE_FLAGS_DIEING:.BYTE SPRITE_STATE::DIEING ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
SPRITE_FLAGS_DESTROY:.BYTE SPRITE_STATE::DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
SPRITE_FLAGS_FREE:.BYTE SPRITE_STATE::FREE ; Free the sprite after the execute and mark UNUSED
SPRITE_FLAGS_VIC_COLLIDE_BACKGROUND:.BYTE SPRITE_STATE::VIC_COLLIDE_BACKGROUND ; VIC detected a collision with the background layer
SPRITE_FLAGS_VIC_COLLIDE_SPRITE:.BYTE SPRITE_STATE::VIC_COLLIDE_SPRITE ; VIC detected a collision with another sprite
SPRITE_FLAGS_UNUSED:.BYTE SPRITE_STATE::UNUSED ; 1, if the sprite slot is unused

SPRITE_DOUBLEWIDTH:.BYTE SPRITE_FLAGS::DOUBLEWIDTH ; Sprite has double-width
SPRITE_DOUBLEHEIGHT:.BYTE SPRITE_FLAGS::DOUBLEHEIGHT ; Sprite has double-height
SPRITE_NO_PRIORITY:.BYTE SPRITE_FLAGS::NO_PRIORITY
SPRITE_NO_MULTICOLOR:.BYTE SPRITE_FLAGS::NO_MULTICOLOR ; Sprite is a multicolor sprite
SPRITE_FLASH_ENABLED:.BYTE SPRITE_FLAGS::FLASH_ENABLED ; Sprite flashes during dying?

Sprite_Table: ; SPRITE_TABLE
                .addr obj_Player_Sprite_Execute
                .addr obj_Player_Sprite_SpriteCollision
                .addr obj_Player_Sprite_ObjectCollision
                .BYTE %00000000
                .BYTE SPRITE_FLAGS::FLASH_ENABLED

                .addr obj_Lightning_Sprite_Execute
                .addr obj_Lightning_Sprite_SpriteCollision
                .addr 0
                .BYTE %00000100
                .BYTE 0

                .addr obj_Forcefield_Sprite_Execute
                .addr obj_Forcefield_Sprite_SpriteCollision
                .addr 0
                .BYTE %00000011
                .BYTE 0

                .addr obj_Mummy_Sprite_Execute
                .addr obj_Mummy_Sprite_SpriteCollision
                .addr obj_Mummy_Sprite_Collision
                .BYTE %00000010
                .BYTE SPRITE_FLAGS::FLASH_ENABLED ; Sprite flashes during dying?

                .addr obj_RayGun_Shot_Sprite_Execute
                .addr 0
                .addr obj_RayGun_Shot_Sprite_ObjectCollision
                .BYTE %00000100
                .BYTE 0

                .addr obj_Frankenstein_Sprite_Execute
                .addr obj_Frankenstein_Sprite_SpriteCollision
                .addr obj_Frankenstein_Sprite_ObjectCollision
                .BYTE %00000000
                .BYTE SPRITE_FLAGS::FLASH_ENABLED ; Sprite flashes during dying?

                .BYTE $80

MAP_ROOM_VISIBLE:.BYTE ROOM_FLAGS::VISIBLE
MAP_ROOM_STOP_DRAW:.BYTE ROOM_FLAGS::STOP_DRAW

; =============== S U B R O U T I N E =======================================

.proc GAME_start
                LDA     #<(COLORRAM - 192)
                STA     PP_A
                LDA     #>(COLORRAM - 192)
                STA     PP_A+1
                LDX     #200            ; starting at line 200
loc_8CC:        LDA     PP_A
                STA     BITMAP_ADR_TABLE_LSB,X
                LDA     PP_A+1
                STA     BITMAP_ADR_TABLE_MSB,X
                INX
                CPX     #200
                BEQ     loc_8F9
                TXA
                AND     #7
                BEQ     loc_8E9
                INC     PP_A
                BNE     loc_8CC
                INC     PP_A+1
                JMP     loc_8CC
loc_8E9:        CLC
                LDA     PP_A
                ADC     #<(320-8+1)
                STA     PP_A
                LDA     PP_A+1
                ADC     #>(320-8+1)
                STA     PP_A+1
                JMP     loc_8CC
loc_8F9:

                LDA     #0
                STA     PP_A
                STA     PP_A+1
                LDX     #0
loc_901:        LDA     PP_A
                STA     MULT_40_TABLE_LSB,X
                LDA     PP_A+1
                STA     MULT_40_TABLE_MSB,X
                CLC
                LDA     PP_A
                ADC     #40
                STA     PP_A
                BCC     loc_916
                INC     PP_A+1
loc_916:        INX
                CPX     #32
                BCC     loc_901

                JSR     PROTECTION_CHECK

                JSR     SNDEFFECT_TABLE

                LDA     SND_DisableSoundEffects ; Always 0, maybe 1 in the tape version?
                CMP     #1
                BEQ     loc_953

                LDA     #<SNDEFFECT_TABLE
                STA     PP_A
                LDA     #>SNDEFFECT_TABLE
                STA     PP_A+1
                LDA     #<SNDEFFECT_TABLE_INIT
                STA     PP_B
                LDA     #>SNDEFFECT_TABLE_INIT
                STA     PP_B+1
                LDY     #0
loc_93A:        LDA     (PP_B),Y
                STA     (PP_A),Y
                INY
                BNE     loc_93A
                INC     PP_A+1
                INC     PP_B+1
                LDA     PP_A+1
                CMP     #>CASTLE
                BCC     loc_93A

                LDX     #16             ; Tutorial
                JSR     GAME_ChangeLevel
                JMP     loc_956

loc_953:        JSR     GAME_CopyTutorialCastle

loc_956:        LDA     #0
                STA     BEFORE_MAINLOOP_FLAG
                JMP     GAME_mainLoop
.endproc

BEFORE_MAINLOOP_FLAG:.BYTE 1

; =============== S U B R O U T I N E =======================================

.proc DRAW_DisableSpritesAndStopSound
                PHA
                TXA
                PHA
                LDA     #0
                NOP
                NOP
                NOP
                SEI
                LDA     #%1111111
                STA     CIA2::ICR       ; Interrupt control and status
                LDA     CIA2::ICR       ; Interrupt control and status
                LDA     #%111
                STA     C6510::D6510    ; Processor port data direction register (0 = Bit #x in processor port can only be read; 1 = Bit #x in processor port can be read and written.)
                LDA     #%101           ; IO mapped, no ROM
                STA     C6510::R6510    ; Processor port
                LDA     #<IRQ_VECTOR
                STA     C6510::IRQ
                LDA     #>IRQ_VECTOR
                STA     C6510::IRQ+1
                LDA     #<NMI_VECTOR
                STA     C6510::NMI
                LDA     #>NMI_VECTOR
                STA     C6510::NMI+1

                LDX     #0
                LDA     #(SPRITE_BASE_A-SCR_DIR_2K_BUF)/64 ; $20 * $40 + $C000 => $C800…CA00 Sprites
loc_990:        STA     IRQ_VIC_SPRITE_ADR,X
                INX
                CPX     #8
                BCS     loc_99C         ; Set MCM and CSEL (Multicolor-Mode, 40 columns)
                ADC     #1
                JMP     loc_990
loc_99C:

                LDA     #VIC_CR1_FLAGS::RSEL|VIC_CR1_FLAGS::DEN ; Set MCM and CSEL (Multicolor-Mode, 40 columns)
                STA     VIC::CR2        ; Control register 2
                STA     IRQ_VIC_CR2     ; Control register 2
                LDA     #0
                STA     VIC::RASTER     ; Raster counter
                LDA     #((TOP_SCREENRAM-SCR_DIR_2K_BUF)/1024)<<4 ; $0C00 => $CC00 = TEXT video address
                AND     #%11110000
                ORA     #((TOP_HIGHRESVIDEORAM-SCR_DIR_2K_BUF)/8192)<<3 ; $2000 => $E000 = GRAPHICS video address
                STA     IRQ_VIC_VM_CB   ; VIC memory control register
                LDA     #1              ; Enable VIC interrupt
                STA     VIC::IRQEN      ; Interrupt enabled
                LDA     #%11111111
                STA     VIC::IRQST      ; Interrupt register
                LDA     #COLOR::BLACK
                STA     IRQ_VIC_EC_BORDER ; Border color
                STA     IRQ_VECTOR_RASTER_TABLE + RASTER_LINE_INFO::color
                LDA     #COLOR::LIGHT_RED ; Shirt of the player
                STA     VIC::SPMC0      ; Sprite multicolor 0
                LDA     #COLOR::LIGHT_GREEN ; Pants of the player
                STA     VIC::SPMC1      ; Sprite multicolor 1
                LDA     #%00000011
                STA     CIA2::DDRA      ; Data direction Port A
                LDA     #($C000-SCR_DIR_2K_BUF)>>14 ; $C000 = VIC base address
                STA     CIA2::PRA       ; Select the position of the VIC-memory
                LDA     #0
                STA     CIA1::CRA       ; Control Timer A
                STA     CIA2::CRA       ; Control Timer A
                STA     CIA1::CRB       ; Control Timer B
                STA     CIA2::CRB       ; Control Timer B
                LDA     #%01111111
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     CIA1::ICR       ; Interrupt Control and status
                CLI
                LDA     #1
                CMP     _DisableSpritesAndStopSound_FIRST_RUN
                BEQ     loc_A04
                STA     _DisableSpritesAndStopSound_FIRST_RUN
                LDA     #%11111111
                STA     IRQ_VIC_ME      ; Sprite enabled

                LDA     #2
                STA     IRQ_DELAY_COUNTER
loc_9FF:        LDA     IRQ_DELAY_COUNTER
                BNE     loc_9FF         ; Wait for 2/60s

loc_A04:        LDA     #0
                STA     IRQ_VIC_ME      ; Sprite enabled
                LDA     #VIC_CR1_FLAGS::YSCROLL_3|VIC_CR1_FLAGS::RSEL|VIC_CR1_FLAGS::DEN|VIC_CR1_FLAGS::BMM ; Video enable
                STA     VIC::CR1        ; Control register 1
                LDA     #$FF
                STA     CIA1::T1L       ; Timer A Low Byte

                LDA     SND_Timer_A_MSB
                ASL     A
                ASL     A
                ORA     #3
                STA     CIA1::T1H       ; Timer A High Byte
                LDA     #$FF
                STA     SND_PlayingSound

                LDA     SND_MusicPlaying
                CMP     #1
                BNE     loc_A3D
                LDX     #24
loc_A2A:        LDA     SND_SID_REG_MIRROR_1,X
                STA     SID::FRELO1,X   ; Channel 1 Frequency Low-Byte
                DEX
                BPL     loc_A2A
                LDA     #%10000001
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     #%00000001
                STA     CIA1::CRA       ; Control Timer A

loc_A3D:        PLA
                TAX
                PLA
                RTS

_DisableSpritesAndStopSound_FIRST_RUN:.BYTE 0
.endproc

; =============== S U B R O U T I N E =======================================


.proc GAME_CopyTutorialCastle
                PHA
                TYA
                PHA
                LDY     #0
                LDA     #<CASTLE
                STA     PP_A
                LDA     #>CASTLE
                STA     PP_A+1
                LDA     #<SAVE_GAME_MEMORY
                STA     PP_B
                LDA     #>SAVE_GAME_MEMORY
                STA     PP_B+1
                LDA     CASTLE + CreepCastle::size     ; size of the castle structure in bytes
                STA     screenDraw_BitmapLineAdr
                LDA     CASTLE + CreepCastle::size + 1 ; size of the castle structure in bytes
                STA     screenDraw_BitmapLineAdr+1
                BEQ     loc_A72
loc_A63:        LDA     (PP_A),Y
                STA     (PP_B),Y
                INY
                BNE     loc_A63
                INC     PP_A+1
                INC     PP_B+1
                DEC     screenDraw_BitmapLineAdr+1
                BNE     loc_A63
loc_A72:        CPY     screenDraw_BitmapLineAdr
                BEQ     copy_tutorial_castle_return
                LDA     (PP_A),Y
                STA     (PP_B),Y
                INY
                JMP     loc_A72

copy_tutorial_castle_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

.proc IRQ_VECTOR
                PHA
                TYA
                PHA
                TXA
                PHA
                CLD
                LDA     VIC::IRQST      ; Interrupt register
                AND     #%00000001
                BNE     IRQ_VECTOR_videoIRQ
                JMP     IRQ_VECTOR_noVideoIRQ
; ---------------------------------------------------------------------------

IRQ_VECTOR_videoIRQ:
                LDA     VIC::IRQST      ; Interrupt register
                STA     VIC::IRQST      ; Interrupt register

                LDX     _IRQ_VECTOR_RASTER_INDEX_CUR
                LDA     IRQ_VECTOR_RASTER_TABLE + RASTER_LINE_INFO::color,X
                NOP
                NOP
                NOP                     ; should only be 3 NOPs to avoid the blinking dots
                NOP
                NOP
                NOP
                STA     VIC::BGCOL0     ; Background color 0

; with only 3 NOPs, here clear bit 7 in VIC_CR1

                CPX     #0
                BEQ     loc_AAE
                JMP     loc_B4D
; ---------------------------------------------------------------------------

loc_AAE:
                LDA     IRQ_VIC_MnX     ; X Coordinate Sprite 0
                STA     VIC::M0X         ; X Coordinate Sprite 0
                LDA     IRQ_VIC_MnX+1   ; X Coordinate Sprite 0
                STA     VIC::M1X         ; X Coordinate Sprite 1
                LDA     IRQ_VIC_MnX+2   ; X Coordinate Sprite 0
                STA     VIC::M2X         ; X Coordinate Sprite 2
                LDA     IRQ_VIC_MnX+3   ; X Coordinate Sprite 0
                STA     VIC::M3X         ; X Coordinate Sprite 3
                LDA     IRQ_VIC_MnX+4   ; X Coordinate Sprite 0
                STA     VIC::M4X         ; X Coordinate Sprite 4
                LDA     IRQ_VIC_MnX+5   ; X Coordinate Sprite 0
                STA     VIC::M5X         ; X Coordinate Sprite 5
                LDA     IRQ_VIC_MnX+6   ; X Coordinate Sprite 0
                STA     VIC::M6X         ; X Coordinate Sprite 6
                LDA     IRQ_VIC_MnX+7   ; X Coordinate Sprite 0
                STA     VIC::M7X         ; X Coordinate Sprite 7
                LDA     IRQ_VIC_MnY     ; Y Coordinate Sprite 0
                STA     VIC::M0Y         ; Y Coordinate Sprite 0
                LDA     IRQ_VIC_MnY+1   ; Y Coordinate Sprite 0
                STA     VIC::M1Y         ; Y Coordinate Sprite 1
                LDA     IRQ_VIC_MnY+2   ; Y Coordinate Sprite 0
                STA     VIC::M2Y         ; Y Coordinate Sprite 2
                LDA     IRQ_VIC_MnY+3   ; Y Coordinate Sprite 0
                STA     VIC::M3Y         ; Y Coordinate Sprite 3
                LDA     IRQ_VIC_MnY+4   ; Y Coordinate Sprite 0
                STA     VIC::M4Y         ; Y Coordinate Sprite 4
                LDA     IRQ_VIC_MnY+5   ; Y Coordinate Sprite 0
                STA     VIC::M5Y         ; Y Coordinate Sprite 5
                LDA     IRQ_VIC_MnY+6   ; Y Coordinate Sprite 0
                STA     VIC::M6Y         ; Y Coordinate Sprite 6
                LDA     IRQ_VIC_MnY+7   ; Y Coordinate Sprite 0
                STA     VIC::M7Y         ; Y Coordinate Sprite 7
                LDA     IRQ_VIC_MSIGX   ; MSBs of X coordinates
                STA     VIC::MSIGX       ; MSBs of X coordinates
                LDA     IRQ_VIC_ME      ; Sprite enabled
                STA     VIC::ME          ; Sprite enabled
                LDA     IRQ_VIC_VM_CB   ; Memory pointers
                STA     VIC::VM_CB       ; Memory pointers
                LDA     IRQ_VIC_EC_BORDER ; Border color
                STA     VIC::EC_BORDER   ; Border color
                LDA     IRQ_VECTOR_RASTER_TABLE + RASTER_LINE_INFO::color
                STA     VIC::BGCOL0      ; Background color 0
                LDA     IRQ_VIC_CR2     ; Control register 2
                STA     VIC::CR2         ; Control register 2
                LDA     IRQ_VIC_SPRITE_ADR
                STA     TOP_SCREENRAM+$3F8
                LDA     IRQ_VIC_SPRITE_ADR+1
                STA     TOP_SCREENRAM+$3F9
                LDA     IRQ_VIC_SPRITE_ADR+2
                STA     TOP_SCREENRAM+$3FA
                LDA     IRQ_VIC_SPRITE_ADR+3
                STA     TOP_SCREENRAM+$3FB
                LDA     IRQ_VIC_SPRITE_ADR+4
                STA     TOP_SCREENRAM+$3FC
                LDA     IRQ_VIC_SPRITE_ADR+5
                STA     TOP_SCREENRAM+$3FD
                LDA     IRQ_VIC_SPRITE_ADR+6
                STA     TOP_SCREENRAM+$3FE
                LDA     IRQ_VIC_SPRITE_ADR+7
                STA     TOP_SCREENRAM+$3FF

                LDA     IRQ_DELAY_COUNTER
                BEQ     loc_B4D
                DEC     IRQ_DELAY_COUNTER

loc_B4D:
                INX
                INX
                CPX     IRQ_VECTOR_RASTER_INDEX
                BEQ     loc_B58
                BCC     loc_B58
                LDX     #0

loc_B58:
                LDA     IRQ_VECTOR_RASTER_TABLE + RASTER_LINE_INFO::rasterLine,X
                STA     VIC::RASTER      ; Raster counter
                STX     _IRQ_VECTOR_RASTER_INDEX_CUR

IRQ_VECTOR_noVideoIRQ:
                LDA     CIA1::ICR       ; Interrupt Control and status
                AND     #%00000001
                BEQ     IRQ_VECTOR_return
                JSR     SND_CIA1_TIMER_A_IRQ_musicBufferFeed

IRQ_VECTOR_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTI
_IRQ_VECTOR_RASTER_INDEX_CUR:.BYTE 0
.endproc

; ---------------------------------------------------------------------------
IRQ_VECTOR_RASTER_INDEX:.BYTE 0

IRQ_VECTOR_RASTER_TABLE:
				.byte COLOR::BLACK,   0
                .byte COLOR::DARK_GREY, 162
                .byte COLOR::BROWN, 202
                .byte COLOR::DARK_GREY, 210

; =============== S U B R O U T I N E =======================================

.proc NMI_VECTOR
                PHA
                LDA     #1
                STA     KEY_RestorePressed
                PLA
                RTI
.endproc

KEY_RestorePressed:.BYTE 0

; =============== S U B R O U T I N E =======================================

.proc GAME_mainLoop
                JSR     GAME_Intro
                JSR     GAME_Game
                JMP     GAME_mainLoop
.endproc

; =============== S U B R O U T I N E =======================================

.proc GAME_Intro
                PHA
                TYA
                PHA
                TXA
                PHA

Intro_loopInit:
                LDA     #0
                STA     _Intro_mMenuMusicScore
                LDA     #3
                STA     _Intro_RoomLoopCounter
                LDA     #1
                STA     Intro_IsInIntroFlag
                LDA     #0
                STA     Intro_JoystickPressed
                STA     Intro_RoomNumber

Intro_roomLoop:
                INC     _Intro_RoomLoopCounter
                LDA     _Intro_RoomLoopCounter
                AND     #3
                STA     _Intro_RoomLoopCounter
                BEQ     Intro_roomLoop_titleScreen

                INC     Intro_RoomNumber
                LDA     Intro_RoomNumber
                JSR     GAME_selectRoom ; Set roomPtr to room # in A

                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                BIT     MAP_ROOM_STOP_DRAW
                BEQ     loc_BCD
                LDA     #0
                STA     Intro_RoomNumber

loc_BCD:
                JSR     GAME_roomLoadAndDraw ; Load room for the currently active player(s)
                JMP     loc_BE1
; ---------------------------------------------------------------------------

Intro_roomLoop_titleScreen:
                JSR     DRAW_ClearScreen
                LDA     #<_Intro_ROOM_TITLE_SCREEN
                STA     object_Ptr
                LDA     #>_Intro_ROOM_TITLE_SCREEN
                STA     object_Ptr+1
                JSR     DRAW_Objects    ; Draw all objects in the current room initially

loc_BE1:
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1

                LDA     SND_MusicPlaying
                CMP     #1
                BEQ     loc_BFD
                LDA     _Intro_RoomLoopCounter
                BNE     loc_BFD
                LDA     _Intro_mMenuMusicScore
                BNE     Intro_load_next_music
                INC     _Intro_mMenuMusicScore

loc_BFD:
                LDA     #200
                STA     _Intro_waitForInputTimeout

Intro_WaitForInput:
                LDA     _Intro_RoomLoopCounter
                BEQ     loc_C0D         ; Wait for 2/60s
                JSR     GAME_ExecuteEvents ; Handle 1/30 of all game processing
                JMP     loc_C17
; ---------------------------------------------------------------------------

loc_C0D:
                LDA     IRQ_DELAY_COUNTER ; Wait for 2/60s
                BNE     loc_C0D         ; Wait for 2/60s
                LDA     #2
                STA     IRQ_DELAY_COUNTER

loc_C17:
                LDA     Intro_JoystickPressed
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Button
                BEQ     loc_C25         ; Joystick button

loc_C22:
                JMP     Intro_return
; ---------------------------------------------------------------------------

loc_C25:
                LDA     Intro_JoystickPressed
                EOR     #1
                STA     Intro_JoystickPressed
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1
                BEQ     Intro_RUNSTOP
                DEC     _Intro_waitForInputTimeout
                BNE     Intro_WaitForInput
                JMP     Intro_roomLoop
; ---------------------------------------------------------------------------

Intro_RUNSTOP:
                JSR     GAME_optionsMenu
                LDA     gamePositionLoad_SaveGameLoaded
                CMP     #1
                BEQ     loc_C22
                JMP     Intro_loopInit
; ---------------------------------------------------------------------------

Intro_load_next_music:
                INC     _Intro_str_MUSIC+5
                LDX     #6
                STX     DISK_LOAD_FNAME_LENGTH
_loop:          DEX
                BMI     _select_first_music
                LDA     _Intro_str_MUSIC,X
                STA     DISK_LOAD_FNAME,X
                JMP     _loop
; ---------------------------------------------------------------------------

_select_first_music:
                LDA     #FILETYPE::CASTLE
                STA     DISK_LOAD_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_CHECK
                CMP     #DISK_STATUS::MASTERDISK_DETECTED
                BNE     loc_C88

_next_music_loop:
                JSR     DISK_LOAD_FILE
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::END_OF_FILE
                BEQ     loc_C8D
                LDA     _Intro_str_MUSIC+5
                CMP     #'0'
                BEQ     loc_C88
                LDA     #'0'
                STA     _Intro_str_MUSIC+5
                STA     DISK_LOAD_FNAME+5
                JMP     _next_music_loop
; ---------------------------------------------------------------------------

loc_C88:
                LDA     #$24 ; '$'
                STA     CASTLE + CreepCastle::flags    ; at this point, this is where the music is loaded, not the castle

loc_C8D:
                JSR     DISK_DELAY_AFTER_IO
                LDA     #<(CASTLE + CreepCastle::flags)
                STA     SND_PTR
                LDA     #>(CASTLE + CreepCastle::flags)
                STA     SND_PTR+1
                LDX     #14

_sid_init_loop:
                LDA     SND_SID_REG_MIRROR_1+4,X
                AND     #(~1 & $FF)
                STA     SND_SID_REG_MIRROR_1+4,X
                STA     SID::VCREG1,X       ; NOISE   PULSE   SAW TRI TEST    RING    SYNC    GATE
                SEC
                TXA
                SBC     #7
                TAX
                BCS     _sid_init_loop
                LDA     SND_MIRROR_FILTER_RES_ROUTING
                AND     #%11110000
                STA     SID::Res_Filt    ; Filter Resonance, Filt Ex, Filt 3, Filt 2, Filt 1
                STA     SND_MIRROR_FILTER_RES_ROUTING
                LDA     #0
                STA     SND_TimerCounter
                STA     SND_TimerCounter+1
                LDA     #20
                STA     SND_Timer_A_MSB
                ASL     A
                ASL     A
                ORA     #3
                STA     CIA1::T1H       ; Timer A High Byte
                LDA     #1
                STA     SND_MusicPlaying
                LDA     #%10000001
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     #%00000001
                STA     CIA1::CRA       ; Control Timer A
                JMP     Intro_roomLoop
; ---------------------------------------------------------------------------

Intro_return:
                LDA     #0
                STA     SND_MusicPlaying
                LDA     #0
                STA     Intro_IsInIntroFlag
                LDA     #%00000000
                STA     CIA1::CRA       ; Control Timer A
                LDA     #%01111111
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     CIA1::ICR       ; Interrupt Control and status
                LDX     #14

_sid_reset_loop:
                LDA     SND_SID_REG_MIRROR_1+4,X
                AND     #(~1 & $FF)
                STA     SND_SID_REG_MIRROR_1+4,X
                STA     SID::VCREG1,X       ; NOISE   PULSE   SAW TRI TEST    RING    SYNC    GATE
                SEC
                TXA
                SBC     #7
                TAX
                BCS     _sid_reset_loop
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

_Intro_RoomLoopCounter:.BYTE $85
.endproc

; ---------------------------------------------------------------------------
Intro_IsInIntroFlag:.BYTE 0
Intro_JoystickPressed:.BYTE $A0
Intro_RoomNumber:.BYTE $B0
_Intro_waitForInputTimeout:.BYTE $A0

_Intro_str_MUSIC:scrcode "MUSIC0"
_Intro_mMenuMusicScore:.BYTE $FF

_Intro_ROOM_TITLE_SCREEN:.addr obj_MultiDraw_Object_Setup
                _CreepObj_MultiDraw 8, GfxID::exit, 16, 88, 20, 0
                .BYTE 0
                .addr obj_Text_Object_Setup
                _CreepObj_Text 40, 48, COLOR::ORANGE, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "THE CASTLES O"
                .BYTE $C6
                _CreepObj_Text 48, 64, COLOR::LIGHT_GREEN, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "DOCTOR CREE"
                .BYTE $D0
                _CreepObj_Text 52, 128, COLOR::YELLOW, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "BY ED HOBB"
                .BYTE $D3
                _CreepObj_Text 16, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "BR0DERBUND  SOFTWAR"
                .BYTE $C5, 0
                .addr 0

; =============== S U B R O U T I N E =======================================

.proc GAME_Game
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     gamePositionLoad_SaveGameLoaded
                CMP     #1
                BNE     _copy_saved_game
                LDA     #0
                STA     gamePositionLoad_SaveGameLoaded
                LDA     CASTLE + CreepCastle::flags
                ORA     #CASTLE_FLAGS::SAVED_GAME
                STA     CASTLE + CreepCastle::flags
                JMP     Game_Loop
; ---------------------------------------------------------------------------

_copy_saved_game:
                LDY     #0
                LDA     #<SAVE_GAME_MEMORY
                STA     PP_A
                LDA     #>SAVE_GAME_MEMORY
                STA     PP_A+1
                LDA     #<CASTLE
                STA     PP_B
                LDA     #>CASTLE
                STA     PP_B+1
                LDA     SAVE_GAME_MEMORY ; Castle.size
                STA     screenDraw_BitmapLineAdr
                LDA     SAVE_GAME_MEMORY+1
                STA     screenDraw_BitmapLineAdr+1
                BEQ     loc_DBA

loc_DAB:
                LDA     (PP_A),Y
                STA     (PP_B),Y
                INY
                BNE     loc_DAB
                INC     PP_A+1
                INC     PP_B+1
                DEC     screenDraw_BitmapLineAdr+1
                BNE     loc_DAB

loc_DBA:
                CPY     screenDraw_BitmapLineAdr
                BEQ     loc_DC6
                LDA     (PP_A),Y
                STA     (PP_B),Y
                INY
                JMP     loc_DBA
; ---------------------------------------------------------------------------

loc_DC6:
                LDA     Intro_JoystickPressed
                STA     CASTLE + CreepCastle::playerCount
                LDY     #7
                LDA     #0

loc_DD0:        STA     CASTLE + CreepCastle::playerTimer,Y
                DEY
                BPL     loc_DD0
                LDA     #0
                STA     CASTLE + CreepCastle::playerHasEscaped + CreepPlayerData::player_1
                STA     CASTLE + CreepCastle::playerHasEscaped + CreepPlayerData::player_2
                LDA     CASTLE + CreepCastle::playerStartRoom + CreepPlayerData::player_1
                STA     CASTLE + CreepCastle::playerCurrentRoom + CreepPlayerData::player_1
                LDA     CASTLE + CreepCastle::playerStartRoom + CreepPlayerData::player_2
                STA     CASTLE + CreepCastle::playerCurrentRoom + CreepPlayerData::player_2
                LDA     CASTLE + CreepCastle::playerStartDoor + CreepPlayerData::player_1
                STA     CASTLE + CreepCastle::playerCurrentDoor + CreepPlayerData::player_1
                LDA     CASTLE + CreepCastle::playerStartDoor + CreepPlayerData::player_2
                STA     CASTLE + CreepCastle::playerCurrentDoor + CreepPlayerData::player_2
                LDA     #0
                STA     CASTLE + CreepCastle::firstPlayerIndexInRoom
                LDA     #1
                STA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_1
                LDA     CASTLE + CreepCastle::playerCount
                CMP     #1
                BEQ     loc_E14
                LDA     #0
                STA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_2
                LDA     #PLAYER_STATE::NOT_PLAYING ; Player #2 is not playing
                STA     CASTLE + CreepCastle::playerState + CreepPlayerData::player_2
                JMP     Game_Loop
; ---------------------------------------------------------------------------

loc_E14:
                LDA     #1
                STA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_2

Game_Loop:
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_1
                CMP     #1
                BEQ     Game_Loop_AtLeastOnePlayerAlive
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_2
                CMP     #1
                BEQ     Game_Loop_AtLeastOnePlayerAlive
                JMP     Game_return
; ---------------------------------------------------------------------------

Game_Loop_AtLeastOnePlayerAlive:
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_1
                CMP     #1
                BNE     loc_E5F
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_2
                CMP     #1
                BNE     loc_E5F
                LDA     CASTLE + CreepCastle::playerCurrentRoom + CreepPlayerData::player_1
                CMP     CASTLE + CreepCastle::playerCurrentRoom + CreepPlayerData::player_2
                BNE     loc_E4B
                LDA     #1
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_2
                JMP     loc_E7D
; ---------------------------------------------------------------------------

loc_E4B:
                LDX     CASTLE + CreepCastle::firstPlayerIndexInRoom
                LDA     #0
                STA     mapDraw_playerInCurrentRoom,X
                TXA
                EOR     #1
                TAX
                LDA     #1
                STA     mapDraw_playerInCurrentRoom,X
                JMP     loc_E7D
; ---------------------------------------------------------------------------

loc_E5F:
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_1
                CMP     #1
                BEQ     loc_E73
                LDA     #1
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_2
                LDA     #0
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                JMP     loc_E7D
; ---------------------------------------------------------------------------

loc_E73:
                LDA     #1
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                LDA     #0
                STA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_2

loc_E7D:
                JSR     GAME_mapDraw    ; Show the map of all rooms, wait for a button to exit
                JSR     GAME_roomMainLoop ; Loop for the game code, exists if player left a room or died
                JSR     DRAW_ClearScreen
                LDA     #0
                STA     _Game_PlayersDead_ExitGameLoop
                LDX     #0

Game_Loop_Players:
                LDA     mapDraw_playerInCurrentRoom,X
                CMP     #1
                BNE     Game_Loop_NextPlayer
                LDA     CASTLE + CreepCastle::playerState,X
                CMP     #PLAYER_STATE::DIEING ; Player is dieing by collision, trapdoor or pressing RESTORE
                BEQ     Game_Loop_PlayerIsDieing

                LDA     CASTLE + CreepCastle::playerHasEscaped,X
                CMP     #1
                BNE     Game_Loop_NextPlayer
                STX     GAME_gameEscapeCastle_PlayerNumber
                JSR     GAME_gameEscapeCastle

                LDA     CASTLE + CreepCastle::flags
                AND     #CASTLE_FLAGS::SAVED_GAME
                BNE     Game_Loop_PlayerIsDead
                LDA     optionsMenu_UnlimitedLives
                CMP     #$FF
                BEQ     Game_Loop_PlayerIsDead
                LDA     optionsMenu_CurrentLevel
                CMP     #$FF
                BEQ     Game_Loop_PlayerIsDead
                TXA
                ASL     A
                ASL     A
                CLC
                ADC     #<(CASTLE + CreepCastle::playerTimer)
                STA     PP_A
                LDA     #>(CASTLE + CreepCastle::playerTimer)
                ADC     #0
                STA     PP_A+1
                LDY     #3
loc_ECD:        LDA     (PP_A),Y
                STA     gameHighScoresHandle_PlayerName,Y
                DEY
                BPL     loc_ECD
                STX     gameHighScoresHandle_playerIndex
                JSR     GAME_gameHighScoresHandle
                JMP     Game_Loop_PlayerIsDead
; ---------------------------------------------------------------------------

Game_Loop_PlayerIsDieing:
                LDA     optionsMenu_UnlimitedLives
                CMP     #$FF
                BEQ     loc_EED
                DEC     CASTLE + CreepCastle::playerRemainingLives,X
                LDA     CASTLE + CreepCastle::playerRemainingLives,X
                BEQ     Game_Loop_PlayerIsDead

loc_EED:        LDA     CASTLE + CreepCastle::playerStartRoom,X
                STA     CASTLE + CreepCastle::playerCurrentRoom,X
                LDA     CASTLE + CreepCastle::playerStartDoor,X
                STA     CASTLE + CreepCastle::playerCurrentDoor,X
                JMP     Game_Loop_NextPlayer
; ---------------------------------------------------------------------------

Game_Loop_PlayerIsDead:
                LDA     #0
                STA     CASTLE + CreepCastle::playerIsAlive,X
                LDA     #1
                STA     _Game_PlayersDead_ExitGameLoop

Game_Loop_NextPlayer:
                INX
                CPX     #2
                BCC     Game_Loop_Players

                LDA     _Game_PlayersDead_ExitGameLoop
                CMP     #1
                BNE     _Game_Loop

                JSR     DRAW_ClearScreen
                LDA     #<_Game_GAME_OVER_STR
                STA     object_Ptr
                LDA     #>_Game_GAME_OVER_STR
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

                LDA     CASTLE + CreepCastle::playerCount
                CMP     #0
                BEQ     loc_F4B
                LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_1
                CMP     #1
                BEQ     loc_F39
                LDA     #<_Game_PLAYER_1_STR
                STA     object_Ptr
                LDA     #>_Game_PLAYER_1_STR
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

loc_F39:        LDA     CASTLE + CreepCastle::playerIsAlive + CreepPlayerData::player_2
                CMP     #1
                BEQ     loc_F4B
                LDA     #<_Game_PLAYER_2_STR
                STA     object_Ptr
                LDA     #>_Game_PLAYER_2_STR
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

loc_F4B:        LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1
                LDA     #35
                JSR     GAME_WAIT_DELAY_100ms

_Game_Loop:
                JMP     Game_Loop
; ---------------------------------------------------------------------------

Game_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
                .BYTE $B4
_Game_PlayersDead_ExitGameLoop:.BYTE $A0
                .BYTE $89
_Game_GAME_OVER_STR:_CreepObj_Text 60, 56, COLOR::LIGHT_RED, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "GAME OVE"
                .BYTE $D2, 0
_Game_PLAYER_1_STR:_CreepObj_Text 48, 104, COLOR::YELLOW, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "FOR PLAYER "
                .BYTE $B1, 0
_Game_PLAYER_2_STR:_CreepObj_Text 48, 128, COLOR::ORANGE, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "FOR PLAYER "
                .BYTE $B2, 0

; =============== S U B R O U T I N E =======================================

; Show the map of all rooms, wait for a button to exit

.proc GAME_mapDraw
                PHA
                TYA
                PHA
                TXA
                PHA

mapDisplay_loop:
                JSR     DRAW_ClearScreen
                LDA     #COLOR::BLACK
                STA     VIC::SP0COL      ; Color sprite 0
                STA     VIC::SP1COL      ; Color sprite 1
                LDA     #0
                STA     _mapDraw_currentPlayer

mapDisplay_setup_player_loop:
                LDX     _mapDraw_currentPlayer
                LDA     mapDraw_playerInCurrentRoom,X
                CMP     #1
                BEQ     loc_FB6
                JMP     loc_1087
; ---------------------------------------------------------------------------

loc_FB6:
                LDA     CASTLE + CreepCastle::playerCurrentRoom,X
                JSR     GAME_selectRoom ; Set roomPtr to room # in A

                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                ORA     MAP_ROOM_VISIBLE
                STA     (mRoomPtr),Y

                LDA     CASTLE + CreepCastle::playerCurrentDoor,X
                JSR     GAME_selectDoor ; Select door #A in the current room
                LDY     #CreepObj_Door::Flags
                LDA     (mVObjectPtr),Y
                AND     #%00000011
                STA     _mapDraw_doorPosition

                JSR     Sprite_Create
                TXA
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                STA     _mapDraw_playerSpriteIndex

                LDY     #CreepRoom::XPos ; X position of the room on the map
                LDA     (mRoomPtr),Y
                LDY     #CreepObj_Door::mapDoorXOffset
                CLC
                ADC     (mVObjectPtr),Y
                CLC
                LDY     _mapDraw_doorPosition
                ADC     _mapDraw_playerXOffsTable,Y
                SEC
                SBC     #4
                ASL     A
                LDY     _mapDraw_playerSpriteIndex
                STA     IRQ_VIC_MnX,Y   ; X Coordinate Sprite 0
                BCC     loc_1004
                LDA     BITMASK_01__80,Y
                ORA     IRQ_VIC_MSIGX   ; MSBs of X coordinates
                JMP     loc_100B
; ---------------------------------------------------------------------------

loc_1004:
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     IRQ_VIC_MSIGX   ; MSBs of X coordinates

loc_100B:       STA     IRQ_VIC_MSIGX   ; MSBs of X coordinates

                CLC
                LDY     #CreepRoom::YPos ; Y position of the room on the map
                LDA     (mRoomPtr),Y
                LDY     #CreepObj_Door::mapDoorYOffset
                ADC     (mVObjectPtr),Y
                CLC
                LDY     _mapDraw_doorPosition
                ADC     _mapDraw_playerYOffsTable,Y
                CLC
                ADC     #50
                LDY     _mapDraw_playerSpriteIndex
                STA     IRQ_VIC_MnY,Y   ; Y Coordinate Sprite 0

                LDY     _mapDraw_doorPosition
                LDA     _mapDraw_ArrowDownLeftUp_GfxID_Tbl,Y
                STA     mSprites + CreepSprite::gfxID,X
                JSR     Sprite_Update

                LDY     _mapDraw_playerSpriteIndex
                LDA     BITMASK_01__80,Y
                ORA     IRQ_VIC_ME      ; Sprite enabled
                STA     IRQ_VIC_ME      ; Sprite enabled

                LDY     _mapDraw_currentPlayer
                LDX     CASTLE + CreepCastle::playerRemainingLives,Y
                LDA     _mapDraw_PLAYER_LIVES_COLOR_TAB,X
                STA     _mapDraw_ONE_UP + CreepObj_Text::Color
                STA     _mapDraw_TWO_UP + CreepObj_Text::Color

                TYA
                ASL     A
                TAX
                LDA     _mapDraw_Player_Up_Tbl,X
                STA     object_Ptr
                LDA     _mapDraw_Player_Up_Tbl+1,X
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

                TYA
                ASL     A
                ASL     A
                CLC
                ADC     #<(CASTLE + CreepCastle::playerTimer)
                STA     object_Ptr
                LDA     #0
                ADC     #>(CASTLE + CreepCastle::playerTimer)
                STA     object_Ptr+1
                JSR     ConvertTimerToTime

                CLC
                LDA     _mapDraw_playerTimerXOffsetTable,Y
                ADC     #8
                STA     DRAW_Image_Foreground_Left
                LDA     #16
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::time_separators
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

loc_1087:
                INC     _mapDraw_currentPlayer
                LDA     _mapDraw_currentPlayer
                CMP     #2
                BEQ     loc_1094
                JMP     mapDisplay_setup_player_loop
; ---------------------------------------------------------------------------

loc_1094:
                JSR     GAME_mapDrawRooms ; Draw the actual rooms with doors but without players, etc

                LDA     #0
                STA     _mapDraw_MAP_PLAYERS_IN_SAME_ROOM
                LDA     #1
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_1
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_2
                LDA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                CMP     #1
                BEQ     loc_10BA
                LDA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_2
                CMP     #1
                BNE     loc_10E3
                LDA     #0
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_2
                JMP     loc_10E3
; ---------------------------------------------------------------------------

loc_10BA:
                LDA     #0
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_1
                LDA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_2
                CMP     #1
                BNE     loc_10E3
                LDA     #0
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_2
                LDA     CASTLE + CreepCastle::playerCurrentDoor + CreepPlayerData::player_1
                CMP     CASTLE + CreepCastle::playerCurrentDoor + CreepPlayerData::player_2
                BNE     loc_10E3
                LDA     #1
                STA     _mapDraw_MAP_PLAYERS_IN_SAME_ROOM
                LDA     #COLOR::WHITE
                STA     VIC::SP0COL      ; Color sprite 0
                STA     VIC::SP1COL      ; Color sprite 1
                JMP     loc_10EB
; ---------------------------------------------------------------------------

loc_10E3:
                LDA     #COLOR::BLACK
                STA     VIC::SP0COL      ; Color sprite 0
                STA     VIC::SP1COL      ; Color sprite 1

loc_10EB:
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1

                LDA     #1
                STA     _mapDraw_flag_inMapDisplay_UNUSED
                LDA     #0
                STA     KEY_RestorePressed
                LDA     _mapDraw_Arrow_TimerTable + CreepPlayerData::player_1
                STA     _mapDraw_MAP_ARROW_FLASH_TIMER + CreepPlayerData::player_1
                LDA     _mapDraw_Arrow_TimerTable + CreepPlayerData::player_2
                STA     _mapDraw_MAP_ARROW_FLASH_TIMER + CreepPlayerData::player_2
                LDA     #0
                STA     _mapDraw_currentPlayer

mapDraw_waitLoop:
                LDA     #1
                STA     IRQ_DELAY_COUNTER
                LDX     _mapDraw_currentPlayer
                LDA     _mapDraw_MAP_PLAYERS_IN_SAME_ROOM
                CMP     #1
                BEQ     _mapDisplay_check_keys
                DEC     _mapDraw_MAP_ARROW_FLASH_TIMER,X
                BNE     _mapDisplay_check_keys
                LDA     _mapDraw_Arrow_TimerTable,X
                STA     _mapDraw_MAP_ARROW_FLASH_TIMER,X
                CPX     #0
                BEQ     loc_1133

                LDA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                CMP     #1
                BEQ     loc_113E

loc_1133:
                LDA     VIC::SP0COL      ; Color sprite 0
                EOR     #COLOR::WHITE
                STA     VIC::SP0COL      ; Color sprite 0
                JMP     _mapDisplay_check_keys
; ---------------------------------------------------------------------------

loc_113E:
                LDA     VIC::SP1COL      ; Color sprite 1
                EOR     #COLOR::WHITE
                STA     VIC::SP1COL      ; Color sprite 1

_mapDisplay_check_keys:
                LDA     KEY_RestorePressed
                CMP     #1              ; RESTORE pressed?
                BNE     loc_115A        ; => no
                LDA     #0
                STA     KEY_RestorePressed
                LDA     #0
                STA     _mapDraw_flag_inMapDisplay_UNUSED
                JMP     GAME_mainLoop
; ---------------------------------------------------------------------------

loc_115A:
                TXA
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key

                LDA     PROT_5F6A_ALWAYS_0
                CMP     #1
                BNE     loc_1170
                LDA     #1
                STA     PROT_2E02_UNUSED
                JSR     PROT_UNKNOWN_FUNC
                JMP     mapDisplay_loop
; ---------------------------------------------------------------------------

loc_1170:
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1              ; RUN/STOP pressed?
                BNE     loc_117D        ; => no
                JSR     GAME_gamePositionSave
                JMP     mapDisplay_loop
; ---------------------------------------------------------------------------

loc_117D:
                LDA     KEY_GetJoystick_Button ; Joystick button pressed?
                BEQ     loc_1187        ; => no
                LDA     #1
                STA     _mapDraw_PLAYER_BUTTON_CONFIRMED,X

loc_1187:
                LDA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_1
                CMP     #1
                BNE     loc_1195
                LDA     _mapDraw_PLAYER_BUTTON_CONFIRMED + CreepPlayerData::player_2
                CMP     #1
                BEQ     _mapDisplay_waitForButtonRelease

loc_1195:
                LDA     _mapDraw_currentPlayer
                EOR     #1
                STA     _mapDraw_currentPlayer

loc_119D:
                LDA     IRQ_DELAY_COUNTER ; Wait for 1/60s
                BNE     loc_119D        ; Wait for 1/60s
                JMP     mapDraw_waitLoop
; ---------------------------------------------------------------------------

_mapDisplay_waitForButtonRelease:
                LDA     #0
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Button
                BNE     _mapDisplay_waitForButtonRelease
                LDA     #1
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Button
                BNE     _mapDisplay_waitForButtonRelease

                LDA     #SOUND_EFFECT::MAP_CLOSE
                JSR     SND_PlayEffect
                LDA     #0
                STA     _mapDraw_flag_inMapDisplay_UNUSED
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
mapDraw_playerInCurrentRoom: _CreepPlayerData $A0,$A0
_mapDraw_MAP_PLAYERS_IN_SAME_ROOM:.BYTE $CA
_mapDraw_PLAYER_BUTTON_CONFIRMED: _CreepPlayerData $A0,$AF
_mapDraw_MAP_ARROW_FLASH_TIMER: _CreepPlayerData $80,$CF
_mapDraw_flag_inMapDisplay_UNUSED:.BYTE 0
_mapDraw_Arrow_TimerTable: _CreepPlayerData 6,15
_mapDraw_playerTimerXOffsetTable:.BYTE  16,116,23,24
_mapDraw_currentPlayer:.BYTE $FF
_mapDraw_playerSpriteIndex:.BYTE $A0
_mapDraw_doorPosition:.BYTE $A0
_mapDraw_playerXOffsTable:.BYTE ( -1 & $FF),  2       ,(-1 & $FF),(-5 & $FF)
_mapDraw_playerYOffsTable:.BYTE (-10 & $FF),(-2 & $FF),  6       ,(-2 & $FF)
_mapDraw_ArrowDownLeftUp_GfxID_Tbl:.BYTE GfxID::roommap_arrow_down,GfxID::roommap_arrow_left,GfxID::roommap_arrow_up
_mapDraw_PLAYER_LIVES_COLOR_TAB:.BYTE (COLOR::WHITE<<4)+COLOR::CYAN,COLOR::LIGHT_RED,COLOR::YELLOW,COLOR::LIGHT_GREEN

_mapDraw_Player_Up_Tbl:.addr _mapDraw_ONE_UP,_mapDraw_TWO_UP
_mapDraw_ONE_UP:_CreepObj_Text 16, 0, COLOR::WHITE, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "ONE U"
                .BYTE $D0, 0
_mapDraw_TWO_UP:_CreepObj_Text 116, 0, COLOR::WHITE, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "TWO U"
                .BYTE $D0
                .BYTE 0

; =============== S U B R O U T I N E =======================================

; Draw the actual rooms with doors but without players, etc

.proc GAME_mapDrawRooms
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #<ROOM_BASE
                STA     mRoomPtr
                LDA     #>ROOM_BASE
                STA     mRoomPtr+1

mapRoomDraw_roomLoop:
                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                BIT     MAP_ROOM_STOP_DRAW
                BEQ     loc_121C
                JMP     mapRoomDraw_return
; ---------------------------------------------------------------------------

loc_121C:
                BIT     MAP_ROOM_VISIBLE
                BNE     loc_1224
                JMP     mapRoomDraw_nextRoom
; ---------------------------------------------------------------------------

loc_1224:
                AND     #%00001111
                STA     OBJECT_roommap_floor_square_COLOR+1
                LDY     #CreepRoom::XPos ; X position of the room on the map
                LDA     (mRoomPtr),Y
                STA     _mapDrawRooms_roomX
                LDY     #CreepRoom::YPos ; Y position of the room on the map
                LDA     (mRoomPtr),Y
                STA     _mapDrawRooms_roomY
                LDY     #CreepRoom::widthHeight ; Bit 0-2: height, Bit 3-5: width on the map
                LDA     (mRoomPtr),Y
                AND     #%00000111
                STA     _mapDrawRooms_roomHeight
                LDA     (mRoomPtr),Y
                LSR     A
                LSR     A
                LSR     A
                AND     #%00000111
                STA     _mapDrawRooms_roomWidth
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     _mapDrawRooms_roomY
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::roommap_floor_square
                STA     DRAW_Image_Foreground_GfxID
                LDA     _mapDrawRooms_roomHeight
                STA     _mapDrawRooms_HeightIn8Pixel

mapRoomDraw_VLoop:
                LDA     _mapDrawRooms_roomWidth
                STA     _mapDrawRooms_WidthIn4Pixel
                LDA     _mapDrawRooms_roomX
                STA     DRAW_Image_Foreground_Left

mapRoomDraw_HLoop:
                JSR     DRAW_Image      ; Draw the fill box of the room

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                DEC     _mapDrawRooms_WidthIn4Pixel
                BNE     mapRoomDraw_HLoop ; Draw the fill box of the room
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     _mapDrawRooms_HeightIn8Pixel
                BNE     mapRoomDraw_VLoop

                LDA     _mapDrawRooms_roomX
                STA     DRAW_Image_Mask_Left
                LDA     _mapDrawRooms_roomY
                STA     DRAW_Image_Mask_Top
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                LDA     _mapDrawRooms_roomWidth
                STA     _mapDrawRooms_WidthIn4Pixel
                LDA     #GfxID::roommap_topButtomEdge
                STA     DRAW_Image_Mask_GfxID

_mapRoomDraw_drawLineTop:
                JSR     DRAW_Image      ; Draw top line of the room

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Mask_Left
                DEC     _mapDrawRooms_WidthIn4Pixel
                BNE     _mapRoomDraw_drawLineTop ; Draw top line of the room

                LDA     _mapDrawRooms_roomX
                STA     DRAW_Image_Mask_Left
                LDA     _mapDrawRooms_roomHeight
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     _mapDrawRooms_roomY
                SEC
                SBC     #3
                STA     DRAW_Image_Mask_Top
                LDA     _mapDrawRooms_roomWidth
                STA     _mapDrawRooms_WidthIn4Pixel

_mapRoomDraw_drawLineBottom:
                JSR     DRAW_Image      ; Draw bottom line of the room

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Mask_Left
                DEC     _mapDrawRooms_WidthIn4Pixel
                BNE     _mapRoomDraw_drawLineBottom ; Draw bottom line of the room

                LDA     _mapDrawRooms_roomX
                STA     DRAW_Image_Mask_Left
                LDA     _mapDrawRooms_roomY
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::roommap_leftEdge
                STA     DRAW_Image_Mask_GfxID
                LDA     _mapDrawRooms_roomHeight
                STA     _mapDrawRooms_WidthIn4Pixel

_mapRoomDraw_drawLineLeft:
                JSR     DRAW_Image      ; Draw left line of the room

                CLC
                LDA     DRAW_Image_Mask_Top
                ADC     #8
                STA     DRAW_Image_Mask_Top
                DEC     _mapDrawRooms_WidthIn4Pixel
                BNE     _mapRoomDraw_drawLineLeft ; Draw left line of the room

                LDA     _mapDrawRooms_roomWidth
                ASL     A
                ASL     A
                CLC
                ADC     _mapDrawRooms_roomX
                SEC
                SBC     #4
                STA     DRAW_Image_Mask_Left
                LDA     _mapDrawRooms_roomY
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::roommap_rightEdge
                STA     DRAW_Image_Mask_GfxID
                LDA     _mapDrawRooms_roomHeight
                STA     _mapDrawRooms_WidthIn4Pixel

_mapRoomDraw_drawLineRight:
                JSR     DRAW_Image      ; Draw right line of the room

                CLC
                LDA     DRAW_Image_Mask_Top
                ADC     #8
                STA     DRAW_Image_Mask_Top
                DEC     _mapDrawRooms_WidthIn4Pixel
                BNE     _mapRoomDraw_drawLineRight ; Draw right line of the room

                LDA     #0
                JSR     GAME_selectDoor ; Select door #A in the current room
                LDA     selectedDoor_Count
                STA     _mapDrawRooms_WidthIn4Pixel

mapRoomDraw_nextDoor:
                LDA     _mapDrawRooms_WidthIn4Pixel
                BNE     mapRoomDraw_drawDoor ; => there are still doors in the room

mapRoomDraw_nextRoom:
                CLC
                LDA     mRoomPtr
                ADC     #.SIZEOF(CreepRoom)
                STA     mRoomPtr
                BCC     loc_1359
                INC     mRoomPtr+1

loc_1359:
                JMP     mapRoomDraw_roomLoop
; ---------------------------------------------------------------------------

mapRoomDraw_drawDoor:
                LDY     #CreepObj_Door::Flags
                LDA     (mVObjectPtr),Y
                AND     #%00000011
                BNE     loc_136D        ; 0 = Top
                LDA     _mapDrawRooms_roomY
                STA     DRAW_Image_Mask_Top
                JMP     loc_1381
; ---------------------------------------------------------------------------

loc_136D:
                CMP     #DOOR_FLAGS::POSITION_BOTTOM
                BNE     loc_13A0
                LDA     _mapDrawRooms_roomHeight
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     _mapDrawRooms_roomY
                SEC
                SBC     #3
                STA     DRAW_Image_Mask_Top

loc_1381:
                LDA     _mapDrawRooms_roomX
                LDY     #CreepObj_Door::mapDoorXOffset
                CLC
                ADC     (mVObjectPtr),Y
                STA     DRAW_Image_Mask_Left
                AND     #%00000010
                BEQ     loc_139B
                EOR     DRAW_Image_Mask_Left
                STA     DRAW_Image_Mask_Left
                LDA     #GfxID::roommap_door_topButtomRight
                JMP     mapRoomDraw_drawSingleDoor
; ---------------------------------------------------------------------------

loc_139B:
                LDA     #GfxID::roommap_door_topButtomLeft
                JMP     mapRoomDraw_drawSingleDoor
; ---------------------------------------------------------------------------

loc_13A0:
                PHA
                LDA     _mapDrawRooms_roomY
                CLC
                LDY     #CreepObj_Door::mapDoorYOffset
                ADC     (mVObjectPtr),Y
                STA     DRAW_Image_Mask_Top
                PLA
                CMP     #DOOR_FLAGS::POSITION_LEFT
                BEQ     loc_13C5
                LDA     _mapDrawRooms_roomWidth ; Right
                ASL     A
                ASL     A
                CLC
                ADC     _mapDrawRooms_roomX
                SEC
                SBC     #4
                STA     DRAW_Image_Mask_Left
                LDA     #GfxID::roommap_door_right
                JMP     mapRoomDraw_drawSingleDoor
; ---------------------------------------------------------------------------

loc_13C5:
                LDA     _mapDrawRooms_roomX
                STA     DRAW_Image_Mask_Left
                LDA     #GfxID::roommap_door_left

mapRoomDraw_drawSingleDoor:
                STA     DRAW_Image_Mask_GfxID
                JSR     DRAW_Image

                CLC
                LDA     mVObjectPtr
                ADC     #.SIZEOF(CreepObj_Door)
                STA     mVObjectPtr
                BCC     loc_13DE
                INC     mVObjectPtr+1

loc_13DE:
                DEC     _mapDrawRooms_WidthIn4Pixel
                JMP     mapRoomDraw_nextDoor
; ---------------------------------------------------------------------------

mapRoomDraw_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

_mapDrawRooms_WidthIn4Pixel:.BYTE $A0
_mapDrawRooms_HeightIn8Pixel:.BYTE $B1
_mapDrawRooms_roomX:.BYTE $A0
_mapDrawRooms_roomY:.BYTE $8C
_mapDrawRooms_roomWidth:.BYTE $A0
_mapDrawRooms_roomHeight:.BYTE $A0
.endproc

; =============== S U B R O U T I N E =======================================

; Load room for the currently active player(s)

.proc GAME_roomLoadAndDraw
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     DRAW_ClearScreen

; Erase screen direction buffer
                LDA     #<SCR_DIR_2K_BUF
                STA     PP_A
                LDA     #>SCR_DIR_2K_BUF
                STA     PP_A+1
                LDY     #0
loc_1402:       LDA     #0
loc_1404:       STA     (PP_A),Y
                INY
                BNE     loc_1404
                INC     PP_A+1
                LDA     PP_A+1
                CMP     #>SPRITE_BASE_A
                BCC     loc_1402

                LDA     mapDraw_playerInCurrentRoom + CreepPlayerData::player_1
                CMP     #1              ; Player #1 in the current room?
                BEQ     loc_141D        ; Load room for player #1 (and maybe player #2 is in it as well)
                LDX     #1              ; Load room for player #2
                JMP     loc_141F
; ---------------------------------------------------------------------------

loc_141D:       LDX     #0              ; Load room for player #1 (and maybe player #2 is in it as well)
loc_141F:       LDA     Intro_IsInIntroFlag
                CMP     #1
                BNE     loc_142C
                LDA     Intro_RoomNumber
                JMP     _roomLoadAndDraw_room_in_A
; ---------------------------------------------------------------------------

loc_142C:       LDA     CASTLE + CreepCastle::playerCurrentRoom,X

_roomLoadAndDraw_room_in_A:
                JSR     GAME_selectRoom ; Set roomPtr to room # in A

                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                AND     #%00001111
                STA     OBJECT_walkway_left_ROOMCOLOR
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                ORA     OBJECT_walkway_left_ROOMCOLOR
                STA     OBJECT_walkway_left_ROOMCOLOR
                STA     OBJECT_walkway_center_ROOMCOLOR
                STA     OBJECT_walkway_right_ROOMCOLOR
                STA     OBJECT_ladder_b_ROOMCOLOR
                STA     OBJECT_ladder_b_ROOMCOLOR+2
                STA     OBJECT_trapdoor_1_ROOMCOLOR
                STA     OBJECT_trapdoor_1_ROOMCOLOR+1
                STA     OBJECT_trapdoor_1_ROOMCOLOR+2
                STA     OBJECT_trapdoor_2_ROOMCOLOR
                STA     OBJECT_trapdoor_2_ROOMCOLOR+1
                STA     OBJECT_trapdoor_2_ROOMCOLOR+2
                STA     OBJECT_trapdoor_3_ROOMCOLOR
                STA     OBJECT_trapdoor_3_ROOMCOLOR+1
                STA     OBJECT_trapdoor_3_ROOMCOLOR+2
                STA     OBJECT_trapdoor_4_ROOMCOLOR
                STA     OBJECT_trapdoor_4_ROOMCOLOR+1
                STA     OBJECT_trapdoor_4_ROOMCOLOR+2
                STA     OBJECT_trapdoor_5_ROOMCOLOR
                STA     OBJECT_trapdoor_5_ROOMCOLOR+1
                STA     OBJECT_trapdoor_5_ROOMCOLOR+2
                STA     OBJECT_trapdoor_6_ROOMCOLOR
                STA     OBJECT_trapdoor_6_ROOMCOLOR+1
                STA     OBJECT_trapdoor_6_ROOMCOLOR+2
                LDY     #7
loc_1489:       STA     OBJECT_MovingSidewalk_anim_1_ROOMCOLOR,Y
                STA     OBJECT_MovingSidewalk_anim_2_ROOMCOLOR,Y
                STA     OBJECT_MovingSidewalk_anim_3_ROOMCOLOR,Y
                STA     OBJECT_MovingSidewalk_anim_4_ROOMCOLOR,Y
                DEY
                BPL     loc_1489
                AND     #%00001111
                ORA     #(COLOR::WHITE<<4)+COLOR::BLACK
                STA     OBJECT_sliding_pole_onePixel_ROOMCOLOR
                LDA     OBJECT_walkway_right_ROOMCOLOR
                AND     #%11110000
                ORA     #COLOR::WHITE
                STA     OBJECT_ladder_a_ROOMCOLOR
                STA     OBJECT_ladder_b_ROOMCOLOR+1

                LDY     #CreepRoom::objectPtr ; Objects within the room
                LDA     (mRoomPtr),Y
                STA     object_Ptr
                INY
                LDA     (mRoomPtr),Y
                STA     object_Ptr+1

                LDA     Intro_IsInIntroFlag
                CMP     #1
                BNE     loc_14C5
                CLC
                LDA     object_Ptr+1
                ADC     #>(SAVE_GAME_MEMORY - CASTLE)
                STA     object_Ptr+1

loc_14C5:       JSR     DRAW_Objects    ; Draw all objects in the current room initially

                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

; Loop for the game code, exists if player left a room or died

.proc GAME_roomMainLoop
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     GAME_roomLoadAndDraw ; Load room for the currently active player(s)

                LDX     #0
loc_14D8:       LDA     mapDraw_playerInCurrentRoom,X
                CMP     #1
                BNE     loc_14E5
                STX     obj_Player_Add_playerNumber
                JSR     obj_Player_Add  ; Add player to the current room
loc_14E5:       INX
                CPX     #2
                BCC     loc_14D8

                LDA     #1
                STA     _roomMainLoop_InsideMainLoop_WRITE_ONLY
                LDA     #0
                STA     KEY_RestorePressed
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1

roomMain_loop:  JSR     GAME_ExecuteEvents ; Handle 1/30 of all game processing

                LDA     PROT_5F6A_ALWAYS_0
                CMP     #1
                BNE     loc_150E
                LDA     #0
                STA     PROT_2E02_UNUSED
                JSR     PROT_UNKNOWN_FUNC

loc_150E:
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1              ; RUN/STOP pressed?
                BNE     roomMain_no_RUN_STOP ; => no

loc_1515:
                LDA     #3
                STA     IRQ_DELAY_COUNTER

loc_151A:
                LDA     IRQ_DELAY_COUNTER ; Wait for 3/60s
                BNE     loc_151A        ; Wait for 3/60s
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1              ; RUN/STOP released?
                BEQ     loc_1515        ; => no, wait
                LDX     #3

loc_152B:
                LDA     CIA1::TOD1,X   ; Real Time Clock 1/10s
                STA     _roomMainLoop_COPY_CIA_TOD1 + CreepPlayerTime::player_1,X
                LDA     CIA2::TOD1,X   ; Real Time Clock 1/10s
                STA     _roomMainLoop_COPY_CIA_TOD1 + CreepPlayerTime::player_2,X
                DEX
                BPL     loc_152B

loc_153A:
                LDA     #0
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1
                BNE     loc_153A

loc_1546:
                LDA     #3
                STA     IRQ_DELAY_COUNTER

loc_154B:
                LDA     IRQ_DELAY_COUNTER ; Wait for 3/60s
                BNE     loc_154B        ; Wait for 3/60s
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_RunStopPressed
                CMP     #1
                BEQ     loc_1546

                LDX     #3
loc_155C:       LDA     _roomMainLoop_COPY_CIA_TOD1 + CreepPlayerTime::player_1,X
                STA     CIA1::TOD1,X   ; Real Time Clock 1/10s
                LDA     _roomMainLoop_COPY_CIA_TOD1 + CreepPlayerTime::player_2,X
                STA     CIA2::TOD1,X   ; Real Time Clock 1/10s
                DEX
                BPL     loc_155C

roomMain_no_RUN_STOP:
                LDA     KEY_RestorePressed
                CMP     #1              ; RESTORE pressed?
                BNE     loc_1594        ; => no
                LDA     #0
                STA     KEY_RestorePressed
                LDX     #1

roomMain_RESTORE_pressed:
                LDA     CASTLE + CreepCastle::playerState,X
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     loc_1591
                LDA     #PLAYER_STATE::DIEING ; Player is dieing by collision, trapdoor or pressing RESTORE
                STA     CASTLE + CreepCastle::playerState,X
                LDY     obj_Player_Execute_playerSpriteNumber,X
                LDA     mSprites + CreepSprite::state,Y
                ORA     SPRITE_FLAGS_SHOULD_DIE ; Let the sprite die, depending of the type by flashing it
                STA     mSprites + CreepSprite::state,Y

loc_1591:
                DEX
                BPL     roomMain_RESTORE_pressed

loc_1594:
                LDA     CASTLE + CreepCastle::playerState + CreepPlayerData::player_1
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     loc_15A3
                LDA     #0
                STA     CASTLE + CreepCastle::firstPlayerIndexInRoom
                JMP     roomMain_loop
; ---------------------------------------------------------------------------

loc_15A3:
                LDA     CASTLE + CreepCastle::playerState + CreepPlayerData::player_2
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     loc_15B2
                LDA     #1
                STA     CASTLE + CreepCastle::firstPlayerIndexInRoom

loc_15AF:       JMP     roomMain_loop
; ---------------------------------------------------------------------------

loc_15B2:       LDX     #0
loc_15B4:       LDA     CASTLE + CreepCastle::playerState,X
                CMP     #PLAYER_STATE::MOVING_IN_OUT ; Player is in the transition to move in or out of a room
                BEQ     loc_15AF
                CMP     #PLAYER_STATE::START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
                BEQ     loc_15AF
                INX
                CPX     #2
                BCC     loc_15B4

                LDA     #0
                STA     _roomMainLoop_InsideMainLoop_WRITE_ONLY

                LDX     #30             ; 30 ticks = 1s

loc_15CB:       JSR     GAME_ExecuteEvents ; Handle 1/30 of all game processing
                DEX
                BNE     loc_15CB
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_roomMainLoop_InsideMainLoop_WRITE_ONLY:.BYTE 0
_roomMainLoop_COPY_CIA_TOD1: _CreepPlayerTime $A8,$A0,$A0,$A0, $A0,$A0,$C5,$A2
.endproc

; =============== S U B R O U T I N E =======================================

; Draw all objects in the current room initially

.proc DRAW_Objects
                PHA
                TYA
                PHA

_DRAW_Objects_loop:
                LDY     #0
                LDA     (object_Ptr),Y
                STA     _DRAW_Objects_func+1
                INY
                LDA     (object_Ptr),Y
                STA     _DRAW_Objects_func+2
                CLC
                LDA     object_Ptr
                ADC     #2
                STA     object_Ptr
                BCC     loc_15FB
                INC     object_Ptr+1
loc_15FB:       LDA     _DRAW_Objects_func+2
                BEQ     _DRAW_Objects_return
_DRAW_Objects_func:
                JSR     _DRAW_Objects_func+1
                JMP     _DRAW_Objects_loop
_DRAW_Objects_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_MultiDraw_Object_Setup
                PHA
                TYA
                PHA
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode

_obj_MultiDraw_Object_Setup_loop:
                LDY     #CreepObj_MultiDraw::Repeat
                LDA     (object_Ptr),Y
                BEQ     _obj_MultiDraw_Object_Setup_return
                STA     _obj_MultiDraw_Prepare_Repeat
                LDY     #CreepObj_MultiDraw::gfxID
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_MultiDraw::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MultiDraw::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top

_obj_MultiDraw_Object_Setup_drawRepeat:
                JSR     DRAW_Image

                DEC     _obj_MultiDraw_Prepare_Repeat
                BEQ     _obj_MultiDraw_Object_Setup_nextObj

                CLC
                LDY     #CreepObj_MultiDraw::xOffset
                LDA     DRAW_Image_Foreground_Left
                ADC     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MultiDraw::yOffset
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                JMP     _obj_MultiDraw_Object_Setup_drawRepeat
; ---------------------------------------------------------------------------

_obj_MultiDraw_Object_Setup_nextObj:
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_MultiDraw)
                STA     object_Ptr
                BCC     _obj_MultiDraw_Object_Setup_loop
                INC     object_Ptr+1
                JMP     _obj_MultiDraw_Object_Setup_loop
; ---------------------------------------------------------------------------

_obj_MultiDraw_Object_Setup_return:
                INC     object_Ptr
                BNE     loc_1665
                INC     object_Ptr+1

loc_1665:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_obj_MultiDraw_Prepare_Repeat:.BYTE $A0
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_Walkway_Object_Setup
                PHA
                TYA
                PHA

obj_Walkway_Prepare_loopWalkways:
                LDY     #CreepObj_Walkway::Length
                LDA     (object_Ptr),Y
                STA     _obj_Walkway_Prepare_Length
                BNE     loc_167F
                INC     object_Ptr
                BNE     loc_167C
                INC     object_Ptr+1

loc_167C:
                JMP     obj_Walkway_Prepare_return
; ---------------------------------------------------------------------------

loc_167F:
                LDY     #CreepObj_Walkway::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Walkway::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #1
                STA     _obj_Walkway_Prepare_Index

                LDA     DRAW_Image_Foreground_Left
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDA     DRAW_Image_Foreground_Top
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

obj_Walkway_Prepare_loop:
                LDA     _obj_Walkway_Prepare_Index
                CMP     #1
                BEQ     loc_16BA
                CMP     _obj_Walkway_Prepare_Length
                BEQ     loc_16BF
                LDA     #GfxID::walkway_center
                JMP     loc_16C1
; ---------------------------------------------------------------------------

loc_16BA:
                LDA     #GfxID::walkway_left
                JMP     loc_16C1
; ---------------------------------------------------------------------------

loc_16BF:
                LDA     #GfxID::walkway_right

loc_16C1:
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     #1
                STA     _obj_Walkway_Prepare_Pos

loc_16D1:
                LDA     _obj_Walkway_Prepare_Index
                CMP     #1
                BEQ     loc_16E2
                CMP     _obj_Walkway_Prepare_Length
                BEQ     loc_16EE

loc_16DD:
                LDA     #DIR_ALLOW::RIGHT|DIR_ALLOW::LEFT
                JMP     loc_16F8
; ---------------------------------------------------------------------------

loc_16E2:
                LDA     _obj_Walkway_Prepare_Pos
                CMP     #1
                BNE     loc_16DD
                LDA     #DIR_ALLOW::RIGHT
                JMP     loc_16F8
; ---------------------------------------------------------------------------

loc_16EE:
                LDA     _obj_Walkway_Prepare_Pos
                CMP     DRAW_Image_Foreground_Width
                BNE     loc_16DD
                LDA     #DIR_ALLOW::LEFT

loc_16F8:
                LDY     #CreepScreenState::dirFlags
                ORA     (ScreenDirectionAddr),Y
                STA     (ScreenDirectionAddr),Y
                INC     _obj_Walkway_Prepare_Pos
                CLC
                LDA     ScreenDirectionAddr
                ADC     #.SIZEOF(CreepScreenState)
                STA     ScreenDirectionAddr
                BCC     loc_170C
                INC     ScreenDirectionAddr+1

loc_170C:
                LDA     _obj_Walkway_Prepare_Pos
                CMP     DRAW_Image_Foreground_Width
                BCC     loc_16D1
                BEQ     loc_16D1

                LDA     DRAW_Image_Foreground_Width
                ASL     A
                ASL     A
                CLC
                ADC     DRAW_Image_Foreground_Left
                STA     DRAW_Image_Foreground_Left
                INC     _obj_Walkway_Prepare_Index
                LDA     _obj_Walkway_Prepare_Index
                CMP     _obj_Walkway_Prepare_Length
                BEQ     loc_172F
                BCS     loc_1732

loc_172F:
                JMP     obj_Walkway_Prepare_loop
; ---------------------------------------------------------------------------

loc_1732:
                LDA     object_Ptr
                CLC
                ADC     #.SIZEOF(CreepObj_Walkway)
                STA     object_Ptr
                BCC     loc_173D
                INC     object_Ptr+1

loc_173D:
                JMP     obj_Walkway_Prepare_loopWalkways
; ---------------------------------------------------------------------------

obj_Walkway_Prepare_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_obj_Walkway_Prepare_Index:.BYTE $A0
_obj_Walkway_Prepare_Pos:.BYTE $A0
_obj_Walkway_Prepare_Length:.BYTE $A9
.endproc

; =============== S U B R O U T I N E =======================================

.proc obj_SlidingPole_Object_Setup
                PHA
                TYA
                PHA

obj_SlidingPole_nextPole:
                LDY     #CreepObj_SlidingPole::Length
                LDA     (object_Ptr),Y
                BNE     loc_1759
                INC     object_Ptr
                BNE     loc_1756
                INC     object_Ptr+1

loc_1756:
                JMP     obj_SlidingPole_Prepare_return
; ---------------------------------------------------------------------------

loc_1759:
                STA     _obj_SlidingPole_Prepare_Length
                LDY     #CreepObj_SlidingPole::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_SlidingPole::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top

                LDA     DRAW_Image_Foreground_Left
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDA     DRAW_Image_Foreground_Top
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

obj_SlidingPole_drawLoop:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::RIGHT|DIR_ALLOW::LEFT
                BEQ     loc_17AA
                SEC
                LDA     DRAW_Image_Foreground_Left
                SBC     #4
                STA     DRAW_Image_Mask_Left
                LDA     DRAW_Image_Foreground_Top
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::sliding_pole_platform_mask
                STA     DRAW_Image_Mask_GfxID
                LDA     #GfxID::sliding_pole_empty
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::ForegroundAndMask
                STA     DRAW_Image_Mode
                JMP     loc_17B4
; ---------------------------------------------------------------------------

loc_17AA:
                LDA     #GfxID::sliding_pole_plain
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode

loc_17B4:
                JSR     DRAW_Image

                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::DOWN
                STA     (ScreenDirectionAddr),Y
                DEC     _obj_SlidingPole_Prepare_Length
                BNE     loc_17D2
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_SlidingPole)
                STA     object_Ptr
                BCC     loc_17CF
                INC     object_Ptr+1

loc_17CF:
                JMP     obj_SlidingPole_nextPole
; ---------------------------------------------------------------------------

loc_17D2:
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                CLC
                LDA     ScreenDirectionAddr
                ADC     #80
                STA     ScreenDirectionAddr
                BCC     loc_17E6
                INC     ScreenDirectionAddr+1

loc_17E6:
                JMP     obj_SlidingPole_drawLoop
; ---------------------------------------------------------------------------

obj_SlidingPole_Prepare_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_obj_SlidingPole_Prepare_Length:.BYTE $80
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_Ladder_Object_Setup
                PHA
                TYA
                PHA

obj_Ladder_Prepare_loop:
                LDY     #CreepObj_Ladder::Length
                LDA     (object_Ptr),Y
                BNE     loc_1800
                INC     object_Ptr
                BNE     loc_17FD
                INC     object_Ptr+1

loc_17FD:
                JMP     obj_Ladder_Prepare_return
; ---------------------------------------------------------------------------

loc_1800:
                STA     _obj_Ladder_Prepare_Height
                LDY     #CreepObj_Ladder::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Ladder::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top

                LDA     DRAW_Image_Foreground_Left
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDA     DRAW_Image_Foreground_Top
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

obj_Ladder_loop:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::RIGHT|DIR_ALLOW::LEFT
                BNE     loc_184C
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode

                LDA     _obj_Ladder_Prepare_Height
                CMP     #1
                BEQ     loc_1844
                LDA     #GfxID::ladder_top
                STA     DRAW_Image_Foreground_GfxID
                JMP     obj_Ladder_draw_and_Done
; ---------------------------------------------------------------------------

loc_1844:
                LDA     #GfxID::ladder_middle
                STA     DRAW_Image_Foreground_GfxID
                JMP     obj_Ladder_draw_and_Done
; ---------------------------------------------------------------------------

loc_184C:
                LDA     #SCREEN_DRAW_MODE::ForegroundAndMask
                STA     DRAW_Image_Mode
                LDA     _obj_Ladder_Prepare_Height
                CMP     #1
                BNE     loc_1874
                LDA     #GfxID::ladder_bottom_floor
                STA     DRAW_Image_Foreground_GfxID
                LDA     #GfxID::ladder_bottom_floor_mask
                STA     DRAW_Image_Mask_GfxID
                LDA     DRAW_Image_Foreground_Left
                STA     DRAW_Image_Mask_Left
                LDA     DRAW_Image_Foreground_Top
                STA     DRAW_Image_Mask_Top

obj_Ladder_draw_and_Done:
                JSR     DRAW_Image

                JMP     obj_Ladder_drawDone
; ---------------------------------------------------------------------------

loc_1874:
                LDA     #GfxID::ladder_middle_floor
                STA     DRAW_Image_Foreground_GfxID
                LDA     #GfxID::ladder_middle_floor_mask
                STA     DRAW_Image_Mask_GfxID
                SEC
                LDA     DRAW_Image_Foreground_Left
                SBC     #4
                STA     DRAW_Image_Foreground_Left
                STA     DRAW_Image_Mask_Left
                LDA     DRAW_Image_Foreground_Top
                STA     DRAW_Image_Mask_Top
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left

obj_Ladder_drawDone:
                LDA     _obj_Ladder_Prepare_Height
                LDY     #CreepObj_Ladder::Length
                CMP     (object_Ptr),Y
                BEQ     loc_18AD
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::UP
                STA     (ScreenDirectionAddr),Y

loc_18AD:
                DEC     _obj_Ladder_Prepare_Height
                BNE     obj_Ladder_moreLadder
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Ladder)
                STA     object_Ptr
                BCC     loc_18BD
                INC     object_Ptr+1

loc_18BD:
                JMP     obj_Ladder_Prepare_loop
; ---------------------------------------------------------------------------

obj_Ladder_moreLadder:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::DOWN
                STA     (ScreenDirectionAddr),Y
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                CLC
                LDA     ScreenDirectionAddr
                ADC     #80
                STA     ScreenDirectionAddr
                BCC     loc_18DC
                INC     ScreenDirectionAddr+1

loc_18DC:
                JMP     obj_Ladder_loop
; ---------------------------------------------------------------------------

obj_Ladder_Prepare_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_obj_Ladder_Prepare_Height:.BYTE $D2
.endproc

; =============== S U B R O U T I N E =======================================

.proc DRAW_ClearScreen
                PHA
                TYA
                PHA
                LDA     SND_DisableSoundEffects ; Always 0, maybe 1 in the tape version?
                CMP     #1
                BEQ     loc_18F6
                LDA     VIC::CR1         ; Control register 1
                AND     #(~VIC_CR1_FLAGS::DEN & $FF) ; Video enable
                STA     VIC::CR1         ; Control register 1

loc_18F6:
                LDA     #0
                STA     IRQ_VIC_ME      ; Sprite enabled
                LDA     #<(TOP_HIGHRESVIDEORAM+$1F00)
                STA     PP_A
                LDA     #>(TOP_HIGHRESVIDEORAM+$1F00)
                STA     PP_A+1
                LDY     #$F9
loc_1904:       LDA     #0
loc_1906:       STA     (PP_A),Y
                DEY
                CPY     #$FF
                BNE     loc_1906
                DEC     PP_A+1
                LDA     PP_A+1
                CMP     #>TOP_HIGHRESVIDEORAM
                BCS     loc_1904

                LDY     #CreepSprite::spriteType
loc_1917:       LDA     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                STA     mSprites + CreepSprite::state,Y
                TYA
                CLC
                ADC     #.SIZEOF(CreepSprite)
                TAY
                BNE     loc_1917
                LDA     #0
                STA     OBJECT_COUNT
                STA     IRQ_VECTOR_RASTER_INDEX
                STA     IRQ_VECTOR_RASTER_TABLE + RASTER_LINE_INFO::color
                STA     IRQ_VIC_EC_BORDER ; Border color
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

.proc GAME_WAIT_DELAY_100ms
                STA     DELAY_TIME
                PHA
                TXA
                PHA
                LDX     #6              ; Written for a 60Hz NTSC machine
loc_193D:       LDA     DELAY_TIME
                STA     IRQ_DELAY_COUNTER
loc_1943:       LDA     IRQ_DELAY_COUNTER ; Wait for an IRQ, which happens at 60Hz on an NTSC machine
                BNE     loc_1943        ; Wait for an IRQ, which happens at 60Hz on an NTSC machine
                DEX
                BNE     loc_193D
                PLA
                TAX
                PLA
                RTS

DELAY_TIME:     .BYTE $A0
.endproc

; =============== S U B R O U T I N E =======================================

.proc GAME_gameEscapeCastle
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     DRAW_ClearScreen
                LDA     #6
                STA     IRQ_VECTOR_RASTER_INDEX

                LDA     CASTLE + CreepCastle::flags
                AND     #CASTLE_FLAGS::HAS_ESCAPE
                BEQ     loc_1971
                LDA     CASTLE + CreepCastle::escapeCastleOutsidePtr
                STA     object_Ptr
                LDA     CASTLE + CreepCastle::escapeCastleOutsidePtr+1
                STA     object_Ptr+1
                JSR     DRAW_Objects    ; Draw all objects in the current room initially

loc_1971:
                CLC
                LDA     GAME_gameEscapeCastle_PlayerNumber
                ADC     #'1'
                STA     _gameEscapeCastle_PlayerEscapeText+7 ; "  ESCAPE"
                LDA     #<_gameEscapeCastle_Texts
                STA     object_Ptr
                LDA     #>_gameEscapeCastle_Texts
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

                LDA     GAME_gameEscapeCastle_PlayerNumber
                ASL     A
                ASL     A
                CLC
                ADC     #<(CASTLE + CreepCastle::playerTimer)
                STA     object_Ptr
                LDA     #0
                ADC     #>(CASTLE + CreepCastle::playerTimer)
                STA     object_Ptr+1
                JSR     ConvertTimerToTime

                LDA     #GfxID::time_separators
                STA     DRAW_Image_Foreground_GfxID
                LDA     #104
                STA     DRAW_Image_Foreground_Left
                LDA     #24
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                AND     #(~VIC_CR1_FLAGS::RST8 & $FF)
                STA     VIC::CR1         ; Control register 1

                LDY     GAME_gameEscapeCastle_PlayerNumber
                LDX     obj_Player_Execute_playerSpriteNumber,Y
                LDA     #135
                STA     mSprites + CreepSprite::YPos,X
                LDA     #8
                STA     mSprites + CreepSprite::XPos,X

                JSR     GetRandom
                AND     #%1110
                BEQ     loc_19D5        ; Walk with a goodbye wave after coming back
                LDA     #.SIZEOF(CreepEscapeState)*0 ; Regular walk with a goodbye wave
                JMP     loc_19D7
; ---------------------------------------------------------------------------

loc_19D5:
                LDA     #.SIZEOF(CreepEscapeState)*4 ; Walk with a goodbye wave after coming back

loc_19D7:
                STA     _gameEscapeCastle_stateIndex
                LDA     #0
                STA     _gameEscapeCastle_stateSteps

gameEscapeCastle_stateLoop:
                LDA     _gameEscapeCastle_stateSteps
                BNE     loc_1A01
                LDY     _gameEscapeCastle_stateIndex
                LDA     _gameEscapeCastle_STATES + CreepEscapeState::XPos,Y
                BNE     loc_19EF
                JMP     gameEscapeCastle_return
; ---------------------------------------------------------------------------

loc_19EF:
                STA     _gameEscapeCastle_stateSteps
                LDA     _gameEscapeCastle_STATES + CreepEscapeState::nextState,Y
                STA     _gameEscapeCastle_currentState
                CLC
                LDA     _gameEscapeCastle_stateIndex
                ADC     #.SIZEOF(CreepEscapeState)
                STA     _gameEscapeCastle_stateIndex

loc_1A01:
                LDA     _gameEscapeCastle_currentState
                CMP     #ESCAPE_CASTLE_STATES::RUN_LEFT
                BCC     gameEscapeCastle_walk_right
                BEQ     gameEscapeCastle_walk_left

gameEscapeCastle_wave:
                INC     mSprites + CreepSprite::gfxID,X
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::player_wave_goodbye_end_marker
                BCS     loc_1A18
                CMP     #GfxID::player_wave_goodbye_1
                BCS     gameEscapeCastle_setSprite

loc_1A18:
                LDA     #GfxID::player_wave_goodbye_1
                JMP     gameEscapeCastle_setSprite
; ---------------------------------------------------------------------------

gameEscapeCastle_walk_right:
                INC     mSprites + CreepSprite::XPos,X
                INC     mSprites + CreepSprite::gfxID,X
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::exit
                BCS     loc_1A2E
                CMP     #GfxID::player_run_right_1
                BCS     gameEscapeCastle_setSprite

loc_1A2E:
                LDA     #GfxID::player_run_right_1
                JMP     gameEscapeCastle_setSprite
; ---------------------------------------------------------------------------

gameEscapeCastle_walk_left:
                DEC     mSprites + CreepSprite::XPos,X
                INC     mSprites + CreepSprite::gfxID,X
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::player_run_right_1
                BCC     gameEscapeCastle_setSprite
                LDA     #GfxID::player_run_left_1

gameEscapeCastle_setSprite:
                STA     mSprites + CreepSprite::gfxID,X
                TXA
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                TAY

                SEI
                LDA     mSprites + CreepSprite::XPos,X
                SEC
                SBC     #16
                ASL     A
                CLC
                ADC     #24             ; Offset to start at the left of the screen, just right of the border
                STA     IRQ_VIC_MnX,Y   ; X Coordinate Sprite 0
                LDA     mSprites + CreepSprite::XPos,X
                CMP     #132
                BCS     loc_1A6B
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     IRQ_VIC_MSIGX   ; MSBs of X coordinates
                JMP     loc_1A70
; ---------------------------------------------------------------------------

loc_1A6B:
                LDA     BITMASK_01__80,Y
                ORA     IRQ_VIC_MSIGX   ; MSBs of X coordinates

loc_1A70:
                STA     IRQ_VIC_MSIGX   ; MSBs of X coordinates
                CLI

                LDA     mSprites + CreepSprite::YPos,X
                CLC
                ADC     #50             ; Offset to start at the top of the screen, just below the border
                STA     IRQ_VIC_MnY,Y   ; Y Coordinate Sprite 0
                JSR     Sprite_Update

                LDA     BITMASK_01__80,Y
                ORA     IRQ_VIC_ME      ; Sprite enabled
                STA     IRQ_VIC_ME      ; Sprite enabled

                LDA     GAME_gameEscapeCastle_PlayerNumber
                BEQ     loc_1A91
                LDA     obj_Player_Execute_PlayerHeadColorTab+1
                JMP     loc_1A94
; ---------------------------------------------------------------------------

loc_1A91:       LDA     obj_Player_Execute_PlayerHeadColorTab
loc_1A94:       STA     VIC::SP0COL,Y    ; Color sprite 0

                DEC     _gameEscapeCastle_stateSteps
                LDA     #2
                STA     IRQ_DELAY_COUNTER

gameEscapeCastle_wait:
                LDA     IRQ_DELAY_COUNTER ; Wait for 2/60s
                BNE     gameEscapeCastle_wait ; Wait for 2/60s
                JMP     gameEscapeCastle_stateLoop
; ---------------------------------------------------------------------------

gameEscapeCastle_return:
                LDA     #10             ; 1s delay
                JSR     GAME_WAIT_DELAY_100ms
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
GAME_gameEscapeCastle_PlayerNumber:.BYTE $B5
_gameEscapeCastle_Texts:_CreepObj_Text 32, 0, COLOR::LIGHT_GREEN, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
_gameEscapeCastle_PlayerEscapeText:scrcode "PLAYER   ESCAPE"
                .BYTE $D3
                _CreepObj_Text 56, 24, COLOR::YELLOW, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "TIME"
                .BYTE $BA, 0
_gameEscapeCastle_STATES:_CreepEscapeState 128, ESCAPE_CASTLE_STATES::RUN_RIGHT
                _CreepEscapeState 25, ESCAPE_CASTLE_STATES::WAVE
                _CreepEscapeState 45, ESCAPE_CASTLE_STATES::RUN_RIGHT
                _CreepEscapeState 0, ESCAPE_CASTLE_STATES::RUN_RIGHT
                _CreepEscapeState 172, ESCAPE_CASTLE_STATES::RUN_RIGHT
                _CreepEscapeState 44, ESCAPE_CASTLE_STATES::RUN_LEFT
                _CreepEscapeState 25, ESCAPE_CASTLE_STATES::WAVE
                _CreepEscapeState 45, ESCAPE_CASTLE_STATES::RUN_RIGHT
                _CreepEscapeState 0,0
_gameEscapeCastle_currentState:.BYTE $A5

_gameEscapeCastle_stateSteps:.BYTE $A0
_gameEscapeCastle_stateIndex:.BYTE $A0

; =============== S U B R O U T I N E =======================================


.proc obj_Image_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     IMAGE_DATA_TABLE+$2C ; SPRITE_22 = GfxID::image_placeholder
                LDA     object_Ptr+1
                STA     IMAGE_DATA_TABLE+$2D
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::imagedraw_placeholder
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Image::Height
                LDA     (object_Ptr),Y  ; Height
                SEC
                SBC     #1
                LSR     A
                LSR     A
                LSR     A
                STA     PP_B
                INC     PP_B
                LDY     #CreepObj_Image::Width
                LDA     (object_Ptr),Y  ; Width
                TAX
                LDA     #0
                STA     PP_A
                STA     PP_A+1
loc_1B18:       CPX     #0
                BEQ     loc_1B2D
                CLC
                LDA     PP_A            ; PP_A += (((Height - 1) >> 3) + 1) * Width
                ADC     PP_B
                STA     PP_A
                LDA     PP_A+1
                ADC     #0
                STA     PP_A+1
                DEX
                JMP     loc_1B18
; ---------------------------------------------------------------------------

loc_1B2D:       ASL     PP_A
                ROL     PP_A+1          ; PP_A *= 2
                LDY     #CreepObj_Image::Height
                LDA     (object_Ptr),Y  ; Height
                TAX
                LDY     #0

loc_1B38:       CPX     #0
                BEQ     loc_1B4D
                CLC
                LDA     PP_A
                ADC     (object_Ptr),Y  ; Width
                STA     PP_A            ; PP_A += Height * Width
                LDA     PP_A+1
                ADC     #0
                STA     PP_A+1
                DEX
                JMP     loc_1B38
; ---------------------------------------------------------------------------

loc_1B4D:       CLC
                LDA     #.SIZEOF(CreepObj_Image) ; Headersize: Width + Height + Unknown
                ADC     PP_A            ; PP_A += Headersize
                STA     PP_A
                LDA     #0
                ADC     PP_A+1
                STA     PP_A+1
                CLC
                LDA     object_Ptr
                ADC     PP_A
                STA     object_Ptr
                LDA     object_Ptr+1
                ADC     PP_A+1
                STA     object_Ptr+1

obj_Image_Prepare_loop:
                LDY     #0
                LDA     (object_Ptr),Y
                BNE     loc_1B7D
                CLC
                LDA     object_Ptr
                ADC     #1
                STA     object_Ptr
                LDA     object_Ptr+1
                ADC     #0
                STA     object_Ptr+1
                JMP     obj_Image_Draw_return
; ---------------------------------------------------------------------------

loc_1B7D:
                STA     DRAW_Image_Foreground_Left
                INY
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                JSR     DRAW_Image

                CLC
                LDA     object_Ptr
                ADC     #2
                STA     object_Ptr
                LDA     object_Ptr+1
                ADC     #0
                STA     object_Ptr+1
                JMP     obj_Image_Prepare_loop
; ---------------------------------------------------------------------------

obj_Image_Draw_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


.proc GAME_gameHighScoresHandle
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     CASTLE + CreepCastle::playerCount
                CMP     #0
                BEQ     loc_1BB6
                LDA     #<(HIGHSCORES_2_PLAYER + CreepHighscoreEntry::time-1)
                STA     PP_A
                LDA     #>(HIGHSCORES_2_PLAYER + CreepHighscoreEntry::time-1)
                STA     PP_A+1
                JMP     loc_1BBE
; ---------------------------------------------------------------------------

loc_1BB6:
                LDA     #<(HIGHSCORES_1_PLAYER + CreepHighscoreEntry::time-1)
                STA     PP_A
                LDA     #>(HIGHSCORES_1_PLAYER + CreepHighscoreEntry::time-1)
                STA     PP_A+1

loc_1BBE:
                LDA     #10
                STA     _gameHighScoresHandle_HighScorePosition

loc_1BC3:       LDY     #3
loc_1BC5:       LDA     (PP_A),Y
                CMP     gameHighScoresHandle_PlayerName,Y
                BCC     loc_1BD1
                BNE     loc_1BE7
                JMP     loc_1BE4
; ---------------------------------------------------------------------------

loc_1BD1:
                CLC
                LDA     PP_A
                ADC     #.SIZEOF(CreepHighscoreEntry)
                STA     PP_A
                BCC     loc_1BDC
                INC     PP_A+1

loc_1BDC:
                DEC     _gameHighScoresHandle_HighScorePosition
                BNE     loc_1BC3
                JMP     gameHighScoresHandle_return
; ---------------------------------------------------------------------------

loc_1BE4:
                DEY
                BNE     loc_1BC5

loc_1BE7:
                LDA     CASTLE + CreepCastle::playerCount
                CMP     #0
                BEQ     loc_1BF8
                LDY     #.SIZEOF(CreepHighscoreEntry)*19+2-1
                LDA     #104
                STA     KEY_StringInput_TextXPos
                JMP     loc_1BFF
; ---------------------------------------------------------------------------

loc_1BF8:
                LDY     #.SIZEOF(CreepHighscoreEntry)*9+2-1
                LDA     #24
                STA     KEY_StringInput_TextXPos

loc_1BFF:
                SEC
                LDA     #10
                SBC     _gameHighScoresHandle_HighScorePosition
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     #56
                STA     KEY_StringInput_TextYPos
                SEC
                LDA     #10
                SBC     _gameHighScoresHandle_HighScorePosition
                TAX
                LDA     _gameHighScores_color_value_table,X
                STA     KEY_StringInput_TextColor
                SEC
                LDA     PP_A
                SBC     #2
                STA     _gameHighScoresHandle_word_1D03
                LDA     PP_A+1
                SBC     #0
                STA     _gameHighScoresHandle_word_1D03+1

loc_1C2A:
                DEC     _gameHighScoresHandle_HighScorePosition
                BEQ     loc_1C43
                LDA     #6
                STA     _gameHighScoresHandle_byte_1CFF

loc_1C34:
                LDA     HIGHSCORES,Y
                STA     HIGHSCORES_1_PLAYER + CreepHighscoreEntry::time+1,Y
                DEY
                DEC     _gameHighScoresHandle_byte_1CFF
                BNE     loc_1C34
                JMP     loc_1C2A
; ---------------------------------------------------------------------------

loc_1C43:       LDY     #3
loc_1C45:       LDA     gameHighScoresHandle_PlayerName,Y
                STA     (PP_A),Y
                DEY
                BNE     loc_1C45

                LDA     _gameHighScoresHandle_word_1D03
                STA     PP_A
                LDA     _gameHighScoresHandle_word_1D03+1
                STA     PP_A+1
                LDA     #0
                LDY     #0
                STA     (PP_A),Y
                JSR     GAME_gameHighScores

                LDA     #<_gameHighScoresHandle_0x1D05
                STA     object_Ptr
                LDA     #>_gameHighScoresHandle_0x1D05
                STA     object_Ptr+1
                LDX     gameHighScoresHandle_playerIndex
                LDA     _gameHighScoresHandle_ASCII_NUMBER_1_2,X
                STA     _gameHighScoresHandle_PLAYER_ASCII_NUMBER
                JSR     obj_Text_Object_Setup

                LDA     #3
                STA     KEY_StringInput_maxLength
                LDA     #TEXTFONT::s8x8
                STA     KEY_StringInput_TextFont
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1
                JSR     KEY_StringInput
                LDY     #0
                LDA     _gameHighScoresHandle_word_1D03
                STA     PP_A
                LDA     _gameHighScoresHandle_word_1D03+1
                STA     PP_A+1
loc_1C95:       CPY     KEY_StringInput_retLength
                BCC     loc_1C9F
                LDA     #' '
                JMP     loc_1CA2
; ---------------------------------------------------------------------------

loc_1C9F:       LDA     KEY_StringInput_retBuffer,Y
loc_1CA2:       STA     (PP_A),Y
                INY
                CPY     #3
                BCC     loc_1C95

                LDX     optionsMenu_CurrentLevel
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                CLC
                LDA     MULT_40_TABLE_LSB,Y
                ADC     GAME_MENU,X
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ADC     #0
                ORA     #>SCREENRAM
                STA     PP_A+1
                LDA     #$59 ; 'Y'
                STA     DISK_SAVE_FILE_FILENAME+3
                LDY     #14
loc_1CC8:       LDA     (PP_A),Y
                AND     #%01111111
                CMP     #' '
                BCS     loc_1CD2
                ORA     #'@'
loc_1CD2:       STA     DISK_SAVE_FILE_FILENAME+4,Y
                DEY
                BPL     loc_1CC8
                LDA     GAME_MENU + CreepOptionsMenu::XPos+3,X
                STA     DISK_SAVE_FILE_FNAME_LENGTH
                LDA     #FILETYPE::HIGHSCORE
                STA     DISK_SAVE_FILE_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_CHECK
                CMP     #DISK_STATUS::MASTERDISK_DETECTED
                BNE     loc_1CF0
                JSR     DISK_SAVE_FILE

loc_1CF0:       JSR     DISK_DELAY_AFTER_IO

gameHighScoresHandle_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

gameHighScoresHandle_PlayerName:.BYTE $CD, $A5, $AA, $D0
gameHighScoresHandle_playerIndex:.BYTE $B6
_gameHighScoresHandle_HighScorePosition:.BYTE $A0
_gameHighScoresHandle_byte_1CFF:.BYTE $A5
                .BYTE $A0
_gameHighScoresHandle_ASCII_NUMBER_1_2:_CreepPlayerData $B1, $B2
_gameHighScoresHandle_word_1D03:.addr $A0A0
_gameHighScoresHandle_0x1D05:_CreepObj_Text 64, 160, COLOR::LIGHT_BLUE, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "PLAYER "
_gameHighScoresHandle_PLAYER_ASCII_NUMBER:.BYTE $A0
                _CreepObj_Text 20, 184, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "ENTER YOUR INITIAL"
                .BYTE $D3
                _CreepObj_Text 24, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "FOLLOWED B"
                .BYTE $D9
                _CreepObj_Text 120, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE_INVERTED
                scrcode "RETUR"
                .BYTE $CE, 0

; =============== S U B R O U T I N E =======================================

.proc GAME_gameHighScores
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     DRAW_ClearScreen
                LDX     optionsMenu_CurrentLevel
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                CLC
                LDA     MULT_40_TABLE_LSB,Y
                ADC     GAME_MENU,X
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ADC     #0
                ORA     #>SCREENRAM
                STA     PP_A+1
                LDY     GAME_MENU + CreepOptionsMenu::XPos+3,X
                DEY
                DEY
                LDA     (PP_A),Y
                STA     _gameHighScores_OutputBuf,Y

loc_1D6C:
                DEY
                BMI     loc_1D79
                LDA     (PP_A),Y
                AND     #%01111111
                STA     _gameHighScores_OutputBuf,Y
                JMP     loc_1D6C
; ---------------------------------------------------------------------------

loc_1D79:
                LDA     #<_gameHighScores_OutputBuf
                STA     object_Ptr
                LDA     #>_gameHighScores_OutputBuf
                STA     object_Ptr+1

                SEC
                LDA     #21
                SBC     GAME_MENU + CreepOptionsMenu::XPos+3,X
                ASL     A
                ASL     A
                CLC
                ADC     #16
                STA     DRAW_String_TextXPos
                LDA     #16
                STA     DRAW_String_TextYPos
                LDA     #COLOR::WHITE
                STA     DRAW_String_TextColor
                LDA     #TEXTFONT::s8x16
                STA     DRAW_String_TextFont
                JSR     DRAW_String

                LDA     #24
                STA     DRAW_String_TextXPos
                LDX     #0
                LDA     #TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                STA     DRAW_String_TextFont

gameHighScores_loop_nextColumn:
                LDA     #0
                STA     _gameHighScores_LineCounter
                LDA     #56
                STA     DRAW_String_TextYPos

gameHighScores_loop:
                LDY     _gameHighScores_LineCounter
                LDA     _gameHighScores_color_value_table,Y
                STA     DRAW_String_TextColor
                LDA     HIGHSCORES_1_PLAYER + CreepHighscoreEntry::name,X
                CMP     #$FF
                BEQ     loc_1DD6
                STA     _gameHighScores_OutputBuf
                LDA     HIGHSCORES_1_PLAYER + CreepHighscoreEntry::name+1,X
                STA     _gameHighScores_OutputBuf+1
                LDA     HIGHSCORES_1_PLAYER + CreepHighscoreEntry::name+2,X
                JMP     loc_1DDE
; ---------------------------------------------------------------------------

loc_1DD6:
                LDA     #'.'
                STA     _gameHighScores_OutputBuf
                STA     _gameHighScores_OutputBuf+1

loc_1DDE:
                ORA     #%10000000
                STA     _gameHighScores_OutputBuf+2
                LDA     #<_gameHighScores_OutputBuf
                STA     object_Ptr
                LDA     #>_gameHighScores_OutputBuf
                STA     object_Ptr+1
                JSR     DRAW_String

                LDA     HIGHSCORES_1_PLAYER,X
                CMP     #$FF
                BEQ     loc_1E20

                CLC
                TXA
                ADC     #<(HIGHSCORES_1_PLAYER + CreepHighscoreEntry::time-1)
                STA     object_Ptr
                LDA     #>(HIGHSCORES_1_PLAYER + CreepHighscoreEntry::time-1)
                ADC     #0
                STA     object_Ptr+1
                JSR     ConvertTimerToTime

                LDA     DRAW_String_TextXPos
                CLC
                ADC     #32
                STA     DRAW_Image_Foreground_Left
                LDA     DRAW_String_TextYPos
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::time_separators
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

loc_1E20:
                CLC
                LDA     DRAW_String_TextYPos
                ADC     #8
                STA     DRAW_String_TextYPos
                CLC
                TXA
                ADC     #.SIZEOF(CreepHighscoreEntry)
                TAX
                INC     _gameHighScores_LineCounter
                LDA     _gameHighScores_LineCounter
                CMP     #10
                BCS     gameHighScores_nextColumn
                JMP     gameHighScores_loop
; ---------------------------------------------------------------------------

gameHighScores_nextColumn:
                LDA     DRAW_String_TextXPos
                CMP     #24
                BNE     gameHighScores_loop_return
                LDA     #104
                STA     DRAW_String_TextXPos
                JMP     gameHighScores_loop_nextColumn
; ---------------------------------------------------------------------------

gameHighScores_loop_return:
                LDA     #<_gameHighScores_headline
                STA     object_Ptr
                LDA     #>_gameHighScores_headline
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

_gameHighScores_headline:_CreepObj_Text 40, 0, COLOR::YELLOW, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "BEST TIMES FO"
                .BYTE $D2
                _CreepObj_Text 24, 40, COLOR::LIGHT_GREEN, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "1 PLAYER  2 PLAYER"
                .BYTE $D3, 0
.endproc
_gameHighScores_color_value_table:.BYTE COLOR::WHITE   ; 0
                .BYTE COLOR::YELLOW  ; 1
                .BYTE COLOR::YELLOW  ; 2
                .BYTE COLOR::ORANGE  ; 3
                .BYTE COLOR::ORANGE  ; 4
                .BYTE COLOR::ORANGE  ; 5
                .BYTE COLOR::LIGHT_RED; 6
                .BYTE COLOR::LIGHT_RED; 7
                .BYTE COLOR::LIGHT_RED; 8
                .BYTE COLOR::LIGHT_RED; 9

; =============== S U B R O U T I N E =======================================

.proc DISK_CHECK
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #15
                LDX     #8
                LDY     #15
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                LDA     #1
                LDX     #<_DISK_CHECK_FILENAME_I
                LDY     #>_DISK_CHECK_FILENAME_I
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                JSR     kernal::OPEN            ; Open file. (Must call SETLFS and SETNAM beforehands.)
                LDA     #15
                JSR     kernal::CLOSE           ; Close file. Input: A = Logical number.
                LDA     #2
                LDX     #8
                LDY     #0
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                LDA     #1
                LDX     #<_DISK_CHECK_FILENAME_DIR
                LDY     #>_DISK_CHECK_FILENAME_DIR
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                JSR     kernal::OPEN            ; Open file. (Must call SETLFS and SETNAM beforehands.)
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::NO_ERROR
                BNE     loc_1F01
                LDX     #2
                JSR     kernal::CHKIN           ; Define file as default input. (Must call OPEN beforehands.) Input: X = Logical number.
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::NO_ERROR
                BNE     loc_1F01
                LDY     #8

loc_1ED8:
                JSR     kernal::CHRIN           ; Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
                DEY
                BNE     loc_1ED8
                LDY     #0

loc_1EE0:
                JSR     kernal::CHRIN           ; Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
                EOR     _DISK_CHECK_STR_DUNGEONMASTER,Y
                AND     #$7F
                BNE     loc_1EF5
                LDA     _DISK_CHECK_STR_DUNGEONMASTER,Y
                AND     #$80
                BNE     loc_1F06
                INY
                JMP     loc_1EE0
; ---------------------------------------------------------------------------

loc_1EF5:
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::NO_ERROR
                BNE     loc_1F01
                LDA     #DISK_STATUS::OK
                JMP     loc_1F08
; ---------------------------------------------------------------------------

loc_1F01:       LDA     #DISK_STATUS::ERROR
                JMP     loc_1F08
; ---------------------------------------------------------------------------

loc_1F06:       LDA     #DISK_STATUS::MASTERDISK_DETECTED
loc_1F08:       STA     _DISK_CHECK_DISK_DETECTED
                LDA     #2
                JSR     kernal::CLOSE           ; Close file. Input: A = Logical number.
                PLA
                TAX
                PLA
                TAY
                PLA
                LDA     _DISK_CHECK_DISK_DETECTED
                RTS

_DISK_CHECK_FILENAME_DIR:scrcode "$"
_DISK_CHECK_STR_DUNGEONMASTER:scrcode "DUNGEONMASTE"
                            .byte $D2
_DISK_CHECK_DISK_DETECTED:.BYTE $A0
_DISK_CHECK_FILENAME_I:scrcode "I"
.endproc

; =============== S U B R O U T I N E =======================================

.proc SND_CIA1_TIMER_A_IRQ_musicBufferFeed
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     SND_TimerCounter
                BNE     loc_1F3B
                LDA     SND_TimerCounter+1
                BEQ     _SND_NEXT_CMD
                DEC     SND_TimerCounter+1

loc_1F3B:       DEC     SND_TimerCounter
                LDA     SND_TimerCounter
                ORA     SND_TimerCounter+1
                BEQ     _SND_NEXT_CMD
                JMP     CIA1_TIMER_A_IRQ_musicBufferFeed_return
; ---------------------------------------------------------------------------

_SND_NEXT_CMD:
                LDY     #0
                LDA     (SND_PTR),Y
                LSR     A
                LSR     A
                TAX
                LDA     SND_COMMAND_SIZE_TABLE,X
                TAX
                TAY

_SND_COPY_NEXT_CMD:
                DEY
                BMI     _SND_COPY_ADVANCE
                LDA     (SND_PTR),Y
                STA     SND_COMMAND_BUF,Y
                JMP     _SND_COPY_NEXT_CMD
; ---------------------------------------------------------------------------

_SND_COPY_ADVANCE:
                CLC
                TXA
                ADC     SND_PTR
                STA     SND_PTR
                BCC     loc_1F6A
                INC     SND_PTR+1

loc_1F6A:       LDA     SND_COMMAND_BUF
                LSR     A
                LSR     A
                CMP     #SOUND_CMD::PLAY_NOTE
                BNE     loc_1FA2
                JSR     SND_selectVoice
                LDA     SND_COMMAND_BUF
                AND     #%11
                TAX
                LDA     SND_COMMAND_BUF+1
                CLC
                ADC     SND_NOTE_TRANSPOSE_VALUE,X
                TAX

                LDY     #0              ; Select the frequency for a voice
                LDA     SND_FREQ_TABLE_LOW,X
                STA     (SND_VoiceBaseRegAddr),Y
                STA     (SND_VoiceBaseRegMirrorAddr),Y
                INY
                LDA     SND_FREQ_TABLE_HIGH,X
                STA     (SND_VoiceBaseRegAddr),Y
                STA     (SND_VoiceBaseRegMirrorAddr),Y

                LDY     #4
                LDA     (SND_VoiceBaseRegMirrorAddr),Y
                ORA     #1              ; Set gate (enable ADSR for the voice)
                STA     (SND_VoiceBaseRegAddr),Y
                STA     (SND_VoiceBaseRegMirrorAddr),Y
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_1FA2:       CMP     #SOUND_CMD::START_PLAY
                BNE     loc_1FB6
                JSR     SND_selectVoice
                LDY     #4
                LDA     (SND_VoiceBaseRegMirrorAddr),Y
                AND     #(~1 & $FF)             ; Clear gate (disable ADSR for the voice)
                STA     (SND_VoiceBaseRegMirrorAddr),Y
                STA     (SND_VoiceBaseRegAddr),Y
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_1FB6:       CMP     #SOUND_CMD::SET_DURATION_MSB
                BNE     loc_1FC3
                LDA     SND_COMMAND_BUF+1
                STA     SND_TimerCounter
                JMP     CIA1_TIMER_A_IRQ_musicBufferFeed_return
; ---------------------------------------------------------------------------

loc_1FC3:       CMP     #SOUND_CMD::SET_DURATION_LSB
                BNE     loc_1FD0
                LDA     SND_COMMAND_BUF+1
                STA     SND_TimerCounter+1
                JMP     CIA1_TIMER_A_IRQ_musicBufferFeed_return
; ---------------------------------------------------------------------------

loc_1FD0:       CMP     #SOUND_CMD::SET_ADSR_etc
                BNE     loc_1FFA
                JSR     SND_selectVoice
                LDY     #2
loc_1FD9:       CPY     #4              ; CR1 register?
                BEQ     loc_1FE7        ; => yes
                LDA     SND_COMMAND_BUF-1,Y
                STA     (SND_VoiceBaseRegAddr),Y
                STA     (SND_VoiceBaseRegMirrorAddr),Y
                JMP     loc_1FF2
; ---------------------------------------------------------------------------

loc_1FE7:       LDA     (SND_VoiceBaseRegMirrorAddr),Y
                AND     #1              ; Read the current gate value
                ORA     SND_COMMAND_BUF-1,Y
                STA     (SND_VoiceBaseRegAddr),Y
                STA     (SND_VoiceBaseRegMirrorAddr),Y
loc_1FF2:       INY
                CPY     #7
                BCC     loc_1FD9        ; CR1 register?
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_1FFA:       CMP     #SOUND_CMD::FILTER_AND_VOLUME
                BNE     loc_2033
                LDA     SND_COMMAND_BUF+1
                STA     SID::FCLO        ; Filter Cutoff Low (FC2-FC0)
                STA     SND_MIRROR_FILTER_CUTOFF
                LDA     SND_COMMAND_BUF+2
                STA     SID::FCHI        ; Filter Cutoff High (FC10-FC3)
                STA     SND_MIRROR_FILTER_CUTOFF+1
                LDA     SND_COMMAND_BUF
                AND     #%11
                TAX
                LDA     BITMASK_01__80,X
                ORA     SND_COMMAND_BUF+3
                STA     SID::Res_Filt    ; Filter Resonance, Filt Ex, Filt 3, Filt 2, Filt 1
                STA     SND_MIRROR_FILTER_RES_ROUTING
                LDA     SND_MIRROR_Mode_Volume
                AND     #%1111
                ORA     SND_COMMAND_BUF+4
                STA     SND_MIRROR_Mode_Volume
                STA     SID::SIGVOL    ; Chan 3 Off, High Pass, Band Pass, Low Pass, Volume
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_2033:       CMP     #SOUND_CMD::SET_TRANSPOSE
                BNE     loc_2046
                LDA     SND_COMMAND_BUF
                AND     #%11
                TAX
                LDA     SND_COMMAND_BUF+1
                STA     SND_NOTE_TRANSPOSE_VALUE,X
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_2046:       CMP     #SOUND_CMD::SET_FILTER
                BNE     loc_205B
                LDA     SND_MIRROR_Mode_Volume
                AND     #%11110000
                ORA     SND_COMMAND_BUF+1
                STA     SND_MIRROR_Mode_Volume
                STA     SID::SIGVOL    ; Chan 3 Off, High Pass, Band Pass, Low Pass, Volume
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_205B:       CMP     #SOUND_CMD::SET_TIMER
                BNE     loc_206F
                LDA     SND_COMMAND_BUF+1
                STA     SND_Timer_A_MSB
                ASL     A
                ASL     A
                ORA     #3
                STA     CIA1::T1H       ; Timer A High Byte
                JMP     _SND_NEXT_CMD
; ---------------------------------------------------------------------------

loc_206F:
                LDA     Intro_IsInIntroFlag
                CMP     #1
                BEQ     _in_intro       ; The intro plays continously, so we just restart
                LDA     #$FF
                STA     SND_PlayingSound ; No sound is playing
                LDA     #0
                STA     CIA1::CRA       ; Control Timer A
                LDA     #%01111111
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     CIA1::ICR       ; Interrupt Control and status
                JMP     CIA1_TIMER_A_IRQ_musicBufferFeed_return
; ---------------------------------------------------------------------------

_in_intro:
                LDA     #<(CASTLE + CreepCastle::flags)  ; The intro plays continously, so we just restart
                STA     SND_PTR
                LDA     #>(CASTLE + CreepCastle::flags)
                STA     SND_PTR+1
                LDA     #2
                STA     SND_TimerCounter+1
                LDA     SND_MIRROR_FILTER_RES_ROUTING
                AND     #%11110000
                STA     SID::Res_Filt    ; Filter Resonance, Filt Ex, Filt 3, Filt 2, Filt 1
                STA     SND_MIRROR_FILTER_RES_ROUTING

CIA1_TIMER_A_IRQ_musicBufferFeed_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

.proc SND_selectVoice
                PHA
                TXA
                PHA
                LDA     SND_COMMAND_BUF ; Low 2 bits of the command contain the voice #
                AND     #%11
                ASL     A
                TAX
                LDA     SND_regAddr,X
                STA     SND_VoiceBaseRegAddr
                LDA     SND_regAddr+1,X
                STA     SND_VoiceBaseRegAddr+1
                LDA     SND_regMirrorAddr,X
                STA     SND_VoiceBaseRegMirrorAddr
                LDA     SND_regMirrorAddr+1,X
                STA     SND_VoiceBaseRegMirrorAddr+1
                PLA
                TAX
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
SND_COMMAND_BUF:.BYTE $99,$A0,$C1,$C6,$CE,$A2,$AA
SND_COMMAND_SIZE_TABLE:.BYTE   2,  1,  2,  2,  6,  5,  2,  2,  2,  1
SND_TimerCounter:.WORD 0
SND_MusicPlaying:.BYTE 0
SND_regAddr:    .addr SID::FRELO1,SID::FRELO2,SID::FRELO3
SND_regMirrorAddr:.addr SND_SID_REG_MIRROR_1,SND_SID_REG_MIRROR_2,SND_SID_REG_MIRROR_3
SND_SID_REG_MIRROR_1:.BYTE $A0,$A9,$B5,$A0,$E5,$A0,$86
SND_SID_REG_MIRROR_2:.BYTE $A0,$80,$BA,$CE,$8D,$A0,$82
SND_SID_REG_MIRROR_3:.BYTE $A0,$B8,$BC,$A0,$B0,$A0,$CC
SND_MIRROR_FILTER_CUTOFF:.WORD $B0A0
SND_MIRROR_FILTER_RES_ROUTING:.BYTE $84
SND_MIRROR_Mode_Volume:.BYTE 15
SND_NOTE_TRANSPOSE_VALUE:.BYTE 12, 12, 12
SND_Timer_A_MSB:.BYTE 20

; SID frequencies as listed in the C64 manual. 96 notes from C0 to B7
SND_FREQ_TABLE_LOW:.BYTE $0C,$1C,$2D,$3E,$51,$66,$7B,$91; 0
                .BYTE $A9,$C3,$DD,$FA,$18,$38,$5A,$7D; 8
                .BYTE $A3,$CC,$F6,$23,$53,$86,$BB,$F4; 16
                .BYTE $30,$70,$B4,$FB,$47,$98,$ED,$47; 24
                .BYTE $A7,$0C,$77,$E9,$61,$E1,$68,$F7; 32
                .BYTE $8F,$30,$DA,$8F,$4E,$18,$EF,$D2; 40
                .BYTE $C3,$C3,$D1,$EF,$1F,$60,$B5,$1E; 48
                .BYTE $9C,$31,$DF,$A5,$87,$86,$A2,$DF; 56
                .BYTE $3E,$C1,$6B,$3C,$39,$63,$BE,$4B; 64
                .BYTE $0F,$0C,$45,$BF,$7D,$83,$D6,$79; 72
                .BYTE $73,$C7,$7C,$97,$1E,$18,$8B,$7E; 80
                .BYTE $FA,$06,$AC,$F3,$E6,$8F,$F8,$2E; 88
SND_FREQ_TABLE_HIGH:.BYTE $01,$01,$01,$01,$01,$01,$01,$01; 0
                .BYTE $01,$01,$01,$01,$02,$02,$02,$02; 8
                .BYTE $02,$02,$02,$03,$03,$03,$03,$03; 16
                .BYTE $04,$04,$04,$04,$05,$05,$05,$06; 24
                .BYTE $06,$07,$07,$07,$08,$08,$09,$09; 32
                .BYTE $0A,$0B,$0B,$0C,$0D,$0E,$0E,$0F; 40
                .BYTE $10,$11,$12,$13,$15,$16,$17,$19; 48
                .BYTE $1A,$1C,$1D,$1F,$21,$23,$25,$27; 56
                .BYTE $2A,$2C,$2F,$32,$35,$38,$3B,$3F; 64
                .BYTE $43,$47,$4B,$4F,$54,$59,$5E,$64; 72
                .BYTE $6A,$70,$77,$7E,$86,$8E,$96,$9F; 80
                .BYTE $A8,$B3,$BD,$C8,$D4,$E1,$EE,$FD; 88

; =============== S U B R O U T I N E =======================================

.proc SND_PlayEffect
                PHA
                STA     SND_pA
                TYA
                PHA
                LDA     Intro_IsInIntroFlag
                CMP     #1              ; No effects in the intro
                BEQ     SND_PlayEffect_return
                LDA     SND_DisableSoundEffects ; Always 0, maybe 1 in the tape version?
                CMP     #1              ; No effects, if globally turned off
                BEQ     SND_PlayEffect_return
                LDA     SND_PlayingSound ; Already playing something?
                BPL     SND_PlayEffect_return ; => yes!

                LDA     SND_pA
                STA     SND_PlayingSound
                ASL     A
                TAY
                LDA     SNDEFFECT_TABLE,Y
                STA     SND_PTR
                LDA     SNDEFFECT_TABLE+1,Y
                STA     SND_PTR+1
                LDA     #0
                STA     SID::VCREG1         ; NOISE   PULSE   SAW TRI TEST    RING    SYNC    GATE
                STA     SID::VCREG2         ; NOISE   PULSE   SAW TRI TEST    RING    SYNC    GATE
                STA     SID::VCREG3         ; NOISE   PULSE   SAW TRI TEST    RING    SYNC    GATE
                STA     SID::Res_Filt       ; Filter Resonance, Filt Ex, Filt 3, Filt 2, Filt 1
                STA     SND_TimerCounter
                STA     SND_TimerCounter+1
                LDA     #15
                STA     SID::SIGVOL    ; Chan 3 Off, High Pass, Band Pass, Low Pass, Volume
                LDA     #SID_NOTE::C2
                STA     SND_NOTE_TRANSPOSE_VALUE
                STA     SND_NOTE_TRANSPOSE_VALUE+1
                STA     SND_NOTE_TRANSPOSE_VALUE+2
                LDA     #20
                STA     SND_Timer_A_MSB
                ASL     A
                ASL     A
                ORA     #3
                STA     CIA1::T1H       ; Timer A High Byte
                LDA     #$81
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     #1
                STA     CIA1::CRA       ; Control Timer A

SND_PlayEffect_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
SND_pA:         .BYTE $A0
SND_PlayingSound:.BYTE $FF

; =============== S U B R O U T I N E =======================================


.proc GAME_optionsMenu
                PHA
                TYA
                PHA
                TXA
                PHA

_optionsMenu_loop:
                LDA     #VIC_CR1_FLAGS::YSCROLL_3|VIC_CR1_FLAGS::RSEL
                STA     VIC::CR1         ; Control register 1
                LDA     #%11            ; $0000 = VIC base address
                STA     CIA2::DDRA      ; Data direction Port A
                STA     CIA2::PRA       ; Select the position of the VIC-memory
                LDA     #0
                STA     IRQ_VIC_ME      ; Sprite enabled
                LDA     #%00010100      ; $0400 => $0400 = TEXT video address, $2000 => $2000 = FONT address
                STA     IRQ_VIC_VM_CB   ; Memory pointers
                LDA     #<COLORRAM
                STA     PP_A
                LDA     #>COLORRAM
                STA     PP_A+1
                LDY     #0

_optionsMenu_clrScr:
                LDA     #COLOR::WHITE

_optionsMenu_clrScr2:
                STA     (PP_A),Y
                INY
                BNE     _optionsMenu_clrScr2
                INC     PP_A+1
                LDA     PP_A+1
                CMP     #>CIA1::PRA      ; Monitoring/control of the 8 data lines of Port A.
                BCC     _optionsMenu_clrScr
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1

_optionsMenu_wait4Input:
                LDA     #0
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Button
                BNE     _optionsMenu_joyButtonPressed
                LDA     KEY_GetJoystick_Input
                AND     #(~JOYSTICK_DIRECTION::DOWN & $FF)
                BNE     _optionsMenu_wait4Input

                LDX     optionsMenu_CurrentSelection
                CLC
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     MULT_40_TABLE_LSB,Y
                ADC     #<SCREENRAM
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ADC     #>SCREENRAM
                STA     PP_A+1
                LDY     GAME_MENU,X
                DEY
                DEY
                LDA     #' '
                STA     (PP_A),Y
                LDA     KEY_GetJoystick_Input
                BEQ     loc_22B5
                LDA     optionsMenu_CurrentSelection
                CMP     optionsMenu_Marker
                BNE     loc_22AF
                LDA     #0
                JMP     loc_22C3
; ---------------------------------------------------------------------------

loc_22AF:
                CLC
                ADC     #4
                JMP     loc_22C3
; ---------------------------------------------------------------------------

loc_22B5:
                LDA     optionsMenu_CurrentSelection
                BNE     loc_22C0
                LDA     optionsMenu_Marker
                JMP     loc_22C3
; ---------------------------------------------------------------------------

loc_22C0:
                SEC
                SBC     #4

loc_22C3:
                STA     optionsMenu_CurrentSelection
                TAX
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                CLC
                LDA     MULT_40_TABLE_LSB,Y
                ADC     #<SCREENRAM
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ADC     #>SCREENRAM
                STA     PP_A+1
                LDY     GAME_MENU,X
                DEY
                DEY
                LDA     #'>'
                STA     (PP_A),Y
                JMP     loc_2320
; ---------------------------------------------------------------------------

_optionsMenu_joyButtonPressed:
                LDX     optionsMenu_CurrentSelection
                LDA     GAME_MENU + CreepOptionsMenu::action,X
                BNE     loc_2326
                LDA     optionsMenu_UnlimitedLives
                EOR     #%11111111
                STA     optionsMenu_UnlimitedLives
                CLC
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     MULT_40_TABLE_LSB,Y
                ADC     #<SCREENRAM
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ADC     #>SCREENRAM
                STA     PP_A+1
                LDA     GAME_MENU,X
                CLC
                ADC     #17
                TAY
                LDX     #0

loc_2310:
                CPX     #2
                BEQ     loc_231A
                LDA     (PP_A),Y
                EOR     #%10000000
                STA     (PP_A),Y

loc_231A:
                INX
                INY
                CPX     #6
                BCC     loc_2310

loc_2320:
                JSR     GAME_optionsMenuWaitForButtonOrKeyReleased
                JMP     _optionsMenu_wait4Input
; ---------------------------------------------------------------------------

loc_2326:
                CMP     #OPTION_ACTION::LOAD_CASTLE
                BNE     loc_2333
                LDX     optionsMenu_CurrentSelection
                JSR     GAME_ChangeLevel

_optionsMenu_loop_:
                JMP     _optionsMenu_loop
; ---------------------------------------------------------------------------

loc_2333:
                CMP     #OPTION_ACTION::SELECT
                BNE     loc_2341
                JSR     GAME_gamePositionLoad
                LDA     gamePositionLoad_SaveGameLoaded
                CMP     #1
                BNE     _optionsMenu_loop_

loc_2341:
                CMP     #OPTION_ACTION::RESUME_GAME
                BNE     _optionsMenu_return
                LDA     optionsMenu_CurrentLevel
                CMP     #$FF
                BEQ     _optionsMenu_loop_
                JSR     DRAW_DisableSpritesAndStopSound
                JSR     GAME_gameHighScores
                LDA     #<_optionsMenu_PRESS_ENTER_TO_EXIT
                STA     object_Ptr
                LDA     #>_optionsMenu_PRESS_ENTER_TO_EXIT
                STA     object_Ptr+1
                JSR     obj_Text_Object_Setup

                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1
                LDA     #0
                STA     KEY_StringInput_maxLength
                JSR     KEY_StringInput
                JMP     _optionsMenu_loop
; ---------------------------------------------------------------------------

_optionsMenu_return:
                JSR     GAME_optionsMenuWaitForButtonOrKeyReleased
                JSR     DRAW_DisableSpritesAndStopSound
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

.proc GAME_optionsMenuWaitForButtonOrKeyReleased
                PHA

loc_237D:       LDA     #2
                STA     IRQ_DELAY_COUNTER
loc_2382:       LDA     IRQ_DELAY_COUNTER ; Wait for 2/60s
                BNE     loc_2382        ; Wait for 2/60s
                LDA     #0
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Input
                BPL     loc_237D
                LDA     KEY_GetJoystick_Button
                BNE     loc_237D
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
optionsMenu_CurrentSelection:.BYTE $A0
optionsMenu_CurrentLevel:.BYTE $FF
optionsMenu_Marker:.BYTE $A0
optionsMenu_UnlimitedLives:.BYTE 0
_optionsMenu_PRESS_ENTER_TO_EXIT:_CreepObj_Text 16, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "PRES"
                .BYTE $D3
                _CreepObj_Text 120, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "TO EXI"
                .BYTE $D4
                _CreepObj_Text 64, 192, COLOR::GREY, TEXTFONT::s8x8|TEXTFONT::UPPERCASE_INVERTED
                scrcode "RETUR"
                .BYTE $CE, 0

; =============== S U B R O U T I N E =======================================

.proc GAME_ChangeLevel
                PHA
                TYA
                PHA
                CPX     optionsMenu_CurrentLevel
                BNE     loc_23C6
                JMP     ChangeLevel_return
; ---------------------------------------------------------------------------

loc_23C6:
                LDA     #$5A ; Z'
                STA     DISK_LOAD_FNAME
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     MULT_40_TABLE_LSB,Y
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ORA     #>SCREENRAM
                STA     PP_A+1
                CLC
                LDA     PP_A
                ADC     GAME_MENU,X
                STA     PP_A
                BCC     loc_23E6
                INC     PP_A+1

loc_23E6:
                LDY     #0
loc_23E8:       LDA     (PP_A),Y
                CMP     #' '
                BCS     loc_23F0
                ORA     #'@'
loc_23F0:       STA     DISK_LOAD_FNAME+1,Y
                INY
                CPY     #15
                BCC     loc_23E8
                LDY     GAME_MENU + CreepOptionsMenu::XPos+3,X
                STY     DISK_LOAD_FNAME_LENGTH
                LDA     #FILETYPE::SAVEGAME
                STA     DISK_LOAD_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_CHECK
                CMP     #DISK_STATUS::MASTERDISK_DETECTED
                BNE     loc_2417
                JSR     DISK_LOAD_FILE
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::END_OF_FILE
                BEQ     loc_241D

loc_2417:
                JSR     DISK_DELAY_AFTER_IO
                JMP     ChangeLevel_return
; ---------------------------------------------------------------------------

loc_241D:
                LDA     #$59 ; 'Y'
                STA     DISK_LOAD_FNAME
                LDA     #FILETYPE::HIGHSCORE
                STA     DISK_LOAD_FILETYPE
                JSR     DISK_LOAD_FILE
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::END_OF_FILE
                BEQ     loc_2445

; Erase all highscores
                LDA     #122
                STA     HIGHSCORES
                LDA     #0
                STA     HIGHSCORES+1
                LDY     #120-1
                LDA     #$FF
loc_243F:       STA     HIGHSCORES_1_PLAYER,Y
                DEY
                BPL     loc_243F

loc_2445:
                JSR     DISK_DELAY_AFTER_IO
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     MULT_40_TABLE_LSB,Y
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,Y
                ORA     #>SCREENRAM
                STA     PP_A+1
                CLC
                LDA     GAME_MENU,X
                ADC     PP_A
                STA     PP_A
                BCC     loc_2463
                INC     PP_A+1

loc_2463:
                STX     _ChangeLevel_byte_24A6
                LDX     optionsMenu_CurrentLevel
                LDY     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     MULT_40_TABLE_LSB,Y
                STA     PP_B
                LDA     MULT_40_TABLE_MSB,Y
                ORA     #>SCREENRAM
                STA     PP_B+1
                CLC
                LDA     PP_B
                ADC     GAME_MENU,X
                STA     PP_B
                BCC     loc_2484
                INC     PP_B+1

loc_2484:
                LDY     #15
                LDX     _ChangeLevel_byte_24A6

loc_2489:
                LDA     optionsMenu_CurrentLevel
                CMP     #$FF
                BEQ     loc_2496
                LDA     (PP_B),Y
                AND     #$7F
                STA     (PP_B),Y

loc_2496:
                LDA     (PP_A),Y
                ORA     #$80
                STA     (PP_A),Y
                DEY
                BPL     loc_2489
                STX     optionsMenu_CurrentLevel

ChangeLevel_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_ChangeLevel_byte_24A6:.BYTE $86
.endproc

; =============== S U B R O U T I N E =======================================


.proc GAME_gamePositionLoad
                PHA
                TXA
                PHA
                JSR     DRAW_DisableSpritesAndStopSound
                LDA     #FILENAME_MODE::RESUME
                STA     gameFilenameGet_SaveOrResumeFlag
                JSR     GAME_gameFilenameGet
                LDX     KEY_StringInput_retLength
                BEQ     loc_24F9

loc_24BA:
                DEX
                BMI     loc_24C6
                LDA     KEY_StringInput_retBuffer,X
                STA     DISK_LOAD_FNAME,X
                JMP     loc_24BA
; ---------------------------------------------------------------------------

loc_24C6:
                LDA     KEY_StringInput_retLength
                STA     DISK_LOAD_FNAME_LENGTH
                LDA     #FILETYPE::CASTLE
                STA     DISK_LOAD_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_CHECK
                CMP     #DISK_STATUS::OK
                BEQ     loc_24E1
                JSR     DISK_DELAY_AFTER_IO
                JMP     loc_24F9
; ---------------------------------------------------------------------------

loc_24E1:
                JSR     DISK_LOAD_FILE
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                STA     _gamePositionLoad_status
                JSR     DISK_DELAY_AFTER_IO
                LDA     _gamePositionLoad_status
                CMP     #READST_ERRORS::END_OF_FILE
                BNE     loc_24F9
                LDA     #1
                STA     gamePositionLoad_SaveGameLoaded

loc_24F9:       PLA
                TAX
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
gamePositionLoad_SaveGameLoaded:.BYTE 0
_gamePositionLoad_status:.BYTE $90

; =============== S U B R O U T I N E =======================================


.proc GAME_gamePositionSave
                PHA
                TXA
                PHA
                LDA     #FILENAME_MODE::SAVE
                STA     gameFilenameGet_SaveOrResumeFlag
                JSR     GAME_gameFilenameGet
                LDX     KEY_StringInput_retLength
                BEQ     loc_256B

loc_250F:
                DEX
                BMI     loc_251B
                LDA     KEY_StringInput_retBuffer,X
                STA     DISK_SAVE_FILE_FILENAME+3,X
                JMP     loc_250F
; ---------------------------------------------------------------------------

loc_251B:
                LDA     KEY_StringInput_retLength
                STA     DISK_SAVE_FILE_FNAME_LENGTH
                LDA     #FILETYPE::CASTLE
                STA     DISK_SAVE_FILE_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_CHECK
                CMP     #DISK_STATUS::OK
                BNE     loc_2540
                JSR     DISK_SAVE_FILE
                JSR     kernal::READST          ; Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
                CMP     #READST_ERRORS::NO_ERROR
                BNE     loc_2540
                JSR     DISK_DELAY_AFTER_IO
                JMP     loc_256B
; ---------------------------------------------------------------------------

loc_2540:       JSR     DISK_DELAY_AFTER_IO
                CMP     #0
                BEQ     loc_2550
                LDA     #<_gamePositionSave_IO_ERROR_TXT
                STA     object_Ptr
                LDA     #>_gamePositionSave_IO_ERROR_TXT
                JMP     loc_2556
; ---------------------------------------------------------------------------

loc_2550:       LDA     #<_gamePositionSave_CANNOT_SAVE_TO_MASTER_TXT
                STA     object_Ptr
                LDA     #>_gamePositionSave_CANNOT_SAVE_TO_MASTER_TXT

loc_2556:       STA     object_Ptr+1
                JSR     DRAW_ClearScreen
                JSR     obj_Text_Object_Setup
                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1
                LDA     #35
                JSR     GAME_WAIT_DELAY_100ms

loc_256B:       PLA
                TAX
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_gamePositionSave_CANNOT_SAVE_TO_MASTER_TXT:_CreepObj_Text 16, 64, COLOR::LIGHT_RED, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "YOU CANNOT SAVE YOU"
                .BYTE $D2
                _CreepObj_Text 36, 88, COLOR::LIGHT_RED, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "POSITION TO TH"
                .BYTE $C5
                _CreepObj_Text 52, 112, COLOR::LIGHT_RED, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "MASTER DIS"
                .BYTE $CB, 0
_gamePositionSave_IO_ERROR_TXT:_CreepObj_Text 60, 80, COLOR::LIGHT_RED, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "I/O ERRO"
                .BYTE $D2, 0

; =============== S U B R O U T I N E =======================================

.proc GAME_gameFilenameGet
                PHA
                JSR     DRAW_ClearScreen
                LDA     #<_gameFilenameGet_0x2633
                STA     object_Ptr
                LDA     #>_gameFilenameGet_0x2633
                STA     object_Ptr+1
                JSR     DRAW_Objects    ; Draw all objects in the current room initially

                LDA     gameFilenameGet_SaveOrResumeFlag
                BEQ     loc_25D7
                LDA     #<_gameFilenameGet_0x261F
                STA     object_Ptr
                LDA     #>_gameFilenameGet_0x261F
                STA     object_Ptr+1
                JMP     loc_25DF
; ---------------------------------------------------------------------------

loc_25D7:
                LDA     #<_gameFilenameGet_0x2609
                STA     object_Ptr
                LDA     #>_gameFilenameGet_0x2609
                STA     object_Ptr+1

loc_25DF:       JSR     DRAW_Objects    ; Draw all objects in the current room initially

                LDA     VIC::CR1         ; Control register 1
                ORA     #VIC_CR1_FLAGS::DEN ; Video enable
                STA     VIC::CR1         ; Control register 1
                LDA     #32
                STA     KEY_StringInput_TextXPos
                LDA     #72
                STA     KEY_StringInput_TextYPos
                LDA     #16
                STA     KEY_StringInput_maxLength
                LDA     #COLOR::WHITE
                STA     KEY_StringInput_TextColor
                LDA     #TEXTFONT::s8x16
                STA     KEY_StringInput_TextFont
                JSR     KEY_StringInput
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
gameFilenameGet_SaveOrResumeFlag:.BYTE $A0

_gameFilenameGet_0x2609:.addr obj_Text_Object_Setup
                _CreepObj_Text 44, 0, COLOR::WHITE, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "SAVE POSITIO"
                .BYTE $CE
                .addr 0
                .BYTE 0
_gameFilenameGet_0x261F:.addr obj_Text_Object_Setup
                _CreepObj_Text 52, 0, COLOR::WHITE, TEXTFONT::s8x16|TEXTFONT::UPPERCASE
                scrcode "RESUME GAM"
                .BYTE $C5
                .addr 0
                .BYTE 0
_gameFilenameGet_0x2633:.addr obj_Text_Object_Setup
                _CreepObj_Text 28, 48, COLOR::LIGHT_GREEN, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "TYPE IN FILE NAM"
                .BYTE $C5
                _CreepObj_Text 24, 56, COLOR::LIGHT_GREEN, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "FOLLOWED B"
                .BYTE $D9
                _CreepObj_Text 120, 56, COLOR::LIGHT_GREEN, TEXTFONT::s8x8|TEXTFONT::UPPERCASE_INVERTED
                scrcode "RETUR"
                .BYTE $CE
                _CreepObj_Text 32, 120, COLOR::LIGHT_RED, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "PRESS         T"
                .BYTE $CF
                _CreepObj_Text 80, 120, COLOR::LIGHT_RED, TEXTFONT::s8x8|TEXTFONT::UPPERCASE_INVERTED
                scrcode "RESTOR"
                .BYTE $C5
                _CreepObj_Text 72, 128, COLOR::LIGHT_RED, TEXTFONT::s8x8|TEXTFONT::UPPERCASE
                scrcode "CANCE"
                .BYTE $CC
                .addr 0
                .BYTE 0

; =============== S U B R O U T I N E =======================================

.proc KEY_StringInput
                PHA
                TXA
                PHA
                LDA     #0
                STA     KEY_RestorePressed
                LDA     KEY_StringInput_TextColor
                STA     DRAW_String_TextColor
                LDA     KEY_StringInput_TextFont
                ORA     #TEXTFONT::ILLEGAL|TEXTFONT::UPPERCASE
                STA     DRAW_String_TextFont
                LDA     KEY_StringInput_TextXPos
                STA     DRAW_String_TextXPos
                LDA     KEY_StringInput_TextYPos
                STA     DRAW_String_TextYPos
                LDA     #'-'
                STA     KEY_StringInput_StringBuf
                LDX     KEY_StringInput_maxLength

loc_26B9:       CPX     #0
                BEQ     loc_26CD
                JSR     KEY_StringInput_PrintChar
                DEX
                CLC
                LDA     DRAW_String_TextXPos
                ADC     #8
                STA     DRAW_String_TextXPos
                JMP     loc_26B9
; ---------------------------------------------------------------------------

loc_26CD:       STX     KEY_StringInput_retLength

_inputLoop:     LDA     KEY_StringInput_retLength
                CMP     KEY_StringInput_maxLength
                BEQ     loc_26F7

                INC     KEY_StringInput_RotatingCursorIndex
                LDA     KEY_StringInput_RotatingCursorIndex
                AND     #3
                TAX
                LDA     KEY_StringInput_RotatingCursorChars,X ; Bottom right box, Bottom left box, Top left box, Top right box
                STA     KEY_StringInput_StringBuf

                LDA     KEY_StringInput_retLength
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     KEY_StringInput_TextXPos
                STA     DRAW_String_TextXPos
                JSR     KEY_StringInput_PrintChar

loc_26F7:       JSR     KEY_GetKey
                CMP     #KEYBOARD_INPUT::NOTHING
                BNE     loc_2730
                LDA     KEY_RestorePressed
                CMP     #1
                BEQ     loc_2712
                LDA     #3
                STA     IRQ_DELAY_COUNTER

loc_270A:       LDA     IRQ_DELAY_COUNTER ; Wait for 3/60s
                BNE     loc_270A        ; Wait for 3/60s
                JMP     _inputLoop
; ---------------------------------------------------------------------------

loc_2712:       LDA     #0
                STA     KEY_StringInput_retLength

loc_2717:       LDA     #0
                STA     KEY_RestorePressed
                LDA     #3
                STA     IRQ_DELAY_COUNTER
loc_2721:       LDA     IRQ_DELAY_COUNTER ; Wait for 3/60s
                BNE     loc_2721
                LDA     KEY_RestorePressed
                CMP     #0
                BNE     loc_2717
                JMP     loc_276E
; ---------------------------------------------------------------------------

loc_2730:       CMP     #KEYBOARD_INPUT::BACKSPACE ; Backspace?
                BNE     loc_274F
                LDA     KEY_StringInput_retLength
                CMP     KEY_StringInput_maxLength
                BEQ     loc_2744
                LDA     #'-'
                STA     KEY_StringInput_StringBuf
                JSR     KEY_StringInput_PrintChar

loc_2744:       LDA     KEY_StringInput_retLength
                BEQ     loc_274C
                DEC     KEY_StringInput_retLength

loc_274C:       JMP     _inputLoop
; ---------------------------------------------------------------------------

loc_274F:       CMP     #KEYBOARD_INPUT::RETURN ; Return?
                BNE     loc_2756
                JMP     loc_276E
; ---------------------------------------------------------------------------

loc_2756:       LDX     KEY_StringInput_retLength
                CPX     KEY_StringInput_maxLength
                BEQ     loc_274C
                STA     KEY_StringInput_retBuffer,X
                INX
                STX     KEY_StringInput_retLength
                STA     KEY_StringInput_StringBuf
                JSR     KEY_StringInput_PrintChar
                JMP     _inputLoop
; ---------------------------------------------------------------------------

loc_276E:       PLA
                TAX
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

.proc KEY_StringInput_PrintChar
                PHA
                LDA     KEY_StringInput_StringBuf
                ORA     #$80
                STA     KEY_StringInput_StringBuf
                LDA     #<KEY_StringInput_StringBuf
                STA     object_Ptr
                LDA     #>KEY_StringInput_StringBuf
                STA     object_Ptr+1
                JSR     DRAW_String
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
KEY_StringInput_TextXPos:.BYTE $A0
KEY_StringInput_TextYPos:.BYTE $A0
KEY_StringInput_TextColor:.BYTE $A4
KEY_StringInput_TextFont:.BYTE $B2
KEY_StringInput_maxLength:.BYTE $A0
KEY_StringInput_retLength:.BYTE $FF
KEY_StringInput_retBuffer:.BYTE $A0,$E5,$B2,$A4,$B2,$A0,$C8,$C4,$96,$A0,$CC,$A0,$A0,$B2,$A0,$A0,$A0,$A5,$A0,$A0
KEY_StringInput_StringBuf:.BYTE $FF
KEY_StringInput_RotatingCursorIndex:.BYTE $B9
KEY_StringInput_RotatingCursorChars:.BYTE $6C, $7B, $7E, $7C; 0

; =============== S U B R O U T I N E =======================================


.proc KEY_GetKey
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #0
                STA     _KEY_GetKey_inputBufferIndex
                STA     _KEY_GetKey_tableIndex
                LDA     #%11111110
                STA     _KEY_GetKey_Mask
                LDA     #$FF
                STA     CIA1::DDRA      ; Data Direction Port A - Bit X: 0=Input (read only), 1=Output (read and write)
                LDA     #0
                STA     CIA1::DDRB      ; Data Direction Port B - Bit X: 0=Input (read only), 1=Output (read and write)

_StringInput_GetKey_loop:
                LDA     _KEY_GetKey_Mask
                STA     CIA1::PRA       ; Monitoring/control of the 8 data lines of Port A.
                LDA     CIA1::PRB       ; Monitoring/control of the 8 data lines of Port B.
                STA     _KEY_GetKey_CIA_Input
                LDA     #7
                STA     _KEY_GetKey_ASCII

_StringInput_GetKey_indexLoop:
                LSR     _KEY_GetKey_CIA_Input
                BCS     loc_27F0
                LDX     _KEY_GetKey_tableIndex
                LDA     _KEY_GetKey_table,X
                BMI     loc_27F0
                LDX     _KEY_GetKey_inputBufferIndex
                STA     _KEY_GetKey_inputBuffer,X
                INX
                STX     _KEY_GetKey_inputBufferIndex
                CPX     #3
                BEQ     loc_27FE

loc_27F0:       INC     _KEY_GetKey_tableIndex
                DEC     _KEY_GetKey_ASCII
                BPL     _StringInput_GetKey_indexLoop
                SEC
                ROL     _KEY_GetKey_Mask
                BCS     _StringInput_GetKey_loop

loc_27FE:       LDX     #0
loc_2800:       CPX     _KEY_GetKey_inputBufferIndex
                BEQ     _StringInput_GetKey_noInput
                LDY     #0
loc_2807:       CPY     _KEY_GetKey_lastIndex
                BEQ     loc_2821
                LDA     _KEY_GetKey_inputIndex,Y
                CMP     _KEY_GetKey_inputBuffer,X
                BEQ     loc_2818
                INY
                JMP     loc_2807
; ---------------------------------------------------------------------------

loc_2818:       INX
                JMP     loc_2800
; ---------------------------------------------------------------------------

_StringInput_GetKey_noInput:
                LDA     #KEYBOARD_INPUT::NOTHING
                JMP     loc_2824
; ---------------------------------------------------------------------------

loc_2821:       LDA     _KEY_GetKey_inputBuffer,X
loc_2824:       STA     _KEY_GetKey_ASCII

                LDX     _KEY_GetKey_inputBufferIndex
                STX     _KEY_GetKey_lastIndex

loc_282D:       DEX
                BMI     _StringInput_GetKey_return
                LDA     _KEY_GetKey_inputBuffer,X
                STA     _KEY_GetKey_inputIndex,X
                JMP     loc_282D
; ---------------------------------------------------------------------------

_StringInput_GetKey_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                LDA     _KEY_GetKey_ASCII
                RTS
.endproc

; ---------------------------------------------------------------------------
_KEY_GetKey_table:.BYTE 8, $D, 8, $80, $80, $80, $80, $80, $33, $57, $41
                .BYTE $34, $5A, $53, $45, $80, $35, $52, $44, $36, $43
                .BYTE $46, $54, $58, $37, $59, $47, $38, $42, $48, $55
                .BYTE $56, $39, $49, $4A, $30, $4D, $4B, $4F, $4E, $2B
                .BYTE $50, $4C, $2D, $2E, $3A, $40, $2C, $80, $2A, $3B
                .BYTE $80, $80, $3D, $80, $2F, $31, 8, $80, $32, $20, $80
                .BYTE $51, $80
_KEY_GetKey_inputBufferIndex:.BYTE $A0
_KEY_GetKey_inputBuffer:.BYTE $A0, $D2, $A0
_KEY_GetKey_lastIndex:.BYTE 0
_KEY_GetKey_inputIndex:.BYTE $B2, $C6, $C8
_KEY_GetKey_Mask:.BYTE $A0
_KEY_GetKey_CIA_Input:.BYTE $AE
_KEY_GetKey_tableIndex:.BYTE $A0
_KEY_GetKey_ASCII:.BYTE $FF

; =============== S U B R O U T I N E =======================================

.proc DISK_SAVE_FILE
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #2
                LDX     #8
                LDY     #0
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                CLC
                LDA     DISK_SAVE_FILE_FNAME_LENGTH
                ADC     #3
                LDX     #<DISK_SAVE_FILE_FILENAME
                LDY     #>DISK_SAVE_FILE_FILENAME
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                LDA     DISK_SAVE_FILE_FILETYPE
                ASL     A
                TAX
                LDA     _DISK_SAVE_FILE_FILETYPE_TABLE,X
                STA     PP_A
                LDA     _DISK_SAVE_FILE_FILETYPE_TABLE+1,X
                STA     PP_A+1
                CLC
                LDY     #0
                LDA     (PP_A),Y
                ADC     PP_A
                TAX
                INY
                LDA     (PP_A),Y
                ADC     PP_A+1
                TAY
                LDA     #PP_A
                JSR     kernal::SAVE            ; Save file. (Must call SETLFS and SETNAM beforehands.)
                                        ; Input: A = Address of zero page register holding start address of memory area to save; X/Y = End address of memory area plus 1.
                                        ; Output: Carry: 0 = No errors, 1 = Error; A = KERNAL error code (if Carry = 1).
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

DISK_SAVE_FILE_FILETYPE:.BYTE $A0
DISK_SAVE_FILE_FNAME_LENGTH:.BYTE $FF
DISK_SAVE_FILE_FILENAME:.BYTE '@','0',':', $F0,$B0,$B1,$B2,$A0,$F0,$A0,$96,$A0,$A0,$B8,$A0,$85,$A0,$D3,$A0
_DISK_SAVE_FILE_FILETYPE_TABLE:
				.addr CASTLE
                .addr SAVE_GAME_MEMORY
                .addr HIGHSCORES

; =============== S U B R O U T I N E =======================================

.proc DISK_LOAD_FILE
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #2
                LDX     #8
                LDY     #0
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                LDA     DISK_LOAD_FNAME_LENGTH
                LDX     #<DISK_LOAD_FNAME
                LDY     #>DISK_LOAD_FNAME
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                LDA     #0
                LDX     DISK_LOAD_FILETYPE
                LDY     _DISK_LOAD_FILE_FILETYPE_HIGHADDR,X
                LDX     #0
                JSR     kernal::LOAD            ; Load or verify file. (Must call SETLFS and SETNAM beforehands.)
                                        ; Input: A: 0 = Load, 1-255 = Verify; X/Y = Load address (if secondary address = 0).
                                        ; Output: Carry: 0 = No errors, 1 = Error; A = KERNAL error code (if Carry = 1); X/Y = Address of last byte loaded/verified (if Carry = 0).
                STX     DISK_LOAD_FILEADDR
                STY     DISK_LOAD_FILEADDR+1
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_DISK_LOAD_FILE_FILETYPE_HIGHADDR:.BYTE >CASTLE
                .BYTE >SAVE_GAME_MEMORY
                .BYTE >HIGHSCORES

; =============== S U B R O U T I N E =======================================


.proc DISK_ACCESS_PREPARE
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #%00000000      ; Disable VIC interrupts
                STA     VIC::IRQEN      ; Interrupt enabled
                LDA     #%01111111
                STA     CIA1::ICR       ; Interrupt Control and status
                LDA     CIA1::ICR       ; Interrupt Control and status
                LDA     #%111
                STA     C6510::D6510    ; Processor port data direction register (0 = Bit #x in processor port can only be read; 1 = Bit #x in processor port can be read and written.)
                LDA     #%110           ; IO mapped, only KERNAL ROM
                STA     C6510::R6510    ; Processor port
                JSR     kernal::IOINIT  ; Initialize CIA's, SID volume; setup memory configuration; set and start interrupt timer.
                LDA     #%111
                STA     C6510::D6510    ; Processor port data direction register (0 = Bit #x in processor port can only be read; 1 = Bit #x in processor port can be read and written.)
                LDA     #%110           ; IO mapped, only KERNAL ROM
                STA     C6510::R6510    ; Processor port
                LDA     VIC::CR1        ; Control register 1
                AND     #%00100000      ; Text mode?
                BEQ     DISK_ACCESS_PREPARE_return ; => yes
                LDA     CIA2::DDRA      ; Data direction Port A
                ORA     #%00000011
                STA     CIA2::DDRA      ; Data direction Port A
                LDA     CIA2::PRA       ; Select the position of the VIC-memory
                AND     #%11111100      ; $C000 = VIC base address
                STA     CIA2::PRA       ; Select the position of the VIC-memory

                LDA     BEFORE_MAINLOOP_FLAG ; 0, once the mainloop is reached
                CMP     #1
                BNE     DISK_ACCESS_PREPARE_return
                LDA     #COLOR::YELLOW
                STA     VIC::EC_BORDER  ; Border color
                LDA     #COLOR::WHITE
                STA     VIC::BGCOL0     ; Background color 0

DISK_ACCESS_PREPARE_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc DISK_DELAY_AFTER_IO
                PHA
                TXA
                PHA
                LDA     #$F8
                STA     _DISK_DELAY_AFTER_IO_DELAY_COUNTER
                STA     _DISK_DELAY_AFTER_IO_DELAY_COUNTER+1
                STA     _DISK_DELAY_AFTER_IO_DELAY_COUNTER+2
_loop:          INC     _DISK_DELAY_AFTER_IO_DELAY_COUNTER
                BNE     _loop
                INC     _DISK_DELAY_AFTER_IO_DELAY_COUNTER+1
                BNE     _loop
                INC     _DISK_DELAY_AFTER_IO_DELAY_COUNTER+2
                BNE     _loop
                JSR     DRAW_DisableSpritesAndStopSound
                PLA
                TAX
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
DISK_LOAD_FNAME:.BYTE $EF,$B6,$A0,$8A,$A0,$8D,$B3,$C3,$A0,$A0,$CA,$A0,$E5,$B5,$C9,$80
DISK_LOAD_FILETYPE:.BYTE $A0
DISK_LOAD_FNAME_LENGTH:.BYTE $B6
DISK_LOAD_FILEADDR:.BYTE $A0,$AD
_DISK_DELAY_AFTER_IO_DELAY_COUNTER:.BYTE $F0,$A0,$B7

; =============== S U B R O U T I N E =======================================

.proc ConvertTimerToTime
                PHA
                TYA
                PHA
                LDY     #1
                LDA     (object_Ptr),Y  ; Hours
                LDY     #6
                JSR     ConvertTimerToTime_convertBCDToImage
                LDY     #2
                LDA     (object_Ptr),Y  ; Minutes
                LDY     #3
                JSR     ConvertTimerToTime_convertBCDToImage
                LDY     #3
                LDA     (object_Ptr),Y  ; Seconds
                LDY     #0
                JSR     ConvertTimerToTime_convertBCDToImage
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

.proc ConvertTimerToTime_convertBCDToImage
                PHA
                STA     _convertTimeToNumber_Value
                TYA
                PHA
                TXA
                PHA
                LDA     #0
                STA     _convertTimeToNumber_Index
                LDA     _convertTimeToNumber_Value
                LSR     A
                LSR     A
                LSR     A
                LSR     A
loc_29E4:       ASL     A
                ASL     A
                ASL     A
                TAX
loc_29E8:       TXA
                AND     #%111
                CMP     #7
                BEQ     loc_29FE
                LDA     _convertTimeToNumber_FONT_8x8_CHARS_0_9,X
                STA     OBJECT_time_separators_IMAGE,Y
                CLC
                TYA
                ADC     #8
                TAY
                INX
                JMP     loc_29E8
; ---------------------------------------------------------------------------

loc_29FE:       INC     _convertTimeToNumber_Index
                LDA     _convertTimeToNumber_Index
                CMP     #2
                BEQ     loc_2A15
                TYA
                SEC
                SBC     #55
                TAY
                LDA     _convertTimeToNumber_Value
                AND     #%1111
                JMP     loc_29E4
; ---------------------------------------------------------------------------

loc_2A15:       PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_convertTimeToNumber_FONT_8x8_CHARS_0_9:.BYTE %11111100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00110000
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %11111100
                .BYTE %11000000
                .BYTE %11000000
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %11000000
                .BYTE %11000000
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %11000000
                .BYTE %11000000
                .BYTE %11000000
                .BYTE %11111100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %00000000
                .BYTE %11111100
                .BYTE %11001100
                .BYTE %11001100
                .BYTE %11111100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00001100
                .BYTE %00000000
_convertTimeToNumber_Value:.BYTE $85
_convertTimeToNumber_Index:.BYTE $A0
.endproc

; =============== S U B R O U T I N E =======================================

.proc obj_Text_Object_Setup
                PHA
                TYA
                PHA

obj_Text_Prepare_loop:
                LDY     #CreepObj_Text::XPos
                LDA     (object_Ptr),Y
                BEQ     obj_Text_Prepare_next
                STA     DRAW_String_TextXPos
                LDY     #CreepObj_Text::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_String_TextYPos
                LDY     #CreepObj_Text::Color
                LDA     (object_Ptr),Y
                STA     DRAW_String_TextColor
                LDY     #CreepObj_Text::Font
                LDA     (object_Ptr),Y
                STA     DRAW_String_TextFont
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Text)
                STA     object_Ptr
                BCC     loc_2A99
                INC     object_Ptr+1

loc_2A99:       JSR     DRAW_String
                JMP     obj_Text_Prepare_loop
; ---------------------------------------------------------------------------

obj_Text_Prepare_next:
                INC     object_Ptr
                BNE     obj_Text_Prepare_return
                INC     object_Ptr+1

obj_Text_Prepare_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc DRAW_String
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     DRAW_String_TextXPos
                STA     DRAW_Image_Foreground_Left
                STA     DRAW_Image_Mask_Left
                LDA     DRAW_String_TextYPos
                STA     DRAW_Image_Foreground_Top
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::StringPrint_Mask
                STA     DRAW_Image_Mask_GfxID
                LDA     #GfxID::StringPrint_CharacterImage
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::ForegroundAndMask
                STA     DRAW_Image_Mode
                LDA     DRAW_String_TextFont
                AND     #3
                BNE     loc_2AD8
                LDA     #TEXTFONT::s8x8

loc_2AD8:       STA     _DRAW_String_TextFontSize
                ASL     A
                ASL     A
                ASL     A
                STA     OBJECT_drawchar_mask + CreepIMG_Header::heightInPixels
                STA     OBJECT_drawchar_characterimage + CreepIMG_Header::heightInPixels
                ASL     A
                CLC
                ADC     #<OBJECT_StringPrint_CharacterImage_IMAGE
                STA     PP_A
                LDA     #0
                ADC     #>OBJECT_StringPrint_CharacterImage_IMAGE
                STA     PP_A+1
                LDY     #COLOR::GREEN
                LDA     DRAW_String_TextColor
                ASL     A
                ASL     A
                ASL     A
                ASL     A

loc_2AF9:       STA     (PP_A),Y
                DEY
                BPL     loc_2AF9

StringPrint_nextCharacter:
                LDY     #0
                LDA     DRAW_String_TextFont
                AND     #TEXTFONT::ILLEGAL|TEXTFONT::UPPERCASE_INVERTED
                LSR     A
                LSR     A
                LSR     A
                TAX
                LDA     (object_Ptr),Y
                AND     #%01111111
                STA     PP_A
                LDA     #0
                STA     PP_A+1
                ASL     PP_A
                ROL     PP_A+1          ; ASCII-Code * 8
                ASL     PP_A
                ROL     PP_A+1
                ASL     PP_A
                ROL     PP_A+1
                CLC
                LDA     _DRAW_String_ROMFontAddrTable,X
                ADC     PP_A
                STA     PP_A
                LDA     _DRAW_String_ROMFontAddrTable+1,X
                ADC     PP_A+1
                STA     PP_A+1
                LDY     #7              ; 8 Bytes per character
                SEI
                LDA     #%111
                STA     C6510::D6510    ; Processor port data direction register (0 = Bit #x in processor port can only be read; 1 = Bit #x in processor port can be read and written.)
                LDA     #1              ; Character ROM, no other ROMs
                STA     C6510::R6510    ; Processor port

loc_2B39:
                LDA     (PP_A),Y        ; Copy 8 Bytes for a Character from the ROM
                STA     _DRAW_String_ROMFontCopyCharacter,Y
                DEY
                BPL     loc_2B39        ; Copy 8 Bytes for a Character from the ROM
                LDA     #%101           ; IO mapped, no ROM
                STA     C6510::R6510    ; Processor port
                CLI
                LDX     #0
                LDA     #<OBJECT_StringPrint_CharacterImage_IMAGE
                STA     PP_A
                LDA     #>OBJECT_StringPrint_CharacterImage_IMAGE
                STA     PP_A+1

StringPrint_nextCharLine:
                LDA     _DRAW_String_ROMFontCopyCharacter,X
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                AND     #%1111
                TAY
                LDA     _DRAW_String_BitConverterTable,Y
                LDY     #0
                STA     (PP_A),Y
                LDA     _DRAW_String_ROMFontCopyCharacter,X
                AND     #%1111
                TAY
                LDA     _DRAW_String_BitConverterTable,Y
                LDY     #1
                STA     (PP_A),Y

                LDA     _DRAW_String_TextFontSize
                CMP     #TEXTFONT::s8x16
                BCS     StringPrint_16x16_or_24x24
                LDA     #2
                JMP     loc_2BAB
; ---------------------------------------------------------------------------

StringPrint_16x16_or_24x24:
                BNE     StringPrint_24x24
                LDY     #0
                LDA     (PP_A),Y
                LDY     #2
                STA     (PP_A),Y        ; Double the height
                LDY     #1
                LDA     (PP_A),Y
                LDY     #3
                STA     (PP_A),Y
                LDA     #4
                JMP     loc_2BAB
; ---------------------------------------------------------------------------

StringPrint_24x24:
                LDY     #0
                LDA     (PP_A),Y
                LDY     #2
                STA     (PP_A),Y
                LDY     #4
                STA     (PP_A),Y        ; Tripple the height
                LDY     #1
                LDA     (PP_A),Y
                LDY     #3
                STA     (PP_A),Y
                LDY     #5
                STA     (PP_A),Y
                LDA     #6

loc_2BAB:
                CLC
                ADC     PP_A
                STA     PP_A
                BCC     loc_2BB4
                INC     PP_A+1

loc_2BB4:
                INX
                CPX     #8
                BCC     StringPrint_nextCharLine
                JSR     DRAW_Image

                LDY     #0
                LDA     (object_Ptr),Y
                BMI     loc_2BD7
                INC     object_Ptr
                BNE     loc_2BC8
                INC     object_Ptr+1

loc_2BC8:
                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #8
                STA     DRAW_Image_Foreground_Left
                STA     DRAW_Image_Mask_Left
                JMP     StringPrint_nextCharacter
; ---------------------------------------------------------------------------

loc_2BD7:
                INC     object_Ptr
                BNE     loc_2BDD
                INC     object_Ptr+1

loc_2BDD:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
DRAW_String_TextXPos:.BYTE $C5
DRAW_String_TextYPos:.BYTE $C4
DRAW_String_TextColor:.BYTE $A0
DRAW_String_TextFont:.BYTE $CC
_DRAW_String_TextFontSize:.BYTE $CA
_DRAW_String_ROMFontAddrTable:.addr $D000,$D400,$D800,$DC00
_DRAW_String_ROMFontCopyCharacter:.BYTE $89,$CE,$F0,$C1,$A0,$BA,$B1,$A0
_DRAW_String_BitConverterTable:.BYTE %00000000         ; 0
                .BYTE %00000001         ; 1
                .BYTE %00000100         ; 2
                .BYTE %00000101         ; 3
                .BYTE %00010000         ; 4
                .BYTE %00010001         ; 5
                .BYTE %00010100         ; 6
                .BYTE %00010101         ; 7
                .BYTE %01000000         ; 8
                .BYTE %01000001         ; 9
                .BYTE %01000100         ; 10
                .BYTE %01000101         ; 11
                .BYTE %01010000         ; 12
                .BYTE %01010001         ; 13
                .BYTE %01010100         ; 14
                .BYTE %01010101         ; 15

PROT_UNKNOWN_FUNC:.BYTE   0,  0,  0,  0,  0,  0,  0,  0

; =============== S U B R O U T I N E =======================================

PROTECTION_CHECK:
                LDX     #'3'
                LDY     #'5'
                LDA     #0
                JSR     PROTECTION_READ_TRACK ; Read Track #35, Sector #9
                BEQ     PROTECTION_CHECK_exit ; Should return error code 27: Read Error (checksum in header)
                LDX     #'0'
                LDY     #'1'
                LDA     #1
                JSR     PROTECTION_READ_TRACK ; Read Track #1, Sector #9
                BNE     PROTECTION_CHECK_exit ; Should return error code 00: No Error

PROTECTION_CHECK_exit:
                JMP     PROTECTION_DECRYPT_JUMPS

; ---------------------------------------------------------------------------
PROTECTION_ERROR_CODE_1st_DIGIT:.BYTE   0,  0,  0,  0
PROTECTION_ERROR_CODE_2nd_DIGIT:.BYTE   0,' ','2','7'

; =============== S U B R O U T I N E =======================================

.proc PROTECTION_READ_TRACK
                STA     PROTECTION_INDEX
                STX     PROTECTION_READ_SECTOR_CMD+8 ; "01 9\r"
                STY     PROTECTION_READ_SECTOR_CMD+9 ; "1 9\r"
                LDA     #0
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                LDA     #15
                LDX     #8
                TAY
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                JSR     kernal::OPEN            ; Open file. (Must call SETLFS and SETNAM beforehands.)
                LDA     #1
                LDX     #<PROTECTION_DRIVE_CMD
                LDY     #>PROTECTION_DRIVE_CMD
                JSR     kernal::SETNAM          ; Set file name parameters. Input: A = File name length; X/Y = Pointer to file name.
                LDA     #5
                LDX     #8
                TAY
                JSR     kernal::SETLFS          ; Set file parameters. Input: A = Logical number; X = Device number; Y = Secondary address.
                JSR     kernal::OPEN            ; Open file. (Must call SETLFS and SETNAM beforehands.)
                JSR     kernal::CLRCHN          ; Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
                LDX     #15
                JSR     kernal::CHKOUT          ; Define file as default output. (Must call OPEN beforehands.) Input: X = Logical number.
                LDY     #0

loc_2C67:
                LDA     PROTECTION_READ_SECTOR_CMD,Y ; "U1: 5 0 01 9\r"
                BEQ     loc_2C72
                JSR     kernal::CHROUT          ; Write byte to default output. (If not screen, must call OPEN and CHKOUT beforehands.)
                INY
                BNE     loc_2C67

loc_2C72:
                JSR     kernal::CLRCHN          ; Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
                LDX     #15
                JSR     kernal::CHKIN           ; Define file as default input. (Must call OPEN beforehands.) Input: X = Logical number.
                JSR     kernal::CHRIN           ; Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
                LDY     PROTECTION_INDEX
                STA     PROTECTION_ERROR_CODE_1st_DIGIT,Y ; The expected error code is 27: Read Error (checksum in header)
                JSR     kernal::CHRIN           ; Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
                STA     PROTECTION_ERROR_CODE_2nd_DIGIT,Y

_loop:
                JSR     kernal::CHRIN           ; Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
                CMP     #13
                BNE     _loop
                LDA     #15
                JSR     kernal::CLOSE           ; Close file. Input: A = Logical number.
                JSR     kernal::CLALL           ; Clear file table; call CLRCHN
                LDY     PROTECTION_INDEX
                LDA     PROTECTION_ERROR_CODE_1st_DIGIT,Y
                ORA     PROTECTION_ERROR_CODE_2nd_DIGIT,Y ; 00 = no error occurred?
                CMP     #'0'
                RTS
.endproc

; ---------------------------------------------------------------------------
PROTECTION_DRIVE_CMD:.BYTE '#'
PROTECTION_READ_SECTOR_CMD: scrcode "U1: 5 0 01 9"
                            .byte 13,0

; =============== S U B R O U T I N E =======================================


PROTECTION_DECRYPT_JUMPS:
                LDA     PROTECTION_ERROR_CODE_1st_DIGIT ; Has to be '2'
                EOR     _ObjectDoor+2
                STA     _ObjectDoor+2
                LDA     PROTECTION_ERROR_CODE_2nd_DIGIT ; Has to be '7'
                EOR     _ObjectDoorBell+2
                STA     _ObjectDoorBell+2
                LDA     PROTECTION_ERROR_CODE_2nd_DIGIT
                EOR     _ObjectSlidingPole+2
                STA     _ObjectSlidingPole+2
                LDA     PROTECTION_ERROR_CODE_1st_DIGIT
                EOR     _ObjectWalkway+2
                STA     _ObjectWalkway+2
                JMP     DRAW_DisableSpritesAndStopSound

; ---------------------------------------------------------------------------
                .BYTE $FF,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,$8E,  4,$2E,$2C,  7,$2E
                .BYTE $F0,$E3,$8E,  5,$2E,$4C,$FD,$2C,$A9, $D,$20,$CB,$2D,$A2,$C7,$AC,  8,$2E,$8A,$D9,  4,$2E,$B0,  3,$4C,$87,$2D,$BD,  0,$B9,$C0,  1,$D0,  4, $A, $A, $A, $A,$8D,  9,$2E,$AD,  2,$2E, $E,  9,$2E,$2A, $E,  9,$2E,$2A,$A8,$B9,$DE,$2D,$8D, $A,$2E,$AD,  2,$2E, $E,  9
                .BYTE $2E,$2A, $E,  9,$2E,$2A,$A8,$B9,$DE,$2D, $A, $A, $A, $A, $D, $A,$2E,  9,$80,$20,$CB,$2D,$20,$CB,$2D,$8D, $A,$2E,$8A,$29, $F,$D0,  6,$AD, $A,$2E,$20,$CB,$2D,$CA,$E0,$FF,$F0,  3,$4C,$27,$2D,$EE,  8,$2E,$AD,  8,$2E,$C9,  2,$B0,  3,$4C,$20,$2D,$EE,  3,$2E,$4C
                .BYTE $95,$2C,$20,$E7,$FF,$20,$5F,  9,$AD,  2,$2E,$D0,$20,$AD,$13,$2E,$85,$21,$A2,  7,$BD,$14,$2E,$95,$26,$CA,$10,$F8,$A2,  3,$BD, $B,$2E,$9D,  8,$DC,$BD, $F,$2E,$9D,  8,$DD,$CA,$10,$F1,$68,$AA,$68,$A8,$68,$60,$48,$20,$D2,$FF,$20,$B7,$FF,$C9,  0,$F0,  6,$68,$68
                .BYTE $68,$4C,$9A,$2D,$68,$60,  0,  5,  3, $F,  0, $F,  3,  1,$28,$43,$29,$20,$31,$39,$38,$34,$20,$42,$52,$30,$44,$45,$52,$42,$55,$4E,$44,$20,$53,$4F,$46,$54,$57,$41,$52,$C5
PROT_2E02_UNUSED:.BYTE $B0
                .BYTE $D2,$AC,$A0,$F0, $F,$C4,$A0,$B0,$82,$A0,$82,$AA,$85,$C5,$A0,$A0,$A0,$92,$B8,$A0,$C6,$A0,$CC,$A0,$86

; =============== S U B R O U T I N E =======================================

; Handle 1/30 of all game processing

.proc GAME_ExecuteEvents
                PHA
_loop:          LDA     IRQ_DELAY_COUNTER ; Throttle engine to 30Hz
                BNE     _loop           ; Throttle engine to 30Hz
                LDA     #2
                STA     IRQ_DELAY_COUNTER

                JSR     Sprite_Collision_VIC_Flags_Update ; Update all sprite collision states
                JSR     Sprite_Execute
                JSR     Object_Execute
                INC     events_Execute_EngineTicks
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
IRQ_DELAY_COUNTER:.BYTE 0
events_Execute_EngineTicks:.BYTE $A0

; =============== S U B R O U T I N E =======================================

; Update all sprite collision states

.proc Sprite_Collision_VIC_Flags_Update
                PHA
                TXA
                PHA
                LDA     VIC::SPSPCL      ; Sprite-sprite collision
                STA     _Sprite_Collision_Set_VIC_MM
                LDA     VIC::SPBGCL      ; Sprite-data collision
                STA     _Sprite_Collision_Set_VIC_MD
                LDX     #0

_Sprite_Collision_Set_spriteCollisionLoop:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                BEQ     loc_2E59
                LSR     _Sprite_Collision_Set_VIC_MM
                LSR     _Sprite_Collision_Set_VIC_MD
                JMP     _Sprite_Collision_Set_nextSprite
; ---------------------------------------------------------------------------

loc_2E59:       AND     #(~(SPRITE_STATE::VIC_COLLIDE_SPRITE|SPRITE_STATE::VIC_COLLIDE_BACKGROUND) & $FF) ; VIC detected a collision with another sprite
                LSR     _Sprite_Collision_Set_VIC_MM
                BCC     loc_2E62
                ORA     #SPRITE_STATE::VIC_COLLIDE_SPRITE ; VIC detected a collision with another sprite

loc_2E62:       LSR     _Sprite_Collision_Set_VIC_MD
                BCC     loc_2E69
                ORA     #SPRITE_STATE::VIC_COLLIDE_BACKGROUND ; VIC detected a collision with the background layer

loc_2E69:       STA     mSprites + CreepSprite::state,X

_Sprite_Collision_Set_nextSprite:
                CLC
                TXA
                ADC     #.SIZEOF(CreepSprite)
                TAX
                BNE     _Sprite_Collision_Set_spriteCollisionLoop
                PLA
                TAX
                PLA
                RTS

; ---------------------------------------------------------------------------
_Sprite_Collision_Set_VIC_MM:.BYTE $C5
_Sprite_Collision_Set_VIC_MD:.BYTE $D0
.endproc

; =============== S U B R O U T I N E =======================================

Sprite_Execute:
                PHA
                TYA
                PHA
                TXA
                PHA
                LDX     #0

Sprite_Execute_loop:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                BEQ     loc_2E8B
                JMP     Sprite_Execute_nextSprite
; ---------------------------------------------------------------------------

loc_2E8B:
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BNE     Sprite_Execute_exec

                BIT     SPRITE_FLAGS_SHOULD_DIE ; Should the sprite die?
                BNE     _Sprite_Execute_DieAnimation ; yes =>
                DEC     mSprites + CreepSprite::phase_counter,X ; Only execute background collision and execute function at phase 0
                BEQ     loc_2EAD

                BIT     SPRITE_FLAGS_VIC_COLLIDE_SPRITE ; Check for Sprite <=> Sprite collision
                BEQ     loc_2EAA
                JSR     Sprite_Collision_Check ; Check sprite #X for sprite-sprite collisions
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_SHOULD_DIE ; Should the sprite die?
                BNE     _Sprite_Execute_DieAnimation ; yes =>

loc_2EAA:
                JMP     Sprite_Execute_nextSprite
; ---------------------------------------------------------------------------

loc_2EAD:
                BIT     SPRITE_FLAGS_DIEING ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
                BNE     _Sprite_Execute_DieAnimation

                BIT     SPRITE_FLAGS_VIC_COLLIDE_BACKGROUND ; Check for Sprite <=> Background collision
                BEQ     loc_2EC2
                JSR     Sprite_Object_Collision_Check ; Sprite #X collided with background
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_SHOULD_DIE ; Should the sprite die?
                BNE     _Sprite_Execute_DieAnimation ; yes =>

loc_2EC2:
                LDA     mSprites + CreepSprite::state,X ; Check for Sprite <=> Sprite collision
                BIT     SPRITE_FLAGS_VIC_COLLIDE_SPRITE ; VIC detected a collision with another sprite
                BEQ     Sprite_Execute_exec
                JSR     Sprite_Collision_Check ; Check sprite #X for sprite-sprite collisions
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_SHOULD_DIE ; Should the sprite die?
                BNE     _Sprite_Execute_DieAnimation ; yes =>

Sprite_Execute_exec:
                LDA     mSprites + CreepSprite::spriteType,X
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::execute,Y
                STA     loc_2EE8+1
                LDA     Sprite_Table+SPRITE_TABLE::execute+1,Y
                STA     loc_2EE8+2

loc_2EE8:       JMP     loc_2EE8+1
; ---------------------------------------------------------------------------

Sprite_Execute_nextObj:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_SHOULD_DIE ; Let the sprite die, depending of the type by flashing it
                BEQ     loc_2EF6

_Sprite_Execute_DieAnimation:
                JSR     Sprite_IsDieingAnimation

loc_2EF6:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BNE     Sprite_Execute_exec ; Destruction happens during the execute function =>

                TXA
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                TAY
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                BEQ     Sprite_Execute_set_X
                LDA     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                STA     mSprites + CreepSprite::state,X
                JMP     Sprite_Execute_disable_sprite
; ---------------------------------------------------------------------------

Sprite_Execute_set_X:
                LDA     mSprites + CreepSprite::XPos,X
                STA     PP_A
                LDA     #0
                STA     PP_A+1
                ASL     PP_A            ; X = Sprite-X * 2 - 8
                ROL     PP_A+1
                SEC
                LDA     PP_A
                SBC     #8
                SEI
                STA     IRQ_VIC_MnX,Y   ; X Coordinate Sprite 0

                LDA     PP_A+1
                SBC     #0              ; X < 0?
                BCC     Sprite_Execute_disable_sprite
                BEQ     loc_2F3C
                LDA     IRQ_VIC_MSIGX   ; MSBs of X coordinates
                ORA     BITMASK_01__80,Y
                JMP     loc_2F43
; ---------------------------------------------------------------------------

loc_2F3C:
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     IRQ_VIC_MSIGX   ; MSBs of X coordinates

loc_2F43:
                STA     IRQ_VIC_MSIGX   ; MSBs of X coordinates

                AND     BITMASK_01__80,Y
                BEQ     Sprite_Execute_set_Y
                LDA     IRQ_VIC_MnX,Y   ; X Coordinate Sprite 0
                CMP     #88             ; X < 256+88 (344 = 320 + 24)
                BCC     Sprite_Execute_set_Y ; sprite is at least partly visible =>

Sprite_Execute_disable_sprite:
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     IRQ_VIC_ME      ; disable sprite
                JMP     loc_2F69
; ---------------------------------------------------------------------------

Sprite_Execute_set_Y:
                LDA     mSprites + CreepSprite::YPos,X
                CLC                     ; Y = Sprite-Y + 50
                ADC     #50
                STA     IRQ_VIC_MnY,Y   ; Y Coordinate Sprite 0

                LDA     IRQ_VIC_ME      ; Sprite enabled
                ORA     BITMASK_01__80,Y ; enable sprite

loc_2F69:
                STA     IRQ_VIC_ME      ; Sprite enabled
                CLI
                LDA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                STA     mSprites + CreepSprite::phase_counter,X ; Only execute background collision and execute function at phase 0

Sprite_Execute_nextSprite:
                CLC
                TXA
                ADC     #.SIZEOF(CreepSprite)
                TAX
                BEQ     Sprite_Execute_return
                JMP     Sprite_Execute_loop
; ---------------------------------------------------------------------------

Sprite_Execute_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
BITMASK_01__80: .BYTE $01, $02, $04, $08, $10, $20, $40, $80

; =============== S U B R O U T I N E =======================================

.proc Sprite_IsDieingAnimation
                PHA
                TYA
                PHA
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_SHOULD_DIE ; Should the sprite die?
                BNE     loc_2FA3        ; yes =>

                LDA     mSprites + CreepSprite::flickerCounter,X
                BNE     Sprite_FlashOnOff_setFlickerColor
                LDA     mSprites + CreepSprite::state,X
                EOR     SPRITE_FLAGS_DIEING ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
                JMP     _Sprite_FlickerAnimation_destroy_sprite
; ---------------------------------------------------------------------------

loc_2FA3:
                EOR     SPRITE_FLAGS_SHOULD_DIE ; clear the flag
                STA     mSprites + CreepSprite::state,X

                LDA     mSprites + CreepSprite::spriteType,X
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::flashes,Y ; Does this sprite type support flashing?
                BIT     SPRITE_FLASH_ENABLED ; Sprite flashes during dying?
                BNE     loc_2FC4

; Spritetype does not flash, destroy immediately
                LDA     mSprites + CreepSprite::state,X

_Sprite_FlickerAnimation_destroy_sprite:
                ORA     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                STA     mSprites + CreepSprite::state,X
                JMP     Sprite_FlashOnOff_return
; ---------------------------------------------------------------------------

loc_2FC4:
                LDA     #8
                STA     mSprites + CreepSprite::flickerCounter,X ; Flicker 8 times
                TXA
                LSR     A
                LSR     A
                LSR     A               ; X (Sprite offset) / 64 => Y (Sprite Index)
                LSR     A
                LSR     A
                TAY
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     VIC::SPMC        ; Sprite multicolor
                STA     VIC::SPMC        ; Sprite multicolor

                LDA     mSprites + CreepSprite::state,X
                ORA     SPRITE_FLAGS_DIEING ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
                STA     mSprites + CreepSprite::state,X

                LDA     #1
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation

Sprite_FlashOnOff_setFlickerColor:
                LDA     events_Execute_EngineTicks
                AND     #1
                BNE     Sprite_FlashOnOff_black

Sprite_FlashOnOff_white:
                TXA
                LSR     A
                LSR     A
                LSR     A               ; X (Sprite offset) / 64 => Y (Sprite Index)
                LSR     A
                LSR     A
                TAY
                LDA     #COLOR::WHITE
                STA     VIC::SP0COL,Y    ; Color sprite 0
                DEC     mSprites + CreepSprite::flickerCounter,X

                LDA     mSprites + CreepSprite::flickerCounter,X
                ASL     A
                ASL     A
                ASL     A
                STA     SNDEFFECT_SPRITE_FLASH_NOTE
                LDA     #SOUND_EFFECT::SPRITE_FLASH
                JSR     SND_PlayEffect
                JMP     loc_301C
; ---------------------------------------------------------------------------

Sprite_FlashOnOff_black:
                TXA
                LSR     A
                LSR     A
                LSR     A               ; X (Sprite offset) / 64 => Y (Sprite Index)
                LSR     A
                LSR     A
                TAY
                LDA     #COLOR::BLACK
                STA     VIC::SP0COL,Y    ; Color sprite 0

loc_301C:
                LDA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                STA     mSprites + CreepSprite::phase_counter,X ; Only execute background collision and execute function at phase 0

Sprite_FlashOnOff_return:
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

; Check sprite #X for sprite-sprite collisions

.proc Sprite_Collision_Check
                PHA
                TYA
                PHA
                STX     _Sprite_Collision_SpriteNumber
                LDA     mSprites + CreepSprite::spriteType,X
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::collisionMask,Y
                BPL     loc_303B
                JMP     Sprite_Collision_Check_return
; ---------------------------------------------------------------------------

loc_303B:
                STA     _Sprite_Collision_IgnoreHitMask

                LDA     mSprites + CreepSprite::XPos,X
                STA     _Sprite_Collision_PosLeft
                CLC
                ADC     mSprites + CreepSprite::widthInPixels,X
                STA     _Sprite_Collision_PosRight
                BCC     loc_3052
                LDA     #0
                STA     _Sprite_Collision_PosLeft

loc_3052:
                LDA     mSprites + CreepSprite::YPos,X
                STA     _Sprite_Collision_PosTop
                CLC
                ADC     mSprites + CreepSprite::heightInPixels,X
                STA     _Sprite_Collision_PosBottom
                BCC     loc_3066
                LDA     #0
                STA     _Sprite_Collision_PosTop

loc_3066:       LDY     #0
Sprite_Collision_Check_loop:
                STY     _Sprite_Collision_currentIndex
                CPY     _Sprite_Collision_SpriteNumber
                BEQ     Sprite_Collision_Check_next ; ignore if the same sprite =>
                LDA     mSprites + CreepSprite::state,Y
                BIT     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                BNE     Sprite_Collision_Check_next ; ignore unused sprites =>

                BIT     SPRITE_FLAGS_VIC_COLLIDE_SPRITE ; Sprite collision detected by VIC?
                BEQ     Sprite_Collision_Check_next ; no =>
                LDA     mSprites + CreepSprite::spriteType,Y
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::collisionMask,Y
                BMI     Sprite_Collision_Check_next ; all sprite collisions ignored? => (This is not used)
                BIT     _Sprite_Collision_IgnoreHitMask
                BNE     Sprite_Collision_Check_next ; Ignore collision of these two sprite types? =>

; Overlap the sprites rectangles?
                LDY     _Sprite_Collision_currentIndex
                LDA     _Sprite_Collision_PosRight
                CMP     mSprites + CreepSprite::XPos,Y
                BCC     Sprite_Collision_Check_next
                LDA     mSprites + CreepSprite::XPos,Y
                CLC
                ADC     mSprites + CreepSprite::widthInPixels,Y
                CMP     _Sprite_Collision_PosLeft
                BCC     Sprite_Collision_Check_next
                LDA     _Sprite_Collision_PosBottom
                CMP     mSprites + CreepSprite::YPos,Y
                BCC     Sprite_Collision_Check_next
                LDA     mSprites + CreepSprite::YPos,Y
                CLC
                ADC     mSprites + CreepSprite::heightInPixels,Y
                CMP     _Sprite_Collision_PosTop
                BCC     Sprite_Collision_Check_next

                JSR     Sprite_Collision ; Collide sprite X with Y
                LDX     _Sprite_Collision_currentIndex
                LDY     _Sprite_Collision_SpriteNumber
                JSR     Sprite_Collision ; Collide sprite Y with X

Sprite_Collision_Check_next:
                LDX     _Sprite_Collision_SpriteNumber
                LDY     _Sprite_Collision_currentIndex
                TYA
                CLC
                ADC     #.SIZEOF(CreepSprite)
                BEQ     Sprite_Collision_Check_return
                TAY
                JMP     Sprite_Collision_Check_loop
; ---------------------------------------------------------------------------

Sprite_Collision_Check_return:
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

; Sprite collision between sprite #X and #Y happened

Sprite_Collision:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DIEING ; Sprite is dieing (potentially flashing) and ignored for collisions – once flashing is done, it is destroyed
                BNE     Sprite_Collision_return

                LDA     #1
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                STY     _Sprite_Collision_pSpriteNumber2
                LDA     mSprites + CreepSprite::spriteType,X
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::collision,Y
                STA     loc_3101+1
                LDA     Sprite_Table+SPRITE_TABLE::collision+1,Y
                STA     loc_3101+2
                BEQ     Sprite_Collision_die
                LDY     _Sprite_Collision_pSpriteNumber2

loc_3101:
                JMP     loc_3101+1
; ---------------------------------------------------------------------------

Sprite_Collision_next:
                LDA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                CMP     #1
                BNE     Sprite_Collision_return

Sprite_Collision_die:
                LDA     mSprites + CreepSprite::state,X
                ORA     SPRITE_FLAGS_SHOULD_DIE ; Let the sprite die, depending of the type by flashing it
                STA     mSprites + CreepSprite::state,X

Sprite_Collision_return:
                RTS

; ---------------------------------------------------------------------------
_Sprite_Collision_SpriteNumber:.BYTE $AC
_Sprite_Collision_currentIndex:.BYTE $B1
_Sprite_Collision_PosLeft:.BYTE $C4
_Sprite_Collision_PosRight:.BYTE $A0
_Sprite_Collision_PosTop:.BYTE $92
_Sprite_Collision_PosBottom:.BYTE $B9
_Sprite_Collision_IgnoreHitMask:.BYTE $A0
_Sprite_Collision_pSpriteNumber2:.BYTE $FF
Sprite_Collision_DieFlag:.BYTE $D3        ; 0 = Sprite survives collision, 1 = Sprite will die after collision

; =============== S U B R O U T I N E =======================================

; Sprite #X collided with background

Sprite_Object_Collision_Check:
                PHA
                TYA
                PHA

                CLC
                LDA     mSprites + CreepSprite::XPos,X
                STA     _Sprite_Object_Collision_Check_PosLeft
                ADC     mSprites + CreepSprite::widthInPixels,X
                STA     _Sprite_Object_Collision_Check_PosRight
                BCC     loc_3135
                LDA     #0
                STA     _Sprite_Object_Collision_Check_PosLeft

loc_3135:
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                STA     _Sprite_Object_Collision_Check_PosTop
                ADC     mSprites + CreepSprite::heightInPixels,X
                STA     _Sprite_Object_Collision_Check_PosBottom
                BCC     loc_3149
                LDA     #0
                STA     _Sprite_Object_Collision_Check_PosTop

loc_3149:
                LDA     OBJECT_COUNT
                BNE     loc_3151
                JMP     _Sprite_Object_Collision_Check_return
; ---------------------------------------------------------------------------

loc_3151:
                ASL     A
                ASL     A
                ASL     A
                STA     _Sprite_Object_Collision_Check_MaxObjectOffset
                LDY     #0

loc_3159:
                STY     _Sprite_Object_Collision_Check_ObjectNumber
                LDA     mObjects + CreepObject::flags,Y
                BIT     OBJECT_INVISIBLE ; Object is invisible
                BNE     _Sprite_Object_Collision_Check_nextObject ; Object disabled? => ignore

; Compare sprite rect with object rectangle for collision
                LDA     _Sprite_Object_Collision_Check_PosRight
                CMP     mObjects + CreepObject::XPos,Y
                BCC     _Sprite_Object_Collision_Check_nextObject
                CLC
                LDA     mObjects + CreepObject::XPos,Y
                ADC     mObjects + CreepObject::width,Y
                CMP     _Sprite_Object_Collision_Check_PosLeft
                BCC     _Sprite_Object_Collision_Check_nextObject
                LDA     _Sprite_Object_Collision_Check_PosBottom
                CMP     mObjects + CreepObject::YPos,Y
                BCC     _Sprite_Object_Collision_Check_nextObject
                CLC
                LDA     mObjects + CreepObject::YPos,Y
                ADC     mObjects + CreepObject::height,Y
                CMP     _Sprite_Object_Collision_Check_PosTop
                BCC     _Sprite_Object_Collision_Check_nextObject

                LDA     #1
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision
                LDA     mSprites + CreepSprite::spriteType,X
                ASL     A
                ASL     A
                ASL     A
                TAY
                LDA     Sprite_Table+SPRITE_TABLE::objectCollision,Y
                STA     loc_31A9+1      ; Validate collision of sprite #X with object #Y
                LDA     Sprite_Table+SPRITE_TABLE::objectCollision+1,Y
                STA     loc_31A9+2      ; Validate collision of sprite #X with object #Y
                BEQ     _Sprite_Object_Collision_Check_nextObj2
                LDY     _Sprite_Object_Collision_Check_ObjectNumber

loc_31A9:
                JMP     loc_31A9+1      ; Validate collision of sprite #X with object #Y
; ---------------------------------------------------------------------------

Sprite_Object_Collision_Check_nextObj:
                LDY     _Sprite_Object_Collision_Check_ObjectNumber
                LDA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision
                CMP     #1              ; Was the collision flag reset by the check?
                BNE     _Sprite_Object_Collision_Check_nextObj2 ; yes, that means the sprite will not die =>
                LDA     mSprites + CreepSprite::state,X
                ORA     SPRITE_FLAGS_SHOULD_DIE ; Let the sprite die, depending of the type by flashing it
                STA     mSprites + CreepSprite::state,X

_Sprite_Object_Collision_Check_nextObj2:
                LDY     _Sprite_Object_Collision_Check_ObjectNumber
                LDA     mObjects + CreepObject::objectType,Y
                ASL     A
                ASL     A
                TAY
                LDA     ObjectType_Table+2,Y
                STA     loc_31D9+1      ; Validate collision of object #Y with sprite #X
                LDA     ObjectType_Table+3,Y
                STA     loc_31D9+2      ; Validate collision of object #Y with sprite #X
                BEQ     _Sprite_Object_Collision_Check_nextObject
                LDY     _Sprite_Object_Collision_Check_ObjectNumber

loc_31D9:
                JMP     loc_31D9+1      ; Validate collision of object #Y with sprite #X
; ---------------------------------------------------------------------------

_Sprite_Object_Collision_Check_nextObject:
                LDA     _Sprite_Object_Collision_Check_ObjectNumber
                CLC
                ADC     #.SIZEOF(CreepObject)
                TAY
                CPY     _Sprite_Object_Collision_Check_MaxObjectOffset
                BEQ     _Sprite_Object_Collision_Check_return
                JMP     loc_3159
; ---------------------------------------------------------------------------

_Sprite_Object_Collision_Check_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_Sprite_Object_Collision_Check_MaxObjectOffset:.BYTE $B0
_Sprite_Object_Collision_Check_ObjectNumber:.BYTE $FF
_Sprite_Object_Collision_Check_PosLeft:.BYTE $A0
_Sprite_Object_Collision_Check_PosRight:.BYTE $83
_Sprite_Object_Collision_Check_PosTop:.BYTE $A0
_Sprite_Object_Collision_Check_PosBottom:.BYTE $8D
Sprite_Object_Collision_DieFlag:.BYTE $C3 ; 0 = Object survives collision, 1 = Object will die after collision

; =============== S U B R O U T I N E =======================================

.proc obj_Player_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     obj_Player_Execute_CREATE
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                ASL     A
                TAY
                LDA     _obj_Player_Execute_CIA_TOD1_ADDR,Y
                STA     PP_A
                LDA     _obj_Player_Execute_CIA_TOD1_ADDR+1,Y
                STA     PP_A+1
                LDA     _obj_Player_Execute_PlayerTime_Ptr,Y
                STA     PP_B
                LDA     _obj_Player_Execute_PlayerTime_Ptr+1,Y
                STA     PP_B+1
                LDY     #3

loc_3222:
                LDA     (PP_A),Y
                STA     (PP_B),Y
                DEY
                BPL     loc_3222
                JMP     obj_Player_Execute_return
; ---------------------------------------------------------------------------

obj_Player_Execute_CREATE:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     obj_Player_Execute_checkState
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                ASL     A
                TAY
                LDA     _obj_Player_Execute_CIA_TOD1_ADDR,Y
                STA     PP_B
                LDA     _obj_Player_Execute_CIA_TOD1_ADDR+1,Y
                STA     PP_B+1
                LDA     _obj_Player_Execute_PlayerTime_Ptr,Y
                STA     PP_A
                LDA     _obj_Player_Execute_PlayerTime_Ptr+1,Y
                STA     PP_A+1
                LDY     #3

loc_3252:
                LDA     (PP_A),Y
                STA     (PP_B),Y
                DEY
                BPL     loc_3252

                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
                BEQ     loc_32BC
                JSR     obj_Player_Color_Set
                JMP     loc_32DB
; ---------------------------------------------------------------------------

obj_Player_Execute_checkState:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                TAY
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::MOVING_IN_OUT ; Player is in the transition to move in or out of a room
                BEQ     obj_Player_Execute_EXIT_ROOM
                CMP     #PLAYER_STATE::START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
                BNE     obj_Player_Execute_noENTER
                LDA     #PLAYER_STATE::MOVING_IN_OUT ; Player is in the transition to move in or out of a room
                STA     CASTLE + CreepCastle::playerState,Y
                JMP     loc_32BC
; ---------------------------------------------------------------------------

obj_Player_Execute_EXIT_ROOM:
                STY     _obj_Player_Execute_spriteNumber
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                LDA     _obj_Player_Execute_ExitStates + CreepState::nextState,Y
                CMP     #PLAYER_STATE::NEXT_STATE ; Skip to the next state
                BEQ     loc_329E
                LDY     _obj_Player_Execute_spriteNumber
                STA     CASTLE + CreepCastle::playerState,Y
                LDA     #1
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                LDA     CASTLE + CreepCastle::playerState,Y
                JMP     obj_Player_Execute_noENTER
; ---------------------------------------------------------------------------

loc_329E:
                CLC
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                ADC     #.SIZEOF(CreepState)
                STA     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                TAY
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     _obj_Player_Execute_ExitStates + CreepState::xOffset,Y
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     _obj_Player_Execute_ExitStates + CreepState::yOffset,Y
                STA     mSprites + CreepSprite::YPos,X

loc_32BC:
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                LDA     _obj_Player_Execute_ExitStates + CreepState::gfxID,Y
                STA     mSprites + CreepSprite::gfxID,X
                JSR     obj_Player_Color_Set
                JMP     obj_Player_Execute_return
; ---------------------------------------------------------------------------

obj_Player_Execute_noENTER:
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BEQ     loc_32DB
                LDA     mSprites + CreepSprite::state,X
                ORA     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                STA     mSprites + CreepSprite::state,X
                JMP     obj_Player_Execute_return
; ---------------------------------------------------------------------------

loc_32DB:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorNextState,X ; Additional sprite depended data
                CMP     #$FF
                BEQ     loc_32EA
                CMP     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorCurrentState,X ; Additional sprite depended data
                BEQ     loc_32EA
                JSR     obj_TrapDoor_Switch_Trigger ; Check switch for trapdoor #A and trigger, if necessary

loc_32EA:
                STA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorCurrentState,X ; Additional sprite depended data
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorNextState,X ; Additional sprite depended data

                JSR     CalcScreenDirectionAddrForSprite ; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     mSprites + CreepSprite::data + CreepSprite_Player::dirAllow,X ; Additional sprite depended data
                STA     _obj_Player_Execute_allowedDirMask
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Player::dirAllow,X ; Additional sprite depended data

                LDA     CalcScreenDirectionAddrForSprite_Bottom_subpixel
                BEQ     loc_3337

                LDA     _obj_Player_Execute_allowedDirMask
                AND     #DIR_ALLOW::UP|DIR_ALLOW::DOWN
                BNE     loc_338E
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #(~(DIR_ALLOW::RIGHT|DIR_ALLOW::LEFT) & $FF)
                STA     _obj_Player_Execute_allowedDirMask

                LDA     CalcScreenDirectionAddrForSprite_Bottom_subpixel
                LSR     A
                CMP     CalcScreenDirectionAddrForSprite_Left_subpixel
                BEQ     loc_332C
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #DIR_ALLOW::UP|DIR_ALLOW::UP_RIGHT|DIR_ALLOW::RIGHT|DIR_ALLOW::DOWN|DIR_ALLOW::DOWN_LEFT|DIR_ALLOW::LEFT
                STA     _obj_Player_Execute_allowedDirMask
                JMP     loc_338E
; ---------------------------------------------------------------------------

loc_332C:
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #(~(DIR_ALLOW::UP_RIGHT|DIR_ALLOW::DOWN_LEFT) & $FF)
                STA     _obj_Player_Execute_allowedDirMask
                JMP     loc_338E
; ---------------------------------------------------------------------------

loc_3337:
                LDA     CalcScreenDirectionAddrForSprite_Left_subpixel
                CMP     #3
                BNE     loc_3360
                SEC
                LDA     ScreenDirectionAddr
                SBC     #78
                STA     ScreenDirectionAddr
                BCS     loc_3349
                DEC     ScreenDirectionAddr+1

loc_3349:
                LDY     #CreepScreenState::dirFlags
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #DIR_ALLOW::UP|DIR_ALLOW::RIGHT|DIR_ALLOW::DOWN|DIR_ALLOW::DOWN_LEFT|DIR_ALLOW::LEFT
                STA     _obj_Player_Execute_allowedDirMask
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::UP_RIGHT
                ORA     _obj_Player_Execute_allowedDirMask
                STA     _obj_Player_Execute_allowedDirMask
                JMP     loc_338E
; ---------------------------------------------------------------------------

loc_3360:
                CMP     #0
                BNE     loc_3386

                SEC
                LDA     ScreenDirectionAddr
                SBC     #82
                STA     ScreenDirectionAddr
                BCS     loc_336F
                DEC     ScreenDirectionAddr+1

loc_336F:
                LDY     #CreepScreenState::dirFlags
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #(~(DIR_ALLOW::UP_RIGHT|DIR_ALLOW::DOWN_LEFT|DIR_ALLOW::UP_LEFT) & $FF)
                STA     _obj_Player_Execute_allowedDirMask
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::UP_LEFT
                ORA     _obj_Player_Execute_allowedDirMask
                STA     _obj_Player_Execute_allowedDirMask
                JMP     loc_338E
; ---------------------------------------------------------------------------

loc_3386:
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #DIR_ALLOW::UP|DIR_ALLOW::RIGHT|DIR_ALLOW::DOWN|DIR_ALLOW::LEFT
                STA     _obj_Player_Execute_allowedDirMask

loc_338E:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                JSR     KEY_GetJoystick ; Check joystick for port #A and the RUN/STOP key
                LDA     KEY_GetJoystick_Button
                STA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                LDA     KEY_GetJoystick_Input
                STA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                TAY
                BMI     obj_Player_Execute_noJoystickInput
                LDA     BITMASK_01__80,Y
                BIT     _obj_Player_Execute_allowedDirMask
                BEQ     loc_33B2
                TYA
                STA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                JMP     loc_33DE
; ---------------------------------------------------------------------------

loc_33B2:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                BMI     obj_Player_Execute_noJoystickInput
                CLC
                ADC     #1
                AND     #7
                CMP     KEY_GetJoystick_Input
                BEQ     loc_33CB
                SEC
                SBC     #2
                AND     #7
                CMP     KEY_GetJoystick_Input
                BNE     obj_Player_Execute_noJoystickInput

loc_33CB:
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                LDA     BITMASK_01__80,Y
                BIT     _obj_Player_Execute_allowedDirMask
                BNE     loc_33DE

obj_Player_Execute_noJoystickInput:
                LDA     #JOYSTICK_DIRECTION::NOTHING
                STA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                JMP     obj_Player_Execute_return
; ---------------------------------------------------------------------------

loc_33DE:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                AND     #3
                CMP     #JOYSTICK_DIRECTION::RIGHT
                BNE     loc_33F4
                SEC
                LDA     mSprites + CreepSprite::YPos,X
                SBC     CalcScreenDirectionAddrForSprite_Bottom_subpixel
                STA     mSprites + CreepSprite::YPos,X
                JMP     loc_3405
; ---------------------------------------------------------------------------

loc_33F4:
                CMP     #JOYSTICK_DIRECTION::UP
                BNE     loc_3405
                SEC
                LDA     mSprites + CreepSprite::XPos,X
                SBC     CalcScreenDirectionAddrForSprite_Left_subpixel
                STA     mSprites + CreepSprite::XPos,X
                INC     mSprites + CreepSprite::XPos,X

loc_3405:
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     _obj_Player_Execute_xOffsetTable,Y
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     _obj_Player_Execute_yOffsetTable,Y
                STA     mSprites + CreepSprite::YPos,X

                TYA
                AND     #3
                BNE     loc_3459
                LDA     _obj_Player_Execute_allowedDirMask
                AND     #DIR_ALLOW::UP
                BEQ     loc_3451
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                BNE     loc_3433
                INC     mSprites + CreepSprite::gfxID,X
                JMP     loc_3436
; ---------------------------------------------------------------------------

loc_3433:
                DEC     mSprites + CreepSprite::gfxID,X

loc_3436:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::player_climb_ladder_1
                BCS     loc_3445
                LDA     #GfxID::player_climb_ladder_4
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_3482
; ---------------------------------------------------------------------------

loc_3445:
                CMP     #GfxID::lightning_lightning_pole
                BCC     loc_3482
                LDA     #GfxID::player_climb_ladder_1
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_3482
; ---------------------------------------------------------------------------

loc_3451:
                LDA     #GfxID::player_climb_pole
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_3482
; ---------------------------------------------------------------------------

loc_3459:
                INC     mSprites + CreepSprite::gfxID,X

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                CMP     #JOYSTICK_DIRECTION::DOWN
                BCS     loc_3476
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::exit
                BCS     loc_346E
                CMP     #GfxID::player_run_right_1
                BCS     loc_3482

loc_346E:
                LDA     #GfxID::player_run_right_1
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_3482
; ---------------------------------------------------------------------------

loc_3476:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::player_run_right_1
                BCC     loc_3482
                LDA     #GfxID::player_run_left_1
                STA     mSprites + CreepSprite::gfxID,X

loc_3482:
                JSR     obj_Player_Color_Set

obj_Player_Execute_return:
                JMP     Sprite_Execute_nextObj


; =============== S U B R O U T I N E =======================================


obj_Player_Color_Set:
                JSR     Sprite_Update
                TXA
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                STA     _obj_Player_Execute_spriteNumber
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     obj_Player_Execute_PlayerHeadColorTab,Y
                LDY     _obj_Player_Execute_spriteNumber
                STA     VIC::SP0COL,Y    ; Color sprite 0
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Player_Execute_ExitStates:_CreepState   0,   0, GfxID::player_run_exit_1, PLAYER_STATE::NEXT_STATE ; Player is in the current room
                _CreepState   1, $FF, GfxID::player_run_exit_2, PLAYER_STATE::NEXT_STATE
                _CreepState   1,   0, GfxID::player_run_exit_3, PLAYER_STATE::NEXT_STATE
                _CreepState   1, $FF, GfxID::player_run_exit_4, PLAYER_STATE::NEXT_STATE
                _CreepState   1,   0, GfxID::player_run_exit_5, PLAYER_STATE::NEXT_STATE
                _CreepState   1, $FF, GfxID::player_run_exit_6, PLAYER_STATE::LEFT_ROOM

                _CreepState   0,   0, GfxID::player_run_exit_6, PLAYER_STATE::NEXT_STATE
                _CreepState $FF,   1, GfxID::player_run_exit_5, PLAYER_STATE::NEXT_STATE
                _CreepState $FF,   0, GfxID::player_run_exit_4, PLAYER_STATE::NEXT_STATE
                _CreepState $FF,   1, GfxID::player_run_exit_3, PLAYER_STATE::NEXT_STATE
                _CreepState $FF,   0, GfxID::player_run_exit_2, PLAYER_STATE::NEXT_STATE
                _CreepState $FF,   1, GfxID::player_run_exit_1, PLAYER_STATE::IN_ROOM

obj_Player_Execute_playerSpriteNumber:.BYTE $80, $A0
obj_Player_Execute_PlayerHeadColorTab:.BYTE COLOR::YELLOW,COLOR::ORANGE
_obj_Player_Execute_allowedDirMask:.BYTE $82
_obj_Player_Execute_spriteNumber:.BYTE $D1
_obj_Player_Execute_xOffsetTable:.BYTE   0,  1,  1,  1,  0,$FF,$FF,$FF
_obj_Player_Execute_yOffsetTable:.BYTE $FE,$FE,  0,  2,  2,  2,  0,$FE

_obj_Player_Execute_CIA_TOD1_ADDR:.addr CIA1::TOD1, CIA2::TOD1 ; Real Time Clock 1/10s
_obj_Player_Execute_PlayerTime_Ptr:.addr CASTLE + CreepCastle::playerTimer + CreepPlayerTime::player_1
                .addr CASTLE + CreepCastle::playerTimer + CreepPlayerTime::player_2

; =============== S U B R O U T I N E =======================================

obj_Player_Sprite_ObjectCollision:
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR
                BNE     loc_3505

                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCC     loc_3529

loc_3505:
                LDA     #0
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision

                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR_SWITCH
                BNE     obj_Player_Collision_return
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCS     obj_Player_Collision_return
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorNextState,X ; Additional sprite depended data
                JMP     obj_Player_Collision_return
; ---------------------------------------------------------------------------

loc_3529:
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     #PLAYER_STATE::DIEING ; Player is dieing by collision, trapdoor or pressing RESTORE
                STA     CASTLE + CreepCastle::playerState,Y

obj_Player_Collision_return:
                JMP     Sprite_Object_Collision_Check_nextObj


; =============== S U B R O U T I N E =======================================


obj_Player_Sprite_SpriteCollision:
                LDA     mSprites + CreepSprite::spriteType,Y
                CMP     #SPRITE_TYPE::FORCEFIELD
                BEQ     obj_Player_Sprite_Collision_ignore
                CMP     #SPRITE_TYPE::PLAYER ; collision with any other sprite except the other play kills
                BNE     obj_Player_Sprite_Collision_killPlayer
                LDA     mSprites + CreepSprite::gfxID,Y
                CMP     #GfxID::player_climb_ladder_1
                BEQ     loc_3556
                CMP     #GfxID::player_climb_ladder_2
                BEQ     loc_3556
                CMP     #GfxID::player_climb_ladder_3
                BEQ     loc_3556
                CMP     #GfxID::player_climb_ladder_4
                BEQ     loc_3556
                CMP     #GfxID::player_climb_pole
                BNE     obj_Player_Sprite_Collision_ignore

loc_3556:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::player_climb_ladder_1
                BEQ     loc_356D
                CMP     #GfxID::player_climb_ladder_2
                BEQ     loc_356D
                CMP     #GfxID::player_climb_ladder_3
                BEQ     loc_356D
                CMP     #GfxID::player_climb_ladder_4
                BEQ     loc_356D
                CMP     #GfxID::player_climb_pole
                BNE     obj_Player_Sprite_Collision_ignore

loc_356D:
                LDA     mSprites + CreepSprite::YPos,Y
                CMP     mSprites + CreepSprite::YPos,X
                BEQ     obj_Player_Sprite_Collision_ignore
                BCC     loc_357F
                LDA     #(~DIR_ALLOW::DOWN & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Player::dirAllow,X ; Additional sprite depended data
                JMP     obj_Player_Sprite_Collision_ignore
; ---------------------------------------------------------------------------

loc_357F:
                LDA     #(~DIR_ALLOW::UP & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Player::dirAllow,X ; Additional sprite depended data

obj_Player_Sprite_Collision_ignore:
                LDA     #0
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                JMP     loc_359B
; ---------------------------------------------------------------------------

obj_Player_Sprite_Collision_killPlayer:
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Player_Sprite_Collision_ignore
                LDA     #PLAYER_STATE::DIEING ; Player is dieing by collision, trapdoor or pressing RESTORE
                STA     CASTLE + CreepCastle::playerState,Y

loc_359B:
                JMP     Sprite_Collision_next


; =============== S U B R O U T I N E =======================================

; Add player to the current room

obj_Player_Add:
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     Sprite_Create
                LDY     obj_Player_Add_playerNumber
                TXA
                STA     obj_Player_Execute_playerSpriteNumber,Y

                LDA     CASTLE + CreepCastle::playerCurrentDoor,Y
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     _obj_Door_Object_Setup_RoomDoorPtr
                STA     mVObjectPtr
                LDA     _obj_Door_Object_Setup_RoomDoorPtr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Door::Flags
                LDA     (mVObjectPtr),Y
                AND     #DOOR_FLAGS::ISOPEN ; Is the door open?
                BEQ     loc_35F1        ; No => place player into room without a transition

                LDA     #PLAYER_STATE::START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
                LDY     obj_Player_Add_playerNumber
                STA     CASTLE + CreepCastle::playerState,Y
                CLC
                LDY     #CreepObj_Door::XPos
                LDA     (mVObjectPtr),Y
                ADC     #11
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDY     #CreepObj_Door::YPos
                LDA     (mVObjectPtr),Y
                ADC     #12
                STA     mSprites + CreepSprite::YPos,X
                LDA     #.SIZEOF(CreepState)*6 ; Enter room transition
                STA     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                LDA     #3
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                JMP     loc_360D
; ---------------------------------------------------------------------------

loc_35F1:
                LDA     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                LDY     obj_Player_Add_playerNumber
                STA     CASTLE + CreepCastle::playerState,Y
                LDY     #CreepObj_Door::XPos
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #6
                STA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Door::YPos
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #15
                STA     mSprites + CreepSprite::YPos,X

loc_360D:
                LDA     #3
                STA     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                LDA     #17
                STA     mSprites + CreepSprite::yOffset,X ; Y-Offset to define the baseline of the sprite
                LDA     #JOYSTICK_DIRECTION::NOTHING
                STA     mSprites + CreepSprite::data + CreepSprite_Player::selectedDir,X ; Additional sprite depended data
                LDA     obj_Player_Add_playerNumber
                STA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     #GfxID::player_run_left_1
                STA     mSprites + CreepSprite::gfxID,X
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorCurrentState,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::data + CreepSprite_Player::trapdoorNextState,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::data + CreepSprite_Player::dirAllow,X ; Additional sprite depended data
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
obj_Player_Add_playerNumber:.BYTE $BA

; =============== S U B R O U T I N E =======================================


.proc obj_Lightning_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     loc_364D
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X
                JMP     obj_Lightning_Execute_return
; ---------------------------------------------------------------------------

loc_364D:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     loc_3658
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X

loc_3658:
                JSR     GetRandom
                AND     #%11
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                INC     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation

                JSR     GetRandom
                AND     #%11
                CLC
                ADC     #GfxID::lightning_anim_1
                CMP     mSprites + CreepSprite::gfxID,X
                BNE     loc_3679
                CLC
                ADC     #1
                CMP     #GfxID::forcefield_anim_2
                BCC     loc_3679
                LDA     #GfxID::lightning_anim_1

loc_3679:
                STA     mSprites + CreepSprite::gfxID,X
                JSR     Sprite_Update

obj_Lightning_Execute_return:
                JMP     Sprite_Execute_nextObj
.endproc

; =============== S U B R O U T I N E =======================================

.proc obj_Lightning_Sprite_SpriteCollision
                LDA     #0              ; The lightning survives all collisions with sprites
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                JMP     Sprite_Collision_next
.endproc

; =============== S U B R O U T I N E =======================================

.proc obj_Lightning_Sprite_Create
                PHA
                TYA
                PHA
                TXA
                PHA
                TAY
                JSR     Sprite_Create
                LDA     #SPRITE_TYPE::LIGHTNING
                STA     mSprites + CreepSprite::spriteType,X
                LDA     mObjects + CreepObject::YPos,Y
                CLC
                ADC     #8
                STA     mSprites + CreepSprite::YPos,X
                LDA     mObjects + CreepObject::XPos,Y
                STA     mSprites + CreepSprite::XPos,X
                LDA     mObjectsVars + CreepObjectVars_LightningMachine::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_Lightning::id,X ; Additional sprite depended data
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

.proc obj_Forcefield_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     loc_36C7
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X
                JMP     obj_Forcefield_Execute_return
; ---------------------------------------------------------------------------

loc_36C7:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     loc_36D2
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X

loc_36D2:
                LDY     mSprites + CreepSprite::data + CreepSprite_Forcefield::id,X ; Additional sprite depended data
                LDA     _obj_Forcefield_isActiveFlag,Y
                CMP     #1
                BNE     loc_371A
                LDA     mSprites + CreepSprite::data + CreepSprite_Forcefield::flag,X ; Additional sprite depended data
                CMP     #1
                BEQ     loc_3709
                LDA     #1
                STA     mSprites + CreepSprite::data + CreepSprite_Forcefield::flag,X ; Additional sprite depended data
                JSR     CalcScreenDirectionAddrForSprite ; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines
                SEC
                LDA     ScreenDirectionAddr
                SBC     #.SIZEOF(CreepScreenState)
                STA     ScreenDirectionAddr
                BCS     loc_36F6
                DEC     ScreenDirectionAddr+1

loc_36F6:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::RIGHT & $FF)
                STA     (ScreenDirectionAddr),Y
                LDY     #4
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::LEFT & $FF)
                STA     (ScreenDirectionAddr),Y
                JMP     loc_3715
; ---------------------------------------------------------------------------

loc_3709:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::forcefield_anim_1
                BNE     loc_3715
                LDA     #GfxID::forcefield_anim_2
                JMP     loc_3746
; ---------------------------------------------------------------------------

loc_3715:
                LDA     #GfxID::forcefield_anim_1
                JMP     loc_3746
; ---------------------------------------------------------------------------

loc_371A:
                LDA     mSprites + CreepSprite::data + CreepSprite_Forcefield::flag,X ; Additional sprite depended data
                CMP     #1
                BNE     obj_Forcefield_Execute_return
                LDA     #0
                STA     mSprites + CreepSprite::data + CreepSprite_Forcefield::flag,X ; Additional sprite depended data
                JSR     CalcScreenDirectionAddrForSprite ; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines
                SEC
                LDA     ScreenDirectionAddr
                SBC     #.SIZEOF(CreepScreenState)
                STA     ScreenDirectionAddr
                BCS     loc_3734
                DEC     ScreenDirectionAddr+1

loc_3734:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::RIGHT
                STA     (ScreenDirectionAddr),Y
                LDY     #4
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::LEFT
                STA     (ScreenDirectionAddr),Y
                LDA     #GfxID::forcefield_anim_off

loc_3746:
                STA     mSprites + CreepSprite::gfxID,X
                JSR     Sprite_Update

obj_Forcefield_Execute_return:
                JMP     Sprite_Execute_nextObj
.endproc


; =============== S U B R O U T I N E =======================================

.proc obj_Forcefield_Sprite_SpriteCollision
                LDA     #0              ; The forcefield survives all collisions with sprites
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                JMP     Sprite_Collision_next
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_Forcefield_Create_Sprite
                PHA
                TYA
                PHA
                TXA
                PHA
                JSR     Sprite_Create
                LDA     #SPRITE_TYPE::FORCEFIELD
                STA     mSprites + CreepSprite::spriteType,X
                LDY     #CreepObj_Forcefield::XPosController
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Forcefield::YPosController
                LDA     (object_Ptr),Y
                CLC
                ADC     #2
                STA     mSprites + CreepSprite::YPos,X
                LDA     #GfxID::forcefield_anim_1
                STA     mSprites + CreepSprite::gfxID,X
                LDA     obj_Forcefield_Prepare_ForcefieldCount
                STA     mSprites + CreepSprite::data + CreepSprite_Forcefield::id,X ; Additional sprite depended data
                LDA     #0
                STA     mSprites + CreepSprite::data + CreepSprite_Forcefield::flag,X ; Additional sprite depended data
                LDA     #4
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                LDA     #2
                STA     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                LDA     #25
                STA     mSprites + CreepSprite::yOffset,X ; Y-Offset to define the baseline of the sprite
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

.proc obj_Mummy_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     loc_37AE
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X
                JMP     obj_Mummy_Execute_return
; ---------------------------------------------------------------------------

loc_37AE:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     loc_37C6
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X
                LDA     mSprites + CreepSprite::data + CreepSprite_Mummy::flag,X ; Additional sprite depended data
                BEQ     loc_37C6

                LDA     #GfxID::mummy_left_1
                STA     mSprites + CreepSprite::gfxID,X
                JSR     Sprite_Update

loc_37C6:
                LDA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorNextState,X ; Additional sprite depended data
                CMP     #$FF
                BEQ     loc_37D5
                CMP     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorCurrentState,X ; Additional sprite depended data
                BEQ     loc_37D5
                JSR     obj_TrapDoor_Switch_Trigger ; Check switch for trapdoor #A and trigger, if necessary

loc_37D5:
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorCurrentState,X ; Additional sprite depended data
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorNextState,X ; Additional sprite depended data

                CLC
                LDA     obj_Mummy_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Mummy::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Mummy_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mSprites + CreepSprite::data + CreepSprite_Mummy::flag,X ; Additional sprite depended data
                BNE     loc_3846

                INC     mSprites + CreepSprite::data + CreepSprite_Mummy::slideOutAnimationIndex,X ; Additional sprite depended data
                LDY     mSprites + CreepSprite::data + CreepSprite_Mummy::slideOutAnimationIndex,X ; Additional sprite depended data
                LDA     _obj_Mummy_Execute_mummy_slide_animation,Y
                CMP     #GfxID::illegal
                BEQ     loc_3828
                STA     mSprites + CreepSprite::gfxID,X

                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     _obj_Mummy_Execute_slideOutXOffset,Y
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     _obj_Mummy_Execute_slideOutYOffset,Y
                STA     mSprites + CreepSprite::YPos,X

                LDA     mSprites + CreepSprite::data + CreepSprite_Mummy::slideOutAnimationIndex,X ; Additional sprite depended data
                ASL     A
                ASL     A
                ADC     #SID_NOTE::C3
                STA     SNDEFFECT_MUMMY_RELEASE_NOTE
                LDA     #SOUND_EFFECT::MUMMY_RELEASE
                JSR     SND_PlayEffect
                JMP     loc_38C8
; ---------------------------------------------------------------------------

loc_3828:
                LDA     #1
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::flag,X ; Additional sprite depended data
                CLC
                LDY     #CreepObj_Mummy::mummyXPos
                LDA     (mVObjectPtr),Y
                ADC     #4
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (mVObjectPtr),Y
                ADC     #7
                STA     mSprites + CreepSprite::YPos,X
                LDA     #2
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation

loc_3846:
                LDA     CASTLE + CreepCastle::playerState + CreepPlayerData::player_1
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BEQ     loc_3857
                LDA     CASTLE + CreepCastle::playerState + CreepPlayerData::player_2
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BEQ     loc_385C
                JMP     obj_Mummy_Execute_return
; ---------------------------------------------------------------------------

loc_3857:
                LDY     #0
                JMP     loc_385E
; ---------------------------------------------------------------------------

loc_385C:
                LDY     #1

loc_385E:
                LDA     obj_Player_Execute_playerSpriteNumber,Y
                TAY
                JSR     CalcScreenDirectionAddrForSprite ; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines

                SEC
                LDA     mSprites + CreepSprite::XPos,X
                SBC     mSprites + CreepSprite::XPos,Y
                BCS     loc_3872
                EOR     #$FF            ; abs(A)
                ADC     #1

loc_3872:
                CMP     #2
                BCC     obj_Mummy_Execute_return

                INC     mSprites + CreepSprite::gfxID,X ; increment animation phase
                LDA     mSprites + CreepSprite::XPos,X
                CMP     mSprites + CreepSprite::XPos,Y ; Tracked player left or right of the mummy?
                BCS     obj_Mummy_Execute_moveLeft

                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y ; Can the mummy move right?
                AND     #DIR_ALLOW::RIGHT
                BEQ     obj_Mummy_Execute_return ; no =>

                INC     mSprites + CreepSprite::XPos,X ; move right
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::mummy_right_1
                BCC     loc_3897
                CMP     #GfxID::key_1
                BCC     loc_38BA

loc_3897:
                LDA     #GfxID::mummy_right_1
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_38BA
; ---------------------------------------------------------------------------

obj_Mummy_Execute_moveLeft:
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::LEFT
                BEQ     obj_Mummy_Execute_return

                DEC     mSprites + CreepSprite::XPos,X ; move left
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::mummy_left_1
                BCC     loc_38B5
                CMP     #GfxID::mummy_right_1
                BCC     loc_38BA

loc_38B5:
                LDA     #GfxID::mummy_left_1
                STA     mSprites + CreepSprite::gfxID,X

loc_38BA:
                LDY     #CreepObj_Mummy::savedXPos
                LDA     mSprites + CreepSprite::XPos,X
                STA     (mVObjectPtr),Y
                LDY     #CreepObj_Mummy::savedYPos
                LDA     mSprites + CreepSprite::YPos,X
                STA     (mVObjectPtr),Y

loc_38C8:
                JSR     Sprite_Update

obj_Mummy_Execute_return:
                JMP     Sprite_Execute_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Mummy_Sprite_Collision
                STY     _obj_Mummy_Collision_collisionId
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR
                BNE     loc_3919

                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCS     loc_3919

                CLC
                LDA     obj_TrapDoor_Ptr
                ADC     mObjectsVars + CreepObjectVars_Ankh::id,Y
                STA     mVObjectPtr
                LDA     obj_TrapDoor_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Trapdoor::Flags
                LDA     (mVObjectPtr),Y
                BIT     TRAPDOOR_OPEN
                BEQ     loc_3919

                CLC
                LDA     obj_Mummy_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Mummy::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Mummy_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Mummy::Type
                LDA     #OBJ_MUMMY_STATE::DIEING
                STA     (mVObjectPtr),Y
                JMP     obj_Mummy_Collision_return
; ---------------------------------------------------------------------------

loc_3919:
                LDY     _obj_Mummy_Collision_collisionId
                LDA     #0
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision

                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR_SWITCH
                BNE     obj_Mummy_Collision_return
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCS     obj_Mummy_Collision_return
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorNextState,X ; Additional sprite depended data

obj_Mummy_Collision_return:
                JMP     Sprite_Object_Collision_Check_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Mummy_Sprite_SpriteCollision
                LDA     mSprites + CreepSprite::spriteType,Y
                BEQ     loc_3949        ; Mummy survives collisions with player and Frankenstein
                CMP     #SPRITE_TYPE::FRANKENSTEIN
                BNE     loc_3951

loc_3949:
                LDA     #0
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision
                JMP     loc_3967
; ---------------------------------------------------------------------------

loc_3951:
                CLC
                LDA     obj_Mummy_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Mummy::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Mummy_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Mummy::Type
                LDA     #OBJ_MUMMY_STATE::DIEING
                STA     (mVObjectPtr),Y

loc_3967:
                JMP     Sprite_Collision_next
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Mummy_Sprite_Create
                PHA
                STA     _obj_Mummy_Sprite_Create_inputFlag
                TYA
                PHA
                TXA
                PHA
                TAY
                JSR     Sprite_Create
                LDA     #SPRITE_TYPE::MUMMY
                STA     mSprites + CreepSprite::spriteType,X
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorCurrentState,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::trapdoorNextState,X ; Additional sprite depended data

                LDA     mObjectsVars + CreepObjectVars_Ankh::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::id,X ; Additional sprite depended data
                CLC
                ADC     obj_Mummy_Ptr
                STA     mVObjectPtr
                LDA     obj_Mummy_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     #5
                STA     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                LDA     #17
                STA     mSprites + CreepSprite::yOffset,X ; Y-Offset to define the baseline of the sprite
                LDA     #GfxID::illegal
                STA     mSprites + CreepSprite::gfxID,X

                LDA     _obj_Mummy_Sprite_Create_inputFlag
                BNE     loc_39D0

                LDA     #0
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::flag,X ; Additional sprite depended data
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::slideOutAnimationIndex,X ; Additional sprite depended data
                LDA     #4
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                LDY     #CreepObj_Mummy::mummyXPos
                CLC
                LDA     (mVObjectPtr),Y
                ADC     #13
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (mVObjectPtr),Y
                ADC     #8
                STA     mSprites + CreepSprite::YPos,X
                JMP     loc_39E8
; ---------------------------------------------------------------------------

loc_39D0:
                LDA     #1
                STA     mSprites + CreepSprite::data + CreepSprite_Mummy::flag,X ; Additional sprite depended data
                LDY     #CreepObj_Mummy::savedXPos
                LDA     (mVObjectPtr),Y
                STA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Mummy::savedYPos
                LDA     (mVObjectPtr),Y
                STA     mSprites + CreepSprite::YPos,X
                LDA     #2
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation

loc_39E8:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Mummy_Sprite_Create_inputFlag:.BYTE $B3
_obj_Mummy_Execute_mummy_slide_animation:.BYTE GfxID::mummy_slide_1; 0
                .BYTE GfxID::mummy_slide_2; 1
                .BYTE GfxID::mummy_slide_3; 2
                .BYTE GfxID::mummy_slide_4; 3
                .BYTE GfxID::mummy_slide_5; 4
                .BYTE GfxID::mummy_slide_6; 5
                .BYTE GfxID::mummy_slide_6; 6
                .BYTE GfxID::illegal     ; 7
_obj_Mummy_Execute_slideOutXOffset:.BYTE   0,$FE,$FE,$FE,$FE,$FE,$FE,  0
_obj_Mummy_Execute_slideOutYOffset:.BYTE   0,  0,  0,  2,  2,  2,  2,  0
_obj_Mummy_Collision_collisionId:.BYTE $BA

; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Shot_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     loc_3A37
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X

                LDA     mSprites + CreepSprite::data + CreepSprite_RayGun::shotRayGunId,X ; Additional sprite depended data
                CLC
                ADC     obj_RayGun_Ptr
                STA     mVObjectPtr
                LDA     obj_RayGun_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Raygun::Flags
                LDA     #%11111111
                EOR     RAYGUN_SHOT_ACTIVE ; The Raygun can only fire one shot at the time
                AND     (mVObjectPtr),Y
                STA     (mVObjectPtr),Y
                JMP     obj_RayGun_Laser_Execute_return
; ---------------------------------------------------------------------------

loc_3A37:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     loc_3A42
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X

loc_3A42:
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::data + CreepSprite_RayGun::shotXSpeed,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::XPos,X
                CMP     #176
                BCS     obj_RayGun_Laser_Execute_removeShot ; Is the laser shot out of bounds?
                CMP     #8
                BCS     obj_RayGun_Laser_Execute_return

obj_RayGun_Laser_Execute_removeShot:
                LDA     mSprites + CreepSprite::state,X
                ORA     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                STA     mSprites + CreepSprite::state,X

obj_RayGun_Laser_Execute_return:
                JMP     Sprite_Execute_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Shot_Sprite_ObjectCollision
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::LIGHTNINGMACHINE
                BEQ     obj_RayGun_Laser_Collision_return
                CMP     #OBJECT_TYPE::FRANKENSTEIN
                BEQ     obj_RayGun_Laser_Collision_return
                CMP     #OBJECT_TYPE::RAYGUN
                BNE     loc_3A77        ; Do not remove laser shot if it collides with the matching ray gun
                LDA     mSprites + CreepSprite::data + CreepSprite_RayGun::shotRayGunId,X ; Additional sprite depended data
                CMP     mObjectsVars + CreepObjectVars_RayGun::id,Y
                BNE     obj_RayGun_Laser_Collision_return

loc_3A77:
                LDA     #0              ; Do not remove laser shot if it collides with the matching ray gun
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision

obj_RayGun_Laser_Collision_return:
                JMP     Sprite_Object_Collision_Check_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Shot_Create
                PHA
                TYA
                PHA
                TXA
                PHA
                TAY
                CLC
                LDA     mObjectsVars + CreepObjectVars_RayGun::id,Y
                ADC     #7
                AND     #%11111000
                LSR     A
                ADC     #SID_NOTE::Gs3
                STA     SNDEFFECT_LASER_FIRED_NOTE
                LDA     #SOUND_EFFECT::LASER_FIRED
                JSR     SND_PlayEffect

                JSR     Sprite_Create
                LDA     #SPRITE_TYPE::RAYGUN_SHOT
                STA     mSprites + CreepSprite::spriteType,X
                LDA     mObjects + CreepObject::XPos,Y
                STA     mSprites + CreepSprite::XPos,X
                CLC
                LDA     mObjects + CreepObject::YPos,Y
                ADC     #5
                STA     mSprites + CreepSprite::YPos,X
                LDA     #GfxID::raygun_shot
                STA     mSprites + CreepSprite::gfxID,X
                LDA     mObjectsVars + CreepObjectVars_RayGun::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_RayGun::shotRayGunId,X ; Additional sprite depended data

                LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_FACING_LEFT ; Raygun is facing left (vs right)
                BEQ     obj_RayGun_Laser_Shot_Create_right
                SEC
                LDA     mSprites + CreepSprite::XPos,X
                SBC     #8
                STA     mSprites + CreepSprite::XPos,X
                LDA     #(-4 & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_RayGun::shotXSpeed,X ; Additional sprite depended data
                JMP     obj_RayGun_Laser_Shot_Create_done
; ---------------------------------------------------------------------------

obj_RayGun_Laser_Shot_Create_right:
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     #8
                STA     mSprites + CreepSprite::XPos,X
                LDA     #4
                STA     mSprites + CreepSprite::data + CreepSprite_RayGun::shotXSpeed,X ; Additional sprite depended data

obj_RayGun_Laser_Shot_Create_done:
                JSR     Sprite_Update
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Frankenstein_Sprite_Execute
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                BEQ     loc_3AFF
                EOR     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                ORA     SPRITE_FLAGS_FREE ; Free the sprite after the execute and mark UNUSED
                STA     mSprites + CreepSprite::state,X
                JMP     _obj_Frankenstein_Sprite_Execute_return
; ---------------------------------------------------------------------------

loc_3AFF:
                BIT     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                BEQ     loc_3B0A
                EOR     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X

loc_3B0A:
                CLC
                LDA     obj_Frankenstein_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Frankenstein::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Frankenstein_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                BIT     FRANKENSTEIN_AWAKE
                BNE     _obj_Frankenstein_Execute_player_FrankensteinIsAwake
                LDA     Intro_IsInIntroFlag
                CMP     #1
                BNE     loc_3B2C
                JMP     _obj_Frankenstein_Sprite_Execute_return
; ---------------------------------------------------------------------------

loc_3B2C:
                LDA     #1
                STA     _obj_Frankenstein_Execute_playerIndex

_obj_Frankenstein_Execute_playerLoop:
                LDY     _obj_Frankenstein_Execute_playerIndex
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     _obj_Frankenstein_Execute_nextPlayer

                LDA     obj_Player_Execute_playerSpriteNumber,Y
                TAY
                SEC
                LDA     mSprites + CreepSprite::YPos,X
                SBC     mSprites + CreepSprite::YPos,Y
                CMP     #4
                BCS     _obj_Frankenstein_Execute_nextPlayer
                SEC
                LDA     mSprites + CreepSprite::XPos,X
                SBC     mSprites + CreepSprite::XPos,Y
                BCC     loc_3B5E

                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                BIT     FRANKENSTEIN_FACEING_LEFT
                BEQ     _obj_Frankenstein_Execute_nextPlayer
                JMP     _obj_Frankenstein_Execute_wakeUpFrankenstein
; ---------------------------------------------------------------------------

loc_3B5E:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                BIT     FRANKENSTEIN_FACEING_LEFT
                BEQ     _obj_Frankenstein_Execute_wakeUpFrankenstein

_obj_Frankenstein_Execute_nextPlayer:
                DEC     _obj_Frankenstein_Execute_playerIndex
                BPL     _obj_Frankenstein_Execute_playerLoop
                JMP     _obj_Frankenstein_Sprite_Execute_return
; ---------------------------------------------------------------------------

_obj_Frankenstein_Execute_wakeUpFrankenstein:
                ORA     FRANKENSTEIN_AWAKE
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                LDY     #CreepObj_Frankenstein::Flags
                STA     (mVObjectPtr),Y
                LDA     #JOYSTICK_DIRECTION::NOTHING
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                LDA     #SOUND_EFFECT::FRANKENSTEIN_WAKEUP
                JSR     SND_PlayEffect

_obj_Frankenstein_Execute_player_FrankensteinIsAwake:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorNextState,X ; Additional sprite depended data
                CMP     #$FF
                BEQ     loc_3B91
                CMP     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorCurrentState,X ; Additional sprite depended data
                BEQ     loc_3B91
                JSR     obj_TrapDoor_Switch_Trigger ; Check switch for trapdoor #A and trigger, if necessary

loc_3B91:
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorCurrentState,X ; Additional sprite depended data
                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorNextState,X ; Additional sprite depended data

                JSR     CalcScreenDirectionAddrForSprite ; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                STA     _obj_Frankenstein_Execute_dirAllow
                LDA     #DIR_ALLOW::UP|DIR_ALLOW::UP_RIGHT|DIR_ALLOW::RIGHT|DIR_ALLOW::DOWN_RIGHT|DIR_ALLOW::DOWN|DIR_ALLOW::DOWN_LEFT|DIR_ALLOW::LEFT|DIR_ALLOW::UP_LEFT
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                LDA     _obj_Frankenstein_Execute_dirAllow
                BNE     loc_3BB8
                LDA     #JOYSTICK_DIRECTION::NOTHING
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                JMP     loc_3CB4
; ---------------------------------------------------------------------------

loc_3BB8:
                LDY     #6
                LDA     #0
                STA     _obj_Frankenstein_Execute_playerIndex

loc_3BBF:
                LDA     BITMASK_01__80,Y
                BIT     _obj_Frankenstein_Execute_dirAllow
                BEQ     loc_3BCD
                INC     _obj_Frankenstein_Execute_playerIndex
                STY     _obj_Frankenstein_Execute_direction

loc_3BCD:
                DEY
                DEY
                BPL     loc_3BBF

                LDA     _obj_Frankenstein_Execute_playerIndex
                CMP     #1
                BNE     loc_3BE1
                LDA     _obj_Frankenstein_Execute_direction
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                JMP     loc_3CB4
; ---------------------------------------------------------------------------

loc_3BE1:
                CMP     #2
                BNE     loc_3C06

                LDA     _obj_Frankenstein_Execute_direction
                SEC
                SBC     #JOYSTICK_DIRECTION::DOWN  ; Invert up/down direction
                AND     #%111
                TAY
                LDA     BITMASK_01__80,Y
                BIT     _obj_Frankenstein_Execute_dirAllow
                BEQ     loc_3C06
                LDY     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                BMI     loc_3C06
                LDA     BITMASK_01__80,Y
                BIT     _obj_Frankenstein_Execute_dirAllow
                BEQ     loc_3C06
                JMP     loc_3CB4
; ---------------------------------------------------------------------------

loc_3C06:
                LDA     #$FF
                LDY     #CreepFrankensteinPlayerDelta::negativeX

loc_3C0A:
                STA     _obj_Frankenstein_Execute_offsetDelta,Y
                DEY
                BPL     loc_3C0A
                LDA     #1
                STA     _obj_Frankenstein_Execute_playerIndex

_obj_Frankenstein_Sprite_Execute_playerLoop:
                LDY     _obj_Frankenstein_Execute_playerIndex
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     loc_3C62
                LDA     obj_Player_Execute_playerSpriteNumber,Y
                TAY
                SEC
                LDA     mSprites + CreepSprite::XPos,Y
                SBC     mSprites + CreepSprite::XPos,X
                BCS     loc_3C35
                EOR     #$FF            ; abs(A)
                ADC     #1
                LDY     #CreepFrankensteinPlayerDelta::negativeX
                JMP     loc_3C37
; ---------------------------------------------------------------------------

loc_3C35:
                LDY     #CreepFrankensteinPlayerDelta::positiveX

loc_3C37:
                CMP     _obj_Frankenstein_Execute_offsetDelta,Y
                BCS     loc_3C3F
                STA     _obj_Frankenstein_Execute_offsetDelta,Y

loc_3C3F:
                LDY     _obj_Frankenstein_Execute_playerIndex
                LDA     obj_Player_Execute_playerSpriteNumber,Y
                TAY
                SEC
                LDA     mSprites + CreepSprite::YPos,Y
                SBC     mSprites + CreepSprite::YPos,X
                BCS     loc_3C58
                EOR     #$FF            ; abs(A)
                ADC     #1
                LDY     #CreepFrankensteinPlayerDelta::negativeY
                JMP     loc_3C5A
; ---------------------------------------------------------------------------

loc_3C58:
                LDY     #CreepFrankensteinPlayerDelta::postiveY

loc_3C5A:
                CMP     _obj_Frankenstein_Execute_offsetDelta,Y
                BCS     loc_3C62
                STA     _obj_Frankenstein_Execute_offsetDelta,Y

loc_3C62:
                DEC     _obj_Frankenstein_Execute_playerIndex
                BPL     _obj_Frankenstein_Sprite_Execute_playerLoop

                LDA     #$FF
                STA     _obj_Frankenstein_Execute_minDelta

loc_3C6C:
                LDA     #0
                STA     _obj_Frankenstein_Execute_maxDelta
                LDA     #$FF
                STA     _obj_Frankenstein_Execute_deltaIndex
                LDY     #CreepFrankensteinPlayerDelta::negativeX

loc_3C78:
                LDA     _obj_Frankenstein_Execute_offsetDelta,Y
                CMP     _obj_Frankenstein_Execute_minDelta
                BCS     loc_3C8B
                CMP     _obj_Frankenstein_Execute_maxDelta
                BCC     loc_3C8B
                STA     _obj_Frankenstein_Execute_maxDelta
                STY     _obj_Frankenstein_Execute_deltaIndex

loc_3C8B:
                DEY
                BPL     loc_3C78

                LDA     _obj_Frankenstein_Execute_deltaIndex
                CMP     #$FF
                BNE     loc_3C9D
                LDA     #JOYSTICK_DIRECTION::NOTHING
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                JMP     loc_3CB4
; ---------------------------------------------------------------------------

loc_3C9D:
                ASL     A
                TAY
                LDA     BITMASK_01__80,Y
                BIT     _obj_Frankenstein_Execute_dirAllow
                BNE     loc_3CB0
                LDA     _obj_Frankenstein_Execute_maxDelta
                STA     _obj_Frankenstein_Execute_minDelta
                JMP     loc_3C6C
; ---------------------------------------------------------------------------

loc_3CB0:
                TYA
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data

loc_3CB4:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                AND     #JOYSTICK_DIRECTION::RIGHT
                BEQ     loc_3CFB
                SEC
                LDA     mSprites + CreepSprite::YPos,X
                SBC     CalcScreenDirectionAddrForSprite_Bottom_subpixel
                STA     mSprites + CreepSprite::YPos,X
                INC     mSprites + CreepSprite::gfxID,X

                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                CMP     #JOYSTICK_DIRECTION::RIGHT
                BEQ     loc_3CE5
                DEC     mSprites + CreepSprite::XPos,X

                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::frankenstein_left_1
                BCC     loc_3CDD
                CMP     #GfxID::frankenstein_slide
                BCC     _obj_Frankenstein_Sprite_Execute_updateSprite

loc_3CDD:
                LDA     #GfxID::frankenstein_left_1
                STA     mSprites + CreepSprite::gfxID,X
                JMP     _obj_Frankenstein_Sprite_Execute_updateSprite
; ---------------------------------------------------------------------------

loc_3CE5:
                INC     mSprites + CreepSprite::XPos,X

                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::frankenstein_right_1
                BCC     loc_3CF3
                CMP     #GfxID::frankenstein_left_1
                BCC     _obj_Frankenstein_Sprite_Execute_updateSprite

loc_3CF3:
                LDA     #GfxID::frankenstein_right_1
                STA     mSprites + CreepSprite::gfxID,X
                JMP     _obj_Frankenstein_Sprite_Execute_updateSprite
; ---------------------------------------------------------------------------

loc_3CFB:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                BMI     obj_Frankenstein_Sprite_Execute_noMovement ; Bit 7 set? => no movement
                SEC
                LDA     mSprites + CreepSprite::XPos,X
                SBC     CalcScreenDirectionAddrForSprite_Left_subpixel
                STA     mSprites + CreepSprite::XPos,X
                INC     mSprites + CreepSprite::XPos,X
                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #DIR_ALLOW::UP
                BNE     loc_3D26
                LDA     #GfxID::frankenstein_slide
                STA     mSprites + CreepSprite::gfxID,X
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     #2
                STA     mSprites + CreepSprite::YPos,X
                JMP     _obj_Frankenstein_Sprite_Execute_updateSprite
; ---------------------------------------------------------------------------

loc_3D26:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                BNE     loc_3D37
                SEC
                LDA     mSprites + CreepSprite::YPos,X
                SBC     #2
                STA     mSprites + CreepSprite::YPos,X
                JMP     loc_3D40
; ---------------------------------------------------------------------------

loc_3D37:
                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     #2
                STA     mSprites + CreepSprite::YPos,X

loc_3D40:
                LDA     mSprites + CreepSprite::YPos,X
                AND     #%110
                LSR     A
                CLC
                ADC     #GfxID::frankenstein_climb_ladder_1
                STA     mSprites + CreepSprite::gfxID,X

_obj_Frankenstein_Sprite_Execute_updateSprite:
                JSR     Sprite_Update

obj_Frankenstein_Sprite_Execute_noMovement:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data
                LDY     #CreepObj_Frankenstein::frankensteinDirection
                STA     (mVObjectPtr),Y
                LDA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Frankenstein::frankensteinXPos
                STA     (mVObjectPtr),Y
                LDA     mSprites + CreepSprite::YPos,X
                LDY     #CreepObj_Frankenstein::frankensteinYPos
                STA     (mVObjectPtr),Y
                LDA     mSprites + CreepSprite::gfxID,X
                LDY     #CreepObj_Frankenstein::frankensteinGfxID
                STA     (mVObjectPtr),Y

_obj_Frankenstein_Sprite_Execute_return:
                JMP     Sprite_Execute_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Frankenstein_Sprite_ObjectCollision
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCC     loc_3D85

loc_3D7D:
                LDA     #0
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision
                JMP     obj_Frankenstein_Collision__return
; ---------------------------------------------------------------------------

loc_3D85:
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR
                BEQ     loc_3DA1
                LDA     #0
                STA     Sprite_Object_Collision_DieFlag ; 0 = Object survives collision, 1 = Object will die after collision
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::TRAPDOOR_SWITCH
                BNE     obj_Frankenstein_Collision__return
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,Y
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorNextState,X ; Additional sprite depended data
                JMP     obj_Frankenstein_Collision__return
; ---------------------------------------------------------------------------

loc_3DA1:
                CLC
                LDA     obj_TrapDoor_Ptr
                ADC     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,Y
                STA     mVObjectPtr
                LDA     obj_TrapDoor_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Trapdoor::Flags
                LDA     (mVObjectPtr),Y
                BIT     TRAPDOOR_OPEN
                BEQ     loc_3D7D

                CLC
                LDA     obj_Frankenstein_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Frankenstein::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Frankenstein_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Trapdoor::Flags
                LDA     FRANKENSTEIN_AWAKE
                EOR     #%11111111
                AND     (mVObjectPtr),Y
                ORA     FRANKENSTEIN_IS_DEAD
                STA     (mVObjectPtr),Y
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data

obj_Frankenstein_Collision__return:
                JMP     Sprite_Object_Collision_Check_nextObj
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Frankenstein_Sprite_SpriteCollision
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                BIT     FRANKENSTEIN_AWAKE
                BEQ     _obj_Frankenstein_Sprite_Collision_noCollision
                LDA     mSprites + CreepSprite::spriteType,Y
                BEQ     _obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #SPRITE_TYPE::FORCEFIELD
                BEQ     _obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #SPRITE_TYPE::MUMMY
                BEQ     _obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #SPRITE_TYPE::FRANKENSTEIN
                BEQ     loc_3E18

                CLC
                LDA     obj_Frankenstein_Ptr
                ADC     mSprites + CreepSprite::data + CreepSprite_Frankenstein::id,X ; Additional sprite depended data
                STA     mVObjectPtr
                LDA     obj_Frankenstein_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Frankenstein::Flags
                LDA     FRANKENSTEIN_AWAKE
                EOR     #%11111111
                AND     (mVObjectPtr),Y
                ORA     FRANKENSTEIN_IS_DEAD
                STA     (mVObjectPtr),Y
                JMP     obj_Frankenstein_Sprite_Collision_return
; ---------------------------------------------------------------------------

loc_3E18:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::frankenstein_slide
                BCC     loc_3E4E
                CMP     #GfxID::frankenstein_sleep
                BCS     loc_3E4E
                LDA     mSprites + CreepSprite::gfxID,Y
                CMP     #GfxID::frankenstein_slide
                BCC     obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #GfxID::frankenstein_sleep
                BCS     obj_Frankenstein_Sprite_Collision_noCollision
                LDA     mSprites + CreepSprite::YPos,X
                CMP     mSprites + CreepSprite::YPos,Y
                BEQ     obj_Frankenstein_Sprite_Collision_noCollision
                BCS     loc_3E43
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                AND     #(~DIR_ALLOW::DOWN & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                JMP     obj_Frankenstein_Sprite_Collision_noCollision
; ---------------------------------------------------------------------------

loc_3E43:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                AND     #(~DIR_ALLOW::UP & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data

_obj_Frankenstein_Sprite_Collision_noCollision:
                JMP     obj_Frankenstein_Sprite_Collision_noCollision
; ---------------------------------------------------------------------------

loc_3E4E:       LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::frankenstein_right_1
                BCC     obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #GfxID::frankenstein_slide
                BCS     obj_Frankenstein_Sprite_Collision_noCollision
                LDA     mSprites + CreepSprite::gfxID,Y
                CMP     #GfxID::frankenstein_right_1
                BCC     obj_Frankenstein_Sprite_Collision_noCollision
                CMP     #GfxID::frankenstein_slide
                BCS     obj_Frankenstein_Sprite_Collision_noCollision
                LDA     mSprites + CreepSprite::XPos,X
                CMP     mSprites + CreepSprite::XPos,Y
                BCS     loc_3E77
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                AND     #(~DIR_ALLOW::RIGHT & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                JMP     obj_Frankenstein_Sprite_Collision_noCollision
; ---------------------------------------------------------------------------

loc_3E77:
                LDA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                AND     #(~DIR_ALLOW::LEFT & $FF)
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data

obj_Frankenstein_Sprite_Collision_noCollision:
                LDA     #0
                STA     Sprite_Collision_DieFlag ; 0 = Sprite survives collision, 1 = Sprite will die after collision

obj_Frankenstein_Sprite_Collision_return:
                JMP     Sprite_Collision_next
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Frankenstein_Sprite_Create
                PHA
                TYA
                PHA
                TXA
                PHA
                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                BIT     FRANKENSTEIN_IS_DEAD
                BNE     obj_Frankenstein_Sprite_Create_return

                JSR     Sprite_Create
                LDA     #SPRITE_TYPE::FRANKENSTEIN
                STA     mSprites + CreepSprite::spriteType,X
                LDA     mFrankensteinObjectNumber
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::id,X ; Additional sprite depended data

                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::flags,X ; Additional sprite depended data
                BIT     FRANKENSTEIN_AWAKE
                BNE     loc_3EC8
                LDY     #CreepObj_Frankenstein::XPos
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Frankenstein::YPos
                LDA     (object_Ptr),Y
                CLC
                ADC     #7
                STA     mSprites + CreepSprite::YPos,X
                LDA     #GfxID::frankenstein_sleep
                STA     mSprites + CreepSprite::gfxID,X
                JMP     loc_3EE4
; ---------------------------------------------------------------------------

loc_3EC8:
                LDY     #CreepObj_Frankenstein::frankensteinXPos
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::XPos,X
                LDY     #CreepObj_Frankenstein::frankensteinYPos
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::YPos,X
                LDY     #CreepObj_Frankenstein::frankensteinGfxID
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::gfxID,X
                LDY     #CreepObj_Frankenstein::frankensteinDirection
                LDA     (object_Ptr),Y
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::direction,X ; Additional sprite depended data

loc_3EE4:
                LDA     #3
                STA     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                LDA     #17
                STA     mSprites + CreepSprite::yOffset,X ; Y-Offset to define the baseline of the sprite
                JSR     Sprite_Update

                LDA     #$FF
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::dirAllow,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorCurrentState,X ; Additional sprite depended data
                STA     mSprites + CreepSprite::data + CreepSprite_Frankenstein::trapdoorNextState,X ; Additional sprite depended data
                LDA     #2
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                STA     mSprites + CreepSprite::phase_counter,X ; Only execute background collision and execute function at phase 0

obj_Frankenstein_Sprite_Create_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Frankenstein_Execute_playerIndex:.BYTE $85
_obj_Frankenstein_Execute_direction:.BYTE $A0
_obj_Frankenstein_Execute_offsetDelta: _CreepFrankensteinPlayerDelta $A5,$C4,$85,$C1
_obj_Frankenstein_Execute_minDelta:.BYTE $BA
_obj_Frankenstein_Execute_maxDelta:.BYTE $C9
_obj_Frankenstein_Execute_deltaIndex:.BYTE $A0
_obj_Frankenstein_Execute_dirAllow:.BYTE $85

; =============== S U B R O U T I N E =======================================


.proc Sprite_Create
                PHA
                TYA
                PHA
                LDX     #0
Sprite_CreepGetFree_loop:
                LDA     mSprites + CreepSprite::state,X
                BIT     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                BNE     Sprite_CreepGetFree_foundSlot
                TXA
                CLC
                ADC     #.SIZEOF(CreepSprite)
                TAX
                BNE     Sprite_CreepGetFree_loop
                SEC
                JMP     Sprite_CreepGetFree_return
; ---------------------------------------------------------------------------

Sprite_CreepGetFree_foundSlot:
                LDY     #.SIZEOF(CreepSprite)
                LDA     #0

Sprite_CreepGetFree_clrStruct:
                STA     mSprites,X
                INX
                DEY
                BNE     Sprite_CreepGetFree_clrStruct
                TXA
                SEC
                SBC     #.SIZEOF(CreepSprite)
                TAX
                LDA     SPRITE_FLAGS_CREATED ; Sprite was just created, reset during the first execute call
                STA     mSprites + CreepSprite::state,X
                LDA     #1
                STA     mSprites + CreepSprite::phase_counter,X ; Only execute background collision and execute function at phase 0
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation
                CLC

Sprite_CreepGetFree_return:
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


Object_Execute:
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #0
                STA     _Object_Execute_Index

Object_Execute_loop:
                LDA     _Object_Execute_Index
                CMP     OBJECT_COUNT
                BCC     loc_3F64
                JMP     Object_Execute_return
; ---------------------------------------------------------------------------

loc_3F64:
                ASL     A
                ASL     A
                ASL     A
                TAX
                LDA     mObjects + CreepObject::flags,X
                BIT     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                BEQ     Object_Execute_dontExec

                LDA     mObjects + CreepObject::objectType,X
                ASL     A
                ASL     A
                TAY
                LDA     ObjectType_Table,Y
                STA     loc_3F84+1
                LDA     ObjectType_Table+1,Y
                STA     loc_3F84+2
                BEQ     Object_Execute_disableExec

loc_3F84:
                JMP     loc_3F84+1
; ---------------------------------------------------------------------------

Object_Execute_nextObject:
                JMP     loc_3F93
; ---------------------------------------------------------------------------

Object_Execute_disableExec:
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; no executable function => clear the flag
                STA     mObjects + CreepObject::flags,X

loc_3F93:
                LDA     mObjects + CreepObject::flags,X

Object_Execute_dontExec:
                BIT     OBJECT_DELETE   ; Delete the object, e.g. after a key was picked
                BEQ     Object_Execute_nextObj

                JSR     Object_setInvisible
                DEC     OBJECT_COUNT
                LDA     OBJECT_COUNT
                ASL     A
                ASL     A
                ASL     A
                STA     loc_3FAA+1

loc_3FAA:
                CPX     #0
                BEQ     Object_Execute_return
                TAY
                LDA     #.SIZEOF(CreepObject)
                STA     _Object_Execute_ObjectSizeCounter

loc_3FB4:
                LDA     mObjects,Y
                STA     mObjects,X
                LDA     mObjectsVars,Y
                STA     mObjectsVars,X
                INX
                INY
                DEC     _Object_Execute_ObjectSizeCounter
                BNE     loc_3FB4

Object_Execute_nextObj:
                INC     _Object_Execute_Index
                JMP     Object_Execute_loop
; ---------------------------------------------------------------------------

Object_Execute_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_Object_Execute_ObjectSizeCounter:.BYTE $D8
_Object_Execute_Index:.BYTE $84

; =============== S U B R O U T I N E =======================================


.proc obj_Door_Object_Execute
                LDA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,X
                BNE     loc_4017
                LDA     #1
                STA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,X
                LDA     #14
                STA     mObjectsVars + CreepObjectVars_Door::openingCount,X

                LDA     mObjectsVars + CreepObjectVars_Door::id,X
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     _obj_Door_Object_Setup_RoomDoorPtr
                STA     mVObjectPtr
                LDA     _obj_Door_Object_Setup_RoomDoorPtr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Door::Flags
                LDA     (mVObjectPtr),Y
                ORA     #DOOR_FLAGS::ISOPEN
                STA     (mVObjectPtr),Y
                LDY     #CreepObj_Door::DestinationDoor
                LDA     (mVObjectPtr),Y
                PHA
                LDY     #CreepObj_Door::DestinationRoom
                LDA     (mVObjectPtr),Y
                JSR     GAME_selectRoom ; Set roomPtr to room # in A
                PLA
                JSR     GAME_selectDoor ; Select door #A in the current room

                LDY     #CreepObj_Door::Flags
                LDA     (mVObjectPtr),Y
                ORA     #DOOR_FLAGS::ISOPEN
                STA     (mVObjectPtr),Y

loc_4017:
                SEC
                LDA     #SID_NOTE::E1
                SBC     mObjectsVars + CreepObjectVars_Door::openingCount,X
                STA     SNDEFFECT_DOOR_OPEN_NOTE
                LDA     #SOUND_EFFECT::DOOR_OPEN
                JSR     SND_PlayEffect

                LDA     mObjectsVars + CreepObjectVars_Door::openingCount,X
                BEQ     loc_404A
                DEC     mObjectsVars + CreepObjectVars_Door::openingCount,X

                CLC
                ADC     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Mask_Top
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Mask_Left
                LDA     #GfxID::door
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                JMP     obj_Door_Execute_return
; ---------------------------------------------------------------------------

loc_404A:
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X
                LDY     #5
                LDA     mObjectsVars + CreepObjectVars_Door::color,X

loc_4058:
                STA     SPRITE_diagonal_exit_path_COLOR,Y
                DEY
                BPL     loc_4058
                LDA     #GfxID::diagonal_exit_path
                STA     DRAW_Image_Foreground_GfxID
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Foreground_Top
                JSR     Object_Redraw

obj_Door_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Door_Object_ObjectCollision
                STY     _obj_Door_Object_ObjectCollision_Y
                LDA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,Y
                BEQ     loc_4082
                LDA     mSprites + CreepSprite::spriteType,X
                BEQ     loc_4085

loc_4082:
                JMP     obj_Door_InFront_return
; ---------------------------------------------------------------------------

loc_4085:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                CMP     #JOYSTICK_DIRECTION::UP_RIGHT
                BNE     obj_Door_InFront_return
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Door_InFront_return

                LDA     #PLAYER_STATE::START_MOVE_IN_OUT ; Start moving in or out transition to/from a room
                STA     CASTLE + CreepCastle::playerState,Y
                LDA     #0              ; Leave room transition
                STA     mSprites + CreepSprite::data + CreepSprite_Player::exitEntryAnimState,X ; Additional sprite depended data
                LDA     #3
                STA     mSprites + CreepSprite::anim_phases,X ; Number of phases for the animation

                LDY     _obj_Door_Object_ObjectCollision_Y
                LDA     mObjectsVars + CreepObjectVars_Door::id,Y
                ASL     A
                ASL     A
                ASL     A
                CLC
                ADC     _obj_Door_Object_Setup_RoomDoorPtr
                STA     mVObjectPtr
                LDA     _obj_Door_Object_Setup_RoomDoorPtr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Door::YPos
                CLC
                LDA     (mVObjectPtr),Y
                ADC     #15
                STA     mSprites + CreepSprite::YPos,X
                LDY     #CreepObj_Door::XPos
                CLC
                LDA     (mVObjectPtr),Y
                ADC     #6
                STA     mSprites + CreepSprite::XPos,X

                LDY     #CreepObj_Door::Typ
                LDA     (mVObjectPtr),Y
                BEQ     loc_40DD
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     #1
                STA     CASTLE + CreepCastle::playerHasEscaped,Y

loc_40DD:
                LDY     #CreepObj_Door::DestinationDoor
                LDA     (mVObjectPtr),Y
                STA     _obj_Door_Object_ObjectCollision_playerDoor
                LDY     #CreepObj_Door::DestinationRoom
                LDA     (mVObjectPtr),Y
                STA     _obj_Door_Object_ObjectCollision_playerRoom
                JSR     GAME_selectRoom ; Set roomPtr to room # in A

                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                ORA     MAP_ROOM_VISIBLE
                STA     (mRoomPtr),Y

                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     _obj_Door_Object_ObjectCollision_playerRoom
                STA     CASTLE + CreepCastle::playerCurrentRoom,Y
                LDA     _obj_Door_Object_ObjectCollision_playerDoor
                STA     CASTLE + CreepCastle::playerCurrentDoor,Y

obj_Door_InFront_return:
                LDY     _obj_Door_Object_ObjectCollision_Y
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_Door_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDY     #0
                LDA     (object_Ptr),Y
                STA     _obj_Door_Object_Setup_DoorCount
                INC     object_Ptr
                BNE     loc_411E
                INC     object_Ptr+1

loc_411E:
                LDA     object_Ptr
                STA     _obj_Door_Object_Setup_RoomDoorPtr
                LDA     object_Ptr+1
                STA     _obj_Door_Object_Setup_RoomDoorPtr+1
                LDA     #0
                STA     _obj_Door_Object_Setup_DoorIndex

loc_412D:
                LDA     _obj_Door_Object_Setup_DoorIndex
                CMP     _obj_Door_Object_Setup_DoorCount
                BNE     loc_4138
                JMP     _obj_Door_Object_Setup_return
; ---------------------------------------------------------------------------

loc_4138:
                LDY     #CreepObj_Door::Typ
                LDA     (object_Ptr),Y
                TAX
                LDA     _obj_Door_Object_Setup_DoorOrHouseTable,X
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Door::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Door::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #16
                STA     DRAW_Image_Foreground_Top
                LDA     _obj_Door_Object_Setup_DoorIndex
                STA     mObjectsVars + CreepObjectVars_Door::id,X
                LDA     #OBJECT_TYPE::DOOR
                STA     mObjects + CreepObject::objectType,X

                LDY     #CreepObj_Door::DestinationRoom
                LDA     (object_Ptr),Y
                JSR     GAME_selectRoom ; Set roomPtr to room # in A
                LDY     #CreepRoom::flagsColor ; Bit 0-3: color, Bit 6: end of room list, Bit 7: room visible
                LDA     (mRoomPtr),Y
                AND     #%1111
                STA     mObjectsVars + CreepObjectVars_Door::color,X
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                ORA     mObjectsVars + CreepObjectVars_Door::color,X
                STA     mObjectsVars + CreepObjectVars_Door::color,X

                LDY     #CreepObj_Door::Flags
                LDA     (object_Ptr),Y
                AND     #DOOR_FLAGS::ISOPEN
                BNE     loc_41A0
                LDA     #GfxID::metal_gate
                JMP     loc_41B2
; ---------------------------------------------------------------------------

loc_41A0:
                LDA     #1
                STA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,X
                LDY     #5
                LDA     mObjectsVars + CreepObjectVars_Door::color,X

loc_41AA:
                STA     SPRITE_diagonal_exit_path_COLOR,Y
                DEY
                BPL     loc_41AA
                LDA     #GfxID::diagonal_exit_path

loc_41B2:
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Door)
                STA     object_Ptr
                BCC     loc_41C3
                INC     object_Ptr+1

loc_41C3:
                INC     _obj_Door_Object_Setup_DoorIndex
                JMP     loc_412D
; ---------------------------------------------------------------------------

_obj_Door_Object_Setup_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Door_Object_Setup_DoorIndex:.BYTE $A0
_obj_Door_Object_Setup_DoorCount:.BYTE $A0
_obj_Door_Object_Setup_DoorOrHouseTable:.BYTE GfxID::exit,GfxID::house
_obj_Door_Object_Setup_RoomDoorPtr:.addr $B4AC
_obj_Door_Object_ObjectCollision_Y:.BYTE $A0
_obj_Door_Object_ObjectCollision_playerRoom:.BYTE $9E
_obj_Door_Object_ObjectCollision_playerDoor:.BYTE $A0

; =============== S U B R O U T I N E =======================================


.proc obj_DoorBell_Object_ObjectCollision
                STX     _obj_DoorBell_Object_ObjectCollision_X
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Door_Button_InFront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     obj_Door_Button_InFront_return
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #12
                BCS     obj_Door_Button_InFront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                TAX
                LDA     CASTLE + CreepCastle::playerState,X
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Door_Button_InFront_return
                LDX     #0

loc_4201:
                LDA     mObjects + CreepObject::objectType,X
                BNE     loc_420E        ; not a Door? =>
                LDA     mObjectsVars + CreepObjectVars_Door::id,X
                CMP     mObjectsVars + CreepObjectVars_Doorbell::keyId,Y
                BEQ     loc_4216

loc_420E:
                CLC
                TXA
                ADC     #.SIZEOF(CreepObject)
                TAX
                JMP     loc_4201
; ---------------------------------------------------------------------------

loc_4216:
                LDA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,X
                BNE     obj_Door_Button_InFront_return
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

obj_Door_Button_InFront_return:
                LDX     _obj_DoorBell_Object_ObjectCollision_X
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================

.proc obj_DoorBell_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDY     #0
                LDA     (object_Ptr),Y
                STA     _obj_DoorBell_Setup_ButtonCount
                INC     object_Ptr
                BNE     loc_423C
                INC     object_Ptr+1

loc_423C:
                LDA     _obj_DoorBell_Setup_ButtonCount
                BEQ     obj_Door_Button_Prepare_return

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::DOORBELL
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_DoorBell::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_DoorBell::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::button
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_DoorBell::doorNumber
                LDA     (object_Ptr),Y
                STA     mObjectsVars + CreepObjectVars_Doorbell::keyId,X
                LDY     #0

loc_4265:
                LDA     mObjects + CreepObject::objectType,Y
                BNE     loc_4278        ; not a Door? =>
                LDA     mObjectsVars + CreepObjectVars_Door::id,Y
                CMP     mObjectsVars + CreepObjectVars_Doorbell::keyId,X
                BNE     loc_4278
                LDA     mObjectsVars + CreepObjectVars_Door::color,Y
                JMP     loc_4280
; ---------------------------------------------------------------------------

loc_4278:
                TYA
                CLC
                ADC     #.SIZEOF(CreepObject)
                TAY
                JMP     loc_4265
; ---------------------------------------------------------------------------

loc_4280:
                LDY     #8

loc_4282:
                STA     OBJECT_button_COLOR,Y
                DEY
                BPL     loc_4282
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                ORA     #(COLOR::WHITE<<4)+COLOR::BLACK
                STA     OBJECT_button_COLOR+4
                JSR     Object_Redraw

                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_DoorBell)
                STA     object_Ptr
                BCC     loc_429F
                INC     object_Ptr+1

loc_429F:
                DEC     _obj_DoorBell_Setup_ButtonCount
                JMP     loc_423C
; ---------------------------------------------------------------------------

obj_Door_Button_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_DoorBell_Setup_ButtonCount:.BYTE $A0
_obj_DoorBell_Object_ObjectCollision_X:.BYTE $FF

; =============== S U B R O U T I N E =======================================


.proc obj_LightningMachine_Object_Execute
                CLC
                LDA     obj_Lightning_Ptr
                ADC     mObjectsVars + CreepObjectVars_LightningMachine::id,X
                STA     mVObjectPtr
                LDA     obj_Lightning_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mObjectsVars + CreepObjectVars_LightningMachine::lightningIsActive,X ; Lightning flash sprite is on
                CMP     #1
                BEQ     loc_42CF
                LDA     #1
                STA     mObjectsVars + CreepObjectVars_LightningMachine::lightningIsActive,X ; Lightning flash sprite is on
                JSR     obj_Lightning_Sprite_Create
                JMP     loc_435B
; ---------------------------------------------------------------------------

loc_42CF:
                LDY     #CreepObj_Lightning::Flags
                LDA     (mVObjectPtr),Y
                BIT     LIGHTNING_IS_ON
                BNE     loc_4351

                LDA     #0
                STA     mObjectsVars + CreepObjectVars_LightningMachine::lightningIsActive,X ; Lightning flash sprite is on
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X
                LDA     #(COLOR::GREEN<<4)+COLOR::GREEN
                STA     OBJECT_lightning_colormask_COLOR
                STA     OBJECT_lightning_colormask_COLOR+1

                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDY     #CreepObj_Lightning::XPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Lightning::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::lightning_colormask
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Lightning::Length
                LDA     (mVObjectPtr),Y
                STA     _obj_Lightning_Pole_Execute_Length

obj_Lightning_Pole_Execute_drawPole:
                LDA     _obj_Lightning_Pole_Execute_Length
                BEQ     loc_4324
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     _obj_Lightning_Pole_Execute_Length
                JMP     obj_Lightning_Pole_Execute_drawPole
; ---------------------------------------------------------------------------

loc_4324:
                LDY     #CreepSprite::spriteType

loc_4326:
                LDA     mSprites + CreepSprite::spriteType,Y
                CMP     #SPRITE_TYPE::LIGHTNING
                BNE     loc_433D
                LDA     mSprites + CreepSprite::state,Y
                BIT     SPRITE_FLAGS_UNUSED ; 1, if the sprite slot is unused
                BNE     loc_433D
                LDA     mSprites + CreepSprite::data + CreepSprite_Lightning::id,Y ; Additional sprite depended data
                CMP     mObjectsVars + CreepObjectVars_LightningMachine::id,X
                BEQ     loc_4345

loc_433D:
                TYA
                CLC
                ADC     #.SIZEOF(CreepSprite)
                TAY
                JMP     loc_4326
; ---------------------------------------------------------------------------

loc_4345:
                LDA     mSprites + CreepSprite::state,Y
                ORA     SPRITE_FLAGS_DESTROY ; Sprite to be destroyed, will be freed in the next execute loop
                STA     mSprites + CreepSprite::state,Y
                JMP     obj_Lightning_Pole_Execute_return
; ---------------------------------------------------------------------------

loc_4351:
                LDA     events_Execute_EngineTicks
                AND     #%11
                BEQ     loc_435B
                JMP     obj_Lightning_Pole_Execute_return
; ---------------------------------------------------------------------------

loc_435B:
                INC     mObjectsVars + CreepObjectVars_LightningMachine::phase,X ; Phase 0-2 if lightning machine is active
                LDA     mObjectsVars + CreepObjectVars_LightningMachine::phase,X ; Phase 0-2 if lightning machine is active
                CMP     #3
                BCC     loc_436A
                LDA     #0
                STA     mObjectsVars + CreepObjectVars_LightningMachine::phase,X ; Phase 0-2 if lightning machine is active

loc_436A:
                STA     _obj_Lightning_Pole_Execute_phase

                LDY     #CreepObj_Lightning::XPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Lightning::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::lightning_colormask
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Lightning::Length
                LDA     (mVObjectPtr),Y
                STA     _obj_Lightning_Pole_Execute_Length

obj_Lightning_Pole_Execute_drawAnimPole:
                LDA     _obj_Lightning_Pole_Execute_Length
                BEQ     obj_Lightning_Pole_Execute_return
                LDA     _obj_Lightning_Pole_Execute_phase
                BEQ     obj_Lightning_Pole_Execute_phase_0
                CMP     #1
                BEQ     obj_Lightning_Pole_Execute_phase_1

obj_Lightning_Pole_Execute_phase_2:
                LDA     #(COLOR::BLUE<<4)+COLOR::BLUE
                STA     OBJECT_lightning_colormask_COLOR
                LDA     #COLOR::WHITE
                STA     OBJECT_lightning_colormask_COLOR+1
                JMP     loc_43BE
; ---------------------------------------------------------------------------

obj_Lightning_Pole_Execute_phase_0:
                LDA     #(COLOR::WHITE<<4)+COLOR::BLUE
                STA     OBJECT_lightning_colormask_COLOR
                LDA     #COLOR::BLUE
                STA     OBJECT_lightning_colormask_COLOR+1
                JMP     loc_43BE
; ---------------------------------------------------------------------------

obj_Lightning_Pole_Execute_phase_1:
                LDA     #(COLOR::BLUE<<4)+COLOR::WHITE
                STA     OBJECT_lightning_colormask_COLOR
                LDA     #COLOR::BLUE
                STA     OBJECT_lightning_colormask_COLOR+1

loc_43BE:
                JSR     DRAW_Image

                INC     _obj_Lightning_Pole_Execute_phase
                LDA     _obj_Lightning_Pole_Execute_phase
                CMP     #3
                BCC     loc_43D0
                LDA     #0
                STA     _obj_Lightning_Pole_Execute_phase

loc_43D0:
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     _obj_Lightning_Pole_Execute_Length
                JMP     obj_Lightning_Pole_Execute_drawAnimPole
; ---------------------------------------------------------------------------

obj_Lightning_Pole_Execute_return:
                JMP     Object_Execute_nextObject

; ---------------------------------------------------------------------------
_obj_Lightning_Pole_Execute_Length:.BYTE $A5
_obj_Lightning_Pole_Execute_phase:.BYTE $A0
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_Lightning_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_Lightning_Ptr
                LDA     object_Ptr+1
                STA     obj_Lightning_Ptr+1
                LDA     #0
                STA     _obj_Lightning_Prepare_LightningCount

obj_Lightning_Prepare_loop:
                LDY     #CreepObj_Lightning::Flags
                LDA     (object_Ptr),Y
                BIT     LIGHTNING_END_MARKER
                BEQ     loc_440A
                INC     object_Ptr
                BNE     loc_4407
                INC     object_Ptr+1

loc_4407:
                JMP     obj_Lightning_Prepare_return
; ---------------------------------------------------------------------------

loc_440A:
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     _obj_Lightning_Prepare_LightningCount
                STA     mObjectsVars + CreepObjectVars_LightningMachine::id,X

                LDY     #CreepObj_Lightning::Flags
                LDA     (object_Ptr),Y
                BIT     LIGHTNING_IS_SWITCH
                BEQ     obj_Lightning_Prepare_LightningMachine


obj_Lightning_Prepare_switch:
                LDY     #CreepObj_Lightning::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Lightning::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::lightning_switch
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                LDA     #OBJECT_TYPE::LIGHTNINGMACHINE_SWITCH
                STA     mObjects + CreepObject::objectType,X

                LDY     #CreepObj_Lightning::Flags
                LDA     (object_Ptr),Y
                BIT     LIGHTNING_IS_ON
                BNE     loc_445C
                LDA     #GfxID::lightning_switch_off
                JMP     loc_445E
; ---------------------------------------------------------------------------

loc_445C:
                LDA     #GfxID::lightning_switch_on

loc_445E:
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw
                JMP     obj_Lightning_Prepare_next
; ---------------------------------------------------------------------------

obj_Lightning_Prepare_LightningMachine:
                LDA     #OBJECT_TYPE::LIGHTNINGMACHINE
                STA     mObjects + CreepObject::objectType,X

                LDY     #CreepObj_Lightning::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Lightning::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::lightning_lightning_pole
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Lightning::Length
                LDA     (object_Ptr),Y
                STA     _obj_Lightning_Prepare_Length
                STA     mObjectsVars + CreepObjectVars_LightningMachine::length,X ; Length of the pole of the lightning machine

loc_448E:
                LDA     _obj_Lightning_Prepare_Length
                BEQ     loc_44A5
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     _obj_Lightning_Prepare_Length
                JMP     loc_448E
; ---------------------------------------------------------------------------

loc_44A5:
                SEC
                LDA     DRAW_Image_Foreground_Left
                SBC     #4
                STA     DRAW_Image_Foreground_Left
                LDA     #GfxID::lightning_globe
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                LDY     #CreepObj_Lightning::Flags
                LDA     (object_Ptr),Y
                BIT     LIGHTNING_IS_ON
                BEQ     obj_Lightning_Prepare_next
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

obj_Lightning_Prepare_next:
                CLC
                LDA     _obj_Lightning_Prepare_LightningCount
                ADC     #.SIZEOF(CreepObj_Lightning)
                STA     _obj_Lightning_Prepare_LightningCount
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Lightning)
                STA     object_Ptr
                BCC     loc_44DC
                INC     object_Ptr+1

loc_44DC:
                JMP     obj_Lightning_Prepare_loop
; ---------------------------------------------------------------------------

obj_Lightning_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_obj_Lightning_Prepare_LightningCount:.BYTE $95
_obj_Lightning_Prepare_Length:.BYTE $80
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_LightningMachineSwitch_Object_ObjectCollision
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Lightning_Switch_InFront_return_
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #4
                BCS     obj_Lightning_Switch_InFront_return_
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                BEQ     loc_4507
                CMP     #JOYSTICK_DIRECTION::DOWN
                BEQ     loc_4507

obj_Lightning_Switch_InFront_return_:
                JMP     obj_Lightning_Switch_InFront_return
; ---------------------------------------------------------------------------

loc_4507:
                LDA     #0
                STA     _obj_Lightning_Switch_InFront_index
                CLC
                LDA     obj_Lightning_Ptr
                ADC     mObjectsVars + CreepObjectVars_LightningMachine::id,Y
                STA     PP_A
                LDA     obj_Lightning_Ptr+1
                ADC     #0
                STA     PP_A+1

                STY     _obj_Lightning_Switch_InFront_byte_45D8
                LDY     #CreepObj_Lightning::Flags
                LDA     (PP_A),Y
                BIT     LIGHTNING_IS_ON
                BNE     loc_4530
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                BNE     obj_Lightning_Switch_InFront_return_
                JMP     loc_4535
; ---------------------------------------------------------------------------

loc_4530:
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                BEQ     obj_Lightning_Switch_InFront_return_

loc_4535:
                LDA     (PP_A),Y
                EOR     LIGHTNING_IS_ON
                STA     (PP_A),Y

loc_453C:
                LDA     _obj_Lightning_Switch_InFront_index
                CMP     #4
                BCS     loc_4550
                CLC
                LDA     #CreepObj_Lightning::switchedIds
                ADC     _obj_Lightning_Switch_InFront_index
                TAY
                LDA     (PP_A),Y
                CMP     #$FF
                BNE     loc_4553

loc_4550:
                JMP     loc_4594
; ---------------------------------------------------------------------------

loc_4553:
                STA     _obj_Lightning_Switch_InFront_id
                CLC
                ADC     obj_Lightning_Ptr
                STA     PP_B
                LDA     obj_Lightning_Ptr+1
                ADC     #0
                STA     PP_B+1
                LDY     #CreepObj_Lightning::Flags
                LDA     (PP_B),Y
                EOR     LIGHTNING_IS_ON
                STA     (PP_B),Y
                LDY     #0

loc_456E:
                LDA     mObjects + CreepObject::objectType,Y
                CMP     #OBJECT_TYPE::LIGHTNINGMACHINE
                BNE     loc_457D
                LDA     mObjectsVars + CreepObjectVars_LightningMachine::id,Y
                CMP     _obj_Lightning_Switch_InFront_id
                BEQ     loc_4585

loc_457D:
                TYA
                CLC
                ADC     #.SIZEOF(CreepObject)
                TAY
                JMP     loc_456E
; ---------------------------------------------------------------------------

loc_4585:
                LDA     mObjects + CreepObject::flags,Y
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,Y
                INC     _obj_Lightning_Switch_InFront_index
                JMP     loc_453C
; ---------------------------------------------------------------------------

loc_4594:
                LDY     #CreepObj_Lightning::Flags
                LDA     (PP_A),Y
                BIT     LIGHTNING_IS_ON
                BNE     loc_45A7
                LDA     #SID_NOTE::B3
                STA     SNDEFFECT_LIGHTNING_SWITCHED_NOTE
                LDA     #GfxID::lightning_switch_off
                JMP     loc_45AE
; ---------------------------------------------------------------------------

loc_45A7:
                LDA     #SID_NOTE::B2
                STA     SNDEFFECT_LIGHTNING_SWITCHED_NOTE
                LDA     #GfxID::lightning_switch_on

loc_45AE:
                STA     DRAW_Image_Foreground_GfxID
                LDY     _obj_Lightning_Switch_InFront_byte_45D8
                LDA     mObjects + CreepObject::XPos,Y
                STA     DRAW_Image_Foreground_Left
                LDA     mObjects + CreepObject::YPos,Y
                STA     DRAW_Image_Foreground_Top
                STX     _obj_Lightning_Switch_InFront_byte_45D9
                LDX     _obj_Lightning_Switch_InFront_byte_45D8
                JSR     Object_Redraw

                LDX     _obj_Lightning_Switch_InFront_byte_45D9
                LDY     _obj_Lightning_Switch_InFront_byte_45D8
                LDA     #SOUND_EFFECT::LIGHTNING_SWITCHED
                JSR     SND_PlayEffect

obj_Lightning_Switch_InFront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject

; ---------------------------------------------------------------------------
_obj_Lightning_Switch_InFront_index:.BYTE $99
_obj_Lightning_Switch_InFront_byte_45D8:.BYTE $80
_obj_Lightning_Switch_InFront_byte_45D9:.BYTE $A0
_obj_Lightning_Switch_InFront_id:.BYTE $C8
.endproc
obj_Lightning_Ptr:.addr $CEA0
LIGHTNING_IS_SWITCH:.BYTE $80
LIGHTNING_IS_ON:.BYTE $40
LIGHTNING_END_MARKER:.BYTE $20

; =============== S U B R O U T I N E =======================================


.proc obj_ForcefieldButton_Object_Execute
                DEC     mObjectsVars + CreepObjectVars_Forcefield_Button::timerTicks,X
                BNE     obj_Forcefield_Timer_Execute_return
                DEC     mObjectsVars + CreepObjectVars_Forcefield_Button::remainingTime,X
                LDY     mObjectsVars + CreepObjectVars_Forcefield_Button::remainingTime,X
                LDA     _obj_Forcefield_Timer_Execute_soundFreq,Y
                STA     SNDEFFECT_FORCEFIELD_TIMER_NOTE
                LDA     #SOUND_EFFECT::FORCEFIELD_TIMER
                JSR     SND_PlayEffect
                LDY     #0

loc_45F8:
                TYA
                CMP     mObjectsVars + CreepObjectVars_Forcefield_Button::remainingTime,X
                BCC     loc_4603
                LDA     #%1010101
                JMP     loc_4605
; ---------------------------------------------------------------------------

loc_4603:
                LDA     #%00000000

loc_4605:
                STA     OBJECT_forcefield_progress_IMAGE,Y
                INY
                CPY     #8
                BCC     loc_45F8

                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::forcefield_progress
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     mObjectsVars + CreepObjectVars_Forcefield_Button::remainingTime,X
                BEQ     loc_4633
                LDA     #30
                STA     mObjectsVars + CreepObjectVars_Forcefield_Button::timerTicks,X
                JMP     obj_Forcefield_Timer_Execute_return
; ---------------------------------------------------------------------------

loc_4633:
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X
                LDY     mObjectsVars + CreepObjectVars_Forcefield_Button::id,X
                LDA     #1
                STA     _obj_Forcefield_isActiveFlag,Y

obj_Forcefield_Timer_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_ForcefieldButton_Object_ObjectCollision
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Forcefield_Timer_InFront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     obj_Forcefield_Timer_InFront_return

                LDA     #SID_NOTE::C1
                STA     SNDEFFECT_FORCEFIELD_TIMER_NOTE
                LDA     #SOUND_EFFECT::FORCEFIELD_TIMER
                JSR     SND_PlayEffect

                LDA     mObjects + CreepObject::flags,Y
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,Y
                LDA     #30
                STA     mObjectsVars + CreepObjectVars_Forcefield_Button::timerTicks,Y
                LDA     #8
                STA     mObjectsVars + CreepObjectVars_Forcefield_Button::remainingTime,Y
                LDA     #%1010101
                STA     OBJECT_forcefield_progress_IMAGE
                STA     OBJECT_forcefield_progress_IMAGE+1
                STA     OBJECT_forcefield_progress_IMAGE+2
                STA     OBJECT_forcefield_progress_IMAGE+3
                STA     OBJECT_forcefield_progress_IMAGE+4
                STA     OBJECT_forcefield_progress_IMAGE+5
                STA     OBJECT_forcefield_progress_IMAGE+6
                STA     OBJECT_forcefield_progress_IMAGE+7

                LDA     mObjects + CreepObject::XPos,Y
                STA     DRAW_Image_Mask_Left
                LDA     mObjects + CreepObject::YPos,Y
                STA     DRAW_Image_Mask_Top
                LDA     mObjects + CreepObject::gfxID,Y
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     mObjectsVars + CreepObjectVars_Forcefield_Button::id,Y
                TAY
                LDA     #0
                STA     _obj_Forcefield_isActiveFlag,Y

obj_Forcefield_Timer_InFront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Forcefield_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #0
                STA     obj_Forcefield_Prepare_ForcefieldCount

obj_Forcefield_Prepare_loop:
                LDY     #CreepObj_Forcefield::XPos
                LDA     (object_Ptr),Y
                BNE     loc_46C7
                INC     object_Ptr
                BNE     loc_46C4
                INC     object_Ptr+1

loc_46C4:
                JMP     obj_Forcefield_Prepare_return
; ---------------------------------------------------------------------------

loc_46C7:
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::FORCEFIELD_BUTTON
                STA     mObjects + CreepObject::objectType,X

                LDY     #CreepObj_Forcefield::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Forcefield::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::forcefield_switch
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::forcefield_progress
                STA     DRAW_Image_Foreground_GfxID
                LDY     #7
                LDA     #%01010101

loc_4705:
                STA     OBJECT_forcefield_progress_IMAGE,Y
                DEY
                BPL     loc_4705
                JSR     Object_Redraw

                LDA     obj_Forcefield_Prepare_ForcefieldCount
                STA     mObjectsVars + CreepObjectVars_Forcefield_Button::id,X
                TAY
                LDA     #1
                STA     _obj_Forcefield_isActiveFlag,Y
                JSR     obj_Forcefield_Create_Sprite

                LDY     #CreepObj_Forcefield::XPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Forcefield::YPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::forcefield_gate_top
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                INC     obj_Forcefield_Prepare_ForcefieldCount
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Forcefield)
                STA     object_Ptr
                BCC     loc_4746
                INC     object_Ptr+1

loc_4746:
                JMP     obj_Forcefield_Prepare_loop
; ---------------------------------------------------------------------------

obj_Forcefield_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_Forcefield_Prepare_ForcefieldCount:.BYTE $BA
_obj_Forcefield_isActiveFlag:.BYTE $A0,$A4,$B2,$FE,$A0,$A0
_obj_Forcefield_Timer_Execute_soundFreq:.BYTE SID_NOTE::As4,SID_NOTE::A4,SID_NOTE::G4,SID_NOTE::F4,SID_NOTE::Ds4,SID_NOTE::D4,SID_NOTE::C4,SID_NOTE::As3

; =============== S U B R O U T I N E =======================================


.proc obj_Ankh_Object_Execute
                LDA     events_Execute_EngineTicks
                AND     #%11
                BNE     obj_Mummy_Tomb_Execute_return
                DEC     mObjectsVars + CreepObjectVars_Ankh::awakeningCounter,X
                BNE     loc_4776
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X
                JMP     loc_4782
; ---------------------------------------------------------------------------

loc_4776:
                LDA     mObjectsVars + CreepObjectVars_Ankh::ankh_color,X
                CMP     #(COLOR::BLUE<<4)+COLOR::BLUE
                BNE     loc_4782
                LDA     #(COLOR::WHITE<<4)+COLOR::WHITE
                JMP     loc_4784
; ---------------------------------------------------------------------------

loc_4782:       LDA     #(COLOR::BLUE<<4)+COLOR::BLUE
loc_4784:       LDY     #5
loc_4786:       STA     OBJECT_ankh_COLOR,Y
                DEY
                BPL     loc_4786
                STA     mObjectsVars + CreepObjectVars_Ankh::ankh_color,X

                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Foreground_Top
                LDA     mObjects + CreepObject::gfxID,X
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

obj_Mummy_Tomb_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Ankh_Object_ObjectCollision
                STX     _obj_Ankh_ObjectCollision_saveX
                STY     _obj_Ankh_ObjectCollision_saveY
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     _obj_Ankh_ObjectCollision_return

                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #8
                BCS     _obj_Ankh_ObjectCollision_return

                CLC
                LDA     obj_Mummy_Ptr
                ADC     mObjectsVars + CreepObjectVars_Ankh::id,Y
                STA     mVObjectPtr
                LDA     obj_Mummy_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Mummy::Type
                LDA     (mVObjectPtr),Y
                CMP     #OBJ_MUMMY_STATE::SLEEPING
                BEQ     _obj_Ankh_ObjectCollision_awakeMummy

_obj_Ankh_ObjectCollision_return:
                JMP     _obj_Mummy_Infront_return
; ---------------------------------------------------------------------------

_obj_Ankh_ObjectCollision_awakeMummy:
                LDA     #OBJ_MUMMY_STATE::AWAKE
                LDY     #CreepObj_Mummy::Type
                STA     (mVObjectPtr),Y
                CLC
                LDY     #CreepObj_Mummy::mummyXPos
                LDA     (mVObjectPtr),Y
                ADC     #4
                LDY     #CreepObj_Mummy::savedXPos
                STA     (mVObjectPtr),Y
                CLC
                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (mVObjectPtr),Y
                ADC     #7
                LDY     #CreepObj_Mummy::savedYPos
                STA     (mVObjectPtr),Y
                LDY     _obj_Ankh_ObjectCollision_saveY
                LDA     mObjects + CreepObject::flags,Y
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,Y
                LDA     #8
                STA     mObjectsVars + CreepObjectVars_Ankh::awakeningCounter,Y
                LDA     #(COLOR::BLUE<<4)+COLOR::BLUE
                STA     mObjectsVars + CreepObjectVars_Ankh::ankh_color,Y

                LDY     #CreepObj_Mummy::mummyXPos
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #4
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #8
                STA     DRAW_Image_Mask_Top
                LDA     #3
                STA     _obj_Ankh_Object_ObjectCollision_counter
                LDA     #GfxID::mummy_casket_bricks
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode

loc_4831:
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Mask_Left
                DEC     _obj_Ankh_Object_ObjectCollision_counter
                BNE     loc_4831

                LDA     #GfxID::mummy_casket_open
                STA     DRAW_Image_Foreground_GfxID
                SEC
                LDA     DRAW_Image_Mask_Left
                SBC     #12
                STA     DRAW_Image_Foreground_Left
                LDA     DRAW_Image_Mask_Top
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDX     _obj_Ankh_ObjectCollision_saveY
                LDA     #0
                JSR     obj_Mummy_Sprite_Create

_obj_Mummy_Infront_return:
                LDX     _obj_Ankh_ObjectCollision_saveX
                LDY     _obj_Ankh_ObjectCollision_saveY
                JMP     _Sprite_Object_Collision_Check_nextObject

; ---------------------------------------------------------------------------
_obj_Ankh_ObjectCollision_saveX:.BYTE $FF
_obj_Ankh_ObjectCollision_saveY:.BYTE $A0
_obj_Ankh_Object_ObjectCollision_counter:.BYTE $B5
.endproc

; =============== S U B R O U T I N E =======================================


.proc obj_MummyTomb_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #0
                STA     _obj_Mummy_Prepare_MummyObjectNumber
                LDA     object_Ptr
                STA     obj_Mummy_Ptr
                LDA     object_Ptr+1
                STA     obj_Mummy_Ptr+1

obj_Mummy_Prepare_loop:
                LDY     #CreepObj_Mummy::Type
                LDA     (object_Ptr),Y
                CMP     #OBJ_MUMMY_STATE::END_OF_LIST
                BNE     loc_4897
                INC     object_Ptr
                BNE     loc_4894
                INC     object_Ptr+1

loc_4894:       JMP     obj_Mummy_Prepare_return
; ---------------------------------------------------------------------------

loc_4897:       JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error

                LDA     #OBJECT_TYPE::ANKH
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_Mummy::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Mummy::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::ankh
                STA     DRAW_Image_Foreground_GfxID
                LDA     _obj_Mummy_Prepare_MummyObjectNumber
                STA     mObjectsVars + CreepObjectVars_Ankh::id,X
                LDY     #5
                LDA     #(COLOR::BLUE<<4)+COLOR::BLUE
                STA     mObjectsVars + CreepObjectVars_Ankh::ankh_color,X
loc_48BF:       STA     OBJECT_ankh_COLOR,Y
                DEY
                BPL     loc_48BF
                JSR     Object_Redraw

                LDA     #3
                STA     _obj_Mummy_Prepare_VCount

                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::mummy_casket_bricks
                STA     DRAW_Image_Foreground_GfxID

loc_48DE:       LDA     #5
                STA     _obj_Mummy_Prepare_WCount
                LDY     #CreepObj_Mummy::mummyXPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left

loc_48EA:       JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                DEC     _obj_Mummy_Prepare_WCount
                BNE     loc_48EA
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     _obj_Mummy_Prepare_VCount
                BNE     loc_48DE

                LDY     #CreepObj_Mummy::Type
                LDA     (object_Ptr),Y
                CMP     #OBJ_MUMMY_STATE::SLEEPING
                BEQ     loc_496E

                LDY     #CreepObj_Mummy::mummyXPos
                LDA     (object_Ptr),Y
                CLC
                ADC     #4
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_Mummy::mummyYPos
                LDA     (object_Ptr),Y
                CLC
                ADC     #8
                STA     DRAW_Image_Mask_Top
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                LDA     #GfxID::mummy_casket_bricks
                STA     DRAW_Image_Mask_GfxID
                LDA     #3
                STA     _obj_Mummy_Prepare_VCount

loc_4934:       JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Mask_Left
                DEC     _obj_Mummy_Prepare_VCount
                BNE     loc_4934

                LDA     DRAW_Image_Mask_Left
                SEC
                SBC     #12
                STA     DRAW_Image_Foreground_Left
                LDA     DRAW_Image_Mask_Top
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::mummy_casket_open
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDY     #CreepObj_Mummy::Type
                LDA     (object_Ptr),Y
                CMP     #OBJ_MUMMY_STATE::AWAKE
                BNE     loc_496E
                LDA     #$FF
                JSR     obj_Mummy_Sprite_Create

loc_496E:       LDA     object_Ptr
                CLC
                ADC     #.SIZEOF(CreepObj_Mummy)
                STA     object_Ptr
                BCC     loc_4979
                INC     object_Ptr+1

loc_4979:       CLC
                LDA     _obj_Mummy_Prepare_MummyObjectNumber
                ADC     #.SIZEOF(CreepObj_Mummy)
                STA     _obj_Mummy_Prepare_MummyObjectNumber
                JMP     obj_Mummy_Prepare_loop
; ---------------------------------------------------------------------------

obj_Mummy_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_Mummy_Ptr:  .addr $CCA0
_obj_Mummy_Prepare_MummyObjectNumber:.BYTE $A5
_obj_Mummy_Prepare_VCount:.BYTE $90
_obj_Mummy_Prepare_WCount:.BYTE $A0

; =============== S U B R O U T I N E =======================================


.proc obj_Key_Object_ObjectCollision
                STY     _obj_Key_Infront_pObjectNumber
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Key_Infront_return
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Key_Infront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     obj_Key_Infront_return

                LDA     #SOUND_EFFECT::KEY_PICKUP
                JSR     SND_PlayEffect

                LDY     _obj_Key_Infront_pObjectNumber
                LDA     mObjects + CreepObject::flags,Y
                ORA     OBJECT_DELETE   ; Delete the object, e.g. after a key was picked
                STA     mObjects + CreepObject::flags,Y

                CLC
                LDA     obj_Key_Ptr
                ADC     mObjectsVars + CreepObjectVars_Key::id,Y
                STA     mVObjectPtr
                LDA     obj_Key_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Key::GfxID ; Graphics for the key, 0 = key was picked up
                LDA     #0
                STA     (mVObjectPtr),Y
                LDY     #CreepObj_Key::id
                LDA     (mVObjectPtr),Y
                STA     _obj_Key_InfrontPrepare_KeyID

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                BEQ     loc_49E9
                LDY     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_2
                INC     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_2
                LDA     _obj_Key_InfrontPrepare_KeyID
                STA     CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_2,Y
                JMP     obj_Key_Infront_return
; ---------------------------------------------------------------------------

loc_49E9:       LDY     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_1
                INC     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_1
                LDA     _obj_Key_InfrontPrepare_KeyID
                STA     CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_1,Y

obj_Key_Infront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_Key_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_Key_Ptr
                LDA     object_Ptr+1
                STA     obj_Key_Ptr+1
                LDA     #0
                STA     _obj_Key_InfrontPrepare_KeyID

obj_Key_Prepare_loop:
                LDY     #CreepObj_Key::id
                LDA     (object_Ptr),Y
                BNE     loc_4A1B
                INC     object_Ptr
                BNE     loc_4A18
                INC     object_Ptr+1

loc_4A18:       JMP     obj_Key_Prepare_return
; ---------------------------------------------------------------------------

loc_4A1B:
                LDY     #CreepObj_Key::GfxID ; Graphics for the key, 0 = key was picked up
                LDA     (object_Ptr),Y
                BEQ     loc_4A47
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error

                LDA     #OBJECT_TYPE::KEY
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_Key::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Key::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDY     #CreepObj_Key::GfxID ; Graphics for the key, 0 = key was picked up
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_GfxID
                LDA     _obj_Key_InfrontPrepare_KeyID
                STA     mObjectsVars + CreepObjectVars_Key::id,X
                JSR     Object_Redraw

loc_4A47:
                CLC
                LDA     _obj_Key_InfrontPrepare_KeyID
                ADC     #.SIZEOF(CreepObj_Key)
                STA     _obj_Key_InfrontPrepare_KeyID
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Key)
                STA     object_Ptr
                BCC     obj_Key_Prepare_loop
                INC     object_Ptr+1
                JMP     obj_Key_Prepare_loop
; ---------------------------------------------------------------------------

obj_Key_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Key_InfrontPrepare_KeyID:.BYTE $A0
obj_Key_Ptr:    .addr $A098
_obj_Key_Infront_pObjectNumber:.BYTE $A0

; =============== S U B R O U T I N E =======================================


.proc obj_KeyLock_Object_ObjectCollision
                STX     _obj_DoorLock_Object_ObjectCollision_saveX
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Door_Lock_InFront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                TAX
                LDA     CASTLE + CreepCastle::playerState,X
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Door_Lock_InFront_return
                LDX     _obj_DoorLock_Object_ObjectCollision_saveX
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     obj_Door_Lock_InFront_return
                LDA     mObjectsVars + CreepObjectVars_Key_Lock::keyId,Y
                JSR     obj_Key_NotFound
                BCS     obj_Door_Lock_InFront_return
                LDX     #0

loc_4A8D:
                LDA     mObjects + CreepObject::objectType,X
                BNE     loc_4A9A        ; not a Door? =>
                LDA     mObjectsVars + CreepObjectVars_Door::id,X
                CMP     mObjectsVars + CreepObjectVars_Key_Lock::doorId,Y
                BEQ     loc_4AA2

loc_4A9A:
                TXA
                CLC
                ADC     #.SIZEOF(CreepObject)
                TAX
                JMP     loc_4A8D
; ---------------------------------------------------------------------------

loc_4AA2:
                LDA     mObjectsVars + CreepObjectVars_Door::doorIsOpen,X
                BNE     obj_Door_Lock_InFront_return
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

obj_Door_Lock_InFront_return:
                LDX     _obj_DoorLock_Object_ObjectCollision_saveX
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_KeyLock_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA

obj_Door_Lock_Prepare_loop:
                LDY     #CreepObj_DoorLock::keyId
                LDA     (object_Ptr),Y
                BEQ     loc_4B0D
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error

                LDA     #OBJECT_TYPE::KEYLOCK
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_DoorLock::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_DoorLock::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDY     #CreepObj_DoorLock::keyId
                LDA     (object_Ptr),Y
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                ORA     (object_Ptr),Y
                LDY     #8
loc_4AE3:       STA     OBJECT_lock_COLOR,Y
                DEY
                BPL     loc_4AE3

                LDA     #GfxID::lock
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_DoorLock::keyId
                LDA     (object_Ptr),Y
                STA     mObjectsVars + CreepObjectVars_Key_Lock::keyId,X
                LDY     #CreepObj_DoorLock::doorId
                LDA     (object_Ptr),Y
                STA     mObjectsVars + CreepObjectVars_Key_Lock::doorId,X
                JSR     Object_Redraw

                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_DoorLock)
                STA     object_Ptr
                BCC     obj_Door_Lock_Prepare_loop
                INC     object_Ptr+1
                JMP     obj_Door_Lock_Prepare_loop
; ---------------------------------------------------------------------------

loc_4B0D:       INC     object_Ptr
                BNE     loc_4B13
                INC     object_Ptr+1
loc_4B13:       PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_DoorLock_Object_ObjectCollision_saveX:.BYTE $C2

; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Object_Execute
                LDA     events_Execute_EngineTicks
                AND     #%11
                BEQ     loc_4B24

obj_RayGun_Execute_return_:
                JMP     obj_RayGun_Execute_return
; ---------------------------------------------------------------------------

loc_4B24:
                CLC
                LDA     obj_RayGun_Ptr
                ADC     mObjectsVars + CreepObjectVars_RayGun::id,X
                STA     mVObjectPtr
                LDA     obj_RayGun_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mObjects + CreepObject::flags,X
                BIT     OBJECT_INVISIBLE ; Object is invisible
                BEQ     loc_4B3F
                JMP     _obj_RayGun_Object_Execute_disabled
; ---------------------------------------------------------------------------

loc_4B3F:
                LDA     Intro_IsInIntroFlag
                CMP     #1
                BEQ     obj_RayGun_Execute_return_

                LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_PLAYER_CONTROLLING ; A player is in active control of the Raygun
                BNE     obj_RayGun_Execute_movement

                LDA     #(-1 & $FF)
                STA     obj_RayGun_id
                LDA     #0
                STA     obj_RayGun_FacingDir
                LDA     #1
                STA     _obj_RayGun_Execute_Player

obj_RayGun_Execute_scanPlayerLoop:
                LDY     _obj_RayGun_Execute_Player
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_RayGun_Execute_nextPlayer
                LDA     obj_Player_Execute_playerSpriteNumber,Y
                TAY
                SEC
                LDA     mSprites + CreepSprite::YPos,Y
                SBC     mObjects + CreepObject::YPos,X
                BCS     loc_4B79
                EOR     #$FF            ; abs(A)
                ADC     #1

loc_4B79:
                CMP     obj_RayGun_id
                BCS     obj_RayGun_Execute_nextPlayer
                STA     obj_RayGun_id
                LDA     mSprites + CreepSprite::YPos,Y
                CMP     #200
                BCS     obj_RayGun_Execute_wantsUp
                CMP     mObjects + CreepObject::YPos,X
                BCS     obj_RayGun_Execute_wantsDown

obj_RayGun_Execute_wantsUp:
                LDA     RAYGUN_MOVE_UP  ; Move the Raygun up
                STA     obj_RayGun_FacingDir
                JMP     obj_RayGun_Execute_nextPlayer
; ---------------------------------------------------------------------------

obj_RayGun_Execute_wantsDown:
                LDA     RAYGUN_MOVE_DOWN ; Move the Raygun down
                STA     obj_RayGun_FacingDir

obj_RayGun_Execute_nextPlayer:
                DEC     _obj_RayGun_Execute_Player
                BPL     obj_RayGun_Execute_scanPlayerLoop

                LDA     #%11111111
                EOR     RAYGUN_MOVE_UP  ; Move the Raygun up
                EOR     RAYGUN_MOVE_DOWN ; Move the Raygun down
                LDY     #CreepObj_Raygun::Flags
                AND     (mVObjectPtr),Y
                ORA     obj_RayGun_FacingDir
                STA     (mVObjectPtr),Y

obj_RayGun_Execute_movement:
                LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_MOVE_UP  ; Move the Raygun up
                BEQ     obj_RayGun_Execute_notMoveUp

                LDY     #CreepObj_Raygun::gunYPos
                LDA     (mVObjectPtr),Y
                LDY     #CreepObj_Raygun::YPos
                CMP     (mVObjectPtr),Y
                BEQ     obj_RayGun_Execute_noMovement
                SEC
                SBC     #1
                LDY     #CreepObj_Raygun::gunYPos
                STA     (mVObjectPtr),Y
                LDA     #(COLOR::GREEN<<4)+COLOR::GREY
                JSR     obj_RayGun_Control_Update_Color
                JMP     _obj_RayGun_Object_Execute_disabled
; ---------------------------------------------------------------------------

obj_RayGun_Execute_notMoveUp:
                BIT     RAYGUN_MOVE_DOWN ; Move the Raygun down
                BNE     obj_RayGun_Execute_moveDown

obj_RayGun_Execute_noMovement:
                LDA     #(COLOR::GREY<<4)+COLOR::GREY
                JSR     obj_RayGun_Control_Update_Color
                JMP     obj_RayGun_Execute_movementDone
; ---------------------------------------------------------------------------

obj_RayGun_Execute_moveDown:
                LDY     #CreepObj_Raygun::gunYPos
                LDA     (mVObjectPtr),Y
                CMP     mObjectsVars + CreepObjectVars_RayGun::YPos,X
                BCS     obj_RayGun_Execute_noMovement
                CLC
                ADC     #CreepObj_Raygun::XPos
                STA     (mVObjectPtr),Y
                LDA     #(COLOR::GREY<<4)+COLOR::RED
                JSR     obj_RayGun_Control_Update_Color

_obj_RayGun_Object_Execute_disabled:
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Raygun::gunYPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top

                LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_FACING_LEFT ; Raygun is facing left (vs right)
                BEQ     loc_4C0F        ; Facing right Tracking Animation
                LDA     #4              ; Facing left Tracking Animation
                JMP     loc_4C11
; ---------------------------------------------------------------------------

loc_4C0F:       LDA     #0              ; Facing right Tracking Animation
loc_4C11:       STA     obj_RayGun_FacingDir
                LDY     #CreepObj_Raygun::gunYPos
                LDA     (mVObjectPtr),Y
                AND     #%11
                ORA     obj_RayGun_FacingDir
                TAY
                LDA     _obj_RayGun_Execute_RAYGUN_animTbl,Y
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

obj_RayGun_Execute_movementDone:
                LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_PLAYER_CONTROLLING ; A player is in active control of the Raygun
                BEQ     loc_4C3D
                EOR     RAYGUN_PLAYER_CONTROLLING ; A player is in active control of the Raygun
                STA     (mVObjectPtr),Y
                BIT     RAYGUN_FIRED_BY_PLAYER ; The shot was fired by the player
                BNE     loc_4C44
                JMP     obj_RayGun_Execute_return
; ---------------------------------------------------------------------------

loc_4C3D:       LDA     obj_RayGun_id
                CMP     #5
                BCS     obj_RayGun_Execute_return

loc_4C44:       LDY     #CreepObj_Raygun::Flags
                LDA     (mVObjectPtr),Y
                BIT     RAYGUN_SHOT_ACTIVE ; The Raygun can only fire one shot at the time
                BNE     obj_RayGun_Execute_return
                JSR     obj_RayGun_Shot_Create
                ORA     RAYGUN_SHOT_ACTIVE ; The Raygun can only fire one shot at the time
                STA     (mVObjectPtr),Y

obj_RayGun_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_RayGun_Ptr
                LDA     object_Ptr+1
                STA     obj_RayGun_Ptr+1
                LDA     #0
                STA     obj_RayGun_id

obj_RayGun_Prepare_loop:
                LDY     #CreepObj_Raygun::Flags
                LDA     (object_Ptr),Y
                BIT     RAYGUN_END_MARKER
                BEQ     loc_4C7E
                INC     object_Ptr
                BNE     loc_4C7B
                INC     object_Ptr+1

loc_4C7B:
                JMP     loc_4D55
; ---------------------------------------------------------------------------

loc_4C7E:
                LDA     #%11111111
                EOR     RAYGUN_SHOT_ACTIVE ; The Raygun can only fire one shot at the time
                AND     (object_Ptr),Y
                STA     (object_Ptr),Y

                LDY     #CreepObj_Raygun::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Raygun::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode

                LDY     #CreepObj_Raygun::Flags
                LDA     (object_Ptr),Y
                BIT     RAYGUN_FACING_LEFT ; Raygun is facing left (vs right)
                BNE     loc_4CA8
                LDA     #GfxID::raygun_track_right
                JMP     loc_4CAA
; ---------------------------------------------------------------------------

loc_4CA8:
                LDA     #GfxID::raygun_track_left

loc_4CAA:
                STA     DRAW_Image_Foreground_GfxID
                LDY     #CreepObj_Raygun::Length
                LDA     (object_Ptr),Y
                STA     obj_RayGun_FacingDir

loc_4CB4:
                LDA     obj_RayGun_FacingDir
                BEQ     loc_4CCB
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                DEC     obj_RayGun_FacingDir
                JMP     loc_4CB4
; ---------------------------------------------------------------------------

loc_4CCB:
                LDY     #CreepObj_Raygun::Flags
                LDA     (object_Ptr),Y
                BIT     RAYGUN_TRACK_ONLY ; Only generate the Raygun track, but not the actual Raygun
                BNE     loc_4D1A

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::RAYGUN
                STA     mObjects + CreepObject::objectType,X
                LDA     obj_RayGun_id
                STA     mObjectsVars + CreepObjectVars_RayGun::id,X
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X
                LDY     #CreepObj_Raygun::Length
                LDA     (object_Ptr),Y
                ASL     A
                ASL     A
                ASL     A
                LDY     #CreepObj_Raygun::YPos
                CLC
                ADC     (object_Ptr),Y
                SEC
                SBC     #11
                STA     mObjectsVars + CreepObjectVars_RayGun::YPos,X

                LDY     #CreepObj_Raygun::Flags
                LDA     (object_Ptr),Y
                BIT     RAYGUN_FACING_LEFT ; Raygun is facing left (vs right)
                BNE     loc_4D10
                CLC
                LDY     #CreepObj_Raygun::XPos
                LDA     (object_Ptr),Y
                ADC     #4
                JMP     loc_4D17
; ---------------------------------------------------------------------------

loc_4D10:
                SEC
                LDY     #CreepObj_Raygun::XPos
                LDA     (object_Ptr),Y
                SBC     #8

loc_4D17:
                STA     mObjects + CreepObject::XPos,X

loc_4D1A:
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::RAYGUN_CONTROLLER
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_Raygun::XPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Raygun::YPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::raygun_button
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                LDA     obj_RayGun_id
                STA     mObjectsVars + CreepObjectVars_RayGun_Controller::id,X
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Raygun)
                STA     object_Ptr
                BCC     loc_4D49
                INC     object_Ptr+1

loc_4D49:
                CLC
                LDA     obj_RayGun_id
                ADC     #.SIZEOF(CreepObj_Raygun)
                STA     obj_RayGun_id
                JMP     obj_RayGun_Prepare_loop
; ---------------------------------------------------------------------------

loc_4D55:       PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_RayGun_Ptr: .addr $B780
obj_RayGun_id:  .BYTE $A0
obj_RayGun_FacingDir:.BYTE $80
_obj_RayGun_Execute_Player:.BYTE $C2

RAYGUN_END_MARKER:.BYTE $80
RAYGUN_SHOT_ACTIVE:.BYTE $40            ; The Raygun can only fire one shot at the time
RAYGUN_PLAYER_CONTROLLING:.BYTE $20     ; A player is in active control of the Raygun
RAYGUN_TRACK_ONLY:.BYTE $10             ; Only generate the Raygun track, but not the actual Raygun
RAYGUN_FIRED_BY_PLAYER:.BYTE 8          ; The shot was fired by the player
RAYGUN_MOVE_UP: .BYTE 4                 ; Move the Raygun up
RAYGUN_MOVE_DOWN:.BYTE 2                ; Move the Raygun down
RAYGUN_FACING_LEFT:.BYTE 1              ; Raygun is facing left (vs right)
_obj_RayGun_Execute_RAYGUN_animTbl:.BYTE GfxID::raygun_facing_right_4, GfxID::raygun_facing_right_1, GfxID::raygun_facing_right_2, GfxID::raygun_facing_right_3; 0
                .BYTE GfxID::raygun_facing_left_4, GfxID::raygun_facing_left_1, GfxID::raygun_facing_left_2, GfxID::raygun_facing_left_3; 4

; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Controller_Object_ObjectCollision
                STY     obj_RayGun_Control_InFront_pObjectNumber
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_RayGun_Control_InFront_return
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                CMP     #8
                BCS     obj_RayGun_Control_InFront_return
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_RayGun_Control_InFront_return

                LDY     obj_RayGun_Control_InFront_pObjectNumber
                CLC
                LDA     obj_RayGun_Ptr
                ADC     mObjectsVars + CreepObjectVars_RayGun::id,Y
                STA     mVObjectPtr
                LDA     obj_RayGun_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     #%11111111
                EOR     RAYGUN_MOVE_UP  ; Move the Raygun up
                EOR     RAYGUN_MOVE_DOWN ; Move the Raygun down
                LDY     #CreepObj_Raygun::Flags
                AND     (mVObjectPtr),Y
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                BNE     loc_4DBB
                ORA     RAYGUN_MOVE_UP  ; Move the Raygun up
                JMP     loc_4DC9
; ---------------------------------------------------------------------------

loc_4DBB:       CPY     #JOYSTICK_DIRECTION::DOWN
                BNE     loc_4DC5
                ORA     RAYGUN_MOVE_DOWN ; Move the Raygun down
                JMP     loc_4DC9
; ---------------------------------------------------------------------------

loc_4DC5:       CPY     #JOYSTICK_DIRECTION::NOTHING
                BNE     obj_RayGun_Control_InFront_return

loc_4DC9:       ORA     RAYGUN_PLAYER_CONTROLLING ; A player is in active control of the Raygun
                LDY     #CreepObj_Raygun::Flags
                STA     (mVObjectPtr),Y

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     loc_4DDD
                LDA     (mVObjectPtr),Y
                ORA     RAYGUN_FIRED_BY_PLAYER ; The shot was fired by the player
                JMP     loc_4DE4
; ---------------------------------------------------------------------------

loc_4DDD:       LDA     #%11111111
                EOR     RAYGUN_FIRED_BY_PLAYER ; The shot was fired by the player
                AND     (mVObjectPtr),Y
loc_4DE4:       STA     (mVObjectPtr),Y

obj_RayGun_Control_InFront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_RayGun_Control_Update_Color
                PHA
                STA     obj_RayGun_Control_Update_colorVal
                TYA
                PHA
                LDA     obj_RayGun_Control_Update_colorVal
                STA     OBJECT_raygun_button_colormask_COLOR
                STA     OBJECT_raygun_button_colormask_COLOR+1

                LDY     #CreepObj_Raygun::XPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Raygun::YPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::raygun_button_colormask
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

                LDA     obj_RayGun_Control_Update_colorVal
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                STA     OBJECT_raygun_button_colormask_COLOR
                STA     OBJECT_raygun_button_colormask_COLOR+1

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #16
                STA     DRAW_Image_Foreground_Top
                JSR     DRAW_Image
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_RayGun_Control_InFront_pObjectNumber:.BYTE $9F
obj_RayGun_Control_Update_colorVal:.BYTE $A7

; =============== S U B R O U T I N E =======================================


.proc obj_MatterTransmitter_Object_Execute
                LDA     events_Execute_EngineTicks
                AND     #1
                BNE     obj_MatterTransmitter_Object_Execute_next

                JSR     GetRandom
                AND     #%111111
                STA     SNDEFFECT_TELEPORT_NOTE
                LDA     #SOUND_EFFECT::TELEPORT
                JSR     SND_PlayEffect

                LDA     events_Execute_EngineTicks
                AND     #%11
                BEQ     loc_4E52
                LDA     #COLOR::WHITE ; Flicker white
                JMP     loc_4E55
; ---------------------------------------------------------------------------

loc_4E52:       LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::color,X
loc_4E55:       ASL     A
                ASL     A
                ASL     A
                ASL     A
                STA     OBJECT_teleport_destination_COLOR
                STA     OBJECT_teleport_destination_COLOR+1
                STA     OBJECT_teleport_destination_COLOR+2
                STA     OBJECT_teleport_destination_COLOR+3

                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::YPos,X
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::teleport_destination
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

                LDA     events_Execute_EngineTicks
                AND     #%11
                BEQ     loc_4E8A
                LDA     #COLOR::BLACK ; Flicker black
                JMP     loc_4E8D
; ---------------------------------------------------------------------------

loc_4E8A:       LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::color,X

loc_4E8D:       JSR     obj_MatterTransmitter_SetColor

                LDA     events_Execute_EngineTicks
                AND     #%11
                BNE     obj_MatterTransmitter_Object_Execute_next
                DEC     mObjectsVars + CreepObjectVars_MatterTransmitter::flickerCount,X
                BNE     obj_MatterTransmitter_Object_Execute_next
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

obj_MatterTransmitter_Object_Execute_next:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MatterTransmitter_Object_ObjectCollision
                LDA     mObjects + CreepObject::flags,Y
                BIT     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                BNE     obj_Teleport_InFront_return2
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_Teleport_InFront_return2
                STY     _obj_MatterTransmitter_Setup_pObjectNumber
                LDY     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                LDA     CASTLE + CreepCastle::playerState,Y
                CMP     #PLAYER_STATE::IN_ROOM ; Player is in the current room
                BNE     obj_Teleport_InFront_return2

                LDY     _obj_MatterTransmitter_Setup_pObjectNumber
                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr,Y
                STA     mVObjectPtr
                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr+1,Y
                STA     mVObjectPtr+1

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BNE     obj_Teleport_InFront_button
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickDirections,X ; Additional sprite depended data
                BNE     obj_Teleport_InFront_return2
                LDA     events_Execute_EngineTicks
                AND     #%1111
                BNE     obj_Teleport_InFront_return2

                LDY     #CreepObj_MatterTransmitter::Color
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #1              ; next destination
                STA     (mVObjectPtr),Y
                ASL     A
                ADC     #CreepObj_MatterTransmitter::destinations
                TAY
                LDA     (mVObjectPtr),Y ; End of destination list reached?
                BNE     loc_4EF7
                LDA     #0              ; Then jump back to the beginning
                LDY     #CreepObj_MatterTransmitter::Color
                STA     (mVObjectPtr),Y

loc_4EF7:       LDY     #CreepObj_MatterTransmitter::Color
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #SID_NOTE::D4
                STA     SNDEFFECT_TELEPORT_CHANGE_NOTE
                LDA     #SOUND_EFFECT::TELEPORT_CHANGE
                JSR     SND_PlayEffect

                LDA     (mVObjectPtr),Y
                CLC
                ADC     #COLOR::RED
                STX     _obj_MatterTransmitter_ObjectCollision_temp
                LDX     _obj_MatterTransmitter_Setup_pObjectNumber
                JSR     obj_MatterTransmitter_SetColor
                LDX     _obj_MatterTransmitter_ObjectCollision_temp

obj_Teleport_InFront_return2:
                JMP     obj_Teleport_InFront_return
; ---------------------------------------------------------------------------

obj_Teleport_InFront_button:
                LDY     _obj_MatterTransmitter_Setup_pObjectNumber
                LDA     mObjects + CreepObject::flags,Y
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,Y
                LDA     #8              ; Flicker 8 times
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::flickerCount,Y
                LDY     #CreepObj_MatterTransmitter::Color
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #COLOR::RED
                LDY     _obj_MatterTransmitter_Setup_pObjectNumber
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::color,Y
                LDY     #CreepObj_MatterTransmitter::Color
                LDA     (mVObjectPtr),Y
                ASL     A
                ADC     #CreepObj_MatterTransmitter::destinations
                TAY
                LDA     (mVObjectPtr),Y
                PHA
                INY
                LDA     (mVObjectPtr),Y
                LDY     _obj_MatterTransmitter_Setup_pObjectNumber
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::YPos,Y
                CLC
                ADC     #7
                STA     mSprites + CreepSprite::YPos,X
                PLA
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::XPos,Y
                STA     mSprites + CreepSprite::XPos,X

obj_Teleport_InFront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MatterTransmitter_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDY     #CreepObj_MatterTransmitter::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_MatterTransmitter::YPos
                LDA     (object_Ptr),Y
                CLC
                ADC     #24
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::walkway_center
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                LDA     #3
                STA     _obj_MatterTransmitter_Setup_selectedColor

loc_4F81:
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Mask_Left
                DEC     _obj_MatterTransmitter_Setup_selectedColor
                BNE     loc_4F81

                LDY     #CreepObj_MatterTransmitter::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MatterTransmitter::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::teleport_booth
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #12
                STA     DRAW_Image_Foreground_Left
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #24
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::walkway_center
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::MATTERTRANSMITTER
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_MatterTransmitter::XPos
                CLC
                LDA     (object_Ptr),Y
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MatterTransmitter::YPos
                LDA     (object_Ptr),Y
                CLC
                ADC     #24
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::teleport_2
                STA     DRAW_Image_Foreground_GfxID
                LDA     object_Ptr
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr,X
                LDA     object_Ptr+1
                STA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr+1,X
                JSR     Object_Redraw

                LDY     #CreepObj_MatterTransmitter::Color
                LDA     (object_Ptr),Y
                CLC
                ADC     #COLOR::RED
                JSR     obj_MatterTransmitter_SetColor

                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::teleport_destination
                STA     DRAW_Image_Foreground_GfxID
                LDA     #(COLOR::RED<<4)+COLOR::BLACK
                STA     _obj_MatterTransmitter_Setup_selectedColor

loc_500E:
                LDY     #CreepObj_MatterTransmitter::destinations + CreepObj_MatterTransmitter_Destinations::XPos
                LDA     (object_Ptr),Y
                BEQ     loc_504B
                LDA     _obj_MatterTransmitter_Setup_selectedColor
                STA     OBJECT_teleport_destination_COLOR
                STA     OBJECT_teleport_destination_COLOR+1
                STA     OBJECT_teleport_destination_COLOR+2
                STA     OBJECT_teleport_destination_COLOR+3

                LDY     #CreepObj_MatterTransmitter::destinations + CreepObj_MatterTransmitter_Destinations::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MatterTransmitter::destinations + CreepObj_MatterTransmitter_Destinations::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                JSR     DRAW_Image

                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_MatterTransmitter_Destinations)
                STA     object_Ptr
                BCC     loc_503F
                INC     object_Ptr+1

loc_503F:
                CLC
                LDA     _obj_MatterTransmitter_Setup_selectedColor
                ADC     #(COLOR::WHITE<<4)+COLOR::BLACK
                STA     _obj_MatterTransmitter_Setup_selectedColor
                JMP     loc_500E
; ---------------------------------------------------------------------------

loc_504B:
                CLC
                LDA     object_Ptr
                ADC     #4
                STA     object_Ptr
                BCC     obj_Teleport_Prepare_return
                INC     object_Ptr+1

obj_Teleport_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MatterTransmitter_SetColor
                PHA
                STA     _obj_MatterTransmitter_SetColor_COLOR
                TYA
                PHA
                LDA     _obj_MatterTransmitter_SetColor_COLOR
                ASL     A
                ASL     A
                ASL     A
                ASL     A
                ORA     #COLOR::LIGHT_RED
                STA     OBJECT_teleport_booth_colormask_COLOR
                STA     OBJECT_teleport_booth_colormask_COLOR+1
                STA     OBJECT_teleport_booth_colormask_COLOR+2
                LDA     #COLOR::LIGHT_GREY
                STA     OBJECT_teleport_booth_colormask_COLOR+3
                STA     OBJECT_teleport_booth_colormask_COLOR+4
                STA     OBJECT_teleport_booth_colormask_COLOR+5

                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr,X
                STA     mVObjectPtr
                LDA     mObjectsVars + CreepObjectVars_MatterTransmitter::objectPtr+1,X
                STA     mVObjectPtr+1

                LDY     #CreepObj_MatterTransmitter::XPos
                LDA     (mVObjectPtr),Y
                CLC
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MatterTransmitter::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDA     #GfxID::teleport_booth_colormask
                STA     DRAW_Image_Foreground_GfxID
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                LDA     #COLOR::WHITE
                STA     OBJECT_teleport_booth_colormask_COLOR+3
                STA     OBJECT_teleport_booth_colormask_COLOR+4
                STA     OBJECT_teleport_booth_colormask_COLOR+5
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                JSR     DRAW_Image
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_MatterTransmitter_ObjectCollision_temp:.BYTE $A0
_obj_MatterTransmitter_Setup_pObjectNumber:.BYTE $FF
_obj_MatterTransmitter_Setup_selectedColor:.BYTE $D5
_obj_MatterTransmitter_SetColor_COLOR:.BYTE $C3

; =============== S U B R O U T I N E =======================================


.proc obj_TrapDoor_Switch_Object_Execute
                CLC
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,X
                ADC     obj_TrapDoor_Ptr
                STA     mVObjectPtr
                LDA     obj_TrapDoor_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::doorIsOpen,X
                BEQ     loc_5129

                LDY     #CreepObj_Trapdoor::XPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Mask_Top
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                STA     DRAW_Image_Mask_GfxID
                JSR     obj_TrapDoor_PlaySound ; Play trapdoor sound modfied by A
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                CMP     #GfxID::trapdoor_6
                BNE     loc_515F

                CLC
                LDY     #CreepObj_Trapdoor::XPos
                LDA     (mVObjectPtr),Y
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::trapdoor_7
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw
                JMP     loc_5165
; ---------------------------------------------------------------------------

loc_5129:
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                CMP     #GfxID::trapdoor_6
                BNE     loc_5133
                JSR     Object_setInvisible

loc_5133:
                LDY     #CreepObj_Trapdoor::XPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                STA     DRAW_Image_Foreground_GfxID
                JSR     obj_TrapDoor_PlaySound ; Play trapdoor sound modfied by A
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                CMP     #GfxID::trapdoor_1
                BEQ     loc_5165
                DEC     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                JMP     obj_TrapDoor_Switch_Execute_return
; ---------------------------------------------------------------------------

loc_515F:
                INC     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                JMP     obj_TrapDoor_Switch_Execute_return
; ---------------------------------------------------------------------------

loc_5165:
                LDA     mObjects + CreepObject::flags,X
                EOR     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

obj_TrapDoor_Switch_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================

; Play trapdoor sound modfied by A

.proc obj_TrapDoor_PlaySound
                PHA
                SEC
                SBC     #SID_NOTE::C6
                STA     SNDEFFECT_TRAPDOOR_SWITCHED_NOTE
                LDA     #SOUND_EFFECT::TRAPDOOR_SWITCHED
                JSR     SND_PlayEffect
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_TrapDoor_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_TrapDoor_Ptr
                LDA     object_Ptr+1
                STA     obj_TrapDoor_Ptr+1
                LDA     #0
                STA     obj_TrapDoor_Prepare_objNumber

obj_TrapDoor_Prepare_loop:
                LDY     #CreepObj_Trapdoor::Flags
                LDA     (object_Ptr),Y
                BIT     TRAPDOOR_END_MARKER
                BEQ     loc_51A5
                INC     object_Ptr
                BNE     loc_51A2
                INC     object_Ptr+1

loc_51A2:       JMP     obj_TrapDoor_Prepare_return
; ---------------------------------------------------------------------------

loc_51A5:       JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::TRAPDOOR
                STA     mObjects + CreepObject::objectType,X
                LDA     obj_TrapDoor_Prepare_objNumber
                STA     mObjectsVars + CreepObjectVars_TrapDoor::id,X

                LDY     #CreepObj_Trapdoor::Flags
                LDA     (object_Ptr),Y
                BIT     TRAPDOOR_OPEN
                BNE     loc_51C9
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_trapdoor_controller_COLOR
                LDA     #(COLOR::GREEN<<4)+COLOR::GREEN
                STA     OBJECT_trapdoor_controller_COLOR+2
                JMP     loc_522E
; ---------------------------------------------------------------------------

loc_51C9:       LDY     #CreepObj_Trapdoor::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Top
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                LDA     #GfxID::trapdoor_mask
                STA     DRAW_Image_Mask_GfxID
                JSR     DRAW_Image

                CLC
                LDA     DRAW_Image_Mask_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                LDA     DRAW_Image_Mask_Top
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::trapdoor_7
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                LDA     #(COLOR::RED<<4)+COLOR::BLACK
                STA     OBJECT_trapdoor_controller_COLOR
                LDA     #(COLOR::GREY<<4)+COLOR::GREY
                STA     OBJECT_trapdoor_controller_COLOR+2

                LDY     #CreepObj_Trapdoor::XPos
                LDA     (object_Ptr),Y
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (object_Ptr),Y
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::RIGHT & $FF)
                STA     (ScreenDirectionAddr),Y
                LDY     #4
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::LEFT & $FF)
                STA     (ScreenDirectionAddr),Y

loc_522E:
                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::TRAPDOOR_SWITCH
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_Trapdoor::XPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Trapdoor::YPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::trapdoor_controller
                STA     DRAW_Image_Foreground_GfxID
                LDA     obj_TrapDoor_Prepare_objNumber
                STA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::id,X
                JSR     Object_Redraw

                CLC
                LDA     obj_TrapDoor_Prepare_objNumber
                ADC     #.SIZEOF(CreepObj_Trapdoor)
                STA     obj_TrapDoor_Prepare_objNumber
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Trapdoor)
                STA     object_Ptr
                BCC     loc_5266
                INC     object_Ptr+1

loc_5266:
                JMP     obj_TrapDoor_Prepare_loop
; ---------------------------------------------------------------------------

obj_TrapDoor_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================

; Check switch for trapdoor #A and trigger, if necessary

.proc obj_TrapDoor_Switch_Trigger
                PHA
                STA     obj_TrapDoor_Switch_Check_trapDoorIndex
                TYA
                PHA
                TXA
                PHA
                LDA     mVObjectPtr
                STA     _obj_TrapDoor_Switch_Check_SavedWord40
                LDA     mVObjectPtr+1
                STA     _obj_TrapDoor_Switch_Check_SavedWord40+1
                LDA     ScreenDirectionAddr
                STA     _obj_TrapDoor_Switch_Check_SavedWord3C
                LDA     ScreenDirectionAddr+1
                STA     _obj_TrapDoor_Switch_Check_SavedWord3C+1

                CLC
                LDA     obj_TrapDoor_Ptr
                ADC     obj_TrapDoor_Switch_Check_trapDoorIndex
                STA     mVObjectPtr
                LDA     obj_TrapDoor_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_Trapdoor::Flags
                LDA     (mVObjectPtr),Y
                EOR     TRAPDOOR_OPEN
                STA     (mVObjectPtr),Y
                LDX     #0

loc_52A6:
                LDA     mObjects + CreepObject::objectType,X
                CMP     #OBJECT_TYPE::TRAPDOOR
                BNE     loc_52B5
                LDA     mObjectsVars + CreepObjectVars_TrapDoor::id,X
                CMP     obj_TrapDoor_Switch_Check_trapDoorIndex
                BEQ     loc_52BD

loc_52B5:
                TXA
                CLC
                ADC     #.SIZEOF(CreepObject)
                TAX
                JMP     loc_52A6
; ---------------------------------------------------------------------------

loc_52BD:
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

                LDY     #CreepObj_Trapdoor::Flags
                LDA     (mVObjectPtr),Y
                BIT     TRAPDOOR_OPEN
                BNE     _obj_TrapDoor_Switch_Check_doorOpen

                LDA     #0
                STA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::doorIsOpen,X
                LDA     #GfxID::trapdoor_6
                STA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_trapdoor_controller_COLOR
                LDA     #(COLOR::GREEN<<4)+COLOR::GREEN
                STA     OBJECT_trapdoor_controller_COLOR+2

                LDY     #CreepObj_Trapdoor::XPos
                LDA     (mVObjectPtr),Y
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (mVObjectPtr),Y
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::RIGHT
                STA     (ScreenDirectionAddr),Y
                LDY     #4
                LDA     (ScreenDirectionAddr),Y
                ORA     #DIR_ALLOW::LEFT
                STA     (ScreenDirectionAddr),Y
                JMP     _obj_TrapDoor_Switch_Check_continue
; ---------------------------------------------------------------------------

_obj_TrapDoor_Switch_Check_doorOpen:
                LDA     #1
                STA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::doorIsOpen,X
                LDA     #GfxID::trapdoor_1
                STA     mObjectsVars + CreepObjectVars_TrapDoor_Switch::gfxID,X
                LDA     #(COLOR::RED<<4)+COLOR::BLACK
                STA     OBJECT_trapdoor_controller_COLOR
                LDA     #(COLOR::GREY<<4)+COLOR::GREY
                STA     OBJECT_trapdoor_controller_COLOR+2

                LDY     #CreepObj_Trapdoor::XPos
                LDA     (mVObjectPtr),Y
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDY     #CreepObj_Trapdoor::YPos
                LDA     (mVObjectPtr),Y
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

                LDY     #CreepScreenState::dirFlags
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::RIGHT & $FF)
                STA     (ScreenDirectionAddr),Y
                LDY     #4
                LDA     (ScreenDirectionAddr),Y
                AND     #(~DIR_ALLOW::LEFT & $FF)
                STA     (ScreenDirectionAddr),Y

_obj_TrapDoor_Switch_Check_continue:
                LDY     #CreepObj_Trapdoor::XPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Trapdoor::YPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::trapdoor_controller
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     _obj_TrapDoor_Switch_Check_SavedWord40
                STA     mVObjectPtr
                LDA     _obj_TrapDoor_Switch_Check_SavedWord40+1
                STA     mVObjectPtr+1
                LDA     _obj_TrapDoor_Switch_Check_SavedWord3C
                STA     ScreenDirectionAddr
                LDA     _obj_TrapDoor_Switch_Check_SavedWord3C+1
                STA     ScreenDirectionAddr+1
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_TrapDoor_Prepare_objNumber:.BYTE $A5
obj_TrapDoor_Switch_Check_trapDoorIndex:.BYTE $A0
_obj_TrapDoor_Switch_Check_SavedWord40:.addr $A0A0
_obj_TrapDoor_Switch_Check_SavedWord3C:.addr $80A0

obj_TrapDoor_Ptr:.addr $A0A5
TRAPDOOR_END_MARKER:.BYTE $80
TRAPDOOR_OPEN:  .BYTE $01

; =============== S U B R O U T I N E =======================================


.proc obj_MovingSidewalk_Object_Execute
                CLC
                LDA     obj_MovingSidewalk_Ptr
                ADC     mObjectsVars + CreepObjectVars_MovingSidewalk_Button::id,X
                STA     mVObjectPtr
                LDA     obj_MovingSidewalk_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_SWITCHED_BY_PLY1 ; Player1 just flicked the switch
                BEQ     loc_53A9
                BIT     MOVINGSIDEWALK_ENABLED_BY_PLY1 ; Player1 turned it on
                BEQ     obj_MovingSidewalk_Object_Execute_switch

loc_53A9:
                BIT     MOVINGSIDEWALK_SWITCHED_BY_PLY2 ; Player2 just flicked the switch
                BEQ     obj_MovingSidewalk_Object_Execute_setFlags
                BIT     MOVINGSIDEWALK_ENABLED_BY_PLY2 ; Player2 turned it on
                BNE     obj_MovingSidewalk_Object_Execute_setFlags

obj_MovingSidewalk_Object_Execute_switch:
                BIT     MOVINGSIDEWALK_TURNED_ON ; MovingSidewalk is moving
                BEQ     obj_MovingSidewalk_Object_Execute_switchOn

obj_MovingSidewalk_Object_Execute_switchOff: ; MovingSidewalk is moving
                EOR     MOVINGSIDEWALK_TURNED_ON
                EOR     MOVINGSIDEWALK_MOVING_RIGHT ; MovingSidewalk is moving to the right
                STA     (mVObjectPtr),Y
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                STA     OBJECT_MovingSidewalk_controller_COLOR+2
                LDA     #SID_NOTE::Fs2
                STA     SNDEFFECT_MOVINGSIDEWALK_SWITCH_NOTE
                JMP     loc_53FB
; ---------------------------------------------------------------------------

obj_MovingSidewalk_Object_Execute_switchOn:
                ORA     MOVINGSIDEWALK_TURNED_ON ; MovingSidewalk is moving
                STA     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_MOVING_RIGHT ; MovingSidewalk is moving to the right
                BEQ     loc_53EC
                LDA     #(COLOR::GREEN<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR+2
                LDA     #SID_NOTE::C2
                STA     SNDEFFECT_MOVINGSIDEWALK_SWITCH_NOTE
                JMP     loc_53FB
; ---------------------------------------------------------------------------

loc_53EC:
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                LDA     #(COLOR::RED<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR+2
                LDA     #SID_NOTE::C3
                STA     SNDEFFECT_MOVINGSIDEWALK_SWITCH_NOTE

loc_53FB:
                LDY     #CreepObj_MovingSidewalk::XPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MovingSidewalk::YPosController
                LDA     (mVObjectPtr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::movingsidewalk_controller
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     #SOUND_EFFECT::MOVINGSIDEWALK_SWITCH
                JSR     SND_PlayEffect

obj_MovingSidewalk_Object_Execute_setFlags:
                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     #%11111111
                EOR     MOVINGSIDEWALK_ENABLED_BY_PLY1 ; Player1 turned it on
                EOR     MOVINGSIDEWALK_ENABLED_BY_PLY2 ; Player2 turned it on
                AND     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_SWITCHED_BY_PLY1 ; Player1 just flicked the switch
                BEQ     loc_5432
                ORA     MOVINGSIDEWALK_ENABLED_BY_PLY1 ; Player1 turned it on
                EOR     MOVINGSIDEWALK_SWITCHED_BY_PLY1 ; Player1 just flicked the switch

loc_5432:
                BIT     MOVINGSIDEWALK_SWITCHED_BY_PLY2 ; Player2 just flicked the switch
                BEQ     loc_543D
                ORA     MOVINGSIDEWALK_ENABLED_BY_PLY2 ; Player2 turned it on
                EOR     MOVINGSIDEWALK_SWITCHED_BY_PLY2 ; Player2 just flicked the switch

loc_543D:
                STA     (mVObjectPtr),Y

                BIT     MOVINGSIDEWALK_TURNED_ON ; MovingSidewalk is moving
                BEQ     obj_MovingSidewalk_Execute_return
                LDA     events_Execute_EngineTicks
                AND     #1
                BNE     obj_MovingSidewalk_Execute_return
                LDA     mObjects + CreepObject::gfxID,X
                STA     DRAW_Image_Foreground_GfxID

                LDA     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_MOVING_RIGHT ; MovingSidewalk is moving to the right
                BNE     loc_546A
                INC     DRAW_Image_Foreground_GfxID
                LDA     DRAW_Image_Foreground_GfxID
                CMP     #GfxID::movingsidewalk_controller
                BCC     loc_5479
                LDA     #GfxID::movingsidewalk_anim_1
                STA     DRAW_Image_Foreground_GfxID
                JMP     loc_5479
; ---------------------------------------------------------------------------

loc_546A:
                DEC     DRAW_Image_Foreground_GfxID
                LDA     DRAW_Image_Foreground_GfxID
                CMP     #GfxID::movingsidewalk_anim_1
                BCS     loc_5479
                LDA     #GfxID::movingsidewalk_anim_4
                STA     DRAW_Image_Foreground_GfxID

loc_5479:
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Foreground_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Foreground_Top
                JSR     Object_Redraw

obj_MovingSidewalk_Execute_return:
                JMP     Object_Execute_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MovingSidewalk_Object_ObjectCollision
                CLC
                LDA     obj_MovingSidewalk_Ptr
                ADC     mObjectsVars + CreepObjectVars_MovingSidewalk_Button::id,Y
                STA     mVObjectPtr
                LDA     obj_MovingSidewalk_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                STY     _obj_MovingSidewalk_InFront_byte_564D
                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_TURNED_ON ; MovingSidewalk is moving
                BEQ     obj_MovingSidewalk_InFront_next

                LDA     mSprites + CreepSprite::spriteType,X
                BEQ     loc_54B7
                CMP     #SPRITE_TYPE::MUMMY
                BEQ     loc_54BE
                CMP     #SPRITE_TYPE::FRANKENSTEIN
                BEQ     loc_54BE
                JMP     obj_MovingSidewalk_InFront_next
; ---------------------------------------------------------------------------

loc_54B7:
                LDA     mSprites + CreepSprite::gfxID,X
                CMP     #GfxID::exit
                BCS     obj_MovingSidewalk_InFront_next

loc_54BE:
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                LDY     _obj_MovingSidewalk_InFront_byte_564D
                SEC
                SBC     mObjects + CreepObject::XPos,Y
                BCC     obj_MovingSidewalk_InFront_next
                CMP     #32
                BCS     obj_MovingSidewalk_InFront_next

                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     (mVObjectPtr),Y
                BIT     MOVINGSIDEWALK_MOVING_RIGHT ; MovingSidewalk is moving to the right
                BEQ     loc_54E0
                LDA     #(-1 & $FF)
                JMP     loc_54E2
loc_54E0:       LDA     #1
loc_54E2:       STA     _obj_MovingSidewalk_speed

                LDA     mSprites + CreepSprite::spriteType,X
                BNE     loc_54F1
                LDA     events_Execute_EngineTicks
                AND     #%111
                BNE     loc_54F4

loc_54F1:
                ASL     _obj_MovingSidewalk_speed

loc_54F4:
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     _obj_MovingSidewalk_speed
                STA     mSprites + CreepSprite::XPos,X

obj_MovingSidewalk_InFront_next:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MovingSidewalk_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_MovingSidewalk_Ptr
                LDA     object_Ptr+1
                STA     obj_MovingSidewalk_Ptr+1
                LDA     #0
                STA     _obj_MovingSidewalk_setup_movingsidewalk_id

obj_MovingSidewalk_Prepare_loop:
                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     (object_Ptr),Y
                BIT     MOVINGSIDEWALK_END_MARKER
                BEQ     loc_5527
                INC     object_Ptr
                BNE     loc_5524
                INC     object_Ptr+1

loc_5524:
                JMP     obj_MovingSidewalk_Prepare_return
; ---------------------------------------------------------------------------

loc_5527:
                LDA     #%11111111
                EOR     MOVINGSIDEWALK_SWITCHED_BY_PLY1 ; Player1 just flicked the switch
                EOR     MOVINGSIDEWALK_SWITCHED_BY_PLY2 ; Player2 just flicked the switch
                EOR     MOVINGSIDEWALK_ENABLED_BY_PLY1 ; Player1 turned it on
                EOR     MOVINGSIDEWALK_ENABLED_BY_PLY2 ; Player2 turned it on
                AND     (object_Ptr),Y
                STA     (object_Ptr),Y

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::MOVINGSIDEWALK
                STA     mObjects + CreepObject::objectType,X
                LDA     _obj_MovingSidewalk_setup_movingsidewalk_id
                STA     mObjectsVars + CreepObjectVars_MovingSidewalk::id,X
                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_TRIGGER_EXECUTE ; Trigger execute function for the object
                STA     mObjects + CreepObject::flags,X

                LDY     #CreepObj_MovingSidewalk::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Left
                LDY     #CreepObj_MovingSidewalk::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::movingsidewalk_mask
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     DRAW_Image_Mask_Left
                STA     DRAW_Image_Foreground_Left
                LDA     DRAW_Image_Mask_Top
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::movingsidewalk_anim_1
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::MOVINGSIDEWALK_BUTTON
                STA     mObjects + CreepObject::objectType,X
                LDA     _obj_MovingSidewalk_setup_movingsidewalk_id
                STA     mObjectsVars + CreepObjectVars_MovingSidewalk_Button::id,X
                LDY     #CreepObj_MovingSidewalk::XPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MovingSidewalk::YPosController
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::movingsidewalk_controller
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                LDY     #CreepObj_MovingSidewalk::Flags
                LDA     (object_Ptr),Y
                BIT     MOVINGSIDEWALK_TURNED_ON ; MovingSidewalk is moving
                BNE     loc_55B9
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                STA     OBJECT_MovingSidewalk_controller_COLOR+2
                JMP     loc_55D5
; ---------------------------------------------------------------------------

loc_55B9:
                BIT     MOVINGSIDEWALK_MOVING_RIGHT ; MovingSidewalk is moving to the right
                BNE     loc_55CB
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                LDA     #(COLOR::RED<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR+2
                JMP     loc_55D5
; ---------------------------------------------------------------------------

loc_55CB:
                LDA     #(COLOR::GREEN<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR
                LDA     #(COLOR::GREY<<4)+COLOR::BLACK
                STA     OBJECT_MovingSidewalk_controller_COLOR+2

loc_55D5:
                JSR     DRAW_Image

                LDY     #CreepObj_MovingSidewalk::XPosController
                LDA     (object_Ptr),Y
                CLC
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_MovingSidewalk::YPosController
                LDA     (object_Ptr),Y
                CLC
                ADC     #8
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::movingsidewalk_7
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                CLC
                LDA     _obj_MovingSidewalk_setup_movingsidewalk_id
                ADC     #.SIZEOF(CreepObj_MovingSidewalk)
                STA     _obj_MovingSidewalk_setup_movingsidewalk_id
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_MovingSidewalk)
                STA     object_Ptr
                BCC     loc_5608
                INC     object_Ptr+1

loc_5608:
                JMP     obj_MovingSidewalk_Prepare_loop
; ---------------------------------------------------------------------------

obj_MovingSidewalk_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc


; =============== S U B R O U T I N E =======================================


.proc obj_MovingSidewalkButton_Object_ObjectCollision
                LDA     mSprites + CreepSprite::spriteType,X
                BNE     obj_MovingSidewalkButton_InFront_return
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::joystickButton,X ; Additional sprite depended data
                BEQ     obj_MovingSidewalkButton_InFront_return

                CLC
                LDA     obj_MovingSidewalk_Ptr
                ADC     mObjectsVars + CreepObjectVars_MovingSidewalk_Button::id,Y
                STA     mVObjectPtr
                LDA     obj_MovingSidewalk_Ptr+1
                ADC     #0
                STA     mVObjectPtr+1

                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                BEQ     loc_5636
                LDA     MOVINGSIDEWALK_SWITCHED_BY_PLY2 ; Player2 just flicked the switch
                JMP     loc_5639
; ---------------------------------------------------------------------------

loc_5636:
                LDA     MOVINGSIDEWALK_SWITCHED_BY_PLY1 ; Player1 just flicked the switch

loc_5639:
                LDY     #CreepObj_MovingSidewalk::Flags
                ORA     (mVObjectPtr),Y
                STA     (mVObjectPtr),Y

obj_MovingSidewalkButton_InFront_return:
                JMP     _Sprite_Object_Collision_Check_nextObject
.endproc

; ---------------------------------------------------------------------------
MOVINGSIDEWALK_END_MARKER:.BYTE $80
MOVINGSIDEWALK_ENABLED_BY_PLY2:.BYTE $20 ; Player2 turned it on
MOVINGSIDEWALK_ENABLED_BY_PLY1:.BYTE $10 ; Player1 turned it on
MOVINGSIDEWALK_SWITCHED_BY_PLY2:.BYTE 8  ; Player2 just flicked the switch
MOVINGSIDEWALK_SWITCHED_BY_PLY1:.BYTE 4  ; Player1 just flicked the switch
MOVINGSIDEWALK_MOVING_RIGHT:.BYTE 2      ; MovingSidewalk is moving to the right
MOVINGSIDEWALK_TURNED_ON:.BYTE 1         ; MovingSidewalk is moving
_obj_MovingSidewalk_setup_movingsidewalk_id:.BYTE $A4
_obj_MovingSidewalk_speed:.BYTE $B9
obj_MovingSidewalk_Ptr:.addr $B6A0
_obj_MovingSidewalk_InFront_byte_564D:.BYTE $A0

; =============== S U B R O U T I N E =======================================


.proc obj_Frankenstein_Object_Setup
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     object_Ptr
                STA     obj_Frankenstein_Ptr
                LDA     object_Ptr+1
                STA     obj_Frankenstein_Ptr+1
                LDA     #0
                STA     mFrankensteinObjectNumber

_obj_FrankensteinCoffin_Object_Setup_loop:

                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                BIT     FRANKENSTEIN_END_MARKER
                BEQ     loc_5674
                INC     object_Ptr
                BNE     loc_5671
                INC     object_Ptr+1

loc_5671:
                JMP     obj_Frankenstein_Prepare_return
; ---------------------------------------------------------------------------

loc_5674:
                LDY     #CreepObj_Frankenstein::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Mask_Left
                CLC
                LDY     #CreepObj_Frankenstein::YPos
                LDA     (object_Ptr),Y
                ADC     #24
                STA     DRAW_Image_Mask_Top
                LDA     #GfxID::frankenstein_coffin_mask
                STA     DRAW_Image_Mask_GfxID
                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

                LDA     DRAW_Image_Mask_Left
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos
                LDA     DRAW_Image_Mask_Top
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JSR     CalcScreenDirectionAddr ; Calc ptr into 2k buffer of 40 words * 25 lines

                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                BIT     FRANKENSTEIN_FACEING_LEFT
                BNE     loc_56B7
                LDA     #(~DIR_ALLOW::LEFT & $FF)
                JMP     loc_56C4
; ---------------------------------------------------------------------------

loc_56B7:
                SEC
                LDA     ScreenDirectionAddr
                SBC     #.SIZEOF(CreepScreenState)
                STA     ScreenDirectionAddr
                BCS     loc_56C2
                DEC     ScreenDirectionAddr+1

loc_56C2:
                LDA     #(~DIR_ALLOW::RIGHT & $FF)

loc_56C4:
                STA     _obj_Frankenstein_Setup_SCRBitsMask
                LDY     #4

loc_56C9:
                LDA     (ScreenDirectionAddr),Y
                AND     _obj_Frankenstein_Setup_SCRBitsMask
                STA     (ScreenDirectionAddr),Y
                DEY
                DEY
                BPL     loc_56C9

                JSR     Object_Create   ; Create an object, return the offset in X. C = 1, if error
                LDA     #OBJECT_TYPE::FRANKENSTEIN
                STA     mObjects + CreepObject::objectType,X
                LDY     #CreepObj_Frankenstein::XPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Left
                LDY     #CreepObj_Frankenstein::YPos
                LDA     (object_Ptr),Y
                STA     DRAW_Image_Foreground_Top
                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                BIT     FRANKENSTEIN_FACEING_LEFT
                BNE     loc_56F8
                LDA     #GfxID::frankenstein_coffin_facing_right
                JMP     loc_56FA
; ---------------------------------------------------------------------------

loc_56F8:
                LDA     #GfxID::frankenstein_coffin_facing_left

loc_56FA:
                STA     DRAW_Image_Foreground_GfxID
                JSR     Object_Redraw

                LDY     #CreepObj_Frankenstein::Flags
                LDA     (object_Ptr),Y
                BIT     FRANKENSTEIN_FACEING_LEFT
                BNE     loc_5728

                CLC
                LDA     DRAW_Image_Foreground_Left
                ADC     #4
                STA     DRAW_Image_Foreground_Left
                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     #24
                STA     DRAW_Image_Foreground_Top
                LDA     #GfxID::walkway_center
                STA     DRAW_Image_Foreground_GfxID
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode
                JSR     DRAW_Image

loc_5728:
                JSR     obj_Frankenstein_Sprite_Create
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepObj_Frankenstein)
                STA     object_Ptr
                BCC     loc_5736
                INC     object_Ptr+1

loc_5736:
                CLC
                LDA     mFrankensteinObjectNumber
                ADC     #.SIZEOF(CreepObj_Frankenstein)
                STA     mFrankensteinObjectNumber
                JMP     _obj_FrankensteinCoffin_Object_Setup_loop
; ---------------------------------------------------------------------------

obj_Frankenstein_Prepare_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
obj_Frankenstein_Ptr:.addr $A090
mFrankensteinObjectNumber:.BYTE $C1
_obj_Frankenstein_Setup_SCRBitsMask:.BYTE $A0
FRANKENSTEIN_END_MARKER:.BYTE $80
FRANKENSTEIN_IS_DEAD:.BYTE $04
FRANKENSTEIN_AWAKE:.BYTE $02
FRANKENSTEIN_FACEING_LEFT:.BYTE $01

; =============== S U B R O U T I N E =======================================

; Create an object, return the offset in X. C = 1, if error

.proc Object_Create
                PHA
                TYA
                PHA
                LDA     OBJECT_COUNT
                CMP     #32
                BNE     loc_575E
                SEC
                JMP     object_Create_return
; ---------------------------------------------------------------------------

loc_575E:
                INC     OBJECT_COUNT
                ASL     A
                ASL     A
                ASL     A
                TAX
                LDY     #.SIZEOF(CreepRoom)
                LDA     #OBJECT_TYPE::DOOR

_loop:
                STA     mObjects,X
                STA     mObjectsVars,X
                INX
                DEY
                BNE     _loop
                TXA
                SEC
                SBC     #.SIZEOF(CreepRoom)
                TAX
                LDA     OBJECT_INVISIBLE ; Object is invisible
                STA     mObjects + CreepObject::flags,X
                CLC

object_Create_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc Object_Redraw
                PHA
                LDA     mObjects + CreepObject::flags,X
                BIT     OBJECT_INVISIBLE ; Object is invisible
                BNE     loc_57A6

                LDA     #SCREEN_DRAW_MODE::ForegroundAndMask
                STA     DRAW_Image_Mode
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Mask_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Mask_Top
                LDA     mObjects + CreepObject::gfxID,X
                STA     DRAW_Image_Mask_GfxID
                JMP     loc_57AB
; ---------------------------------------------------------------------------

loc_57A6:
                LDA     #SCREEN_DRAW_MODE::Foreground
                STA     DRAW_Image_Mode

loc_57AB:
                JSR     DRAW_Image

                LDA     OBJECT_INVISIBLE ; Object is invisible
                EOR     #%11111111      ; Clear disable flag
                AND     mObjects + CreepObject::flags,X
                STA     mObjects + CreepObject::flags,X

                LDA     DRAW_Image_Foreground_GfxID
                STA     mObjects + CreepObject::gfxID,X
                LDA     DRAW_Image_Foreground_Left
                STA     mObjects + CreepObject::XPos,X
                LDA     DRAW_Image_Foreground_Top
                STA     mObjects + CreepObject::YPos,X
                LDA     DRAW_Image_Foreground_Width
                STA     mObjects + CreepObject::width,X
                LDA     DRAW_Image_Foreground_Height
                STA     mObjects + CreepObject::height,X
                ASL     mObjects + CreepObject::width,X
                ASL     mObjects + CreepObject::width,X
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc Object_setInvisible
                PHA
                LDA     mObjects + CreepObject::flags,X
                BIT     OBJECT_INVISIBLE ; Object is invisible
                BNE     roomAnim_Disable_return

                LDA     #SCREEN_DRAW_MODE::Mask
                STA     DRAW_Image_Mode
                LDA     mObjects + CreepObject::gfxID,X
                STA     DRAW_Image_Mask_GfxID
                LDA     mObjects + CreepObject::XPos,X
                STA     DRAW_Image_Mask_Left
                LDA     mObjects + CreepObject::YPos,X
                STA     DRAW_Image_Mask_Top
                JSR     DRAW_Image

                LDA     mObjects + CreepObject::flags,X
                ORA     OBJECT_INVISIBLE ; Object is invisible
                STA     mObjects + CreepObject::flags,X

roomAnim_Disable_return:
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================


.proc DRAW_Image
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::Foreground
                BNE     _DRAW_Image_Mask
                JMP     _DRAW_Image_Foreground_or_both
; ---------------------------------------------------------------------------

_DRAW_Image_Mask:
                LDA     DRAW_Image_Mask_GfxID
                STA     screenDraw_PTR
                LDA     #0
                STA     screenDraw_PTR+1
                ASL     screenDraw_PTR
                ROL     screenDraw_PTR+1
                CLC
                LDA     screenDraw_PTR
                ADC     #<IMAGE_DATA_TABLE
                STA     screenDraw_PTR
                LDA     screenDraw_PTR+1
                ADC     #>IMAGE_DATA_TABLE
                STA     screenDraw_PTR+1

                LDY     #0
                LDA     (screenDraw_PTR),Y
                STA     PP_A
                INY
                LDA     (screenDraw_PTR),Y
                STA     PP_A+1

                LDY     #CreepIMG_Header::widthInBytes
                LDA     (PP_A),Y
                STA     _DRAW_Image_Mask_Width
                LDY     #CreepIMG_Header::heightInPixels
                LDA     (PP_A),Y
                STA     _DRAW_Image_Mask_Height
                STA     _DRAW_Image_Mask_Linecount

                CLC
                LDA     DRAW_Image_Mask_Top
                ADC     _DRAW_Image_Mask_Height
                STA     _DRAW_Image_Mask_Bottom
                DEC     _DRAW_Image_Mask_Bottom

                SEC
                LDA     DRAW_Image_Mask_Left
                SBC     #16
                BCS     loc_586F
                STA     _DRAW_Image_Mask_XByteOffset
                LDA     #%11111111
                JMP     loc_5874
; ---------------------------------------------------------------------------

loc_586F:
                STA     _DRAW_Image_Mask_XByteOffset
                LDA     #%00000000

loc_5874:
                STA     _DRAW_Image_Mask_XByteOffset+1

                LDA     _DRAW_Image_Mask_XByteOffset
                LSR     A
                LSR     A
                STA     _DRAW_Image_Mask_LeftBytePos
                LDA     _DRAW_Image_Mask_XByteOffset+1
                AND     #%11000000
                ORA     _DRAW_Image_Mask_LeftBytePos
                STA     _DRAW_Image_Mask_LeftBytePos ; = roundup((screenDraw_Background_Left - 16) / 4)
                ASL     _DRAW_Image_Mask_XByteOffset
                ROL     _DRAW_Image_Mask_XByteOffset+1 ; LSB/MSB = (screenDraw_Background_Left - 16) * 2

                CLC
                LDA     _DRAW_Image_Mask_LeftBytePos
                ADC     _DRAW_Image_Mask_Width
                STA     _DRAW_Image_Mask_RightBytePos
                DEC     _DRAW_Image_Mask_RightBytePos

                LDA     #0
                STA     _DRAW_Image_Mask_FirstLineFlag
                CLC
                LDA     PP_A
                ADC     #.SIZEOF(CreepIMG_Header)
                STA     PP_A
                BCC     loc_58AD
                INC     PP_A+1

loc_58AD:
                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::Mask
                BNE     _DRAW_Image_Foreground_or_both
                JMP     _DRAW_Image_drawMaskOnly
; ---------------------------------------------------------------------------

_DRAW_Image_Foreground_or_both:
                LDA     DRAW_Image_Foreground_GfxID
                STA     screenDraw_PTR
                LDA     #0
                STA     screenDraw_PTR+1
                ASL     screenDraw_PTR
                ROL     screenDraw_PTR+1
                CLC
                LDA     screenDraw_PTR
                ADC     #<IMAGE_DATA_TABLE
                STA     screenDraw_PTR
                LDA     screenDraw_PTR+1
                ADC     #>IMAGE_DATA_TABLE
                STA     screenDraw_PTR+1
                LDY     #0
                LDA     (screenDraw_PTR),Y
                STA     PP_B
                INY
                LDA     (screenDraw_PTR),Y
                STA     PP_B+1

                LDY     #0
                LDA     (PP_B),Y
                STA     DRAW_Image_Foreground_Width
                LDY     #1
                LDA     (PP_B),Y
                STA     DRAW_Image_Foreground_Height
                STA     _DRAW_Image_Foreground_Linecount

                CLC
                LDA     DRAW_Image_Foreground_Top
                ADC     DRAW_Image_Foreground_Height
                STA     DRAW_Image_Foreground_Bottom
                DEC     DRAW_Image_Foreground_Bottom

                SEC
                LDA     DRAW_Image_Foreground_Left
                SBC     #16
                BCS     loc_590A
                STA     _DRAW_Image_Foreground_XByteOffset
                LDA     #%11111111
                JMP     loc_590F
; ---------------------------------------------------------------------------

loc_590A:
                STA     _DRAW_Image_Foreground_XByteOffset
                LDA     #%00000000

loc_590F:
                STA     _DRAW_Image_Foreground_XByteOffset+1

                LDA     _DRAW_Image_Foreground_XByteOffset
                LSR     A
                LSR     A
                STA     _DRAW_Image_Foreground_LeftBytePos
                LDA     _DRAW_Image_Foreground_XByteOffset+1
                AND     #%11000000
                ORA     _DRAW_Image_Foreground_LeftBytePos
                STA     _DRAW_Image_Foreground_LeftBytePos ; = roundup((screenDraw_Foreground_Left - 16) / 4)
                ASL     _DRAW_Image_Foreground_XByteOffset
                ROL     _DRAW_Image_Foreground_XByteOffset+1 ; LSB/MSB = (screenDraw_Foreground_Left - 16) * 2

                CLC
                LDA     _DRAW_Image_Foreground_LeftBytePos
                ADC     DRAW_Image_Foreground_Width
                STA     _DRAW_Image_Foreground_RightBytePos
                DEC     _DRAW_Image_Foreground_RightBytePos

                LDA     #0
                STA     _DRAW_Image_Foreground_FirstLineFlag
                CLC
                LDA     PP_B
                ADC     #.SIZEOF(CreepIMG_Header)
                STA     PP_B
                BCC     loc_5948
                INC     PP_B+1

loc_5948:
                LDA     DRAW_Image_Foreground_Top
                STA     _DRAW_Image_Foreground_TopBytePos
                CMP     #220
                BCS     loc_5957
                LDA     #%00000000
                JMP     loc_5959
; ---------------------------------------------------------------------------

loc_5957:
                LDA     #%11111111

loc_5959:
                STA     screenDraw_PTR
                LSR     screenDraw_PTR
                ROR     _DRAW_Image_Foreground_TopBytePos
                LSR     screenDraw_PTR
                ROR     _DRAW_Image_Foreground_TopBytePos
                LSR     screenDraw_PTR
                ROR     _DRAW_Image_Foreground_TopBytePos

                LDA     DRAW_Image_Foreground_Height
                SEC
                SBC     #1
                LSR     A
                LSR     A
                LSR     A
                CLC
                ADC     _DRAW_Image_Foreground_TopBytePos
                STA     _DRAW_Image_Foreground_BottomBytePos

                LDA     _DRAW_Image_Foreground_TopBytePos
                BPL     loc_5985
                LDA     #0
                SEC
                SBC     _DRAW_Image_Foreground_TopBytePos

loc_5985:
                TAX
                LDA     MULT_40_TABLE_LSB,X
                STA     _DRAW_Image_Foreground_ColorTopLineOffset
                LDA     MULT_40_TABLE_MSB,X
                STA     _DRAW_Image_Foreground_ColorTopLineOffset+1

                LDA     _DRAW_Image_Foreground_TopBytePos
                BPL     loc_59A8
                SEC
                LDA     #0
                SBC     _DRAW_Image_Foreground_ColorTopLineOffset
                STA     _DRAW_Image_Foreground_ColorTopLineOffset
                LDA     #0
                SBC     _DRAW_Image_Foreground_ColorTopLineOffset+1
                STA     _DRAW_Image_Foreground_ColorTopLineOffset+1

loc_59A8:
                LDA     DRAW_Image_Foreground_Left
                SEC
                SBC     #16
                STA     screenDraw_PTR
                BCS     loc_59B7
                LDA     #%11111111
                JMP     loc_59B9
; ---------------------------------------------------------------------------

loc_59B7:
                LDA     #%00000000

loc_59B9:
                STA     screenDraw_PTR+1
                LSR     screenDraw_PTR+1
                ROR     screenDraw_PTR
                LSR     screenDraw_PTR+1
                ROR     screenDraw_PTR
                STA     screenDraw_PTR+1

                CLC
                LDA     _DRAW_Image_Foreground_ColorTopLineOffset
                ADC     screenDraw_PTR
                STA     _DRAW_Image_Foreground_ColorTopLineOffset
                LDA     _DRAW_Image_Foreground_ColorTopLineOffset+1
                ADC     screenDraw_PTR+1
                STA     _DRAW_Image_Foreground_ColorTopLineOffset+1

                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::ForegroundAndMask
                BEQ     _DRAW_Image_drawForegroundAndMask
                CMP     #SCREEN_DRAW_MODE::Foreground
                BNE     _DRAW_Image_drawMaskOnly

_DRAW_Image_drawForegroundOnly:
                LDA     DRAW_Image_Foreground_Top
                STA     _DRAW_Image_clippedTop
                LDA     DRAW_Image_Foreground_Bottom
                STA     _DRAW_Image_clippedBottom
                JMP     _DRAW_Image_setup_done
; ---------------------------------------------------------------------------

_DRAW_Image_drawMaskOnly:
                LDA     DRAW_Image_Mask_Top
                STA     _DRAW_Image_clippedTop
                LDA     _DRAW_Image_Mask_Bottom
                STA     _DRAW_Image_clippedBottom
                JMP     _DRAW_Image_setup_done
; ---------------------------------------------------------------------------

_DRAW_Image_drawForegroundAndMask:
                LDA     DRAW_Image_Foreground_Top
                CMP     DRAW_Image_Mask_Top
                BEQ     _DRAW_Image_drawForegroundAndMask_clippingTop3
                BCC     _DRAW_Image_drawForegroundAndMask_clippingTop
                CMP     #220
                BCC     _DRAW_Image_drawForegroundAndMask_clippingTop2
                LDA     DRAW_Image_Mask_Top
                CMP     #220
                BCS     _DRAW_Image_drawForegroundAndMask_clippingTop2
                JMP     _DRAW_Image_drawForegroundAndMask_clippingTop3
; ---------------------------------------------------------------------------

_DRAW_Image_drawForegroundAndMask_clippingTop:

                LDA     DRAW_Image_Mask_Top
                CMP     #220
                BCC     _DRAW_Image_drawForegroundAndMask_clippingTop3
                LDA     DRAW_Image_Foreground_Top
                CMP     #220
                BCS     _DRAW_Image_drawForegroundAndMask_clippingTop3

_DRAW_Image_drawForegroundAndMask_clippingTop2:
                LDA     DRAW_Image_Mask_Top
                JMP     _DRAW_Image_drawForegroundAndMask_clippingTop4
; ---------------------------------------------------------------------------

_DRAW_Image_drawForegroundAndMask_clippingTop3:
                LDA     DRAW_Image_Foreground_Top

_DRAW_Image_drawForegroundAndMask_clippingTop4:

                STA     _DRAW_Image_clippedTop

                LDA     DRAW_Image_Foreground_Bottom
                CMP     _DRAW_Image_Mask_Bottom
                BEQ     _DRAW_Image_drawForegroundAndMask_clippingBottom2
                BCC     _DRAW_Image_drawForegroundAndMask_clippingBottom
                CMP     #220
                BCC     _DRAW_Image_drawForegroundAndMask_clippingBottom1
                LDA     _DRAW_Image_Mask_Bottom
                CMP     #220
                BCC     _DRAW_Image_drawForegroundAndMask_clippingBottom2
                JMP     _DRAW_Image_drawForegroundAndMask_clippingBottom1
; ---------------------------------------------------------------------------

_DRAW_Image_drawForegroundAndMask_clippingBottom:

                LDA     _DRAW_Image_Mask_Bottom
                CMP     #220
                BCC     _DRAW_Image_drawForegroundAndMask_clippingBottom2
                LDA     DRAW_Image_Foreground_Bottom
                CMP     #220
                BCS     _DRAW_Image_drawForegroundAndMask_clippingBottom2

_DRAW_Image_drawForegroundAndMask_clippingBottom1:
                LDA     DRAW_Image_Foreground_Bottom
                STA     _DRAW_Image_clippedBottom
                JMP     _DRAW_Image_setup_done
; ---------------------------------------------------------------------------

_DRAW_Image_drawForegroundAndMask_clippingBottom2:
                LDA     _DRAW_Image_Mask_Bottom
                STA     _DRAW_Image_clippedBottom

_DRAW_Image_setup_done:
                LDA     _DRAW_Image_clippedTop
                STA     _DRAW_Image_Current_Top
                TAX
                LDA     BITMAP_ADR_TABLE_LSB,X
                STA     screenDraw_BitmapLineAdr
                LDA     BITMAP_ADR_TABLE_MSB,X
                STA     screenDraw_BitmapLineAdr+1

_DRAW_Image_lineLoop:
                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::Foreground
                BEQ     _DRAW_Image_mask_done
                LDA     _DRAW_Image_Mask_Linecount
                BEQ     _DRAW_Image_mask_done
                LDA     _DRAW_Image_Mask_FirstLineFlag
                CMP     #1
                BEQ     loc_5A97
                LDA     _DRAW_Image_Current_Top
                CMP     DRAW_Image_Mask_Top
                BNE     _DRAW_Image_mask_done

                LDA     #1
                STA     _DRAW_Image_Mask_FirstLineFlag

loc_5A97:
                DEC     _DRAW_Image_Mask_Linecount
                LDA     _DRAW_Image_Current_Top
                CMP     #200
                BCS     _DRAW_Image_next_mask_Line
                LDA     _DRAW_Image_Mask_LeftBytePos
                STA     _DRAW_Image_Current_BytePos
                CLC
                LDA     screenDraw_BitmapLineAdr
                ADC     _DRAW_Image_Mask_XByteOffset
                STA     _screenDraw_Current_BitmapAdr
                LDA     screenDraw_BitmapLineAdr+1
                ADC     _DRAW_Image_Mask_XByteOffset+1
                STA     _screenDraw_Current_BitmapAdr+1
                LDY     #0

_DRAW_Image_mask_row:
                LDA     _DRAW_Image_Current_BytePos
                CMP     #40
                BCS     _DRAW_Image_mask_rowEnd
                LDA     (PP_A),Y
                EOR     #%11111111
                AND     (_screenDraw_Current_BitmapAdr),Y
                STA     (_screenDraw_Current_BitmapAdr),Y

_DRAW_Image_mask_rowEnd:
                LDA     _DRAW_Image_Current_BytePos
                CMP     _DRAW_Image_Mask_RightBytePos
                BEQ     _DRAW_Image_next_mask_Line
                CLC
                LDA     _screenDraw_Current_BitmapAdr
                ADC     #7
                STA     _screenDraw_Current_BitmapAdr
                BCC     loc_5ADA
                INC     _screenDraw_Current_BitmapAdr+1

loc_5ADA:
                INC     _DRAW_Image_Current_BytePos
                INY
                JMP     _DRAW_Image_mask_row
; ---------------------------------------------------------------------------

_DRAW_Image_next_mask_Line:
                CLC
                LDA     PP_A
                ADC     _DRAW_Image_Mask_Width
                STA     PP_A
                BCC     _DRAW_Image_mask_done
                INC     PP_A+1

_DRAW_Image_mask_done:
                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::Mask
                BEQ     _DRAW_Image_foreground_done
                LDA     _DRAW_Image_Foreground_Linecount
                BEQ     _DRAW_Image_foreground_done
                LDA     _DRAW_Image_Foreground_FirstLineFlag
                CMP     #1
                BEQ     loc_5B0D
                LDA     _DRAW_Image_Current_Top
                CMP     DRAW_Image_Foreground_Top
                BNE     _DRAW_Image_foreground_done

                LDA     #1
                STA     _DRAW_Image_Foreground_FirstLineFlag

loc_5B0D:
                DEC     _DRAW_Image_Foreground_Linecount
                LDA     _DRAW_Image_Current_Top
                CMP     #200
                BCS     _DRAW_Image_next_Foreground_Line
                LDA     _DRAW_Image_Foreground_LeftBytePos
                STA     _DRAW_Image_Current_BytePos

                LDA     screenDraw_BitmapLineAdr
                CLC
                ADC     _DRAW_Image_Foreground_XByteOffset
                STA     _screenDraw_Current_BitmapAdr
                LDA     screenDraw_BitmapLineAdr+1
                ADC     _DRAW_Image_Foreground_XByteOffset+1
                STA     _screenDraw_Current_BitmapAdr+1
                LDY     #0

_DRAW_Image_foreground_row:
                LDA     _DRAW_Image_Current_BytePos
                CMP     #40
                BCS     _DRAW_Image_foreground_rowEnd
                LDA     (PP_B),Y
                ORA     (_screenDraw_Current_BitmapAdr),Y
                STA     (_screenDraw_Current_BitmapAdr),Y

_DRAW_Image_foreground_rowEnd:
                LDA     _DRAW_Image_Current_BytePos
                CMP     _DRAW_Image_Foreground_RightBytePos
                BEQ     _DRAW_Image_next_Foreground_Line
                CLC
                LDA     _screenDraw_Current_BitmapAdr
                ADC     #7
                STA     _screenDraw_Current_BitmapAdr
                BCC     loc_5B4E
                INC     _screenDraw_Current_BitmapAdr+1

loc_5B4E:
                INY
                INC     _DRAW_Image_Current_BytePos
                JMP     _DRAW_Image_foreground_row
; ---------------------------------------------------------------------------

_DRAW_Image_next_Foreground_Line:
                CLC
                LDA     PP_B
                ADC     DRAW_Image_Foreground_Width
                STA     PP_B
                BCC     _DRAW_Image_foreground_done
                INC     PP_B+1

_DRAW_Image_foreground_done:
                LDA     _DRAW_Image_Current_Top
                CMP     _DRAW_Image_clippedBottom
                BEQ     _DRAW_Image_loop_done
                INC     _DRAW_Image_Current_Top
                LDA     _DRAW_Image_Current_Top
                AND     #%00000111
                BEQ     loc_5B7C
                INC     screenDraw_BitmapLineAdr
                BNE     _DRAW_Image_lineLoop_
                INC     screenDraw_BitmapLineAdr+1
                JMP     _DRAW_Image_lineLoop_
; ---------------------------------------------------------------------------

loc_5B7C:
                CLC
                LDA     screenDraw_BitmapLineAdr
                ADC     #<(320-8+1)
                STA     screenDraw_BitmapLineAdr
                LDA     screenDraw_BitmapLineAdr+1
                ADC     #>(320-8+1)
                STA     screenDraw_BitmapLineAdr+1

_DRAW_Image_lineLoop_:
                JMP     _DRAW_Image_lineLoop
; ---------------------------------------------------------------------------

_DRAW_Image_loop_done:
                LDA     DRAW_Image_Mode
                CMP     #SCREEN_DRAW_MODE::Mask ; only draw the background?
                BNE     _DRAW_Image_copy_colorram
                JMP     _DRAW_Image_return ; => then we are done!
; ---------------------------------------------------------------------------

_DRAW_Image_copy_colorram:
                LDA     DRAW_Image_Foreground_Top
                AND     #%00000111
                BEQ     loc_5BA2
                LDA     #1
                JMP     loc_5BA4
; ---------------------------------------------------------------------------

loc_5BA2:
                LDA     #0

loc_5BA4:
                STA     _DRAW_Image_IsSubpixelLine
                LDA     _DRAW_Image_Foreground_TopBytePos
                STA     _DRAW_Image_Current_Top
                CLC
                LDA     #<TOP_SCREENRAM
                ADC     _DRAW_Image_Foreground_ColorTopLineOffset
                STA     PP_A
                LDA     #>TOP_SCREENRAM
                ADC     _DRAW_Image_Foreground_ColorTopLineOffset+1
                STA     PP_A+1

_DRAW_Image_copy_bcolorram_lineloop:
                LDA     _DRAW_Image_Current_Top
                CMP     #25
                BCS     loc_5BE5
                LDY     #0
                LDA     _DRAW_Image_Foreground_LeftBytePos
                STA     _DRAW_Image_Current_BytePos

_DRAW_Image_copy_bcolorram_hloop:
                LDA     _DRAW_Image_Current_BytePos
                CMP     #40
                BCS     loc_5BD6
                LDA     (PP_B),Y
                STA     (PP_A),Y

loc_5BD6:
                INY
                LDA     _DRAW_Image_Current_BytePos
                CMP     _DRAW_Image_Foreground_RightBytePos
                BEQ     loc_5BE5
                INC     _DRAW_Image_Current_BytePos
                JMP     _DRAW_Image_copy_bcolorram_hloop
; ---------------------------------------------------------------------------

loc_5BE5:
                LDA     _DRAW_Image_Current_Top
                CMP     _DRAW_Image_Foreground_BottomBytePos
                BEQ     loc_5BFF
                INC     _DRAW_Image_Current_Top
                CLC
                LDA     PP_B
                ADC     DRAW_Image_Foreground_Width
                STA     PP_B
                BCC     loc_5C16
                INC     PP_B+1
                JMP     loc_5C16
; ---------------------------------------------------------------------------

loc_5BFF:
                LDA     _DRAW_Image_IsSubpixelLine
                CMP     #1
                BNE     loc_5C24
                LDA     #0
                STA     _DRAW_Image_IsSubpixelLine
                LDA     _DRAW_Image_Current_Top
                CMP     #$FF
                BEQ     loc_5C16
                CMP     #24
                BCS     loc_5C24

loc_5C16:
                CLC
                LDA     PP_A
                ADC     #40
                STA     PP_A
                BCC     _DRAW_Image_copy_bcolorram_lineloop
                INC     PP_A+1
                JMP     _DRAW_Image_copy_bcolorram_lineloop
; ---------------------------------------------------------------------------

loc_5C24:
                CLC
                LDA     PP_B
                ADC     DRAW_Image_Foreground_Width
                STA     PP_B
                BCC     loc_5C30
                INC     PP_B+1

loc_5C30:
                LDA     DRAW_Image_Foreground_Top
                AND     #%00000111
                BEQ     loc_5C3C
                LDA     #1
                JMP     loc_5C3E
; ---------------------------------------------------------------------------

loc_5C3C:
                LDA     #0

loc_5C3E:
                STA     _DRAW_Image_IsSubpixelLine
                LDA     _DRAW_Image_Foreground_TopBytePos
                STA     _DRAW_Image_Current_Top
                CLC
                LDA     #<COLORRAM
                ADC     _DRAW_Image_Foreground_ColorTopLineOffset
                STA     PP_A
                LDA     #>COLORRAM
                ADC     _DRAW_Image_Foreground_ColorTopLineOffset+1
                STA     PP_A+1

_DRAW_Image_copy_colorram_lineloop:
                LDA     _DRAW_Image_Current_Top
                CMP     #25
                BCS     loc_5C7F
                LDY     #0
                LDA     _DRAW_Image_Foreground_LeftBytePos
                STA     _DRAW_Image_Current_BytePos

_DRAW_Image_copy_colorram_hloop:
                LDA     _DRAW_Image_Current_BytePos
                CMP     #40
                BCS     loc_5C70
                LDA     (PP_B),Y
                STA     (PP_A),Y

loc_5C70:
                INY
                LDA     _DRAW_Image_Current_BytePos
                CMP     _DRAW_Image_Foreground_RightBytePos
                BEQ     loc_5C7F
                INC     _DRAW_Image_Current_BytePos
                JMP     _DRAW_Image_copy_colorram_hloop
; ---------------------------------------------------------------------------

loc_5C7F:
                LDA     _DRAW_Image_Current_Top
                CMP     _DRAW_Image_Foreground_BottomBytePos
                BEQ     loc_5C99
                INC     _DRAW_Image_Current_Top
                CLC
                LDA     PP_B
                ADC     DRAW_Image_Foreground_Width
                STA     PP_B
                BCC     loc_5CB0
                INC     PP_B+1
                JMP     loc_5CB0
; ---------------------------------------------------------------------------

loc_5C99:
                LDA     _DRAW_Image_IsSubpixelLine
                CMP     #1
                BNE     _DRAW_Image_return
                LDA     #0
                STA     _DRAW_Image_IsSubpixelLine
                LDA     _DRAW_Image_Current_Top
                CMP     #$FF
                BEQ     loc_5CB0
                CMP     #24
                BCS     _DRAW_Image_return

loc_5CB0:
                CLC
                LDA     PP_A
                ADC     #40
                STA     PP_A
                BCC     _DRAW_Image_copy_colorram_lineloop
                INC     PP_A+1
                JMP     _DRAW_Image_copy_colorram_lineloop
; ---------------------------------------------------------------------------

_DRAW_Image_return:
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_DRAW_Image_Current_Top:.BYTE $A0
_DRAW_Image_clippedTop:.BYTE $94
_DRAW_Image_clippedBottom:.BYTE $A9
DRAW_Image_Mode:.BYTE $8A
_DRAW_Image_Current_BytePos:.BYTE $CF
DRAW_Image_Foreground_GfxID:.BYTE $9E
DRAW_Image_Foreground_Top:.BYTE $A0
DRAW_Image_Foreground_Left:.BYTE $C5
DRAW_Image_Foreground_Bottom:.BYTE $FF
DRAW_Image_Foreground_Width:.BYTE $C5
DRAW_Image_Foreground_Height:.BYTE $E5
_DRAW_Image_Foreground_Linecount:.BYTE $A0
_DRAW_Image_Foreground_XByteOffset:.WORD $9EA0
_DRAW_Image_Foreground_LeftBytePos:.BYTE $95
_DRAW_Image_Foreground_RightBytePos:.BYTE $B9
_DRAW_Image_Foreground_FirstLineFlag:.BYTE $90
DRAW_Image_Mask_GfxID:.BYTE $80
DRAW_Image_Mask_Top:.BYTE $B8
DRAW_Image_Mask_Left:.BYTE $C5
_DRAW_Image_Mask_Bottom:.BYTE $A0
_DRAW_Image_Mask_Width:.BYTE $AF
_DRAW_Image_Mask_Height:.BYTE $BA
_DRAW_Image_Mask_Linecount:.BYTE $D5
_DRAW_Image_Mask_XByteOffset:.WORD $A0A0
_DRAW_Image_Mask_LeftBytePos:.BYTE $D0
_DRAW_Image_Mask_RightBytePos:.BYTE $D9
_DRAW_Image_Mask_FirstLineFlag:.BYTE $8A
_DRAW_Image_Foreground_TopBytePos:.BYTE $E6
_DRAW_Image_Foreground_BottomBytePos:.BYTE $B1
_DRAW_Image_Foreground_ColorTopLineOffset:.WORD $FFA0
_DRAW_Image_IsSubpixelLine:.BYTE $A0

MULT_40_TABLE_LSB:.BYTE $A5,$A0,$F0,$A0,$A0,$A1,$A0,$A0,$A0,$80,$A0,$A0,$98,$A0,$CC,$B7,$A0,$A0,$B0,$85,$C4,$AD,$A0,$83,$A0,$E8,$A0,$A0,$C3,$D5,$FB,$D0
MULT_40_TABLE_MSB:.BYTE $A0,$E0,$C4,$E9,$A0,$AF,$C3,$A0,$B5,$D3,$89,$C2,$94,$C4,$A0,$C3,$A0,$D6,$A0,$88,$A0,$A0,$C5,$A0,$86,$A0,$89,$A0,$F5,$B6,$C3,$97

; =============== S U B R O U T I N E =======================================

.proc Sprite_Update
                PHA
                TYA
                PHA
                LDA     mSprites + CreepSprite::gfxID,X
                STA     screenDraw_PTR
                LDA     #0
                STA     screenDraw_PTR+1
                ASL     screenDraw_PTR  ; Sprite grafics ID * 2 + table address
                ROL     screenDraw_PTR+1
                CLC
                LDA     screenDraw_PTR
                ADC     #<IMAGE_DATA_TABLE
                STA     screenDraw_PTR
                LDA     screenDraw_PTR+1
                ADC     #>IMAGE_DATA_TABLE
                STA     screenDraw_PTR+1

                LDY     #0
                LDA     (screenDraw_PTR),Y
                STA     PP_A            ; Address of the sprite image data
                INY
                LDA     (screenDraw_PTR),Y
                STA     PP_A+1

                LDY     #CreepIMG_Header::spriteFlagsColor
                LDA     (PP_A),Y
                STA     mSprites + CreepSprite::spriteFlagsColor,X
                LDY     #CreepIMG_Header::widthInBytes
                LDA     (PP_A),Y
                STA     _Sprite_Update_WidthInBytes
                ASL     A               ; 4 pixels per Byte (2 bits are used for multi-color)
                ASL     A
                STA     mSprites + CreepSprite::widthInPixels,X
                LDY     #CreepIMG_Header::heightInPixels
                LDA     (PP_A),Y
                STA     mSprites + CreepSprite::heightInPixels,X

                TXA
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                LSR     A
                STA     _Sprite_Update_SpriteIndex
                TAY
                LDA     IRQ_VIC_SPRITE_ADR,Y
                EOR     #(SPRITE_BASE_B-SPRITE_BASE_A)/64 ; Double-Buffer Sprite: $20/$28 * $40 + $C000 => $C800…CA00/$CA00…$CC00 Sprites
                STA     PP_B
                LDA     #0
                STA     PP_B+1
                ASL     PP_B
                ROL     PP_B+1
                ASL     PP_B
                ROL     PP_B+1          ; multiply by 64
                ASL     PP_B
                ROL     PP_B+1
                ASL     PP_B
                ROL     PP_B+1
                ASL     PP_B
                ROL     PP_B+1
                ASL     PP_B
                ROL     PP_B+1
                CLC
                LDA     PP_B
                ADC     #<SCR_DIR_2K_BUF
                STA     PP_B
                LDA     PP_B+1
                ADC     #>SCR_DIR_2K_BUF
                STA     PP_B+1

                CLC
                LDA     PP_A
                ADC     #.SIZEOF(CreepIMG_Header) ; 3 Byte header
                STA     PP_A
                BCC     loc_5DAD
                INC     PP_A+1

loc_5DAD:
                LDA     #0
                STA     _Sprite_Update_H

_Sprite_Update_loopH:
                LDY     #0              ; Width

_Sprite_Update_loopW:
                CPY     _Sprite_Update_WidthInBytes
                BCS     _Sprite_Update_widthLimitReached
                LDA     (PP_A),Y
                JMP     loc_5DC0        ; 3 bytes for the width of the sprite, filled with $00
; ---------------------------------------------------------------------------

_Sprite_Update_widthLimitReached:
                LDA     #0

loc_5DC0:
                STA     (PP_B),Y        ; 3 bytes for the width of the sprite, filled with $00
                INY
                CPY     #3
                BCC     _Sprite_Update_loopW
                INC     _Sprite_Update_H
                LDA     _Sprite_Update_H
                CMP     #21
                BEQ     _Sprite_Update_loopDone
                CMP     mSprites + CreepSprite::heightInPixels,X
                BCS     _Sprite_Update_heightLimitReached
                CLC
                LDA     PP_A
                ADC     _Sprite_Update_WidthInBytes
                STA     PP_A
                BCC     loc_5DED
                INC     PP_A+1
                JMP     loc_5DED
; ---------------------------------------------------------------------------

_Sprite_Update_heightLimitReached:
                LDA     #<_Sprite_Update_3ZeroBytes
                STA     PP_A
                LDA     #>_Sprite_Update_3ZeroBytes
                STA     PP_A+1

loc_5DED:
                CLC
                LDA     PP_B
                ADC     #3              ; next line in the sprite image
                STA     PP_B
                BCC     _Sprite_Update_loopH ; Width
                INC     PP_B+1
                JMP     _Sprite_Update_loopH ; Width
; ---------------------------------------------------------------------------

_Sprite_Update_loopDone:
                LDY     _Sprite_Update_SpriteIndex
                LDA     IRQ_VIC_SPRITE_ADR,Y
                EOR     #(SPRITE_BASE_B-SPRITE_BASE_A)/64 ; Double-Buffer Sprite: $20/$28 * $40 + $C000 => $C800…CA00/$CA00…$CC00 Sprites
                STA     IRQ_VIC_SPRITE_ADR,Y

                LDA     mSprites + CreepSprite::spriteFlagsColor,X
                AND     #%00001111
                STA     VIC::SP0COL,Y    ; Color sprite 0

                LDA     mSprites + CreepSprite::spriteFlagsColor,X
                BIT     SPRITE_DOUBLEWIDTH ; Sprite has double-width
                BNE     loc_5E21
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     VIC::XXPAND      ; Sprite X expansion
                JMP     loc_5E2A
; ---------------------------------------------------------------------------

loc_5E21:
                LDA     VIC::XXPAND      ; Sprite X expansion
                ASL     mSprites + CreepSprite::widthInPixels,X
                ORA     BITMASK_01__80,Y

loc_5E2A:
                STA     VIC::XXPAND      ; Sprite X expansion

                LDA     mSprites + CreepSprite::spriteFlagsColor,X
                BIT     SPRITE_DOUBLEHEIGHT ; Sprite has double-height
                BNE     loc_5E40
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     VIC::MYE         ; Sprite Y expansion
                JMP     loc_5E49
; ---------------------------------------------------------------------------

loc_5E40:
                LDA     VIC::MYE         ; Sprite Y expansion
                ORA     BITMASK_01__80,Y
                ASL     mSprites + CreepSprite::heightInPixels,X

loc_5E49:
                STA     VIC::MYE         ; Sprite Y expansion

                LDA     mSprites + CreepSprite::spriteFlagsColor,X
                BIT     SPRITE_NO_PRIORITY
                BNE     loc_5E5D
                LDA     VIC::SPBGPR      ; Sprite data priority
                ORA     BITMASK_01__80,Y
                JMP     loc_5E65
; ---------------------------------------------------------------------------

loc_5E5D:
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     VIC::SPBGPR      ; Sprite data priority

loc_5E65:
                STA     VIC::SPBGPR      ; Sprite data priority

                LDA     mSprites + CreepSprite::spriteFlagsColor,X
                BIT     SPRITE_NO_MULTICOLOR ; Sprite is a multicolor sprite
                BNE     loc_5E79
                LDA     VIC::SPMC        ; Sprite multicolor
                ORA     BITMASK_01__80,Y
                JMP     loc_5E81
; ---------------------------------------------------------------------------

loc_5E79:
                LDA     BITMASK_01__80,Y
                EOR     #%11111111
                AND     VIC::SPMC        ; Sprite multicolor

loc_5E81:
                STA     VIC::SPMC        ; Sprite multicolor

                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_Sprite_Update_SpriteIndex:.BYTE $8C
_Sprite_Update_3ZeroBytes:.BYTE %00000000,%00000000,%00000000
_Sprite_Update_H:.BYTE $A0
_Sprite_Update_WidthInBytes:.BYTE $8A

; =============== S U B R O U T I N E =======================================

.proc obj_Key_NotFound
                PHA
                STA     _obj_Key_NotFound_pObjectNumber
                TYA
                PHA
                LDA     mSprites + CreepSprite::data + CreepSprite_Player::playerNumber,X ; Additional sprite depended data
                BEQ     loc_5EAA
                LDA     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_2
                STA     _obj_Key_NotFound_KeyCount
                LDA     #<(CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_2)
                STA     PP_A
                LDA     #>(CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_2)
                STA     PP_A+1
                JMP     loc_5EB8
; ---------------------------------------------------------------------------

loc_5EAA:
                LDA     CASTLE + CreepCastle::playerKeyCount + CreepPlayerData::player_1
                STA     _obj_Key_NotFound_KeyCount
                LDA     #<(CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_1)
                STA     PP_A
                LDA     #>(CASTLE + CreepCastle::playerKeys + CreepPlayerKeys::player_1)
                STA     PP_A+1

loc_5EB8:
                LDY     #0

loc_5EBA:
                CPY     _obj_Key_NotFound_KeyCount
                BEQ     loc_5ECA
                LDA     (PP_A),Y
                CMP     _obj_Key_NotFound_pObjectNumber
                BEQ     loc_5ECE
                INY
                JMP     loc_5EBA
; ---------------------------------------------------------------------------

loc_5ECA:
                SEC
                JMP     obj_Key_NotFound_return
; ---------------------------------------------------------------------------

loc_5ECE:
                CLC

obj_Key_NotFound_return:
                PLA
                TAY
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
_obj_Key_NotFound_KeyCount:.BYTE $B5
_obj_Key_NotFound_pObjectNumber:.BYTE $D4

; =============== S U B R O U T I N E =======================================

.proc GetRandom
                LDA     _GetRandom_SEED+2
                ROR     A
                LDA     _GetRandom_SEED+1
                ROR     A
                STA     _GetRandom_SEED
                LDA     #0
                ROL     A
                EOR     _GetRandom_SEED+1
                STA     _GetRandom_SEED+1
                LDA     _GetRandom_SEED
                EOR     _GetRandom_SEED+2
                STA     _GetRandom_SEED+2
                EOR     _GetRandom_SEED+1
                STA     _GetRandom_SEED+1
                RTS

_GetRandom_SEED:.BYTE $A0,$C6,$57
.endproc

; =============== S U B R O U T I N E =======================================

; Check joystick for port #A and the RUN/STOP key

.proc KEY_GetJoystick
                PHA
                STA     _KEY_GetJoystick_inputPort
                TXA
                PHA
                LDA     #$FF
                STA     CIA1::DDRA      ; Data Direction Port A - Bit X: 0=Input (read only), 1=Output (read and write)
                LDA     #0
                STA     CIA1::DDRB      ; Data Direction Port B - Bit X: 0=Input (read only), 1=Output (read and write)
                LDA     #%01111111      ; Select Column 7
                STA     CIA1::PRA       ; Monitoring/control of the 8 data lines of Port A.

                LDA     CIA1::PRB       ; Monitoring/control of the 8 data lines of Port B.
                AND     #%10000000      ; Row 7, Column 7 => RUN/STOP key
                BEQ     _KEY_GetJoystick_RUNSTOP_YES
                LDA     #0
                JMP     _KEY_GetJoystick_RUNSTOP_NO
_KEY_GetJoystick_RUNSTOP_YES:
                LDA     #1
_KEY_GetJoystick_RUNSTOP_NO:
                STA     KEY_GetJoystick_RunStopPressed

                LDA     #0
                STA     PROT_5F6A_ALWAYS_0

                LDA     _KEY_GetJoystick_inputPort
                EOR     #1
                TAX
                LDA     #0
                STA     CIA1::DDRA,X     ; Data Direction Port A - Bit X: 0=Input (read only), 1=Output (read and write)
                LDA     CIA1::PRA,X      ; Monitoring/control of the 8 data lines of Port A.
                STA     _KEY_GetJoystick_inputPort
                AND     #%00001111
                TAX
                LDA     KEY_GetJoystick_Table,X
                STA     KEY_GetJoystick_Input ; 0=up, 1=up,right, 2=right, 3=down,right, 4=down, 5=down,left, 6=left, 7=up,left
                LDA     _KEY_GetJoystick_inputPort
                AND     #%00010000      ; Button pressed?
                BNE     _KEY_GetJoystick_JButton_NO
                LDA     #1
                JMP     _KEY_GetJoystick_JButton_YES
; ---------------------------------------------------------------------------

_KEY_GetJoystick_JButton_NO:
                LDA     #0

_KEY_GetJoystick_JButton_YES:
                STA     KEY_GetJoystick_Button
                PLA
                TAX
                PLA
                RTS
.endproc

; ---------------------------------------------------------------------------
KEY_GetJoystick_Input:.BYTE $82
KEY_GetJoystick_Button:.BYTE $A0
_KEY_GetJoystick_inputPort:.BYTE $BF
KEY_GetJoystick_Table:.BYTE JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::NOTHING
                .BYTE JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::DOWN_RIGHT,JOYSTICK_DIRECTION::UP_RIGHT,JOYSTICK_DIRECTION::RIGHT
                .BYTE JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::DOWN_LEFT,JOYSTICK_DIRECTION::UP_LEFT,JOYSTICK_DIRECTION::LEFT
                .BYTE JOYSTICK_DIRECTION::NOTHING,JOYSTICK_DIRECTION::DOWN,JOYSTICK_DIRECTION::UP,JOYSTICK_DIRECTION::NOTHING
KEY_GetJoystick_RunStopPressed:.BYTE 0
PROT_5F6A_ALWAYS_0:.BYTE 0

; =============== S U B R O U T I N E =======================================

; Calc ptr for sprite X into 2k buffer of 40 words * 25 lines

CalcScreenDirectionAddrForSprite:
                PHA
                TYA
                PHA
                CLC
                LDA     mSprites + CreepSprite::XPos,X
                ADC     mSprites + CreepSprite::xOffset,X ; X-Offset for collision testing
                STA     CalcScreenDirectionAddr_XPos
                AND     #%00000011
                STA     CalcScreenDirectionAddrForSprite_Left_subpixel
                LDA     CalcScreenDirectionAddr_XPos
                LSR     A
                LSR     A
                SEC
                SBC     #4
                STA     CalcScreenDirectionAddr_XPos

                CLC
                LDA     mSprites + CreepSprite::YPos,X
                ADC     mSprites + CreepSprite::yOffset,X ; Y-Offset to define the baseline of the sprite
                STA     CalcScreenDirectionAddr_YPos
                AND     #%00000111
                STA     CalcScreenDirectionAddrForSprite_Bottom_subpixel
                LDA     CalcScreenDirectionAddr_YPos
                LSR     A
                LSR     A
                LSR     A
                STA     CalcScreenDirectionAddr_YPos
                JMP     jmp_CalcScreenDirectionAddr

; =============== S U B R O U T I N E =======================================

; Calc ptr into 2k buffer of 40 words * 25 lines

CalcScreenDirectionAddr:
                PHA
                TYA
                PHA

jmp_CalcScreenDirectionAddr:
                LDY     CalcScreenDirectionAddr_YPos
                LDA     MULT_40_TABLE_LSB,Y
                STA     ScreenDirectionAddr
                LDA     MULT_40_TABLE_MSB,Y
                STA     ScreenDirectionAddr+1
                ASL     ScreenDirectionAddr ; * 40 * 2
                ROL     ScreenDirectionAddr+1
                CLC
                LDA     ScreenDirectionAddr
                ADC     #<SCR_DIR_2K_BUF
                STA     ScreenDirectionAddr
                LDA     ScreenDirectionAddr+1
                ADC     #>SCR_DIR_2K_BUF
                STA     ScreenDirectionAddr+1

                LDA     CalcScreenDirectionAddr_XPos
                ASL     A
                CLC
                ADC     ScreenDirectionAddr
                STA     ScreenDirectionAddr
                BCC     _CalcScreenDirectionAddr_return
                INC     ScreenDirectionAddr+1

_CalcScreenDirectionAddr_return:
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
CalcScreenDirectionAddr_XPos:.BYTE $AC
CalcScreenDirectionAddr_YPos:.BYTE $85
CalcScreenDirectionAddrForSprite_Left_subpixel:.BYTE $C8
CalcScreenDirectionAddrForSprite_Bottom_subpixel:.BYTE $A0

; =============== S U B R O U T I N E =======================================

; Set roomPtr to room # in A

.proc GAME_selectRoom
                PHA
                STA     mRoomPtr
                LDA     #0
                STA     mRoomPtr+1
                ASL     mRoomPtr
                ROL     mRoomPtr+1      ; Room # * 8
                ASL     mRoomPtr
                ROL     mRoomPtr+1
                ASL     mRoomPtr
                ROL     mRoomPtr+1
                CLC
                LDA     mRoomPtr
                ADC     #<ROOM_BASE
                STA     mRoomPtr
                LDA     mRoomPtr+1      ; + ROOM_BASE
                ADC     #>ROOM_BASE
                STA     mRoomPtr+1

                LDA     Intro_IsInIntroFlag
                CMP     #1
                BNE     _selectRoom_notInIntro
                CLC
                LDA     mRoomPtr+1
                ADC     #>(SAVE_GAME_MEMORY - CASTLE)
                STA     mRoomPtr+1

_selectRoom_notInIntro:
                PLA
                RTS
.endproc

; =============== S U B R O U T I N E =======================================

; Select door #A in the current room

.proc GAME_selectDoor
                PHA
                STA     selectedDoor_Count
                TYA
                PHA
                LDY     #CreepRoom::doorsPtr ; Position of the doors in the room
                LDA     (mRoomPtr),Y
                STA     mVObjectPtr
                INY
                LDA     (mRoomPtr),Y
                STA     mVObjectPtr+1

                LDY     #0
                LDA     (mVObjectPtr),Y ; number of doors in this room
                PHA
                LDA     selectedDoor_Count
                ASL     A               ; Each door is 8 bytes large
                ASL     A
                ASL     A
                CLC
                ADC     #1              ; +1 for the room number value
                ADC     mVObjectPtr
                STA     mVObjectPtr
                LDA     mVObjectPtr+1
                ADC     #0
                STA     mVObjectPtr+1
                PLA
                STA     selectedDoor_Count
                PLA
                TAY
                PLA
                RTS
.endproc
selectedDoor_Count:.BYTE $A1



				.include "object_images.s"


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

                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                .BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
SNDEFFECT_TABLE_INIT:.addr $75FF
                .addr $7598
                .addr $75A4
                .addr $75B0
                .BYTE 0


; =============== S U B R O U T I N E =======================================

.proc GAME_optionsMenuPrepare
                PHA
                TYA
                PHA
                TXA
                PHA
                LDA     #<SCREENRAM
                STA     PP_A
                LDA     #>SCREENRAM
                STA     PP_A+1
                LDX     #3
                LDY     #0
                LDA     #' '
loc_17585:      STA     (PP_A),Y
                INY
                BNE     loc_17585
                INC     PP_A+1
                DEX
                BPL     loc_17585

                LDA     #0
                STA     optionsMenu_CurrentSelection
                LDA     #<TXT_GameSelection
                STA     object_Ptr
                LDA     #>TXT_GameSelection
                STA     object_Ptr+1
loc_1759C:      LDY     #CreepOptionsMenu::XPos
                LDA     (object_Ptr),Y
                CMP     #$FF
                BEQ     loc_1760A
                LDY     #CreepOptionsMenu::action
                LDA     (object_Ptr),Y
                CMP     #OPTION_ACTION::NONE
                BEQ     loc_175C0
                LDY     #0
                LDX     optionsMenu_CurrentSelection

loc_175B1:      LDA     (object_Ptr),Y
                STA     GAME_MENU,X
                INX
                INY
                CPY     #.SIZEOF(CreepOptionsMenu)
                BCC     loc_175B1
                INX
                STX     optionsMenu_CurrentSelection

loc_175C0:      LDY     #CreepOptionsMenu::YPos
                LDA     (object_Ptr),Y
                TAX
                CLC
                LDA     MULT_40_TABLE_LSB,X
                ADC     #<SCREENRAM
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,X
                ADC     #>SCREENRAM
                STA     PP_A+1
                CLC
                LDA     PP_A
                LDY     #CreepOptionsMenu::XPos
                ADC     (object_Ptr),Y
                STA     PP_A
                BCC     loc_175E1
                INC     PP_A+1

loc_175E1:
                LDY     #CreepOptionsMenu::XPos
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepOptionsMenu)
                STA     object_Ptr
                BCC     loc_175EE
                INC     object_Ptr+1

loc_175EE:
                LDA     (object_Ptr),Y
                AND     #%00111111      ; Copy character to screen memory
                STA     (PP_A),Y

                LDA     (object_Ptr),Y
                BMI     loc_175FC       ; => end of string
                INY
                JMP     loc_175EE
; ---------------------------------------------------------------------------

loc_175FC:
                CLC
                INY
                TYA
                ADC     object_Ptr
                STA     object_Ptr
                BCC     loc_1759C
                INC     object_Ptr+1
                JMP     loc_1759C
; ---------------------------------------------------------------------------

loc_1760A:
                LDX     GAME_MENU + CreepOptionsMenu::XPos+9
                CLC
                LDA     #<SCREENRAM
                ADC     MULT_40_TABLE_LSB,X
                STA     PP_A
                LDA     #>SCREENRAM
                ADC     MULT_40_TABLE_MSB,X
                STA     PP_A+1
                LDY     GAME_MENU + CreepOptionsMenu::action+6
                DEY
                DEY
                LDA     #'>'
                STA     (PP_A),Y

                CLC
                LDX     #7
                LDA     #<SCREENRAM
                ADC     MULT_40_TABLE_LSB,X
                STA     PP_A
                LDA     #>SCREENRAM
                ADC     MULT_40_TABLE_MSB,X
                STA     PP_A+1
                LDY     #23

loc_17638:
                LDA     (PP_A),Y
                ORA     #%10000000      ; Invert selection
                STA     (PP_A),Y
                INY
                CPY     #26
                BCC     loc_17638

                LDA     #'$'
                STA     DISK_LOAD_FNAME
                LDA     #'0'
                STA     DISK_LOAD_FNAME+1
                LDA     #':'
                STA     DISK_LOAD_FNAME+2
                LDA     #'Z'
                STA     DISK_LOAD_FNAME+3
                LDA     #'*'
                STA     DISK_LOAD_FNAME+4
                LDA     #5
                STA     DISK_LOAD_FNAME_LENGTH
                LDA     #FILETYPE::SAVEGAME
                STA     DISK_LOAD_FILETYPE
                JSR     DISK_ACCESS_PREPARE
                JSR     DISK_LOAD_FILE
                JSR     DISK_DELAY_AFTER_IO

                LDA     #<SAVE_GAME_MEMORY
                STA     PP_A
                LDA     #>SAVE_GAME_MEMORY
                STA     PP_A+1
                LDA     #12
                STA     _optionsMenuPrepare_YPos
                LDA     #3
                STA     _optionsMenuPrepare_XPos

loc_17681:
                LDA     PP_A+1
                CMP     DISK_LOAD_FILEADDR+1
                BCC     loc_17691
                BNE     loc_1769A
                LDA     PP_A
                CMP     DISK_LOAD_FILEADDR
                BCS     loc_1769A

loc_17691:
                LDY     #0
                LDA     (PP_A),Y
                INY
                ORA     (PP_A),Y
                BNE     loc_1769D

loc_1769A:
                JMP     loc_17749
; ---------------------------------------------------------------------------

loc_1769D:
                CLC
                LDA     PP_A
                ADC     #4
                STA     PP_A
                BCC     loc_176A8
                INC     PP_A+1

loc_176A8:
                LDY     #0
                LDA     (PP_A),Y
                BNE     loc_176B7
                INC     PP_A
                BNE     loc_17681
                INC     PP_A+1
                JMP     loc_17681
; ---------------------------------------------------------------------------

loc_176B7:
                CMP     #'"'
                BNE     loc_176C2
                INY
                LDA     (PP_A),Y
                CMP     #'Z'
                BEQ     loc_176CB

loc_176C2:
                INC     PP_A
                BNE     loc_176A8
                INC     PP_A+1
                JMP     loc_176A8
; ---------------------------------------------------------------------------

loc_176CB:
                LDX     optionsMenu_CurrentSelection
                LDA     _optionsMenuPrepare_XPos
                STA     GAME_MENU + CreepOptionsMenu::XPos,X
                LDA     _optionsMenuPrepare_YPos
                STA     GAME_MENU + CreepOptionsMenu::YPos,X
                LDA     #OPTION_ACTION::LOAD_CASTLE
                STA     GAME_MENU + CreepOptionsMenu::action,X
                LDX     _optionsMenuPrepare_YPos
                CLC
                LDA     MULT_40_TABLE_LSB,X
                ADC     #>SCREENRAM
                STA     PP_B
                LDA     MULT_40_TABLE_MSB,X
                ADC     #<SCREENRAM
                STA     PP_B+1
                LDX     _optionsMenuPrepare_XPos
                DEX
                DEX
                CLC
                TXA
                ADC     PP_B
                STA     PP_B
                BCC     loc_17700
                INC     PP_B+1

loc_17700:      LDY     #2
loc_17702:      LDA     (PP_A),Y
                CMP     #'"'
                BEQ     loc_17710
                AND     #%00111111
                STA     (PP_B),Y
                INY
                JMP     loc_17702
; ---------------------------------------------------------------------------

loc_17710:
                LDX     optionsMenu_CurrentSelection
                TYA
                STA     GAME_MENU + CreepOptionsMenu::XPos+3,X
                DEC     GAME_MENU + CreepOptionsMenu::XPos+3,X
                INX
                INX
                INX
                INX
                STX     optionsMenu_CurrentSelection
                CLC
                TYA
                ADC     PP_A
                STA     PP_A
                BCC     loc_1772B
                INC     PP_A+1

loc_1772B:
                LDA     _optionsMenuPrepare_XPos
                CMP     #3
                BNE     loc_1773A
                LDA     #22
                STA     _optionsMenuPrepare_XPos

loc_17737:
                JMP     loc_176C2
; ---------------------------------------------------------------------------

loc_1773A:
                LDA     #3
                STA     _optionsMenuPrepare_XPos
                INC     _optionsMenuPrepare_YPos
                LDA     _optionsMenuPrepare_YPos
                CMP     #24
                BCC     loc_17737

loc_17749:      LDX     optionsMenu_CurrentSelection
                DEX
                DEX
                DEX
                DEX
                STX     optionsMenu_Marker
                LDA     #8
                STA     optionsMenu_CurrentSelection
                PLA
                TAX
                PLA
                TAY
                PLA
                RTS

; ---------------------------------------------------------------------------
_optionsMenuPrepare_XPos:.BYTE $A0
_optionsMenuPrepare_YPos:.BYTE $A0

TXT_GameSelection:_CreepOptionsMenu 5, 3, OPTION_ACTION::NONE
                scrcode "USE JOYSTICK 1 TO MOVE POINTE"
                .BYTE $D2
                _CreepOptionsMenu 5, 4, OPTION_ACTION::NONE
                scrcode "PRESS TRIGGER BUTTON TO SELEC"
                .BYTE $D4
                _CreepOptionsMenu 3, 6, OPTION_ACTION::SELECT
                scrcode "RESUME GAM"
                .BYTE $C5
                _CreepOptionsMenu 22, 6, OPTION_ACTION::RESUME_GAME
                scrcode "VIEW BEST TIME"
                .BYTE $D3
                _CreepOptionsMenu 3, 7, OPTION_ACTION::VIEW_HIGHSCORES
                scrcode "UNLIMITED LIVES (ON/OFF"
                .BYTE $A9
                _CreepOptionsMenu 3, 8, OPTION_ACTION::UNLIMITED_LIVES
                scrcode "EXIT MEN"
                .BYTE $D5
                _CreepOptionsMenu 3, 10, OPTION_ACTION::NONE
                scrcode "LOAD GAME"
                .BYTE $BA
                .BYTE $FF
.endproc
                .END
