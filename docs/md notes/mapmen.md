# Final Fantasy (C64) - Mapmen Sprite Architecture & Loading Strategy

## 1. Overview & Sprite Math
On the NES, the PPU supports hardware X/Y flipping via OAM attribute bits. On the Commodore 64 VIC-II, there is no hardware sprite flipping. Hero sprites must be pre-baked in ROM for all facing directions to avoid expensive runtime software bit-reversals.

Each hero class uses a 3-layer sprite overlay to achieve full color fidelity (e.g. base body, clothing/skin accents, hair/hat highlights):

* **Layers:** 3 hardware sprites per frame (Layer 0, Layer 1, Layer 2)
* **Directions:** 4 directions (Down, Up, Left, Right)
* **Frames:** 2 walk cycle animation frames per direction
* **Sprites per class:** $3 \text{ layers} \times 4 \text{ directions} \times 2 \text{ frames} = 24 \text{ sprites}$
* **Memory per class:** $24 \text{ sprites} \times 64 \text{ bytes} = 1,536 \text{ bytes}$ ($1.5 \text{ KB}$)

With 12 total classes (6 basic + 6 promoted after Bahamut's trial):
* **Total sprites:** $12 \text{ classes} \times 24 \text{ sprites} = 288 \text{ sprites}$
* **Total ROM space:** $288 \times 64 \text{ bytes} = 18,432 \text{ bytes}$ ($\approx 18 \text{ KB}$)

---

## 2. ROM Banking Strategy
An EasyFlash cartridge bank holds 16 KB ($16,384 \text{ bytes}$). Because all 12 classes require 18 KB, they are naturally split across two cartridge banks:

* **Bank A (Standard Classes):** Classes 0–5 (Fighter, Thief, Black Belt, Red Mage, White Mage, Black Mage)
  * Size: $6 \times 1,536 \text{ bytes} = 9,216 \text{ bytes}$ ($\approx 9 \text{ KB}$)
* **Bank B (Promoted Classes):** Classes 6–11 (Knight, Ninja, Master, Red Wizard, White Wizard, Black Wizard)
  * Size: $6 \times 1,536 \text{ bytes} = 9,216 \text{ bytes}$ ($\approx 9 \text{ KB}$)

### Self-Contained Bank Loaders (Code Duplication)
To avoid unnecessary cross-bank trampoline calls or putting extra loader code into the fixed RAM bank (`Bank 0F` / `KERNEL`), each mapman bank will contain its own copy of the extraction loader routine:
1. Caller (e.g. `LoadPlayerMapmanCHR`) determines the leader's class ID.
2. If class $< 6$, swap in **Bank A**; if class $\ge 6$, swap in **Bank B**.
3. Call the localized loader routine within that bank.
4. The loader copies the 1,536 bytes (24 sprites) directly into VIC-II Character/Sprite RAM.
5. Restore the caller's previous PRG bank.

Because EasyFlash cartridges offer up to 1 MB (64 banks), duplicating a small ~60-byte copy routine in each bank is practically free.

---

## 3. VIC-II RAM Caching (The Active Leader)
Only the lead party member is visible on the overworld and town/dungeon exploration maps. Therefore, only **one character's 24 sprites (1,536 bytes)** need to reside in VIC-II RAM at any given time.

### Why cache all 24 sprites (1.5 KB) instead of 6 sprites (384 B)?
* **Zero in-game copying:** When the player changes direction (pressing W/A/S/D) or steps into the next walk frame, **no copying and no bank switching occurs**. The engine simply writes 3 sprite pointers:
  ```ca65
  LDA lut_LeaderSpritePointers + (direction * 6) + (anim_frame * 3) + 0
  STA $43F8   ; Layer 0 (Base)
  LDA lut_LeaderSpritePointers + (direction * 6) + (anim_frame * 3) + 1
  STA $43F9   ; Layer 1 (Accents)
  LDA lut_LeaderSpritePointers + (direction * 6) + (anim_frame * 3) + 2
  STA $43FA   ; Layer 2 (Highlights)
  ```
* **Affordable RAM cost:** In VIC-II Bank 1 (`$4000–$7FFF`), Character tiles take `$4800–$4FFF` (2 KB) and Screen RAM takes `$4000–$43E7` (1 KB). Over 12 KB remains free (`$5000–$7FFF`) for sprites, buffers, and variables.
* **When cache is refreshed:**
  1. Entering a map (overworld, town, dungeon).
  2. Rearranging party order in the menu screen.
  3. Bahamut class promotion sequence.
  *(All occur during transitions/fades where a 1.5 KB copy takes a fraction of a frame and is completely invisible).*

