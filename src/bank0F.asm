.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "KERNEL"

.export GameStart_L

.export DrawComplexString_L, DrawBox_L, CallMusicPlay_L, UpdateJoy_L, DrawPalette_L
.export DrawComplexString, DrawBox, CallMusicPlay, UpdateJoy, DrawPalette, LoadMenuCHRPal, ClearOAM
.export LoadMenuCHR, LoadMenuBGCHRAndPalettes, LoadBattleBGCHRAndPalettes, LoadBatSprCHRPalettes
.export GameStart, OnReset, OnNMI, OnIRQ
.export WaitForVBlank_L, WaitForVBlank
.export SwapPRG_L, SwapPRG
.export CoordToNTAddr, lut_ScreenRowLo, lut_ScreenRowHi
.export DrawCursor, UpdateSprites

.import EnterIntroStory, EnterTitleScreen
.import lut_MenuCHR
.import lut_FingerSprite


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

    ; For testing bank switching, unconditionally jump to intro story
    LDA startintrocheck             ; check a random spot in memory.  This value is not inialized as powerup,
    CMP #$4D                        ;    and will be semi-random.
    BEQ :+                          ; if it is any value other than $4D, we can assume we just powered on...
      LDA #$4D                      ; ... so initilize it to $4D.  From this point forward, it will always be initlialized.
      STA startintrocheck           ; This is how the game makes the distinction between cold boot and warm reset
      
      LDA #BANK_INTRO               ; If we just came in from a cold boot...
      JSR SwapPRG_L                 ; swap in the intro story bank
      JSR EnterIntroStory           ; And do the intro story!
      
      
  : LDA #BANK_TITLE                 ; Then swap in the title bank
    JSR SwapPRG_L                   ; to do the title screen
    JSR EnterTitleScreen


	  
halt_loop:
    ; Core game loop logic will live here
    jmp halt_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Clear OAM   [$C43C :: 0x3C44C]  [976]
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
CallMusicPlay:      rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawPalette  [5863]
;;
DrawPalette:        rts

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
;;    Btn A:  Space
;;    Btn B:  Backspace (Inst/Del) or Esc (Run/Stop)
;;    Select: Left Shift or Right Shift
;;    Start:  Return or Commodore (C=)
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
    ; Row 1 (bit 1) = RETURN (Start)
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
    AND #$02        ; Row 1: Return
    BNE :+
    LDA joy
    ORA #BTN_START
    STA joy
:

    ; --- Keyboard Col 1 ($FD) ---
    ; Row 1 (bit 1) = W (Up)
    ; Row 2 (bit 2) = A (Left)
    ; Row 5 (bit 5) = S (Down)
    ; Row 7 (bit 7) = Left Shift (Select)
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
:   TXA
    BMI :+          ; Row 7 (bit 7): Left Shift (0 when pressed)
    LDA joy
    ORA #BTN_SELECT
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

    ; --- Keyboard Col 6 ($BF) ---
    ; Row 4 (bit 4) = Right Shift (Select)
    LDA #$BF
    STA CIAPRA
    LDA CIAPRB
    AND #$10        ; Row 4: Right Shift
    BNE :+
    LDA joy
    ORA #BTN_SELECT
    STA joy
:

    ; --- Keyboard Col 7 ($7F) ---
    ; Row 4 (bit 4) = Space (Button A)
    ; Row 5 (bit 5) = Commodore C= (Start)
    ; Row 7 (bit 7) = Run/Stop (Button B)
    LDA #$7F
    STA CIAPRA
    LDA CIAPRB
    TAX
    AND #$10        ; Row 4: Space
    BNE :+
    LDA joy
    ORA #BTN_A
    STA joy
:   TXA
    AND #$20        ; Row 5: Commodore (C=)
    BNE :+
    LDA joy
    ORA #BTN_START
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
    BEQ @Exit                     ; $00 = null terminator -> exit

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
;;  DrawBox  [$E06E :: 0x3E07E]  [7787]
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
;;  Draw middle row of a box (used by DrawBox)   [$E0A5 :: 0x3E0B5]  [7839]
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
;;  Draw bottom row of a box (used by DrawBox)   [$E0D7 :: 0x3E0E7]  [7882]
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
;;  Draw top row of a box (used by DrawBox)   [$E0FC :: 0x3E10C]  [7918]
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
;;  Menu Conditional Stall   [$E12E :: 0x3E13E]  [7962]
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
    ; Low byte of dest is always $00
    lda #$00
    sta chr_dest
    ; PPU $0000 maps to C64 $4800, $0100 -> $4900, etc.
    ; Destination high byte = $48 + (A & $07)
    txa
    pha             ; preserve X
    lda #$48
    sta chr_dest+1
    pla
    tax             ; restore X

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
    STA BGCOL0                    ; $D021 = Background Color 0 (%00)
    LDA lut_BackdropPal+1, X
    STA BGCOL1                    ; $D022 = Background Color 1 (%01)
    LDA lut_BackdropPal+2, X
    STA BGCOL2                    ; $D023 = Background Color 2 (%10)

    ; Color 3 goes to Color RAM ($D800)
    LDA lut_BackdropPal+3, X
    ORA #$08                      ; Bit 3 = 1 enables MultiColor mode for character cell
    STA tmp+2

    ; Set border color to Black
    LDA #COLOR_BLACK
    STA EXTCOL                    ; $D020

    ; Enable MultiColor Character mode on VIC-II:
    LDA SCROLX
    ORA #$10                      ; Bit 4 = 1: MultiColor text mode
    STA SCROLX

    ; Load font & menu window borders (chars $80-$FF)
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
    JSR LoadBattleBGCHRAndPalettes   ; Load Battle BG and palettes.
    RTS

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

    ; 1. Copy 1024 bytes (tiles 0..127) to $4800-$4BFF
    ; This puts tile 127 at character 127 ($7F) as the full solid block!
    LDA #<lut_MenuCHR
    STA tmp
    LDA #>lut_MenuCHR
    STA tmp+1

    LDA #$00
    STA chr_dest
    LDA #$48
    STA chr_dest+1

    LDX #$04
    LDY #$00
@Loop1:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    BNE @Loop1
    INC tmp+1
    INC chr_dest+1
    DEX
    BNE @Loop1

    ; 2. Copy 1024 bytes (tiles 0..127) to $4C00-$4FFF
    ; This puts the font (tiles 0..126) at characters $80..$FE!
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
@Loop2:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    BNE @Loop2
    INC tmp+1
    INC chr_dest+1
    DEX
    BNE @Loop2

    ; 3. Ensure Character $FF (at $4FF8-$4FFF) is a blank space (all zeros)
    ; so that $FF in story text and ClearNT acts as transparent/empty space
    LDY #7
    LDA #$00
:   STA $4FF8, Y
    DEY
    BPL :-

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DTE table   [$F050 :: 0x3F060]  [11294]
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
    tax
    lda lut_EasyFlashBanks, x
    sta EASYFLASH_BANK
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
