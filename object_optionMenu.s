; Building the options menu including all castles on the disk

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
:               STA     (PP_A),Y
                INY
                BNE     :-
                INC     PP_A+1
                DEX
                BPL     :-

                LDA     #0
                STA     optionsMenu_CurrentSelection
                LDA     #<TXT_GameSelection
                STA     object_Ptr
                LDA     #>TXT_GameSelection
                STA     object_Ptr+1

@menuLoop:      LDY     #CreepOptionsMenu::XPos
                LDA     (object_Ptr),Y
                CMP     #$FF
                BEQ     @endOfMenus

                LDY     #CreepOptionsMenu::action
                LDA     (object_Ptr),Y
                CMP     #OPTION_ACTION::NONE
                BEQ     @noAction

                LDY     #0
                LDX     optionsMenu_CurrentSelection
: 			    LDA     (object_Ptr),Y
                STA     GAME_MENU,X
                INX
                INY
                CPY     #.SIZEOF(CreepOptionsMenu)
                BCC     :-
                INX
                STX     optionsMenu_CurrentSelection

@noAction:      LDY     #CreepOptionsMenu::YPos
                LDA     (object_Ptr),Y
				; use the Y position to cala the screen ptr
                TAX
                CLC
                LDA     MULT_40_TABLE_LSB,X
                ADC     #<SCREENRAM
                STA     PP_A
                LDA     MULT_40_TABLE_MSB,X
                ADC     #>SCREENRAM
                STA     PP_A+1
				; add the X position to the screen ptr
                CLC
                LDA     PP_A
                LDY     #CreepOptionsMenu::XPos
                ADC     (object_Ptr),Y
                STA     PP_A
                BCC     :+
                INC     PP_A+1
:
                LDY     #CreepOptionsMenu::XPos
                CLC
                LDA     object_Ptr
                ADC     #.SIZEOF(CreepOptionsMenu)
                STA     object_Ptr
                BCC     :+
                INC     object_Ptr+1

:               LDA     (object_Ptr),Y
                AND     #%00111111      ; Copy character to screen memory
                STA     (PP_A),Y

                LDA     (object_Ptr),Y
                BMI     :+       ; => end of string
                INY
                JMP     :-

:               CLC
                INY
                TYA
                ADC     object_Ptr
                STA     object_Ptr
                BCC     @menuLoop
                INC     object_Ptr+1
                JMP     @menuLoop
; ---------------------------------------------------------------------------

@endOfMenus:
				; set selection marker
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

				; invert the current selection
                CLC
                LDX     #7
                LDA     #<SCREENRAM
                ADC     MULT_40_TABLE_LSB,X
                STA     PP_A
                LDA     #>SCREENRAM
                ADC     MULT_40_TABLE_MSB,X
                STA     PP_A+1
                LDY     #23
:		        LDA     (PP_A),Y
                ORA     #%10000000 ; Invert character
                STA     (PP_A),Y
                INY
                CPY     #26
                BCC     :-

				; LOAD "$0:Z*" to find all castles on the disk
                LDA     #'$'
                STA     DISK_LOAD_FNAME
                LDA     #'0'
                STA     DISK_LOAD_FNAME+1
                LDA     #':'
                STA     DISK_LOAD_FNAME+2
                LDA     #$5A ; 'Z'
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

@dirCastleLoop:
				; end address reached?
				LDA     PP_A+1
                CMP     DISK_LOAD_FILEADDR+1
                BCC     :+
                BNE     @_return
                LDA     PP_A
                CMP     DISK_LOAD_FILEADDR
                BCS     @_return

				; 16 bit next BASIC line address = $0000 => end of the program
:               LDY     #0
                LDA     (PP_A),Y
                INY
                ORA     (PP_A),Y
                BNE     @processLine

@_return:       JMP     @return


@processLine:   CLC
                LDA     PP_A
                ADC     #4		; skip filesize (line number)
                STA     PP_A
                BCC     @filenameLoop
                INC     PP_A+1

@filenameLoop:  LDY     #0
                LDA     (PP_A),Y
                BNE     @nextChar
                INC     PP_A
                BNE     @dirCastleLoop
                INC     PP_A+1
                JMP     @dirCastleLoop

@nextChar:      CMP     #'"'
                BNE     @nextCharLoop
                INY
                LDA     (PP_A),Y
                CMP     #$5A ; 'Z'
                BEQ     @findCastleFilename
@nextCharLoop:
                INC     PP_A
                BNE     @filenameLoop
                INC     PP_A+1
                JMP     @filenameLoop
; ---------------------------------------------------------------------------

@findCastleFilename:
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
                ADC     #<SCREENRAM
                STA     PP_B
                LDA     MULT_40_TABLE_MSB,X
                ADC     #>SCREENRAM
                STA     PP_B+1
                LDX     _optionsMenuPrepare_XPos
                DEX
                DEX
                CLC
                TXA
                ADC     PP_B
                STA     PP_B
                BCC     :+
                INC     PP_B+1
: 			    
			    LDY     #2
: 			    LDA     (PP_A),Y
                CMP     #'"'
                BEQ     @endOfFilename
                AND     #%00111111
                STA     (PP_B),Y
                INY
                JMP     :-
@endOfFilename:
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
                BCC     :+
                INC     PP_A+1

				; calculate the next screen position for the castle filename
:               LDA     _optionsMenuPrepare_XPos
                CMP     #3
                BNE     @switchFirstCol
                LDA     #22
                STA     _optionsMenuPrepare_XPos

@next:
                JMP     @nextCharLoop
; ---------------------------------------------------------------------------

@switchFirstCol:
                LDA     #3
                STA     _optionsMenuPrepare_XPos
                INC     _optionsMenuPrepare_YPos
                LDA     _optionsMenuPrepare_YPos
                CMP     #24
                BCC     @next

@return:        LDX     optionsMenu_CurrentSelection
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
