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
                CMP     #$5A ; 'Z'
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
