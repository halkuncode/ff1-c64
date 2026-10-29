# Final Fantasy (C64) - Mapmen Sprite Architecture & Loading Strategy

## 1. Overview & Sprite Math
On the NES, the PPU supports hardware X/Y flipping via OAM attribute bits. On the Commodore 64 VIC-II, there is no hardware sprite flipping. All facing directions and animation frames are pre-baked in ROM.

To optimize sprite count and memory while maintaining crisp visual quality:
* **2-Layer Composition per Pose:**
  * **Layer 0 (Outline):** Hi-res (single-color) sprite, dedicated to a crisp black outline (`COLOR_BLACK = 0`).
  * **Layer 1 (Base Fill):** Multicolor sprite, rendering the body, clothing, skin, and hair colors.
* **Directions:** 4 directions (South/Down, North/Up, West/Left, East/Right).
* **Walk Cycle:** 2 animation frames per direction (Frame 0 = Standing / Step A, Frame 1 = Step B).
* **Sprites per Hero:** 
  $$\text{Sprites} = 2 \text{ layers} \times 4 \text{ directions} \times 2 \text{ frames} = 16 \text{ sprites}$$
* **Memory per Hero:** 
  $$\text{Memory} = 16 \text{ sprites} \times 64 \text{ bytes} = 1,024 \text{ bytes (1.0 KB)}$$

### Class 1 Heroes (6 Basic Classes)
1. **Fighter** (Sprites 0–15)
2. **Thief** (Sprites 16–31)
3. **Black Belt** (Sprites 32–47)
4. **Red Mage** (Sprites 48–63)
5. **White Mage** (Sprites 64–79)
6. **Black Mage** (Sprites 80–95)

* **Total Sprites for Class 1:** $6 \text{ classes} \times 16 \text{ sprites} = 96 \text{ sprites}$
* **Total ROM Size:** $96 \times 64 \text{ bytes} = 6,144 \text{ bytes (6.0 KB)}$ (stored in `res/maps/mapmen/mapmen.spr`)

---

## 2. Palette & Color Register Architecture

Because only **one hero** (the active party leader) is rendered on screen during exploration, the VIC-II sprite color registers can be dynamically loaded for that specific hero class without color conflicts:

### VIC-II Sprite Color Mapping
* **Hi-Res Outline Sprite:** Individual Sprite Color register = `COLOR_BLACK` (`$00`).
* **Multicolor Base Sprite:**
  * **Color 1:** Shared Sprite Multicolor Register 0 (`$D025` / `SPMC0`).
  * **Color 2:** Shared Sprite Multicolor Register 1 (`$D026` / `SPMC1`).
  * **Custom Color:** Individual Sprite Color Register (`SPxCOL`, e.g. `$D027`–`$D02E`).

### Class Color Specifications

| Class ID | Class Name | Color 1 (`$D025` / `SPMC0`) | Color 2 (`$D026` / `SPMC1`) | Custom Color (`SPxCOL`) |
| :---: | :--- | :--- | :--- | :--- |
| **0** | **Fighter** | Red (`$02`) | Peach (`$0A` / 10) | *Not used / Black* |
| **1** | **Thief** | Cyan (`$03`) | Peach (`$0A` / 10) | Brown (`$08`) |
| **2** | **Black Belt** | Cyan (`$03`) | Peach (`$0A` / 10) | Brown (`$08`) |
| **3** | **Red Mage** | Red (`$02`) | Peach (`$0A` / 10) | White (`$01`) |
| **4** | **White Mage** | White (`$01`) | Peach (`$0A` / 10) | *Not used / Black* |
| **5** | **Black Mage** | Blue (`$06`) | Yellow (`$07`) | Peach (`$0A` / 10) |

---

## 3. Pose & Sprite Layout per Hero (16 Sprites)

Each class contains 8 poses stored sequentially as 16 sprites (Outline first, then Base for each pose):

| Pose Index | Direction | Walk Frame | Layer 0 (Hi-Res Outline) | Layer 1 (Multicolor Base) |
| :---: | :---: | :---: | :---: | :---: |
| **0** | **South (Down)** | Frame 0 | Sprite +0 | Sprite +1 |
| **1** | **South (Down)** | Frame 1 | Sprite +2 | Sprite +3 |
| **2** | **North (Up)** | Frame 0 | Sprite +4 | Sprite +5 |
| **3** | **North (Up)** | Frame 1 | Sprite +6 | Sprite +7 |
| **4** | **West (Left)** | Frame 0 | Sprite +8 | Sprite +9 |
| **5** | **West (Left)** | Frame 1 | Sprite +10 | Sprite +11 |
| **6** | **East (Right)** | Frame 0 | Sprite +12 | Sprite +13 |
| **7** | **East (Right)** | Frame 1 | Sprite +14 | Sprite +15 |

---

## 4. VIC-II RAM Staging & Active Leader Extraction

Only the active party leader's 16 sprites (1,024 bytes) need to reside in VIC-II RAM.

### RAM Allocation in VIC-II Bank 1 (`$4000–$7FFF`)
* **Screen RAM:** `$4000–$43E7` (1 KB)
* **Screen RAM 1 (Back buffer):** `$4400–$47E7` (1 KB)
* **Character Tiles:** `$4800–$4FFF` (2 KB)
* **Active Mapman Sprite Pool:** `$5800–$5BFF` (1 KB = 16 sprites, Sprite Blocks 96–111)
  * Block 96 = `$5800 / 64`

### Zero-Copy Runtime Animation
Because all 16 sprites of the active leader are pre-loaded into `$5800–$5BFF`:
* Changing direction or walking requires **zero byte copies and zero bank switches**.
* The movement engine simply calculates the pose index:
  $$\text{Pose} = (\text{direction\_index} \times 2) + \text{anim\_frame}$$
* It sets the hardware sprite pointers:
  * Outline Pointer (`$43F8` / `$47F8`): `96 + (Pose * 2)`
  * Base Pointer (`$43F9` / `$47F9`): `96 + (Pose * 2) + 1`

### Cache Refresh Triggers
The 1,024-byte leader sprite cache is refreshed only on:
1. Entering the overworld, town, or dungeon.
2. Exiting the Lineup/Formation menu (if the party order changed).
3. Bahamut class promotion sequence.
