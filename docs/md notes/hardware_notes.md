# Final Fantasy 1: C64 Hardware Translation Architecture

This document tracks hardware mapping strategies, architectural decisions, and translation layers for porting NES Final Fantasy 1 to the Commodore 64 (EasyFlash cartridge).

---

## 1. Joystick & Input Translation

### The NES Input Abstraction
NES Final Fantasy 1 does **not** scatter raw hardware reads (`$4016`) across the codebase. Instead, input is cleanly compartmentalized into a single routine in the fixed Kernel:

1. **`UpdateJoy`** is called once per frame.
2. It polls the hardware and writes the result into five Zero Page variables:
   * **`joy`**: Raw bitmask of held directions and buttons.
   * **`joy_a`**: Incremented when **Button A** is newly pressed (action / talk / confirm).
   * **`joy_b`**: Incremented when **Button B** is newly pressed (cancel / back / close).
   * **`joy_start`**: Incremented when **Start** is newly pressed (main menu / pause).
   * **`joy_select`**: Incremented when **Select** is newly pressed (party order / minimap).
3. The rest of the game (dialogue, field movement, shops, battle commands) **only ever checks these five variables**, clearing them when consumed (e.g., `STA joy_a`).

---

### The C64 Translation Layer

On the Commodore 64, your replacement `UpdateJoy` routine simply polls the C64 hardware and writes directly into those identical five variables.

```
       C64 Hardware Sources                         NES Game Interface
┌─────────────────────────────────┐             ┌─────────────────────────┐
│ Joystick Port 2 ($DC00)         │             │ joy        (Directions) │
│   - Up, Down, Left, Right       │────────────▶│ joy_a      (Button A)   │
│   - Fire Button 1               │             │                         │
├─────────────────────────────────┤             │ joy_b      (Button B)   │
│ SID POT Lines ($D419 / $D41A)   │────────────▶│                         │
│   - Fire Button 2 (POT Ground)  │             │ joy_start  (Start)      │
├─────────────────────────────────┤             │                         │
│ CIA1 Keyboard Matrix Scan       │────────────▶│ joy_select (Select)     │
│   - RETURN / SPACE              │             └─────────────────────────┘
│   - F1 / Commodore (C=)         │
└─────────────────────────────────┘
```

#### Button Mappings

| NES Control | C64 Physical Input | Detection Method |
| :--- | :--- | :--- |
| **D-Pad** | Joystick Port 2 (Directions) | Bits 0–3 of CIA1 Data Port A (`$DC00`) |
| **Button A** (Confirm/Talk) | **Joystick Button 1 (Standard Fire)** | Bit 4 of CIA1 Data Port A (`$DC00` = 0) |
| **Button B** (Cancel/Back) | **Joystick Button 2** *(Modern 2-button pad)* | SID Potentiometer line (POTX/POTY `< $10`) |
| **Button Start** (Menu) | **`RETURN`** or **`SPACE`** | CIA1 Keyboard Matrix Scan |
| **Button Select** (Party/Map) | **`F1`** or **`C=` (Commodore Key)** | CIA1 Keyboard Matrix Scan |

---

### How Two-Button Joysticks Work via POT Lines on C64

Standard C64 joysticks only wire pins 1–4 (directions), pin 6 (fire), pin 7 (+5V), and pin 8 (GND). 

Modern 2-button C64 joysticks and gamepads (such as TheC64 gamepad, C64GS pads, Amiga CD32 pads, and modified Genesis pads) connect the **second button to pin 9 (POTX / POTY)**:

1. **At Rest (Released)**: The POT line is open or pulled to +5V through an internal capacitor/resistor network, reading high values in SID register **`$D419`** (Port 1 POTX) or **`$D41B`** / **`$D41A`** (Port 2 POT).
2. **Pressed**: The second button shorts pin 9 directly to ground (GND).
3. **Detection in Software**:
   * Read the SID POT register corresponding to your joystick port.
   * If the register value drops below a threshold (typically `< $10`), **Button 2 is pressed**.
   * If detected, set the **Button B** bit in `joy` / increment `joy_b`.

---

### Handling NES Joypad Calls in the Codebase

Whenever you encounter NES input code in the original disassembly:

1. **In Subroutines & Menus (`LDA joy_a`, `LDA joy_start`, etc.)**:
   * **Do not modify the calling code.**
   * Because `joy_a`, `joy_b`, `joy_start`, and `joy_select` are fed by your C64 `UpdateJoy`, the caller receives the exact same trigger pulses it expects.
2. **In `ReadJoypadData` / `UpdateJoy`**:
   * Strip out the NES `$4016` shift loop entirely.
   * Replace with reading `$DC00` (directions + button 1), SID POT register (button 2), and keyboard row/column checks for `RETURN`, `SPACE`, `F1`, and `C=`.

## 2. Save RAM (SRAM) & Flash Save Bank Architecture

### The NES Baseline
* On the NES, the cartridge board (MMC1 / SNROM) contained an 8 KB battery-backed SRAM chip mapped at `$6000`–`$7FFF`.
* In [`variables.inc`](file:///c:/Users/halku/Projects/Programming/games/ff1/c64/variables.inc#L302-L306), the game defines:
  * **`unsram = $6000`** ($400 bytes / 1024 bytes): Active in-memory party and world state. Updated continuously during gameplay.
  * **`sram = $6400`** ($400 bytes / 1024 bytes): The packed save slot. Contains active party data, checksum, and two assertion markers (`$55` and `$AA`).
* Total persistent data required by Final Fantasy 1 is **only 1024 bytes (1 KB)**.

---

### C64 In-Game Memory Mapping ($6000–$7FFF)
* On the Commodore 64, `$6000`–`$7FFF` is **free internal motherboard RAM**.
* **During gameplay, no bank switching is required.** The game reads and writes to `unsram` (`$6000`) and `sram` (`$6400`) with **zero performance overhead and 1:1 original memory addresses**.

---

### The Persistence Problem & The "Save Bank" Solution
Because the C64's internal motherboard RAM is volatile, data at `$6000`–$67FF` is cleared when power is turned off. 

To achieve battery-free persistence on the EasyFlash cartridge:
* EasyFlash has **64 banks (1 MB)** of Flash memory.
* Final Fantasy 1 only uses **17 banks** (Banks `$00` through `$10`).
* We designate an unused bank—**Bank 63 (`$3F`)**—as the dedicated **Save Bank**.

```
  C64 Internal RAM                     EasyFlash Cartridge
┌────────────────────────┐         ┌─────────────────────────┐
│ $6000-$63FF: unsram    │         │ Bank $00: Bootloader    │
│ (Active game state)    │         │ Bank $01-$0E: Game Data │
├────────────────────────┤         │ Bank $0F: Kernel        │
│ $6400-$67FF: sram      │ Save at │ Bank $10: Intro / Title │
│ (Packed 1KB save slot) │────────▶│ ...                     │
│                        │   Inn   │ Bank $3F: [SAVE BANK]   │
└────────────────────────┘         │  (1KB flash save slot)  │
            ▲                      └─────────────────────────┘
            │                               │
            └──────── Load on Boot ─────────┘
```

---

### The Three Stages of the Save Lifecycle

#### Stage 1: Cold Boot Restore (`boot00.asm`)
1. During boot, the loader temporarily selects the **Save Bank** (`lda #$3F; sta $DE00`).
2. It inspects the assertion markers in the Save Bank:
   * Offset `$4FE` == `$55`
   * Offset `$4FF` == `$AA`
3. **If valid**: Copies the 1 KB from the Save Bank directly into RAM at `$6400`–`$67FF`. When `GameStart` checks the checksum on title screen, the **"CONTINUE"** option is enabled.
4. **If invalid (first boot / uninitialized)**: Fills `$6400` with `$00`. `GameStart` detects uninitialized save data and forces **"NEW GAME"**.

#### Stage 2: In-Game Play
* The game modifies party HP, MP, gold, and inventory in RAM at `$6000`–`$63FF`.
* No flash programming or banking occurs during regular gameplay.

#### Stage 3: Saving at an Inn or Tent (`bank_0E.asm`)
In the original NES disassembly ([`bank_0E.asm` lines 5816–5852](file:///c:/Users/halku/Projects/Programming/games/ff1/c64/docs/Final%20Fantasy%20Disassembly/bank_0E.asm#L5816-L5852)), when saving at an Inn:
1. The game packs `$6000` into `$6400`.
2. It writes assertion markers `$55` and `$AA`.
3. It computes the checksum and writes it to `sram_checksum` (`$64FD`).
4. **Our C64 Hook**: Right after the checksum is written, we call **`PersistSaveToFlash`**:
   * Switch EasyFlash to Bank `$3F` (`$DE00`).
   * Erase the sector (or send the NOR flash byte program sequence).
   * Program the 1024 bytes from `$6400` into the Flash ROM.
   * Switch EasyFlash back to Bank `$0E`.
   * Return to the game and play the save jingle!

---

### Why EasyFlash Flash Saving Beats Floppy Disks
1. **Instantaneous**: Writing 1 KB of Flash memory takes under 15 milliseconds. Floppy saves take 3–5 seconds with drive motor spin-up.
2. **Self-Contained**: The save file is stored directly inside the `.crt` image or on the physical EasyFlash cartridge. Emulators (Retro Debugger, VICE) and real hardware (EasyFlash 1/3, Kung Fu Flash, Ultimate II+) automatically preserve `.crt` flash writes.
3. **Zero KERNAL Dependency**: Requires no KERNAL disk routines, no IEC bus handling, and no disk swapping.


