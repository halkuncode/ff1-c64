.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "KERNEL"

.export GameStart_L

.export DrawComplexString_L, DrawBox_L, CallMusicPlay_L, UpdateJoy_L, DrawPalette_L
.export DrawComplexString, DrawBox, CallMusicPlay, CallMusicPlay_NoSwap, UpdateJoy, DrawPalette, LoadMenuCHRPal, ClearOAM
.export LoadBorderPalette_Blue, LoadBorderPalette_Black
.export LoadMenuCHR, LoadMenuBGCHRAndPalettes, LoadBattleBGCHRAndPalettes, LoadBatSprCHRPalettes, LoadNewGameCHRPal
.export GameStart, OnReset, OnNMI, OnIRQ
.export WaitForVBlank_L, WaitForVBlank
.export SwapPRG_L, SwapPRG
.export CoordToNTAddr, lut_ScreenRowLo, lut_ScreenRowHi
.export DrawCursor, UpdateSprites, VerifyChecksum
.export lut_NES_to_C64, lut_OWTileColors

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
    SEI                 ; Keep interrupts disabled during hardware setup
    CLD

    LDA #COLOR_BLACK	; Turn off display (border and background to black ($00))
    STA BGCOL0
    STA EXTCOL

	LDA #$02			; Set default screen pointer ($4000) and charset ($4800)
    STA VMCSB			; Screen: $4000 (bits 7-4=0000), Charset: $4800 (bits 3-1=001 -> $02)

	LDX #$FF            ; Reset stack pointer
    TXS

    ; 1. Hardware CIA1 setup (keyboard matrix) & silence timers
    LDA #$7F
    STA CIAICR         ; Disable CIA1 timer IRQs
    STA CI2ICR         ; Disable CIA2 NMI timers
    LDA CIAICR         ; Acknowledge any pending CIA interrupts
    LDA CI2ICR
    LDA #$FF
    STA CIDDRA         ; Port A all outputs (Keyboard columns)
    STA CIAPRA         ; Port A all lines high (unselected)
    LDA #$00
    STA CIDDRB         ; Port B all inputs (Keyboard rows)

    ; 2. Reset Sprite Multiplexer & turn off hardware sprites
    STA spr_multiplex_mode ; 0 = Standard single-zone VBlank IRQ
    STA spr_irq_zone
    STA shadow_spr_en
    STA SPENA

    ; 3. Setup standard VBlank Raster IRQ at line 250
    LDA #1
    STA IRQMSK
    LDA #250
    STA RASTER
    LDA SCROLY
    AND #$7F
    STA SCROLY
    LDA #$FF
    STA VICIRQ

    ; 4. Clear Zero Page before enabling interrupts
    JSR ClearZeroPage   ; Clear Zero Page ($02-$EF)

    CLI                 ; Enable interrupts now that all hardware is cleanly initialized

    ; Check if cold boot or warm reset (Start/F1 pressed during intro)
    LDA startintrocheck
    CMP #$4D
    BEQ @TitleScreen

    LDA #$4D
    STA startintrocheck ; Mark as initialized so Start/F1 goes straight to title screen

    ; Initialize startup variables
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

.if SKIP_TO_MAP
    JMP @NewGame                    ; Skip Intro and Title, jump straight to Party Gen
.endif

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
	JSR NewGame_LoadStartingStats   ;   and set their starting stats
    ; New Game and Continue meet here -- actually start up the game
  @Begin:
    JSR ClearZeroPage               ; clear Zero Page for good measure
    
    LDA unsram_ow_scroll_x          ; fetch OW scroll from unsram
    STA ow_scroll_x
    LDA unsram_ow_scroll_y
    STA ow_scroll_y
    
    LDA unsram_vehicle              ; fetch vehicle from unsram (wouldn't
    STA vehicle_next                ;   this always be 'on-foot'?)
    STA vehicle
    
  ; JMP DoOverworld                 ; <- Flow into DoOverworld!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Do Overworld  [186]
;;
;;    Called when you enter (or exit to) the overworld.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoOverworld:
	JSR PrepOverworld       ; do all overworld preparation
    ;JSR ScreenWipe_Open     ; then do the screen wipe effect (Implment later) 
                            ; then enter the overworld loop
  ; JMP EnterOverworldLoop  ; <- flow into


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Main Overworld Game Logic Loop  [201]
;;
;;   This is where everything spawns from on the overworld.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterOverworldLoop:
    LDX #$FF            ; purge stack and wipe the stack pointer so it points to top of stack
    TXS                 ;   overworld loop is the de-facto "top" of all gameflow.

    LDA #0
    STA move_ctr_x      ; repeat delay counter

@Loop:
    JSR WaitForVBlank_L
    JSR UpdateJoy_L

    ; Check if in repeat delay
    LDA move_ctr_x
    BEQ @CheckInput
    DEC move_ctr_x
    JMP @Loop

@CheckInput:
    LDA joy
    AND #(UP | DOWN | LEFT | RIGHT)
    BEQ @Loop           ; no directional key pressed

    ; Mutually exclusive Up / Down
    LDA joy
    AND #UP
    BEQ @CheckDown
    DEC ow_scroll_y
    JMP @CheckHoriz
@CheckDown:
    LDA joy
    AND #DOWN
    BEQ @CheckHoriz
    INC ow_scroll_y

@CheckHoriz:
    ; Mutually exclusive Left / Right
    LDA joy
    AND #LEFT
    BEQ @CheckRight
    DEC ow_scroll_x
    JMP @DoRedraw
@CheckRight:
    LDA joy
    AND #RIGHT
    BEQ @DoRedraw
    INC ow_scroll_x

@DoRedraw:
    ; Repeat delay (6 frames ≈ 10 tiles/sec)
    LDA #6
    STA move_ctr_x

    ; Redraw map at new coordinates
    JSR DrawFullMap

    JMP @Loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load Overworld Tileset Data  [645]
;;
;;    Copies $400 bytes of overworld tileset data to RAM.
;;
;;  This fills the following buffers:
;;    tileset_prop
;;    tsa_ul, tsa_ur, tsa_dl, tsa_dr
;;    tsa_attr
;;    load_map_pal
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadOWTilesetData:
    LDA #BANK_OWINFO
    JSR SwapPRG_L       ; swap to bank containing OW tileset data

    LDA #0              ; set low bytes of
    STA tmp             ;  source pointer
    STA tmp+2           ;  and dest pointer

    LDA #>lut_OWTileset ; high byte of source pointer
    STA tmp+1

    LDA #>tileset_data  ; high byte of dest pointer
    STA tmp+3

    LDX #4              ; high byte of loop counter ($400 iterations)
    LDY #0              ; low byte of loop counter and index

  @Loop:
    LDA (tmp), Y        ; copy over a byte
    STA (tmp+2), Y
    INY                 ; inc our index
    BNE @Loop           ; loop until it wraps

    INC tmp+1           ; once it wraps, inc high bytes of both pointers
    INC tmp+3
    DEX                 ; and decrement overall loop counter

    BNE @Loop           ; and keep looping until that expires ($400 iterations)

    RTS                 ; then exit



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Set OW Scroll  [709]
;;
;;    Sets the scroll for the overworld map.  And optionally
;;  turns the screen on (seperate entry point)
;;
;;    Changes to SetOWScroll can impact the timing of some raster effects.
;;  See ScreenWipeFrame for details.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetOWScroll_PPUOn:
SetOWScroll:
    ; Enable MultiColor Mode and 40 Columns on VIC-II
    LDA SCROLX
    ORA #$10            ; Bit 4 = MultiColor Mode ON
    STA SCROLX

    ; Ensure 25 rows and screen enabled
    LDA SCROLY
    ORA #$10            ; Bit 4 = Screen ON
    STA SCROLY
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Clear Zero Page  [1013]
;;
;;    Clears Zero Page RAM ($0002-$00EF). Preserves $00 (DDR) and
;;  $01 (PORT) 6510 hardware I/O registers to prevent crashing.
;;
;;    This is done after game start as a preparation measure.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearZeroPage:
    LDX #$EF          ; start from $EF and count down
    LDA #0
  @Loop:
      STA 0, X
      DEX
      CPX #$01        ; Stop before clearing $01 (PORT) and $00 (DDR)
      BNE @Loop       ; clear RAM from $02-EF

    LDA #$1B          ; scramble the NPC directional RNG seed
    ORA npcdir_seed   ;  to make it a little more random
    STA npcdir_seed

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Prep Overworld  [1728]
;;
;;    Sets up everything for entering (or re-entering) the world map.
;;  INCLUDING map decompression.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrepOverworld:
    LDA #0
    ;;STA $2000           ; disable NMIs (use 64 eqivilant) 
    ;;STA $2001           ; turn off PPU ""
    ;;STA $4015           ; silence APU ""

    STA scroll_y        ; zero a whole bunch of other things:
    STA tileprop
    STA tileprop+1
    STA inroom
    STA entering_shop
    STA facing
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select
    STA mapflags        ; zeroing map flags indicates we're on the overworld map

    JSR LoadOWCHR           ; load up necessary CHR
    JSR LoadOWTilesetData   ; the tileset
    JSR LoadMapPalettes     ; palettes
    JSR DrawFullMap         ; then draw the map

    ; LDA ow_scroll_x      ; get ow scroll X
    ; AND #$10             ; isolate the '16' bit (nametable bit)
    ; CMP #$10             ; move it to C (C set if we're to use NT @ $2400)
    ; ROL A                ; roll that bit into bit 0
    ; AND #$01             ; isolate it
    ; ORA #$08             ; OR with 8 (sprites use right-hand pattern table)
    ; STA NTsoft2000       ; record this as our soft2000
    ; STA soft2000

    JSR WaitForVBlank_L       ; wait for a VBlank
    JSR DrawMapPalette        ; before drawing the palette
    JSR SetOWScroll_PPUOn     ; the setting the scroll and turning PPU on
    ; LDA #0                  ;  .. but then immediately turn PPU off!
    ; STA $2001               ;     (stupid -- why doesn't it just call the other SetOWScroll that doesn't turn PPU on)

    LDX vehicle
    LDA @lut_VehicleMusic, X  ; use the current vehicle as an index
    STA music_track           ;   to get the proper music track -- and play it

    ; LDA #BANK_BTLDATA     ; swap to battle rate bank and get the battle rate for the overworld
    ; JSR SwapPRG_L         ;  (first entry in the table).  And record it to 'battlerate'.
    ; LDA lut_BattleRates   ; However, this value goes unused because the battle rate for overworld
    ; STA battlerate        ; is hardcoded... so this is effectively useless for OW (it's used for SM, though).

    RTS                   ; then exit!

  ;;  The lut for knowing which track to play based on the current vehicle

  @lut_VehicleMusic:
  .BYTE $44               ; unused
  .BYTE $44               ; on foot
  .BYTE $44,$44           ; canoe (2nd byte unused)
  .BYTE $45,$45,$45,$45   ; ship (last 3 bytes unused)
  .BYTE $46               ; airship



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  NewGame_LoadStartingStats  [1811]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NewGame_LoadStartingStats:
    LDA #BANK_STARTINGSTATS ; swap in bank containing starting stats
    JSR SwapPRG_L
    
    LDX #$00                ; load up the starting stats for each character
    JSR @LoadStats
    LDX #$40
    JSR @LoadStats
    LDX #$80
    JSR @LoadStats
    LDX #$C0
  ; JMP @LoadStats
    

  @LoadStats:
    LDA ch_class, X         ; get the class
    ASL A                   ; $10 bytes of starting data for each class
    ASL A
    ASL A
    ASL A
    TAY                     ; source index in Y
    
    ;; lut_ClassStartingStats table contains $B bytes of data, padded to $10
    ;;   byte 0 is a redundant and unused class ID byte.
    ;;   The rest is as outlined below
    
    LDA lut_ClassStartingStats+1, Y ; starting HP
    STA ch_curhp, X
    STA ch_maxhp, X
    
    LDA lut_ClassStartingStats+2, Y ; base stats
    STA ch_str, X
    LDA lut_ClassStartingStats+3, Y
    STA ch_agil, X
    LDA lut_ClassStartingStats+4, Y
    STA ch_int, X
    LDA lut_ClassStartingStats+5, Y
    STA ch_vit, X
    LDA lut_ClassStartingStats+6, Y
    STA ch_luck, X
    
    LDA lut_ClassStartingStats+7, Y ; sub stats
    STA ch_dmg, X
    LDA lut_ClassStartingStats+8, Y
    STA ch_hitrate, X
    LDA lut_ClassStartingStats+9, Y
    STA ch_evade, X
    LDA lut_ClassStartingStats+$A, Y
    STA ch_magdef, X
    
    ; Award starting MP if the class ID is >= RM, but < KN
    LDA ch_class, X
    CMP #CLS_RM
    BCC :+
      CMP #CLS_KN
      BCS :+
        LDA #$02                ; start with 2 MP
        STA ch_curmp, X
        STA ch_maxmp, X
  : RTS



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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  CallMusicPlay   [1613]
;;
;;    Calls the music play routine.  Comes in two flavors.  Both are the same, only
;;  CallMusicPlay_NoSwap does not swap the original bank back in.  Therefore CallMusicPlay_NoSwap
;;  should only be called from this bank (bank F) and only if the bank that's swapped in
;;  is unimportant.
;;
;;    The Music Play routine should be called once per frame unless all sound is stopped.  If sound is active,
;;  failure to call the music Play routine will result in unsteady tempo and other ugly audio effects.
;;
;;  IN:  cur_bank = bank to swap back to on exit (CallMusicPlay only)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CallMusicPlay_NoSwap:
    LDA #BANK_MUSIC     ; swap to music bank (where MusicPlay is)
    JSR SwapPRG_L
    JMP MusicPlay_L     ; jump to it, and return (do not swap back)

CallMusicPlay:
    PHA
    TXA
    PHA
    TYA
    PHA
    LDA cur_bank
    PHA

    LDA #BANK_MUSIC     ; swap to music bank (for MusicPlay)
    JSR SwapPRG_L
    JSR MusicPlay_L     ; call MusicPlay

    PLA
    JSR SwapPRG_L       ; swap back to original bank

    PLA
    TAY
    PLA
    TAX
    PLA
    RTS 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Full Map   [3821]
;;
;;    Draws 15 rows of tiles for the map, filling the entire screen.
;;  It accomplishes this by adding 15 to the map scroll, then faking
;;  upward movement to draw rows bottom first.
;;
;;    For Standard maps, this does no map decompression.  However for the overworld,
;;  each row is decompressed prior to drawing.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawFullMap:
    ; Initialize row counter for 13 metatile rows (0 to 12)
    LDA #0
    STA tmp+14          ; metatile row index (0..12)

@RowLoop:
    ; Calculate world Y: mapdraw_y = (ow_scroll_y + row_index) & $FF
    LDA ow_scroll_y
    CLC
    ADC tmp+14
    STA mapdraw_y

    ; Decompress this overworld row into mapdata ($7000 + (mapdraw_y & $0F) * $100)
    JSR LoadOWMapRow

    ; Set map_row_ptr (tmp+8, tmp+9) to start of decompressed row in RAM
    LDA #<mapdata
    STA tmp+8
    LDA mapdraw_y
    AND #$0F
    ORA #>mapdata
    STA tmp+9

    ; Calculate Screen RAM row pointers & Color RAM row pointers
    ; top screen row = tmp+14 * 2
    LDA tmp+14
    ASL A               ; * 2
    TAX
    LDA lut_ScreenRowLo, X
    STA tmp+0           ; scr_top_ptr low
    STA tmp+2           ; col_top_ptr low (same offset!)
    LDA lut_ScreenRowHi, X
    STA tmp+1           ; scr_top_ptr high ($40..$43)
    CLC
    ADC #$98
    STA tmp+3           ; col_top_ptr high ($D8..$DB, Color RAM)

    ; Check if there is a bottom screen row (for row_index < 12)
    CPX #24             ; row 24 is the 25th row on screen, so no row 25
    BCS @NoBottomRow
    INX
    LDA lut_ScreenRowLo, X
    STA tmp+4           ; scr_bot_ptr low
    STA tmp+6           ; col_bot_ptr low
    LDA lut_ScreenRowHi, X
    STA tmp+5           ; scr_bot_ptr high ($40..$43)
    CLC
    ADC #$98
    STA tmp+7           ; col_bot_ptr high ($D8..$DB, Color RAM)

@NoBottomRow:
    ; Now plot 20 metatiles horizontally across 40 character columns
    LDA #0
    STA tmp+10          ; tmp+10 = metatile column index (0..19)

@ColLoop:
    ; world_x = (ow_scroll_x + col_index) & $FF
    LDA ow_scroll_x
    CLC
    ADC tmp+10
    TAY                 ; Y = world_x index into decompressed row
    LDA (tmp+8), Y      ; A = metatile ID (0..127)
    TAY                 ; Y = metatile ID index into TSA tables

    ; Fetch quadrant character tile IDs
    LDA tsa_ul, Y
    STA tmp+12          ; char_ul
    LDA tsa_ur, Y
    STA tmp+13          ; char_ur
    LDA tsa_dl, Y
    STA tmp+15          ; char_dl
    LDA tsa_dr, Y
    PHA                 ; save char_dr on stack

    ; col_index * 2 gives character column offset on screen (0, 2, 4, ... 38)
    LDA tmp+10
    ASL A
    TAY                 ; Y = char column offset

    ; Plot top-left tile (Screen RAM & Color RAM)
    LDA tmp+12
    STA (tmp+0), Y
    TAX
    LDA lut_OWTileColors, X
    STA (tmp+2), Y

    ; Plot top-right tile
    INY
    LDA tmp+13
    STA (tmp+0), Y
    TAX
    LDA lut_OWTileColors, X
    STA (tmp+2), Y
    DEY

    ; Plot bottom row (if row_index < 12)
    LDA tmp+14
    CMP #12
    BCS @SkipBottomPlot

    ; Plot bottom-left tile
    LDA tmp+15
    STA (tmp+4), Y
    TAX
    LDA lut_OWTileColors, X
    STA (tmp+6), Y

    ; Plot bottom-right tile
    INY
    PLA                 ; retrieve char_dr from stack
    STA (tmp+4), Y
    TAX
    LDA lut_OWTileColors, X
    STA (tmp+6), Y
    JMP @ColNext

@SkipBottomPlot:
    PLA                 ; discard saved char_dr from stack

@ColNext:
    INC tmp+10
    LDA tmp+10
    CMP #20             ; 20 metatiles wide (40 columns)
    BNE @ColLoop

    ; Next metatile row
    INC tmp+14
    LDA tmp+14
    CMP #13             ; 13 metatile rows (rows 0..12 = screen rows 0..24)
    BEQ @Done
    JMP @RowLoop

@Done:
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_OWTileColors
;;
;;  Lookup table mapping each of the 256 Overworld 8x8 character tiles ($00-$FF)
;;  to its corresponding MultiColor Color RAM nybble ($08-$0F with bit 3 set).
;;
;;  Tile Ranges:
;;    $00-$1F (  0- 31): $09 (White)       - Mountains
;;    $20-$3A ( 32- 58): $0D (Green)       - Terrain / grass / paths
;;    $3B-$61 ( 59- 97): $0E (Blue)        - Water / rivers / sea
;;    $62-$68 ( 98-104): $0A (Red / Brown) - Bridges / dirt
;;    $69-$6A (105-106): $0E (Blue)        - Waterfall
;;    $6B-$72 (107-114): $0B (Cyan)        - Marsh / swamp
;;    $73-$7B (115-123): $0F (Yellow)      - Desert tower
;;    $7C-$EA (124-234): $09 (White)       - Buildings / castles / towns
;;    $EB-$F3 (235-243): $0F (Yellow)      - Desert sands
;;    $F4-$FF (244-255): $09 (White)       - Docks / structures
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_OWTileColors:
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $00-$0F
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $10-$1F
    .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D  ; $20-$2F
    .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0E, $0E, $0E, $0E, $0E  ; $30-$3F
    .byte $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  ; $40-$4F
    .byte $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  ; $50-$5F
    .byte $0E, $0E, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0B, $0B, $0B, $0B, $0B  ; $60-$6F
    .byte $0B, $0B, $0B, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $09, $09, $09, $09  ; $70-$7F
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $80-$8F
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $90-$9F
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $A0-$AF
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $B0-$BF
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $C0-$CF
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $D0-$DF
    .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0F, $0F, $0F, $0F, $0F  ; $E0-$EF
    .byte $0F, $0F, $0F, $0F, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $F0-$FF



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Map routines' Semi-local RTS   [4158]
;;
;;   It is branched/jumped to by map loading routines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Map_RTS:
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load World Map Row  [4178]
;;
;;  Called to load a single row of an overworld map.  Since only so many can be in RAM at once
;;    a new row needs to be loaded every time the player moves up or down on the overworld map.
;;
;;  IN:   mapflags  = indicates whether or not we're on the overworld map
;;        mapdraw_y = indicates which row needs to be loaded
;;
;;  TMP:  tmp to tmp+7 used
;;
;;  NOTES:  overworld map cannot cross bank boundary.  Entire map and all its pointers must all fit on one bank
;;     (which shouldn't be a problem).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadOWMapRow:
    LDA mapflags     ; get StandardMap flag (to test to see if we're really in the overworld or not)
    LSR A            ; shift flag into C
    BCS Map_RTS      ; if flag is set (in standard map), we're not in the overworld, so don't do anything -- just exit

    LDA #BANK_OWMAP  ; swap to bank containing overworld map
    JSR SwapPRG_L

    LDA #>lut_OWPtrTbl ; set (tmp+6) to the start of the pointers for the rows of the OW map.
    STA tmp+7          ; we will then index this pointer table to get the pointer for the start of the row
    LDA #<lut_OWPtrTbl ; Need to use a pointer because there are 256 rows, which means 512 bytes for indexing
    STA tmp+6          ; so normal indexing won't work -- have to use indirect mode

    LDA mapdraw_y    ; Load the row we need to load
    TAX              ; stuff it in X (temporary)
    ASL A            ; double it (2 bytes per pointer)
    BCC :+           ; if there was carry...
      INC tmp+7      ; inc the high byte of our temp pointer
:   TAY              ; put low byte in Y for indexing
    LDA (tmp+6), Y   ; load low byte of row pointer
    STA tmp          ; put it in tmp
    INY              ; inc our index
    LDA (tmp+6), Y   ; load high byte, and put it in tmp+1
    STA tmp+1        ; (tmp) is now our source pointer for the row

    TXA              ; get our row number (previously stuffed in X)
    AND #$0F         ; mask out the low 4 bits
    ORA #>mapdata    ; and ORA with high byte of mapdata destination
    STA tmp+3        ; use this as high byte of dest pointer (to receive decompressed map)
    LDA #<mapdata    ; the row will be decompressed to $7x00-$7xFF
    STA tmp+2        ; where 'x' is the low 4 bits of the row number
                     ; (tmp+2) is now our dest pointer for the row

           ; no RTS or JMP -- code seamlessly runs into DecompressMap



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DecompressMap  [4227]
;;
;;   Decompresses a map from the given source buffer, and puts it in the given dest buffer
;;
;;  IN:  (tmp)   = pointer to source buffer (containing compressed map -- it's assumed it's between $8000-BFFF)
;;       (tmp+2) = pointer to dest buffer (to receive decompressed map. typically $7xxx)
;;
;;  TMP: tmp to tmp+5 used
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DecompressMap:
    LDY #0          ; zero Y, our index
    LDA (tmp), Y    ; read a byte from source
    BPL @SingleTile ; if high byte clear (not a run), jump ahead to place a single tile
    CMP #$FF        ; otherwise check for $FF (termination code)
    BEQ Map_RTS     ; if == $FF, branch to exit

    ; code reaches here if loaded source byte was $80-FE (need a run of this tile)
    AND #$7F        ; take low 7 bits (tile to run)
    STA tmp+4       ; put tile in temp ram
    INC tmp         ; inc low byte of src pointer (need to leave Y=0)
    BNE @TileRun    ; if it didn't wrap, jump ahead to TileRun sublabel

      INC tmp+1     ; low byte of src pointer wrapped, so inc high byte
      BIT tmp+1     ; check to see if high byte went over $BF (crossed bank boundary)
      BVC @TileRun  ; if it didn't, proceed to TileRun
      JSR @NextBank ; otherwise, we need to swap in the next bank, first

  @TileRun:
    LDA (tmp), Y    ; get next src byte (length of run)
    TAX             ; put length of run in X
    LDA tmp+4       ; get tile ID
  @RunLoop:
      STA (tmp+2), Y ; write tile ID to dest buffer
      INY            ; INY to increment our dest index
      BEQ @Full256   ; if Y wrapped... this run was a full 256 tiles long (maximum). Jump ahead
      DEX            ; decrement X (our run length)
      BNE @RunLoop   ; if it isn't zero yet, we jump back to the loop

      TYA            ; add Y to the low byte of our dest pointer
      CLC
      ADC tmp+2
      STA tmp+2
      BCC :+         ; if adding Y caused a carry, we'll need to inc the high byte
    @Full256:
        INC tmp+3    ; inc high byte of dest pointer
 :    INC tmp        ; inc low byte of src pointer
      BNE DecompressMap ; if it didn't wrap, jump back to main map loading loop
      JMP @IncSrcHigh   ; otherwise (did wrap), need to increment the high byte of the source pointer

  @SingleTile:
    STA (tmp+2), Y       ; write tile to dest buffer
    INC tmp+2            ; increment low byte of dest pointer
    BNE :+               ; if it wrapped...
      INC tmp+3          ; inc high byte of dest pointer
 :  INC tmp              ; inc low byte of src pointer
    BNE DecompressMap    ; if no wrapping, just continue with map decompression. Otherwise...

  @IncSrcHigh:
    INC tmp+1            ; increment high byte of source pointer
    BIT tmp+1            ; check to see if we've reached end of PRG bank (BIT will set V if the value is >= $C0)
    BVC DecompressMap    ; if we haven't, just continue with map decompression
    JSR @NextBank        ; otherwise swap in the next bank
    JMP DecompressMap    ; and continue decompression

;; NextBank local subroutine
;; called via JSR when a map crosses a bank boundary (so a new bank needs to be swapped in)
@NextBank:
    LDA #>$8000   ; reset high byte of source pointer to start of the bank: $8000
    STA tmp+1
    LDA tmp+5     ; get original bank number
    CLC
    ADC #$01      ; increment it by 1
    JMP SwapPRG_L ; swap that new bank in and exit



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
;;  Draw Map Palette  [5872]
;;
;;    Draws the normal palette, or the "in room" palette depending on whether or
;;  not the player is currently inside rooms.  This is called by maps only.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawMapPalette:
    LDA #COLOR_BLACK
    STA EXTCOL          ; Border = Black ($00)
    STA BGCOL0          ; BGCOL0 = Black ($00)
    LDA #COLOR_GREEN
    STA BGCOL1          ; BGCOL1 = Dark/Normal Green ($05)
    LDA #COLOR_GREY
    STA BGCOL2          ; BGCOL2 = Mid Grey ($0C / 12)
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load Map Palettes  [5934]
;;
;;    Note palettes are not loaded from ROM, but rather they're loaded from
;;  the load_map_pal temporary buffer (temporary because it gets overwritten
;;  due to it sharing space with draw_buf).  So this must be called pretty much
;;  immediately after the tileset is loaded.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadMapPalettes:
    RTS                 ; dummied out for now

;     LDX #$2F                ; X is loop counter
;   @Loop:
;       LDA load_map_pal, X   ; copy colors from temp palette buffer
;       STA cur_pal, X        ; to our actual palette
;       DEX
;       BPL @Loop             ; loop until X wraps ($30 iterations)
; 
;     LDA #BANK_MAPMANPAL
;     JSR SwapPRG_L           ; swap to bank containing mapman palettes
; 
;     LDA ch_class            ; get lead party member's class
;     ASL A                   ; double it, and put it in X
;     TAX
; 
;     LDA lut_MapmanPalettes, X   ; use that as an index to get that class's mapman palette
;     STA cur_pal+$12
;     LDA lut_MapmanPalettes+1, X
;     STA cur_pal+$16
; 
;     RTS                     ; then exit



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
    NOP
    NOP
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
    NOP
    NOP
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
    NOP
    NOP
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
    NOP
    NOP
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
;;  DO NOT IMPLMENT A CONTROLLER ON PORT 2 THIS GAME IS KEYBAORD ONLY
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
    LDA #COLOR_LIGHTBLUE ; Color 14 (bit 3=1 enables multicolor for border)
    STA (color_dest), Y
    INY

    LDX tmp+10         ; width of innards
@Loop:
    LDA #$FF           ; FF = inner box body tile (blank space, blue bg shines through)
    STA (ppu_dest), Y
    LDA #COLOR_WHITE   ; Color 1 (bit 3=0 keeps innards hi-res)
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$FB           ; FB = R border tile
    STA (ppu_dest), Y
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
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
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
    STA (color_dest), Y
    INY

    LDX tmp+10          ; width of innards
@Loop:
    LDA #$FD            ; FD = bottom border tile
    STA (ppu_dest), Y
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$FE            ; FE = DR border tile
    STA (ppu_dest), Y
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
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
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
    STA (color_dest), Y
    INY

    LDX tmp+10          ; width of innards
@Loop:
    LDA #$F8            ; F8 = U border tile
    STA (ppu_dest), Y
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
    STA (color_dest), Y
    INY
    DEX
    BNE @Loop

    LDA #$F9            ; F9 = UR border tile
    STA (ppu_dest), Y
    LDA #COLOR_LIGHTBLUE ; Color 14 (multicolor border)
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


LoadOWCHR:                     ; overworld map -- does not load any palettes
    LDA #BANK_MAPCHR
    JSR SwapPRG_L
    JSR LoadOWBGCHR
    ;JSR LoadPlayerMapmanCHR    ; skipped for now - sprite architecture under rework
    ;JMP LoadOWObjectCHR
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load Player Mapman CHR  [9710]
;;
;;   Loads CHR for the player mapman graphic based on the lead party member's class
;;
;;  TMP:  tmp and tmp+1 used
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadPlayerMapmanCHR:
    LDA #0          ; #0 -> tmp
    STA tmp
    LDA ch_class    ; Get lead party member's class
    ORA #$90        ; ORA with #$90, and put in tmp+1
    STA tmp+1       ; (tmp) is now $9x00 (where x=lead party member's class).
                    ;    This points to mapman graphics for that class
    LDX #1          ; X=1  (load 1 row of tiles)
    LDA #$10        ; A=$10 (high byte of dest address:  $1000)
    JMP CHRLoadToA  ; jump to CHR loader


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load OW Object CHR  [9734]
;;
;;   Loads CHR for all overworld objects and mapmans
;;   This includes:  ship, canoe, airship, bridge, canal, etc
;;   It is assumed the proper CHR bank is swapped in.
;;
;;  IN:   tmp  = assumed to contain 0  (this routine does not explicitly clear it)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadOWObjectCHR:
    LDA #$9C         ; source address is $9C00 (note:  low byte not explicitly cleared)
    STA tmp+1
    LDX #$06         ; 6 rows to load
    LDA #$11         ; dest address is $1100
    JMP CHRLoadToA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load OW BG CHR  [9750]
;;
;;   Loads all CHR for Overworld BG tiles (full left-hand pattern table)
;;   It is assumed the proper CHR bank is swapped in
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadOWBGCHR:
    LDA #0
    STA tmp
    LDA #$80
    STA tmp+1        ; source address is $8000
    LDX #$08         ; 8 pages to load (2048 bytes = 256 C64 tiles -> $4800-$4FFF)
    LDA #0           ; dest address is $0000 (maps to C64 $4800)
    JMP CHRLoadToA



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
    LDA #COLOR_WHITE           ; Multicolor 1 = 01 (White)
    STA BGCOL1
    LDA #COLOR_DARKGREY        ; Multicolor 2 = 11 (Dark Grey, $0B)
    STA BGCOL2
    LDA #COLOR_BLUE            ; Background = Blue
    STA BGCOL0
    LDA #COLOR_BLACK           ; Screen border = Black
    STA EXTCOL
    LDA SCROLX
    ORA #$10                   ; Enable MultiColor text mode
    STA SCROLX
    RTS

LoadBorderPalette_Black:
    LDA #COLOR_WHITE           ; Multicolor 1 = 01 (White)
    STA BGCOL1
    LDA #COLOR_DARKGREY        ; Multicolor 2 = 11 (Dark Grey, $0B)
    STA BGCOL2
    LDA #COLOR_BLACK           ; Background = Black
    STA BGCOL0
    STA EXTCOL
    LDA SCROLX
    ORA #$10                   ; Enable MultiColor text mode
    STA SCROLX
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
    pha
    txa
    pha
    tsx
    lda $0102, x                ; Fetch original A (bank ID) from stack
    tax
    lda lut_EasyFlashBanks, x   ; Lookup EasyFlash physical bank
    sta EASYFLASH_BANK          ; Perform hardware bank switch
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

    jmp GameStart_L    ; jump to the start of the game (GameStart will CLI when ready)


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
