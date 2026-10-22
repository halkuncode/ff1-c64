.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "BANK_0E"

.export EnterIntroStory, EnterTitleScreen, NewGamePartyGeneration, DoPartyGen_OnCharacter
.export PtyGen_DrawText, PtyGen_DrawOneText, PtyGen_DrawCursor, PtyGen_Frame, PtyGen_Joy
.import LoadMenuCHRPal, LoadNewGameCHRPal, DrawComplexString, WaitForVBlank_L, UpdateJoy_L, DrawBox
.import GameStart_L, CallMusicPlay_L, ClearOAM, DrawPalette_L, DrawCursor
.import lut_ScreenRowLo, lut_ScreenRowHi
.import lut_IntroStoryText

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

    ; Set border to black, background to blue
    LDA #$0F
    STA cur_pal + $0C          ; Virtual palette border = Black ($0F) for title screen
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0

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

    ; Set standard VIC-II text mode: 40 cols, 25 rows, screen ON
    LDA #$1B
    STA SCROLY
    LDA #$08
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
;;  ClearNT  [$9B5E :: 0x39B6E]  [2504]
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

    JSR UpdateJoy_L         ; Scan keyboard & joystick
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
;;  Pointerless strings for the title screen  [$A253 :: 0x3A263]
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
;;  Small LUT for the Y position of the title screen cursor  [$A272 :: 0x3A282]

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

    JSR IntroStory_Joy         ; update joypad

    LDA joy_a                  ; check to see if either A
    ORA joy_b                  ;  or B were pressed
    BNE :+                     ; if not...
      RTS                      ; ... exit normally

:   PLA                        ; if either A or B pressed, PLA to drop the last
    PLA                        ;  return address, then exit (does a double-RTS)
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Turn Menu Screen On   [$B78A :: 0x3B79A]  [8078]
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
    RTS                     ; Return to bank0F (which enters halt_loop to display screen)


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

    ; Name screen input is deferred until next step per user instructions
    ; LDA joy_a
    ; BNE DoNameInput
    LDA joy_b
    BEQ :+
      SEC
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
    ; Set border to black, background to blue
    LDA #$0F
    STA cur_pal + $0C          ; Virtual palette border = Black ($0F) for title screen
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_BLUE
    STA BGCOL0

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
    LDA #$08
    STA SCROLX
    LDA #$02                   ; Screen: $4000, Charset: $4800
    STA VMCSB

    ; Clear soft2000 & joypad catchers
    LDA #$08
    STA soft2000
    LDA #0
    STA joy_a
    STA joy_b
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
;;  PtyGen_DrawCursor  [$9F26 :: 0x39F36]  [3155]
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