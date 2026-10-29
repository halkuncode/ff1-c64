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

---

## 5. Vehicle & Special Map Sprites Architecture

Vehicle and map transition sprites are stored in `res/maps/vechicles/vechicles.spr`.
Like the heroes, each vehicle visual object uses the **2-layer composite architecture**:
* **Layer 0 (Outline):** Hi-res (single-color) sprite, dedicated to a crisp black outline (`COLOR_BLACK = $00`).
* **Layer 1 (Base Fill):** Multicolor sprite, rendering the colors using shared and custom registers.

### Total Sprite Count & Memory
* **Total Visual Objects / Poses:** 26 objects/frames
* **Sprites per Object:** 2 sprites (1 Hi-Res Outline + 1 Multicolor Base)
* **Total Sprites:** $26 \times 2 = 52 \text{ sprites}$
* **Total ROM Size:** $52 \times 64 \text{ bytes} = 3,328 \text{ bytes}$ (`res/maps/vechicles/vechicles.spr`)

### Vehicle Palette & Color Register Architecture
All 52 sprites share a unified palette configuration:
* **Hi-Res Outline Sprite:** Individual Sprite Color Register = `COLOR_BLACK` (`$00`).
* **Multicolor Base Sprite:**
  * **Multicolor 1 (`$D025` / `SPMC0`):** White (`$01`)
  * **Multicolor 2 (`$D026` / `SPMC1`):** Brown (`$08` / C64 Color 9 / Orange-Brown)
  * **Custom Color (`SPxCOL`):** Green (`$05`)

*(Note: Depending on context, when a vehicle is boarded, the vehicle sprites replace or overlay the mapman sprites, or are loaded into dedicated VIC-II sprite slots).*

---

## 6. Vehicle Sprite Layout & NES Mirroring Table (52 Sprites)

The 52 sprites directly mirror the NES sprite sheet layout and numbering:

| Index | Visual Object / Pose | Direction / Animation Frame | Layer 0 (Hi-Res Outline) | Layer 1 (Multicolor Base) |
| :---: | :--- | :--- | :---: | :---: |
| **0** | **Airship Shadow** | Static shadow below airship | Sprite 0 | Sprite 1 |
| **1** | **Bridge** | World map bridge object | Sprite 2 | Sprite 3 |
| **2** | **Canal** | Blown canal cutscene / transition | Sprite 4 | Sprite 5 |
| **3** | **(Blank)** | Blank placeholder (matches NES) | Sprite 6 | Sprite 7 |
| **4** | **Ship** | North, Frame 1 | Sprite 8 | Sprite 9 |
| **5** | **Ship** | North, Frame 2 | Sprite 10 | Sprite 11 |
| **6** | **Ship** | South, Frame 1 | Sprite 12 | Sprite 13 |
| **7** | **Ship** | South, Frame 2 | Sprite 14 | Sprite 15 |
| **8** | **Ship** | East, Frame 1 | Sprite 16 | Sprite 17 |
| **9** | **Ship** | East, Frame 2 | Sprite 18 | Sprite 19 |
| **10** | **Ship** | West, Frame 1 | Sprite 20 | Sprite 21 |
| **11** | **Ship** | West, Frame 2 | Sprite 22 | Sprite 23 |
| **12** | **Airship** | North, Frame 1 | Sprite 24 | Sprite 25 |
| **13** | **Airship** | North, Frame 2 | Sprite 26 | Sprite 27 |
| **14** | **Airship** | South, Frame 1 | Sprite 28 | Sprite 29 |
| **15** | **Airship** | South, Frame 2 | Sprite 30 | Sprite 31 |
| **16** | **Airship** | East, Frame 1 | Sprite 32 | Sprite 33 |
| **17** | **Airship** | East, Frame 2 | Sprite 34 | Sprite 35 |
| **18** | **Airship** | West, Frame 1 | Sprite 36 | Sprite 37 |
| **19** | **Airship** | West, Frame 2 | Sprite 38 | Sprite 39 |
| **20** | **Canoe** | North, Frame 1 | Sprite 40 | Sprite 41 |
| **21** | **Canoe** | North, Frame 2 | Sprite 42 | Sprite 43 |
| **22** | **Canoe** | South, Frame 1 | Sprite 44 | Sprite 45 |
| **23** | **Canoe** | South, Frame 2 | Sprite 46 | Sprite 47 |
| **24** | **Canoe** | East/West, Frame 1 (shared) | Sprite 48 | Sprite 49 |
| **25** | **Canoe** | East/West, Frame 2 (shared) | Sprite 50 | Sprite 51 |

