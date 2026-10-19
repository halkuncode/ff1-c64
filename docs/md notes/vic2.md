# VIC-II Video & Color Memory Management Architecture

This document outlines the display architecture, memory layouts, color translation, and raster-split techniques for porting NES Final Fantasy 1's PPU graphics to the Commodore 64 VIC-II.

---

## 1. Visual Strategy Overview

NES Final Fantasy 1 uses a 256×240 resolution with 4-color palettes for both background tiles (1 shared + 3 colors per 16×16 attribute block) and sprites. 

To achieve visual fidelity on the C64 without sacrificing character readability, we use a **hybrid display strategy**:
1. **Background Worlds (Overworld, Towns, Dungeons)**: **MultiColor Character Mode** (160×200 "double-wide" pixels). Each 8×8 cell gets 4 colors, matching the NES 4-color-per-tile structure.
2. **Dialogue & Menus**: **Hi-Res Character Mode** (320×200 single-width pixels) via mid-frame **Raster Mode Switching** so text remains crisp and legible.
3. **Sprites (Party Members & NPCs)**: **Layered / Overlaid Sprites** (stacking two hardware sprites at the same coordinate) to achieve 4 colors with crisp outlines.
4. **Battle Screen**: MultiColor "double-wide" background/tiles for large monster graphics on the left, paired with overlaid sprites for party members on the right.

---

## 2. Memory Organization & VIC-II Banking

The VIC-II chip can only address a **16 KB window** of memory at any given moment, controlled by CIA2 Port A (`$DD00` bits 0–1):

| Bank | Address Range | Notes & Hazards | Suitability |
| :--- | :--- | :--- | :--- |
| **Bank 0** | `$0000`–`$3FFF` | Contains ZP (`$00-$FF`), Stack (`$0100`), Screen RAM (`$0400`), Kernel (`$1000-$4FFF`) | Standard, but Kernel occupies `$1000-$4FFF` |
| **Bank 1** | `$4000`–`$7FFF` | **Pure RAM** (No ROM shadows). Contains Save RAM (`$6000-$67FF`) | **Recommended for Game Worlds** |
| **Bank 2** | `$8000`–`$BFFF` | EasyFlash Cartridge ROM window sits here! | Unusable (ROM shadows) |
| **Bank 3** | `$C000`–`$FFFF` | Contains I/O / Color RAM CPU space (`$D000`), RAM underneath | Usable for Menus / Alt screens |

---

### Recommended VIC-II Memory Layout: Bank 1 (`$4000`–`$7FFF`)

Setting CIA2 `$DD00 = $02` (bits 1–0 = `10` binary, inverted logic) selects **Bank 1** (`$4000`–`$7FFF`):

```
VIC-II Bank 1 ($4000 - $7FFF)
┌─────────────────────────────────────────────────────────────┐
│ $4000 - $43E7 : Screen RAM 0 (Default Screen, 1000 bytes)   │
│ $43F8 - $43FF : Sprite Pointers for Screen 0 (8 bytes)      │
├─────────────────────────────────────────────────────────────┤
│ $4400 - $47E7 : Screen RAM 1 (Double-buffering / Menus)     │
│ $47F8 - $47FF : Sprite Pointers for Screen 1 (8 bytes)      │
├─────────────────────────────────────────────────────────────┤
│ $4800 - $4FFF : Character Set 0 (Map / World Tiles, 2 KB)   │
├─────────────────────────────────────────────────────────────┤
│ $5000 - $57FF : Character Set 1 (Font & Dialogue Tiles, 2 KB│
├─────────────────────────────────────────────────────────────┤
│ $5800 - $5FFF : Sprite Graphics Data (32 sprites x 64 bytes)│
├─────────────────────────────────────────────────────────────┤
│ $6000 - $63FF : [CPU ONLY] unsram (Active Game State)       │
│ $6400 - $67FF : [CPU ONLY] sram   (Packed Save Slot)        │
├─────────────────────────────────────────────────────────────┤
│ $6800 - $7FFF : Monster Graphics / Battle Buffer Data       │
└─────────────────────────────────────────────────────────────┘
```

#### Why Bank 1 is Optimal:
1. **No ROM interference**: Unlike Bank 0 and Bank 2, Bank 1 has no hardware Character ROM shadows. The VIC-II sees 100% genuine RAM.
2. **Coexists with Save RAM**: The VIC-II ignores memory ranges it isn't pointed to, so having `unsram` and `sram` at `$6000`–`$67FF` causes zero interference.
3. **Double-Buffering Ready**: Screen 0 (`$4000`) and Screen 1 (`$4400`) easily fit side-by-side for glitch-free map transitions.

---

### The Fixed Color RAM ($D800–$DBE7)

Unlike Screen RAM and Character Sets, **Color RAM is hardwired at `$D800`–`$DBE7`** (1000 nybbles, 4 bits per cell):
* It **never moves**, regardless of which 16 KB bank is selected in `$DD00`.
* In MultiColor Character mode, the lower 4 bits of `$D800 + offset` define the **4th color** (individual color) for that character cell.

---

## 3. Color Translation: NES PPU vs. C64 VIC-II

### The Color Model Comparison

| Hardware | Colors per 8×8 Tile | Color Sources | Total Palette Range |
| :--- | :--- | :--- | :--- |
| **NES PPU** | 4 colors per cell | 1 universal background + 3 colors from 1 of 4 palettes | 64 master colors (8 luminance steps) |
| **C64 MultiColor** | 4 colors per cell | 3 shared global colors + 1 individual cell color | 16 fixed hardware colors |

```
MultiColor Tile Pixel Pair (2x1 "Double-Wide"):
  %00 = Background Color 0 ($D021)  --> Shared across entire screen
  %01 = Background Color 1 ($D022)  --> Shared across entire screen
  %10 = Background Color 2 ($D023)  --> Shared across entire screen
  %11 = Individual Cell Color ($D800) --> Unique to each 8x8 tile!
```

### Tileset Color Optimization Strategy
To match NES tilesets (Overworld, Grass, Water, Mountains, Castles):
1. **Set `$D021` (Color 0)** to the dominant ground color (e.g., Green for Overworld, Cobblestone Grey for Towns, Dark Blue for Ocean).
2. **Set `$D022` and `$D023` (Colors 1 & 2)** to common accents (e.g., Light Green / Tan for dirt roads and mountains).
3. **Use Color RAM (`$D800`)** for the unique element in each tile (e.g., Blue for water tiles, Grey for stone, Red for roofs).

---

## 4. Sprite Architecture: 4-Color Characters via Overlays

A single C64 MultiColor sprite has 3 colors (2 shared + 1 individual), but pixels are chunky 2×1 blocks. A standard Hi-Res sprite has fine 1×1 pixels, but only 1 color.

### The Overlay Technique (Two Sprites per Character)
To achieve crisp, 4-color party members and NPCs with fine detail:
* **Sprite Layer 1 (MultiColor)**: Carries the skin tone, hair, and clothing body colors.
* **Sprite Layer 2 (Hi-Res)**: Placed at the exact same $(X, Y)$ coordinate. Carries black/dark outlines, eyes, and weapon edges in crisp 1×1 resolution.

```
       [Sprite Layer 1]               [Sprite Layer 2]                 [Final Composite]
     (MultiColor 12x21)              (Hi-Res 24x21 Outline)          (Overlaid on Screen)
   Skin, Armor, Tunic Colors         Dark Outlines & Eyes           Crisp, 4-Color Hero!
```

#### Sprite Allocation (8 Hardware Sprites):
* **Field / Overworld**:
  * Sprites 0 & 1: Hero Layer 1 (MultiColor) + Hero Layer 2 (Hi-Res Outline)
  * Sprites 2 & 3: Vehicle / Ship / Canoe overlay
  * Sprites 4, 5, 6, 7: Available for NPCs / monsters (via raster multiplexer)

---

## 5. Mid-Frame Raster Mode Switching ("Dialogue Split")

### The Problem
If the dialogue window at the top of the screen is rendered in MultiColor mode, text is double-wide, chunky, and difícil to read.

### The Solution: Scanline Mode Switch
The C64 VIC-II allows changing display modes mid-frame using a **Raster Interrupt**:

```
Scanline 0 - 64:   DIALOGUE / STATUS WINDOW
                   - Hi-Res Text Mode ($D016 bit 4 = 0)
                   - Character set points to Font ($5000)
                   - Crisp, single-pixel text and thin box borders
───────────────────────────────────────────────────────────────────  ◄── RASTER SPLIT (Line 65)
Scanline 65 - 250: GAME WORLD (Overworld / Town / Dungeon)
                   - MultiColor Mode ($D016 bit 4 = 1)
                   - Character set points to Map Tiles ($4800)
                   - 4-color double-wide tiles for full world color!
```

---

## 6. Module-by-Module Execution Summary

| Game Module | Background Mode | Sprite Strategy | Color Scheme |
| :--- | :--- | :--- | :--- |
| **Overworld** | MultiColor Character (160×200) | Overlaid Hero (2 sprites) + Vehicle | `$D021` = Green; Color RAM for oceans, mountains, trees |
| **Towns / Dungeons** | MultiColor Character (160×200) + Top Raster Text Split | Overlaid Hero + Multiplexed NPCs | Top 8 rows = Hi-Res Text; Bottom 17 rows = MultiColor Map |
| **Main Menus** | Full Hi-Res Character (320×200) | Multiplexed character portraits | Clean dark blue background (`$D021 = 6`), white text |
| **Battle Screen** | MultiColor Background (Monsters) | 4 Hero Party Overlaid Sprites on Right | Left side = MultiColor monster art; Right side = Animated hero sprites |

