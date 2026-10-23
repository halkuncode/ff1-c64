.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "KERNEL"

.export GameStart_L

.export DrawComplexString_L, DrawBox_L, CallMusicPlay_L, UpdateJoy_L, DrawPalette_L
.export DrawComplexString, DrawBox, CallMusicPlay, UpdateJoy, DrawPalette, LoadMenuCHRPal, ClearOAM
.export LoadBorderPalette_Blue, LoadBorderPalette_Black
.export LoadMenuCHR, LoadMenuBGCHRAndPalettes, LoadBattleBGCHRAndPalettes, LoadBatSprCHRPalettes, LoadNewGameCHRPal
.export GameStart, OnReset, OnNMI, OnIRQ
.export WaitForVBlank_L, WaitForVBlank
.export SwapPRG_L, SwapPRG
.export CoordToNTAddr, lut_ScreenRowLo, lut_ScreenRowHi
.export DrawCursor, UpdateSprites, VerifyChecksum
.export lut_NES_to_C64

.import EnterIntroStory, EnterTitleScreen, NewGamePartyGeneration
.import lut_MenuCHR
.import lut_FingerSprite, lut_HeroSprites
.import lut_BattleFormations
.import MusicPlay_L


;;;;
;;
;;  This is a jump table of sorts.  Best I can figure is that the assembler the original developers used assembled
;;    each bank seperately, and didn't have an advanced linker.  So instead of JMPing to arbitrary addresses that
;;    could change as routines get moved around and stuff, other banks JSR to these routines which are at fixed,
;;    easy to remember addresses -- and then these addresses just JMP to the proper routine.
;;
;;  With ca65 and more modern assemblers, this isn't necessary at all.  You can just JSR to the real routines directly
;;    instead of these '_L' routines and save yourself 3 cycles.
;;
;;;;

GameStart_L:          JMP GameStart
DrawComplexString_L:  JMP DrawComplexString
DrawBox_L:            JMP DrawBox
CallMusicPlay_L:      JMP CallMusicPlay
UpdateJoy_L:          JMP UpdateJoy
DrawPalette_L:        JMP DrawPalette


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Game Start [59]
;;
;;    The game code starts here.  This is jumped to after the reset vector
;;  preps all the necessary hardware stuff.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GameStart:
    lda #COLOR_BLACK	; Turn off diplay (screen background color to black ($00))
    sta BGCOL0

	STA unk_FE          ; ?? I don't think this is ever used

	lda #$02			; set default screen pointer ($4000) and charset ($4800)
    sta VMCSB			; Screen: $4000 (bits 7-4=0000), Charset: $4800 (bits 3-1=001 -> $02)

	LDX #$FF            ; reset stack pointer
    TXS

    ; Check if cold boot or warm reset (Enter/Start pressed during intro)
    LDA startintrocheck
    CMP #$4D
    BEQ @TitleScreen

    ; Cold boot: initialize variables
    LDA #0
    STA btlformation
    STA ow_tile

	LDA #0              ; (pointless LDA)
	JSR DisableAPU      ; Silence/disable all audio

    ;; Load some startup info
    
    LDA #BANK_STARTUPINFO       ; swap in bank containing some LUTs
    JSR SwapPRG_L

    LDX #$00                        ; Loop $100 times to fill each page of unsram
    : LDA lut_InitUnsramFirstPage, X; Page 0 of unsram is loaded from this table
      STA unsram, X
      
      LDA #0                        ; stat page filled with zeros (proper stats will be assigned
      STA ch_stats, X               ;   later after party generation)
      
      LDA lut_InitGameFlags, X      ; game flags page loaded from this table
      STA game_flags, X
      
      LDA #0                        ; zero magic data page (proper MP assigned after
      STA ch_magicdata, X           ; party generation
      
      INX                           ; loop for the full page
      BNE :-

	LDA #40
	STA ch_exptonext                ; initialize exptonext.  40 XP to get to level 2
	STA ch_exptonext + (1<<6)
	STA ch_exptonext + (2<<6)
	STA ch_exptonext + (3<<6)
	
	LDA #$01                        ; start on foot
	STA unsram_vehicle

    LDA #$4D
    STA startintrocheck             ; Mark as initialized so warm reset goes to title screen

    LDA #BANK_INTRO                 ; Cold boot: do the intro story!
    JSR SwapPRG_L
    JSR EnterIntroStory

@TitleScreen:
    LDA #BANK_TITLE                 ; Then swap in the title bank
    JSR SwapPRG_L                   ; to do the title screen
    JSR EnterTitleScreen

    BCS @NewGame                    ; Do a new game, if the user selected the New Game option
    
        ; Otherwise, they selected "Continue"...
    LDA sram_assert_55              ; check sram assertion values to make sure
    CMP #$55                        ;  sram is not corrupt.  If they are not what are expected...
    BNE @NewGame                    ;  then do a new game.
    LDA sram_assert_AA
    CMP #$AA
    BNE @NewGame
    
    JSR VerifyChecksum              ; Then verify checksum to ensure save game integrity
    BCS @NewGame                    ;  if it failed, do a new game
    
    ; Continue saved game
    LDX #$00
    : LDA   sram, X                 ; Copy all of SRAM to unsram
      STA unsram, X
      LDA   sram+$100, X
      STA unsram+$100, X
      LDA   sram+$200, X
      STA unsram+$200, X
      LDA   sram+$300, X
      STA unsram+$300, X
      INX
      BNE :-
    JMP @Begin                      ; Then begin the game
    
    
  @NewGame:
    LDA #BANK_PARTYGEN              ; swap in party generation bank
    JSR SwapPRG_L
    JSR NewGamePartyGeneration      ; create a new party

@Begin:  
halt_loop:
    jsr WaitForVBlank_L
    jsr CallMusicPlay_L
    jmp halt_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Verify Checksum  [2057]
;;
;;    Sums every byte in SRAM ($6400-$67FF) including carry.
;;    If the result equals $FF, CLC (valid).
;;    Otherwise, SEC (corrupt).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VerifyChecksum:
    LDA #$00      ; clear A
    LDX #$00      ; and X
    CLC           ; and C!
@Loop:
    ADC $6400, X  ; sum every byte between $6400-$67FF
    ADC $6500, X  ; include carry in each addition
    ADC $6600, X
    ADC $6700, X
    INX
    BNE @Loop

    CMP #$FF      ; if result does not equal $FF, the checksum has failed
    BNE @Fail

    ; success!
    CLC
    RTS

@Fail:
    SEC
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Clear OAM   [976]
;;
;;    Fills Shadow OAM with $F8 (which effectively clears it so no sprites are visible)
;;  also resets the sprite index to zero, so that the next sprite drawn will
;;  have top priority.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearOAM:
    lda #$00
    sta shadow_spr_en       ; Turn off all 8 sprite enables
    sta sprindex            ; Reset allocation pointer to Slot 0
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Disable APU  [1042]
;;
;;    Silences all channels and prevents them from being audible until they are
;;  re-enabled. Channels will become re-enabled once the music engine starts
;;  a new track.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisableAPU:
    lda #$00
    sta V1CR        ; Voice 1 Control (Gate off, clear waveform)
    sta V2CR        ; Voice 2 Control (Gate off, clear waveform)
    sta V3CR        ; Voice 3 Control (Gate off, clear waveform)
    sta SIGVOL      ; Master Volume & Filter Mode = 0 (silence)
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CallMusicPlay  [1613]
;;
CallMusicPlay:
    pha
    txa
    pha
    tya
    pha
    lda cur_bank
    pha

    lda #BANK_MUSIC
    jsr SwapPRG
    jsr MusicPlay_L

    pla
    jsr SwapPRG

    pla
    tay
    pla
    tax
    pla
    rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawPalette  [5863]
;;
;;    Flushes the 32-byte Virtual Palette (cur_pal at $0240) to VIC-II registers.
;;    Translates NES 6-bit color indices to C64 colors using lut_NES_to_C64.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPalette:
    ; 1. Border Color (from cur_pal + $0C)
    lda cur_pal + $0C
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta EXTCOL

    ; 2. Background Color 0 (from cur_pal + $0E)
    lda cur_pal + $0E
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta BGCOL0

    ; 3. Extra Background Colors 1 & 2 (for battle / world backdrops)
    lda cur_pal + 1
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta BGCOL1

    lda cur_pal + 2
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta BGCOL2

    ; 4. Sprite Multicolor registers ($D025, $D026)
    ; NES Sprite Palettes start at cur_pal + $10
    lda cur_pal + $11
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta SPMC0

    lda cur_pal + $12
    and #$3F
    tax
    lda lut_NES_to_C64, x
    sta SPMC1

    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_NES_to_C64
;;
;;  Translation lookup table mapping the 64 NES master colors ($00-$3F)
;;  to the closest matching Commodore 64 color (0-15).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_NES_to_C64:
    ; $00 - $0F: Dark / Mid tones
    .byte COLOR_GREY,       COLOR_BLUE,       COLOR_BLUE,       COLOR_PURPLE
    .byte COLOR_PURPLE,     COLOR_RED,        COLOR_BROWN,      COLOR_BROWN
    .byte COLOR_BROWN,      COLOR_GREEN,      COLOR_GREEN,      COLOR_GREEN
    .byte COLOR_CYAN,       COLOR_BLACK,      COLOR_BLACK,      COLOR_BLACK

    ; $10 - $1F: Mid / Vibrant tones
    .byte COLOR_LIGHTGREY,  COLOR_LIGHTBLUE,  COLOR_BLUE,       COLOR_PURPLE
    .byte COLOR_PURPLE,     COLOR_RED,        COLOR_ORANGE,     COLOR_ORANGE
    .byte COLOR_YELLOW,     COLOR_GREEN,      COLOR_LIGHTGREEN, COLOR_GREEN
    .byte COLOR_CYAN,       COLOR_BLACK,      COLOR_BLACK,      COLOR_BLACK

    ; $20 - $2F: Light tones
    .byte COLOR_WHITE,      COLOR_LIGHTBLUE,  COLOR_LIGHTBLUE,  COLOR_PURPLE
    .byte COLOR_LIGHTRED,   COLOR_LIGHTRED,   COLOR_LIGHTRED,   COLOR_ORANGE
    .byte COLOR_YELLOW,     COLOR_LIGHTGREEN, COLOR_LIGHTGREEN, COLOR_LIGHTGREEN
    .byte COLOR_CYAN,       COLOR_DARKGREY,   COLOR_BLACK,      COLOR_BLACK

    ; $30 - $3F: Pastel / Highlight tones
    .byte COLOR_WHITE,      COLOR_LIGHTBLUE,  COLOR_LIGHTBLUE,  COLOR_LIGHTGREY
    .byte COLOR_LIGHTRED,   COLOR_LIGHTRED,   COLOR_LIGHTRED,   COLOR_YELLOW
    .byte COLOR_YELLOW,     COLOR_LIGHTGREEN, COLOR_LIGHTGREEN, COLOR_CYAN
    .byte COLOR_CYAN,       COLOR_LIGHTGREY,  COLOR_BLACK,      COLOR_BLACK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UpdateJoy  [5692]
;;
;;    Reads and processes joypad/keyboard data
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateJoy:
    JSR ReadJoypadData
    LDX #$00
    JSR ProcessJoyButtons
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ReadJoypadData  [5708]
;;  
;;  (Name kept from original source for legacy purposes;
;;   the game uses the keyboard only)
;;  Scans C64 keyboard matrix for mapped controls:
;;    D-Pad:  W (Up), S (Down), A (Left), D (Right)
;;    Btn A:  Return or Space
;;    Btn B:  Backspace (Inst/Del) or Esc (Run/Stop)
;;    Select: Commodore (C=)
;;    Start:  F1
;;
;;  OUT: 'joy' = 8-bit NES button format ($80=A, $40=B, $20=Select, $10=Start, $08=U, $04=D, $02=L, $01=R)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadJoypadData:
    ; Configure CIA1: Port A outputs ($FF), Port B inputs ($00)
    LDA #$FF
    STA CIDDRA
    LDA #$00
    STA CIDDRB

    LDA #0
    STA joy

    ; --- Keyboard Col 0 ($FE) ---
    ; Row 0 (bit 0) = INST/DEL (Button B)
    ; Row 1 (bit 1) = RETURN (Button A)
    ; Row 4 (bit 4) = F1 (Start)
    LDA #$FE
    STA CIAPRA
    LDA CIAPRB
    TAX
    AND #$01        ; Row 0: Inst/Del
    BNE :+
    LDA joy
    ORA #BTN_B
    STA joy
:   TXA
    AND #$02        ; Row 1: Return (Button A)
    BNE :+
    LDA joy
    ORA #BTN_A
    STA joy
:   TXA
    AND #$10        ; Row 4: F1 (Start)
    BNE :+
    LDA joy
    ORA #BTN_START
    STA joy
:

    ; --- Keyboard Col 1 ($FD) ---
    ; Row 1 (bit 1) = W (Up)
    ; Row 2 (bit 2) = A (Left)
    ; Row 5 (bit 5) = S (Down)
    LDA #$FD
    STA CIAPRA
    LDA CIAPRB
    TAX
    AND #$02        ; Row 1: W
    BNE :+
    LDA joy
    ORA #UP
    STA joy
:   TXA
    AND #$04        ; Row 2: A
    BNE :+
    LDA joy
    ORA #LEFT
    STA joy
:   TXA
    AND #$20        ; Row 5: S
    BNE :+
    LDA joy
    ORA #DOWN
    STA joy
:

    ; --- Keyboard Col 2 ($FB) ---
    ; Row 2 (bit 2) = D (Right)
    LDA #$FB
    STA CIAPRA
    LDA CIAPRB
    AND #$04        ; Row 2: D
    BNE :+
    LDA joy
    ORA #RIGHT
    STA joy
:

    ; --- Keyboard Col 7 ($7F) ---
    ; Row 4 (bit 4) = Space (Button A)
    ; Row 5 (bit 5) = Commodore C= (Select)
    ; Row 7 (bit 7) = Run/Stop (Button B)
    LDA #$7F
    STA CIAPRA
    LDA CIAPRB
    TAX
    AND #$10        ; Row 4: Space (Button A)
    BNE :+
    LDA joy
    ORA #BTN_A
    STA joy
:   TXA
    AND #$20        ; Row 5: Commodore (C=) (Select)
    BNE :+
    LDA joy
    ORA #BTN_SELECT
    STA joy
:   TXA
    BMI :+          ; Row 7 (bit 7): Run/Stop (0 when pressed)
    LDA joy
    ORA #BTN_B
    STA joy
:

    ; Restore CIA1 Port A to all lines high
    LDA #$FF
    STA CIAPRA
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ProcessJoyButtons  [5747]
;;
;;  Examines 'joy' and 'joy_ignore' to determine button edge transitions.
;;  Increments joy_start, joy_select, joy_a, joy_b when pressed from released state.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessJoyButtons:
    LDA joy         ; get joypad data
    AND #$03        ; check Left and Right button states
    BEQ :+          ; if either are pressed...
      LDX #$03      ;   X=$03, otherwise, X=$00
:   STX tmp+1       ; back that value up

    LDA joy         ; get joy data again
    AND #$0C        ; this time, check Up and Down buttons
    BEQ :+
      TXA           ; if either are pressed, OR previous value with $0C
      ORA #$0C      ;  tmp+1 is now a mask indicating which directional buttons we want to keep
      STA tmp+1     ;  directional buttons not included in the mask will be discarded

:   LDA joy         ; get joy data -- do some EOR magic
    EOR joy_ignore  ;  invert it with all the buttons to ignore.
    AND tmp+1       ;  mask out the directional buttons to keep
    EOR joy_ignore  ;  and re-invert, restoring ALL buttons *except* the directional we want to keep
    STA joy_ignore  ;  write back to ignore
    EOR joy

    TAX             ; put transitioned buttons in X

    AND #BTN_START  ; see if Start button transitioned
    BEQ @select
    LDA joy
    AND #BTN_START
    BEQ :+
      INC joy_start
:   LDA joy_ignore
    EOR #BTN_START
    STA joy_ignore

@select:
    TXA
    AND #BTN_SELECT
    BEQ @btn_b
    LDA joy
    AND #BTN_SELECT
    BEQ :+
      INC joy_select
:   LDA joy_ignore
    EOR #BTN_SELECT
    STA joy_ignore

@btn_b:
    TXA
    AND #BTN_B
    BEQ @btn_a
    LDA joy
    AND #BTN_B
    BEQ :+
      INC joy_b
:   LDA joy_ignore
    EOR #BTN_B
    STA joy_ignore

@btn_a:
    TXA
    AND #BTN_A
    BEQ @Exit
    LDA joy
    AND #BTN_A
    BEQ :+
      INC joy_a
:   LDA joy_ignore
    EOR #BTN_A
    STA joy_ignore

@Exit:
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Complex String  [7370]
;;
;;  Draws a DTE-compressed string with control codes to Screen RAM.
;;
;;  IN:
;;    text_ptr = pointer to text
;;    cur_bank = bank containing text
;;    ret_bank = bank to return to
;;    dest_x   = starting column (0..39)
;;    dest_y   = starting row (0..24)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawComplexString:
    LDA cur_bank
    JSR SwapPRG_L
    JSR CoordToNTAddr

@StallAndDraw:

@Draw_NoStall:
    LDY #0
    LDA (text_ptr), Y             ; Fetch character from string
    BNE :+
    JMP @Exit                     ; $00 = null terminator -> exit
:

    INC text_ptr                  ; Advance string pointer
    BNE :+
    INC text_ptr+1
:
    CMP #$1A                      ; Control code if < $1A
    BCC @ControlCode

    CMP #$7A                      ; DTE character if < $7A
    BCS @NoDTE

    ; Dual Tile Encoding ($1A - $69)
    SEC
    SBC #$1A                      ; 0-based DTE index
    TAX
    LDA lut_DTE1, X               ; First character in DTE pair
    LDY #0
    STA (ppu_dest), Y
    INC ppu_dest
    BNE :+
    INC ppu_dest+1
:
    LDA lut_DTE2, X               ; Second character in DTE pair

@NoDTE:
    LDY #0
    STA (ppu_dest), Y
    INC ppu_dest
    BNE :+
    INC ppu_dest+1
:
    JMP @Draw_NoStall

@ControlCode:
    CMP #$01                      ; $01 = Double line break
    BEQ @DoubleLineBreak
    CMP #$02                      ; $02 = Item / class name
    BEQ @Code_02
    CMP #$05                      ; $05 = Single line break
    BEQ @SingleLineBreak
    JMP @SingleLineBreak

@DoubleLineBreak:
    INC dest_y
    INC dest_y
    JSR CoordToNTAddr
    JMP @Draw_NoStall

@SingleLineBreak:
    INC dest_y
    JSR CoordToNTAddr
    JMP @Draw_NoStall

@Code_02:
    LDY #0
    LDA (text_ptr), Y             ; Fetch item ID from string
    INC text_ptr
    BNE @DrawItem
    INC text_ptr+1

@DrawItem:
    JSR @Save                     ; Save current string & bank
    PHA                           ; Save Item ID on stack

    LDA #BANK_ITEMS
    STA cur_bank
    JSR SwapPRG_L

    PLA                           ; Restore Item ID in A
    ASL A
    TAX

    BCS @itemHigh
    LDA lut_ItemNamePtrTbl, X
    STA text_ptr
    LDA lut_ItemNamePtrTbl+1, X
    JMP @itemGo

@itemHigh:
    LDA lut_ItemNamePtrTbl+$100, X
    STA text_ptr
    LDA lut_ItemNamePtrTbl+$101, X

@itemGo:
    STA text_ptr+1
    JSR @Draw_NoStall
    JMP @Restore

@Save:
    LDY text_ptr
    STY tmp_hi
    LDY text_ptr+1
    STY tmp_hi+1
    LDY cur_bank
    STY tmp_hi+2
    RTS

@Restore:
    LDA tmp_hi
    STA text_ptr
    LDA tmp_hi+1
    STA text_ptr+1
    LDA tmp_hi+2
    STA cur_bank
    JSR SwapPRG_L
    JMP @Draw_NoStall

@Exit:
    LDA ret_bank
    JSR SwapPRG_L
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CoordToNTAddr  [6943]
;;
;;  Converts (dest_x, dest_y) into Screen RAM address ($4000 + Y*40 + X)
;;  and stores it in ppu_dest.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CoordToNTAddr:
    LDX dest_y
    CPX #25
    BCC :+
    LDX #24
:
    LDA lut_ScreenRowLo, X
    CLC
    ADC dest_x
    STA ppu_dest
    LDA lut_ScreenRowHi, X
    ADC #0
    STA ppu_dest+1
    RTS

lut_ScreenRowLo:
    .lobytes $4000 +  0*40, $4000 +  1*40, $4000 +  2*40, $4000 +  3*40
    .lobytes $4000 +  4*40, $4000 +  5*40, $4000 +  6*40, $4000 +  7*40
    .lobytes $4000 +  8*40, $4000 +  9*40, $4000 + 10*40, $4000 + 11*40
    .lobytes $4000 + 12*40, $4000 + 13*40, $4000 + 14*40, $4000 + 15*40
    .lobytes $4000 + 16*40, $4000 + 17*40, $4000 + 18*40, $4000 + 19*40
    .lobytes $4000 + 20*40, $4000 + 21*40, $4000 + 22*40, $4000 + 23*40
    .lobytes $4000 + 24*40

lut_ScreenRowHi:
    .hibytes $4000 +  0*40, $4000 +  1*40, $4000 +  2*40, $4000 +  3*40
    .hibytes $4000 +  4*40, $4000 +  5*40, $4000 +  6*40, $4000 +  7*40
    .hibytes $4000 +  8*40, $4000 +  9*40, $4000 + 10*40, $4000 + 11*40
    .hibytes $4000 + 12*40, $4000 + 13*40, $4000 + 14*40, $4000 + 15*40
    .hibytes $4000 + 16*40, $4000 + 17*40, $4000 + 18*40, $4000 + 19*40
    .hibytes $4000 + 20*40, $4000 + 21*40, $4000 + 22*40, $4000 + 23*40
    .hibytes $4000 + 24*40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawBox  [7787]
;;
;;    Draws a standard bordered window box.
;;
;;   IN:   box_x,y   = Top-left coordinates of the box
;;         box_wd,ht = Width and height of the box (including borders)
;;
;;   OUT:  dest_x,y  = X,Y coords of inner box body (where text begins)
;;
;;   TMP:  color_dest (tmp+8), tmp+10 (inner width), tmp+11 (inner height)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawBox:
    LDA box_x         ; copy given coords to output coords
    STA dest_x
    LDA box_y
    STA dest_y
    JSR CoordToNTAddr ; convert those coords to a Screen RAM address (in ppu_dest)

    ; Set up color_dest pointer to Color RAM ($D800 - $4000 = +$9800)
    LDA ppu_dest
    STA color_dest
    LDA ppu_dest+1
    CLC
    ADC #>($D800 - $4000)
    STA color_dest+1

    LDA box_wd        ; Get width of box
    SEC
    SBC #$02          ; subtract 2 to get width of "innards" (minus left and right borders)
    STA tmp+10        ; put this new width in temp ram
    LDA box_ht        ; Do same with box height
    SEC
    SBC #$02
    STA tmp+11        ; put new height in temp ram

    JSR DrawBoxRow_Top    ; Draw the top row of the box
@Loop:                    ; Loop to draw all inner rows
      JSR DrawBoxRow_Mid  ;   draw inner row
      DEC tmp+11          ;   decrement our adjusted height
      BNE @Loop           ;   loop until expires
    JSR DrawBoxRow_Bot    ; Draw bottom row

    LDA dest_x        ; get dest X coord
    CLC
    ADC #$01          ; and increment it by 1
    STA dest_x
    LDA dest_y        ; get dest Y coord
    CLC
    ADC #$02          ; and inc by 2
    STA dest_y        ; dest_x and dest_y are now our output coords (where text starts)

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw middle row of a box (used by DrawBox)  [7839]
;;
;;   IN:  tmp+10   = width of innards (box_wd - 2)
;;        ppu_dest = Screen RAM address of the start of this row
;;        color_dest = Color RAM address of the start of this row
;;
;;   OUT: ppu_dest, color_dest advanced by 40 to next row
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawBoxRow_Mid:
    JSR MenuCondStall  ; do the conditional stall

    LDY #0
    LDA #$FA           ; FA = L border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY

    LDX tmp+10         ; width of innards
@Loop:
    LDA #$FF           ; FF = inner box body tile (blank space, blue bg shines through)
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$FB           ; FB = R border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y

    ; Advance ppu_dest and color_dest to next row (+40)
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
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw bottom row of a box (used by DrawBox)  [7882]
;;
;;   IN:  tmp+10   = width of innards (box_wd - 2)
;;        ppu_dest = Screen RAM address of the start of this row
;;        color_dest = Color RAM address of the start of this row
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawBoxRow_Bot:
    JSR MenuCondStall   ; Do the conditional stall

    LDY #0
    LDA #$FC            ; FC = DL border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY

    LDX tmp+10          ; width of innards
@Loop:
    LDA #$FD            ; FD = bottom border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$FE            ; FE = DR border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw top row of a box (used by DrawBox)  [7918]
;;
;;   IN:  tmp+10   = width of innards (box_wd - 2)
;;        ppu_dest = Screen RAM address of the start of this row
;;        color_dest = Color RAM address of the start of this row
;;
;;   OUT: ppu_dest, color_dest advanced by 40 to next row
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawBoxRow_Top:
    JSR MenuCondStall   ; Do the conditional stall

    LDY #0
    LDA #$F7            ; F7 = UL border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY

    LDX tmp+10          ; width of innards
@Loop:
    LDA #$F8            ; F8 = U border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$F9            ; F9 = UR border tile
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y

    ; Advance ppu_dest and color_dest to next row (+40)
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
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Menu Conditional Stall  [7962]
;;
;;    Conditionally stalls (waits) a frame when menustall is nonzero.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuCondStall:
    LDA menustall          ; check stall flag
    BEQ @Exit              ; if zero, we're not to stall, so just exit
      JSR CallMusicPlay    ; keep music playing
      JSR WaitForVBlank_L  ; wait a frame
@Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Misc "Master" CHR/Palette loading routines  [9659]
;;
;;   These "Master" routines load all CHR (BG and Sprite) necessary for the given
;;  situation.  Some also load most/all the palettes.  Exceptions will be noted
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


LoadNewGameCHRPal:
    JSR LoadMenuBGCHRAndPalettes
    JMP LoadBatSprCHRPalettes

LoadMenuCHRPal:                ; does not load 'lit orb' palette, or the two middle palettes ($03C0-03CB)
    JSR LoadMenuBGCHRAndPalettes
    JMP LoadBatSprCHRPalettes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CHR Row Loading To Given Address 'A'  [9777]
;;
;;  Reads a given number of CHR rows from the given buffer, and writes to the specified
;;  address in CHR-RAM.  Destination address is stored in A upon entry
;;  It is assumed the proper PRG bank is swapped in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CHRLoadToA    [9777]
;;
;;  Sets the destination in C64 Character Memory ($4800)
;;  and loads character rows.
;;
;;  IN:   A     = high byte of PPU dest address ($00-$0F -> $4800-$4FFF)
;;        X     = number of rows to load (1 row = 256 bytes)
;;        (tmp) = source pointer to graphic data (in Cartridge ROM $8000-$BFFF)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CHRLoadToA:
    ; Destination in C64 Character Memory ($4800-$4FFF)
    ; PPU dest address high byte A divided by 2 gives C64 page offset from $4800
    ; e.g. A = $06 (PPU $0600) -> C64 $4B00 (tile $60, 32 tiles)
    pha
    lda #$00
    sta chr_dest
    pla
    lsr a
    clc
    adc #$48
    sta chr_dest+1

    ; No JMP or RTS -- seamlessly runs into CHRLoad

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CHR Row Loading    [9803]
;;
;;  Reads a given number of CHR rows from the given buffer, and writes them
;;  directly to C64 VIC-II Character Memory (at chr_dest, default $4800).
;;  It is assumed that the proper PRG bank is swapped in.
;;
;;  CHRLoad       zeros Y (source index) before looping
;;  CHRLoad_Cont  does not (retains Y's original value upon call)
;;
;;  IN:   X     = number of rows to load (1 row = 256 bytes)
;;        (tmp) = source pointer to graphic data in $8000-$BFFF
;;        Y     = additional source index (for CHRLoad_Cont only)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CHRLoad:
    ldy #$00

CHRLoad_Cont:
    lda (tmp), Y      ; read byte from Cartridge ROM
    sta (chr_dest), Y ; write directly to C64 Character RAM ($4800)!
    iny
    bne CHRLoad_Cont

    inc tmp+1         ; next source page
    inc chr_dest+1    ; next destination page
    dex
    bne CHRLoad_Cont
    rts	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LoadBattleBGCHRAndPalettes  [9985]
;;
;;   Loads all BG CHR (but not sprite CHR) for battle
;;  Also loads palettes for backdrop and border, but not for sprites or enemies
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadBattleBGCHRAndPalettes:
    LDA #BANK_OWINFO              ; Swap to BANK_OWINFO
    JSR SwapPRG_L

    LDX ow_tile                   ; Get last OW tile we stepped on
    LDA lut_BtlBackdrops, X       ; Use it as an index to get the backdrop ID
    PHA                           ; Save backdrop ID on stack

    JSR LoadBattleBGCHRPointers   ; Swap in desired bank, and set up pointers to battle backdrop (tmp)

    ; Destination Character RAM address = $4800 (VIC-II Bank 1 charset)
    LDA #$00
    STA chr_dest
    LDA #$48
    STA chr_dest+1

    ; Copy 18 C64 MultiColor tiles (18 * 8 = 144 bytes) to Character RAM ($4800)
    LDY #$00
@CopyLoop:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    CPY #144                      ; 18 tiles * 8 bytes = 144 bytes ($90)
    BNE @CopyLoop

    ; Now load the C64 backdrop palette
    PLA                           ; Restore backdrop ID
    ASL A
    ASL A                         ; Multiply ID by 4 (4 bytes per palette)
    TAX

    LDA #BANK_OWINFO              ; Swap back to Bank 0 to read palette
    JSR SwapPRG_L

    LDA lut_BackdropPal+0, X
    STA cur_pal+0
    STA BGCOL0                    ; $D021 = Background Color 0 (%00)
    LDA lut_BackdropPal+1, X
    STA cur_pal+1
    STA BGCOL1                    ; $D022 = Background Color 1 (%01)
    LDA lut_BackdropPal+2, X
    STA cur_pal+2
    STA BGCOL2                    ; $D023 = Background Color 2 (%10)

    ; Color 3 goes to Color RAM ($D800) and cur_pal+3
    LDA lut_BackdropPal+3, X
    STA cur_pal+3
    ORA #$08                      ; Bit 3 = 1 enables MultiColor mode for character cell
    STA tmp+2

    ; Set border color to Black
    LDA #COLOR_BLACK
    STA EXTCOL                    ; $D020

    ; Enable MultiColor Character mode on VIC-II:
    LDA SCROLX
    ORA #$10                      ; Bit 4 = 1: MultiColor text mode
    STA SCROLX

    ; Load monster graphics (enemy CHR)
    LDA btlformation              ; get battle formation number
    ASL A                         ; multiply it by 16
    ASL A
    ASL A
    ASL A
    STA tmp+4                     ; put low byte in tmp+4
    LDA btlformation
    AND #$7F                      ; drop the "Formation B" bit
    LSR A
    LSR A
    LSR A
    LSR A
    CLC
    ADC #>lut_BattleFormations    ; add to high byte of pointer
    STA tmp+5                     ; (tmp+4) points to formation entry in Bank $0B

    LDA #BANK_BTLDATA             ; swap to Bank $0B
    JSR SwapPRG_L

    LDY #0
    LDA (tmp+4), Y                ; Enemy CHR page ID from formation data
    AND #$0F
    STA enCHRpage

    JSR LoadBattleBGCHRPointers   ; swaps in BANK_BATTLECHR ($07 or $08), sets tmp to start of CHR
    INC tmp+1                     ; increment high byte: monsters start at offset $0120 ($8120)

    ; Copy 880 bytes (110 tiles * 8 bytes = $0370 bytes) of monster graphics to $4890-$4BFF
    LDA #$20                      ; source starts at (tmp) + $20 -> $8120, $8920, etc.
    STA tmp
    LDA #$90                      ; dest starts at $4890 (tile $12)
    STA chr_dest
    LDA #$48
    STA chr_dest+1

    LDX #$03                      ; 3 full pages (768 bytes)
    LDY #$00
@MonsterPageLoop:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    BNE @MonsterPageLoop
    INC tmp+1
    INC chr_dest+1
    DEX
    BNE @MonsterPageLoop

    ; Remaining 112 bytes ($70) -> completes 880 bytes, reaching $4C00
@MonsterRemLoop:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    CPY #$70
    BNE @MonsterRemLoop

    ; Load font & menu window borders (chars $80-$FF, $4C00-$4FFF)
    JSR LoadMenuCHR

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Load Battle BG CHR pointers   [10055]
;;
;;
;;   Takes given Battle BG (or Enemy group image) ID
;;    Swaps in the bank containing that CHR
;;    and points (tmp) to the CHR
;;
;;   Each Battle BG CHR set is $0800 bytes
;;
;;   X, Y are left unchanged
;;
;;   IN:   A       = Battle BG ID whose pointers to load
;;
;;   OUT:  (tmp)   = Pointer to start of CHR
;;         *       = Desired bank swapped in
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadBattleBGCHRPointers:
    AND #$0F     ; mask with $0F (there are only 16 battle BGs)
    CMP #$08     ; if the BG is >= 8, then it's on the second bank of Battle BG CHR
    BCS @SecondBank

       ; otherwise it's on the first bank
       ASL A          ; multiply index by 8
       ASL A
       ASL A
       ORA #$80       ; and OR with $80 to get the high byte of the pointer
       STA tmp+1
       LDA #BANK_BATTLECHR   ; and indicate first bank of Battle BG CHR
       JMP @FinishUp

@SecondBank:
       AND #$07       ; subtract 8 by masking
       ASL A
       ASL A
       ASL A          ; multiply by 8
       ORA #$80       ; and OR to get high byte
       STA tmp+1
       LDA #BANK_BATTLECHR+1 ; and indiate second bank of Battle BG CHR

@FinishUp:
    JSR SwapPRG_L     ; Swap in indicated bank
    LDA #$00          ;  and set low byte of pointer to 0
    STA tmp
    RTS               ;  and exit!



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load Menu BG CHR and Palettes  [10099]
;;
;;   Loads CHR and Palettes for menus
;;
;;   Does not load palettes or CHR for sprites
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadMenuBGCHRAndPalettes:
    JSR LoadBattleBGCHRAndPalettes   ; Load Battle BG, monster CHR, font, etc.
    LDA #BANK_ORBCHR                 ; Swap to Bank D (BANK_ORBCHR)
    JSR SwapPRG_L
    LDX #$01                         ; 1 page (256 bytes = 32 tiles * 8 bytes)
    LDA #<lut_OrbCHR                 ; from source address lut_OrbCHR ($B600)
    STA tmp
    LDA #>lut_OrbCHR
    STA tmp+1
    LDA #$06                         ; dest address $0600 (maps to C64 $4B00)
    JSR CHRLoadToA                   ; loads 32 orb tiles into $4B00-$4BFF (tiles $60-$7F)
    JMP LoadBorderPalette_Blue       ; Set up menu border and background colors

LoadBorderPalette_Blue:
    lda #$01                   ; NES Blue ($01)
    bne :+                     ; Always branch

LoadBorderPalette_Black:
    lda #$0F                   ; NES Black ($0F)

:   sta cur_pal + $0E          ; Blue/Black to window background
    lda #$0F                   ; NES Black ($0F)
    sta cur_pal + $0C          ; Black to border color 0
    lda #$00                   ; NES Grey ($00)
    sta cur_pal + $0D          ; Grey to color 1
    lda #$30                   ; NES White ($30)
    sta cur_pal + $0F          ; White to color 3
    jmp DrawPalette            ; Flush Virtual Palette to VIC-II hardware

LoadBatSprCHRPalettes:
    LDA #BANK_MENUCHR          ; Bank 9 (contains lut_FingerSprite)
    JSR SwapPRG_L

    ; Copy 128 bytes of Finger Sprite (Base + Overlay) from lut_FingerSprite to $5800
    LDA #<lut_FingerSprite
    STA tmp
    LDA #>lut_FingerSprite
    STA tmp+1

    LDA #<$5800
    STA chr_dest
    LDA #>$5800
    STA chr_dest+1

    LDY #$00
@CopySprite:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    CPY #128
    BNE @CopySprite

    ; Copy 1536 bytes (6 pages = 24 blocks) of Hero Sprites from lut_HeroSprites to $5880
    LDA #<lut_HeroSprites
    STA tmp
    LDA #>lut_HeroSprites
    STA tmp+1

    LDA #<$5880
    STA chr_dest
    LDA #>$5880
    STA chr_dest+1

    LDX #6                     ; 6 pages = 1536 bytes ($0600)
    LDY #0
@CopyHeroes:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    BNE @CopyHeroes
    INC tmp+1
    INC chr_dest+1
    DEX
    BNE @CopyHeroes

    ; Load 16-byte battle/menu sprite palette into cur_pal + $10..$1F
    LDX #$0F
:   LDA lut_BattleSpritePalettes, X
    STA cur_pal + $10, X
    DEX
    BPL :-

    ; Set global Sprite Multicolor registers according to user specs:
    ; Background is 00 (transparent / black $D021)
    ; Multicolor 1 = 11 (Dark Grey, $0B)
    ; Multicolor 2 = 15 (Light Grey, $0F)
    LDA #COLOR_DARKGREY        ; 11 ($0B)
    STA SPMC0                  ; $D025 = Sprite Multicolor 0
    LDA #COLOR_LIGHTGREY       ; 15 ($0F)
    STA SPMC1                  ; $D026 = Sprite Multicolor 1

    ; Set Bank back to caller's bank (BANK_INTRO / BANK_TITLE = $0E)
    LDA #BANK_INTRO
    JSR SwapPRG_L
    RTS

lut_BattleSpritePalettes:
    .byte $0F,$28,$18,$21,  $0F,$16,$30,$36,   $0F,$30,$22,$12,  $0F,$30,$10,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Menu CHR Loading  [9856]
;;
;;   Load CHR for menus (text, window borders, icons)
;;   Copies 1024 bytes (128 characters) from Bank 09 ($8800)
;;   to C64 VIC-II Character Memory at $4C00 (chars $80-$FF)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadMenuCHR:
    LDA #BANK_MENUCHR             ; Bank 9
    JSR SwapPRG_L

    ; Copy 1024 bytes (128 tiles) to $4C00-$4FFF (characters $80-$FF)
    ; Characters $00-$7F ($4800-$4BFF) remain preserved for graphic tiles!
    ; Tile 127 in lut_MenuCHR lands at character $FF as the full solid block.
    LDA #<lut_MenuCHR
    STA tmp
    LDA #>lut_MenuCHR
    STA tmp+1

    LDA #$00
    STA chr_dest
    LDA #$4C
    STA chr_dest+1

    LDX #$04
    LDY #$00
@Loop:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    BNE @Loop
    INC tmp+1
    INC chr_dest+1
    DEX
    BNE @Loop

    ; 1. Ensure Character $FF (at $4FF8-$4FFF) is transparent (blank space, all zeros)
    LDY #$07
    LDA #$00
:   STA $4FF8, Y
    DEY
    BPL :-

    ; Note: Character $00 is loaded from the battle backdrop CHR graphics ($4800-$4807)

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DTE table  [11294]
;;
;;  first table is the 2nd character in a DTE pair
;;  second table is the 1st character in a DTE pair
;;
;;  don't ask me why it's reversed
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_DTE2:
  .BYTE $FF,$B7,$AB,$A8,  $FF,$B1,$A4,$FF,  $B1,$A8,$B6,$B5,  $B8,$FF,$B2,$FF
  .BYTE $AA,$A4,$B6,$AC,  $FF,$B5,$B6,$A5,  $A8,$BA,$A8,$B5,  $B2,$B7,$A6,$B7
  .BYTE $B1,$A7,$B1,$AC,  $A8,$B6,$A7,$A4,  $B0,$A9,$FF,$A8,  $BA,$FF,$A8,$B0
  .BYTE $92,$FF,$A9,$B2,  $AF,$B3,$BC,$A4,  $8A,$A8,$FF,$B5,  $B2,$AC,$FF,$AB
  .BYTE $A8,$B7,$AC,$A4,  $A6,$AF,$A8,$AF,  $A8,$B6,$FF,$AF,  $A8,$A7,$AC,$C3

lut_DTE1:
  .BYTE $A8,$FF,$B7,$AB,  $B6,$AC,$FF,$B7,  $A4,$B5,$FF,$A8,  $B2,$A7,$B7,$B1
  .BYTE $B1,$A8,$A8,$FF,  $B2,$A4,$AC,$FF,  $B9,$FF,$B0,$B2,  $FF,$B6,$FF,$A4
  .BYTE $A8,$B1,$B2,$AB,  $B6,$A4,$A8,$AB,  $FF,$FF,$B5,$AF,  $B2,$AA,$A6,$B2
  .BYTE $90,$BC,$B2,$B5,  $AF,$FF,$FF,$A6,  $96,$B7,$A9,$B8,  $BC,$B7,$AF,$FF
  .BYTE $B1,$AC,$B5,$BA,  $A4,$A4,$BA,$AC,  $A5,$B5,$B8,$FF,  $AA,$FF,$AF,$C3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  SwapPRG  [13871]
;;
;;   Swaps so the desired bank of PRG ROM is visible in the $8000-$BFFF range
;;
;;  IN:   A = desired bank to swap to (00-0F)
;;
;;  OUT:  A = 0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SwapPRG_L:       JMP SwapPRG

SwapPRG:
    sta cur_bank
    pha
    txa
    pha
    ldx cur_bank
    lda lut_EasyFlashBanks, x
    sta EASYFLASH_BANK
    pla
    tax
    pla
    rts

lut_EasyFlashBanks:
    .byte 16    ; NES Bank 0  -> EasyFlash Bank 16
    .byte 1     ; NES Bank 1  -> EasyFlash Bank 1
    .byte 2     ; NES Bank 2  -> EasyFlash Bank 2
    .byte 3     ; NES Bank 3  -> EasyFlash Bank 3
    .byte 4     ; NES Bank 4  -> EasyFlash Bank 4
    .byte 5     ; NES Bank 5  -> EasyFlash Bank 5
    .byte 6     ; NES Bank 6  -> EasyFlash Bank 6
    .byte 7     ; NES Bank 7  -> EasyFlash Bank 7
    .byte 8     ; NES Bank 8  -> EasyFlash Bank 8
    .byte 9     ; NES Bank 9  -> EasyFlash Bank 9
    .byte 10    ; NES Bank 10 -> EasyFlash Bank 10
    .byte 11    ; NES Bank 11 -> EasyFlash Bank 11
    .byte 12    ; NES Bank 12 -> EasyFlash Bank 12
    .byte 13    ; NES Bank 13 -> EasyFlash Bank 13
    .byte 14    ; NES Bank 14 -> EasyFlash Bank 14
    .byte 15    ; NES Bank 15 -> EasyFlash Bank 15


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Entry / Reset  [13892]
;;
;;   Entry point for the program.  Does C64 and mapper prepwork, and gets
;;   everything started
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnReset:
    sei            ; Set Interrupt flag (prevent IRQs during setup)
    cld            ; clear Decimal flag (just a formality, doesn't really do anything)

    ldx #$FF       ; reset stack pointer
    txs

    jsr ClearBGPalette ; clear the BG palette (set border and BG colors to black)

    cli            ; Enable interrupts now that all vectors and hardware are ready
    jmp GameStart_L    ; jump to the start of the game!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   NMI Vector [13966]
;;
;;     On C64, NMI is triggered by the RESTORE key or CIA2.
;;    We point $FFFA here to safely RTI without crashing.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnNMI:
    rti


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Wait for VBlank   [13985]
;;
;;    This does an infinite loop in wait for an NMI/IRQ to be triggered
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WaitForVBlank_L: JMP WaitForVBlank

WaitForVBlank:
    lda vblank_count
@Wait:
    cmp vblank_count
    beq @Wait
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   OnIRQ - VIC-II Raster Interrupt Handler   [14003]
;;
;;   On C64, this takes the place of the NES PPU VBlank NMI.
;;   Pointed to by $FFFE in RAM.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OnIRQ:
    ; Check if Party Generation 2-zone multiplexer is active
    lda spr_multiplex_mode
    beq @NormalIRQ
    jmp PartyGen_IRQ

@NormalIRQ:
    ; Increment frame counter
    inc vblank_count

    ; Push sprites to VIC-II hardware during VBlank
    jsr UpdateSprites

    ; Acknowledge VIC-II Raster IRQ
    lda #$01
    sta VICIRQ

    ; When called via KERNAL at $0314, registers were already pushed by KERNAL ($FF48).
    ; We jump to $FEBC which pulls Y, X, A and performs RTI cleanly!
    jmp $FEBC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  PartyGen_IRQ - 2-Zone Raster Multiplexer for Party Generation
;;
;;  Zone 1 (Scanline 250 / VBlank -> 135):
;;    Physical Sprites 0-3: Hero 0 (Top-Left)
;;    Physical Sprites 4-7: Hero 1 (Top-Right)
;;  Zone 2 (Scanline 145 -> 240):
;;    Physical Sprites 0-3: Hero 2 (Bottom-Left)
;;    Physical Sprites 4-7: Hero 3 (Bottom-Right)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BLOCK_HERO_BASE = 98           ; $62 ($5880 in Bank 1 RAM)

COLOR_PEACH = COLOR_LIGHTRED  ; $0A

PartyGen_IRQ:
    lda #$01
    sta VICIRQ                 ; Acknowledge VIC-II Raster IRQ

    lda spr_irq_zone
    beq @Zone0
    cmp #1
    beq @Zone1
    cmp #2
    beq @Zone2
    jmp @Zone3

@Zone0:
    inc vblank_count           ; Increment frame counter once per frame on VBlank

    jsr SetupHero0_Upper
    jsr SetupHero1_Upper

    ; Common VIC-II configuration for sprites
    lda #$00
    sta MSIGX                  ; MSB 0 for all
    sta XEXP                   ; No X expansion
    sta YEXP                   ; No Y expansion
    sta SPBGPR                 ; In front of BG
    lda #$FF
    sta SPENA                  ; Enable all 8 sprites

    lda char_index
    cmp #$20
    bcs @TopNoCursor

    ; Cursor is in Top Half (Hero 0 or Hero 1)
    jsr SetupCursor

    ; Arm next split at Scanline 100 for Feet
    lda #100
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #1
    sta spr_irq_zone
    jmp $FEBC

@TopNoCursor:
    jsr SetupHero01_Feet

    ; Arm next split at Scanline 145 for Bottom Half
    lda #145
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #2
    sta spr_irq_zone
    jmp $FEBC

@Zone1:
    ; Scanline 100: Cursor top finished, set up Feet for Hero 0 & 1
    jsr SetupHero01_Feet

    ; Arm next split at Scanline 145 for Bottom Half
    lda #145
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #2
    sta spr_irq_zone
    jmp $FEBC

@Zone2:
    ; Scanline 145: Bottom Half (Hero 2 & 3)
    jsr SetupHero2_Upper
    jsr SetupHero3_Upper

    lda char_index
    cmp #$20
    bcc @BottomNoCursor

    ; Cursor is in Bottom Half (Hero 2 or Hero 3)
    jsr SetupCursor

    ; Arm next split at Scanline 204 for Feet
    lda #204
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #3
    sta spr_irq_zone
    jmp $FEBC

@BottomNoCursor:
    jsr SetupHero23_Feet

    ; Arm next split at Scanline 250 for VBlank
    lda #250
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #0
    sta spr_irq_zone
    jmp $FEBC

@Zone3:
    ; Scanline 204: Cursor bottom finished, set up Feet for Hero 2 & 3
    jsr SetupHero23_Feet

    ; Arm next split at Scanline 250 for VBlank
    lda #250
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #0
    sta spr_irq_zone
    jmp $FEBC

SetupCursor:
    ldx char_index
    lda ptygen_curs_x, x
    sta SP1X
    sta SP5X
    lda ptygen_curs_y, x
    sta SP1Y
    sta SP5Y
    lda #BLOCK_FINGER_OVERLAY   ; Block 97 (Hi-Res Overlay, White)
    sta $43F9                  ; Sprite 1 pointer
    lda #COLOR_WHITE
    sta SP1COL
    lda #BLOCK_FINGER_BASE      ; Block 96 (Multicolor Base, White + Greys)
    sta $43FD                  ; Sprite 5 pointer
    lda #COLOR_WHITE
    sta SP5COL
    lda #%00100000             ; Sprite 5 Multicolor, Sprite 1 Hi-Res
    sta SPMC
    rts

SetupHero0_Upper:
    ldx ptygen+0
    txa
    asl a
    asl a                      ; A = class * 4
    tay

    ; Layer 0: Body (Y = 90, X = 120)
    lda #120
    sta SP0X
    lda #90
    sta SP0Y
    tya
    clc
    adc #BLOCK_HERO_BASE
    sta $43F8
    lda lut_ClassColors, y
    sta SP0COL

    ; Layer 2: Skin/Accents (Y = 90 + dY, X = 120)
    lda #120
    sta SP2X
    lda #90
    clc
    adc lut_Class_dY + 2, y
    sta SP2Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 2)
    sta $43FA
    lda lut_ClassColors + 2, y
    sta SP2COL

    ; Layer 3: Hilight/Secondary (Y = 90, X = 120)
    lda #120
    sta SP3X
    lda #90
    sta SP3Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 3)
    sta $43FB
    lda lut_ClassColors + 3, y
    sta SP3COL
    rts

SetupHero1_Upper:
    ldx ptygen+$10
    txa
    asl a
    asl a
    tay

    ; Layer 0: Body (Y = 90, X = 232)
    lda #232
    sta SP4X
    lda #90
    sta SP4Y
    tya
    clc
    adc #BLOCK_HERO_BASE
    sta $43FC
    lda lut_ClassColors, y
    sta SP4COL

    ; Layer 2: Skin/Accents (Y = 90 + dY, X = 232)
    lda #232
    sta SP6X
    lda #90
    clc
    adc lut_Class_dY + 2, y
    sta SP6Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 2)
    sta $43FE
    lda lut_ClassColors + 2, y
    sta SP6COL

    ; Layer 3: Hilight/Secondary (Y = 90, X = 232)
    lda #232
    sta SP7X
    lda #90
    sta SP7Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 3)
    sta $43FF
    lda lut_ClassColors + 3, y
    sta SP7COL
    rts

SetupHero01_Feet:
    ; Sprite 1: Hero 0 Feet (Y = 111, X = 120)
    lda #120
    sta SP1X
    lda #111
    sta SP1Y
    ldx ptygen+0
    txa
    asl a
    asl a
    tay
    clc
    adc #(BLOCK_HERO_BASE + 1)
    sta $43F9
    lda lut_ClassColors + 1, y
    sta SP1COL

    ; Sprite 5: Hero 1 Feet (Y = 111, X = 232)
    lda #232
    sta SP5X
    lda #111
    sta SP5Y
    ldx ptygen+$10
    txa
    asl a
    asl a
    tay
    clc
    adc #(BLOCK_HERO_BASE + 1)
    sta $43FD
    lda lut_ClassColors + 1, y
    sta SP5COL

    lda #$00                   ; All Hi-Res
    sta SPMC
    rts

SetupHero2_Upper:
    ldx ptygen+$20
    txa
    asl a
    asl a
    tay

    ; Layer 0: Body (Y = 194, X = 120)
    lda #120
    sta SP0X
    lda #194
    sta SP0Y
    tya
    clc
    adc #BLOCK_HERO_BASE
    sta $43F8
    lda lut_ClassColors, y
    sta SP0COL

    ; Layer 2: Skin/Accents (Y = 194 + dY, X = 120)
    lda #120
    sta SP2X
    lda #194
    clc
    adc lut_Class_dY + 2, y
    sta SP2Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 2)
    sta $43FA
    lda lut_ClassColors + 2, y
    sta SP2COL

    ; Layer 3: Hilight/Secondary (Y = 194, X = 120)
    lda #120
    sta SP3X
    lda #194
    sta SP3Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 3)
    sta $43FB
    lda lut_ClassColors + 3, y
    sta SP3COL
    rts

SetupHero3_Upper:
    ldx ptygen+$30
    txa
    asl a
    asl a
    tay

    ; Layer 0: Body (Y = 194, X = 232)
    lda #232
    sta SP4X
    lda #194
    sta SP4Y
    tya
    clc
    adc #BLOCK_HERO_BASE
    sta $43FC
    lda lut_ClassColors, y
    sta SP4COL

    ; Layer 2: Skin/Accents (Y = 194 + dY, X = 232)
    lda #232
    sta SP6X
    lda #194
    clc
    adc lut_Class_dY + 2, y
    sta SP6Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 2)
    sta $43FE
    lda lut_ClassColors + 2, y
    sta SP6COL

    ; Layer 3: Hilight/Secondary (Y = 194, X = 232)
    lda #232
    sta SP7X
    lda #194
    sta SP7Y
    tya
    clc
    adc #(BLOCK_HERO_BASE + 3)
    sta $43FF
    lda lut_ClassColors + 3, y
    sta SP7COL
    rts

SetupHero23_Feet:
    ; Sprite 1: Hero 2 Feet (Y = 215, X = 120)
    lda #120
    sta SP1X
    lda #215
    sta SP1Y
    ldx ptygen+$20
    txa
    asl a
    asl a
    tay
    clc
    adc #(BLOCK_HERO_BASE + 1)
    sta $43F9
    lda lut_ClassColors + 1, y
    sta SP1COL

    ; Sprite 5: Hero 3 Feet (Y = 215, X = 232)
    lda #232
    sta SP5X
    lda #215
    sta SP5Y
    ldx ptygen+$30
    txa
    asl a
    asl a
    tay
    clc
    adc #(BLOCK_HERO_BASE + 1)
    sta $43FD
    lda lut_ClassColors + 1, y
    sta SP5COL

    lda #$00                   ; All Hi-Res
    sta SPMC
    rts

lut_ClassColors:
    ; Class 0 (Fighter): Red, Red/Brown, Peach, Light Grey
    .byte COLOR_RED, COLOR_RED, COLOR_PEACH, COLOR_LIGHTGREY
    ; Class 1 (Thief): Brown, Brown, Peach, Cyan
    .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_PEACH, COLOR_CYAN
    ; Class 2 (Black Belt): Cyan, Cyan, Brown, Peach
    .byte COLOR_CYAN, COLOR_CYAN, COLOR_ORANGE, COLOR_PEACH
    ; Class 3 (Red Mage): Red, Red, Peach, White
    .byte COLOR_RED, COLOR_RED, COLOR_PEACH, COLOR_WHITE
    ; Class 4 (White Mage): White, White, Red, Peach
    .byte COLOR_WHITE, COLOR_WHITE, COLOR_RED, COLOR_PEACH
    ; Class 5 (Black Mage): Cyan, Cyan, Yellow, Brown
    .byte COLOR_CYAN, COLOR_CYAN, COLOR_YELLOW, COLOR_ORANGE

lut_Class_dY:
    .byte 0, 21, 0, 0   ; Class 0 (Fighter)
    .byte 0, 21, 0, 0   ; Class 1 (Thief)
    .byte 0, 21, 0, 0   ; Class 2 (Black Belt)
    .byte 0, 21, 0, 0   ; Class 3 (Red Mage)
    .byte 0, 21, 3, 0   ; Class 4 (White Mage) - dY=+3 on Layer 2!
    .byte 0, 21, 0, 0   ; Class 5 (Black Mage)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Clear BG Palette   [14015]
;;
;;     This routine resets the BG palette to all black (0)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearBGPalette:
    lda #COLOR_BLACK
    sta EXTCOL     ; Border color = Black
    sta BGCOL0     ; Background color 0 = Black
    sta BGCOL1     ; Extra background color 1 = Black
    sta BGCOL2     ; Extra background color 2 = Black
    rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LUTs for Sprite Bitmasks
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_BitMask:
    .byte $01, $02, $04, $08, $10, $20, $40, $80

lut_BitMaskInv:
    .byte $FE, $FD, $FB, $F7, $EF, $DF, $BF, $7F

lut_PairMask:
    .byte $03, $06, $0C, $18, $30, $60, $C0, $00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Cursor  [10516]
;;
;;    Draws the cursor at given X,Y coords (spr_x,spr_y)
;;    Allocates 2 paired sprite slots:
;;      Slot X   : Multicolor Base (hand shape)
;;      Slot X+1 : Hi-Res Overlay (white cuff & highlights)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawCursor:
    ldx sprindex
    cpx #$07                ; Ensure at least 2 slots (X and X+1 <= 7)
    bcs @Exit

    ; 1. Set coordinates for both Base and Overlay
    lda spr_x
    sta shadow_spr_x, x
    sta shadow_spr_x+1, x

    lda spr_y
    sta shadow_spr_y, x
    sta shadow_spr_y+1, x

    ; Clear MSB for both slots (assuming X < 256 for menu cursor)
    lda lut_BitMaskInv, x
    and shadow_spr_msb
    sta shadow_spr_msb
    inx
    lda lut_BitMaskInv, x
    and shadow_spr_msb
    sta shadow_spr_msb
    dex

    ; 2. Set Sprite Pointers (Slot X is in front = Overlay, Slot X+1 is behind = Base)
    lda #BLOCK_FINGER_OVERLAY    ; Block 97 ($61 -> $5840)
    sta shadow_spr_ptr, x
    lda #BLOCK_FINGER_BASE       ; Block 96 ($60 -> $5800)
    sta shadow_spr_ptr+1, x

    ; 3. Set Colors (Custom color White for both as specified)
    lda #COLOR_WHITE             ; Custom color 1 for Overlay (in front)
    sta shadow_spr_col, x
    lda #COLOR_WHITE             ; Custom color 1 for Base (behind)
    sta shadow_spr_col+1, x

    ; 4. Set Modes: Slot X = Hi-Res Overlay, Slot X+1 = Multicolor Base
    lda lut_BitMaskInv, x
    and shadow_spr_mcm
    sta shadow_spr_mcm           ; Disable multicolor (Hi-Res) on Overlay (Slot X)

    inx
    lda lut_BitMask, x
    ora shadow_spr_mcm
    sta shadow_spr_mcm           ; Enable multicolor on Base (Slot X+1)

    ; 5. Enable both slots
    dex
    lda lut_PairMask, x
    ora shadow_spr_en
    sta shadow_spr_en

    ; 6. Advance sprindex by 2 for next entity
    inx
    inx
    stx sprindex

@Exit:
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Update Sprites  (VIC-II Flush)
;;
;;    Flushes the shadow sprite registers to the VIC-II hardware
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateSprites:
    ; 1. Copy coordinates to $D000-$D00F
    ldx #$00
    ldy #$00
@CoordLoop:
    lda shadow_spr_x, x
    sta SP0X, y
    lda shadow_spr_y, x
    sta SP0Y, y
    iny
    iny
    inx
    cpx #$08
    bne @CoordLoop

    ; 2. MSB of X coordinates ($D010)
    lda shadow_spr_msb
    sta MSIGX

    ; 3. Sprite Pointers (Screen at $4000 -> pointers at $43F8-$43FF)
    ; And Individual Colors ($D027-$D02E)
    ldx #$07
@AttrLoop:
    lda shadow_spr_ptr, x
    sta $43F8, x
    lda shadow_spr_col, x
    sta SP0COL, x
    dex
    bpl @AttrLoop

    ; 4. Modes & Enables
    lda shadow_spr_mcm
    sta SPMC                     ; $D01C

    lda shadow_spr_en
    sta SPENA                    ; $D015

    ; 5. Priorities and Expansion (Ensure normal size in front of BG)
    lda #$00
    sta SPBGPR                   ; $D01B (0 = in front of BG)
    sta XEXP                     ; $D01D (no X stretch)
    sta YEXP                     ; $D017 (no Y stretch)

    rts
