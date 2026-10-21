.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "BANK_0E"

.export EnterIntroStory, EnterTitleScreen
.import LoadMenuCHRPal, DrawComplexString, WaitForVBlank_L, UpdateJoy_L, DrawBox
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

;; Draw the finger cursor at its starting position, flush, and return
    JSR ClearOAM            ; Clear shadow sprite buffer

    LDX #0
    STX cursor              ; Cursor at starting position (0 = Continue)
    LDA #120                ; Cursor X coord
    STA spr_x
    LDA lut_TitleCursor_Y   ; Y coord for position 0
    STA spr_y
    JSR DrawCursor          ; Draw Finger Cursor (Base + Overlay)

    JSR WaitForVBlank_L     ; Wait for VBlank so UpdateSprites flushes to VIC-II hardware
    RTS                     ; Return to bank0F.asm (which pauses in halt_loop)

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