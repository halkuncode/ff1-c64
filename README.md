# Final Fantasy (Commodore 64 Port)

An authentic, native Commodore 64 port of Square's classic NES RPG **Final Fantasy (1987)**, based on Disch's comprehensive NES disassembly.

The project targets the **EasyFlash 1MB Cartridge** format, translating NES MMC1 bank switching, PPU graphics, APU sound, and game logic into native 6510 assembly for the Commodore 64 and its VIC-II and SID chips.

---

## Technical Architecture

### 1. Memory & Banking Architecture
The NES version used an MMC1 mapper with 16 KB switchable PRG-ROM banks at `$8000–$BFFF` and a fixed bank (Bank 0F) at `$C000–$FFFF`. On the Commodore 64:
- **EasyFlash Cartridge:** Provides up to 1 MB of switchable ROM mapped into `$8000–$BFFF`. EasyFlash hardware registers (`$DE00` / `$DE02`) handle bank switching via a clean `SwapPRG` routine.
- **Relocated Fixed Bank 0F:** Because the C64 has hardware I/O and KERNAL ROM mapped around `$D000–$FFFF`, Bank 0F is copied to C64 RAM at `$1000–$2FFF` on boot, keeping it always accessible without bank collision.
- **VIC-II Bank 1:** Video RAM is configured to Bank 1 (`$4000–$7FFF`), with Screen RAM at `$4000` and Character Generation Memory (Charset) at `$4800`.
- **Zero Page Safety:** Preserves the C64's 6510 processor port registers (`$00` DDR and `$01` PORT) during game initializations like `ClearZeroPage`.

### 2. Video & Display (VIC-II vs. NES PPU)
- **Screen Dimensions:** The NES outputs a 32×30 tile grid, while the C64 provides a 40×25 character grid. Dialog boxes, menus, the opening prologue, and the character generation screens are horizontally centered and vertically adjusted to fit comfortably within 25 rows.
- **Text & Font System:** Incorporates Dual Tile Encoding (DTE) decompression and control code parsing matching the original NES text routines.
- **Raster Interrupts & Multiplexing:**
  - **Party Generation Screen:** Implements a dynamic 2-zone VIC-II raster interrupt multiplexer (`PartyGen_IRQ`) to render all four hero classes simultaneously using hardware sprites and hi-res color overlays.
  - **Character Naming Screen:** Features hardware cursor sprite rendering over standard text mode, backed by custom border layouts and color palettes.

### 3. Audio & Sound Engine (MOS 6581 / 8580 SID)
- The music driver (Bank 0D) translates the original NES APU 4-channel sound data into native 3-voice SID registers:
  - **Voice 1 & Voice 2:** Melodic pulse/square channels with hardware ADSR envelope emulation.
  - **Voice 3:** Triangle/bass lines and noise-based percussion effects.
- Driven at 60 Hz per-frame cadence via `CallMusicPlay` / `CallMusicPlay_NoSwap`.

---

## Controls (Keyboard Only)

The game uses the **C64 Keyboard exclusively** (no joystick):

| NES Function | C64 Keyboard Key | Function / Description |
|---|---|---|
| **D-Pad (Up, Down, Left, Right)** | **W, S, A, D** | Menu navigation & directional movement |
| **Button A (Confirm / Select)** | **Return** or **Space** | Confirm choices, select letters, talk |
| **Button B (Cancel / Back)** | **Inst/Del** (Backspace) or **Run/Stop** | Cancel choice, back up cursor, back out |
| **Start** | **F1** | Start game, confirm title option |
| **Select** | **Commodore (C=)** | Select option / toggle |

---

## Project Structure

```
ff1-c64/
├── docs/                # Disassembly notes, technical references, and ROM byte maps
├── gfx/                 # Source graphics, tilesets, and conversion assets
├── orgsrc/              # Entroper's FF1Disassembly submodule (reference only)
├── res/                 # Binary graphics, audio tables, and character data
│   ├── audio/           # SID score and song data
│   ├── data/            # Battle formations and game data tables
│   ├── heroes/          # Hero sprite graphics and class1.spr definition
│   ├── menu/            # Menu font and orb CHR assets
│   └── monsters/        # Monster graphic CHR files
├── scripts/             # Python asset pipeline and graphic conversion tools
├── src/                 # Main 6510 assembly source files
│   ├── bank00–bank0E.asm# Switchable PRG banks (Overworld, Menus, Battle, Audio, etc.)
│   ├── bank0F.asm       # Core engine, IRQ/VBlank handlers, string/box drawers
│   ├── cartboot.asm     # EasyFlash cold boot, RAM relocation, and hardware init
│   ├── c64.inc          # Commodore 64 hardware register equates ($D000, $DC00, etc.)
│   ├── constants.inc    # Game constants, bank IDs, and class definitions
│   └── variables.inc    # Zero Page and RAM memory variable maps
├── ff1c64.cfg           # ld65 linker configuration for EasyFlash bank segments
└── Makefile             # Build automation
```

---

## Prerequisites & Toolchain

To build this project on Windows or Linux, ensure you have the following installed and available in your `PATH`:

- **[cc65](https://cc65.github.io/):** 6502/6510 assembler suite (`ca65` and `ld65`).
- **[VICE](https://vice-emu.sourceforge.io/):** For testing via `x64sc` and cartridge conversion (`cartconv.exe`).
- **Python 3:** For running sprite and asset compilation scripts (`scripts/`).
- **GNU Make:** Build orchestration (`make`).
- *(Optional)* **[C64 Retro Debugger](https://github.com/SYSHEAD/c64-debugger):** Supported natively by `make run` for memory and raster debugging.

---

## Building & Running

### Build the EasyFlash Cartridge (`ff1.crt`)
```powershell
make
```
This compiles all assembly banks, generates symbols and debug labels (`ff1.lbl`, `ff1.labels`), and packages them into the final **`ff1.crt`** image using `cartconv`.

### Run in VICE Emulator
```powershell
make vice
```

### Run with Retro Debugger
```powershell
make run
```

### Clean Build Artifacts
```powershell
make clean
```

---

## Current Status

- [x] EasyFlash boot loader and memory remapping.
- [x] VIC-II interrupt raster system and VBlank engine.
- [x] Opening Prologue ("The world is veiled in darkness...").
- [x] Animated Title Screen and menu cursor selection.
- [x] Party Generation Screen with 4-hero hardware sprite multiplexing.
- [x] Interactive Character Naming Screen with font selector and full keyboard input.
- [x] Starting character stat calculations and Zero Page hardware protection.
- [ ] Overworld exploration and map streaming engine.
- [ ] In-game menu system (Status, Equipment, Magic, Item).
- [ ] Turn-based battle engine and monster rendering.

---

## Credits & Acknowledgments

- **Square:** The original creators of *Final Fantasy* (1987).
- **Disch:** Author of the comprehensive NES Final Fantasy disassembly.
- **Entroper:** Maintainer of the modern GitHub [FF1Disassembly](https://github.com/Entroper/FF1Disassembly) repository.
- **Commodore 64 & CC65 Communities:** For documentation, tooling, and emulator support.
