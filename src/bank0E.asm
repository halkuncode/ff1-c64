.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "BANK_0E"

.export EnterIntroStory, EnterTitleScreen, NewGamePartyGeneration, DoPartyGen_OnCharacter
.export PtyGen_DrawText, PtyGen_DrawOneText, PtyGen_DrawCursor, PtyGen_Frame, PtyGen_Joy
.export DoNameInput, CharName_Frame, CharName_DrawCursor, NameInput_DrawName, DrawNameInputScreen
.export PrintCharStat, PrintPrice, PrintGold
.export PrintNumber_1Digit, PrintNumber_2Digit, PrintNumber_3Digit, PrintNumber_4Digit, PrintNumber_5Digit, PrintNumber_6Digit
.export FormatNumber_2Digits, FormatNumber_3Digits, FormatNumber_4Digits, FormatNumber_5Digits, FormatNumber_6Digits
.export TrimZeros_2Digits, TrimZeros_3Digits, TrimZeros_4Digits, TrimZeros_5Digits, TrimZeros_6Digits
.export DrawMainMenu, DrawOrbBox, DrawMainMenuGoldBox, DrawMainMenuOptionBox
.export DrawMainItemBox, LoadMainItemBoxDims, DrawMainMenuCharBoxBody
.export DrawMenuString, DrawMenuComplexString, lut_MainItemBoxes, lut_MenuText
.export EnterMainMenu, ResumeMainMenu, MainMenuLoop, MainMenuSubTarget
.export MoveMainMenuSubCursor, MoveCursorUpDown, MenuFrame
.export PlaySFX_MenuMove, PlaySFX_MenuSel, PlaySFX_Error
.export EnterItemMenu, EnterMagicMenu, EnterEquipMenu, EnterStatusMenu, ClearMenuScreen
.export DrawCharMenuString, DrawCharMenuString_Len, MenuWaitForBtn_SFX, MenuWaitForBtn, lut_StatusBoxes
.import LoadMenuCHRPal, LoadNewGameCHRPal, DrawComplexString, WaitForVBlank_L, UpdateJoy_L, DrawBox, DrawOBSprite
.import GameStart_L, CallMusicPlay_L, ClearOAM, DrawPalette_L, DrawCursor, EraseBox
.import DoOverworld, DrawItemBox, SortEquipmentList
.import DrawEquipMenuStrings, UnadjustEquipStats, ReadjustEquipStats
.import lut_ScreenRowLo, lut_ScreenRowHi, CoordToNTAddr
.import lut_IntroStoryText
.import LoadPrice

BANK_THIS = $0E



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TitleScreen_Copyright  [48]
;;
;;    Prepares the screen and draws the little copyright message
;;  at the bottom of the screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TitleScreen_Copyright:
    JSR IntroTitlePrepare      ; clear NT, start music, reset input/cursor, etc

    ; Set border to black, background to blue, and multicolor border registers
    LDA #$0F
    STA cur_pal + $0C          ; Virtual palette border = Black ($0F) for title screen
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0
    LDA #COLOR_WHITE
    STA BGCOL1
    LDA #COLOR_DARKGREY
    STA BGCOL2

    ; Paint Screen RAM ($4000-$43E7) with character $00 (solid block)
    LDX #$00
    LDA #$00                   ; character $00 (solid block)
@LoopScreen:
    STA $4000, X
    STA $4100, X
    STA $4200, X
    STA $4300, X
    INX
    BNE @LoopScreen

    ; Paint Color RAM ($D800-$DBE7) with character color 00 (black)
    LDX #$00
    LDA #COLOR_BLACK           ; char color 00
@LoopColor:
    STA COLOR_RAM, X
    STA COLOR_RAM + $0100, X
    STA COLOR_RAM + $0200, X
    STA COLOR_RAM + $0300, X
    INX
    BNE @LoopColor

    ; Ensure VIC-II Bank 1 ($4000-$7FFF) is selected
    LDA CI2DRA
    ORA #$03
    STA CI2DRA
    LDA CI2PRA
    AND #$FC
    ORA #VIC_BANK1
    STA CI2PRA

    ; Set VIC-II text mode: 40 cols, 25 rows, screen ON, MultiColor mode ON
    LDA #$1B
    STA SCROLY
    LDA #$18
    STA SCROLX
    LDA #$02                   ; Screen: $4000, Charset: $4800
    STA VMCSB

    LDX #0
    JSR @DrawString         ; JSR to @DrawString to draw the first one
                            ;  then just let code flow into it to draw a second one (2 strings total)

  @DrawString:
    LDA @lut_Copyright, X   ; get Target Screen RAM address low
    STA tmp
    LDA @lut_Copyright+1, X ; get Target Screen RAM address high
    STA tmp+1

    ; Set up Color RAM destination pointer in tmp+2, tmp+3
    ; Color RAM = Screen RAM - $4000 + $D800 = Screen RAM + $9800
    LDA tmp
    STA tmp+2
    LDA tmp+1
    CLC
    ADC #>($D800 - $4000)
    STA tmp+3

    INX                     ; move X past the address we just read
    INX
    LDY #0

  @Loop:
    LDA @lut_Copyright, X   ; get next character in string
    BEQ @Exit               ; if zero, exit (null terminator)
    STA (tmp), Y            ; write character code to Screen RAM
    LDA #COLOR_WHITE        ; white text
    STA (tmp+2), Y          ; write color to Color RAM
    INX                     ; move X to next character
    INY                     ; move Y to next screen position
    BNE @Loop               ; keep looping

  @Exit:
    INX                     ; move X past null terminator
    RTS

 ;; LUT for the copyright text. Simply a 2-byte target Screen RAM address, followed by a
 ;; null terminated string. Two strings total.

@lut_Copyright:
  .WORD $43A4
  .BYTE $8C,$FF,$81,$89,$88,$87,$FF,$9C,$9A,$9E,$8A,$9B,$8E,$FF,$FF,$00  ; "C 1987 SQUARE  "
  .WORD $43CC
  .BYTE $8C,$FF,$81,$89,$89,$80,$FF,$97,$92,$97,$9D,$8E,$97,$8D,$98,$00  ; "C 1990 NINTENDO"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_Joy    [85]
;;
;;    Updates joypad data and forces a game restart when the Start button is pressed
;;  (which brings up the title screen).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_Joy:
    LDA #0                ; reset the respond rate to zero
    STA respondrate       ;  (why do this here?  Very out of place)

    JSR UpdateJoy_L       ; Update joypad data
    LDA joy
    AND #BTN_START        ; see if start was pressed
    BEQ :+                ;  if not, just exit
      JMP GameStart_L     ; if it was pressed, restart game (brings up title screen)
:   RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ClearNT  [2504]
;;
;;  Clears Screen RAM ($4000-$43E7) with $FF (spaces)
;;  and clears Color RAM ($D800-$DBE7) to Blue (hidden text)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearNT:
    LDX #$00
    LDA #$FF               ; Blank space character ($FF)
@LoopNT:
    STA $4000, X
    STA $4100, X
    STA $4200, X
    STA $4300, X
    INX
    BNE @LoopNT

    ; Fill Color RAM with Blue so all text is initially hidden (matches NES palette %01)
    LDX #$00
    LDA #COLOR_BLUE
@LoopColor:
    STA COLOR_RAM, X
    STA COLOR_RAM + $0100, X
    STA COLOR_RAM + $0200, X
    STA COLOR_RAM + $0300, X
    INX
    BNE @LoopColor

    ; Set background and border to Blue (native NES story background)
    LDA #$01
    STA cur_pal + $0C          ; Virtual palette border = Blue ($01) for opening story
    STA cur_pal + $0E          ; Virtual palette background = Blue ($01)
    LDA #COLOR_BLUE
    STA BGCOL0
    STA EXTCOL

    ; Ensure VIC-II Bank 1 ($4000-$7FFF) is selected
    LDA CI2DRA
    ORA #$03
    STA CI2DRA
    LDA CI2PRA
    AND #$FC
    ORA #VIC_BANK1
    STA CI2PRA

    ; Set standard VIC-II text mode: 40 cols, 25 rows, text mode, screen ON
    LDA #$1B
    STA SCROLY
    LDA #$08
    STA SCROLX
    LDA #$02
    STA VMCSB

    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Enter Intro Story  [3393]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterIntroStory:
    JSR IntroTitlePrepare      ; load CHR, start music, other prepwork

    ; Now that the screen is cleared and palettes are prepped, draw
    ; the intro story text as a Complex String
    LDA #<lut_IntroStoryText   ; pointer to intro story text (Bank 0D $BF20)
    STA text_ptr
    LDA #>lut_IntroStoryText
    STA text_ptr+1

    LDA #0
    STA menustall

    LDA #BANK_INTROTEXT        ; $0D
    STA cur_bank
    LDA #BANK_THIS             ; $0E
    STA ret_bank

    LDA #5                     ; Centered column on 40-col screen (starts col 5)
    STA dest_x
    LDA #1                     ; Start at Row 1 (prologue spans rows 1 to 23)
    STA dest_y

    JSR DrawComplexString      ; Draw intro story to Screen RAM!

    JSR TurnMenuScreenOn_ClearOAM ; turn on the screen and clear OAM

    JSR IntroStory_MainLoop    ; Run the main loop of the intro story

    LDA #0                     ; once intro story exits, reset respond rate
    STA respondrate
    STA joy_a                  ; clear joypad catchers
    STA joy_b
    STA joy_start
    RTS                        ; and exit to Title Screen!



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Enter Title Screen  [3472]
;;
;;    Draws the title screen and runs its logic loop.
;;
;;  OUT:  respondrate
;;                  C = clear if player selected "Continue"
;;                      set if player selected "New Game"
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterTitleScreen:
    JSR TitleScreen_Copyright     ; Do prepwork, and draw the copyright text
	   ;; The rest of the title screen consists of 3 boxes, each containing a single
   ;;  complex string.  The game here simply draws each of those boxes and 
   ;;  the contained string in order.

    LDA #BANK_THIS   ; set current bank (containing text)
    STA cur_bank     ;  and ret bank (to return to) to this bank
    STA ret_bank     ;  see DrawComplexString for why this is needed

    LDA #15          ; first box is centered at 15,8 with dims 10x4
    STA box_x        ;  and contains "Continue" text
    LDA #8
    STA box_y
    LDA #4
    STA box_ht
    LDA #10
    STA box_wd
    JSR DrawBox
    LDA #<lut_TitleText_Continue
    STA text_ptr
    LDA #>lut_TitleText_Continue
    STA text_ptr+1
    LDA #0
    STA menustall    ; disable menu stalling
    JSR DrawComplexString

    LDA #13          ; next box is same X pos and same dims, but at Y=13
    STA box_y        ;  and contains text "New Game"
    JSR DrawBox
    LDA #<lut_TitleText_NewGame
    STA text_ptr
    LDA #>lut_TitleText_NewGame
    STA text_ptr+1
    JSR DrawComplexString

    LDA #18          ; last box is moved left and down a bit (12,18)
    STA box_y        ;  and is a little fatter (wd=16)
    LDA #12          ; this box contains "Respond Rate"
    STA box_x
    LDA #16
    STA box_wd
    JSR DrawBox
    LDA #<lut_TitleText_RespondRate
    STA text_ptr
    LDA #>lut_TitleText_RespondRate
    STA text_ptr+1
    JSR DrawComplexString

;; Title screen interactive selection loop
    LDA #0
    STA cursor              ; Cursor at starting position (0 = Continue)
    STA joy_prevdir
    STA joy_a
    STA joy_start

    JSR TitleScreen_DrawRespondRate ; Draw initial respond rate digit

    ; Debounce: ensure all buttons/keys (F1, Space, Return) are released before accepting input
@WaitRelease:
    JSR WaitForVBlank_L
    JSR UpdateJoy_L
    LDA joy
    BNE @WaitRelease

    LDA #0
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_prevdir

TitleScreen_Loop:
    JSR ClearOAM            ; Clear shadow sprite buffer

    LDX cursor              ; Cursor position: 0 = Continue, 1 = New Game
    LDA #120                ; Fixed X pixel coord
    STA spr_x
    LDA lut_TitleCursor_Y, X; Y coord from table (118 for Continue, 158 for New Game)
    STA spr_y
    JSR DrawCursor          ; Draw Finger Cursor (Base + Overlay)

    JSR WaitForVBlank_L     ; Wait for VBlank so UpdateSprites flushes to VIC-II hardware
    JSR TitleScreen_DrawRespondRate ; Redraw respond rate digit

    JSR UpdateJoy_L         ; Scan keyboard
    LDA #BANK_THIS
    STA cur_bank

    JSR CallMusicPlay_L     ; Keep music playing every frame

    LDA joy_a               ; Check if Fire / Space or Start / Return was pressed
    ORA joy_start
    BNE TitleScreen_OptionChosen

    LDA joy                 ; Directional buttons (Up, Down, Left, Right)
    AND #$0F
    CMP joy_prevdir
    BEQ TitleScreen_Loop

    STA joy_prevdir
    CMP #0
    BEQ TitleScreen_Loop    ; Button released, continue looping

    CMP #$04                ; Up ($08) or Down ($04)?
    BCC @LeftRight

@UpDown:
    LDA cursor              ; Toggle cursor between Continue (0) and New Game (1)
    EOR #1
    STA cursor
    JSR PlaySFX_MenuMove    ; Play cursor "tweep" sound effect!
    JMP TitleScreen_Loop

@LeftRight:
    CMP #RIGHT              ; Pressed Right?
    BNE @Left
    LDA #1                  ; +1 for Right
    BNE :+
@Left:
    LDA #$FF                ; -1 for Left
:   CLC
    ADC respondrate
    AND #7                  ; Wrap between 0..7
    STA respondrate
    JSR PlaySFX_MenuMove    ; Play "tweep" sound effect!
    JMP TitleScreen_Loop

TitleScreen_OptionChosen:
    JSR PlaySFX_MenuSel     ; Play selection sound on choice!
    LDA #0
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    STA joy
    STA joy_prevdir
    LDA cursor
    LSR A                   ; C=1 if New Game (cursor=1), C=0 if Continue (cursor=0)
    RTS                     ; Option selected! Return to bank0F.asm (falls to halt_loop)


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Menu Sound Effects (borrows Voice 2)
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlaySFX_MenuMove:
    lda #3              ; 3 frames duration (crisp chirp)
    sta sq2_sfx
    lda #<$5000         ; High chirp starting at ~1.25 kHz
    sta V2FREQ_L
    lda #>$5000
    sta V2FREQ_H
    lda #$02            ; Fast decay (24ms)
    sta V2AD
    lda #$00            ; Zero sustain (clean blip)
    sta V2SR
    lda #SID_PULSE
    sta V2CR
    lda #(SID_PULSE | SID_GATE)
    sta V2CR
    rts

PlaySFX_MenuSel:
    lda #5              ; 5 frames duration
    sta sq2_sfx
    lda #<$6000         ; Higher pitch (~1.5 kHz)
    sta V2FREQ_L
    lda #>$6000
    sta V2FREQ_H
    lda #$03
    sta V2AD
    lda #$00
    sta V2SR
    lda #SID_PULSE
    sta V2CR
    lda #(SID_PULSE | SID_GATE)
    sta V2CR
    rts


TitleScreen_DrawRespondRate:
    LDA respondrate         ; 0 to 7
    CLC
    ADC #$80 + 1            ; Convert 0..7 to menu font digit tile '1'..'8' ($81..$88)
    STA $433A               ; Screen RAM (Row 20, Col 26 - at the end after "RESPOND RATE")
    LDA #COLOR_WHITE
    STA $DB3A               ; Color RAM (White text)
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroTitlePrepare   [3600]
;;
;;    Does various preparation things for the intro story and title screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroTitlePrepare:
    LDA #$08               ; set soft2000 so that sprites use right pattern
    STA soft2000           ;   table while BG uses left

    LDA #0
    STA btlformation       ; Initialize to battle formation 0 (Imp/Wolf/Iguana/Giant)
    STA ow_tile            ; Initialize to overworld tile 0 (Grass backdrop)

    JSR LoadMenuCHRPal     ; Load necessary CHR and palettes

    LDA #$41
    STA music_track        ; Start up the crystal theme music

    LDA #0
    STA joy_a              ; clear A, B, Start button catchers
    STA joy_b
    STA joy_start
    STA cursor
    STA joy_prevdir        ; as well as resetting the cursor and previous joy direction

    JMP ClearNT            ; Wipe Screen RAM & Color RAM clean and return!



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Pointerless strings for the title screen  [3643]
;;
;;    These are complex strings drawn onto the title screen.  They
;;  have no pointer table -- instead the drawing code points to the
;;  strings directly (hence why each string is labelled)

lut_TitleText_Continue:
  .BYTE $8C,$98,$97,$9D,$92,$97,$9E,$8E,$00

lut_TitleText_NewGame:
  .BYTE $97,$8E,$A0,$FF,$90,$8A,$96,$8E,$00

lut_TitleText_RespondRate:
  .BYTE $9B,$8E,$9C,$99,$98,$97,$8D,$FF,$9B,$8A,$9D,$8E,$00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Small LUT for the Y position of the title screen cursor  [3656]

lut_TitleCursor_Y:
  .BYTE 118   ; to point at "Continue" (Row 9)
  .BYTE 158   ; to point at "New Game" (Row 14)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_MainLoop    [3674]
;;
;;    Main loop for the intro story. Called once the screen has been fully
;;  drawn.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_MainLoop:
    LDA #1                     ; start animating from row 1
    STA tmp+6

@BlockLoop:
    JSR IntroStory_AnimateBlock ; animate a 2-row block

    INC tmp+6
    LDA tmp+6
    CMP #24                    ; Rows 1 to 23
    BCC @BlockLoop

     ; once all blocks have been animated, the entire intro story is now visible
     ;  simply keep doing frames in an endless loop.  IntroStory_Frame, will double-RTS
     ;  if the user presses A or B, which will break out of this loop.  It will also
     ;  escape this routine altogether if the user presses start, so this infinite
     ;  loop isn't really all that infinite.  See IntroStory_Frame for details.

@InfiniteLoop:
    JSR IntroStory_Frame
    JMP @InfiniteLoop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_AnimateBlock  [3708]
;;
;;    Animates a "block" (2 rows of text) for the intro story.
;;  Calls IntroStory_AnimateRow for the top row, then for the bottom row.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_AnimateBlock:
    ; Animate top row of the block
    JSR IntroStory_AnimateRow
    LDX tmp+6
    LDA #COLOR_WHITE
    JSR IntroStory_WriteAttr
    LDA #0
    STA joy_a
    STA joy_b

    ; Check if there is a bottom row in this block (rows 1..23)
    INC tmp+6
    LDA tmp+6
    CMP #24
    BCS @Done

    ; Animate bottom row of the block
    JSR IntroStory_AnimateRow
    LDX tmp+6
    LDA #COLOR_WHITE
    JSR IntroStory_WriteAttr
    LDA #0
    STA joy_a
    STA joy_b

@Done:
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_AnimateRow   [3751]
;;
;;    Animates the palette/color to "fade in" a row of text.
;;  Calls IntroStory_Frame, which can double-RTS if A or B is pressed,
;;  causing this routine to exit mid-animation so the entire row fades in
;;  immediately. This is why repeatedly pressing A or B during the intro
;;  story makes the text appear faster.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_AnimateRow:
    LDA #0
    STA tmp+7                     ; Step index in flicker table
@StepLoop:
    LDX tmp+7
    LDA lut_FlickerColor, X
    BMI @Done                     ; $FF marker = end of steps for this row
    LDX tmp+6                     ; Current row (1..23)
    JSR IntroStory_WriteAttr

    LDX tmp+7
    LDA lut_FlickerFrames, X
    STA tmp+3                     ; Duration (frame count) for this step

@FrameLoop:
    JSR IntroStory_Frame          ; Do a frame! (double-RTS on A/B returns to IntroStory_MainLoop)
    DEC tmp+3
    BNE @FrameLoop

    INC tmp+7
    JMP @StepLoop

@Done:
    RTS

lut_FlickerColor:
    .byte COLOR_DARKGREY, COLOR_BLUE, COLOR_GREY, COLOR_DARKGREY, COLOR_LIGHTGREY, COLOR_GREY, COLOR_WHITE, $FF

lut_FlickerFrames:
    .byte 3, 2, 3, 2, 3, 2, 12



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_WriteAttr   [3818]
;;
;;    Updates a row of attribute data for the intro story.
;;  On C64, writes 40 color bytes to Color RAM ($D800) for the given row.
;;
;;  IN:  X = row index (0..24)
;;       A = color (attribute byte)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_WriteAttr:
    PHA
    LDA lut_ScreenRowLo, X
    STA tmp+4
    LDA lut_ScreenRowHi, X
    CLC
    ADC #$98                   ; Map $4000 (Screen RAM) -> $D800 (Color RAM)
    STA tmp+5
    PLA
    LDY #39
:   STA (tmp+4), Y
    DEY
    BPL :-
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IntroStory_Frame   [3848]
;;
;;    Does a frame for the intro story.  It has a very strange way of returning
;;  control to the calling routine, though.
;;
;;    If A or B is pressed, it does a "double RTS" -- IE, not returning control
;;  to the calling routine, but returning control to the routine that called
;;  the calling routine.
;;
;;    If Start is pressed, the routine doesn't exit at all, and instead, the game
;;  jumps back to GameStart (which brings up the title screen -- escaping the intro
;;  story).
;;
;;    If none of those buttons are pressed, the routine exits normally
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IntroStory_Frame:
    JSR WaitForVBlank_L        ; wait for VBlank
    JSR DrawPalette_L          ; and draw the animating palette

    LDA #0
    STA joy_a                  ; clear A and B button catchers
    STA joy_b

    LDA #BANK_THIS             ; set current bank (needed when calling CallMusicPlay from
    STA cur_bank               ;   a swappable bank)
    JSR CallMusicPlay_L        ; Then call music play to keep music playing!

    JSR IntroStory_Joy         ; update joypad (Start jumps to GameStart_L -> TitleScreen)

    LDA joy_a                  ; check to see if either A or B were pressed
    ORA joy_b
    BNE :+                     ; if not...
      RTS                      ; ... exit normally

:   PLA                        ; if either A or B pressed, PLA to drop the last
    PLA                        ;  return address, then exit (does a double-RTS)
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Turn Menu Screen On  [8078]
;;
;;   Waits for VBlank, applies palette, then enables BG and Sprite rendering
;;   with default settings for menus.
;;
;;   Comes in 2 flavors... normal, and 'ClearOAM' -- both of which are the same, only
;;   the ClearOAM version, as the name implies, clears OAM (clearing all sprites).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TurnMenuScreenOn_ClearOAM:  ; [8087]
    JSR ClearOAM
    ; fall through to TurnMenuScreenOn

TurnMenuScreenOn:  ; [8091]
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  NewGamePartyGeneration  [2581]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NewGamePartyGeneration:
    JSR LoadNewGameCHRPal   ; Load up all the CHR and palettes necessary for the New Game menus

    LDX #$3F                ; Initialize the ptygen buffer!
:   LDA lut_PtyGenBuf, X    ;  all $40 bytes!  ($10 bytes per character)
    STA ptygen, X
    DEX
    BPL :-

    LDA #$00        ; Null-terminates draw buffer for character name
    STA $60

@Char_0:                    ; To Character generation for each of the 4 characters
    LDA #$00                ;   branching back to the previous char if cancelled
    STA char_index
    JSR DoPartyGen_OnCharacter
    BCS @Char_0
@Char_1:
    LDA #$10
    STA char_index
    JSR DoPartyGen_OnCharacter
    BCS @Char_0
@Char_2:
    LDA #$20
    STA char_index
    JSR DoPartyGen_OnCharacter
    BCS @Char_1
@Char_3:
    LDA #$30
    STA char_index
    JSR DoPartyGen_OnCharacter
    BCS @Char_2

    ; Once all 4 characters have been generated and named...
    JSR PtyGen_DrawScreen   ; Draw the screen one more time

@ConfirmLoop:
    JSR PtyGen_Frame        ; Keep multiplexer, music, and joypad running
    LDA joy_a
    ORA joy_start
    BNE PtyGen_Confirmed    ; Pressing Space or Return confirms party!
    LDA joy_b
    BEQ @ConfirmLoop
    JMP @Char_3             ; Pressing B returns to Char 3 generation

PtyGen_Confirmed:
    JSR PlaySFX_MenuSel

    ; Move class and name selection into actual character stats
    LDX #$00
    JSR @RecordClassAndName
    LDX #$10
    JSR @RecordClassAndName
    LDX #$20
    JSR @RecordClassAndName
    LDX #$30
    JSR @RecordClassAndName

    ; Disable multiplexer and clear sprites before continuing
    LDA #0
    STA spr_multiplex_mode
    STA shadow_spr_en
    STA SPENA
    RTS

@RecordClassAndName:
    TXA                     ; X is the ptygen source index ($10 bytes per character)
    ASL A
    ASL A
    TAY                     ; Y is the ch_stats dest index ($40 bytes per character)

    LDA ptygen_class, X     ; copy class
    STA ch_class, Y

    LDA ptygen_name+0, X    ; and name
    STA ch_name+0, Y
    LDA ptygen_name+1, X
    STA ch_name+1, Y
    LDA ptygen_name+2, X
    STA ch_name+2, Y
    LDA ptygen_name+3, X
    STA ch_name+3, Y
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DoPartyGen_OnCharacter  [2713]
;;
;;    Does character selection and name input for one character.
;;
;;  input:      ptygen = filled appropriately
;;          char_index = $00, $10, $20, $30 to indicate which character we're setting
;;
;;  output:    C is cleared if user confirmed/named character
;;             C is set if user pressed B to cancel/go back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoPartyGen_OnCharacter:
    JSR PtyGen_DrawScreen           ; Draw the Party generation screen

  @MainLoop:
    JSR PtyGen_Frame                ; Do a frame and update joypad input

.if SKIP_TO_MAP
    LDA joy_start
    BEQ :+
    PLA                             ; Drop return address from JSR DoPartyGen_OnCharacter
    PLA
    JMP PtyGen_Confirmed            ; Start (F1) pressed -> confirm party immediately & go to map!
:
.endif

    LDA joy_a
    BEQ @CheckB
    LDA #0
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    JSR DoNameInput                 ; A pressed -> go to name input screen!
    BCS DoPartyGen_OnCharacter      ; If cancelled (B at cursor 0), redraw screen & resume class select
    CLC                             ; Name successfully entered! Return Carry Clear
    RTS

@CheckB:
    LDA joy_b
    BEQ :+
      SEC                           ; B pressed on class screen -> cancel back to previous character
      RTS

  : LDA joy
    AND #$0F
    CMP joy_prevdir
    BEQ @MainLoop                   ; No change in directional input -> loop

    STA joy_prevdir                 ; Record new directional input as prevdir
    CMP #$00                        ; If directional input released -> loop
    BEQ @MainLoop

    ; User input: Left/Right (A/D key) to select the class
    LDX char_index
    LDA joy_prevdir
    AND #(LEFT | UP)                ; Left (A key, $02) or Up (W key, $08)
    BEQ @CheckRight

    ; Decrement class (wrap 0 -> 5)
    LDA ptygen_class, X
    SEC
    SBC #1
    BPL :+
      LDA #5
  : STA ptygen_class, X
    JMP @UpdateClass

@CheckRight:
    ; Right (D key, $01) or Down (S key, $04) -> Increment class (wrap 5 -> 0)
    LDA ptygen_class, X
    CLC
    ADC #1
    CMP #6
    BCC :+
      LDA #0
  : STA ptygen_class, X

@UpdateClass:
    LDA #$01                        ; Menustall flag (drawing while display is active)
    STA menustall
    LDX char_index                  ; Redraw the on-screen class name
    JSR PtyGen_DrawOneText
    JMP @MainLoop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DoNameInput  [2766]
;;
;;    Does the name input screen.  Draw the screen, gets the name, etc, etc.
;;
;;  input:      ptygen = should be filled appropriately
;;          char_index = $00, 10, 20, 30 to indicate which character's name we're setting
;;
;;  output:    C is cleared to indicate name successfully input
;;             C is set to indicate cancel / go back
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoNameInput:
    ; Turn off hero multiplexer for name screen (single cursor only)
    LDA #$00
    STA spr_multiplex_mode
    STA spr_irq_zone
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY

    LDA #$00
    STA menustall           ; zero a bunch of misc vars being used here
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    STA joy
    STA joy_prevdir

    STA cursor              ; letter of the name we're inputting (0-3)
    STA namecurs_x          ; X position of letter selection cursor (0-9)
    STA namecurs_y          ; Y position (0-6)

    ; Some local temp vars
    @cursoradd    = $63
    @selectedtile = $10

    JSR DrawNameInputScreen

    LDX char_index          ; wipe this character's name
    LDA #$FF
    STA ptygen_name, X
    STA ptygen_name+1, X
    STA ptygen_name+2, X
    STA ptygen_name+3, X

    JSR NameInput_DrawName          ; Draw the initially empty name box

    JSR TurnMenuScreenOn_ClearOAM   ; now that everything is drawn, turn the screen on

    LDA #$01                ; Set menustall, as future drawing will
    STA menustall           ;  be with the screen on

  @MainLoop:
    JSR CharName_Frame      ; Do a frame & get input

    LDA joy_a
    BNE @A_Pressed          ; Check if A or B pressed
    LDA joy_b
    BNE @B_Pressed

    LDA joy                 ; Otherwise see if D-pad state has changed
    AND #$0F
    CMP joy_prevdir
    BEQ @MainLoop           ; no change? Jump back
    STA joy_prevdir

    ; D-pad state has changed, see what it changed to
    CMP #$00
    BEQ @MainLoop           ; if released, do nothing and loop

    CMP #$04
    BCC @Left_Or_Right      ; if < 4, L or R pressed

    CMP #$08                ; otherwise, if == 8, Up pressed
    BNE @Down               ; otherwise, if != 8, Down pressed

  @Up:
    DEC namecurs_y          ; DEC cursor Y position
    BPL @MainLoop
    LDA #$06                ; wrap 0->6
    STA namecurs_y
    JMP @MainLoop

  @Down:
    INC namecurs_y          ; INC cursor Y position
    LDA namecurs_y
    CMP #$07                ; wrap 6->0
    BCC @MainLoop
    LDA #$00
    STA namecurs_y
    JMP @MainLoop

  @Left_Or_Right:
    CMP #$02                ; if D-pad state == 2, Left pressed
    BNE @Right              ; else, Right pressed

  @Left:
    DEC namecurs_x          ; DEC cursor X position
    BPL @MainLoop
    LDA #$09                ; wrap 0->9
    STA namecurs_x
    JMP @MainLoop

  @Right:
    INC namecurs_x          ; INC cursor X position
    LDA namecurs_x
    CMP #$0A                ; wrap 9->0
    BCC @MainLoop
    LDA #$00
    STA namecurs_x
    JMP @MainLoop

  @B_Pressed:
    LDA #$FF                ; if B was pressed, erase the previous tile
    STA @selectedtile       ;   by setting selectedtile to be a space

    LDA cursor              ; then by pre-emptively moving the cursor back
    SEC                     ;   so @SetTile will overwrite the prev char
    SBC #$01                ;   instead of the next one
    BMI @Cancel             ; if cursor was already 0, cancel back to class select!
    STA cursor

    LDA #$00                ; set cursoradd to 0 so @SetTile doesn't change
    STA @cursoradd          ; the cursor
    STA joy_b               ; clear joy_b as well
    JMP @SetTile

  @Cancel:
    LDA #$00
    STA joy_b
    SEC                     ; SEC to indicate user cancelled back to class select
    RTS

  @A_Pressed:
    LDX namecurs_y                  ; when A is pressed, clear joy_a
    LDA #$00
    STA joy_a                       ; Then get the tile they selected by first
    LDA lut_NameInputRowStart, X    ;  running the Y cursor through a row lut
    CLC
    ADC namecurs_x                  ; add X cursor
    ASL A                           ; and multiply by 2 -- since there are spaces between tiles
    TAX                             ; use that value as an index to the lut_NameInput
    LDA lut_NameInput, X
    STA @selectedtile               ; record selected tile
    LDA #$01
    STA @cursoradd                  ; set cursoradd to 1 to indicate we want @SetTile to move the cursor forward

    LDA cursor                      ; check current cursor position
    CMP #$04                        ;  If we've already input 4 letters for this name....
    BCS @Done                       ;  .. then we're done. Branch ahead
                                    ; Otherwise, fall through to SetTile

  @SetTile:
    LDA cursor                  ; use cursor and char_index to access the appropriate
    CLC                         ;   letter in this character's name
    ADC char_index
    TAX
    LDA @selectedtile
    STA ptygen_name, X          ; and write the selected tile

    JSR NameInput_DrawName      ; Redraw the name as it appears on-screen

    LDA cursor                  ; Then add to our cursor
    CLC
    ADC @cursoradd
    BPL :+                      ; clipping at 0 (if subtracting -- although this never happens)
      LDA #$00
  : STA cursor

    JMP @MainLoop               ; And keep going!

  @Done:
    CLC                         ; CLC to indicate name was successfully input
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_Frame  [2933]
;;
;;    Does typical frame handling for the Party Gen screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_Frame:
    JSR WaitForVBlank_L

    LDA #BANK_THIS
    STA cur_bank
    JSR CallMusicPlay_L

    JMP PtyGen_Joy


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CharName_Frame  [2957]
;;
;;    Does typical frame stuff for the Character naming screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CharName_Frame:
    JSR ClearOAM            ; wipe OAM then draw the cursor
    JSR CharName_DrawCursor

    JSR WaitForVBlank_L     ; VBlank

    LDA #BANK_THIS          ; keep playing music
    STA cur_bank
    JSR CallMusicPlay_L

    JMP PtyGen_Joy          ; then update joy


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_Joy  [2987]
;;
;;    Updates joypad data and plays button-related sound effects for
;;    Party Generation screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_Joy:
    LDA joy
    AND #$0F
    STA tmp+7                       ; Save old directional buttons

    JSR UpdateJoy_L                 ; Update joypad and keyboard data

    LDA joy_a                       ; If either A or B pressed...
    ORA joy_b
    BEQ :+
      JMP PlaySFX_MenuSel           ; Play selection SFX

:   LDA joy                         ; Check new directional buttons
    AND #$0F
    BEQ @Exit                       ; None pressed -> exit
    CMP tmp+7                       ; Same as previous frame?
    BEQ @Exit                       ; No new direction -> exit
    JMP PlaySFX_MenuMove            ; Play move chirp SFX

@Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_DrawScreen  [2684]
;;
;;    Prepares and draws the Party Generation screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_DrawScreen:
    ; Set border to black, background to blue, and multicolor border registers
    LDA #$0F
    STA cur_pal + $0C          ; Virtual palette border = Black ($0F) for title screen
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0
    LDA #COLOR_WHITE
    STA BGCOL1
    LDA #COLOR_DARKGREY
    STA BGCOL2

    ; Paint Screen RAM with character $00 (solid black block)
    LDX #$00
    LDA #$00
@LoopScreen:
    STA $4000, X
    STA $4100, X
    STA $4200, X
    STA $4300, X
    INX
    BNE @LoopScreen

    ; Paint Color RAM with character color 00 (black)
    LDX #$00
    LDA #COLOR_BLACK
@LoopColor:
    STA COLOR_RAM, X
    STA COLOR_RAM + $0100, X
    STA COLOR_RAM + $0200, X
    STA COLOR_RAM + $0300, X
    INX
    BNE @LoopColor

    ; Ensure VIC-II Bank 1 ($4000-$7FFF) and standard text mode are set
    LDA CI2DRA
    ORA #$03
    STA CI2DRA
    LDA CI2PRA
    AND #$FC
    ORA #VIC_BANK1
    STA CI2PRA

    LDA #$1B
    STA SCROLY
    LDA #$18                   ; 40 cols, MultiColor text mode ON
    STA SCROLX
    LDA #$02                   ; Screen: $4000, Charset: $4800
    STA VMCSB

    ; Clear soft2000 & joypad catchers
    LDA #$08
    STA soft2000
    LDA #0
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    STA joy
    STA joy_prevdir

    ; Draw the 4 character boxes and text
    JSR PtyGen_DrawBoxes
    JSR PtyGen_DrawText

    ; Enable 2-zone raster multiplexer for all 4 heroes
    LDA #1
    STA spr_multiplex_mode
    LDA #0
    STA spr_irq_zone
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_DrawBoxes  [3016]
;;
;;    Draws the 4 boxes for the Party Generation screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_DrawBoxes:
    LDA #0
    STA tmp+15       ; reset loop counter to zero

@Loop:
    JSR @Box         ; draw the next character's box
    LDA tmp+15
    CLC
    ADC #$10         ; incrementing by $10 each time (indexes ptygen buffer)
    STA tmp+15
    CMP #$40
    BCC @Loop
    RTS

@Box:
    LDX tmp+15           ; get ptygen index in X

    LDA ptygen_box_x, X  ; get X,Y coords from ptygen buffer
    STA box_x
    LDA ptygen_box_y, X
    STA box_y

    LDA #10              ; width = 10
    STA box_wd
    LDA #10              ; height = 10
    STA box_ht

    LDA #0
    STA menustall        ; disable menustalling
    JMP DrawBox          ; draw the box, and exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_DrawText  [3055]
;;
;;    Draws the text for all 4 character boxes in the Party Generation screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_DrawText:
    LDA #0             ; start loop counter at zero
  @MainLoop:
     PHA                ; push loop counter to back it up
     JSR @DrawOne       ; draw one character's strings
     PLA                ;  pull loop counter
     CLC                ; and increase it to point to next character's data
     ADC #$10           ;  ($10 bytes per char in 'ptygen')
     CMP #$40
     BCC @MainLoop      ;  loop until all 4 chars drawn
    RTS

  @DrawOne:
    TAX                 ; put the ptygen index in X for upcoming routine

      ; no JMP or RTS -- code flows seamlessly into PtyGen_DrawOneText

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_DrawOneText  [3093]
;;
;;    This draws text for *one* of the character boxes in the Party Generation
;;  screen.  This is called by the above routine to draw all 4 of them at once,
;;  but is also called to redraw an individual class name when the player changes
;;  the class of the selected character.
;;
;;    The text drawn here is just two short strings.  First is the name of the
;;  selected class (Fighter/Thief/etc).  Second is the character's name.
;;
;;    Text is drawn by simply copying short strings to the format buffer, then
;;  calling DrawComplexString to draw them.  The character's name is simply
;;  the 4 letters copied over.. whereas the class name makes use of one
;;  of DrawComplexString's control codes.  See that routine for further details.
;;
;;  IN:  X = ptygen index of the char whose text we want to draw
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_DrawOneText:
    LDA ptygen_class_x, X   ; get X,Y coords where we're going to place
    STA dest_x              ;  the class name
    LDA ptygen_class_y, X
    STA dest_y

    LDA ptygen_class, X     ; get the selected class
    CLC
    ADC #$F0                ; add $F0 to select the class' "item name"
    STA format_buf-1        ;  store that as 2nd byte in format string
    LDA #$02                ; first byte in string is $02 -- the control code to
    STA format_buf-2        ;  print an item name

    LDA #<(format_buf-2)    ; set the text pointer to point to the start of the 2-byte
    STA text_ptr            ;  string we just constructed
    LDA #>(format_buf-2)
    STA text_ptr+1

    LDA #BANK_THIS          ; set cur and ret banks (see DrawComplexString for why)
    STA cur_bank
    STA ret_bank

    TXA                     ; back up our index (DrawComplexString will corrupt it)
    PHA
    JSR DrawComplexString   ; draw the string
    PLA
    TAX                     ; and restore our index

    LDA ptygen_name, X      ; next, copy over the 4-byte name of the character
    STA format_buf-4        ;  over to the format buffer
    LDA ptygen_name+1, X
    STA format_buf-3
    LDA ptygen_name+2, X
    STA format_buf-2
    LDA ptygen_name+3, X
    STA format_buf-1

    LDA ptygen_name_x, X    ; set destination coords appropriately
    STA dest_x
    LDA ptygen_name_y, X
    STA dest_y

    LDA #<(format_buf-4)    ; set pointer to start of 4-byte string
    STA text_ptr
    LDA #>(format_buf-4)
    STA text_ptr+1

    LDA #BANK_THIS          ; set banks again
    STA cur_bank
    STA ret_bank

    JMP DrawComplexString   ; then draw another complex string -- and exit!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PtyGen_DrawCursor  [3155]
;;
;;    Draws the cursor for the Party Generation screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PtyGen_DrawCursor:
    LDX char_index          ; use the current index to get the cursor
    LDA ptygen_curs_x, X    ;  coords from the ptygen buffer.
    STA spr_x
    LDA ptygen_curs_y, X
    STA spr_y
    JMP DrawCursor          ; and draw the cursor there


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CharName_DrawCursor  [3173]
;;
;;    Draws the cursor for the Character Naming screen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CharName_DrawCursor:
    LDA namecurs_x          ; X position = (cursx * 16) + 88
    ASL A
    ASL A
    ASL A
    ASL A
    CLC
    ADC #88
    STA spr_x

    LDA namecurs_y          ; Y position = (cursy * 16) + 106
    ASL A
    ASL A
    ASL A
    ASL A
    CLC
    ADC #106
    STA spr_y

    JMP DrawCursor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  NameInput_DrawName  [3245]
;;
;;    Used during party generation.. specifically the name input screen
;;  to draw the character's name at the top of the screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NameInput_DrawName:
    @buf  = $5C     ; local - buffer to hold the name for printing

    LDX char_index          ; copy the character's name to our temp @buf
    LDA ptygen_name, X
    STA @buf
    LDA ptygen_name+1, X
    STA @buf+1
    LDA ptygen_name+2, X
    STA @buf+2
    LDA ptygen_name+3, X
    STA @buf+3              ; The code assumes @buf+4 ($60) is 0 (null terminator)

    LDA #>@buf              ; Set the text pointer
    STA text_ptr+1
    LDA #<@buf
    STA text_ptr

    LDA #BANK_THIS          ; set cur/ret banks
    STA cur_bank
    STA ret_bank

    LDA #18                 ; set X/Y positions for the name to be printed (Row 3, Col 18)
    STA dest_x
    LDA #3
    STA dest_y

    LDA #$01                ; drawing while screen is on, so set menustall
    STA menustall

    JMP DrawComplexString   ; Then draw the name and exit!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawNameInputScreen  [3287]
;;
;;  Draws everything except for the player's name.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawNameInputScreen:
    ; Set border to black, background to blue, and multicolor border registers
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0
    LDA #COLOR_WHITE
    STA BGCOL1
    LDA #COLOR_DARKGREY
    STA BGCOL2

    ; Paint Screen RAM with character $00 (solid black block)
    LDX #$00
    LDA #$00
@LoopScreen:
    STA $4000, X
    STA $4100, X
    STA $4200, X
    STA $4300, X
    INX
    BNE @LoopScreen

    ; Paint Color RAM with character color 00 (black)
    LDX #$00
    LDA #COLOR_BLACK
@LoopColor:
    STA COLOR_RAM, X
    STA COLOR_RAM + $0100, X
    STA COLOR_RAM + $0200, X
    STA COLOR_RAM + $0300, X
    INX
    BNE @LoopColor

    ; Ensure VIC-II Bank 1 and standard text mode are set
    LDA CI2DRA
    ORA #$03
    STA CI2DRA
    LDA CI2PRA
    AND #$FC
    ORA #VIC_BANK1
    STA CI2PRA

    LDA #$1B
    STA SCROLY
    LDA #$18                   ; 40 cols, MultiColor text mode ON
    STA SCROLX
    LDA #$02                   ; Screen: $4000, Charset: $4800
    STA VMCSB

    ; Clear soft2000 & joypad catchers
    LDA #$08
    STA soft2000
    LDA #0
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    STA joy
    STA joy_prevdir
    STA menustall

    ; Draw the small top box containing the player's name
    ; (Centered at X=16, Y=1, Width=8, Height=4)
    LDA #16
    STA box_x
    LDA #1
    STA box_y
    LDA #8
    STA box_wd
    LDA #4
    STA box_ht
    JSR DrawBox

    ; Draw the big bottom box containing alphabet input
    ; (Centered at X=8, Y=6, Width=23, Height=19)
    LDA #8
    STA box_x
    LDA #6
    STA box_y
    LDA #23
    STA box_wd
    LDA #19
    STA box_ht
    JSR DrawBox

    ; Print the NameInput LUT as a string inside the bottom box
    LDA #<lut_NameInput
    STA text_ptr
    LDA #>lut_NameInput
    STA text_ptr+1
    LDA #10
    STA dest_x
    LDA #7
    STA dest_y
    LDA #BANK_THIS
    STA cur_bank
    STA ret_bank
    JMP DrawComplexString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Name Input Row Start lut  [3344]
;;
;;    offset (in usable characters) to start of each row in lut_NameInput
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_NameInputRowStart:
  .BYTE  0, 10, 20, 30, 40, 50, 60  ; 10 characters of data per row


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Name Input lut  [3356]
;;
;;    This LUT contains the characters on the name input screen.
;;    Stored in null-terminated string format with $FF (spaces) and
;;    $01 (double line breaks) so it can be drawn in one pass.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_NameInput:
  .BYTE $8A, $FF, $8B, $FF, $8C, $FF, $8D, $FF, $8E, $FF, $8F, $FF, $90, $FF, $91, $FF, $92, $FF, $93, $01  ; A - J
  .BYTE $94, $FF, $95, $FF, $96, $FF, $97, $FF, $98, $FF, $99, $FF, $9A, $FF, $9B, $FF, $9C, $FF, $9D, $01  ; K - T
  .BYTE $9E, $FF, $9F, $FF, $A0, $FF, $A1, $FF, $A2, $FF, $A3, $FF, $BE, $FF, $BF, $FF, $C0, $FF, $FF, $01  ; U - Z ; , . <space>
  .BYTE $80, $FF, $81, $FF, $82, $FF, $83, $FF, $84, $FF, $85, $FF, $86, $FF, $87, $FF, $88, $FF, $89, $01  ; 0 - 9
  .BYTE $A4, $FF, $A5, $FF, $A6, $FF, $A7, $FF, $A8, $FF, $A9, $FF, $AA, $FF, $AB, $FF, $AC, $FF, $AD, $01  ; a - j
  .BYTE $AE, $FF, $AF, $FF, $B0, $FF, $B1, $FF, $B2, $FF, $B3, $FF, $B4, $FF, $B5, $FF, $B6, $FF, $B7, $01  ; k - t
  .BYTE $B8, $FF, $B9, $FF, $BA, $FF, $BB, $FF, $BC, $FF, $BD, $FF, $C2, $FF, $C3, $FF, $C4, $FF, $C5, $01  ; u - z - .. ! ?
  .BYTE $01
  .BYTE $FF, $FF, $FF, $9C, $8E, $95, $8E, $8C, $9D, $FF, $FF, $97, $8A, $96, $8E, $00                      ;   SELECT  NAME



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_PtyGenBuf
;;
;;    Initial template for the 4 character slots ($40 bytes total).
;;    Matches the NES format:
;;      +$00: Class ID
;;      +$01: Padding / Unused ($00)
;;      +$02..+$05: Name (4 bytes, $FF = empty)
;;      +$06..+$07: name_x, name_y
;;      +$08..+$09: class_x, class_y
;;      +$0A..+$0B: spr_x, spr_y
;;      +$0C..+$0D: box_x, box_y
;;      +$0E..+$0F: curs_x, curs_y
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_PtyGenBuf:
  ; Hero 0: Fighter (Top-Left)
  .BYTE $00, $00, $FF, $FF, $FF, $FF, 11,  9,  9,  3, 120,  90,  8,  1,  80,  74
  ; Hero 1: Thief (Top-Right)
  .BYTE $01, $00, $FF, $FF, $FF, $FF, 25,  9, 23,  3, 232,  90, 22,  1, 192,  74
  ; Hero 2: Black Belt (Bottom-Left)
  .BYTE $02, $00, $FF, $FF, $FF, $FF, 11, 22,  9, 16, 120, 194,  8, 14,  80, 178
  ; Hero 3: Red Mage (Bottom-Right)
  .BYTE $03, $00, $FF, $FF, $FF, $FF, 25, 22, 23, 16, 232, 194, 22, 14, 192, 178


; ==============================================================================
; Character Stat & Number Formatting Routines
; ==============================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Print Character Stat  [136]
;;
;;    Called by DrawComplexString to print a specific character stat
;;  String is printed to 'format_buf'
;;
;;  IN:  char_index = character index ($00, $40, $80, or $C0)
;;       A          = ID of stat to draw (between $03-0B and 2C-FF .. other values invalid)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintCharStat:
    CMP #$03      ; is ID == $03?
    BNE :+
      JMP @Level  ; if yes, print Level
:   CMP #$04
    BEQ @Exp      ; if $04, print Exp
    CMP #$05
    BEQ @CurHP    ; if $05, print CurHP
    CMP #$06
    BEQ @MaxHP    ; etc
    CMP #$07
    BEQ @Str
    CMP #$08
    BEQ @Agil
    CMP #$09
    BEQ @Int
    CMP #$0A
    BEQ @Vit
    CMP #$0B
    BEQ @Luck

    CMP #$3C
    BCS @CodeAbove3B   ; see if ID is >= #$3C

    CMP #$2C
    BCC @ExpToNext   ; see if ID is < #$2C (should never happen)

    ;;; code reaches here if the ID is between $2C-3B  (prints MP... cur or max)
      SEC
      SBC #$0C         ; subtract #$C  ($20-2F -- index + $20)
      CLC
      ADC char_index   ; add character index
      TAX
      LDA ch_mp-$20, X ; get MP  (need to subtract $20 because index is +$20)
      STA tmp          ;  and print it as 1 Digit
      JMP PrintNumber_1Digit


@CodeAbove3B:
    CMP #$42
    BCS @ExpToNext     ; see if ID is >= $42

    ;;; code reaches here if ID is between $3C-41  (prints substats, like Damage, Hit%, etc)
      SEC
      SBC #$3C            ; subtract #$3C  ($00-05)
      CLC
      ADC char_index      ; add character index
      TAX
      LDA ch_substats, X  ; get the substat
      STA tmp             ; write it as low byte
      LDA #0              ; set mid byte to 0 (need a mid byte for 3 Digit printing)
      STA tmp+1           ;  and print as 3 digits
      JMP PrintNumber_3Digit

    ;;; all other codes default to Exp to Next level
@ExpToNext:
      LDX char_index         ; get the index
      LDA ch_exptonext, X    ; low byte of Exp To Next
      STA tmp
      LDA ch_exptonext+1, X  ; mid byte
      STA tmp+1
      LDA #0                 ; high byte is 0 (5 digit numbers need a high byte)
      STA tmp+2              ; print it as 5 digits
      JMP PrintNumber_5Digit

@Exp:
    LDA #<(ch_exp - ch_stats)
    JMP @Stat6Digit

@CurHP:
    LDA #<(ch_curhp - ch_stats)
    JMP @Stat3Digit

@MaxHP:
    LDA #<(ch_maxhp - ch_stats)
    JMP @Stat3Digit

@Str:
    LDA #<(ch_str - ch_stats)
    JMP @Stat2Digit

@Agil:
    LDA #<(ch_agil - ch_stats)
    JMP @Stat2Digit

@Int:
    LDA #<(ch_int - ch_stats)
    JMP @Stat2Digit

@Vit:
    LDA #<(ch_vit - ch_stats)
    JMP @Stat2Digit

@Luck:
    LDA #<(ch_luck - ch_stats)
    JMP @Stat2Digit

@Stat1Digit:
    CLC
    ADC char_index
    TAX
    LDA ch_stats, X
    STA tmp
    JMP PrintNumber_1Digit

@Stat2Digit:
    CLC
    ADC char_index
    TAX
    LDA ch_stats, X
    STA tmp
    JMP PrintNumber_2Digit

@Stat3Digit:
    CLC
    ADC char_index     ; add character index to stat ID (currently in A)
    TAX                ; use this to index stat from start of player stats ($6100)
    LDA ch_stats, X
    STA tmp
    LDA ch_stats+1, X  ; read a 2-byte number
    STA tmp+1          ; and print it as 3-digits
    JMP PrintNumber_3Digit

@Stat6Digit:
    CLC
    ADC char_index      ; add character index to stat ID (currently in A)
    TAX                 ; use this to index stat from start of player stats ($6100)
    LDA ch_stats, X
    STA tmp
    LDA ch_stats+1, X   ; read a 3-byte number
    STA tmp+1
    LDA ch_stats+2, X
    STA tmp+2           ; and print it as 6-digits
    JMP PrintNumber_6Digit

;;  Stat Code = $03 -- character level
@Level:
    LDX char_index   ; Get Character index
    LDA ch_level, X  ; Get character's level
    CLC
    ADC #$01         ; Add 1 to it ($00 is "Level 1")
    STA tmp          ; and print it as 2-digit
    JMP PrintNumber_2Digit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Print Price  [287]
;;
;;    Fetches desired item price, then prints it to a temp drawing buffer
;;
;;  IN:  A = item ID whose price we're printing
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintPrice:
    JSR LoadPrice             ; just load the price
    JMP PrintNumber_5Digit    ; and print it as 5-digits!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Print Gold   [302]
;;
;;    Loads and prints current gold amount into a temporary drawing buffer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintGold:
    LDA gold     ; just copy the gold to the routine input vars
    STA tmp
    LDA gold+1
    STA tmp+1
    LDA gold+2
    STA tmp+2
    JMP PrintNumber_6Digit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Print Number   [320]
;;
;;    These routines print a number of a desired number of digits to format_buf.
;;  The number is right-aligned with zeros trimmed off the front
;;  (ie:  "  67" instead of "0067").  A pointer to the start of the buffer
;;  is then stored at text_ptr.
;;
;;  IN:  tmp = 3-byte number to print
;;
;;  OUT: format_buf = buffer receiving the printed string
;;       text_ptr   = pointer to start of buffer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintNumber_1Digit:
    LDA tmp              ; no real formatting involved in 1-digit numbers
    ORA #$80             ; convert to tile ID ($80-$89)
    STA format_buf-1
    LDA #<(format_buf-1)
    JMP PrintNumber_Exit

PrintNumber_2Digit:
    JSR FormatNumber_2Digits
    JSR TrimZeros_2Digits
    LDA #<(format_buf-2)
    JMP PrintNumber_Exit

PrintNumber_3Digit:
    JSR FormatNumber_3Digits
    JSR TrimZeros_3Digits
    LDA #<(format_buf-3)
    JMP PrintNumber_Exit

PrintNumber_4Digit:
    JSR FormatNumber_4Digits
    JSR TrimZeros_4Digits
    LDA #<(format_buf-4)
    JMP PrintNumber_Exit

PrintNumber_5Digit:
    JSR FormatNumber_5Digits
    JSR TrimZeros_5Digits
    LDA #<(format_buf-5)
    JMP PrintNumber_Exit

PrintNumber_6Digit:
    JSR FormatNumber_6Digits
    JSR TrimZeros_6Digits
    LDA #<(format_buf-6)
    JMP PrintNumber_Exit

PrintNumber_Exit:
    STA text_ptr          ; low byte of pointer in A
    LDA #>format_buf      ; high byte
    STA text_ptr+1
    LDA #0
    STA format_buf        ; ensure null-terminated
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Trim Zeros  [380]
;;
;;    Replaces leading '0' characters ($80) with a blank space character ($FF)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TrimZeros_6Digits:
    LDA format_buf-6
    CMP #$80
    BNE TrimZeros_RTS
    LDA #$FF
    STA format_buf-6

TrimZeros_5Digits:
    LDA format_buf-5
    CMP #$80
    BNE TrimZeros_RTS
    LDA #$FF
    STA format_buf-5

TrimZeros_4Digits:
    LDA format_buf-4
    CMP #$80
    BNE TrimZeros_RTS
    LDA #$FF
    STA format_buf-4

TrimZeros_3Digits:
    LDA format_buf-3
    CMP #$80
    BNE TrimZeros_RTS
    LDA #$FF
    STA format_buf-3

TrimZeros_2Digits:
    LDA format_buf-2
    CMP #$80
    BNE TrimZeros_RTS
    LDA #$FF
    STA format_buf-2

TrimZeros_RTS:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Format Number  [432]
;;
;;   Converts binary number in tmp to decimal digits ($80-$89) in format_buf.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FormatNumber_6Digits:
    LDX #8
@Loop:
    LDA tmp+2
    CMP lut_DecD6_hi, X
    BEQ @Equal
    BCS @Good

@Less:
    DEX
    BPL @Loop

    LDX #$80
    STX format_buf-6
    JMP FormatNumber_5Digits

@Equal:
    LDA tmp+1
    CMP lut_DecD6_md, X
    BEQ @Equal2
    BCC @Less
    BCS @Good

@Equal2:
    LDA tmp
    CMP lut_DecD6_lo, X
    BCC @Less

@Good:
    LDA tmp
    SEC
    SBC lut_DecD6_lo, X
    STA tmp
    LDA tmp+1
    SBC lut_DecD6_md, X
    STA tmp+1
    LDA tmp+2
    SBC lut_DecD6_hi, X
    STA tmp+2

    TXA
    CLC
    ADC #$81
    STA format_buf-6


FormatNumber_5Digits:
    LDX #8
@Loop:
    LDA tmp+2
    CMP lut_DecD5_hi, X
    BEQ @Equal
    BCS @Good

@Less:
    DEX
    BPL @Loop

    LDX #$80
    STX format_buf-5
    JMP FormatNumber_4Digits

@Equal:
    LDA tmp+1
    CMP lut_DecD5_md, X
    BEQ @Equal2
    BCC @Less
    BCS @Good

@Equal2:
    LDA tmp
    CMP lut_DecD5_lo, X
    BCC @Less

@Good:
    LDA tmp
    SEC
    SBC lut_DecD5_lo, X
    STA tmp
    LDA tmp+1
    SBC lut_DecD5_md, X
    STA tmp+1
    LDA tmp+2
    SBC lut_DecD5_hi, X
    STA tmp+2
    TXA
    CLC
    ADC #$81
    STA format_buf-5


FormatNumber_4Digits:
    LDX #8
@Loop:
    LDA tmp+1
    CMP lut_DecD4_md, X
    BEQ @Equal
    BCS @Good

@Less:
    DEX
    BPL @Loop

    LDX #$80
    STX format_buf-4
    JMP FormatNumber_3Digits

@Equal:
    LDA tmp
    CMP lut_DecD4_lo, X
    BCC @Less

@Good:
    LDA tmp
    SEC
    SBC lut_DecD4_lo, X
    STA tmp
    LDA tmp+1
    SBC lut_DecD4_md, X
    STA tmp+1
    TXA
    CLC
    ADC #$81
    STA format_buf-4


FormatNumber_3Digits:
    LDX #8
@Loop:
    LDA tmp+1
    CMP lut_DecD3_md, X
    BEQ @Equal
    BCS @Good

@Less:
    DEX
    BPL @Loop

    LDX #$80
    STX format_buf-3
    JMP FormatNumber_2Digits

@Equal:
    LDA tmp
    CMP lut_DecD3_lo, X
    BCC @Less

@Good:
    LDA tmp
    SEC
    SBC lut_DecD3_lo, X
    STA tmp
    LDA tmp+1
    SBC lut_DecD3_md, X
    STA tmp+1
    TXA
    CLC
    ADC #$81
    STA format_buf-3


FormatNumber_2Digits:
    LDX #0
    LDA tmp
@Loop:
    CMP #10
    BCC @Done
    SBC #10
    INX
    BNE @Loop

@Done:
    ORA #$80
    STA format_buf-1
    TXA
    ORA #$80
    STA format_buf-2
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Decimal conversion LUTs  [643]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_DecD6_hi:  .BYTE ^100000,^200000,^300000,^400000,^500000,^600000,^700000,^800000,^900000
lut_DecD6_md:  .BYTE >100000,>200000,>300000,>400000,>500000,>600000,>700000,>800000,>900000
lut_DecD6_lo:  .BYTE <100000,<200000,<300000,<400000,<500000,<600000,<700000,<800000,<900000

lut_DecD5_hi:  .BYTE ^10000,^20000,^30000,^40000,^50000,^60000,^70000,^80000,^90000
lut_DecD5_md:  .BYTE >10000,>20000,>30000,>40000,>50000,>60000,>70000,>80000,>90000
lut_DecD5_lo:  .BYTE <10000,<20000,<30000,<40000,<50000,<60000,<70000,<80000,<90000

lut_DecD4_md:  .BYTE >1000,>2000,>3000,>4000,>5000,>6000,>7000,>8000,>9000
lut_DecD4_lo:  .BYTE <1000,<2000,<3000,<4000,<5000,<6000,<7000,<8000,<9000

lut_DecD3_md:  .BYTE >100,>200,>300,>400,>500,>600,>700,>800,>900
lut_DecD3_lo:  .BYTE <100,<200,<300,<400,<500,<600,<700,<800,<900


; ==============================================================================
; Main Menu Logic & Navigation (Phase 4)
; ==============================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Enter Main Menu  [6154]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterMainMenu:
    LDA #$51
    STA music_track                 ; Menu BGM track ($51)
    JSR LoadMenuCHRPal              ; Load menu CHR, sprites, and palettes

;; ResumeMainMenu redraws the main menu and activates the sprite multiplexer.
ResumeMainMenu:
    LDA #0
    STA menustall
    JSR DrawMainMenu                ; Draw all boxes and character stat bodies

    LDA #0
    STA cursor
    STA menu_cursor_index
    STA menu_cursor_mode            ; 0 = Option Box cursor
    STA joy
    STA joy_prevdir
    STA spr_irq_zone

    LDA #5                          ; 5 options (Item, Magic, Weapon, Armor, Status)
    STA cursor_max

    LDA #2                          ; Activate Main Menu 2-Zone Multiplexer
    STA spr_multiplex_mode

MainMenuLoop:
    JSR MenuFrame                   ; VBlank sync, audio update, joypad read

    LDA cursor
    STA menu_cursor_index           ; Keep multiplexer cursor in sync

    LDA joy_b
    BNE @B_Pressed
    LDA joy_a
    BNE @A_Pressed

    JSR MoveCursorUpDown            ; Navigate options with Up/Down
    JMP MainMenuLoop

@B_Pressed:
    LDA #0
    STA spr_multiplex_mode          ; Restore standard IRQ
    STA SPENA                       ; Turn off sprites
    STA joy_a
    STA joy_b
    STA joy_start
    JSR ClearOAM
    RTS                             ; Exit Main Menu

@A_Pressed:
    JSR PlaySFX_MenuSel             ; Confirm chirp
    LDA cursor
    BNE @NotItem

@Item:
    JSR EnterItemMenu
    JMP ResumeMainMenu

@NotItem:
    CMP #$01
    BNE @NotMagic

@MagicLoop:
    JSR MainMenuSubTarget           ; Select character 0..3
    BCS @EscapeSubTarget            ; Cancelled via B

    LDA submenu_targ                ; 0..3
    ASL A
    ASL A
    ASL A
    ASL A
    ASL A
    ASL A                           ; Shift to $00, $40, $80, $C0
    TAX
    LDA ch_ailments, X
    CMP #$01                        ; Dead?
    BEQ @CantUseMagic
    CMP #$02                        ; Stone?
    BNE @CanUseMagic
@CantUseMagic:
    JSR PlaySFX_Error               ; Buzz SFX
    JMP @MagicLoop
@CanUseMagic:
    JSR EnterMagicMenu
    JMP ResumeMainMenu

@NotMagic:
    CMP #$02
    BNE @NotWeapon
@Weapon:
    LDA #ch_weapons-ch_stats        ; Offset for Weapon data
    STA equipoffset
    JSR EnterEquipMenu
    JMP ResumeMainMenu

@NotWeapon:
    CMP #$03
    BNE @Status
@Armor:
    LDA #ch_armor-ch_stats          ; Offset for Armor data
    STA equipoffset
    JSR EnterEquipMenu
    JMP ResumeMainMenu

@Status:
    JSR MainMenuSubTarget           ; Select character for Status
    BCS @EscapeSubTarget
    JSR EnterStatusMenu
    JMP ResumeMainMenu

@EscapeSubTarget:
    LDA #0
    STA cursor
    STA menu_cursor_index
    STA menu_cursor_mode
    LDA #5
    STA cursor_max
    JMP MainMenuLoop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Main Menu Sub Target  [6294]
;;
;;  Selects one of the 4 party members (0..3) using 2x2 D-pad navigation.
;;  OUT:  C = set if B pressed (cancelled)
;;            clear if A pressed (confirmed)
;;        submenu_targ = selected character (0..3)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainMenuSubTarget:
    LDA #0
    STA cursor
    STA menu_cursor_index
    LDA #1                          ; SubTarget cursor mode
    STA menu_cursor_mode
    STA joy
    STA joy_prevdir

@Loop:
    JSR MenuFrame
    LDA cursor
    STA menu_cursor_index

    LDA joy_b
    BNE @B_Pressed
    LDA joy_a
    BNE @A_Pressed

    JSR MoveMainMenuSubCursor
    JMP @Loop

@B_Pressed:
    LDA #0
    STA menu_cursor_mode
    SEC
    RTS

@A_Pressed:
    LDA cursor
    STA submenu_targ
    LDA #0
    STA menu_cursor_mode
    CLC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Move Main Menu Sub Cursor  [7846]
;;
;;  Navigates a 2x2 grid:
;;    0: Top-Left  (Hero 0)    1: Top-Right (Hero 1)
;;    2: Bot-Left  (Hero 2)    3: Bot-Right (Hero 3)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveMainMenuSubCursor:
    LDA joy
    AND #$0F
    CMP joy_prevdir
    BEQ @Exit
    STA joy_prevdir
    CMP #0
    BEQ @Exit

    LDX #$01                        ; Left/Right toggles bit 0 (Hero 0 <-> Hero 1)
    CMP #$04                        ; Up/Down is >= 4
    BCC :+
    LDX #$02                        ; Up/Down toggles bit 1 (Top <-> Bottom)
:   TXA
    EOR cursor
    STA cursor
    STA menu_cursor_index
    JMP PlaySFX_MenuMove

@Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Move Cursor Up / Down  [7877]
;;
;;  Navigates vertical list (cursor 0..cursor_max-1) with wrapping.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveCursorUpDown:
    LDA joy
    AND #$0C                        ; Up ($08) and Down ($04)
    CMP joy_prevdir
    BEQ @Exit
    STA joy_prevdir
    CMP #0
    BEQ @Exit

    CMP #$04                        ; Down pressed?
    BNE @Up

@Down:
    LDA cursor
    CLC
    ADC #1
    CMP cursor_max
    BCC @Move
    LDA #0
    BEQ @Move

@Up:
    LDA cursor
    SEC
    SBC #1
    BPL @Move
    LDA cursor_max
    SEC
    SBC #1

@Move:
    STA cursor
    STA menu_cursor_index
    JMP PlaySFX_MenuMove

@Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Menu Frame  [7800]
;;
;;  Synchronizes to VBlank, updates audio, and refreshes joypad inputs.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuFrame:
    JSR WaitForVBlank_L
    LDA #BANK_THIS
    STA cur_bank
    JSR CallMusicPlay_L
    LDA #0
    STA joy_a
    STA joy_b
    JMP UpdateJoy_L


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PlaySFX_Error
;;
;;  Low buzz sound effect for invalid menu actions.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlaySFX_Error:
    lda #8                          ; 8 frames duration
    sta sq2_sfx
    lda #<$1500                     ; Low buzz frequency (~330 Hz)
    sta V2FREQ_L
    lda #>$1500
    sta V2FREQ_H
    lda #$04                        ; Attack=0, Decay=4
    sta V2AD
    lda #$00                        ; Sustain=0, Release=0
    sta V2SR
    lda #SID_SAW
    sta V2CR
    lda #(SID_SAW | SID_GATE)
    sta V2CR
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Submenu Stubs (Phase 5 placeholders)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EnterMagicMenu  [6344]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterMagicMenu:
    LDA #0
    STA spr_multiplex_mode          ; Disable raster multiplexer
    STA spr_irq_zone
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY

    LDA #0
    STA menustall
    STA descboxopen

    JSR ClearMenuScreen
    JSR DrawMagicMenuMainBox
    PHP

    LDA #$07
    JSR DrawMainItemBox
    INC dest_y
    LDA #$29
    JSR DrawCharMenuString
    JSR TurnMenuScreenOn_ClearOAM

    PLP
    BCC :+
      JMP MenuWaitForBtn_SFX

:   LDA #0
    STA joy
    STA joy_prevdir

MagicMenu_Loop:
    JSR ClearOAM
    JSR DrawMagicMenuCursor
    JSR MenuFrame

    LDA joy_a
    BNE @A_Pressed
    LDA joy_b
    BNE @B_Pressed

    JSR MoveMagicMenuCursor
    JMP MagicMenu_Loop

  @B_Pressed:
    RTS

  @A_Pressed:
    JSR PlaySFX_MenuSel
    JSR UseMagic_GetRequiredMP
    BCS @HaveMP

      LDA #$32
      JSR DrawItemDescBox
      JMP MagicMenu_Loop

  @HaveMP:
    LDA submenu_targ
    LSR A
    ROR A
    ROR A
    ORA cursor
    TAX

    ASL A
    AND #$38
    ORA ch_spells, X
    CLC
    ADC #MG_START-1

    CMP #MG_CURE
    BNE :+
      JMP UseMagic_CURE
:   CMP #MG_CUR2
    BNE :+
      JMP UseMagic_CUR2
:   CMP #MG_CUR3
    BNE :+
      JMP UseMagic_CUR3
:   CMP #MG_CUR4
    BNE :+
      JMP UseMagic_CUR4
:   CMP #MG_HEAL
    BNE :+
      JMP UseMagic_HEAL
:   CMP #MG_HEL3
    BNE :+
      JMP UseMagic_HEL3
:   CMP #MG_HEL2
    BNE :+
      JMP UseMagic_HEL2
:   CMP #MG_PURE
    BNE :+
      JMP UseMagic_PURE
:   CMP #MG_LIFE
    BNE :+
      JMP UseMagic_LIFE
:   CMP #MG_LIF2
    BNE :+
      JMP UseMagic_LIF2
:   CMP #MG_WARP
    BNE :+
      JMP UseMagic_WARP
:   CMP #MG_SOFT
    BNE :+
      JMP UseMagic_SOFT
:   CMP #MG_EXIT
    BNE :+
      JMP UseMagic_EXIT

:   LDA #$33
    JSR DrawItemDescBox
    JMP MagicMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_CURE  [6473]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_CURE:
    LDA framecounter
    AND #$0F
    ORA #$10
    BNE UseMagic_CureFamily

UseMagic_CUR2:
    LDA framecounter
    AND #$1F
    ORA #$20
    BNE UseMagic_CureFamily

UseMagic_CUR3:
    LDA framecounter
    AND #$3F
    ORA #$40

UseMagic_CureFamily:
    STA hp_recovery
    JSR DrawItemTargetMenu
    LDA #$2B
    JSR DrawItemDescBox

 CureFamily_Loop:
    JSR ItemTargetMenuLoop
    BCS CureFamily_Exit

    LDA cursor
    ROR A
    ROR A
    ROR A
    AND #$C0
    TAX

    LDA ch_ailments, X
    CMP #$01
    BEQ CureFamily_CantUse
    CMP #$02
    BEQ CureFamily_CantUse

    LDA hp_recovery
    JSR MenuRecoverHP_Abs
    JSR DrawItemTargetMenu

    LDX mp_required
    DEC ch_magicdata, X

    JSR MenuWaitForBtn_SFX

  CureFamily_Exit:
    JMP EnterMagicMenu

  CureFamily_CantUse:
    JSR PlaySFX_Error
    JMP CureFamily_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_CUR4  [6532]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_CUR4:
    JSR DrawItemTargetMenu
    LDA #$2B
    JSR DrawItemDescBox
    JSR ItemTargetMenuLoop
    BCS CureFamily_Exit

    LDA cursor
    ROR A
    ROR A
    ROR A
    AND #$C0
    TAX

    LDA ch_maxhp+1, X
    STA ch_curhp+1, X
    LDA ch_maxhp, X
    STA ch_curhp, X

    JSR DrawItemTargetMenu
    LDX mp_required
    DEC ch_magicdata, X

    JSR MenuWaitForBtn_SFX
    JMP EnterMagicMenu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_HEAL  [6561]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_HEAL:
    LDA framecounter
    AND #$07
    CLC
    ADC #$10
    BNE UseMagic_HealFamily

UseMagic_HEL2:
    LDA framecounter
    AND #$0F
    CLC
    ADC #$20
    BNE UseMagic_HealFamily

UseMagic_HEL3:
    LDA framecounter
    AND #$1F
    CLC
    ADC #$40

UseMagic_HealFamily:
    STA hp_recovery
    LDA #$2C
    JSR DrawItemDescBox
    JSR ClearOAM
    JSR MenuWaitForBtn

    LDA joy
    AND #$80
    BEQ HealFamily_Exit

    LDA hp_recovery
    JSR MenuRecoverPartyHP
    LDX mp_required
    DEC ch_magicdata, X
    JSR MenuWaitForBtn_SFX

 HealFamily_Exit:
    JMP EnterMagicMenu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_LIFE  [6604]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_LIFE:
    JSR DrawItemTargetMenu
    LDA #$2E
    JSR DrawItemDescBox
  @Loop:
    JSR ItemTargetMenuLoop
    BCS HealFamily_Exit

    LDA #$01
    STA tmp
    JSR CureOBAilment
    BCS @CantUse

    LDA #1
    STA ch_curhp, X

    LDX mp_required
    DEC ch_magicdata, X

    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX
    JMP EnterMagicMenu

  @CantUse:
    JSR PlaySFX_Error
    JMP @Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_LIF2  [6632]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_LIF2:
    JSR DrawItemTargetMenu
    LDA #$2E
    JSR DrawItemDescBox
  @Loop:
    JSR ItemTargetMenuLoop
    BCS HealFamily_Exit

    LDA #$01
    STA tmp
    JSR CureOBAilment
    BCS @CantUse

    LDA ch_maxhp, X
    STA ch_curhp, X
    LDA ch_maxhp+1, X
    STA ch_curhp+1, X

    LDX mp_required
    DEC ch_magicdata, X

    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX
    JMP EnterMagicMenu

  @CantUse:
    JSR PlaySFX_Error
    JMP @Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_PURE  [6661]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_PURE:
    JSR DrawItemTargetMenu
    LDA #$2D
    JSR DrawItemDescBox
  UseMagic_PURE_Loop:
    JSR ItemTargetMenuLoop
    BCS UseMagic_PURE_Exit

    LDA #$03
    STA tmp
    JSR CureOBAilment
    BCS UseMagic_PURE_CantUse

    LDX mp_required
    DEC ch_magicdata, X
    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX

 UseMagic_PURE_Exit:
    JMP EnterMagicMenu

 UseMagic_PURE_CantUse:
    JSR PlaySFX_Error
    JMP UseMagic_PURE_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_SOFT  [6686]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_SOFT:
    JSR DrawItemTargetMenu
    LDA #$30
    JSR DrawItemDescBox
  @Loop:
    JSR ItemTargetMenuLoop
    BCS UseMagic_PURE_Exit
    LDA #$02
    STA tmp
    JSR CureOBAilment
    BCS @CantUse
    LDX mp_required
    DEC ch_magicdata, X
    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX
    JMP EnterMagicMenu
  @CantUse:
    JSR PlaySFX_Error
    JMP @Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_WARP  [6709]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_WARP:
    LDA #$2F
    JSR DrawItemDescBox
    LDX mp_required
    DEC ch_magicdata, X
    JSR MenuWaitForBtn_SFX

    TSX
    TXA
    CMP #$FF - 16
    BCS UseMagic_DoEXIT

    CLC
    ADC #6
    TAX
    TXS
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_EXIT  [6732]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_EXIT:
    LDA #$31
    JSR DrawItemDescBox
    LDX mp_required
    DEC ch_magicdata, X
    JSR MenuWaitForBtn_SFX

  UseMagic_DoEXIT:
    JMP DoOverworld


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseMagic_GetRequiredMP  [6778]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseMagic_GetRequiredMP:
    LDA submenu_targ
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA tmp

    LDA cursor
    LSR A
    LSR A
    CLC
    ADC tmp
    ADC #ch_curmp - ch_magicdata
    TAX
    STA mp_required
    LDA ch_magicdata, X
    CMP #1
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EnterItemMenu  [6808]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterItemMenu:
    LDA #0
    STA spr_multiplex_mode          ; Disable raster multiplexer
    STA spr_irq_zone
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY

    LDA #0
    STA menustall
    STA descboxopen
    JSR ClearMenuScreen

ResumeItemMenu:
    JSR DrawItemBox
    PHP

    LDA #$03
    JSR DrawItemTitleBox
    JSR TurnMenuScreenOn_ClearOAM

    PLP
    BCC :+
      LDA #$04
      JSR DrawItemDescBox
      JMP MenuWaitForBtn_SFX

:   LDA #0
    STA cursor
    STA joy
    STA joy_prevdir

ItemMenu_Loop:
    JSR ClearOAM
    JSR DrawItemMenuCursor
    JSR MenuFrame

    LDA joy_a
    BNE @APressed
    CMP joy_b
    BNE @Exit
    JSR MoveItemMenuCurs
    JMP ItemMenu_Loop

  @Exit:
    RTS

  @APressed:
    JSR PlaySFX_MenuSel
    LDX cursor
    LDA item_box, X
    ASL A
    TAX
    LDA @ItemJumpTable, X
    STA tmp
    LDA @ItemJumpTable+1, X
    STA tmp+1
    JMP (tmp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Item Jump Table  [6875]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 @ItemJumpTable:
  .WORD UseItem_Bad, UseItem_Lute, UseItem_Crown, UseItem_Crystal, UseItem_Herb, UseItem_Key, UseItem_TNT, UseItem_Adamant, UseItem_Slab, UseItem_Ruby
  .WORD UseItem_Rod, UseItem_Floater, UseItem_Chime, UseItem_Tail, UseItem_Cube, UseItem_Bottle, UseItem_Oxyale, UseItem_Canoe, UseItem_Bad, UseItem_Bad
  .WORD UseItem_Bad, UseItem_Bad, UseItem_Tent, UseItem_Cabin, UseItem_House, UseItem_Heal, UseItem_Pure, UseItem_Soft, UseItem_Bad, UseItem_Bad


UseItem_Bad:
    JMP ItemMenu_Loop

UseItem_Crown:
    LDA #$07

UseItem_SetDesc:
    JSR DrawItemDescBox
    JMP ItemMenu_Loop

UseItem_Crystal:  LDA #$08 ; [6905]
                  BNE UseItem_SetDesc
UseItem_Herb:     LDA #$09 ; [6906]
                  BNE UseItem_SetDesc
UseItem_Key:      LDA #$0A ; [6907]
                  BNE UseItem_SetDesc
UseItem_TNT:      LDA #$0B ; [6908]
                  BNE UseItem_SetDesc
UseItem_Adamant:  LDA #$0C ; [6909]
                  BNE UseItem_SetDesc
UseItem_Slab:     LDA #$0D ; [6910]
                  BNE UseItem_SetDesc
UseItem_Ruby:     LDA #$0E ; [6911]
                  BNE UseItem_SetDesc
UseItem_Chime:    LDA #$13 ; [6912]
                  BNE UseItem_SetDesc
UseItem_Tail:     LDA #$14 ; [6913]
                  BNE UseItem_SetDesc
UseItem_Cube:     LDA #$15 ; [6914]
                  BNE UseItem_SetDesc
UseItem_Oxyale:   LDA #$18 ; [6915]
                  BNE UseItem_SetDesc
UseItem_Canoe:    LDA #$19 ; [6916]
                  BNE UseItem_SetDesc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Bottle  [6925]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Bottle:
    LDA game_flags + OBJID_FAIRY
    LSR A
    BCC @OpenBottle
      LDA #$17
      JSR DrawItemDescBox
      JMP ItemMenu_Loop

@OpenBottle:
    LDA #0
    STA item_bottle
    LDY #OBJID_FAIRY
    JSR ShowMapObject
    LDA #$16
    JSR DrawItemDescBox_Fanfare
    JMP ResumeItemMenu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Rod  [6948]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Rod:
    LDA mapflags
    LSR A
    BCC @CantUse

    LDA tileprop_now
    AND #TP_SPEC_MASK
    CMP #TP_SPEC_USEROD
    BNE @CantUse

    LDY #OBJID_RODPLATE
    LDA game_flags, Y
    LSR A
    BCC @CantUse

    JSR HideMapObject
    LDA #$0F
    JSR DrawItemDescBox_Fanfare
    JMP ItemMenu_Loop

  @CantUse:
    LDA #$10
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Lute  [6980]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Lute:
    LDA mapflags
    LSR A
    BCC @CantUse

    LDA tileprop_now
    AND #TP_SPEC_MASK
    CMP #TP_SPEC_USELUTE
    BNE @CantUse

    LDY #OBJID_LUTEPLATE
    LDA game_flags, Y
    LSR A
    BCC @CantUse

    ASL A
    JSR HideMapObject
    LDA #$05
    JSR DrawItemDescBox_Fanfare
    JMP ItemMenu_Loop

  @CantUse:
    LDA #$06
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Floater  [7013]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Floater:
    LDA mapflags
    LSR A
    BCS @CantUse

    LDA tileprop_now
    AND #OWTP_SPEC_MASK
    CMP #OWTP_SPEC_FLOATER
    BNE @CantUse

    LDA airship_vis
    BNE @CantUse

    INC airship_vis
    LDA #$11
    JSR DrawItemDescBox_Fanfare
    JMP ItemMenu_Loop

  @CantUse:
    LDA #$12
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Tent  [7043]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Tent:
    LDA mapflags
    LSR A
    BCS @CantUse

    DEC item_tent
    LDA #30
    JSR MenuRecoverPartyHP
    LDA #$1A
    JSR MenuSaveConfirm
    JMP EnterItemMenu

  @CantUse:
    LDA #$1B
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Cabin  [7066]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Cabin:
    LDA mapflags
    LSR A
    BCS @CantUse
    DEC item_cabin
    LDA #60
    JSR MenuRecoverPartyHP
    LDA #$1C
    JSR MenuSaveConfirm
    JMP EnterItemMenu
  @CantUse:
    LDA #$1D
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_House  [7087]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_House:
    LDA mapflags
    LSR A
    BCS @CantUse

    DEC item_house
    LDA #120
    JSR MenuRecoverPartyHP
    LDA #$1E
    JSR MenuSaveConfirm

    BCC :+
      JSR MenuRecoverPartyMP
:   JMP EnterItemMenu

  @CantUse:
    LDA #$1F
    JSR DrawItemDescBox
    JMP ItemMenu_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuSaveConfirm  [7123]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuSaveConfirm:
    JSR DrawItemDescBox
    JSR ClearOAM
    JSR MenuWaitForBtn

    LDA joy
    AND #$80
    BNE :+
      JSR CloseDescBox
      CLC
      RTS

:   LDA #$3F
    JSR DrawItemDescBox
    JSR SaveGame
    JSR MenuWaitForBtn_SFX
    SEC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Heal  [7153]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Heal:
    JSR DrawItemTargetMenu
    LDA #$20
    JSR DrawItemDescBox

  _UseItem_Heal_Loop:
    JSR ItemTargetMenuLoop
    BCS UseItem_Exit

    LDA cursor
    ROR A
    ROR A
    ROR A
    AND #$C0
    TAX

    LDA ch_ailments, X
    CMP #$01
    BEQ _UseItem_Heal_CantUse
    CMP #$02
    BEQ _UseItem_Heal_CantUse

    LDA #30
    JSR MenuRecoverHP_Abs
    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX

    DEC item_heal

UseItem_Exit:
    JMP EnterItemMenu

  _UseItem_Heal_CantUse:
    JSR PlaySFX_Error
    JMP _UseItem_Heal_Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Pure  [7195]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Pure:
    JSR DrawItemTargetMenu
    LDA #$21
    JSR DrawItemDescBox
  @Loop:
    JSR ItemTargetMenuLoop
    BCS UseItem_Exit

    LDA #$03
    STA tmp
    JSR CureOBAilment
    BCS @CantUse

    DEC item_pure
    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX
    JMP EnterItemMenu

  @CantUse:
    JSR PlaySFX_Error
    JMP @Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UseItem_Soft  [7223]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UseItem_Soft:
    JSR DrawItemTargetMenu
    LDA #$22
    JSR DrawItemDescBox
  @Loop:
    JSR ItemTargetMenuLoop
    BCS UseItem_Exit

    LDA #$02
    STA tmp
    JSR CureOBAilment
    BCS @CantUse

    DEC item_soft
    JSR DrawItemTargetMenu
    JSR MenuWaitForBtn_SFX
    JMP EnterItemMenu

  @CantUse:
    JSR PlaySFX_Error
    JMP @Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CureOBAilment  [7262]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CureOBAilment:
    LDA cursor
    ROR A
    ROR A
    ROR A
    AND #$C0
    TAX
    LDA ch_ailments, X
    CMP tmp
    BEQ @Success
    SEC
    RTS

@Success:
    LDA #$00
    STA ch_ailments, X
    CLC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ItemTargetMenuLoop  [7293]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ItemTargetMenuLoop:
    LDA #0
    STA cursor
  @Loop:
    LDA #0
    STA joy_a
    STA joy_b

    JSR ClearOAM
    JSR DrawItemTargetCursor
    JSR MenuFrame

    LDA joy_a
    BNE @A_Pressed
    LDA joy_b
    BNE @B_Pressed

    LDA joy
    AND #$03
    CMP joy_prevdir
    BEQ @Loop

    STA joy_prevdir
    CMP #0
    BEQ @Loop

    CMP #$01
    BNE @Left

  @Right:
    LDA cursor
    CLC
    ADC #$01
    JMP @MoveCurs

  @Left:
    LDA cursor
    SEC
    SBC #$01

  @MoveCurs:
    AND #$03
    STA cursor
    JSR PlaySFX_MenuMove
    JMP @Loop

  @A_Pressed:
    JSR PlaySFX_MenuSel
    CLC
    RTS

  @B_Pressed:
    JSR PlaySFX_MenuSel
    SEC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemTargetCursor  [7358]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemTargetCursor:
    LDX cursor
    LDA @lut, X
    STA spr_x
    LDA #138
    STA spr_y
    JMP DrawCursor

  @lut:
    .BYTE 68, 124, 180, 236


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemTargetMenu  [7379]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemTargetMenu:
    LDA #0
    STA menustall
    JSR ClearMenuScreen

    LDA #8
    STA box_y
    LDA #5
    STA box_x
    LDA #30
    STA box_wd
    LDA #9
    STA box_ht
    JSR DrawBox

    JSR @DrawBoxBody
    JMP TurnMenuScreenOn_ClearOAM

 @DrawBoxBody:
    LDX #0*2
    LDA #8
    STA dest_x
    LDA #14
    STA dest_y
    JSR @DrawString

    DEC dest_y
    LDX #1*2
    JSR @DrawString

    DEC dest_y
    LDX #2*2
    JSR @DrawString

    DEC dest_y
    DEC dest_y
    LDX #3*2

 @DrawString:
    LDA @lut_str_pointertable, X
    STA text_ptr
    LDA @lut_str_pointertable+1, X
    STA text_ptr+1
    JMP DrawMenuComplexString

 @lut_str_pointertable:
  .WORD @str_charmaxhp, @str_charcurhp, @str_ailmentblurb, @str_name

 @str_charmaxhp:
  .BYTE $7A,$10,$06,$FF,$FF,$FF
  .BYTE $7A,$11,$06,$FF,$FF,$FF
  .BYTE $7A,$12,$06,$FF,$FF,$FF
  .BYTE $7A,$13,$06,$00

 @str_charcurhp:
  .BYTE $FF,$10,$05,$FF,$FF,$FF
  .BYTE $FF,$11,$05,$FF,$FF,$FF
  .BYTE $FF,$12,$05,$FF,$FF,$FF
  .BYTE $FF,$13,$05,$00

 @str_ailmentblurb:
  .BYTE $10,$02,$FF,$FF,$FF,$FF
  .BYTE $11,$02,$FF,$FF,$FF,$FF
  .BYTE $12,$02,$FF,$FF,$FF,$FF
  .BYTE $13,$02,$00

 @str_name:
  .BYTE $10,$00,$FF,$FF,$FF
  .BYTE $11,$00,$FF,$FF,$FF
  .BYTE $12,$00,$FF,$FF,$FF
  .BYTE $13,$00,$00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuRecoverPartyHP  [7560]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuRecoverPartyHP:
    LDX #$00
    JSR MenuRecoverHP
    LDX #$40
    JSR MenuRecoverHP
    LDX #$80
    JSR MenuRecoverHP
    LDX #$C0
    JSR MenuRecoverHP
    JMP DrawItemTargetMenu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuRecoverHP  [7591]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuRecoverHP:
    LDY ch_ailments, X
    CPY #$01
    BEQ _MenuRecoverHP_Exit
    CPY #$02
    BEQ _MenuRecoverHP_Exit

MenuRecoverHP_Abs:
    STA tmp
    CLC
    ADC ch_curhp, X
    STA ch_curhp, X
    LDA ch_curhp+1, X
    ADC #0
    STA ch_curhp+1, X
    CMP ch_maxhp+1, X
    BEQ _MenuRecoverHP_CheckLow
    BCS _MenuRecoverHP_OverMax

  _MenuRecoverHP_Done:
    LDA #$57
    STA music_track
    LDA tmp
  _MenuRecoverHP_Exit:
    RTS

  _MenuRecoverHP_CheckLow:
    LDA ch_curhp, X
    CMP ch_maxhp, X
    BCS _MenuRecoverHP_OverMax
    BCC _MenuRecoverHP_Done

  _MenuRecoverHP_OverMax:
    LDA ch_maxhp, X
    STA ch_curhp, X
    LDA ch_maxhp+1, X
    STA ch_curhp+1, X
    JMP _MenuRecoverHP_Done


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MoveItemMenuCurs  [7656]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveItemMenuCurs_Exit:
    RTS

MoveItemMenuCurs:
    LDA joy
    AND #$0F
    CMP joy_prevdir
    BEQ MoveItemMenuCurs_Exit
    STA joy_prevdir
    CMP #0
    BEQ MoveItemMenuCurs_Exit

    CMP #$04
    BCC @LeftOrRight
    BNE @Up

 @Down:
    LDA cursor
    CLC
    ADC #$03
    CMP cursor_max
    BCC @Done
    CMP #$03
    BCC @Done

 @DownWrap:
    SEC
    SBC #$03
    CMP #$03
    BCS @DownWrap
    BCC @Done

 @Up:
    LDA cursor
    SEC
    SBC #$03
    BPL @Done

    LDA cursor
    LDX cursor_max
    CPX #$03
    BCC @Done

 @UpWrap:
    CLC
    ADC #$03
    CMP cursor_max
    BCC @UpWrap
    SBC #$03
    JMP @Done

 @LeftOrRight:
    CMP #$01
    BNE @Left

 @Right:
    LDA cursor
    CLC
    ADC #$01
    CMP cursor_max
    BCC @Done
    LDA #0
    BEQ @Done

 @Left:
    LDA cursor
    SEC
    SBC #$01
    BPL @Done
    LDA cursor_max
    SEC
    SBC #$01

 @Done:
    STA cursor
    JMP CloseDescBox_Sfx


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MoveMagicMenuCursor  [7928]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveMagicMenuCursor_Exit:
    RTS

MoveMagicMenuCursor:
    LDA submenu_targ
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA tmp

    LDA joy
    AND #$0F
    CMP joy_prevdir
    BEQ MoveMagicMenuCursor_Exit
    STA joy_prevdir
    CMP #0
    BEQ MoveMagicMenuCursor_Exit

    CMP #$04
    BCS @UpDown
    CMP #$01
    BNE @Left

  @Right:
    LDA cursor
    CLC
    ADC #$01
    AND #$03
    CMP #$03
    BNE @Right_ColOK

      LDA cursor
      AND #$1C
      STA cursor
      JSR @CheckCursor
      BEQ @Right
      JMP CloseDescBox_Sfx

  @Right_ColOK:
    INC cursor
    JSR @CheckCursor
    BEQ @Right
    JMP CloseDescBox_Sfx

  @Left:
    LDA cursor
    SEC
    SBC #$01
    AND #$03
    CMP #$03
    BNE @Left_ColOK

      LDA cursor
      AND #$1C
      ORA #$02
      STA cursor
      JSR @CheckCursor
      BEQ @Left
      JMP CloseDescBox_Sfx

  @Left_ColOK:
    DEC cursor
    JSR @CheckCursor
    BEQ @Left
    JMP CloseDescBox_Sfx

@UpDown:
    BNE @Up

  @Down:
    LDA cursor
    CLC
    ADC #$04
    AND #$1F
    STA cursor
    JSR @CheckCursor
    BEQ @Down
    JMP CloseDescBox_Sfx

  @Up:
    LDA cursor
    SEC
    SBC #$04
    AND #$1F
    STA cursor
    JSR @CheckCursor
    BEQ @Up
    JMP CloseDescBox_Sfx

  @CheckCursor:
    LDA cursor
    ORA tmp
    TAX
    LDA ch_spells, X
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CloseDescBox  [8043]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CloseDescBox_Sfx:
    JSR PlaySFX_MenuMove
    LDA descboxopen
    BNE CloseDescBox
    RTS

CloseDescBox:
    LDA #0
    STA descboxopen
    JMP EraseDescBox


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemMenuCursor  [8150]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemMenuCursor:
    LDA cursor
    ASL A
    TAX
    LDA lut_ItemMenuCursor, X
    STA spr_x
    LDA lut_ItemMenuCursor+1, X
    STA spr_y
    JMP DrawCursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_ItemMenuCursor  [8185]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_ItemMenuCursor:
  .BYTE   68, 82,   140, 82,   212, 82
  .BYTE   68, 98,   140, 98,   212, 98
  .BYTE   68,114,   140,114,   212,114
  .BYTE   68,130,   140,130,   212,130
  .BYTE   68,146,   140,146,   212,146
  .BYTE   68,162,   140,162,   212,162
  .BYTE   68,178,   140,178,   212,178
  .BYTE   68,194,   140,194,   212,194


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMagicMenuCursor  [8203]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMagicMenuCursor:
    LDA cursor
    STA tmp

    AND #$03
    ASL A
    STA tmp+1
    CLC
    ADC tmp+1
    ADC tmp+1
    ASL A
    ASL A
    ASL A
    CLC
    ADC #132
    STA spr_x

    LDA tmp
    ASL A
    ASL A
    AND #$F0
    CLC
    ADC #82
    STA spr_y

    JMP DrawCursor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemTitleBox  [8430]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemTitleBox:
    PHA
    LDA #$07
    JSR DrawMainItemBox
    INC dest_y
    PLA
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemDescBox  [8450]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemDescBox_Fanfare:
    LDX #$54
    STX music_track

DrawItemDescBox:
    PHA
    LDA #1
    STA menustall
    LDA #$08
    JSR DrawMainItemBox
    PLA
    INC descboxopen
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EraseDescBox  [8530]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EraseDescBox:
    LDA #1
    STA menustall
    LDA #$08
    JSR LoadMainItemBoxDims
    JMP EraseBox


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMagicMenuMainBox  [8745]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMagicMenuMainBox:
    LDA #$09
    JSR DrawMainItemBox
    INC dest_y

    LDY #$C0
    LDA #$2A
    JSR DrawCharMenuString_Len

    LDA submenu_targ
    ROR A
    ROR A
    ROR A
    AND #$C0
    TAX
    LDY #$08

  @Loop:
      LDA ch_spells, X
      BNE @FoundSpell
      INX
      LDA ch_spells, X
      BNE @FoundSpell
      INX
      LDA ch_spells, X
      BNE @FoundSpell
      INX
      INX
      DEY
      BNE @Loop

    SEC
    RTS

  @FoundSpell:
    TXA
    AND #$1F
    STA cursor
    CLC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  SaveGame  [5806]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SaveGame:
    LDX #0
    LDA ow_scroll_x
    STA unsram_ow_scroll_x
    LDA ow_scroll_y
    STA unsram_ow_scroll_y
    LDA vehicle
    STA unsram_vehicle

  @CopyLoop:
      LDA unsram       , X
      STA   sram       , X
      LDA unsram + $100, X
      STA   sram + $100, X
      LDA unsram + $200, X
      STA   sram + $200, X
      LDA unsram + $300, X
      STA   sram + $300, X
      INX
      BNE @CopyLoop

    LDA #$55
    STA sram_assert_55
    LDA #$AA
    STA sram_assert_AA

    LDA #$00
    STA sram_checksum
    LDX #$00
    CLC

  @ChecksumLoop:
      ADC sram       , X
      ADC sram + $100, X
      ADC sram + $200, X
      ADC sram + $300, X
      INX
      BNE @ChecksumLoop

    EOR #$FF
    STA sram_checksum
    LDA #$56
    STA music_track
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuRecoverPartyMP  [5908]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuRecoverPartyMP:
    LDX #0
  @Loop:
    LDA ch_ailments, X
    CMP #$01
    BEQ @Skip
    CMP #$02
    BEQ @Skip

      LDA ch_maxmp, X
      STA ch_curmp, X
      LDA ch_maxmp+1, X
      STA ch_curmp+1, X
      LDA ch_maxmp+2, X
      STA ch_curmp+2, X
      LDA ch_maxmp+3, X
      STA ch_curmp+3, X
      LDA ch_maxmp+4, X
      STA ch_curmp+4, X
      LDA ch_maxmp+5, X
      STA ch_curmp+5, X
      LDA ch_maxmp+6, X
      STA ch_curmp+6, X
      LDA ch_maxmp+7, X
      STA ch_curmp+7, X

  @Skip:
    TXA
    CLC
    ADC #$40
    TAX
    BNE @Loop
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ShowMapObject  [831]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowMapObject:
    STY tmp
    LDA game_flags, Y
    ORA #GMFLG_OBJVISIBLE
    STA game_flags, Y
    LDY #0
  @Loop:
      LDA tmp
      CMP mapobj_rawid, Y
      BEQ @Found
      TYA
      CLC
      ADC #$10
      TAY
      CMP #$F0
      BCC @Loop
    RTS

  @Found:
    STA mapobj_id, Y
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  HideMapObject  [961]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HideMapObject:
    STY tmp
    LDA game_flags, Y
    AND #<~GMFLG_OBJVISIBLE
    STA game_flags, Y
    LDY #0
  @Loop:
      LDA tmp
      CMP mapobj_id, Y
      BEQ @Found
      TYA
      CLC
      ADC #$10
      TAY
      CMP #$F0
      BCC @Loop
    RTS

  @Found:
    LDA #0
    STA mapobj_id, Y
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EnterEquipMenu  [8826]
;;
;;  IN:   A = ch_weapons-ch_stats  for weapon menu
;;            ch_armor-ch_stats    for armor menu
;;            this value to be stored in 'equipoffset' by this routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterEquipMenu:
    STA equipoffset       ; record the equipoffset to indicate weapon or armor menu

    LDA #0
    STA spr_multiplex_mode          ; Disable raster multiplexer
    STA spr_irq_zone
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY

    LDA #0
    STA joy_a             ; clear joy_a and joy_b counters
    STA joy_b
    STA menustall         ; and turn off menu stalling

    JSR SortEquipmentList           ; sort the equipment list to remove gaps
    JSR DrawEquipMenu               ; draw the equip menu (but not the item text)
    JSR CopyEquipToItemBox          ; copy equipment from inventory to item_box so it's easier to work with
    JSR UnadjustEquipStats          ; unadjust equipment stats so they can be readjusted later
    JSR ClearOAM                    ; clear OAM

    LDA #1
    STA menustall                   ; now that screen is on, turn on menu stalling
    JSR DrawEquipMenuStrings        ; draw the menu strings (item names)

  @Start:
    LDA #0
    STA eq_modecurs               ; reset the mode cursor to 0  ("Equip")

  @Loop:
    JSR ClearOAM                  ; clear OAM
    JSR DrawEquipMenuModeCurs     ; draw the mode cursor
    JSR EquipMenuFrame            ; then do an Equip Menu Frame

    LDA joy_a
    BNE @A_Pressed            ; check to see if A pressed
    LDA joy_b
    BNE @B_Pressed            ; or B

    JSR MoveEquipMenuModeCurs ; if neither A nor B pressed, move the mode cursor
    JMP @Loop                 ; and loop until one of them is pressed

  @A_Pressed:
    JSR @GoToSubMenu          ; go to the desired sub menu
    JMP @Start                ; then restart this loop once they exit that sub menu

  @B_Pressed:                 ; if B pressed....
    JSR CopyEquipFromItemBox  ;  move all equipment from item box back to player inventory
    JSR SortEquipmentList     ;  sort equipment list to remove gaps
    JMP ReadjustEquipStats    ;  adjust stats to reflect new equipment.  Then exit.


  @GoToSubMenu:
    JSR PlaySFX_MenuSel       ; play the selection sound effect

    LDA #0
    STA cursor                ; reset the primary
    STA cursor2               ;   and secondary cursor to zero

    LDA eq_modecurs           ; get the mode cursor to see which sub menu we're to go to.
    BNE :+
      JMP EquipMenu_EQUIP     ;   mode=0 -> EQUIP
:   CMP #$01
    BNE :+
      JMP EquipMenu_TRADE     ;   mode=1 -> TRADE
:   JMP EquipMenu_DROP        ;   mode=2 -> DROP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EquipMenu_TRADE  [8892]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EquipMenu_TRADE:              ; "TRADE" option selected
    JSR ClearOAM              ; clear OAM
    JSR DrawEquipMenuCurs     ; draw the cursor (primary cursor only)
    JSR EquipMenuFrame        ; do a frame

    LDA joy_a                 ; check or A and B button presses
    BNE @A_Pressed
    LDA joy_b
    BNE @B_Pressed

    JSR MoveEquipMenuCurs     ; then move the cursor for directional presses
    JMP EquipMenu_TRADE       ; rinse, repeat

  @B_Pressed:                 ; if B pressed... just exit
    RTS

  @A_Pressed:                 ; if A pressed...
    LDA cursor
    STA cursor2               ; copy the primary cursor to the secondary cursor
                              ; then proceed to the Trade subloop
    @SubLoop:
      JSR ClearOAM                      ; clear OAM
      JSR DrawEquipMenuCursSecondary    ; draw both primary+secondary cursors
      JSR EquipMenuFrame                ; do a frame

      LDA joy_a
      BNE @DoTrade            ; check for A/B button presses
      LDA joy_b
      BNE EquipMenu_TRADE     ;   if B pressed, jump back to main Trade loop

      JSR MoveEquipMenuCurs   ; check for cursor movement
      JMP @SubLoop            ; and loop

  @DoTrade:              ; DoTrade is called when two items to trade have been selected
    LDX cursor           ; primary cursor in X (one of the items to trade)
    LDY cursor2          ; secondary cursor in Y (the other item)

    LDA item_box, X      ; get the 'X' item
    STA tmp              ;  store it to temp RAM
    LDA item_box, Y      ; get the 'Y' item
    AND #$7F             ;  unequip it
    STA item_box, X      ; move Y item to X item
    LDA tmp              ; get original X item
    AND #$7F             ;  unequip it
    STA item_box, Y      ; and move X item to Y item (swapped the two items)

    JSR DrawEquipMenuStrings   ; redraw all the equipment strings to reflect changes
    JMP EquipMenu_TRADE        ; then jump back to Trade loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EquipMenu_EQUIP  [8945]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EquipMenu_EQUIP:
    JSR ClearOAM             ; clear OAM
    JSR DrawEquipMenuCurs    ; draw the primary cursor
    JSR EquipMenuFrame       ; do a frame

    LDA joy_a
    BNE @A_Pressed           ; check for A/B button presses
    LDA joy_b
    BNE @B_Pressed

    JSR MoveEquipMenuCurs    ; and check for cursor movement
    JMP EquipMenu_EQUIP      ; rinse, repeat

  @B_Pressed:                ; if B pressed, just exit
    RTS

  @A_Pressed:                ; if A pressed...
    LDX cursor               ; get the cursor in X
    LDA item_box, X          ; use it to index and get the selected item
    BNE @ConfirmEquip        ; if this item is nonzero, jump ahead to confirm that it's equippable
                             ;  otherwise.. can't equip (can't equip a blank slot)
    @CantEquip:
      JSR PlaySFX_Error      ; if can't equip, play the error sound effect
      JMP EquipMenu_EQUIP    ; and keep looping

  @ConfirmEquip:
    BMI @ToggleEquip         ; see if item is already equipped, if it is, you can ALWAYS unequip it (no check necessary)
    JSR IsEquipLegal         ; Confirm to see if this item is equippable by this class
    BCS @CantEquip           ; if it isn't (C set), then we can't equip it

    LDX cursor               ; otherwise (can equip), restore X to be the cursor again, then toggle equip state

  @ToggleEquip:
    LDA item_box, X           ; get the item
    EOR #$80                  ; toggle its equip state (unequip it if equipped... or equip it if unequipped)
    STA item_box, X           ; and write it back
    JSR DrawEquipMenuStrings  ; redraw the item names to reflect changes
    JMP EquipMenu_EQUIP       ; and continue looping


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EquipMenu_DROP  [8989]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EquipMenu_DROP:
    JSR ClearOAM              ; clear OAM
    JSR DrawEquipMenuCurs     ; draw the primary cursor
    JSR EquipMenuFrame        ; do a frame

    LDA joy_a
    BNE @A_Pressed            ; check for A and B presses
    LDA joy_b
    BNE @B_Pressed

    JSR MoveEquipMenuCurs     ; check for cursor movement
    JMP EquipMenu_DROP        ; rinse, repeat until A/B pressed

  @B_Pressed:
    RTS                       ; if B pressed, just exit

  @A_Pressed:                 ; if A pressed....
    LDX cursor                ; put the cursor in X
    LDA item_box, X           ; get the item to drop from the item box
    BNE @ConfirmLoop          ; if it's zero....
      JSR PlaySFX_Error       ;  ... play the error sound effect (can't drop an empty slot)
      JMP EquipMenu_DROP      ;      and continue looping

  @ConfirmLoop:
    JSR ClearOAM              ; clear OAM

    LDA framecounter          ; for confirmation, the cursor is to flicker.
    LSR A
    LSR A
    BCS :+                    ; skip over drawing the cursor if C set (odd frame)
      JSR DrawEquipMenuCurs   ;   only draw cursor every other frame
:   JSR EquipMenuFrame        ; Do a frame

    LDA joy_a
    BNE @DoDrop               ; if they pressed A, do the drop
    LDA joy_b
    BNE EquipMenu_DROP        ; if they pressed B, abort, and return to main DROP loop

    JMP @ConfirmLoop          ; if neither A nor B pressed, keep looping until one of them is.

@DoDrop:
    LDX cursor                ; get the cursor in X
    LDA #0
    STA item_box, X           ; erase the item from the item box
    JSR DrawEquipMenuStrings  ; redraw the item names to reflect changes
    JMP EquipMenu_DROP        ; and return to Drop loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  IsEquipLegal  [9057]
;;
;;     Checks to see if a specific class can equip a specific item.
;;  ALSO!  This routine modifies the item_box to de-equip all items of the same
;;  type that this character is equipping.  So if you test to see if a weapon is
;;  equippable, and it is, then all other weapons will be unequipped by this routine.
;;  Or if you try to equip a helmet.. all other helmets will be unequipped.
;;
;;  IN:            A = 1-based ID of item to check (0=blank item)
;;       equipoffset = indicates to check weapon or armor
;;            cursor = 4* the character ID whose class we're to check against
;;
;;  OUT:           C = set if equipping is illegal for this class (can't equip it)
;;                     clear if legal (can)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IsEquipLegal:
    SEC
    SBC #$01          ; subtract 1 from the item ID to make it zero based
    ASL A             ; double it
    STA tmp           ; tmp = (2*item_id)

    LDA cursor        ; get the cursor
    ASL A
    ASL A
    ASL A
    ASL A
    AND #$C0          ; shift and mask to get usable character index
    TAX               ; put char index in X

    LDA ch_class, X   ; get the character's class
    ASL A             ; double it (2 bytes for equip permissions)
    TAX               ; and put in X to index the equip bit

    LDA lut_ClassEquipBit, X        ; get the class permissions bit position word
    STA tmp+4                       ;  and put in tmp+4,5
    LDA lut_ClassEquipBit+1, X
    STA tmp+5

    LDY equipoffset              ; now, see if we're dealing with weapons or armor
    CPY #ch_weapons-ch_stats
    BNE @Armor

  @Weapon:
    LDX tmp                        ; get the weapon id (*2)
    LDA lut_WeaponPermissions, X   ; use it to get the weapon permissions word (low byte)
    AND tmp+4                      ; mask with low byte of class permissions
    STA tmp                        ;  temporarily store result
    LDA lut_WeaponPermissions+1, X ; then do the same with the high byte of the permissions word
    AND tmp+5                      ;  mask with high byte of class permissions
    ORA tmp                        ; then combine with results of low mask
                          ;  here... any nonzero value will indicate that the item cannot be equipped

    CMP #$01              ; compare with 1 (any nonzero value will set C)
    BCC :+                ; if C is set (can't equip)....
      RTS                 ;   ... just exit.  otherwise...

:   LDA cursor            ; get the cursor (character id*4)
    AND #$0C              ; isolate the character bits
    TAX                   ; and put in X for indexing

    LDA item_box, X       ; unequip all weapons
    AND #$7F
    STA item_box, X
    LDA item_box+1, X
    AND #$7F
    STA item_box+1, X
    LDA item_box+2, X
    AND #$7F
    STA item_box+2, X
    LDA item_box+3, X
    AND #$7F
    STA item_box+3, X

    RTS                   ; then exit (C is still clear, indicating item can be equipped)

  @Armor:
    LDX tmp                       ; get the armor id (*2)
    LDA lut_ArmorPermissions, X   ; use it to get the armor permissions word
    AND tmp+4                     ;  and mask it with the class permissions word
    STA tmp
    LDA lut_ArmorPermissions+1, X
    AND tmp+5
    ORA tmp               ; and OR both high and low bytes of result together.  A nonzero result here indicates
                          ;  armor cannot be equipped

    CMP #$01              ; compare with 1 (any nonzero value sets C)
    BCC :+                ; if armor can't be equipped....
      RTS                 ; .. just exit.  Otherwise...

:   TXA                   ; get back the armor_id*2
    LSR A                 ; /2 to restore armor_id
    TAX                   ; and put back in X

    LDA lut_ArmorTypes, X ; use armor ID to index and find out what kind of armor it is (body, helmet, shield, etc)
    STA tmp+2             ; store armor type in tmp+2

    LDA cursor            ; store current cursor in tmp
    STA tmp
    AND #$0C              ; mask out the charater bits  (char ID * 4)
    STA tmp+1             ;  store that in tmp+1  (loop's item to unequip)

    LDY #$04              ; set Y (loop counter) to 4 (loop 4 times)

  @ArmorLoop:
    LDA tmp+1             ; get the loop item index
    CMP tmp               ; compare to the item we're trying to equip
    BEQ @ArmorSkip        ; if they're equal, skip over this item

    LDX tmp+1             ; put loop item index in X
    LDA item_box, X       ;  use it to get that item from the item_box
    BPL @ArmorSkip        ; if that item is not equipped, skip it

    SEC                   ; otherwise (it is equipped), subtract $81 to get the armor ID
    SBC #$81
    TAX                   ; put armor ID in X
    LDA lut_ArmorTypes, X ; use that to look up what type of armor this is

    CMP tmp+2             ; compare that to the type of armor we're trying to equip
    BNE @ArmorSkip        ; if it doesn't match (different kind of armor), skip it

                          ; otherwise... it's a match!  need to unequip it.
    LDX tmp+1             ; get this loop item index in X
    LDA item_box, X       ; use it to get the item from the item box
    AND #$7F              ;    unequip it
    STA item_box, X       ;    then write it back

  @ArmorSkip:
    INC tmp+1             ; increment our loop item counter (to examine next item in the item box)
    DEY                   ; decrement our loop counter
    BNE @ArmorLoop        ; and keep looping until it expires

    CLC                   ; once we're done with all that, CLC to indicate the item can be equipped
    RTS                   ; and exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   lut_ClassEquipBit  [9191]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_ClassEquipBit: ;  FT   TH   BB   RM   WM   BM      KN   NJ   MA   RW   WW   BW
   .WORD            $800,$400,$200,$100,$080,$040,   $020,$010,$008,$004,$002,$001


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   lut_ArmorTypes  [9212]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_ArmorTypes:
  .BYTE    0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0        ; 16 pieces of body armor
  .BYTE    1,1,1,1,1, 1,1,1,1                        ; 9 shields
  .BYTE    2,2,2,2,2, 2,2                            ; 7 helmets
  .BYTE    3,3,3,3,3, 3,3,3                          ; 8 gauntlets


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EquipMenuFrame  [9236]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EquipMenuFrame:
    JSR WaitForVBlank_L     ; wait for VBlank

    LDA #BANK_THIS
    STA cur_bank          ; set cur_bank to this bank
    JSR CallMusicPlay_L   ; so we can call music play routine

    INC framecounter      ; inc the frame counter to count this frame

    LDA #0                ; clear joy_a and joy_b markers so button presses
    STA joy_a             ;  will be recognized
    STA joy_b

    INC framecounter      ; inc frame counter again

    LDA joy               ; get the joy data
    AND #$0F              ; isolate directional buttons
    STA tmp+7             ; and store it as the previous joy data
    JSR UpdateJoy_L       ; then update joy data

    LDA joy_a
    ORA joy_b             ; see if either A or B pressed
    BEQ @NotPressed       ; if not... jump ahead
    JMP PlaySFX_MenuSel   ; otherwise, play the selection sound effect and exit

  @NotPressed:            ; if neither A nor B have been pressed
    LDA joy               ; get the joy data
    AND #$0F              ; isolate directional buttons
    BEQ @Exit             ; if no directions are pressed, exit

    CMP tmp+7             ; compare current buttons to previous buttons
    BEQ @Exit             ; if no change, then exit

    JMP PlaySFX_MenuMove  ; otherwise, a new button has been pressed, so play the menu move sound, then exit

  @Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MoveEquipMenuModeCurs  [9297]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveEquipMenuModeCurs:
    LDA joy           ; get joypad
    AND #$03          ; isolate left/right buttons
    CMP joy_prevdir   ; if they equal previous buttons...
    BEQ @Exit         ;  no new buttons pressed, so exit

    STA joy_prevdir   ; otherwise, record changes
    CMP #0            ; see if a button was pressed or released
    BEQ @Exit         ; if released (no buttons currently down), exit

    CMP #1
    BNE @Left         ; see if they pressed left or right

  @Right:
    LDA eq_modecurs   ; to move right...
    CLC
    ADC #$01          ; add 1 to the mode cursor
    CMP #$03
    BCC @WriteAndExit ; if >= 3....
    LDA #0            ;  ... wrap it to zero

  @WriteAndExit:
    STA eq_modecurs
  @Exit:
    RTS

  @Left:
    LDA eq_modecurs   ; to move left....
    SEC
    SBC #$01          ; subtract one
    BCS @WriteAndExit ; if still >= 0, we're done
    LDA #$02          ; otherwise, wrap to 2
    STA eq_modecurs
    RTS               ; then exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MoveEquipMenuCurs  [9342]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveEquipMenuCurs:
    LDA joy            ; get joy data
    AND #$0F           ; isolate directional buttons
    CMP joy_prevdir    ; see if there were changes
    BEQ @Exit          ; if not, exit

    STA joy_prevdir    ; otherwise, record changes
    CMP #0             ; see if buttons are being pressed
    BEQ @Exit          ; if not, exit

    CMP #$04           ; see if they're pressing up/down or left/right
    BCS @UpDown

  @LeftRight:          ; if left/right, simply toggle the column
    LDA cursor
    EOR #$01           ; EOR with 1 toggles the column
    STA cursor         ; then exit

  @Exit:
    RTS

  @UpDown:
    BNE @Up            ; If not left/right, see if they pressed up or down.

  @Down:
    LDA cursor         ; If down, add 2 to the cursor (next row)
    CLC
    ADC #$02
    AND #$0F           ; mask with $0F to keep in bounds / wrap
    STA cursor
    RTS                ; then exit

  @Up:
    LDA cursor         ; for up.. subtract 2
    SEC
    SBC #$02
    AND #$0F           ; and wrap
    STA cursor
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CopyEquipToItemBox  [9391]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyEquipToItemBox:
    LDX equipoffset       ; X is our source index -- start at the equipment offset
    LDY #0                ; Y is our dest index -- start at zero

  @Loop:
    LDA ch_stats, X       ; copy 4 bytes from source buffer (character inventory)
    STA item_box, Y       ;  to dest buffer (item_box)
    LDA ch_stats+1, X
    STA item_box+1, Y
    LDA ch_stats+2, X
    STA item_box+2, Y
    LDA ch_stats+3, X
    STA item_box+3, Y

    TXA                   ; add $40 to source index (look at next character's inventory)
    CLC
    ADC #$40
    TAX

    TYA                   ; add 4 to dest index
    CLC
    ADC #4
    TAY

    CMP #4*4              ; keep looping until we've copied 16 items (4 characters' inventory)
    BCC @Loop

    RTS                   ; then exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CopyEquipFromItemBox  [9430]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyEquipFromItemBox:
    LDX equipoffset
    LDY #0

  @Loop:
    LDA item_box, Y
    STA ch_stats, X
    LDA item_box+1, Y
    STA ch_stats+1, X
    LDA item_box+2, Y
    STA ch_stats+2, X
    LDA item_box+3, Y
    STA ch_stats+3, X

    TXA
    CLC
    ADC #$40
    TAX

    TYA
    CLC
    ADC #4
    TAY

    CMP #4*4
    BCC @Loop

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawEquipMenu  [9468]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawEquipMenu:
    JSR ClearMenuScreen

    LDA #0
    JSR @DrawEquipBox           ; draw the title box
    INC dest_y
    LDA #$34                    ; menu string $34 ("WEAPON")
    LDX equipoffset
    CPX #ch_weapons - ch_stats  ; check whether this is the weapon or armor screen
    BEQ :+
      LDA #$3E                  ;   if not the weapon screen, change menu string ID to $3E ("ARMOR")
:   JSR DrawMenuString          ; then draw that title string

    LDA #1
    JSR @DrawEquipBox           ; then draw the top menu box
    INC dest_y
    LDA #$35
    JSR DrawMenuString          ; and its contained text ("EQUIP   TRADE   DROP")

    LDA #$03
    JSR @DrawEquipBox           ; char 0's equip box (but leave it empty for now)
    LDA #$02
    JSR @DrawEquipBox           ; char 0's name box
    LDA #$36
    JSR DrawMenuString          ; char 0's name

    LDA #$05
    JSR @DrawEquipBox           ; then char 1...
    LDA #$04
    JSR @DrawEquipBox
    LDA #$38
    JSR DrawMenuString

    LDA #$07
    JSR @DrawEquipBox           ; char 2...
    LDA #$06
    JSR @DrawEquipBox
    LDA #$3A
    JSR DrawMenuString

    LDA #$09
    JSR @DrawEquipBox           ; char 3...
    LDA #$08
    JSR @DrawEquipBox
    LDA #$3C
    JSR DrawMenuString

    RTS

 @DrawEquipBox:
    ASL A                     ; *4  (4 bytes per box)
    ASL A
    TAX                       ; put box*4 in X

    LDA @lut_EquipBoxes, X    ; use it to index our lut
    STA box_x                 ; and load box coords/dims
    LDA @lut_EquipBoxes+1, X
    STA box_y
    LDA @lut_EquipBoxes+2, X
    STA box_wd
    LDA @lut_EquipBoxes+3, X
    STA box_ht

    LDA #BANK_THIS
    STA cur_bank

    JMP DrawBox               ; then draw the box, and return

 @lut_EquipBoxes:
  .BYTE  5,  0,  7,  4   ; title box
  .BYTE 13,  0, 22,  4   ; top menu box ("Equip   Trade   Drop")
  .BYTE  5,  4,  8,  3   ; char 0's name box
  .BYTE 12,  4, 23,  5   ; char 0's equipment box
  .BYTE  5,  9,  8,  3   ; ch 1's
  .BYTE 12,  9, 23,  5
  .BYTE  5, 14,  8,  3   ; ch 2's
  .BYTE 12, 14, 23,  5
  .BYTE  5, 19,  8,  3   ; ch 3's
  .BYTE 12, 19, 23,  5


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawEquipMenuCursSecondary  [9573]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawEquipMenuCursSecondary:
    LDA framecounter           ; get the frame counter
    LSR A                      ;  shift to put bit 1 in C
    LSR A
    BCS DrawEquipMenuCurs      ; If odd frame.. just draw the primary cursor

    LDA cursor2                ; get secondary cursor
    ASL A                      ;  double it and put it in X for LUT indexing
    TAX
    LDA lut_EquipMenuCurs, X   ; get cursor X coord
    CLC
    ADC #$04                   ; add 4 to draw it a little to the right of the primary cursor
    BNE EquipMenuCurs_DoDraw   ; then draw it (always branches)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawEquipMenuCurs  [9586]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawEquipMenuCurs:
    LDA cursor                 ; get primary cursor
    ASL A                      ;  double it and put in X for LUT indexing
    TAX
    LDA lut_EquipMenuCurs, X   ; get cursor X coord... then draw

  EquipMenuCurs_DoDraw:
    STA spr_x                    ; record X coord
    LDA lut_EquipMenuCurs+1, X   ; then fetch
    STA spr_y                    ;    and record Y coord
    JMP DrawCursor               ; draw the cursor, and exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_EquipMenuCurs  [9598]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_EquipMenuCurs:
  .BYTE 124,  90,   204,  90    ; Hero 0, rows 5, 7
  .BYTE 124, 106,   204, 106
  .BYTE 124, 130,   204, 130    ; Hero 1, rows 10, 12
  .BYTE 124, 146,   204, 146
  .BYTE 124, 170,   204, 170    ; Hero 2, rows 15, 17
  .BYTE 124, 186,   204, 186
  .BYTE 124, 210,   204, 210    ; Hero 3, rows 20, 22
  .BYTE 124, 226,   204, 226


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawEquipMenuModeCurs  [9615]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawEquipMenuModeCurs:
    LDX eq_modecurs          ; put mode cursor in X
    LDA @lut_CursorX, X       ; use it as an index to get x coord
    STA spr_x                ; set it
    LDA #66                  ; y coord fixed at 66 (Row 2: 50 + 2*8)
    STA spr_y
    JMP DrawCursor           ; draw the cursor and return

  @lut_CursorX:
     .BYTE 132, 188, 244


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_WeaponPermissions  [9733]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_WeaponPermissions:
  .WORD   $0DE7,$028A,$0400,$02CB,$074D,   $06CB,$07CF,$02CB,$0DE7,$028A
  .WORD   $05C7,$02CB,$06CB,$07CF,$02CB,   $028A,$06CB,$074D,$07CF,$06CB
  .WORD   $06CB,$02CB,$06CB,$06CB,$02CB,   $06CB,$02CB,$0504,$07CF,$0F6D
  .WORD   $0FAE,$0FCB,$0FFE,$0FCB,$0FCA,   $0FCD,$0FCB,$0FEF,$0FDF,$0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_ArmorPermissions  [9745]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_ArmorPermissions:
  .WORD   $0000,$00C3,$06CB,$07CF,$07DF,   $06CB,$07CF,$07CF,$0FDF,$0FDF
  .WORD   $0000,$0000,$0000,$0000,$0FFD,   $0FFE,$07CF,$07CF,$07CF,$07CF
  .WORD   $07CF,$0FDF,$0FDF,$02CB,$0208,   $0000,$07CF,$07CF,$07CF,$0FDF
  .WORD   $0FCF,$0000,$0000,$07CF,$07CF,   $07CB,$0FCB,$07CB,$0FDF,$0000


EnterStatusMenu:
    LDA #0
    STA spr_multiplex_mode          ; Disable raster multiplexer
    STA spr_irq_zone
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY

    LDA #0
    STA menustall                   ; Disable menu stalling
    JSR ClearMenuScreen             ; Clear screen with black bg, prepare VIC-II

    LDX #0*4                        ; Draw Box 0 (Character name)
    JSR @DrawStatusBox
    LDA #$23                        ; Menu string $23 = character name
    JSR DrawCharMenuString

    LDX #1*4                        ; Draw Box 1 (Class name & battle sprite)
    JSR @DrawStatusBox
    LDA #$24                        ; Menu string $24 = class name
    JSR DrawCharMenuString

    LDX #2*4                        ; Draw Box 2 (Level)
    JSR @DrawStatusBox
    LDA #$25                        ; Menu string $25 = level
    JSR DrawCharMenuString

    LDX #3*4                        ; Draw Box 3 (EXP)
    JSR @DrawStatusBox
    LDA #$26                        ; Menu string $26 = EXP / For Lev Up
    JSR DrawCharMenuString

    LDX #4*4                        ; Draw Box 4 (Base stats)
    JSR @DrawStatusBox
    LDA #$27                        ; Menu string $27 = STR, AGL, INT, VIT, LUCK
    JSR DrawCharMenuString

    LDX #5*4                        ; Draw Box 5 (Sub stats)
    JSR @DrawStatusBox
    LDA #$28                        ; Menu string $28 = DAMAGE, HIT, ABSORB, EVADE
    JSR DrawCharMenuString

    JSR ClearOAM                    ; Clear shadow OAM

    LDA submenu_targ                ; 0..3
    ASL A
    ASL A
    ASL A
    ASL A
    ASL A
    ASL A                           ; Shift to $00, $40, $80, $C0
    JSR DrawOBSprite                ; Draw hero battle sprite inside Box 1

    JMP MenuWaitForBtn_SFX          ; Wait for A or B before exiting

@DrawStatusBox:
    LDA lut_StatusBoxes, X
    STA box_x
    LDA lut_StatusBoxes+1, X
    STA box_y
    LDA lut_StatusBoxes+2, X
    STA box_wd
    LDA lut_StatusBoxes+3, X
    STA box_ht
    JSR DrawBox
    INC dest_y                      ; Text starts on box_y + 2
    RTS

lut_StatusBoxes:
    .BYTE  4,  0,  8,  5            ; Box 0: Character name (top left)
    .BYTE 13,  0, 14,  5            ; Box 1: Battle sprite & class name (top center)
    .BYTE 28,  0,  8,  5            ; Box 2: Level (top right)
    .BYTE  8,  5, 23,  7            ; Box 3: EXP (center)
    .BYTE  4, 12, 14, 13            ; Box 4: Base stats (STR, AGL, INT, VIT, LUCK)
    .BYTE 19, 12, 16, 13            ; Box 5: Sub stats (DAMAGE, HIT, ABSORB, EVADE)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Character Menu String  [8541]
;;
;;     Draws a desired menu string (see DrawMenuString), but replaces character stat
;;  codes in the string to reflect the stats of the given character.
;;
;;  IN:              A = menu string ID to draw
;;        submenu_targ = character ID whose stats to draw (0..3)
;;                   Y = length of string (DrawCharMenuString_Len only!)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawCharMenuString:
    LDY #$7F                        ; set length to default 7F

DrawCharMenuString_Len:
    ASL A                           ; double menu string ID
    TAX                             ; put in X
    LDA lut_MenuText, X             ; and load up the pointer into (tmp)
    STA tmp
    LDA lut_MenuText+1, X
    STA tmp+1

    LDA #<bigstr_buf                ; set the text pointer to our bigstring buffer
    STA text_ptr
    LDA #>bigstr_buf
    STA text_ptr+1

@Loop:                              ; now step through each byte of the string....
    LDA (tmp), Y                    ; get the byte
    CMP #$10                        ; compare it to $10 (character stat control code)
    BNE :+                          ;   if it equals...
      ORA submenu_targ              ;   OR with desired character ID (0..3 -> $10..$13)
:   STA bigstr_buf, Y               ; copy the byte to the big string buffer
    DEY                             ; then decrement Y
    CPY #$FF                        ; check to see if it wrapped
    BNE @Loop                       ; and keep looping until it has

    JMP DrawMenuComplexString       ; draw the complex string and exit.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuWaitForBtn_SFX  [7745]
;;
;;    Waits until the user presses A or B, plays MenuSel SFX, and returns.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuWaitForBtn_SFX:
    JSR MenuFrame
    LDA joy_a
    ORA joy_b
    BEQ MenuWaitForBtn_SFX
    LDA #0
    STA joy_a
    STA joy_b
    JMP PlaySFX_MenuSel


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MenuWaitForBtn  [7756]
;;
;;    Waits until the user presses A or B without SFX, and returns.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuWaitForBtn:
    JSR MenuFrame
    LDA joy_a
    ORA joy_b
    BEQ MenuWaitForBtn
    LDA #0
    STA joy_a
    STA joy_b
    RTS



; ==============================================================================
; Main Menu Drawing & Coordinates (C64 40x25 Layout)
; ==============================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Main Menu  [8233]
;;
;;  Clears the screen, draws all 7 boxes (Orb, GP, Option, 4 Hero Boxes),
;;  and populates their contents.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ClearMenuScreen
;;
;;  Prepares VIC-II and clears screen for menus:
;;    - Screen border = Black ($00)
;;    - Background 0  = Blue ($06)
;;    - Multicolor 1  = White ($01)
;;    - Multicolor 2  = Dark Grey ($0B)
;;    - Screen RAM    = Character $00 (solid black tile)
;;    - Color RAM     = Black ($00)
;;
;;  When windows are drawn over this, character $FF (blank space)
;;  allows Background 0 (Blue) to shine through inside the boxes,
;;  while the outside empty spaces remain solid black.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearMenuScreen:
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0
    LDA #COLOR_WHITE
    STA BGCOL1
    LDA #COLOR_DARKGREY
    STA BGCOL2

    ; Fill Screen RAM with character $00 (solid black block)
    LDX #$00
    LDA #$00
@LoopScreen:
    STA $4000, X
    STA $4100, X
    STA $4200, X
    STA $4300, X
    INX
    BNE @LoopScreen

    ; Fill Color RAM with color 0 (black)
    LDX #$00
    LDA #COLOR_BLACK
@LoopColor:
    STA COLOR_RAM, X
    STA COLOR_RAM + $0100, X
    STA COLOR_RAM + $0200, X
    STA COLOR_RAM + $0300, X
    INX
    BNE @LoopColor

    ; Ensure VIC-II Bank 1 ($4000-$7FFF) is selected
    LDA CI2DRA
    ORA #$03
    STA CI2DRA
    LDA CI2PRA
    AND #$FC
    ORA #VIC_BANK1
    STA CI2PRA

    LDA #$1B
    STA SCROLY
    LDA #$18                   ; 40 cols, MultiColor text mode ON (bit 4 = 1)
    STA SCROLX
    LDA #$02                   ; Screen: $4000, Charset: $4800
    STA VMCSB
    RTS


DrawMainMenu:
    JSR ClearMenuScreen            ; Clear screen with character $00 and COLOR_BLACK
    JSR DrawOrbBox                 ; draw the orb box (Box 0) and orbs
    JSR DrawMainMenuGoldBox        ; gold box (Box 5)
    JSR DrawMainMenuOptionBox      ; option box (Box 6)

    LDA #1                         ; Box 1: Character 0
    JSR DrawMainItemBox
    LDA #$00
    JSR DrawMainMenuCharBoxBody

    LDA #2                         ; Box 2: Character 1
    JSR DrawMainItemBox
    LDA #$40
    JSR DrawMainMenuCharBoxBody

    LDA #3                         ; Box 3: Character 2
    JSR DrawMainItemBox
    LDA #$80
    JSR DrawMainMenuCharBoxBody

    LDA #4                         ; Box 4: Character 3
    JSR DrawMainItemBox
    LDA #$C0
    JMP DrawMainMenuCharBoxBody    ; and then exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Main Menu Gold Box  [8269]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainMenuGoldBox:
    LDA #5                         ; Draw MainItem Box 5 (GP Box)
    JSR DrawMainItemBox
    INC dest_y                     ; dest_y = 12 (centered in 5-row box)
    LDA #$01                       ; Menu string 1 = "[Gold] G"
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Orb Box  [8284]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOrbBox:
    LDA #0                         ; Draw MainItem Box 0
    JSR DrawMainItemBox

    ; Fire Orb (top-left inside box: dest_x = 7, dest_y = 2)
    LDA #7
    STA dest_x
    LDA #2
    STA dest_y
    LDA orb_fire
    LDX #$64
    JSR DrawOneOrb

    ; Water Orb (top-right inside box: dest_x = 9, dest_y = 2)
    LDA #9
    STA dest_x
    LDA #2
    STA dest_y
    LDA orb_water
    LDX #$68
    JSR DrawOneOrb

    ; Air Orb (bottom-left inside box: dest_x = 7, dest_y = 4)
    LDA #7
    STA dest_x
    LDA #4
    STA dest_y
    LDA orb_air
    LDX #$6C
    JSR DrawOneOrb

    ; Earth Orb (bottom-right inside box: dest_x = 9, dest_y = 4)
    LDA #9
    STA dest_x
    LDA #4
    STA dest_y
    LDA orb_earth
    LDX #$70
    JMP DrawOneOrb


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawOneOrb
;;
;;  Draws a 2x2 tile orb at (dest_x, dest_y).
;;  Hi-res characters:
;;    - Grey (COLOR_LIGHTGREY = 15) when not lit (tile $76)
;;    - White (COLOR_WHITE = 1) when lit (element tile from X)
;;
;;  IN:  A = orb status (0 = unlit, nonzero = lit)
;;       X = base tile ID when lit
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOneOrb:
    CMP #0
    BNE @IsLit
    LDX #$76                       ; Unlit orb base tile ($76)
    LDY #COLOR_BLACK               ; Unlit color: 0 (Black)
    JMP @WriteOrb
@IsLit:
    LDY #COLOR_WHITE               ; Lit color: 1 (White)
@WriteOrb:
    STY tmp                        ; save color in tmp ($10)
    STX tmp+1                      ; save tile in tmp+1 ($11)

    JSR CoordToNTAddr

    ; Compute color_dest = ppu_dest + ($D800 - $4000)
    LDA ppu_dest
    STA color_dest
    LDA ppu_dest+1
    CLC
    ADC #>($D800 - $4000)
    STA color_dest+1

    ; Top row:
    LDY #0
    LDA tmp+1                      ; tile
    STA (ppu_dest), Y
    LDA tmp
    STA (color_dest), Y

    INY                            ; next column
    INC tmp+1
    LDA tmp+1                      ; tile + 1
    STA (ppu_dest), Y
    LDA tmp
    STA (color_dest), Y

    ; Bottom row (+40 bytes):
    LDA ppu_dest
    CLC
    ADC #40
    STA ppu_dest
    BCC :+
    INC ppu_dest+1
:
    LDA color_dest
    CLC
    ADC #40
    STA color_dest
    BCC :+
    INC color_dest+1
:
    LDY #0
    INC tmp+1
    LDA tmp+1                      ; tile + 2
    STA (ppu_dest), Y
    LDA tmp
    STA (color_dest), Y

    INY
    INC tmp+1
    LDA tmp+1                      ; tile + 3
    STA (ppu_dest), Y
    LDA tmp
    STA (color_dest), Y
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMainMenuOptionBox  [8413]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainMenuOptionBox:
    LDA #6                         ; Draw MainItem Box 6 (Option Box)
    JSR DrawMainItemBox
    LDA #$02                       ; Menu string 2 = Options list
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMainItemBox  [8369]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainItemBox:
    JSR LoadMainItemBoxDims
    JMP DrawBox

LoadMainItemBoxDims:
    ASL A                          ; multiply ID by 4 (4 bytes per box)
    ASL A
    TAX

    LDA lut_MainItemBoxes, X
    STA box_x
    LDA lut_MainItemBoxes+1, X
    STA box_y
    LDA lut_MainItemBoxes+2, X
    STA box_wd
    LDA lut_MainItemBoxes+3, X
    STA box_ht

    LDA #BANK_THIS
    STA cur_bank
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMainMenuCharBoxBody  [8590]
;;
;;  Draws character stats inside a hero box:
;;  Row 0: Name (stat 0)
;;  Row 1: Level (stat 3)
;;  Row 2: Ailment (stat 2) + CurHP / MaxHP (stats 5 & 6)
;;  Row 3: "MAGIC" (if character has MP)
;;  Row 4: MP 1-4 (if character has MP)
;;  Row 5: MP 5-8 (if character has MP)
;;
;;  IN: A = character index ($00, $40, $80, $C0)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainMenuCharBoxBody:
    PHA                            ; Save char index ($00, $40, $80, $C0)
    TAX

    LDA #>str_buf
    STA text_ptr+1

    ; Check if this character has any Max MP
    LDA ch_maxmp, X
    ORA ch_maxmp+1, X
    ORA ch_maxmp+2, X
    ORA ch_maxmp+3, X
    ORA ch_maxmp+4, X
    ORA ch_maxmp+5, X
    ORA ch_maxmp+6, X
    ORA ch_maxmp+7, X
    BNE @DrawMP
    JMP @NoMP

@DrawMP:
    LDY #0
@MPLoop:
    LDA ch_curmp, X                ; current MP for this level
    ORA #$80                       ; convert to digit tile
    STA str_buf, Y
    INY
    LDA #$7A                       ; '/' separator
    STA str_buf, Y
    INX
    INY
    CPY #8*2
    BCC @MPLoop

    ; Terminate row 2 (levels 4-7)
    LDA #0
    STA str_buf + 15

    ; Draw row 2 (levels 4-7) at dest_y + 9
    LDA dest_y
    CLC
    ADC #9
    STA dest_y
    LDA #<(str_buf + 8)
    STA text_ptr
    JSR DrawMenuComplexString

    ; Terminate row 1 (levels 0-3) and draw at dest_y + 8
    LDA #0
    STA str_buf + 7
    DEC dest_y
    LDA #<str_buf
    STA text_ptr
    JSR DrawMenuComplexString

    ; Draw "MAGIC" header at dest_y + 7
    LDA #$52                       ; "MA" DTE tile
    STA str_buf
    LDA #$4A                       ; "GI" DTE tile
    STA str_buf+1
    LDA #$8C                       ; "C" tile
    STA str_buf+2
    LDA #0
    STA str_buf+3
    DEC dest_y
    LDA #<str_buf
    STA text_ptr
    JSR DrawComplexString

    ; Restore dest_y back to dest_y + 0
    LDA dest_y
    SEC
    SBC #7
    STA dest_y

@NoMP:
    PLA                            ; Restore char index ($00, $40, $80, $C0)
    ; Convert $00,$40,$80,$C0 to control code $10,$11,$12,$13
    ASL A
    ROL A
    ROL A
    AND #$03
    ORA #$10
    STA tmp+9                      ; tmp+9 = stat control code ($10-$13)

    ; Build string for Name, Level, Ailment, and CurHP/MaxHP:
    ; Row 0: Name (stat 0)
    ; Row 2: "L" ($95) + Level (stat 3)
    ; Row 4: Ailment (stat 2)
    ; Row 5: CurHP (stat 5) + "/" ($7A) + MaxHP (stat 6)
    LDA tmp+9
    STA str_buf + 0                ; Control code ($10-$13)
    LDA #$00                       ; Stat 0 = Name (4 chars)
    STA str_buf + 1
    LDA #$01                       ; Double line break ($01) -> Row 2
    STA str_buf + 2
    LDA #$95                       ; 'L' tile ($95)
    STA str_buf + 3
    LDA tmp+9
    STA str_buf + 4                ; Control code ($10-$13)
    LDA #$03                       ; Stat 3 = Level (2 digits)
    STA str_buf + 5
    LDA #$01                       ; Double line break ($01) -> Row 4
    STA str_buf + 6
    LDA tmp+9
    STA str_buf + 7                ; Control code ($10-$13)
    LDA #$02                       ; Stat 2 = Ailment ("HP", "ST", "PO")
    STA str_buf + 8
    LDA #$05                       ; Single line break ($05) -> Row 5
    STA str_buf + 9
    LDA tmp+9
    STA str_buf + 10               ; Control code ($10-$13)
    LDA #$05                       ; Stat 5 = Cur HP (3 digits)
    STA str_buf + 11
    LDA #$7A                       ; '/' tile
    STA str_buf + 12
    LDA tmp+9
    STA str_buf + 13               ; Control code ($10-$13)
    LDA #$06                       ; Stat 6 = Max HP (3 digits)
    STA str_buf + 14
    LDA #0                         ; Null terminator
    STA str_buf + 15

    LDA #<str_buf
    STA text_ptr
    LDA #>str_buf
    STA text_ptr+1
    JMP DrawComplexString          ; Draw string and exit!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMenuString  [8485]
;;
;;  IN: A = ID of menu string to draw ($00-$3F)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMenuString:
    ASL A                          ; 2 bytes per pointer
    TAX
    LDA lut_MenuText, X
    STA text_ptr
    LDA lut_MenuText+1, X
    STA text_ptr+1

DrawMenuComplexString:
    LDA #BANK_THIS
    STA cur_bank
    STA ret_bank
    JMP DrawComplexString


; ==============================================================================
; lut_MainItemBoxes - Box Coordinates and Dimensions (C64 40x25 Layout)
; Format per box: [X, Y, Width, Height]
; ==============================================================================

lut_MainItemBoxes:
    .BYTE   5,  0,  8,  8      ; Box 0: Orb Box (X=5, Y=0, W=8, H=8)
    .BYTE  15,  0, 10, 12      ; Box 1: Character 0 stat box (X=15, Y=0, W=10, H=12)
    .BYTE  26,  0, 10, 12      ; Box 2: Character 1 stat box (X=26, Y=0, W=10, H=12)
    .BYTE  15, 12, 10, 12      ; Box 3: Character 2 stat box (X=15, Y=12, W=10, H=12)
    .BYTE  26, 12, 10, 12      ; Box 4: Character 3 stat box (X=26, Y=12, W=10, H=12)
    .BYTE   4, 10, 10,  5      ; Box 5: GP box (X=4, Y=10, W=10, H=5)
    .BYTE   5, 17,  8,  7      ; Box 6: Option box (X=5, Y=17, W=8, H=7)
    .BYTE   5,  0,  8,  4      ; Box 7: Item / Magic title box (X=5, Y=0, W=8, H=4)
    .BYTE   5, 20, 30,  5      ; Box 8: Description box (X=5, Y=20, W=30, H=5)
    .BYTE   5,  2, 30, 18      ; Box 9: Main list box (X=5, Y=2, W=30, H=18)


; ==============================================================================
; Menu Text Pointer Table & String Data
; ==============================================================================

str_MainMenuOptions:
    .BYTE $92, $9D, $8E, $96, $05             ; "ITEM"
    .BYTE $96, $8A, $90, $92, $8C, $05       ; "MAGIC"
    .BYTE $CF, $D0, $D1, $D2, $D3, $05       ; "WEAPON" (condensed: $CF..$D3)
    .BYTE $8A, $9B, $96, $98, $9B, $05       ; "ARMOR"
    .BYTE $CA, $CB, $CC, $CD, $CE, $00       ; "STATUS" (condensed: $CA..$CE)

lut_MenuText:
    .WORD lut_MenuStrings + $0000, lut_MenuStrings + $0001, str_MainMenuOptions, lut_MenuStrings + $0027
    .WORD lut_MenuStrings + $002D, lut_MenuStrings + $003A, lut_MenuStrings + $0059, lut_MenuStrings + $0073
    .WORD lut_MenuStrings + $0081, lut_MenuStrings + $0095, lut_MenuStrings + $00B0, lut_MenuStrings + $00BE
    .WORD lut_MenuStrings + $00C8, lut_MenuStrings + $00D6, lut_MenuStrings + $00F1, lut_MenuStrings + $00FE
    .WORD lut_MenuStrings + $011E, lut_MenuStrings + $013D, lut_MenuStrings + $015F, lut_MenuStrings + $016D
    .WORD lut_MenuStrings + $018E, lut_MenuStrings + $01B8, lut_MenuStrings + $01D3, lut_MenuStrings + $01F0
    .WORD lut_MenuStrings + $01FB, lut_MenuStrings + $0214, lut_MenuStrings + $0226, lut_MenuStrings + $024C
    .WORD lut_MenuStrings + $025D, lut_MenuStrings + $0283, lut_MenuStrings + $0294, lut_MenuStrings + $02C9
    .WORD lut_MenuStrings + $02E6, lut_MenuStrings + $02F8, lut_MenuStrings + $030B, lut_MenuStrings + $0327
    .WORD lut_MenuStrings + $032B, lut_MenuStrings + $0332, lut_MenuStrings + $0339, lut_MenuStrings + $035C
    .WORD lut_MenuStrings + $0398, lut_MenuStrings + $03CB, lut_MenuStrings + $03CF, lut_MenuStrings + $0487
    .WORD lut_MenuStrings + $0499, lut_MenuStrings + $04CD, lut_MenuStrings + $04E5, lut_MenuStrings + $04F7
    .WORD lut_MenuStrings + $0517, lut_MenuStrings + $0533, lut_MenuStrings + $055E, lut_MenuStrings + $057B
    .WORD lut_MenuStrings + $0598, lut_MenuStrings + $059E, lut_MenuStrings + $05B3, lut_MenuStrings + $05B7
    .WORD lut_MenuStrings + $05B8, lut_MenuStrings + $05BC, lut_MenuStrings + $05BD, lut_MenuStrings + $05C1
    .WORD lut_MenuStrings + $05C2, lut_MenuStrings + $05C6, lut_MenuStrings + $05C7, lut_MenuStrings + $05CD

lut_MenuStrings:
    .INCBIN "../res/menu/menustrings.bin"
