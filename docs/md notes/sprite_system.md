# FF1 C64 Sprite Architecture & NES Parity Design

This document details the architecture for porting Final Fantasy 1's NES sprite subsystem to the Commodore 64 VIC-II. It covers asset loading (Graphic Area), display state management (Active Area), the dual-sprite layering model, and routine-by-routine parity with the NES disassembly.

---

## 1. Overview & Core Visual Strategy

On the NES, all sprites are built from $8 \times 8$ pixel tiles (up to 64 hardware sprites per frame). FF1 combines tiles into meta-sprites:
* **Cursor / Finger**: $2 \times 2$ tiles ($16 \times 16$ px = 4 NES hardware sprites).
* **Map Characters & NPCs**: $2 \times 2$ tiles ($16 \times 16$ px = 4 NES hardware sprites).
* **Out-of-Battle Party Characters (`DrawSimple2x3Sprite`)**: $2 \times 3$ tiles ($16 \times 24$ px = 6 NES hardware sprites).
* **Battle Characters**: $2 \times 3$ tiles ($16 \times 24$ px = 6 NES hardware sprites).

### The C64 Dual-Sprite Approach (Base + Overlay)
A C64 hardware sprite is $24 \times 21$ pixels—large enough that **a single C64 sprite position covers what required 4 to 6 NES tiles**.

To match the 4-color richness of NES sprites without coarse multicolor resolution artifacts, all primary entities (Party members, NPCs, Cursor) use **two paired C64 sprite slots** sharing the same $(X, Y)$ coordinate:
1. **Base Sprite (Multicolor Mode, $12 \times 21$ double-wide pixels)**:
   * Provides the body, clothing, and primary shading.
   * Colors: Background (`$D021`), Sprite Multicolor 0 (`$D025`), Sprite Multicolor 1 (`$D026`), and individual sprite color (`$D027 + n`).
2. **Overlay Sprite (High-Resolution Mode, $24 \times 21$ single-wide pixels)**:
   * Provides crisp single-pixel outlines, facial features, whites of eyes, hands, and highlights.
   * Color: Individual high-res color (`$D027 + n + 1`).

*(Reference: `res/finger/finger.asm` demonstrates this exact pair: Sprite 0 is the multicolor hand body, Sprite 1 is the high-res white cuff and crisp outline).*

---

## 2. Two-Stage Sprite Architecture

FF1 on NES separates sprite handling cleanly into two stages. We preserve this exact separation on C64:

```
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: SPRITE GRAPHIC AREA (Asset Loading)                           │
│ Triggered when entering a screen / map / battle                        │
│ ROM Banks (Cartridge) ──> VIC-II Bank RAM Graphic Pool ($5800-$5FFF)  │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 2: SPRITE ACTIVE AREA (Shadow Display List)                      │
│ Triggered every frame during game loop logic                           │
│ Game logic writes (X, Y, Block ID, Colors) to Shadow Sprite Buffer     │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ VBLANK / RASTER IRQ FLUSH                                              │
│ Pushes Shadow Buffer ──> VIC-II Registers ($D000-$D02E, $43F8-$43FF)   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Stage 1: Sprite Graphic Area (CHR Loading)

On the NES, sprite bitmaps live in PRG-ROM banks and are copied into PPU CHR-RAM Pattern Table 1 (`$1000–$1FFF`).

On the C64, with VIC-II Bank 1 active (`$4000–$7FFF`), sprite graphics are allocated in 64-byte blocks. For example, allocating `$5800–$5FFF` provides **32 sprite blocks** (Blocks 96 to 127 in Bank 1):

| Block ID Range | VIC Bank 1 Address | Allocated Contents |
| :--- | :--- | :--- |
| **Blocks 96–97** | `$5800`–`$587F` | Finger / Cursor (Base + Overlay) |
| **Blocks 98–105** | `$5880`–`$5A7F` | Party Member 1 Battle/Menu Sprites (Walking/Stance) |
| **Blocks 106–113**| `$5A80`–`$5C7F` | Party Member 2 Battle/Menu Sprites |
| **Blocks 114–121**| `$5C80`–`$5E7F` | Party Member 3 Battle/Menu Sprites |
| **Blocks 122–127**| `$5E80`–`$5FFF` | Party Member 4 Battle/Menu Sprites / Battle FX |

### Parity Asset Load Routines (in `bank0F.asm`)

* **`LoadBatSprCHRPalettes`**:
  * *NES*: Checks party member classes (`ch_class`), copies character tiles from Bank 09 into PPU `$1000-$17FF`, and loads cursor + fx tiles into `$1800-$1FFF`.
  * *C64*: Checks party classes, copies the 4 classes' C64 64-byte sprite blocks into the RAM Graphic Pool, and loads the Finger sprite (`finger.asm`) into the Cursor blocks.
* **`LoadMapObjCHR`**:
  * *NES*: Copies townspeople / NPC tiles for the current map into PPU `$1100-$1FFF`.
  * *C64*: Copies current map NPC C64 sprite blocks into the Graphic Pool.
* **`LoadOWObjectCHR`**:
  * *NES*: Copies ship, canoe, airship tiles into PPU `$1100-$16FF`.
  * *C64*: Copies vehicle C64 sprite blocks into the Graphic Pool.
* **`LoadPlayerMapmanCHR`**:
  * *NES*: Copies lead character map walking tiles into PPU `$1000`.
  * *C64*: Copies leader walking sprite blocks into the Graphic Pool.

---

## 4. Stage 2: Sprite Active Area (Shadow State & Drawing)

On the NES, active sprites are maintained in a 256-byte Shadow OAM buffer (`oam` at `$0200-$02FF`).
On the C64, we maintain a compact **Shadow Sprite Table**:

```assembly
shadow_spr_x:       .res 8      ; Low 8 bits of X for Sprites 0..7
shadow_spr_msb:     .res 1      ; Bit 8 (MSB) for Sprites 0..7 (maps to $D010)
shadow_spr_y:       .res 8      ; Y coordinates for Sprites 0..7
shadow_spr_ptr:     .res 8      ; Sprite Block IDs (written to $43F8..$43FF)
shadow_spr_col:     .res 8      ; Individual colors (written to $D027..$D02E)
shadow_spr_mcm:     .res 1      ; Multicolor mask (written to $D01C)
shadow_spr_en:      .res 1      ; Enable mask (written to $D015)
shadow_spr_pri:     .res 1      ; Priority over background (written to $D01B)
```

### Pointer Assignment vs. 64-Byte Copying
* **Copying 64 bytes into fixed buffers**: Takes ~600–700 CPU cycles per sprite pair. Copying dynamically each frame consumes significant raster time.
* **Pointer Assignment (Recommended)**: The sprite graphic remains stationary in the Graphic Pool. "Drawing" a sprite merely sets the block index:
  ```assembly
  lda #BLOCK_FINGER_BASE
  sta shadow_spr_ptr+0
  lda #BLOCK_FINGER_OVERLAY
  sta shadow_spr_ptr+1
  ```
  This takes only **6 cycles**, matching the exact behavior of NES `STA oam+1, X` (Tile ID).

---

## 5. Routine Parity Mapping

### 1. `ClearOAM` -> `ClearSprites` (`bank0F.asm`)
* *NES*: Loops through all 64 OAM entries and sets $Y = \$F8$ (off-screen).
* *C64*:
  * Sets `shadow_spr_en = $00` (disables all 8 sprites).
  * Optionally sets `shadow_spr_y` entries to 0 or off-screen.
  * Resets active sprite slot index (`sprindex = 0`).

### 2. `DrawCursor` (`bank0F.asm`)
* *NES*: Loads `lutCursor2x2SpriteTable`, sets `tmp+2 = $F0` (tile offset), calls `Draw2x2Sprite`.
* *C64*:
  * Assigns **Sprite Slot 0** (Base) and **Sprite Slot 1** (Overlay).
  * Sets $(X_0, Y_0) = (X_1, Y_1) = (\text{spr\_x}, \text{spr\_y})$.
  * Sets `shadow_spr_ptr+0 = BLOCK_FINGER_BASE`.
  * Sets `shadow_spr_ptr+1 = BLOCK_FINGER_OVERLAY`.
  * Sets Multicolor bit for Slot 0 (`shadow_spr_mcm |= $01`).
  * Clears Multicolor bit for Slot 1 (`shadow_spr_mcm &= ~$02`, Hi-Res).
  * Sets Slot 0 individual color (`$D027 = COLOR_GREY/BLUE`), Slot 1 color (`$D028 = COLOR_WHITE`).
  * Enables both slots in `shadow_spr_en`.

### 3. `DrawOBSprite` / `DrawSimple2x3Sprite` (`bank0F.asm`)
* *NES*: Calculates class palette and stance (standing vs. crouched/dead), outputs 6 tiles to OAM.
* *C64*:
  * Takes next available sprite slot pair $(2k, 2k+1)$.
  * Sets both $(X, Y)$ coordinates.
  * Sets Base block pointer (standing or crouched base) and Overlay block pointer.
  * Configures Slot $2k$ as Multicolor and Slot $2k+1$ as Hi-Res.
  * Sets class-specific palette colors.

### 4. VBlank / Raster Update (`UpdateSprites`)
* *NES*: Writes `#$02` to `$4014` (PPU OAM DMA).
* *C64*: During Raster IRQ line 250 (VBlank handler):
  ```assembly
  UpdateSprites:
      ; 1. Positions
      ldx #$00
  :   lda shadow_spr_x, x
      sta $D000, x        ; X/Y interleaved in $D000-$D00F
      lda shadow_spr_y, x
      sta $D001, x
      inx
      inx
      cpx #$10
      bne :-
      lda shadow_spr_msb
      sta $D010

      ; 2. Pointers (Screen at $4000 -> pointers at $43F8-$43FF)
      ldx #$07
  :   lda shadow_spr_ptr, x
      sta $43F8, x
      lda shadow_spr_col, x
      sta $D027, x
      dex
      bpl :-

      ; 3. Modes and enables
      lda shadow_spr_mcm
      sta $D01C
      lda shadow_spr_en
      sta $D015
      rts
  ```

---

## 6. Multiplexing Strategy

Because we use 2 hardware sprites per entity, 8 hardware sprites provide **4 concurrent layered objects** per raster line.

1. **Menus / Lineup / Shop**:
   * Usually only the Finger Cursor is active (Slots 0 & 1).
   * Slots 2–7 can display up to 3 party preview sprites simultaneously without any raster interrupts.
2. **Overworld**:
   * Slots 0 & 1: Player / leader walking sprite.
   * Slots 2 & 3: Vehicle (Ship / Airship).
   * Slots 4–7: Available for NPCs / map objects.
3. **Battles**:
   * The 4 hero characters in FF1 occupy fixed horizontal rows:
     * Hero 1: $Y \approx 48$
     * Hero 2: $Y \approx 80$
     * Hero 3: $Y \approx 112$
     * Hero 4: $Y \approx 144$
   * Because heroes never vertically overlap:
     * **Option A (No multiplexing needed)**: 4 heroes $\times$ 2 sprites = 8 hardware sprites utilized across the entire right side of the screen. Attack/magic FX can briefly replace a character or reuse slots.
     * **Option B (Raster IRQ Multiplexing)**: Slots 0 & 1 can be reused at each hero row via mid-frame raster interrupts, freeing up Slots 2–7 completely for weapons, magic animations, and battle cursors.

