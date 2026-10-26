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
.import LoadMenuCHRPal, LoadNewGameCHRPal, DrawComplexString, WaitForVBlank_L, UpdateJoy_L, DrawBox
.import GameStart_L, CallMusicPlay_L, ClearOAM, DrawPalette_L, DrawCursor
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
;;  Print Character Stat  [$8D70 :: 0x38D80]
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
;;  Print Price  [$8E44 :: 0x38E54]
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
;;  Print Gold   [$8E4A :: 0x38E5A]
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
;;  Print Number   [$8E5C :: 0x38E6C]
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
;;  Trim Zeros  [$8E9F :: 0x38EAF]
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
;;  Format Number  [$8ED2 :: 0x38EE2]
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
;;  Decimal conversion LUTs  [$8FD1 :: 0x38FE1]
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
;;  Enter Main Menu  [$ADB3 :: 0x3ADC3]
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
;;  Main Menu Sub Target  [$AE71 :: 0x3AE81]
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
;;  Move Main Menu Sub Cursor  [$B68C :: 0x3B69C]
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
;;  Move Cursor Up / Down  [$B6AB :: 0x3B6CB]
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
;;  Menu Frame  [$B65D :: 0x3B66D]
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

EnterItemMenu:
    RTS

EnterMagicMenu:
    RTS

EnterEquipMenu:
    RTS

EnterStatusMenu:
    RTS


; ==============================================================================
; Main Menu Drawing & Coordinates (C64 40x25 Layout)
; ==============================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Main Menu  [$B84A :: 0x3B85A]
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
;;  Draw Main Menu Gold Box  [$B86E :: 0x3B87E]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainMenuGoldBox:
    LDA #5                         ; Draw MainItem Box 5 (GP Box)
    JSR DrawMainItemBox
    LDA #$01                       ; Menu string 1 = "[Gold] G"
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Orb Box  [$B878 :: 0x3B888]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOrbBox:
    LDA #0                         ; Draw MainItem Box 0
    JSR DrawMainItemBox

    ; Fire Orb (top-left inside box: dest_x = 3, dest_y = 2)
    LDA #3
    STA dest_x
    LDA #2
    STA dest_y
    LDA orb_fire
    LDX #$64
    LDY #COLOR_LIGHTRED
    JSR DrawOneOrb

    ; Water Orb (top-right inside box: dest_x = 6, dest_y = 2)
    LDA #6
    STA dest_x
    LDA #2
    STA dest_y
    LDA orb_water
    LDX #$68
    LDY #COLOR_LIGHTBLUE
    JSR DrawOneOrb

    ; Air Orb (bottom-left inside box: dest_x = 3, dest_y = 4)
    LDA #3
    STA dest_x
    LDA #4
    STA dest_y
    LDA orb_air
    LDX #$6C
    LDY #COLOR_LIGHTGREEN
    JSR DrawOneOrb

    ; Earth Orb (bottom-right inside box: dest_x = 6, dest_y = 4)
    LDA #6
    STA dest_x
    LDA #4
    STA dest_y
    LDA orb_earth
    LDX #$70
    LDY #COLOR_BROWN
    JMP DrawOneOrb


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawOneOrb
;;
;;  Draws a 2x2 tile orb at (dest_x, dest_y).
;;  IN:  A = orb status (0 = unlit, nonzero = lit)
;;       X = base tile ID when lit
;;       Y = color when lit
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOneOrb:
    CMP #0
    BNE @IsLit
    LDX #$76                       ; Unlit orb base tile ($76)
    LDY #COLOR_DARKGREY            ; Unlit color ($0B)
@IsLit:
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
;;  DrawMainMenuOptionBox  [$B911 :: 0x3B921]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMainMenuOptionBox:
    LDA #6                         ; Draw MainItem Box 6 (Option Box)
    JSR DrawMainItemBox
    LDA #$02                       ; Menu string 2 = Options list
    JMP DrawMenuString


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawMainItemBox  [$B8EF :: 0x3B8FF]
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
;;  DrawMainMenuCharBoxBody  [$B9DB :: 0x3B9EB]
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

    ; Draw row 2 (levels 4-7) at dest_y + 5
    LDA dest_y
    CLC
    ADC #5
    STA dest_y
    LDA #<(str_buf + 8)
    STA text_ptr
    JSR DrawMenuComplexString

    ; Terminate row 1 (levels 0-3) and draw at dest_y + 4
    LDA #0
    STA str_buf + 7
    DEC dest_y
    LDA #<str_buf
    STA text_ptr
    JSR DrawMenuComplexString

    ; Draw "MAGIC" header at dest_y + 3
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
    SBC #3
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

    ; Build single-spaced string for Name, Level, and Ailment/HP:
    ; Row 0: Name
    ; Row 1: Level
    ; Row 2: Ailment + HP
    LDA tmp+9
    STA str_buf + 0                ; Control code ($10-$13)
    LDA #$00                       ; Stat 0 = Name (4 chars)
    STA str_buf + 1
    LDA #$05                       ; Single line break ($05) -> Row 1
    STA str_buf + 2
    LDA #$C6                       ; 'L' tile
    STA str_buf + 3
    LDA tmp+9
    STA str_buf + 4                ; Control code ($10-$13)
    LDA #$03                       ; Stat 3 = Level (2 digits)
    STA str_buf + 5
    LDA #$05                       ; Single line break ($05) -> Row 2
    STA str_buf + 6
    LDA tmp+9
    STA str_buf + 7                ; Control code ($10-$13)
    LDA #$02                       ; Stat 2 = Ailment ("HP", "ST", "PO")
    STA str_buf + 8
    LDA #$FF                       ; Space
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
;;  DrawMenuString  [$B938 :: 0x3B948]
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
    .BYTE   1,  1, 10,  6      ; Box 0: Orb Box (X=1, Y=1, W=10, H=6)
    .BYTE  12,  1, 13, 10      ; Box 1: Character 0 stat box (X=12, Y=1, W=13, H=10)
    .BYTE  26,  1, 13, 10      ; Box 2: Character 1 stat box (X=26, Y=1, W=13, H=10)
    .BYTE  12, 12, 13, 10      ; Box 3: Character 2 stat box (X=12, Y=12, W=13, H=10)
    .BYTE  26, 12, 13, 10      ; Box 4: Character 3 stat box (X=26, Y=12, W=13, H=10)
    .BYTE   1,  7, 10,  4      ; Box 5: GP box (X=1, Y=7, W=10, H=4)
    .BYTE   1, 12, 10, 10      ; Box 6: Option box (X=1, Y=12, W=10, H=10)
    .BYTE   1,  1,  8,  4      ; Box 7: Item title box (X=1, Y=1, W=8, H=4)
    .BYTE   1, 18, 38,  6      ; Box 8: Item description box (X=1, Y=18, W=38, H=6)
    .BYTE   1,  5, 38, 13      ; Box 9: Item list box (X=1, Y=5, W=38, H=13)


; ==============================================================================
; Menu Text Pointer Table & String Data
; ==============================================================================

str_MainMenuOptions:
    ; " ITEM" [Single Break: $05] " MAGIC" [Single Break: $05] ...
    .BYTE $FF, $92, $9D, $8E, $96, $05
    .BYTE $FF, $96, $8A, $90, $92, $8C, $05
    .BYTE $FF, $CF, $D0, $D1, $D2, $D3, $05
    .BYTE $FF, $8A, $9B, $96, $98, $9B, $05
    .BYTE $FF, $CA, $CB, $CC, $CD, $CE, $00

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
