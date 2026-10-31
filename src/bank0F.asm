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
.export DrawCursor, UpdateSprites, VerifyChecksum, DrawOBSprite, EraseBox, DoOverworld, DrawItemBox, SortEquipmentList
.export DrawEquipMenuStrings, UnadjustEquipStats, ReadjustEquipStats
.export lut_NES_to_C64, lut_OWMetatileColors, lut_TownCharColors
.export EnterCorneliaTown
.export LoadPrice

.import EnterIntroStory, EnterTitleScreen, NewGamePartyGeneration, EnterMainMenu, EnterLineupMenu
.import lut_MenuCHR
.import lut_FingerSprite, lut_HeroSprites
.import lut_MapmanSprites
.import lut_VehicleSprites
.import lut_BattleFormations
.import MusicPlay_L
.import PrintCharStat, PrintPrice, PrintGold
.import PrintNumber_1Digit, PrintNumber_2Digit, PrintNumber_3Digit, PrintNumber_5Digit, PrintNumber_6Digit


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
CallMusicPlay_L:      RTS                 ; Music is driven automatically by Raster IRQ at 60 Hz
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

    ; 3. Setup standard VBlank Raster IRQ at line 0
    LDA #1
    STA IRQMSK
    LDA #0
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
    STA move_speed
    STA move_ctr_x
    STA move_ctr_y
    STA mapdraw_job

@Loop:
    JSR UpdateJoy_L

    JSR OverworldMovement

    LDA move_speed
    BNE :+
      ; Check for entry teleport into Cornelia Town (Teleport ID 1)
      LDA vehicle
      CMP #$08                  ; Airship flies over towns
      BEQ @NoTele
      LDA tileprop+1
      AND #$80                  ; Teleport bit?
      BEQ @NoTele
      LDA tileprop+1
      AND #$1F                  ; Teleport destination ID
      CMP #$01                  ; Cornelia Town?
      BNE @NoTele               ; Ignore other castles and dungeons
      JSR EnterCorneliaTown
      JMP EnterOverworldLoop
@NoTele:
      JSR ProcessOWInput
:
    JSR WaitForVBlank_L
    INC framecounter
    JSR DrawOWSprites
    JMP @Loop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Process OW input   [479]
;;
;;    Updates joy data and does input processing for the overworld.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessOWInput:
    LDA vehchgpause             ; Check vehicle change pause counter
    BEQ @NoVehPause
    SEC
    SBC #$01
    STA vehchgpause
    RTS                         ; Ignore input during transition pause

@NoVehPause:
    LDA joy_a
    BEQ @NoJoyA
    LDA #0
    STA joy_a
    LDA vehicle
    CMP #$08
    BEQ @DoLandAirship
    CMP #$01
    BEQ @DoFlyAirship
    JMP @NoJoyA

@DoFlyAirship:
    JSR FlyAirship
    RTS

@DoLandAirship:
    JSR LandAirship
    RTS

@NoJoyA:
    LDA joy_start
    BEQ @NoStart
    LDA #0
    STA joy_start
    LDA #BANK_MENUS             ; Swap to Bank $0E (BANK_MENUS)
    JSR SwapPRG_L
    JSR EnterMainMenu           ; Enter main menu!
    JMP DoOverworld             ; Redraw overworld when main menu exits

@NoStart:
    LDA joy_select
    BEQ @NoSelect
    LDA #0
    STA joy_select
    LDA #BANK_MENUS             ; Swap to Bank $0E (BANK_MENUS)
    JSR SwapPRG_L
    JSR EnterLineupMenu         ; Enter formation/lineup menu!
    JMP DoOverworld             ; Redraw overworld when lineup menu exits

@NoSelect:
    LDA joy
    AND #(RIGHT | LEFT | DOWN | UP)
    BEQ @Exit           ; if no direction pressed, exit

    ; Determine facing direction (priority: Right, Left, Down, Up)
    LDA joy
    AND #RIGHT
    BNE @SetRight
    LDA joy
    AND #LEFT
    BNE @SetLeft
    LDA joy
    AND #DOWN
    BNE @SetDown
    LDA #UP
    BNE @SetFacing
@SetRight:
    LDA #RIGHT
    BNE @SetFacing
@SetLeft:
    LDA #LEFT
    BNE @SetFacing
@SetDown:
    LDA #DOWN
@SetFacing:
    STA facing

    LDX vehicle
    CPX #$08
    BEQ @StartMove
    CPX #$04
    BEQ @MoveShip
    CPX #$02
    BEQ @MoveCanoe

@MoveOnFoot:
    JSR OWCanMove
    BCC @StartMove

    ; Check if stepping into river/lake via canoe
    JSR BoardCanoe
    BCC @StartMove

    ; Check if stepping onto the docked ship
    JSR BoardShip
    BCC @StartMove
    BCS @Exit

@MoveCanoe:
    JSR OWCanMove
    BCC @StartMove

    ; Check if unboarding canoe onto land on foot
    JSR UnboardBoat
    BCC @StartMove

    ; Check if boarding docked ship directly from canoe
    JSR BoardShip
    BCC @StartMove
    BCS @Exit

@MoveShip:
    JSR OWCanMove
    BCC @StartMove

    ; Check if boarding canoe directly from ship
    JSR BoardCanoe
    BCC @StartMove

    ; If blocked by land, check if target tile allows docking!
    LDA tileprop
    AND #(OWTP_DOCKSHIP | 1)
    CMP #OWTP_DOCKSHIP
    BNE @Exit           ; Cannot dock here

    JSR UnboardBoat_Abs
    ; Flow into @StartMove to step onto land on foot!

@StartMove:
    JSR StartMapMove

@Exit:
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Overworld movement  [685]
;;
;;    Processes drawing and movement on the overworld map.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OverworldMovement:
    LDA move_speed
    BEQ @Exit

    LDA facing
    LSR A
    BCS @MoveRight
    LSR A
    BCS @MoveLeft
    LSR A
    BCS @MoveDown
    LSR A
    BCS @MoveUp
@Exit:
    RTS

@MoveRight:
    LDA move_ctr_x
    CLC
    ADC move_speed
    STA move_ctr_x
    CMP #16
    BCC @Exit
    INC ow_scroll_x
    JMP @StepDone

@MoveLeft:
    LDA move_ctr_x
    CLC
    ADC move_speed
    STA move_ctr_x
    CMP #16
    BCC @Exit
    DEC ow_scroll_x
    JMP @StepDone

@MoveDown:
    LDA move_ctr_y
    CLC
    ADC move_speed
    STA move_ctr_y
    CMP #16
    BCC @Exit
    INC ow_scroll_y
    JMP @StepDone

@MoveUp:
    LDA move_ctr_y
    CLC
    ADC move_speed
    STA move_ctr_y
    CMP #16
    BCC @Exit
    DEC ow_scroll_y
    JMP @StepDone

@StepDone:
    LDA #0
    STA move_ctr_x
    STA move_ctr_y
    STA move_speed

    ; Update vehicle if changing (e.g. boarding ship)
    LDA vehicle
    CMP vehicle_next
    BEQ @NoVehChange
    LDA vehicle_next
    STA vehicle
    JSR LoadPlayerMapmanSprites
@NoVehChange:

    JSR DrawFullMap
    JSR GetOWTile
    LDA vehicle
    CMP #$08
    BNE :+
    LDA #0
    STA tileprop+1      ; No random encounters in airship
:   RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  GetOWTile  [1635]
;;
;;  Fetches the overworld metatile ID and properties for the tile
;;  the player is currently standing on:
;;    World X = ow_scroll_x + OW_PLAYER_METATILE_X
;;    World Y = ow_scroll_y + OW_PLAYER_METATILE_Y
;;
;;  OUT:  ow_tile   = metatile ID (0..127)
;;        inforest  = non-zero if special tile (caravan, chime, floater)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetOWTile:
    LDA ow_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA tmp                     ; Column index in decompressed row (low byte of pointer)

    LDA ow_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    AND #$0F                    ; Ring buffer row (0..15)
    ORA #>mapdata               ; $70..$7F
    STA tmp+1                   ; High byte of pointer

    LDY #0
    LDA (tmp), Y                ; Get metatile ID
    STA ow_tile

    ASL A                       ; 2 bytes per metatile property
    TAX
    LDA tileset_prop, X         ; Read first property byte
    STA tileprop
    AND #OWTP_SPEC_MASK
    STA inforest
    LDA tileset_prop+1, X       ; Read second property byte (teleport / battle)
    STA tileprop+1
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  OWCanMove  [1086]
;;
;;  Checks whether the player can move onto the target tile
;;  based on current vehicle and tile properties.
;;
;;  IN:   facing = direction (RIGHT, LEFT, DOWN, UP)
;;  OUT:  C clear = movement allowed
;;        C set   = movement blocked
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OWCanMove:
    LDA facing
    LSR A               ; bit 0: RIGHT
    BCS @Right
    LSR A               ; bit 1: LEFT
    BCS @Left
    LSR A               ; bit 2: DOWN
    BCS @Down

@Up:
    LDX #OW_PLAYER_METATILE_X
    LDY #OW_PLAYER_METATILE_Y - 1
    JMP @Calc

@Down:
    LDX #OW_PLAYER_METATILE_X
    LDY #OW_PLAYER_METATILE_Y + 1
    JMP @Calc

@Right:
    LDX #OW_PLAYER_METATILE_X + 1
    LDY #OW_PLAYER_METATILE_Y
    JMP @Calc

@Left:
    LDX #OW_PLAYER_METATILE_X - 1
    LDY #OW_PLAYER_METATILE_Y

@Calc:
    TXA
    CLC
    ADC ow_scroll_x     ; Target World X
    STA tmp             ; Low byte of pointer
    STA tmp+2           ; Save target X for BoardShip

    TYA
    CLC
    ADC ow_scroll_y     ; Target World Y
    STA tmp+3           ; Save target Y for BoardShip
    AND #$0F            ; Ring buffer row (0..15)
    ORA #>mapdata       ; $70..$7F
    STA tmp+1           ; High byte of pointer

    LDY #0
    LDA (tmp), Y        ; Metatile ID at target coords

    ASL A               ; 2 bytes per tile properties
    TAX
    LDA tileset_prop, X ; Copy tile properties from tileset
    STA tileprop
    LDA tileset_prop+1, X
    STA tileprop+1

    ; Airship (vehicle == 8) can fly over everything
    LDA vehicle
    CMP #$08
    BEQ @Success

    ; Vehicle collision check:
    ; Bit 0 = impassable on foot, Bit 1 = canoe, Bit 2 = ship
    LDA tileprop
    AND vehicle
    BNE @Blocked        ; If non-zero, movement forbidden!

    ; If on foot, check special tiles
    LDA vehicle
    CMP #$01
    BEQ @OnFoot

@Success:
    CLC                 ; Movement allowed
    RTS

@Blocked:
    SEC                 ; Movement blocked
    RTS

@OnFoot:
    LDA tileprop
    AND #OWTP_SPEC_MASK
    BEQ @Success        ; Nothing special, success!

    CMP #OWTP_SPEC_CHIME ; Mirage Tower requires Chime
    BEQ @NeedChime

    CMP #OWTP_SPEC_CARAVAN ; Caravan check
    BNE @Success

@Caravan:
    LDA game_flags+OBJID_FAIRY
    AND #$01            ; If fairy already freed, cannot re-enter
    BNE @Success

    LDA #$01            ; Entering caravan shop
    STA entering_shop
    LDA #70
    STA shop_id
    CLC
    RTS

@NeedChime:
    LDA item_chime      ; Check if Chime is in inventory
    BNE @Success        ; If so, allowed
    SEC                 ; Otherwise blocked!
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  BoardShip  [C609]
;;
;;  Attempts to board the parked ship if target coords match (ship_x, ship_y).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BoardShip:
    LDA ship_vis        ; is ship visible / available?
    BEQ Board_Fail      ; if not, fail

    LDA ship_x          ; does target X match ship_x?
    CMP tmp+2
    BNE Board_Fail
    LDA ship_y          ; does target Y match ship_y?
    CMP tmp+3
    BNE Board_Fail

    LDA #$01
    STA vehicle         ; keep current vehicle on foot for the step
    LDA #$04
    STA vehicle_next    ; next vehicle becomes ship when step completes
    LDA #$04
    STA vehchgpause     ; pause briefly to board the ship
    LDA #0
    STA tileprop+1      ; prevent unwanted battle

    LDA #$45
    STA music_track     ; switch to ship music track
    CLC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  BoardCanoe  [$C5E6]
;;
;;  Attempts to board the canoe from on foot or from ship.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BoardCanoe:
    LDA tileprop
    AND #$02            ; Can canoe enter target tile? (bit 1 == 0)
    BNE Board_Fail

    LDA has_canoe       ; Does player have the canoe?
    BEQ Board_Fail

    LDA #$04
    STA vehchgpause

    LDA vehicle         ; Old vehicle
    LDX #$01
    STX vehicle         ; Remain on foot during transition step
    LDX #$02
    STX vehicle_next    ; Become canoe when step finishes

    LDX #0
    STX tileprop+1      ; Prevent battle on transition step

    CMP #$04            ; Did we transition directly from the ship?
    BNE :+
    JSR DockShip        ; If so, dock the ship at our previous position!
:   CLC
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UnboardBoat  [$C5CC]
;;
;;  Exits the canoe or ship onto walkable land on foot.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UnboardBoat:
    LDA tileprop
    AND #$01            ; Walkable on foot? (bit 0 == 0)
    BNE Board_Fail

UnboardBoat_Abs:
    LDA vehicle         ; Old vehicle
    LDX #$01
    STX vehicle_next    ; Next vehicle = foot
    STX vehicle         ; Current vehicle = foot
    LDX #0
    STX tileprop+1      ; Prevent battle

    CMP #$04            ; Was old vehicle the ship?
    BNE :+
    JSR DockShip        ; If so, dock the ship!
:   JSR LoadPlayerMapmanSprites
    CLC
    RTS

DockShip:
    LDA ow_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA ship_x

    LDA ow_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    STA ship_y

    LDA #$44
    STA music_track     ; Switch back to overworld theme
    RTS

Board_Fail:
    SEC
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  FlyAirship  [C215]
;;
;;  Takes off in the airship if player is standing on (airship_x, airship_y).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyAirship:
    LDA airship_vis
    BEQ @Exit

    ; Check if player coords match airship coords
    LDA ow_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    CMP airship_x
    BNE @Exit

    LDA ow_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    CMP airship_y
    BNE @Exit

    LDA #$08
    STA vehicle_next
    STA vehicle
    LDA #$04
    STA vehchgpause
    LDA #$46
    STA music_track     ; switch to airship theme

    JSR LoadPlayerMapmanSprites
    JMP AnimateAirshipTakeoff
@Exit:
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LandAirship  [C6B8]
;;
;;  Attempts to land the airship at current player coords.
;;  Animates descent; if landing is illegal, lifts back into the air.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LandAirship:
    ; 1. Animate descending to the ground
    JSR AnimateAirshipLanding

    ; 2. Check if landing is legal on current tile (tileset_prop & $08 == 0)
    LDA ow_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA tmp

    LDA ow_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    AND #$0F
    ORA #>mapdata
    STA tmp+1

    LDY #0
    LDA (tmp), Y        ; Tile ID
    ASL A
    TAX
    LDA tileset_prop, X ; Tile properties byte 0
    AND #$08            ; Bit 3 = "no airship" landing flag
    BEQ @LegalLand

    ; Illegal landing (mountains, trees, water, etc.):
    ; Bounce right back into the air!
    JSR AnimateAirshipTakeoff
    RTS

@LegalLand:
    ; Legal landing:
    LDA ow_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA airship_x

    LDA ow_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    STA airship_y

    LDA #$01
    STA vehicle_next
    STA vehicle
    LDA #$04
    STA vehchgpause
    LDA #$44
    STA music_track     ; switch back to overworld theme

    JSR LoadPlayerMapmanSprites
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  AnimateAirshipTakeoff  [$E1A8]
;;
;;  Animates the airship rising from ground level (OW_PLAYER_SPR_Y)
;;  to cruising altitude (OW_PLAYER_SPR_Y - AIRSHIP_ALTITUDE).
;;  Rises 1 pixel every 2 frames.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AnimateAirshipTakeoff:
    LDA #OW_PLAYER_SPR_Y
    STA tmp+10              ; Start Y at ground level

@TakeoffLoop:
    JSR AirshipTransitionFrame

    LDA framecounter
    AND #$01
    BNE @TakeoffLoop        ; Ascend once every 2 frames

    DEC tmp+10              ; Move up 1 pixel
    LDA tmp+10
    CMP #(OW_PLAYER_SPR_Y - AIRSHIP_ALTITUDE)
    BCS @TakeoffLoop        ; Loop until Y < (OW_PLAYER_SPR_Y - AIRSHIP_ALTITUDE)

    LDA #(OW_PLAYER_SPR_Y - AIRSHIP_ALTITUDE)
    STA shadow_spr_y + 0
    STA shadow_spr_y + 1
    LDA #1                  ; East (RIGHT)
    STA facing
    JSR UpdatePlayerMapmanPose
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  AnimateAirshipLanding  [$E1C2]
;;
;;  Animates the airship descending from cruising altitude
;;  down to ground level (OW_PLAYER_SPR_Y).
;;  Lowers 1 pixel every 2 frames.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AnimateAirshipLanding:
    LDA #(OW_PLAYER_SPR_Y - AIRSHIP_ALTITUDE)
    STA tmp+10              ; Start Y at cruising altitude

@LandingLoop:
    JSR AirshipTransitionFrame

    LDA framecounter
    AND #$01
    BNE @LandingLoop        ; Descend once every 2 frames

    INC tmp+10              ; Move down 1 pixel
    LDA tmp+10
    CMP #OW_PLAYER_SPR_Y
    BCC @LandingLoop        ; Loop until Y >= OW_PLAYER_SPR_Y

    LDA #OW_PLAYER_SPR_Y
    STA shadow_spr_y + 0
    STA shadow_spr_y + 1
    LDA #1                  ; East (RIGHT)
    STA facing
    JSR UpdatePlayerMapmanPose
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  AirshipTransitionFrame  [$E1E1]
;;
;;  Renders a single frame during takeoff/landing transition:
;;  - Waits for VBlank & increments framecounter
;;  - Plays music
;;  - Updates airship Y position (tmp+10)
;;  - Keeps propeller spinning
;;  - Draws ground shadow below airship (Sprite 4)
;;  - Updates VIC-II sprites
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AirshipTransitionFrame:
    JSR WaitForVBlank_L
    INC framecounter

    ; Set airship sprite Y coordinates
    LDA tmp+10
    STA shadow_spr_y + 0
    STA shadow_spr_y + 1

    ; Airship sprite X coordinates
    LDA #OW_PLAYER_SPR_X
    STA shadow_spr_x + 0
    STA shadow_spr_x + 1

    ; Update propeller animation
    JSR UpdatePlayerMapmanPose

    ; Draw ground shadow at stationary ground coords (Sprite 4)
    LDA #OW_PLAYER_SPR_X
    STA shadow_spr_x + 4
    LDA #OW_PLAYER_SPR_Y
    STA shadow_spr_y + 4
    LDA shadow_spr_msb
    AND #%11101111          ; Sprite 4 MSB = 0
    STA shadow_spr_msb

    LDA #BLOCK_AIRSHIP_SHADOW
    STA shadow_spr_ptr + 4
    LDA shadow_spr_mcm
    AND #%11101111          ; Sprite 4 = Hi-Res
    STA shadow_spr_mcm
    LDA #COLOR_BLACK
    STA shadow_spr_col + 4

    ; Enable Sprite 0, 1 (airship) and 4 (shadow), disable Sprite 5
    LDA shadow_spr_en
    AND #%11011100
    ORA #%00010011
    STA shadow_spr_en

    ; Draw parked ship if visible
    JSR DrawOWObj_Ship

    ; Flush to VIC-II
    JMP UpdateSprites



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  StartMapMove  [3879]
;;
;;    Sets move_speed based on vehicle and prepares incoming map rows.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartMapMove:
    ; Reset movement counters
    LDA #0
    STA move_ctr_x
    STA move_ctr_y

    ; Determine speed based on vehicle (mirroring NES lines 3952-3958)
    ; canoe=1, ship=2, airship=4, walking=1
    LDA vehicle
    CMP #$02
    BCC @OnFoot
    LSR A               ; canoe=1, ship=2, airship=4
    STA move_speed
    BNE @CheckDir
@OnFoot:
    LDA #$01          ; canoe/walking speed
    STA move_speed

@CheckDir:
    ; Mirror NES line 4026: Only decompress when moving vertically;
    ; zero decompression when moving horizontally!
    LDA facing
    LSR A
    BCS @Right
    LSR A
    BCS @Left
    LSR A
    BCS @Down
    LSR A
    BCS @Up
    RTS

@Right:
    ; Horizontal move: rows already in mapdata ring buffer!
    RTS

@Left:
    ; Horizontal move: rows already in mapdata ring buffer!
    RTS

@Down:
    ; Vertical move: pre-decompress incoming bottom row (row + 13) into ring buffer
    LDA ow_scroll_y
    CLC
    ADC #13
    STA mapdraw_y
    JSR LoadOWMapRow
    RTS

@Up:
    ; Vertical move: pre-decompress incoming top row (row - 1) into ring buffer
    LDA ow_scroll_y
    SEC
    SBC #1
    STA mapdraw_y
    JSR LoadOWMapRow
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Do Map Draw Job  [4048]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoMapDrawJob:
    LDA mapdraw_job
    BEQ @Done
    JSR DrawFullMap     ; Option 3: Optimized full map redraw
    LDA #0
    STA mapdraw_job
@Done:
    RTS



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
    ; Standard 40 Columns and 25 Rows on VIC-II (Multicolor, YSCROLL = 3)
    LDA #$18
    STA SCROLX
    LDA #$1B
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
    STA spr_multiplex_mode ; normal single-zone VBlank IRQ
    STA vehchgpause

.if SKIP_TO_MAP
    ; Place ship in the water inside the dock south of Coneria for testing:
    LDA #1
    STA ship_vis
    LDA #$98
    STA ship_x
    LDA #$A9
    STA ship_y

    ; Place airship on the grass east of Castle Coneria for testing:
    LDA #1
    STA airship_vis
    LDA #$9A
    STA airship_x
    LDA #$A6
    STA airship_y

    ; Enable canoe for testing:
    LDA #1
    STA has_canoe
.endif

    JSR LoadOWCHR           ; load up necessary CHR
    JSR LoadOWTilesetData   ; the tileset
    JSR LoadMapPalettes     ; palettes

    ; Pre-decompress initial 13 rows (0 to 12) into mapdata ring buffer
    LDA #0
    STA tmp+14
@InitMapLoop:
    LDA ow_scroll_y
    CLC
    ADC tmp+14
    STA mapdraw_y
    JSR LoadOWMapRow
    INC tmp+14
    LDA tmp+14
    CMP #13
    BNE @InitMapLoop

    JSR DrawFullMap         ; then draw the map
    JSR GetOWTile           ; record the tile and properties the player is standing on

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
    ; Loop for rows 0 to 11 (24 screen rows: top and bottom halves)
    LDA #0
    STA tmp+14          ; metatile row index (0..11)

@RowLoop:
    ; Get pointer to decompressed row in mapdata ($7000 + (row & $0F) * 256)
    LDA ow_scroll_y
    CLC
    ADC tmp+14
    AND #$0F
    ORA #>mapdata
    STA tmp+9
    LDA #<mapdata
    STA tmp+8

    ; Calculate Screen RAM row pointers & Color RAM row pointers
    ; top screen row = tmp+14 * 2
    LDA tmp+14
    ASL A
    TAX
    LDA lut_ScreenRowLo, X
    STA tmp+0           ; scr_top low
    STA tmp+2           ; col_top low
    LDA lut_ScreenRowHi, X
    STA tmp+1           ; scr_top high ($40..$43)
    CLC
    ADC #$98
    STA tmp+3           ; col_top high ($D8..$DB)

    INX
    LDA lut_ScreenRowLo, X
    STA tmp+4           ; scr_bot low
    STA tmp+6           ; col_bot low
    LDA lut_ScreenRowHi, X
    STA tmp+5           ; scr_bot high ($40..$43)
    CLC
    ADC #$98
    STA tmp+7           ; col_bot high ($D8..$DB)

    ; Plot 20 metatiles (40 columns) across top and bottom rows
    LDA #0
    STA tmp+10          ; tmp+10 = screen column index (0, 2, 4, ... 38)
    LDA ow_scroll_x
    STA tmp+11          ; tmp+11 = current world X

@ColLoop:
    LDY tmp+11
    LDA (tmp+8), Y      ; A = metatile ID (0..127)
    TAX                 ; X = metatile ID

    LDY tmp+10          ; Y = screen column
    ; Write Color RAM for all 4 cells (top-left, top-right, bot-left, bot-right)
    LDA lut_OWMetatileColors, X
    STA (tmp+2), Y      ; col_top left
    STA (tmp+6), Y      ; col_bot left
    LDA tsa_ul, X
    STA (tmp+0), Y      ; scr_top left
    LDA tsa_dl, X
    STA (tmp+4), Y      ; scr_bot left

    INY
    LDA lut_OWMetatileColors, X
    STA (tmp+2), Y      ; col_top right
    STA (tmp+6), Y      ; col_bot right
    LDA tsa_ur, X
    STA (tmp+0), Y      ; scr_top right
    LDA tsa_dr, X
    STA (tmp+4), Y      ; scr_bot right

    INY
    STY tmp+10
    INC tmp+11          ; next world X
    CPY #40
    BNE @ColLoop

    INC tmp+14
    LDA tmp+14
    CMP #12             ; rows 0..11 done?
    BNE @RowLoop

    ; Now draw row 12 (screen row 24: top half only!)
    LDA ow_scroll_y
    CLC
    ADC #12
    AND #$0F
    ORA #>mapdata
    STA tmp+9
    LDA #<mapdata
    STA tmp+8

    LDX #24
    LDA lut_ScreenRowLo, X
    STA tmp+0
    STA tmp+2
    LDA lut_ScreenRowHi, X
    STA tmp+1
    CLC
    ADC #$98
    STA tmp+3

    LDA #0
    STA tmp+10
    LDA ow_scroll_x
    STA tmp+11

@LastRowLoop:
    LDY tmp+11
    LDA (tmp+8), Y
    TAX

    LDY tmp+10
    LDA lut_OWMetatileColors, X
    STA (tmp+2), Y
    LDA tsa_ul, X
    STA (tmp+0), Y
    INY

    LDA lut_OWMetatileColors, X
    STA (tmp+2), Y
    LDA tsa_ur, X
    STA (tmp+0), Y
    INY

    STY tmp+10
    INC tmp+11
    CPY #40
    BNE @LastRowLoop

    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_OWMetatileColors
;;
;;  Lookup table mapping each of the 128 Overworld metatile IDs ($00-$7F)
;;  to its MultiColor Color RAM nybble ($08-$0F with bit 3 set).
;;  Selecting color by metatile type resolves the bug where shared 8x8 character
;;  tiles between river/lake water and sand caused desert sands to appear blue.
;;
;;  Color Mapping by Metatile Type:
;;    $09 (White):       Mountains, Castles, Towns, Buildings, Docks
;;    $0D (Green):       Forests, Woods, Grass terrain
;;    $0E (Blue):        Water, Ocean, Rivers, Lakes, Waterfall
;;    $0F (Yellow):      Desert, Sand, Oasis, Mirage Tower
;;    $0A (Brown):       Bridges / dirt tracks
;;    $0B (Cyan):        Marsh / Swamp
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_OWMetatileColors:
    .byte $0D, $09, $09, $0D, $0D, $0D, $0E, $0E, $0E, $09, $09, $09, $09, $0F, $09, $09  ; $00-$0F
    .byte $09, $09, $09, $0D, $0D, $0D, $0E, $0E, $0E, $09, $09, $09, $09, $0F, $0F, $09  ; $10-$1F
    .byte $09, $09, $09, $0D, $0D, $0D, $0E, $0E, $0E, $09, $09, $09, $09, $09, $09, $09  ; $20-$2F
    .byte $09, $09, $09, $09, $09, $09, $0F, $0F, $09, $09, $09, $09, $09, $09, $09, $09  ; $30-$3F
    .byte $0E, $0E, $0F, $0F, $0E, $0F, $0E, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $40-$4F
    .byte $0E, $0E, $0F, $0F, $0A, $0B, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $50-$5F
    .byte $0A, $0A, $0B, $0B, $0F, $0F, $0D, $0D, $0D, $0D, $0D, $09, $0D, $09, $0D, $09  ; $60-$6F
    .byte $0A, $0A, $0B, $0B, $0F, $0F, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09  ; $70-$7F


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_TownCharColors
;;
;;  Lookup table mapping each of the 128 Town character tile IDs ($00-$7F)
;;  to its MultiColor Color RAM nybble ($08-$0F with bit 3 set to 1).
;;  Derived directly from res/maps/town/towncolor.png.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_TownCharColors:
    .byte $08, $0A, $08, $09, $08, $08, $09, $09, $09, $08, $08, $08, $08, $08, $08, $0B
    .byte $08, $0A, $08, $09, $08, $08, $09, $09, $09, $08, $08, $08, $08, $08, $08, $08
    .byte $08, $08, $0B, $0B, $08, $08, $0F, $08, $08, $08, $09, $09, $08, $08, $08, $08
    .byte $08, $08, $0B, $0B, $08, $08, $0A, $0A, $08, $08, $0F, $08, $08, $08, $08, $08
    .byte $0B, $0B, $09, $09, $08, $09, $09, $09, $09, $08, $08, $08, $08, $0B, $08, $08
    .byte $0B, $0B, $09, $09, $08, $08, $08, $0F, $08, $08, $08, $08, $08, $0B, $08, $08
    .byte $0B, $0B, $08, $08, $08, $08, $09, $08, $08, $08, $08, $08, $08, $08, $08, $08
    .byte $0B, $0B, $08, $08, $08, $08, $09, $09, $08, $08, $08, $08, $08, $08, $08, $08



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EnterCorneliaTown
;;
;;  Prepares and runs the town loop for the first town (Cornelia).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnterCorneliaTown:
    ; 1. Save overworld scroll position
    LDA ow_scroll_x
    STA saved_ow_scroll_x
    LDA ow_scroll_y
    STA saved_ow_scroll_y

    ; 2. Initialize map and movement flags
    LDA #1
    STA mapflags                ; Bit 0 = standard map
    LDA #0
    STA move_speed
    STA move_ctr_x
    STA move_ctr_y
    STA town_exit_flag
    STA joy_a
    STA joy_b
    STA joy_start
    STA joy_select

    ; 3. Set initial scroll position for Cornelia
    ; Entry coords: X = 16, Y = 23 (lut_EntrTele_X[1], lut_EntrTele_Y[1])
    ; Screen center is at (9, 6), so sm_scroll = entry_coord - screen_center
    LDA #16 - OW_PLAYER_METATILE_X  ; 16 - 9 = 7
    STA sm_scroll_x
    LDA #23 - OW_PLAYER_METATILE_Y  ; 23 - 6 = 17 ($11)
    STA sm_scroll_y

    LDA #UP
    STA facing                  ; Face into town

    ; 4. Load Town Map, Tileset, CHR and Colors
    JSR LoadTownMap
    JSR LoadTownTilesetData
    JSR LoadTownCHR
    JSR DrawTownPalette
    JSR SetOWScroll

    ; 5. Position player sprite at screen center
    LDA #OW_PLAYER_SPR_X
    STA shadow_spr_x + 0
    STA shadow_spr_x + 1
    LDA #OW_PLAYER_SPR_Y
    STA shadow_spr_y + 0
    STA shadow_spr_y + 1
    LDA #%00000011             ; Enable sprites 0 & 1 only (outline + base)
    STA shadow_spr_en
    STA SPENA

    ; 6. Start town music ($47)
    LDA #$47
    STA music_track

    ; 7. Initial draw of the town screen
    JSR DrawStandardMap
    JSR UpdatePlayerMapmanPose
    JSR UpdateSprites

CorneliaTownLoop:
    JSR UpdateJoy_L
    JSR TownMovement

    LDA town_exit_flag
    BNE @ExitTown

    LDA move_speed
    BNE :+
      JSR ProcessTownInput
:   JSR WaitForVBlank_L
    INC framecounter
    JSR DrawPlayerMapmanSprite
    JSR UpdateSprites
    JMP CorneliaTownLoop

@ExitTown:
    LDA #0
    STA mapflags
    STA tileprop
    STA tileprop+1
    LDA saved_ow_scroll_x
    STA ow_scroll_x
    LDA saved_ow_scroll_y
    CLC
    ADC #1                      ; Return 1 tile south of Cornelia
    STA ow_scroll_y
    LDA #DOWN
    STA facing
    JMP DoOverworld



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ProcessTownInput
;;
;;  Processes joypad inputs inside town.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessTownInput:
    LDA joy_start
    BEQ @NoStart
    LDA #0
    STA joy_start
    LDA #BANK_MENUS
    JSR SwapPRG_L
    JSR EnterMainMenu
    ; Re-enter town screen after menu closes
    JSR LoadTownCHR
    JSR DrawTownPalette
    JSR DrawStandardMap
    LDA #$47
    STA music_track
    RTS

@NoStart:
    LDA joy_select
    BEQ @NoSelect
    LDA #0
    STA joy_select
    LDA #BANK_MENUS
    JSR SwapPRG_L
    JSR EnterLineupMenu
    ; Re-enter town screen after formation menu closes
    JSR LoadTownCHR
    JSR DrawTownPalette
    JSR DrawStandardMap
    LDA #$47
    STA music_track
    RTS

@NoSelect:
    LDA joy
    AND #(RIGHT | LEFT | DOWN | UP)
    BEQ @Exit

    LDA joy
    AND #RIGHT
    BNE @SetRight
    LDA joy
    AND #LEFT
    BNE @SetLeft
    LDA joy
    AND #DOWN
    BNE @SetDown
    LDA #UP
    BNE @SetFacing
@SetRight:
    LDA #RIGHT
    BNE @SetFacing
@SetLeft:
    LDA #LEFT
    BNE @SetFacing
@SetDown:
    LDA #DOWN
@SetFacing:
    STA facing

    JSR SMCanMove
    BCS @Exit

    LDA #$01                    ; Walking speed
    STA move_speed
    LDA #$00
    STA move_ctr_x
    STA move_ctr_y
@Exit:
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TownMovement
;;
;;  Updates player position and animation when moving between tiles in town.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TownMovement:
    LDA move_speed
    BEQ @Exit

    LDA facing
    LSR A
    BCS @MoveRight
    LSR A
    BCS @MoveLeft
    LSR A
    BCS @MoveDown
    LSR A
    BCS @MoveUp
@Exit:
    RTS

@MoveRight:
    LDA move_ctr_x
    CLC
    ADC move_speed
    STA move_ctr_x
    CMP #16
    BCC @Exit
    INC sm_scroll_x
    LDA sm_scroll_x
    AND #$3F
    STA sm_scroll_x
    JMP @StepDone

@MoveLeft:
    LDA move_ctr_x
    CLC
    ADC move_speed
    STA move_ctr_x
    CMP #16
    BCC @Exit
    DEC sm_scroll_x
    LDA sm_scroll_x
    AND #$3F
    STA sm_scroll_x
    JMP @StepDone

@MoveDown:
    LDA move_ctr_y
    CLC
    ADC move_speed
    STA move_ctr_y
    CMP #16
    BCC @Exit
    INC sm_scroll_y
    LDA sm_scroll_y
    AND #$3F
    STA sm_scroll_y
    JMP @StepDone

@MoveUp:
    LDA move_ctr_y
    CLC
    ADC move_speed
    STA move_ctr_y
    CMP #16
    BCC @Exit
    DEC sm_scroll_y
    LDA sm_scroll_y
    AND #$3F
    STA sm_scroll_y
    JMP @StepDone

@StepDone:
    LDA #0
    STA move_ctr_x
    STA move_ctr_y
    STA move_speed

    JSR DrawStandardMap

    ; Check if stepped on exit tile
    LDA sm_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    AND #$3F
    STA tmp+10
    LDA sm_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    AND #$3F
    TAX

    TXA
    LSR A
    LSR A
    ORA #>mapdata
    STA tmp+9
    TXA
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA tmp+8

    LDY tmp+10
    LDA (tmp+8), Y
    CMP #$47                  ; Cornelia town exit border tile
    BEQ @TriggerExit
    ASL A
    TAX
    LDA tileset_prop, X
    AND #TP_TELE_WARP         ; $40 / $C0
    BNE @TriggerExit
    RTS

@TriggerExit:
    LDA #1
    STA town_exit_flag
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  SMCanMove
;;
;;  Checks collision against tileset properties for the target tile in town.
;;  Bit 0 of tileset_prop is NoMove (solid tile).
;;
;;  OUT: C clear = passable
;;       C set   = blocked
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SMCanMove:
    LDA facing
    LSR A
    BCS @Right
    LSR A
    BCS @Left
    LSR A
    BCS @Down

@Up:
    LDA sm_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA tmp+10
    LDA sm_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y - 1
    STA tmp+11
    JMP @CheckTile

@Down:
    LDA sm_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X
    STA tmp+10
    LDA sm_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y + 1
    STA tmp+11
    JMP @CheckTile

@Right:
    LDA sm_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X + 1
    STA tmp+10
    LDA sm_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    STA tmp+11
    JMP @CheckTile

@Left:
    LDA sm_scroll_x
    CLC
    ADC #OW_PLAYER_METATILE_X - 1
    STA tmp+10
    LDA sm_scroll_y
    CLC
    ADC #OW_PLAYER_METATILE_Y
    STA tmp+11

@CheckTile:
    LDA tmp+10
    AND #$3F
    STA tmp+10
    LDA tmp+11
    AND #$3F
    TAX

    TXA
    LSR A
    LSR A
    ORA #>mapdata
    STA tmp+9
    TXA
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA tmp+8

    LDY tmp+10
    LDA (tmp+8), Y
    ASL A
    TAX
    LDA tileset_prop, X
    AND #$01                  ; Solid/NoMove check
    BNE @Blocked
    CLC
    RTS

@Blocked:
    SEC
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LoadTownMap
;;
;;  Decompresses the Cornelia town map (Map 0) from Bank 4 into mapdata ($7000).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadTownMap:
    LDA #BANK_STANDARDMAPS
    JSR SwapPRG_L

    LDA lut_SMPtrTbl
    STA tmp
    LDA lut_SMPtrTbl + 1
    AND #$3F
    ORA #$80
    STA tmp+1

    LDA #<mapdata
    STA tmp+2
    LDA #>mapdata
    STA tmp+3

    LDA #BANK_STANDARDMAPS
    STA tmp+5
    JSR DecompressMap

    ; Clear VIC Bank 1 idle-state fetch byte ($7FFF)
    LDA #0
    STA $7FFF
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LoadTownTilesetData
;;
;;  Loads properties, TSA, and attributes for Town Tileset 0 into RAM ($0400).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadTownTilesetData:
    LDA #BANK_SMINFO
    JSR SwapPRG_L

    LDX #0
:   LDA lut_SMTilesetProp, X
    STA tileset_prop, X
    INX
    BNE :-

    LDX #0
:   LDA lut_SMTilesetTSA, X
    STA tsa_ul, X
    LDA lut_SMTilesetTSA + 256, X
    STA tsa_ul + 256, X
    INX
    BNE :-

    LDX #0
:   LDA lut_SMTilesetAttr, X
    STA tsa_attr, X
    INX
    CPX #128
    BNE :-
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LoadTownCHR
;;
;;  Loads town charset (1024 bytes = 128 characters 0-127) from Bank 3
;;  into C64 VIC-II Character Memory at $4800-$4BFF.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadTownCHR:
    LDA #BANK_TILESETCHR
    JSR SwapPRG_L

    LDA #<lut_TownCHR
    STA tmp
    LDA #>lut_TownCHR
    STA tmp+1

    LDX #$04
    LDA #$00
    JSR CHRLoadToA
    JMP LoadMenuCHR



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawTownPalette
;;
;;  Sets the background and border colors for the town screen.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawTownPalette:
    LDA #COLOR_BLACK
    STA EXTCOL
    LDA #COLOR_GREEN
    STA BGCOL0
    LDA #COLOR_DARKGREY
    STA BGCOL1
    LDA #COLOR_LIGHTGREY
    STA BGCOL2
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawStandardMap
;;
;;  Renders the 40x25 standard map display from mapdata ($7000..$7FFF)
;;  around (sm_scroll_x, sm_scroll_y) using town TSA tiles and lut_TownCharColors.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawStandardMap:
    LDX #0
@ScreenRowLoop:
    STX tmp+15

    ; 1. Calculate metatile row and half
    TXA
    LSR A                         ; C = half (0 = top, 1 = bottom), A = metatile row offset (0..12)
    PHP                           ; save Carry (half) on stack
    CLC
    ADC sm_scroll_y               ; A = world metatile row
    AND #$3F                      ; 64 rows (0..63)
    TAX                           ; X = row (0..63)

    ; Calculate row pointer in mapdata: $7000 + X * 64
    TXA
    LSR A
    LSR A
    ORA #>mapdata
    STA tmp+9                     ; High byte
    TXA
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA tmp+8                     ; Low byte: (tmp+8) = mapdata row pointer

    ; 2. Screen RAM & Color RAM row pointers for screen row tmp+15
    LDX tmp+15
    LDA lut_ScreenRowLo, X
    STA tmp+0                     ; Screen RAM low
    STA tmp+2                     ; Color RAM low
    LDA lut_ScreenRowHi, X
    STA tmp+1                     ; Screen RAM high ($40..$43)
    CLC
    ADC #$98                      ; $D800 - $4000 = +$9800
    STA tmp+3                     ; Color RAM high ($D8..$DB)

    PLP
    BCS @DrawBotHalf

@DrawTopHalf:
    LDX #0
@TopColLoop:
    TXA
    CLC
    ADC sm_scroll_x
    AND #$3F                      ; World metatile column (0..63)
    TAY
    LDA (tmp+8), Y                ; Metatile ID from mapdata
    TAY

    LDA tsa_ul, Y
    PHA
    LDA tsa_ur, Y
    STA tmp+14

    TXA
    ASL A
    TAY

    PLA
    STA (tmp+0), Y                ; Write to Screen RAM
    TAX                           ; X = Left char
    LDA lut_TownCharColors, X
    STA (tmp+2), Y                ; Write to Color RAM

    INY
    LDA tmp+14
    STA (tmp+0), Y                ; Write to Screen RAM
    TAX                           ; X = Right char
    LDA lut_TownCharColors, X
    STA (tmp+2), Y                ; Write to Color RAM

    TYA
    LSR A
    TAX
    INX
    CPX #20
    BNE @TopColLoop
    JMP @NextScreenRow

@DrawBotHalf:
    LDX #0
@BotColLoop:
    TXA
    CLC
    ADC sm_scroll_x
    AND #$3F                      ; World metatile column (0..63)
    TAY
    LDA (tmp+8), Y                ; Metatile ID from mapdata
    TAY

    LDA tsa_dl, Y
    PHA
    LDA tsa_dr, Y
    STA tmp+14

    TXA
    ASL A
    TAY

    PLA
    STA (tmp+0), Y                ; Write to Screen RAM
    TAX                           ; X = Left char
    LDA lut_TownCharColors, X
    STA (tmp+2), Y                ; Write to Color RAM

    INY
    LDA tmp+14
    STA (tmp+0), Y                ; Write to Screen RAM
    TAX                           ; X = Right char
    LDA lut_TownCharColors, X
    STA (tmp+2), Y                ; Write to Color RAM

    TYA
    LSR A
    TAX
    INX
    CPX #20
    BNE @BotColLoop

@NextScreenRow:
    LDX tmp+15
    INX
    CPX #25
    BEQ @Done
    JMP @ScreenRowLoop
@Done:
    RTS



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

    ; Initialize color_dest = ppu_dest + ($D800 - $4000)
    LDA ppu_dest
    STA color_dest
    LDA ppu_dest+1
    CLC
    ADC #>($D800 - $4000)
    STA color_dest+1

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
    LDA text_color
    CMP #$FF
    BEQ :+
    LDA #COLOR_WHITE
    STA (color_dest), Y
:   INC ppu_dest
    BNE :+
    INC ppu_dest+1
:   INC color_dest
    BNE :+
    INC color_dest+1
:
    LDA lut_DTE2, X               ; Second character in DTE pair

@NoDTE:
    LDY #0
    STA (ppu_dest), Y
    LDA text_color
    CMP #$FF
    BEQ :+
    LDA #COLOR_WHITE
    STA (color_dest), Y
:   INC ppu_dest
    BNE :+
    INC ppu_dest+1
:   INC color_dest
    BNE :+
    INC color_dest+1
:
    JMP @Draw_NoStall

@ControlCode:
    CMP #$01                      ; $01 = Double line break
    BEQ @DoubleLineBreak
    CMP #$05                      ; $05 = Single line break
    BEQ @SingleLineBreak
    CMP #$02                      ; $02 = Item / class name
    BEQ @Code_02
    CMP #$03                      ; $03 = Item price
    BEQ @Code_03
    CMP #$04                      ; $04 = Current gold
    BNE :+
    JMP @Code_04
:   CMP #$10
    BCC @SingleLineBreak          ; < $10 defaults to line break
    CMP #$14
    BCS @SingleLineBreak          ; >= $14 defaults to single line break
    JMP @Code_10to13              ; $10-$13 = Character stat (characters 0-3)

@DoubleLineBreak:
    INC dest_y
    INC dest_y
    JSR CoordToNTAddr
    LDA ppu_dest
    STA color_dest
    LDA ppu_dest+1
    CLC
    ADC #>($D800 - $4000)
    STA color_dest+1
    JMP @Draw_NoStall

@SingleLineBreak:
    INC dest_y
    JSR CoordToNTAddr
    LDA ppu_dest
    STA color_dest
    LDA ppu_dest+1
    CLC
    ADC #>($D800 - $4000)
    STA color_dest+1
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

@Code_03:
    LDY #0
    LDA (text_ptr), Y             ; Fetch item ID from string
    INC text_ptr
    BNE :+
    INC text_ptr+1
:   JSR @Save
    TAX
    LDA #BANK_MENUS
    STA cur_bank
    JSR SwapPRG_L
    TXA
    JSR PrintPrice
    JSR @Draw_NoStall
    JMP @Restore

@Code_04:
    JSR @Save
    LDA #BANK_MENUS
    STA cur_bank
    JSR SwapPRG_L
    JSR PrintGold
    JSR @Draw_NoStall
    JMP @Restore

@Code_10to13:
    ; Character index: $00, $40, $80, $C0
    ROR A
    ROR A
    ROR A
    AND #$C0
    STA char_index

    LDY #0
    LDA (text_ptr), Y             ; Fetch stat code from string
    INC text_ptr
    BNE :+
    INC text_ptr+1
:
    CMP #$00                      ; Stat Code $00 = Character Name
    BNE @StatNot00

    ; Stat 0: Copy 4-byte name to format_buf-4 .. format_buf-1
    LDX char_index
    LDA ch_name, X
    STA format_buf-4
    LDA ch_name+1, X
    STA format_buf-3
    LDA ch_name+2, X
    STA format_buf-2
    LDA ch_name+3, X
    STA format_buf-1
    LDA #0
    STA format_buf

    JSR @Save
    LDA #<(format_buf-4)
    STA text_ptr
    LDA #>(format_buf-4)
    STA text_ptr+1
    JSR @Draw_NoStall
    JMP @Restore

@StatNot00:
    CMP #$01                      ; Stat Code $01 = Class Name
    BNE @StatNot01
    LDX char_index
    LDA ch_class, X
    CLC
    ADC #$F0
    JMP @DrawItem

@StatNot01:
    CMP #$02                      ; Stat Code $02 = Ailment blurb ("HP", "ST", "PO", etc.)
    BNE @StatNot02
    LDX char_index
    LDA ch_ailments, X
    CLC
    ADC #$FC
    JMP @DrawItem

@StatNot02:
    CMP #$0C
    BCC @StatPrintStat            ; $03-$0B: PrintCharStat

    CMP #$14
    BCC @StatCode_0Cto13          ; $0C-$13: Weapons/Armor

    CMP #$2C
    BCC @StatCode_14to2B          ; $14-$2B: Spells

@StatPrintStat:
    ; Stat codes $03-$0B, and $2C-$FF: handled by PrintCharStat in BANK_MENUS
    TAX                           ; Stat code in X
    JSR @Save
    LDA #BANK_MENUS
    STA cur_bank
    JSR SwapPRG_L
    TXA
    JSR PrintCharStat
    JSR @Draw_NoStall
    JMP @Restore

@StatCode_0Cto13:
    ; Stat codes $0C-$0F (Weapons), $10-$13 (Armor)
    JMP @Draw_NoStall

@StatCode_14to2B:
    ; Magic spell name:
    SEC
    SBC #$14
    TAX
    LDA @lut_MagicStat, X
    CLC
    ADC char_index
    TAX
    ASL A
    AND #$38
    CLC
    ADC #$AF
    STA tmp
    LDA ch_spells, X
    BEQ @SpellEmpty
    CLC
    ADC tmp
    JMP @DrawItem
@SpellEmpty:
    ; Draw 4 spaces ($FF) so column alignment is maintained
    LDX #4
:   LDY #0
    LDA #$FF
    STA (ppu_dest), Y
    LDA #COLOR_WHITE
    STA (color_dest), Y
    INC ppu_dest
    BNE :+
    INC ppu_dest+1
:   INC color_dest
    BNE :+
    INC color_dest+1
:   DEX
    BNE :---
    JMP @Draw_NoStall

@lut_MagicStat:
    .BYTE $00,$01,$02, $04,$05,$06, $08,$09,$0A, $0C,$0D,$0E
    .BYTE $10,$11,$12, $14,$15,$16, $18,$19,$1A, $1C,$1D,$1E

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  LoadPrice  [10573]
;;
;;  Loads item price into tmp (low) and tmp+1 (high), tmp+2 = 0
;;  IN:  A = item ID
;;  OUT: tmp, tmp+1 = price
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadPrice:
    ASL A        ; double item index (2 bytes per price)
    STA tmp+2    ; store low byte in tmp+2 ($12)

    LDA #>(lut_ItemPrices>>1)  ; high byte of pointer, right-shifted by 1
    ROL A                      ; rotate left by 1 to catch carry from above ASL
    STA tmp+3                  ; store high byte in tmp+3 ($13)

    LDA #BANK_ITEMPRICES
    JSR SwapPRG_L  ; swap to bank D (for item prices)

    LDY #0         ; zero Y (our source index)
    LDA (tmp+2), Y ; get low byte of price
    STA tmp
    INY
    LDA (tmp+2), Y ; and high byte
    STA tmp+1

    LDA #0
    STA tmp+2       ; 3rd byte is always 0 (no item costs more than 65535)

    LDA #BANK_MENUS ; swap back to bank E
    JMP SwapPRG_L   ; and return


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
    ADC #$01          ; and increment it by 1 (top inner row)
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  EraseBox  [7994]
;;
;;  Erases a box on C64 by filling it with black tiles ($00) and black color ($00).
;;
;;  IN:  box_x, box_y, box_wd, box_ht
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EraseBox:
    lda box_y
    sta dest_y
@RowLoop:
    lda box_x
    sta dest_x
    jsr CoordToNTAddr

    lda ppu_dest
    sta color_dest
    lda ppu_dest+1
    clc
    adc #>($D800 - $4000)
    sta color_dest+1

    ldy #0
    lda #$00
@ColLoop:
    sta (ppu_dest), y
    lda #COLOR_BLACK
    sta (color_dest), y
    lda #$00
    iny
    cpy box_wd
    bne @ColLoop

    inc dest_y
    lda dest_y
    sec
    sbc box_y
    cmp box_ht
    bne @RowLoop
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Menu Conditional Stall  [7962]
;;
;;    Conditionally stalls (waits) a frame when menustall is nonzero.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuCondStall:
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
    JSR LoadParkedVehicleSprites
    JSR LoadPlayerMapmanSprites
    RTS


LoadParkedVehicleSprites:
    LDA #BANK_VEHICLES
    JSR SwapPRG_L

    ; 1. Copy Sprite 8 (Ship outline, 64 bytes) to $5C00-$5C3F
    LDX #64
:   LDA lut_VehicleSprites + 512 - 1, X
    STA $5C00 - 1, X
    DEX
    BNE :-

    ; 2. Copy Sprite 9 (Ship base, 64 bytes) to $5C40-$5C7F, remapping bit pair %01 -> %10
    ; so that sails use SP3COL (individual color) instead of SPMC0 (shared with hero)
    LDX #63             ; 63 bitmap bytes (byte 63 is mode byte)
@RemapShip:
    LDA lut_VehicleSprites + 512 + 64 - 1, X
    STA tmp
    LSR A
    AND #$55
    AND tmp
    STA tmp+1           ; tmp+1 = new_even (bits 6, 4, 2, 0)
    LDA tmp
    ASL A
    AND #$AA
    ORA tmp
    AND #$AA            ; A = new_odd (bits 7, 5, 3, 1)
    ORA tmp+1           ; A = new_odd | new_even
    STA $5C40 - 1, X
    DEX
    BNE @RemapShip

    ; Copy byte 63 (mode byte)
    LDA lut_VehicleSprites + 512 + 64 + 63
    STA $5C40 + 63

    ; 3. Copy Sprite 0 (Airship shadow, 64 bytes) to $5C80-$5CBF
    LDX #64
:   LDA lut_VehicleSprites - 1, X
    STA $5C80 - 1, X
    DEX
    BNE :-

    ; 4. Copy Sprite 28 (Airship Front outline, 64 bytes) to $5CC0-$5CFF
    LDX #64
:   LDA lut_VehicleSprites + 1792 - 1, X
    STA $5CC0 - 1, X
    DEX
    BNE :-

    ; 5. Copy Sprite 29 (Airship Front base, 64 bytes) to $5D00-$5D3F, remapping %01 -> %10
    LDX #63
@RemapAirship:
    LDA lut_VehicleSprites + 1792 + 64 - 1, X
    STA tmp
    LSR A
    AND #$55
    AND tmp
    STA tmp+1
    LDA tmp
    ASL A
    AND #$AA
    ORA tmp
    AND #$AA
    ORA tmp+1
    STA $5D00 - 1, X
    DEX
    BNE @RemapAirship

    LDA lut_VehicleSprites + 1792 + 64 + 63
    STA $5D00 + 63

    ; Setup initial sprite pointers and colors for parked ship
    LDA #BLOCK_PARKED_SHIP
    STA shadow_spr_ptr + 2
    LDA #(BLOCK_PARKED_SHIP + 1)
    STA shadow_spr_ptr + 3
    LDA #COLOR_BLACK
    STA shadow_spr_col + 2
    LDA #COLOR_WHITE
    STA shadow_spr_col + 3
    RTS


; Mapmen Color and Direction LUTs
lut_MapmanColor1:
    .byte $02, $03, $03, $02, $01, $06 ; Fighter, Thief, BB, RM, WM, BM (SPMC0 - $D025)
lut_MapmanColor2:
    .byte $0A, $0A, $0A, $0A, $0A, $07 ; Peach for 0..4, Yellow for BM (SPMC1 - $D026)
lut_MapmanCustomColor:
    .byte $00, $08, $08, $01, $00, $0A ; 0=none, Thief/BB=08, RM=01, WM=none, BM=0A (SP1COL)

; Facing index (0..15) -> Base Pose (0=South, 2=North, 4=West, 6=East)
lut_FacingBasePose:
    .byte 0, 6, 4, 6, 0, 6, 4, 6, 2, 6, 4, 6, 0, 6, 4, 6
    ;     -  R  L  RL D  RD LD RLD U  RU LU RLU DU RDU LDU RLDU


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Load Player Mapman Sprites  [9710]
;;
;;  Loads 16 sprites (1,024 bytes) for the lead party member from
;;  BANK_MAPCHR ($8800 + class * 1024) into VIC-II RAM ($5800-$5BFF).
;;  Configures VIC-II sprite colors (SPMC0, SPMC1, custom color)
;;  and sets up physical Sprite 0 (outline) & Sprite 1 (base fill).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadPlayerMapmanSprites:
    LDA vehicle
    CMP #$02
    BNE :+
    JMP @LoadCanoeSprites
:   CMP #$04
    BNE :+
    JMP @LoadShipSprites
:   CMP #$08
    BNE :+
    JMP @LoadAirshipSprites
:

    ; --- Load Walking Hero Sprites ---
    LDA #BANK_MAPCHR
    JSR SwapPRG_L

    LDA ch_class            ; Lead character's class (0..11)
    CMP #6
    BCC :+
    SBC #6                  ; Map promoted classes (6..11) to base classes (0..5)
:   STA tmp                 ; tmp = class (0..5)

    ; Calculate source pointer: lut_MapmanSprites + (class * 1024)
    ; Base = $8800. Each class = 1024 bytes = 4 pages (4 * 256 bytes)
    ASL A
    ASL A                   ; class * 4
    CLC
    ADC #>lut_MapmanSprites ; $88 + (class * 4)
    STA tmp+2               ; source high byte
    LDA #<lut_MapmanSprites ; $00
    STA tmp+1               ; source low byte

    ; Destination pointer: $5800
    LDA #$00
    STA tmp+3               ; dest low byte
    LDA #$58
    STA tmp+4               ; dest high byte

    ; Copy 4 pages (1024 bytes = 16 sprites)
    LDX #4                  ; 4 pages
    LDY #0
@CopyLoop:
    LDA (tmp+1), Y
    STA (tmp+3), Y
    INY
    BNE @CopyLoop
    INC tmp+2               ; advance source page
    INC tmp+4               ; advance dest page
    DEX
    BNE @CopyLoop

    ; Setup VIC-II Sprite Colors for active leader
    LDX tmp                 ; class index (0..5)
    LDA lut_MapmanColor1, X
    STA SPMC0               ; $D025 (Shared Sprite Multicolor 0)
    LDA lut_MapmanColor2, X
    STA SPMC1               ; $D026 (Shared Sprite Multicolor 1)
    LDA lut_MapmanCustomColor, X
    STA shadow_spr_col + 1  ; Sprite 1 individual color = custom color
    STA SP1COL
    LDA #COLOR_BLACK
    STA shadow_spr_col + 0  ; Sprite 0 individual color = black (hi-res outline)
    STA SP0COL
    JMP @FinishSetup

@LoadShipSprites:
    ; --- Load Ship Sprites ---
    LDA #BANK_VEHICLES
    JSR SwapPRG_L

    ; Ship sprites in vechicles.spr start at sprite 8 (512 bytes offset = 2 pages)
    LDA #<(lut_VehicleSprites + 512)
    STA tmp+1
    LDA #>(lut_VehicleSprites + 512)
    STA tmp+2

    ; Destination pointer: $5800
    LDA #$00
    STA tmp+3
    LDA #$58
    STA tmp+4

    ; Copy 4 pages (1024 bytes = 16 sprites for 8 poses)
    LDX #4
    LDY #0
@CopyShipLoop:
    LDA (tmp+1), Y
    STA (tmp+3), Y
    INY
    BNE @CopyShipLoop
    INC tmp+2
    INC tmp+4
    DEX
    BNE @CopyShipLoop

    ; Setup VIC-II Sprite Colors for Ship
    LDA #COLOR_WHITE
    STA SPMC0               ; Shared Sprite Multicolor 0 = White (sails)
    LDA #COLOR_LIGHTRED
    STA SPMC1               ; Shared Sprite Multicolor 1 = Light Brown (hull)
    LDA #COLOR_BLACK
    STA shadow_spr_col + 0  ; Sprite 0 outline = black
    STA SP0COL
    STA shadow_spr_col + 1  ; Sprite 1 custom = black
    STA SP1COL
    JMP @FinishSetup

@LoadAirshipSprites:
    ; --- Load Airship Sprites ---
    LDA #BANK_VEHICLES
    JSR SwapPRG_L

    ; In vechicles.spr:
    ; Sprites 24..27 (offset 1536) = Rear / North poses
    ; Sprites 28..31 (offset 1792) = Front / South poses
    ; Sprites 32..35 (offset 2048) = West poses
    ; Sprites 36..39 (offset 2304) = East poses
    ; Map them into VIC-II RAM:
    ; $5800: South (Poses 0 & 1) <- Sprites 28..31 (offset 1792)
    ; $5900: North (Poses 2 & 3) <- Sprites 24..27 (offset 1536)
    ; $5A00: West  (Poses 4 & 5) <- Sprites 32..35 (offset 2048)
    ; $5B00: East  (Poses 6 & 7) <- Sprites 36..39 (offset 2304)
    LDY #0
@CopyAirshipLoop:
    LDA lut_VehicleSprites + 1792, Y
    STA $5800, Y
    LDA lut_VehicleSprites + 1536, Y
    STA $5900, Y
    LDA lut_VehicleSprites + 2048, Y
    STA $5A00, Y
    LDA lut_VehicleSprites + 2304, Y
    STA $5B00, Y
    INY
    BNE @CopyAirshipLoop

    ; Setup VIC-II Sprite Colors for Airship
    LDA #COLOR_WHITE
    STA SPMC0               ; Shared Sprite Multicolor 0 = White (fins/props)
    LDA #COLOR_LIGHTRED
    STA SPMC1               ; Shared Sprite Multicolor 1 = Light Brown (hull)
    LDA #COLOR_BLACK
    STA shadow_spr_col + 0  ; Sprite 0 outline = black
    STA SP0COL
    STA shadow_spr_col + 1  ; Sprite 1 custom = black
    STA SP1COL
    JMP @FinishSetup

@LoadCanoeSprites:
    ; --- Load Canoe Sprites ---
    LDA #BANK_VEHICLES
    JSR SwapPRG_L

    ; In vechicles.spr:
    ; Sprites 40..43 (offset 2560) = South poses
    ; Sprites 44..47 (offset 2816) = North poses
    ; Sprites 48..51 (offset 3072) = West poses
    ; Sprites 48..51 (offset 3072) = East poses
    LDY #0
@CopyCanoeLoop:
    LDA lut_VehicleSprites + 2560, Y
    STA $5800, Y
    LDA lut_VehicleSprites + 2816, Y
    STA $5900, Y
    LDA lut_VehicleSprites + 3072, Y
    STA $5A00, Y
    STA $5B00, Y
    INY
    BNE @CopyCanoeLoop

    ; Setup VIC-II Sprite Colors for Canoe
    LDA #COLOR_WHITE
    STA SPMC0               ; Shared Sprite Multicolor 0 = White (paddles / splashes)
    LDA #COLOR_LIGHTRED
    STA SPMC1               ; Shared Sprite Multicolor 1 = Light Brown (hull)
    LDA #COLOR_BLACK
    STA shadow_spr_col + 0  ; Sprite 0 outline = black
    STA SP0COL
    STA shadow_spr_col + 1  ; Sprite 1 custom = black
    STA SP1COL
    JMP @FinishSetup

@FinishSetup:
    ; Position Sprites at screen center (Metatile X = 9, Metatile Y = 6)
    LDA #OW_PLAYER_SPR_X
    STA shadow_spr_x + 0
    STA shadow_spr_x + 1

    LDA #OW_PLAYER_SPR_Y
    LDX vehicle
    CPX #$08
    BNE :+
    SEC
    SBC #AIRSHIP_ALTITUDE   ; Airship cruising altitude (32 pixels above ground)
:   STA shadow_spr_y + 0
    STA shadow_spr_y + 1
    LDA shadow_spr_msb
    AND #%11111100          ; Sprites 0 & 1 MSB = 0
    STA shadow_spr_msb

    ; Sprite modes: Sprite 0 = Hi-res (bit 0 = 0), Sprite 1 = Multicolor (bit 1 = 1)
    LDA shadow_spr_mcm
    AND #%11111100
    ORA #%00000010
    STA shadow_spr_mcm
    STA SPMC

    ; Sprite enables: Sprites 0 and 1 enabled
    LDA shadow_spr_en
    ORA #%00000011
    STA shadow_spr_en
    STA SPENA

    ; Priorities and expansions (normal size, in front of BG)
    LDA #$00
    STA shadow_spr_pri
    STA SPBGPR
    STA shadow_spr_xexp
    STA XEXP
    STA shadow_spr_yexp
    STA YEXP

    ; Update initial pose and pointers
    JSR UpdatePlayerMapmanPose
    JMP UpdateSprites


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw OW Sprites  [$E1DC]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOWSprites:
    JSR DrawPlayerMapmanSprite
    JSR DrawOWObj_Ship
    JSR DrawOWObj_Airship
    JMP UpdateSprites


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawOWObj_Ship  [$E2A0]
;;
;;  Renders the parked ship using physical Sprites 2 & 3 when
;;  player is on foot (vehicle == 1) and ship_vis != 0.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOWObj_Ship:
    LDA vehicle
    CMP #$01
    BNE @HideShip
    LDA ship_vis
    BEQ @HideShip

    ; Check X bounds: ship_x - ow_scroll_x
    LDA ship_x
    SEC
    SBC ow_scroll_x
    CMP #20              ; Visible columns: 0..19 metatiles
    BCS @HideShip
    STA tmp+4            ; tmp+4 = screen metatile X (0..19)

    ; Check Y bounds: ship_y - ow_scroll_y
    LDA ship_y
    SEC
    SBC ow_scroll_y
    CMP #13              ; Visible rows: 0..12 metatiles
    BCS @HideShip
    STA tmp+5            ; tmp+5 = screen metatile Y (0..12)

    ; Calculate Pixel X = 24 + tmp+4 * 16
    LDA tmp+4
    ASL A
    ASL A
    ASL A
    ASL A                ; tmp+4 * 16
    CLC
    ADC #24
    STA shadow_spr_x + 2
    STA shadow_spr_x + 3

    ; MSB of X: if tmp+4 >= 15 (24 + 15*16 = 264 >= 256), set bits 2 & 3
    LDA tmp+4
    CMP #15
    BCS @SetMSB
    LDA shadow_spr_msb
    AND #%11110011
    STA shadow_spr_msb
    JMP @CalcY
@SetMSB:
    LDA shadow_spr_msb
    ORA #%00001100
    STA shadow_spr_msb

@CalcY:
    ; Calculate Pixel Y = 50 + tmp+5 * 16 - 7
    LDA tmp+5
    ASL A
    ASL A
    ASL A
    ASL A                ; tmp+5 * 16
    CLC
    ADC #(50 - 7)        ; + 43
    STA shadow_spr_y + 2
    STA shadow_spr_y + 3

    ; Sprite pointers: Block 112 ($5C00) and 113 ($5C40)
    LDA #BLOCK_PARKED_SHIP
    STA shadow_spr_ptr + 2
    LDA #(BLOCK_PARKED_SHIP + 1)
    STA shadow_spr_ptr + 3

    ; Sprite modes: Sprite 2 = Hi-Res (bit 2 = 0), Sprite 3 = Multicolor (bit 3 = 1)
    LDA shadow_spr_mcm
    AND #%11111011
    ORA #%00001000
    STA shadow_spr_mcm

    ; Sprite colors: Sprite 2 = Black, Sprite 3 = White (sails)
    LDA #COLOR_BLACK
    STA shadow_spr_col + 2
    LDA #COLOR_WHITE
    STA shadow_spr_col + 3

    ; Enable Sprites 2 and 3
    LDA shadow_spr_en
    ORA #%00001100
    STA shadow_spr_en
    RTS

@HideShip:
    LDA shadow_spr_en
    AND #%11110011
    STA shadow_spr_en
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawOWObj_Airship  [$E2B8]
;;
;;  Renders either:
;;  1. The shadow below the airship (Sprite 4) when flying (vehicle == 8).
;;  2. The parked airship on the ground (Sprites 4 & 5) when airship_vis != 0
;;     and player is not in the airship (vehicle != 8).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOWObj_Airship:
    LDA vehicle
    CMP #$08
    BNE :+
    JMP @FlyingShadow
:

    ; --- Parked Airship on Ground ---
    LDA airship_vis
    BEQ @HideAirship

    ; Check X bounds: airship_x - ow_scroll_x
    LDA airship_x
    SEC
    SBC ow_scroll_x
    CMP #20              ; Visible columns: 0..19 metatiles
    BCS @HideAirship
    STA tmp+4            ; tmp+4 = screen metatile X (0..19)

    ; Check Y bounds: airship_y - ow_scroll_y
    LDA airship_y
    SEC
    SBC ow_scroll_y
    CMP #13              ; Visible rows: 0..12 metatiles
    BCS @HideAirship
    STA tmp+5            ; tmp+5 = screen metatile Y (0..12)

    ; Calculate Pixel X = 24 + tmp+4 * 16
    LDA tmp+4
    ASL A
    ASL A
    ASL A
    ASL A                ; tmp+4 * 16
    CLC
    ADC #24
    STA shadow_spr_x + 4
    STA shadow_spr_x + 5

    ; MSB of X for bits 4 & 5: if tmp+4 >= 15, set bits 4 & 5
    LDA tmp+4
    CMP #15
    BCS @SetMSB
    LDA shadow_spr_msb
    AND #%11001111
    STA shadow_spr_msb
    JMP @CalcY
@SetMSB:
    LDA shadow_spr_msb
    ORA #%00110000
    STA shadow_spr_msb

@CalcY:
    ; Calculate Pixel Y = 50 + tmp+5 * 16 - 7
    LDA tmp+5
    ASL A
    ASL A
    ASL A
    ASL A                ; tmp+5 * 16
    CLC
    ADC #(50 - 7)        ; + 43
    STA shadow_spr_y + 4
    STA shadow_spr_y + 5

    ; Sprite pointers: Block 115 ($5CC0) and 116 ($5D00)
    LDA #BLOCK_PARKED_AIRSHIP
    STA shadow_spr_ptr + 4
    LDA #(BLOCK_PARKED_AIRSHIP + 1)
    STA shadow_spr_ptr + 5

    ; Sprite modes: Sprite 4 = Hi-Res (bit 4 = 0), Sprite 5 = Multicolor (bit 5 = 1)
    LDA shadow_spr_mcm
    AND #%11101111
    ORA #%00100000
    STA shadow_spr_mcm

    ; Sprite colors: Sprite 4 = Black, Sprite 5 = White (fins/props)
    LDA #COLOR_BLACK
    STA shadow_spr_col + 4
    LDA #COLOR_WHITE
    STA shadow_spr_col + 5

    ; Enable Sprites 4 and 5
    LDA shadow_spr_en
    ORA #%00110000
    STA shadow_spr_en
    RTS

@HideAirship:
    LDA shadow_spr_en
    AND #%11001111
    STA shadow_spr_en
    RTS

@FlyingShadow:
    ; Ground shadow below flying airship at (OW_PLAYER_SPR_X, OW_PLAYER_SPR_Y)
    LDA #OW_PLAYER_SPR_X
    STA shadow_spr_x + 4
    LDA #OW_PLAYER_SPR_Y
    STA shadow_spr_y + 4
    LDA shadow_spr_msb
    AND #%11101111       ; Sprite 4 MSB = 0
    STA shadow_spr_msb

    LDA #BLOCK_AIRSHIP_SHADOW
    STA shadow_spr_ptr + 4

    ; Sprite 4 = Hi-Res Black
    LDA shadow_spr_mcm
    AND #%11101111
    STA shadow_spr_mcm
    LDA #COLOR_BLACK
    STA shadow_spr_col + 4

    ; Enable Sprite 4 (shadow), disable Sprite 5
    LDA shadow_spr_en
    AND #%11011111
    ORA #%00010000
    STA shadow_spr_en
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Draw Player Mapman Sprite / Update Pose  [$E281]
;;
;;  Calculates the current pose index (0..7) based on facing direction
;;  and walk animation counter (move_ctr_x / move_ctr_y), then sets
;;  the hardware sprite pointers for Sprite 0 (outline) & Sprite 1 (base).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawPlayerMapmanSprite:
UpdatePlayerMapmanPose:
    ; 1. Determine walk frame (0 or 1)
    LDA vehicle
    CMP #$08
    BNE @NotAirship
    LDA framecounter
    AND #$04            ; Airship propellers spin constantly (alternates every 4 frames)
    LSR A
    LSR A
    JMP @GotFrame

@NotAirship:
    LDA move_speed
    BEQ @Stationary
    LDA move_ctr_x
    ORA move_ctr_y
    AND #$08
    LSR A
    LSR A
    LSR A               ; Frame 0 (ticks 0..7) or Frame 1 (ticks 8..15)
    JMP @GotFrame
@Stationary:
    LDA #0
@GotFrame:
    ; A = anim frame (0 or 1)

    ; 2. Add base pose for facing direction
    LDX facing
    CLC
    ADC lut_FacingBasePose, X ; + 0 (South), 2 (North), 4 (West), 6 (East)
    ; A = Pose Index (0..7)

    ; 3. Compute sprite block pointers
    ASL A                      ; Pose * 2 (0, 2, 4, 6, 8, 10, 12, 14)
    CLC
    ADC #BLOCK_MAPMAN_BASE     ; 96 ($60) -> $5800
    STA shadow_spr_ptr + 0
    STA $43F8                  ; Outline sprite pointer
    CLC
    ADC #1
    STA shadow_spr_ptr + 1
    STA $43F9                  ; Base sprite pointer
    RTS


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

    LDA lut_BtlBackdropPalettes+0, X
    STA cur_pal+0
    STA BGCOL0                    ; $D021 = Background Color 0 (%00)
    LDA lut_BtlBackdropPalettes+1, X
    STA cur_pal+1
    STA BGCOL1                    ; $D022 = Background Color 1 (%01)
    LDA lut_BtlBackdropPalettes+2, X
    STA cur_pal+2
    STA BGCOL2                    ; $D023 = Background Color 2 (%10)

    ; Color 3 goes to Color RAM ($D800) and cur_pal+3
    LDA lut_BtlBackdropPalettes+3, X
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

    ; Copy Pose 0 (192 bytes = 3 sprites) for each of the 6 classes from lut_HeroSprites
    ; In lut_HeroSprites, each class has 18 sprites = 1152 ($0480) bytes.
    LDA #<lut_HeroSprites
    STA tmp
    LDA #>lut_HeroSprites
    STA tmp+1

    LDA #<$5880
    STA chr_dest
    LDA #>$5880
    STA chr_dest+1

    LDX #0                     ; 6 classes
@CopyHeroClass:
    LDY #0
@CopyPose0:
    LDA (tmp), Y
    STA (chr_dest), Y
    INY
    CPY #192                   ; 3 sprites * 64 bytes = 192 bytes
    BNE @CopyPose0

    ; Advance chr_dest by 192 bytes ($00C0)
    LDA chr_dest
    CLC
    ADC #192
    STA chr_dest
    BCC :+
    INC chr_dest+1
:
    ; Advance tmp by 1152 bytes ($0480) to next class in lut_HeroSprites
    LDA tmp
    CLC
    ADC #<$0480
    STA tmp
    LDA tmp+1
    ADC #>$0480
    STA tmp+1

    INX
    CPX #6
    BNE @CopyHeroClass

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
    php
    sei
    pha
    txa
    pha
    tsx
    lda $0102, x                ; Fetch original A (bank ID) from stack
    tax
    sta cur_bank                ; Keep cur_bank in sync with hardware bank
    lda lut_EasyFlashBanks, x   ; Lookup EasyFlash physical bank
    sta EASYFLASH_BANK          ; Perform hardware bank switch
    pla
    tax
    pla
    plp
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
    ; Check multiplexer mode:
    ;   0 = Normal single-zone VBlank IRQ
    ;   1 = Party Generation 2-zone multiplexer
    ;   2 = Main Menu 2-zone multiplexer
    lda spr_multiplex_mode
    beq @NormalIRQ
    cmp #1
    beq @PartyGen
    cmp #2
    beq @MainMenu
    jmp LineupMenu_IRQ

@PartyGen:
    jmp PartyGen_IRQ

@MainMenu:
    jmp MainMenu_IRQ

@NormalIRQ:
    ; Ensure zone tracker is clean
    lda #0
    sta spr_irq_zone

    ; Increment frame counter
    inc vblank_count

    ; Push sprites to VIC-II hardware during VBlank
    jsr UpdateSprites

    ; Update SID music playback at rock-solid 50/60 Hz
    jsr CallMusicPlay

    ; Re-arm Raster IRQ to line 0, bit 7 = 0
    lda #0
    sta RASTER
    lda SCROLY
    and #$7F
    sta SCROLY

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
    jmp @Zone1

@Zone0:
    inc vblank_count           ; Increment frame counter once per frame on VBlank
    jsr CallMusicPlay

    jsr SetupHero0
    jsr SetupHero1

    ; Common VIC-II configuration for sprites
    lda #$00
    sta MSIGX                  ; MSB 0 for all
    sta XEXP                   ; No X expansion
    sta YEXP                   ; No Y expansion
    sta SPBGPR                 ; In front of BG

    lda char_index
    cmp #$20
    bcs @TopNoCursor

    ; Cursor is in Top Half (Hero 0 or Hero 1)
    jsr SetupCursor
    lda #$FF                   ; Enable all 8 sprites (Heroes 0-5 + Cursor 6-7)
    sta SPENA
    jmp @ArmZone1

@TopNoCursor:
    lda #%00111111             ; Enable Sprites 0-5 (heroes only)
    sta SPENA
    lda #$00
    sta SPMC

@ArmZone1:
    ; Arm next split at Scanline 145 for Bottom Half
    lda #145
    sta RASTER
    lda SCROLY
    and #$7F                   ; Raster bit 8 = 0
    sta SCROLY
    lda #1
    sta spr_irq_zone
    jmp $FEBC

@Zone1:
    ; Scanline 145: Bottom Half (Hero 2 & 3)
    jsr SetupHero2
    jsr SetupHero3

    lda char_index
    cmp #$20
    bcc @BottomNoCursor

    ; Cursor is in Bottom Half (Hero 2 or Hero 3)
    jsr SetupCursor
    lda #$FF                   ; Enable all 8 sprites
    sta SPENA
    jmp @ArmZone0

@BottomNoCursor:
    lda #%00111111             ; Enable Sprites 0-5 (heroes only)
    sta SPENA
    lda #$00
    sta SPMC

@ArmZone0:
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
    sta SP6X
    sta SP7X
    lda ptygen_curs_y, x
    sta SP6Y
    sta SP7Y
    lda #BLOCK_FINGER_OVERLAY   ; Block 97 (Hi-Res Overlay, White)
    sta $43FE                  ; Sprite 6 pointer
    lda #COLOR_WHITE
    sta SP6COL
    lda #BLOCK_FINGER_BASE      ; Block 96 (Multicolor Base, White + Greys)
    sta $43FF                  ; Sprite 7 pointer
    lda #COLOR_WHITE
    sta SP7COL
    lda #%10000000             ; Sprite 7 Multicolor, Sprite 6 Hi-Res
    sta SPMC
    rts

SetupHero0:
    ldx ptygen+0
    cpx #6
    bcc :+
    ldx #0
:   lda lut_ClassSpriteBase, x
    sta $43F8                  ; Sprite 0 pointer (Layer 0)
    clc
    adc #1
    sta $43F9                  ; Sprite 1 pointer (Layer 1)
    adc #1
    sta $43FA                  ; Sprite 2 pointer (Layer 2)

    ldy lut_ClassColorOffset, x

    lda lut_ClassColors + 0, y
    sta SP0COL
    lda lut_ClassColors + 1, y
    sta SP1COL
    lda lut_ClassColors + 2, y
    sta SP2COL

    lda #120
    sta SP0X
    sta SP1X
    sta SP2X

    lda #94
    sta SP0Y
    sta SP1Y
    sta SP2Y
    rts

SetupHero1:
    ldx ptygen+$10
    cpx #6
    bcc :+
    ldx #0
:   lda lut_ClassSpriteBase, x
    sta $43FB                  ; Sprite 3 pointer (Layer 0)
    clc
    adc #1
    sta $43FC                  ; Sprite 4 pointer (Layer 1)
    adc #1
    sta $43FD                  ; Sprite 5 pointer (Layer 2)

    ldy lut_ClassColorOffset, x

    lda lut_ClassColors + 0, y
    sta SP3COL
    lda lut_ClassColors + 1, y
    sta SP4COL
    lda lut_ClassColors + 2, y
    sta SP5COL

    lda #232
    sta SP3X
    sta SP4X
    sta SP5X

    lda #94
    sta SP3Y
    sta SP4Y
    sta SP5Y
    rts

SetupHero2:
    ldx ptygen+$20
    cpx #6
    bcc :+
    ldx #0
:   lda lut_ClassSpriteBase, x
    sta $43F8                  ; Sprite 0 pointer (Layer 0)
    clc
    adc #1
    sta $43F9                  ; Sprite 1 pointer (Layer 1)
    adc #1
    sta $43FA                  ; Sprite 2 pointer (Layer 2)

    ldy lut_ClassColorOffset, x

    lda lut_ClassColors + 0, y
    sta SP0COL
    lda lut_ClassColors + 1, y
    sta SP1COL
    lda lut_ClassColors + 2, y
    sta SP2COL

    lda #120
    sta SP0X
    sta SP1X
    sta SP2X

    lda #198
    sta SP0Y
    sta SP1Y
    sta SP2Y
    rts

SetupHero3:
    ldx ptygen+$30
    cpx #6
    bcc :+
    ldx #0
:   lda lut_ClassSpriteBase, x
    sta $43FB                  ; Sprite 3 pointer (Layer 0)
    clc
    adc #1
    sta $43FC                  ; Sprite 4 pointer (Layer 1)
    adc #1
    sta $43FD                  ; Sprite 5 pointer (Layer 2)

    ldy lut_ClassColorOffset, x

    lda lut_ClassColors + 0, y
    sta SP3COL
    lda lut_ClassColors + 1, y
    sta SP4COL
    lda lut_ClassColors + 2, y
    sta SP5COL

    lda #232
    sta SP3X
    sta SP4X
    sta SP5X

    lda #198
    sta SP3Y
    sta SP4Y
    sta SP5Y
    rts

.export lut_ClassSpriteBase, lut_ClassColors, lut_ClassColorOffset

lut_ClassSpriteBase:
    .byte BLOCK_HERO_BASE + (0 * 3)   ; Class 0 (Fighter): Index 0 (Block 98)
    .byte BLOCK_HERO_BASE + (1 * 3)   ; Class 1 (Thief): Index 1 (Block 101)
    .byte BLOCK_HERO_BASE + (2 * 3)   ; Class 2 (Black Belt): Index 2 (Block 104)
    .byte BLOCK_HERO_BASE + (3 * 3)   ; Class 3 (Red Mage): Index 3 (Block 107)
    .byte BLOCK_HERO_BASE + (5 * 3)   ; Class 4 (White Mage): Index 5 (Block 113)
    .byte BLOCK_HERO_BASE + (4 * 3)   ; Class 5 (Black Mage): Index 4 (Block 110)

lut_ClassColors:
    ; Class 0 (Fighter): Red, Pink/Peach, White
    .byte COLOR_RED, COLOR_PEACH, COLOR_WHITE

    ; Class 1 (Thief): Brown, Pink/Peach, Cyan
    .byte COLOR_BROWN, COLOR_PEACH, COLOR_CYAN

    ; Class 2 (Black Belt): Brown, Pink/Peach, Cyan
    .byte COLOR_BROWN, COLOR_PEACH, COLOR_CYAN

    ; Class 3 (Red Mage): Red, Pink/Peach, White
    .byte COLOR_RED, COLOR_PEACH, COLOR_WHITE

    ; Class 4 (White Mage): Red, Pink/Peach, White
    .byte COLOR_RED, COLOR_PEACH, COLOR_WHITE

    ; Class 5 (Black Mage): Yellow, Brown, Cyan
    .byte COLOR_YELLOW, COLOR_BROWN, COLOR_CYAN

lut_ClassColorOffset:
    .byte 0, 3, 6, 9, 12, 15


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  MainMenu_IRQ - 2-Zone Raster Multiplexer for Main Menu
;;
;;  Zone 0 (Scanline 250 / VBlank -> Scanline 135):
;;    Physical Sprites 0-2: Hero 0 (Box 1, Top-Left: X = 192, Y = 66)
;;    Physical Sprites 3-5: Hero 1 (Box 2, Top-Right: X = 280, Y = 66)
;;    Physical Sprites 6-7: Finger Cursor (if SubTarget on Hero 0 or 1)
;;
;;  Zone 1 (Scanline 135 -> Scanline 250):
;;    Physical Sprites 0-2: Hero 2 (Box 3, Bottom-Left: X = 192, Y = 162)
;;    Physical Sprites 3-5: Hero 3 (Box 4, Bottom-Right: X = 280, Y = 162)
;;    Physical Sprites 6-7: Finger Cursor
;;      - Option Box: X = 52, Y from lut_MMOptionCursor_Y
;;      - SubTarget on Hero 2 or 3: X = 136 or 224, Y = 154
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_MMOptionCursor_Y:
    .byte 194, 202, 210, 218, 226

MainMenu_IRQ:
    lda #$01
    sta VICIRQ                 ; Acknowledge VIC-II Raster IRQ

    lda spr_irq_zone
    beq @Zone0
    jmp @Zone1

@Zone0:
    inc vblank_count
    jsr CallMusicPlay

    lda #$00
    sta XEXP
    sta YEXP
    sta SPBGPR
    sta SPMC

    jsr SetupMMHero0
    jsr SetupMMHero1

    ; Check if SubTarget cursor is on Hero 0 or 1
    lda menu_cursor_mode
    cmp #1
    bne @NoZone0Cursor
    lda menu_cursor_index
    cmp #2
    bcs @NoZone0Cursor

    ; SubTarget cursor in Zone 0
    ldx #136                   ; Hero 0 cursor X
    lda menu_cursor_index
    beq :+
    ldx #224                   ; Hero 1 cursor X
:   stx SP6X
    stx SP7X
    lda #58                    ; Points directly to character name
    sta SP6Y
    sta SP7Y

    lda MSIGX
    and #%00111111             ; Clear MSB for Sprites 6 & 7 (X < 256)
    sta MSIGX

    lda #BLOCK_FINGER_OVERLAY
    sta $43FE
    lda #COLOR_WHITE
    sta SP6COL

    lda #BLOCK_FINGER_BASE
    sta $43FF
    lda #COLOR_WHITE
    sta SP7COL

    lda SPMC
    ora #%10000000             ; Sprite 7 is MultiColor
    sta SPMC

    lda SPENA
    ora #%11000000             ; Enable Sprites 6 & 7
    sta SPENA
    jmp @ArmZone1

@NoZone0Cursor:
    lda SPENA
    and #%00111111             ; Disable cursor sprites in Zone 0
    sta SPENA

@ArmZone1:
    lda #135
    sta RASTER
    lda SCROLY
    and #$7F
    sta SCROLY
    lda #1
    sta spr_irq_zone
    jmp $FEBC

@Zone1:
    lda #$00
    sta XEXP
    sta YEXP
    sta SPBGPR
    sta SPMC

    jsr SetupMMHero2
    jsr SetupMMHero3

    lda menu_cursor_mode
    cmp #1
    beq @Zone1_SubTarget

    ; Option Box Cursor in Zone 1!
    lda #52
    sta SP6X
    sta SP7X

    ldx menu_cursor_index
    cpx #5
    bcc :+
    ldx #0
:   lda lut_MMOptionCursor_Y, x
    sta SP6Y
    sta SP7Y

    lda MSIGX
    and #%00111111             ; Clear MSB for Sprites 6 & 7
    sta MSIGX

    lda #BLOCK_FINGER_OVERLAY
    sta $43FE                  ; Sprite 6 = Overlay
    lda #COLOR_WHITE
    sta SP6COL

    lda #BLOCK_FINGER_BASE
    sta $43FF                  ; Sprite 7 = Base
    lda #COLOR_WHITE
    sta SP7COL

    lda SPMC
    ora #%10000000             ; Sprite 7 is MultiColor
    sta SPMC

    lda SPENA
    ora #%11000000             ; Enable Sprites 6 & 7
    sta SPENA
    jmp @ArmZone0

@Zone1_SubTarget:
    lda menu_cursor_index
    cmp #2
    bcc @NoZone1Cursor

    ldx #136                   ; Hero 2 cursor X
    lda menu_cursor_index
    cmp #2
    beq :+
    ldx #224                   ; Hero 3 cursor X
:   stx SP6X
    stx SP7X
    lda #154                   ; Points to Hero 2/3 name
    sta SP6Y
    sta SP7Y

    lda MSIGX
    and #%00111111
    sta MSIGX

    lda #BLOCK_FINGER_OVERLAY
    sta $43FE
    lda #COLOR_WHITE
    sta SP6COL

    lda #BLOCK_FINGER_BASE
    sta $43FF
    lda #COLOR_WHITE
    sta SP7COL

    lda SPMC
    ora #%10000000
    sta SPMC

    lda SPENA
    ora #%11000000
    sta SPENA
    jmp @ArmZone0

@NoZone1Cursor:
    lda SPENA
    and #%00111111
    sta SPENA

@ArmZone0:
    lda #250
    sta RASTER
    lda SCROLY
    and #$7F
    sta SCROLY
    lda #0
    sta spr_irq_zone
    jmp $FEBC

SetupMMHero0:
    lda ch_ailments + 0
    cmp #$01
    bne @Alive
    lda SPENA
    and #%11111000             ; Disable Sprites 0, 1, 2
    sta SPENA
    rts
@Alive:
    lda SPENA
    ora #%00000111             ; Enable Sprites 0, 1, 2
    sta SPENA

    lda MSIGX
    and #%11111000
    sta MSIGX

    lda #192
    sta SP0X
    sta SP1X
    sta SP2X

    lda #70
    sta SP0Y
    sta SP1Y
    sta SP2Y

    lda ch_class + 0
    cmp #6
    bcc :+
    sbc #6
:   tax
    lda lut_ClassSpriteBase, x
    sta $43F8
    clc
    adc #1
    sta $43F9
    adc #1
    sta $43FA

    ldy lut_ClassColorOffset, x

    lda ch_ailments + 0
    cmp #$02
    beq @Stone
    lda lut_ClassColors + 0, y
    sta SP0COL
    lda lut_ClassColors + 1, y
    sta SP1COL
    lda lut_ClassColors + 2, y
    sta SP2COL
    rts
@Stone:
    lda #COLOR_DARKGREY
    sta SP0COL
    sta SP1COL
    sta SP2COL
    rts

SetupMMHero1:
    lda ch_ailments + $40
    cmp #$01
    bne @Alive
    lda SPENA
    and #%11000111             ; Disable Sprites 3, 4, 5
    sta SPENA
    rts
@Alive:
    lda SPENA
    ora #%00111000             ; Enable Sprites 3, 4, 5
    sta SPENA

    lda MSIGX
    ora #%00111000             ; X=280 -> MSB set for Sprites 3, 4, 5
    sta MSIGX

    lda #24
    sta SP3X
    sta SP4X
    sta SP5X

    lda #70
    sta SP3Y
    sta SP4Y
    sta SP5Y

    lda ch_class + $40
    cmp #6
    bcc :+
    sbc #6
:   tax
    lda lut_ClassSpriteBase, x
    sta $43FB
    clc
    adc #1
    sta $43FC
    adc #1
    sta $43FD

    ldy lut_ClassColorOffset, x

    lda ch_ailments + $40
    cmp #$02
    beq @Stone
    lda lut_ClassColors + 0, y
    sta SP3COL
    lda lut_ClassColors + 1, y
    sta SP4COL
    lda lut_ClassColors + 2, y
    sta SP5COL
    rts
@Stone:
    lda #COLOR_DARKGREY
    sta SP3COL
    sta SP4COL
    sta SP5COL
    rts

SetupMMHero2:
    lda ch_ailments + $80
    cmp #$01
    bne @Alive
    lda SPENA
    and #%11111000             ; Disable Sprites 0, 1, 2
    sta SPENA
    rts
@Alive:
    lda SPENA
    ora #%00000111             ; Enable Sprites 0, 1, 2
    sta SPENA

    lda MSIGX
    and #%11111000
    sta MSIGX

    lda #192
    sta SP0X
    sta SP1X
    sta SP2X

    lda #166
    sta SP0Y
    sta SP1Y
    sta SP2Y

    lda ch_class + $80
    cmp #6
    bcc :+
    sbc #6
:   tax
    lda lut_ClassSpriteBase, x
    sta $43F8
    clc
    adc #1
    sta $43F9
    adc #1
    sta $43FA

    ldy lut_ClassColorOffset, x

    lda ch_ailments + $80
    cmp #$02
    beq @Stone
    lda lut_ClassColors + 0, y
    sta SP0COL
    lda lut_ClassColors + 1, y
    sta SP1COL
    lda lut_ClassColors + 2, y
    sta SP2COL
    rts
@Stone:
    lda #COLOR_DARKGREY
    sta SP0COL
    sta SP1COL
    sta SP2COL
    rts

SetupMMHero3:
    lda ch_ailments + $C0
    cmp #$01
    bne @Alive
    lda SPENA
    and #%11000111             ; Disable Sprites 3, 4, 5
    sta SPENA
    rts
@Alive:
    lda SPENA
    ora #%00111000             ; Enable Sprites 3, 4, 5
    sta SPENA

    lda MSIGX
    ora #%00111000             ; X=280 -> MSB set for Sprites 3, 4, 5
    sta MSIGX

    lda #24
    sta SP3X
    sta SP4X
    sta SP5X

    lda #166
    sta SP3Y
    sta SP4Y
    sta SP5Y

    lda ch_class + $C0
    cmp #6
    bcc :+
    sbc #6
:   tax
    lda lut_ClassSpriteBase, x
    sta $43FB
    clc
    adc #1
    sta $43FC
    adc #1
    sta $43FD

    ldy lut_ClassColorOffset, x

    lda ch_ailments + $C0
    cmp #$02
    beq @Stone
    lda lut_ClassColors + 0, y
    sta SP3COL
    lda lut_ClassColors + 1, y
    sta SP4COL
    lda lut_ClassColors + 2, y
    sta SP5COL
    rts
@Stone:
    lda #COLOR_DARKGREY
    sta SP3COL
    sta SP4COL
    sta SP5COL
    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Clear BG Palette   [14015]
;;
;;     This routine resets the BG palette to all black (0)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineupMenu_IRQ:
    lda #$01
    sta VICIRQ                 ; Acknowledge VIC-II Raster IRQ

    lda spr_irq_zone
    beq @Zone0
    jmp @Zone1

@Zone0:
    inc vblank_count
    jsr CallMusicPlay

    lda #$00
    sta MSIGX
    sta XEXP
    sta YEXP
    sta SPBGPR
    sta SPMC

    ; Sort 4 slots by Y coordinate using 5-comparator network
    lda #0
    sta lu_slot_order+0
    lda #8
    sta lu_slot_order+1
    lda #16
    sta lu_slot_order+2
    lda #24
    sta lu_slot_order+3

    ; 1. Compare (0, 1)
    ldx lu_slot_order+0
    ldy lu_slot_order+1
    lda str_buf+3, x
    cmp str_buf+3, y
    bcc :+
    stx lu_slot_order+1
    sty lu_slot_order+0
:   ; 2. Compare (2, 3)
    ldx lu_slot_order+2
    ldy lu_slot_order+3
    lda str_buf+3, x
    cmp str_buf+3, y
    bcc :+
    stx lu_slot_order+3
    sty lu_slot_order+2
:   ; 3. Compare (0, 2)
    ldx lu_slot_order+0
    ldy lu_slot_order+2
    lda str_buf+3, x
    cmp str_buf+3, y
    bcc :+
    stx lu_slot_order+2
    sty lu_slot_order+0
:   ; 4. Compare (1, 3)
    ldx lu_slot_order+1
    ldy lu_slot_order+3
    lda str_buf+3, x
    cmp str_buf+3, y
    bcc :+
    stx lu_slot_order+3
    sty lu_slot_order+1
:   ; 5. Compare (1, 2)
    ldx lu_slot_order+1
    ldy lu_slot_order+2
    lda str_buf+3, x
    cmp str_buf+3, y
    bcc :+
    stx lu_slot_order+2
    sty lu_slot_order+1
:

    ; Dynamic split raster = Y(2nd lowest) + 22
    ldx lu_slot_order+1
    lda str_buf+3, x
    clc
    adc #22
    sta lu_split_raster

    ; Setup Hero with lowest Y (Sprites 0-2)
    ldx lu_slot_order+0
    jsr SetupLineupHero_012

    ; Setup Hero with 2nd lowest Y (Sprites 3-5)
    ldx lu_slot_order+1
    jsr SetupLineupHero_345

    ; Enable Sprites 0-5
    lda #%00111111
    sta SPENA

    ; Setup Cursor in Zone 0
    ldx #0
    jsr SetupLineupCursor

    ; Arm Zone 1 at lu_split_raster
    lda lu_split_raster
    sta RASTER
    lda SCROLY
    and #$7F
    sta SCROLY
    lda #1
    sta spr_irq_zone
    jmp $FEBC

@Zone1:
    lda #$00
    sta MSIGX
    sta XEXP
    sta YEXP
    sta SPBGPR
    sta SPMC

    ; Setup Hero with 3rd lowest Y (Sprites 0-2)
    ldx lu_slot_order+2
    jsr SetupLineupHero_012

    ; Setup Hero with largest Y (Sprites 3-5)
    ldx lu_slot_order+3
    jsr SetupLineupHero_345

    ; Enable Sprites 0-5
    lda #%00111111
    sta SPENA

    ; Setup Cursor in Zone 1
    ldx #1
    jsr SetupLineupCursor

    ; Arm Zone 0 at Scanline 250 (VBlank)
    lda #250
    sta RASTER
    lda SCROLY
    and #$7F
    sta SCROLY
    lda #0
    sta spr_irq_zone
    jmp $FEBC

SetupLineupHero_012:
    lda str_buf+2, x
    sta SP0X
    sta SP1X
    sta SP2X
    lda str_buf+3, x
    sta SP0Y
    sta SP1Y
    sta SP2Y

    lda str_buf+1, x           ; char index
    tay
    lda ch_class, y
    cmp #6
    bcc :+
    sbc #6
:   tay
    lda lut_ClassSpriteBase, y
    sta $43F8
    clc
    adc #1
    sta $43F9
    adc #1
    sta $43FA

    ; Determine colors
    lda str_buf+1, x
    tay
    lda ch_ailments, y
    cmp #$01                   ; dead?
    bne :+
    lda #COLOR_DARKGREY
    sta SP0COL
    lda #COLOR_BLACK
    sta SP1COL
    sta SP2COL
    rts
:   cmp #$02                   ; stone?
    bne :+
    lda #COLOR_GREY
    sta SP0COL
    lda #COLOR_BLACK
    sta SP1COL
    sta SP2COL
    rts
:   lda ch_class, y
    cmp #6
    bcc :+
    sbc #6
:   tay
    ldx lut_ClassColorOffset, y
    lda lut_ClassColors + 0, x
    sta SP0COL
    lda lut_ClassColors + 1, x
    sta SP1COL
    lda lut_ClassColors + 2, x
    sta SP2COL
    rts

SetupLineupHero_345:
    lda str_buf+2, x
    sta SP3X
    sta SP4X
    sta SP5X
    lda str_buf+3, x
    sta SP3Y
    sta SP4Y
    sta SP5Y

    lda str_buf+1, x           ; char index
    tay
    lda ch_class, y
    cmp #6
    bcc :+
    sbc #6
:   tay
    lda lut_ClassSpriteBase, y
    sta $43FB
    clc
    adc #1
    sta $43FC
    adc #1
    sta $43FD

    ; Determine colors
    lda str_buf+1, x
    tay
    lda ch_ailments, y
    cmp #$01                   ; dead?
    bne :+
    lda #COLOR_DARKGREY
    sta SP3COL
    lda #COLOR_BLACK
    sta SP4COL
    sta SP5COL
    rts
:   cmp #$02                   ; stone?
    bne :+
    lda #COLOR_GREY
    sta SP3COL
    lda #COLOR_BLACK
    sta SP4COL
    sta SP5COL
    rts
:   lda ch_class, y
    cmp #6
    bcc :+
    sbc #6
:   tay
    ldx lut_ClassColorOffset, y
    lda lut_ClassColors + 0, x
    sta SP3COL
    lda lut_ClassColors + 1, x
    sta SP4COL
    lda lut_ClassColors + 2, x
    sta SP5COL
    rts

SetupLineupCursor:
    ldy lu_cursor
    lda str_buf+3, y           ; Hero Y
    clc
    adc #8                     ; Point at character name (+8 pixels)
    cmp lu_split_raster
    bcs @InZone1

@InZone0:
    cpx #0                     ; Are we in Zone 0?
    bne @NoCursor
    jmp @DrawCursor

@InZone1:
    cpx #1                     ; Are we in Zone 1?
    bne @NoCursor

@DrawCursor:
    lda #116                   ; Finger cursor X coord (points to col 14)
    sta SP6X
    sta SP7X
    lda str_buf+3, y           ; Hero Y
    clc
    adc #8                     ; Finger cursor Y coord (+8 pixels)
    sta SP6Y
    sta SP7Y
    lda #BLOCK_FINGER_OVERLAY
    sta $43FE
    lda #COLOR_WHITE
    sta SP6COL
    lda #BLOCK_FINGER_BASE
    sta $43FF
    lda #COLOR_WHITE
    sta SP7COL
    lda SPMC
    ora #%10000000             ; Sprite 7 Multicolor
    sta SPMC
    lda SPENA
    ora #%11000000             ; Enable Sprites 6 & 7
    sta SPENA
    rts

@NoCursor:
    lda SPENA
    and #%00111111             ; Disable Sprites 6 & 7
    sta SPENA
    lda SPMC
    and #%01111111
    sta SPMC
    rts

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawOBSprite  [10405]
;;
;;  Draws an out-of-battle hero sprite on C64.
;;  Used by Status Menu to display the hero inside Box 1.
;;
;;  IN:  A = char_index ($00, $40, $80, $C0)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawOBSprite:
    sta char_index
    tax
    lda ch_ailments, x
    cmp #$01                      ; dead?
    bne @Alive
    lda #0
    sta shadow_spr_en
    sta SPENA
    rts

@Alive:
    lda ch_class, x
    cmp #6
    bcc :+
    sbc #6
:   tax                           ; Class 0..5 in X

    lda lut_ClassSpriteBase, x
    sta shadow_spr_ptr + 0
    sta $43F8
    clc
    adc #1
    sta shadow_spr_ptr + 1
    sta $43F9
    adc #1
    sta shadow_spr_ptr + 2
    sta $43FA

    ldy lut_ClassColorOffset, x

    ldx char_index
    lda ch_ailments, x
    cmp #$02                      ; stone?
    bne @NotStone
    lda #COLOR_DARKGREY
    sta shadow_spr_col + 0
    sta shadow_spr_col + 1
    sta shadow_spr_col + 2
    sta SP0COL
    sta SP1COL
    sta SP2COL
    jmp @Position

@NotStone:
    lda lut_ClassColors + 0, y
    sta shadow_spr_col + 0
    sta SP0COL
    lda lut_ClassColors + 1, y
    sta shadow_spr_col + 1
    sta SP1COL
    lda lut_ClassColors + 2, y
    sta shadow_spr_col + 2
    sta SP2COL

@Position:
    lda #144                      ; Col 15 (X = 24 + 15*8 = 144)
    sta shadow_spr_x + 0
    sta shadow_spr_x + 1
    sta shadow_spr_x + 2
    sta SP0X
    sta SP1X
    sta SP2X

    lda #59                       ; Row 1 (Y = 50 + 1*8 + 1 = 59)
    sta shadow_spr_y + 0
    sta shadow_spr_y + 1
    sta shadow_spr_y + 2
    sta SP0Y
    sta SP1Y
    sta SP2Y

    lda shadow_spr_msb
    and #%11111000
    sta shadow_spr_msb
    lda MSIGX
    and #%11111000
    sta MSIGX

    lda shadow_spr_mcm
    and #%11111000
    sta shadow_spr_mcm
    lda SPMC
    and #%11111000
    sta SPMC

    lda #%00000111
    sta shadow_spr_en
    sta SPENA
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawEquipMenuStrings  [10616]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawEquipMenuStrings:
    LDA #0                       ; string will be placed at str_buf+$10, and will be 8 bytes long
    STA str_buf+$19              ; so put the null terminator at the end right-off

    LDA #1
    STA menustall                ; set menustall

    LDA #$1C-1                   ; A=$1C-1  (1C = start of weapon names in the item list)
    LDX equipoffset
    CPX #ch_weapons - ch_stats   ; buf if we're not dealing with weapons....
    BEQ :+
      LDA #$44-1                 ; A=$44-1  (44 = start of armor names in the item list)
:   STA draweq_stradd            ; this value will be later added to the weapon/armor ID to get
                                 ; the proper string ID.  For now, just stuff it in RAM
                                 ; minus 1 because 0 is an empty slot

    LDA #>(str_buf+$10)          ; set high byte of text pointer
    STA text_ptr+1

    LDA #$00                     ; Set A to zero.  This is our loop counter
  @MainLoop:
    PHA                          ; push the loop counter to the stack
    TAX                          ; then move it to X
    ASL A
    TAY                          ; and move it*2 to Y

    LDA lut_EquipStringPositions, Y     ; use Y to index a positioning LUT
    STA dest_x                          ;  load up x,y coords for this string
    LDA lut_EquipStringPositions+1, Y
    STA dest_y

    LDA #BANK_ITEMS
    JSR SwapPRG_L                ; swap to the bank containing the item strings

    LDA #$FF                     ; fill first 2 bytes of the string with blank spaces (tile FF)
    STA str_buf+$10              ; later, these spaces will be replaced with "E-" if the item
    STA str_buf+$11              ;  is currently equipped.

    LDA item_box, X              ; get the current item ID
    STA tmp+2                    ; and stick it in temp ram for later

    AND #$7F                     ; remove the equip bit (get just the item ID)
    BNE @LoadName                ; if nonzero, load up the other name...

      LDA #$FF                   ; otherwise (zero), slot is empty, just fill the string with spaces
      STA str_buf+$12
      STA str_buf+$13
      STA str_buf+$14
      STA str_buf+$15
      STA str_buf+$16
      STA str_buf+$17
      STA str_buf+$18
      BNE @NotEquipped           ; then skip ahead (always branches)

  @LoadName:                     ; if the slot is not empty....
    CLC                          ; add the weapon/armor offset to the equipment ID.
    ADC draweq_stradd            ;  now A is the proper item ID

    ASL A                        ; double it
    TAX                          ; and stuff it in X to load up the pointer
    LDA lut_ItemNamePtrTbl, X    ; fetch the pointer and store it to (tmp)
    STA tmp
    LDA lut_ItemNamePtrTbl+1, X
    STA tmp+1

    LDY #$06                     ; copy 7 characters from the item name (doesn't look for null termination)
   @LoadNameLoop:
      LDA (tmp), Y               ; load a character in the string
      STA str_buf+$12, Y         ; and write it to our string buffer.  +2 because the first 2 bytes are the equip state
      DEY                        ; (that "E-" if equipped).  Then decrement Y
      BPL @LoadNameLoop          ; and loop until it wraps (7 iterations)

    LDA tmp+2                    ; get the item ID (to see if it's equipped)
    BPL @NotEquipped             ; if not equipped... skip ahead.  Otherwise

      LDA #$8E                   ; draw 'E' tile
      STA str_buf+$10
      LDA #$C2                   ; and '-' tile
      STA str_buf+$11            ; draw them to indicate item is equipped

  @NotEquipped:
    LDA #<(str_buf+$10)          ; finally load the low byte of our text pointer
    STA text_ptr
    JSR DrawComplexString        ; then draw the complex string

    PLA                          ; pull the main loop counter
    CLC
    ADC #$01                     ; increment it by one
    CMP #16                      ; and loop until it reaches 16 (16 equipment names to draw)
    BCC @MainLoop

    LDA #BANK_MENUS              ; once all names are drawn
    STA cur_bank                 ; set cur and ret banks to the MENUS bank
    STA ret_bank
    JSR SwapPRG_L                ; then swap back to that bank
    RTS                          ; and return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lut_EquipStringPositions  [10720]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_EquipStringPositions:
  .BYTE 15,  5,   25,  5        ; character 0
  .BYTE 15,  7,   25,  7
  
  .BYTE 15, 10,   25, 10        ; character 1
  .BYTE 15, 12,   25, 12
  
  .BYTE 15, 15,   25, 15        ; character 2
  .BYTE 15, 17,   25, 17
  
  .BYTE 15, 20,   25, 20        ; character 3
  .BYTE 15, 22,   25, 22


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  UnadjustEquipStats  [10743]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UnadjustEquipStats:
    LDA #BANK_EQUIPSTATS    ; Swap to bank containing equipment stats
    JSR SwapPRG_L

    LDA equipoffset         ; get the equipment offset (weapon or armor offset)
    STA equipmenu_tmp       ;  and back it up in equipmenu_tmp.  This is our editable source index

  @Loop:
    LDX equipmenu_tmp       ; get current source index in X  (it's also in A at this point)
    AND #$C0                ; mask to get the char index in A
    STA tmp+7               ; and put char index in tmp+7 for future use

    LDA ch_stats, X         ; get 1st piece of equipment
    BPL :+                  ; high bit set = equipped.  If equipped... 
      JSR @Adjust           ;   adjust stats for it

:   LDA ch_stats+1, X       ; then do same for 2nd piece
    BPL :+
      JSR @Adjust

:   LDA ch_stats+2, X       ; and 3rd
    BPL :+
      JSR @Adjust

:   LDA ch_stats+3, X       ; and 4th
    BPL :+
      JSR @Adjust

:   JSR UnadjustBBEquipStats  ; do a few adjustments for BB/MAs... or zero absorb

    LDA equipmenu_tmp         ; add $40 to the source index (look at next character)
    CLC
    ADC #$40
    STA equipmenu_tmp
    BCC @Loop                 ; keep looping until source index wraps (wraps after 4 characters)

    LDA #BANK_MENUS           ; then restore the menu bank, and exit
    JMP SwapPRG_L

  ;; local subroutine
  ;;   subtracts a weapon's hit and dmg bonus from the character's stats
  ;;   or removes an armor's evade penalty from the char's stats
  ;;   X remains unchanged by the routine (coming in and going out, X=equipmenu_tmp)

  @Adjust:
    SEC
    SBC #$01              ; subtract 1 from the equipment ID (they're 1-based, not 0-based... 0 is empty slot)

    ASL A
    ASL A                 ; then multiply by 4 (A = equip_id*4) -- high bit (equipped) is lost here, no need to mask it out

    LDY equipoffset              ; see if we're dealing with weapons or armor (use Y so not to disrupt A)
    CPY #ch_weapons - ch_stats
    BNE @AdjustArmor

    @AdjustWeapons:
      ASL A               ; multiply by another 2  (A= weapon_id*8) -- there are 8 bytes of stats per weapon
      STA tmp             ; this is the low byte of our source pointer
      LDA #0
      ADC #>lut_Weapons   ; include carry into high byte of source pointer
      STA tmp+1           ; (tmp) is now a pointer to stats for this weapon

      LDX tmp+7           ; load char index into X
      LDY #0              ; zero source index Y

      LDA ch_hitrate, X   ; get character's hit rate
      SEC
      SBC (tmp), Y        ; subtract the weapon's hit rate bonus
      STA ch_hitrate, X   ; and write back to character's hit rate
      INY                 ; inc source index

      LDA ch_dmg, X       ; get char's dmg
      SEC
      SBC (tmp), Y        ; subtract weapon's damage bonus
      STA ch_dmg, X       ; and write back

      LDX equipmenu_tmp   ; restore X to the equipment source index
      RTS                 ;  before returning

    @AdjustArmor:
      CLC                 ; (A= armor_id*8)
      ADC #<lut_Armor     ; add A to desired pointer
      STA tmp             ;  and store pointer to (tmp)
      LDA #0
      ADC #>lut_Armor
      STA tmp+1           ; (tmp) is now a pointer to stats for this armor

      LDX tmp+7           ; get char index in X
      LDY #0              ; zero our source index Y

      LDA ch_evade, X     ; get character's evade
      CLC
      ADC (tmp), Y        ; add the armor's evade penalty rate (removing the penalty)
      STA ch_evade, X     ; and write back

      LDX equipmenu_tmp   ; then restore X to equipment source index
      RTS                 ; and exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  ReadjustEquipStats  [10854]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadjustEquipStats:
    LDA #BANK_EQUIPSTATS     ; swap to bank containing equipment stats
    JSR SwapPRG_L

    LDA equipoffset          ; get the equipment offset
    STA equipmenu_tmp        ; and put it in equipmenu_tmp -- this is our runtime source index

  @Loop:
    LDX equipmenu_tmp        ; get source index (source index also in A at this point)
    AND #$C0                 ; mask out high bits so A just contains char index
    STA tmp+7                ; store char index in tmp+7 for future use

    LDA ch_stats, X          ; get first piece of equipment
    BPL :+                   ; if equipped....
      JSR @Adjust            ;   adjust for its stats

:   LDA ch_stats+1, X        ; do the same for all 4 pieces of equipment
    BPL :+
      JSR @Adjust

:   LDA ch_stats+2, X
    BPL :+
      JSR @Adjust

:   LDA ch_stats+3, X
    BPL :+
      JSR @Adjust

:   JSR ReadjustBBEquipStats ; adjust for special BB/MA properties

    LDA equipmenu_tmp        ; add $40 to our source index (move to next char)
    CLC
    ADC #$40
    STA equipmenu_tmp

    BCC @Loop                ; and keep looping until it wraps (4 iterations -- all 4 chars)

    LDA #BANK_MENUS          ; then swap back to MENUS bank
    JMP SwapPRG_L            ;   and exit

  ;; local subroutine
  ;;   adds a weapon's hit and dmg bonus to the character's stats
  ;;   or adds armor stats to char stats
  ;;   X remains unchanged by the routine (coming in and going out, X=equipmenu_tmp)

  @Adjust:
    SEC
    SBC #$01               ; subtract 1 from the equip ID (equipment is 1 based -- 0 is an empty slot)
    ASL A
    ASL A                  ; multiply by 4 (this drops the high bit -- no need to mask it out)

    LDY equipoffset             ; see if this is weapon or armor
    CPY #ch_weapons - ch_stats
    BNE @AdjustArmor

  @AdjustWeapon:
    ASL A                  ; multiply by another 2 (A now = weapon_id * 8)
    STA tmp                ; put in tmp as low byte of our pointer
    LDA #0
    ADC #>lut_Weapons      ; add high byte of our pointer (including any appropriate carry)
    STA tmp+1              ; fill tmp+1 to complete our pointer

    LDX tmp+7              ; get the character index
    LDY #0                 ; zero Y (our source index)

    LDA ch_hitrate, X      ; get char's hit rate
    CLC
    ADC (tmp), Y           ; add to it the weapon's hit bonus
    STA ch_hitrate, X      ; and write it back
    INY                    ;   inc source index

    LDA ch_dmg, X          ; get char's damage
    CLC
    ADC (tmp), Y           ; add weapon's damage bonus
    STA ch_dmg, X          ; and write back

    LDX equipmenu_tmp      ; restore X to its original state
    RTS

  @AdjustArmor:            ; A = armor_id * 4
    CLC
    ADC #<lut_Armor        ; add low byte of pointer to our A
    STA tmp                ; and store it in tmp
    LDA #0
    ADC #>lut_Armor        ; then get high byte of pointer (ADC to catch appropriate carry)
    STA tmp+1              ; (tmp) is now a pointer to this armor's stats

    LDX tmp+7              ; get char index
    LDY #0                 ; zero source pointer

    LDA ch_evade, X        ; get char's evade
    SEC
    SBC (tmp), Y           ; subtract armor evade penalty
    STA ch_evade, X        ; and write it back
    INY                    ; inc source index

    LDA ch_absorb, X       ; get absorb
    CLC
    ADC (tmp), Y           ; add absorb bonus
    STA ch_absorb, X       ; and write back

    LDA ch_resist, X       ; get elemental resistence
    INY                    ;   inc source index
    ORA (tmp), Y           ; combine this armor's elemental resistence
    STA ch_resist, X       ; and write back

    LDX equipmenu_tmp      ; restore X to original state
    RTS                    ; and exit


;;;;;;;;;;;;;;;;;;;
;;
;;  UnadjustBBEquipStats  [10974]
;;
;;;;;;;;;;;;;;;;;;;

UnadjustBBEquipStats:
    LDA equipoffset             ; check to see if we're dealing with weapons or armor
    CMP #ch_weapons - ch_stats  ; if armor, jump ahead
    BNE @Armor

  @Weapons:             ; for weapons....
    LDX tmp+7           ; get char index into X
    LDA ch_class, X     ; get the char's class

    CMP #CLS_BB         ; check if he's a black belt or master
    BEQ @BlackBelt      ;  if he isn't, just exit
    CMP #CLS_MA         ; if he is...
    BNE @Exit

  @BlackBelt:
    LDA #0              ; zero his damage stat
    STA ch_dmg, X

  @Exit:
    RTS

  @Armor:               ; for armor...
    LDA #0
    LDX tmp+7           ; get char index
    STA ch_absorb, X    ; zero absorb
    STA ch_resist, X    ; and elemental resistence
    RTS                 ; then exit


;;;;;;;;;;;;;;;;;;;
;;
;;  ReadjustBBEquipStats  [11014]
;;
;;;;;;;;;;;;;;;;;;;

ReadjustBBEquipStats:
    LDX tmp+7          ; load up char index into X
    LDA ch_class, X    ; get this char's class

    CMP #CLS_BB        ; see if he's a black belt or master... if yes, jump ahead
    BEQ @BlackBelt     ; otherwise, exit
    CMP #CLS_MA
    BNE @Exit

  @BlackBelt:
    LDA equipoffset
    CMP #ch_weapons - ch_stats   ; see if we're dealing with weapons or armor
    BNE @Armor

  @Weapons:
    LDA ch_dmg, X             ; check this BB's damage stat
    BEQ @NoWeaponEquipped     ; if zero, we know this BB has no weapon equipped
                              ; we know this because UnadjustBBEquipStats zeros damage for blackbelts.
                              ; thus the only way it could be nonzero is if it had a weapon bonus added.

  @WeaponEquipped:
    LDA ch_str, X             ; if a weapon is equipped... get strength stat
    LSR A                     ;  /2
    ADC ch_dmg, X             ; and add to damage
    STA ch_dmg, X
    RTS                       ; equipped BB's dmg = (str/2 + weapon)

  @NoWeaponEquipped:
    LDA ch_level, X           ; if unequipped, get current experience level
    CLC
    ADC #$01                  ; add 1 (levels are stored 0 based in RAM -- ie '0' is really level 1)
    ASL A                     ; multiply by 2
    STA ch_dmg, X             ; and set dmg.  Unequipped BB's dmg = (level*2)
  @Exit:
    RTS

  @Armor:                     ; for armor....
    LDA ch_absorb, X          ; get absorb
    BNE @Exit                 ; if nonzero he has something equipped (absorb would be 0 otherwise), so just exit

    LDA ch_level, X           ; otherwise, get level + 1
    CLC
    ADC #$01
    STA ch_absorb, X          ; Unequipped BB's absorb=level
    RTS                       ; and exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  DrawItemBox  [11075]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawItemBox:
    LDA #5
    STA box_x
    LDA #2
    STA box_y
    LDA #30
    STA box_wd
    LDA #18
    STA box_ht
    LDA #BANK_MENUS
    STA cur_bank
    JSR DrawBox

    LDX #0           ; X is our dest index -- start it at zero
    LDY #1           ; Y is our source index -- start it at 1 (first byte in the 'items' buffer is unused)

  @ItemFillLoop:
      LDA items, Y       ; check our item qty
      BEQ @IncSrc        ; if it's nonzero...
        TYA              ;  put this item ID in A
        STA item_box, X  ;  and write it to the item box buffer
        INX              ;  inc our dest index

    @IncSrc:
      INY                         ; inc our source index

      CPY #item_orb_start-items   ; since orb names aren't included in the item box...
      BCC @ItemFillLoop           ;   this checks to see if the source index is currently on an orb name
      CPY #item_qty_start-items   ;   if it is, it jumps back to @IncSrc.  If it isn't, it jumps back
      BCC @IncSrc                 ;   to @ItemFillLoop
                                  ; this effectively skips over the orbs

      CPY #item_stop-items        ; keep looping until we go through the entire item list
      BCC @ItemFillLoop

    CPX #0                 ; if the dest index is still zero, the player has no items
    BNE @StartDrawingItems ;   otherwise (nonzero), start drawing the items they have

    ; no items, so no further work to be done... just exit with C set
      SEC
      RTS

  @Exit:
    CLC    ; C clear on exit indicates there was at least 1 item in inventory
    RTS

  @StartDrawingItems:
    STX cursor_max     ; the number of items they have becomes the cursor maximum
    LDA #0
    STA item_box, X    ; put a null terminator at the end of the item box (needed for following loop)
    LDA #0
    STA cursor         ; also reset the cursor to 0 (which will be used as a loop counter below)

  @DrawItemLoop:
    LDX cursor         ; get current loop counter and put it in X
    LDA item_box, X    ; index the item box to see what item name we're to draw
    BEQ @Exit          ; if the item ID is zero, it's a null terminator, which means we're done

    ASL A              ; otherwise double the item ID
    TAX                ;  and put it in X to index (will be used to index the string pointer table)

    LDA #BANK_MENUS    ; set the return bank to BANK_MENUS.
    STA ret_bank       ;   this is required for DrawComplexString (called below)
    LDA #BANK_ITEMS    ; swap to BANK_ITEMS (bank containing item names)
    JSR SwapPRG_L

    LDA lut_ItemNamePtrTbl, X   ; get the pointer to this item name
    STA tmp                     ;  and put it in (tmp)
    LDA lut_ItemNamePtrTbl+1, X
    STA tmp+1

                       ; copy 7 characters verbatim (do not look for null terminators!)
    LDY #$06           ;   this means that shorter item names must be padded with spaces to 7 characters.
   @CopyLoop:
      LDA (tmp), Y         ; copy each character
      STA str_buf+$20, Y   ; and put in str_buf+$20.  Cannot use str_buf as it is,
      DEY                  ;   because it shares RAM with item_box, which we can't overwrite
      BPL @CopyLoop        ; loop until Y wraps (copies 7 characters)

    LDA #0
    STA str_buf+$27    ; end the string buffer with a null terminator

    TXA                ; put X back in A and right-shift it
    LSR A              ;  this restores the unedited item ID number

    CMP #item_qty_start-items   ; see if this item ID falls within the range of IDs that you can have
    BCC @SkipQty                ;  multiple of (qty number needs to be drawn).  If not, Skip ahead

       TAX                     ; put item ID in X
       LDA items, X            ; use it to index inventory to see how many of this item we have
       STA tmp                 ;  put the qty in tmp
       LDA #BANK_MENUS
       STA ret_bank            ; set return bank again
       JSR SwapPRG_L           ; also swap to BANK_MENUS (for PrintNumber routines)

       JSR PrintNumber_2Digit  ; print the 2 digit number

       LDA format_buf-2        ; copy the printed 2 digit number from the format buffer
       STA str_buf+$25         ;  to the end of our string buffer (just before the null terminator)
       LDA format_buf-1
       STA str_buf+$26

  @SkipQty:
    LDA #<(str_buf+$20)    ; fill text_ptr with the pointer to our item name in the string buffer
    STA text_ptr
    LDA #>(str_buf+$20)
    STA text_ptr+1

    LDA cursor             ; get current loop counter again
    ASL A                  ; double it, and stuff it in X
    TAX

    LDA lutItemBoxStrPos, X     ; load up the dest X,Y coords
    STA dest_x                  ;  and record them
    LDA lutItemBoxStrPos+1, X   ; these are the coords at which to draw this item name
    STA dest_y

    JSR DrawComplexString  ; finally actually call DrawComplexString to draw the item name
    INC cursor             ; increment our loop counter to draw the next item
    JMP @DrawItemLoop      ; and continue looping


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  lutItemBoxStrPos  [11211]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lutItemBoxStrPos:
  .BYTE   8, 4,   17, 4,   26, 4
  .BYTE   8, 6,   17, 6,   26, 6
  .BYTE   8, 8,   17, 8,   26, 8
  .BYTE   8,10,   17,10,   26,10
  .BYTE   8,12,   17,12,   26,12
  .BYTE   8,14,   17,14,   26,14
  .BYTE   8,16,   17,16,   26,16
  .BYTE   8,18,   17,18,   26,18


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  SortEquipmentList  [11236]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SortEquipmentList:
    LDY #$04
    LDX equipoffset

   @Loop:
      JSR @SortOne

      TXA
      CLC
      ADC #$40
      AND #$FC
      TAX

      DEY
      BNE @Loop

    RTS

  @SortOne:
    LDA ch_stats, X
    STA tmp
    LDA ch_stats+1, X
    STA tmp+1
    LDA ch_stats+2, X
    STA tmp+2
    LDA ch_stats+3, X
    STA tmp+3

    LDA #0
    STA ch_stats, X
    STA ch_stats+1, X
    STA ch_stats+2, X
    STA ch_stats+3, X

    LDA tmp
    BEQ :+
      STA ch_stats, X
      INX

:   LDA tmp+1
    BEQ :+
      STA ch_stats, X
      INX

:   LDA tmp+2
    BEQ :+
      STA ch_stats, X
      INX

:   LDA tmp+3
    BEQ :+
      STA ch_stats, X

:   RTS
