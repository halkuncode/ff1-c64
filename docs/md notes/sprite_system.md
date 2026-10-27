# FF1 C64 Graphics & Sprite Architecture (NES PPU Emulation on VIC-II)

This document details the complete architecture for porting Final Fantasy 1's NES graphics and sprite subsystems to the Commodore 64 VIC-II. It outlines the emulation of NES PPU memory models, tile mapping, attribute colorization, sprite multiplexing, and virtual palette management.

---

## 1. Architectural Overview: Emulating the NES PPU on VIC-II

The NES PPU (Picture Processing Unit) and the C64 VIC-II are fundamentally different display processors. Rather than rewriting every game screen from scratch, our strategy is to **emulate the logical abstractions of the NES PPU pipeline using C64 hardware primitives**:

```
┌─────────────────────────────────┬─────────────────────────────────┐
│ NES PPU Concept                 │ C64 Emulation Counterpart       │
├─────────────────────────────────┼─────────────────────────────────┤
│ PPU Name Tables (32×30 tiles)   │ Screen RAM (40×25 characters)   │
│ Attribute Tables (16×16 blocks) │ Color RAM ($D800, 8×8 cells)    │
│ Pattern Tables (512 tiles)      │ Charset RAM (256) + Sprite Pool │
│ OAM Buffer (64 sprites)         │ Shadow Sprite Table + Raster IRQ│
│ Palette RAM ($3F00-$3F1F)       │ Virtual Palette System          │
└─────────────────────────────────┴─────────────────────────────────┘
```

---

## 2. PPU RAM vs. Screen RAM (32×30 vs. 40×25 Tiles)

### Resolution & Grid Comparison
* **NES PPU:** 32 columns $\times$ 30 rows ($256 \times 240$ pixels).
* **C64 VIC-II:** 40 columns $\times$ 25 rows ($320 \times 200$ pixels).

```
   NES PPU: 32 cols x 30 rows           C64 VIC-II: 40 cols x 25 rows
┌──────────────────────────────┐     ┌────────────────────────────────────┐
│      [Outer CRT Border]      │     │  Border (Hardware)                 │
│  ┌────────────────────────┐  │     │  ┌──────────────────────────────┐  │
│  │ Active Gameplay UI     │  │     │  │ Centered Gameplay UI         │  │
│  │ (typically 28x26 tiles)│  │     │  │ (Widened horizontally,       │  │
│  │                        │  │     │  │  compacted vertically)       │  │
│  └────────────────────────┘  │     │  └──────────────────────────────┘  │
│      [Outer CRT Border]      │     │  Border (Hardware)                 │
└──────────────────────────────┘     └────────────────────────────────────┘
```

### Addressing CRT Overscan & Positioning
1. **NES CRT Overscan:** 
   * On authentic CRT televisions, the top/bottom 1–2 rows and left/right 1–2 columns of the NES 32×30 grid were hidden by television bezels. Commercial NES games centered their primary UI in an inner 28×24 / 28×26 tile area.
2. **C64 Natural Borders:**
   * The C64 has a built-in hardware border (`$D020`). All 40×25 characters sit fully within the visible active raster area.
3. **Horizontal Translation (40 vs. 32):**
   * We gain **+8 horizontal columns**.
   * Windows and dialogs can be centered symmetrically (e.g., 4 columns of margin on the left, 4 on the right).
   * Box widths can be expanded from 10 tiles to 12 or 14 tiles to give characters, names, and cursors ample breathing room.
4. **Vertical Translation (25 vs. 30):**
   * We lose **5 vertical rows**.
   * Elements cannot be directly mapped 1:1 on the Y axis; they must be **nudged and compacted**.
   * Unnecessary vertical blank rows from the NES layout are trimmed, margins are kept to 1–2 rows, and window heights are carefully tuned (e.g., 10 or 11 rows per box) so menus fit within the 25-row ceiling.

---

## 3. Tile Memory vs. Character RAM (512 vs. 256 Tiles)

### The 512-Tile Problem
* On the NES, CHR-ROM/RAM provides two 256-tile pattern tables ($512$ tiles total).
* Pattern Table 0 (`$0000–$0FFF`) is typically assigned to background tiles ($256$ tiles).
* Pattern Table 1 (`$1000–$1FFF`) is assigned to sprites ($256$ tiles).
* On the C64, VIC-II text mode can only reference **256 character codes ($00–$FF)** at a time (2 KB).

### The C64 Sprite Workaround
* **On the C64, sprites do not share the character generator space.**
  * The VIC-II fetches sprite bitmaps from independent 64-byte blocks anywhere within the active 16 KB bank.
  * In Bank 1 (`$4000–$7FFF`), the character generator occupies `$4800–$4FFF` (256 characters), while sprites reside in the **Graphic Pool at `$5800–$5FFF`** (32 blocks of 64 bytes each).
* Because sprites are decoupled from character generator RAM, **the entire 256-character table is dedicated exclusively to background tiles, font characters, and window borders**.

---

## 4. Attribute RAM vs. Color RAM

### Color Depth & Cell Granularity
* **NES Attribute Tables:**
  * Control $2 \times 2$ tile areas ($16 \times 16$ pixels).
  * Each 16×16 area selects 1 of 4 palettes (each containing 3 unique colors + 1 universal background color).
* **C64 Color RAM (`$D800–$DBE7`):**
  * Controls color at the single $8 \times 8$ character cell level.
  * In standard text mode, only 1 foreground color per cell can be set against a global background color.

### MultiColor Character Mode ($4 \times 8$ Double-Wide Pixels)
To emulate the 4-color richness of NES background tiles (world maps, battle backdrops, monster portraits):
1. **MultiColor Mode** divides each 8×8 tile into $4 \times 8$ double-wide pixels with 4 simultaneous colors:
   * `%00`: Background Color 0 (`$D021`) — Global across the screen.
   * `%01`: Background Color 1 (`$D022`) — Global across the screen.
   * `%10`: Background Color 2 (`$D023`) — Global across the screen.
   * `%11`: **Individual Cell Color (`$D800`)** — Unique per $8 \times 8$ cell!
2. **Monster & Tile Recoloring:**
   * Monster graphics and battle backdrops are drawn using the 3 global background registers for base outlines and shading.
   * The 4th color (`%11`) is driven entirely by Color RAM (`$D800`).
   * **Result:** Changing the Color RAM value across a monster's tiles dynamically shifts its color identity (e.g., Goblin vs. Guard, Red Dragon vs. Blue Dragon), perfectly recreating NES palette swaps!

---

## 5. OAM RAM vs. VIC-II Sprite System

The sprite subsystem represents the largest architectural divide between the two systems:
* **NES PPU:** 64 hardware sprites, 4 colors per sprite, 8 sprites per scanline ($8 \times 8$ or $8 \times 16$).
* **C64 VIC-II:** 8 hardware sprites total, max 8 per scanline ($24 \times 21$ pixels).

```
   NES Meta-Sprite (2x3 tiles)           C64 4-Sprite Hero Stack
   16 px wide x 24 px high               24 px wide x 42 px high
   ┌────────┬────────┐                   ┌──────────────────────────────┐
   │ Tile 1 │ Tile 2 │ (Upper)           │  Sprite 0: Body   (Layer 0)  │
   ├────────┼────────┤                   │  Sprite 2: Skin   (Layer 2)  │ (Y + dY)
   │ Tile 3 │ Tile 4 │ (Mid)             │  Sprite 3: Accent (Layer 3)  │
   ├────────┼────────┤                   ├──────────────────────────────┤
   │ Tile 5 │ Tile 6 │ (Lower)           │  Sprite 1: Feet   (Layer 1)  │ (Y + 21)
   └────────┴────────┘                   └──────────────────────────────┘
```

### The Hero Sprite Stack (3 Sprites per Hero)
All Class 1 heroes are redrawn to fit cleanly into the native C64 $24 \times 21$ sprite box (stored as binary in `res/heroes/class1.spr`). Each hero is a **3-sprite hi-res overlay composite** without any spillover feet sprite:
1. **Layer 0 (Base / Body):** Clothes, tunic, robe, base armor.
2. **Layer 1 (Skin / Accent):** Face, arms, exposed skin, secondary accents.
3. **Layer 2 (Highlight / Trim):** Weapons, highlights, hair, robe trim.
*Layers are drawn in Hi-Res mode ($1 \times 1$ crisp pixels) aligned at $(dX=0, dY=0)$.*

### Native 21-Line Alignment (Zero Feet Spillover & Zero Layer Offsets)
* By fitting the art within 21 lines, there is no need for a 4th "feet" sprite at $Y+21$.
* All 3 layers share identical origin coordinates $(dX=0, dY=0)$, completely eliminating the previous White Mage $+3$ vertical offset snag.
* In the **Party Generation Screen**, Hero 0 (3 sprites) + Hero 1 (3 sprites) + Finger Cursor (2 sprites) = **8 sprites total**, displaying simultaneously without mid-character raster collisions.

---

### The Expanded Virtual OAM Buffer (8 Bytes per Slot)

To allow room for future expansion beyond the NES's 4-byte OAM entries (and to enable ultra-fast power-of-2 $8 \times N$ indexing via `ASL A, ASL A, ASL A`), each Virtual Sprite entry is formatted as an **8-byte descriptor**:

```assembly
; ==============================================================================
; Virtual OAM Entry Format (8 bytes per hardware sub-sprite)
; ==============================================================================
; Offset  Name          Description
; +$00    spr_x_lo      Horizontal pixel coordinate low byte (0-255)
; +$01    spr_x_hi      Horizontal pixel coordinate MSB bitmask (%00000001)
; +$02    spr_y         Vertical scanline coordinate (0-255)
; +$03    spr_ptr       VIC-II 64-byte block pointer (e.g., $60-$7F in Bank 1)
; +$04    spr_col       Native C64 hardware color (0-15: Red, Peach, Cyan, etc.)
; +$05    spr_flags     Render flags: %00000000 = Hi-Res, %00000001 = MultiColor,
;                                     %00000010 = Behind BG, %10000000 = Active/Visible
; +$06    spr_dx        Relative X offset from parent actor origin (signed -128..+127)
; +$07    spr_dy        Relative Y offset from parent actor origin (signed -128..+127)
```

#### Actor Budget:
* **4 Heroes:** 4 sub-sprites each = 16 sub-sprites ($16 \times 8 = 128$ bytes).
* **1 Cursor (Finger):** 2 sub-sprites (Base + Overlay) = 2 sub-sprites ($2 \times 8 = 16$ bytes).
* **Total Buffer Size:** **18 Virtual Sprite Slots = 144 bytes**.
* **Memory Placement:** Allocated at `$0340–$03CF` (the C64 tape buffer area, completely clear of KERNAL vectors at `$0300–$0333` and zero page).

---

### Native C64 Color Tables (Zero Runtime Translation)

Rather than translating NES master color codes ($00–$3F) through `lut_NES_to_C64` every frame, the hero sprite lookup tables store **native C64 hardware color numbers (0–15)** directly:

```assembly
lut_HeroClassSprites:
    ; Fighter (Class 0):
    ;          Block Pointer,       Color,               dX,  dY
    .byte      BLOCK_FGT_BODY,      COLOR_RED,            0,   0   ; Layer 0: Body
    .byte      BLOCK_FGT_FEET,      COLOR_RED,            0,  21   ; Layer 1: Feet
    .byte      BLOCK_FGT_SKIN,      COLOR_PEACH,          0,   0   ; Layer 2: Skin
    .byte      BLOCK_FGT_ACCENT,    COLOR_LIGHT_GREY,     0,   0   ; Layer 3: Hilight

    ; White Mage (Class 4) - Handling the atypical offset:
    .byte      BLOCK_WHM_BODY,      COLOR_WHITE,          0,   0   ; Layer 0: Body
    .byte      BLOCK_WHM_FEET,      COLOR_WHITE,          0,  21   ; Layer 1: Feet
    .byte      BLOCK_WHM_ACCENTS,   COLOR_RED,            0,   3   ; Layer 2: Red Accents (dY=+3!)
    .byte      BLOCK_WHM_SKIN,      COLOR_PEACH,          0,   0   ; Layer 3: Skin
```

---

### Solving the Scanline Multiplexing Clash: Moving the Finger to the Class Name

In the Party Generation screen, displaying all 4 heroes plus the finger cursor presents a critical hardware bottleneck:
* Hero 0 (Left) and Hero 1 (Right) upper bodies require **6 hardware sprites** simultaneously ($3 + 3 = 6$).
* The Finger Cursor requires **2 hardware sprites** (Base + Overlay).
* If the finger cursor sits at the hero sprite's vertical coordinate ($Y \approx 90$), total active sprites on those scanlines reaches $6 + 2 = \mathbf{8 \text{ sprites}}$, leaving zero margin and triggering multiplexer timing collisions with atypical offsets like the White Mage ($Y+3$).

#### The Architectural Solution:
**Move the finger cursor up to point at the Class Name text!**

```
 Scanline
    │
 Y ≈ 74   [ > FIGHTER ] (Cursor pointing at text)   [   THIEF   ]
          Sprites 0 & 1: Finger Cursor (Scanlines 74-89)
          ─────────────────────────────────────────────────────────────────
 Y ≈ 90   [Hero 0 Upper Body]                       [Hero 1 Upper Body]
          Sprites 0, 2, 3 (TL)                      Sprites 4, 6, 7 (TR)
          (Scanlines 90-110: 6 hardware sprites active, 0 cursor conflict!)
          ─────────────────────────────────────────────────────────────────
 Y ≈ 111  [Hero 0 Feet]                             [Hero 1 Feet]
          Sprite 1 (TL)                             Sprite 5 (TR)
          (Scanlines 111-131: 2 hardware sprites active)
          ─────────────────────────────────────────────────────────────────
 Y ≈ 145  === MID-FRAME RASTER IRQ (Window Gap) ===
          Reassign VIC-II Registers 0-7:
            • New Y coordinates (+104 scanlines down to Bottom Boxes)
            • New Sprite Pointers & Colors for Hero 2 & Hero 3
          ─────────────────────────────────────────────────────────────────
 Y ≈ 178  [ > Bl.BELT ] (If bottom slot active)     [   RedMAGE ]
 Y ≈ 194  [Hero 2 Upper Body]                       [Hero 3 Upper Body]
 Y ≈ 215  [Hero 2 Feet]                             [Hero 3 Feet]
```

#### Why This Cleanly Resolves the Architecture:
1. **Zero Scanline Overlap:** The cursor occupies scanlines 74–89. The hero upper bodies begin at scanline 90. They never share a single raster line!
2. **Complete Parity with Battle:** In Battle, the heroes are stacked in a single vertical column (Hero 0 at Y≈60, Hero 1 at Y≈100, Hero 2 at Y≈140, Hero 3 at Y≈180). Reusing this same multiplexer logic simply steps the raster split down through each hero slot.
3. **Intuitive UI:** Pointing the finger directly at the class name (`> FIGHTER`) clearly signals to the player that directional input is changing the hero class.

---

## 6. Palette Management: The Virtual Palette System

### The Challenge
* The NES has dedicated Palette RAM at `$3F00–$3F1F` storing 32 color entries (4 background palettes and 4 sprite palettes of 4 colors each).
* The C64 has no internal palette RAM; colors are fixed hardware registers (`$D020–$D02E`) and the nybble-wide Color RAM (`$D800`).

### The Virtual Palette Architecture
We maintain an in-memory **Virtual Palette Table** (`cur_pal`, 32 bytes) matching the NES layout:

```assembly
cur_pal:        .res 32     ; Virtual Palette Buffer (matching NES $3F00-$3F1F)
; $00-$0F: Background Palettes 0-3 (4 bytes each)
; $10-$1F: Sprite Palettes 0-3     (4 bytes each)
```

```
[NES Game Code / Script]
          │
          │  Writes palette indices (e.g. LoadMenuCHRPal, FadeInBatSprPalettes)
          ▼
[Virtual Palette RAM (cur_pal)]
          │
          │  Translation Driver (DrawPalette / FlushPalette)
          ▼
┌──────────────────────────────────────────────────────────────────┐
│ VIC-II Hardware Mapping:                                         │
│ • Universal BG Color (cur_pal+0) ──> BGCOL0 ($D021) & EXTCOL    │
│ • Menu/Map Shared Accents        ──> BGCOL1 ($D022), BGCOL2 ($D023)│
│ • Cell Colors                    ──> Color RAM ($D800)           │
│ • Sprite Shared Multicolor       ──> SPMC0 ($D025), SPMC1 ($D026)│
│ • Unique Sprite Colors           ──> SP0COL-SP7COL ($D027-$D02E) │
└──────────────────────────────────────────────────────────────────┘
```

---

## 7. Two-Stage Sprite Execution Pipeline

Mirroring the NES architecture, sprite processing is cleanly split into two distinct stages:

```
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: GRAPHIC POOL ALLOCATION (Asset Loading)                       │
│ Triggered on scene / map / battle transition                           │
│ Cartridge ROM Banks ──> VIC-II Bank 1 RAM ($5800-$5FFF, Blocks 96-127) │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ STAGE 2: ACTIVE DISPLAY LIST (Shadow Buffer Generation)                │
│ Runs every frame during game logic                                     │
│ Game logic writes: shadow_spr_x, shadow_spr_y, shadow_spr_ptr, etc.    │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ VBLANK / RASTER IRQ FLUSH (Hardware Execution)                         │
│ UpdateSprites flushes shadow state to VIC-II hardware registers        │
└────────────────────────────────────────────────────────────────────────┘
```

### Fast Pointer Assignment
Drawing a sprite does **not** copy 64 bitmap bytes per frame. Instead, bitmaps remain stationary in the Graphic Pool, and routines assign a 1-byte block pointer:
```assembly
lda #BLOCK_HERO_BODY
sta shadow_spr_ptr, x
```
This takes **6 CPU cycles**, achieving full performance parity with the NES writing a tile index into `oam`.

---

## 8. Routine Parity Mapping Summary

| NES Routine | Original NES Behavior | C64 Parity Implementation |
| :--- | :--- | :--- |
| **`ClearNT`** | Writes spaces to Name Table and zero-fills attributes | Writes solid block `$00` / blank `$FF` to Screen RAM `$4000`, clears Color RAM `$D800` |
| **`ClearOAM`** | Sets 64 OAM sprite Y coords to `$F8` (offscreen) | Clears `shadow_spr_en = $00`, resets `sprindex = 0` |
| **`DrawCursor`** | Writes 4 tiles ($2 \times 2$) to OAM buffer | Allocates 2 sprite slots (Base + Overlay), sets block pointers & coordinates |
| **`DrawBox`** | Writes border tiles and clear interior to PPU NT | Writes border characters ($F7–$FD) to Screen RAM and `$FF` to interior cells |
| **`DrawOBSprite`** / **`DrawSimple2x3Sprite`** | Emits 6 tiles ($2 \times 3$) to OAM with palette | Sets 4 sprite slots (3 upper body + 1 feet) or triggers raster IRQ multiplexer |
| **`UpdateSprites`** | Triggers `$4014` PPU OAM DMA during VBlank | Raster IRQ flushes `shadow_spr_*` to VIC-II registers (`$D000–$D02E`, `$43F8–$43FF`) |
| **`DrawPalette`** | Writes palette table to PPU `$3F00` | Translates `cur_pal` entries into VIC-II register values and Color RAM |
