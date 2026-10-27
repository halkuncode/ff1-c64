# Final Fantasy 1 for the Commodore 64

Hello and welcome to the port of **Final Fantasy 1** to the Commodore 64.

## Background & Origin

Once upon a time, about 10 years ago, a  Final Fantasy hacker known as **Disch** reverse-engineered and published a disassembly of the original Final Fantasy for the Nintendo Entertainment System. I had always wanted to port this game to another platform. Sadly, the microcomputer of my childhood was a Tandy Color Computer, which sported a Motorola 6809 CPU (to which the 6502 was a knock-off). The only other 6502-based machine I knew back then was the Apple II, but its graphics, sound, and storage capabilities were a little... lacking. Even the Apple IIgs, sporting the 65816 still had a graphics subsystem that was… questionable.

With the current renaissance of retro computing I was planning on making a port to the Commander X16, however after seeing a pixel-perfect port of Super Mario 3 to that machine, I didn't think about adding Final Fantasy to the list. When the new Commodore 64 Ultimate came out, I figured it would be fun to maybe port the game to that system instead.

## NES vs. Commodore 64

I figured the C64 and NES were similar in architecture, at least CPU and graphic wise(?) - When you look at the numbers, it kinda paints  round hole on which to place a square peg.

| Feature | Nintendo Entertainment System (NES) | Commodore 64 (C64) |
| :--- | :--- | :--- |
| **CPU** | **Ricoh RP2A03** @ ~1.79 MHz (NTSC) / ~1.66 MHz (PAL)<br>• Basically a 6502 with non-functional BCD due to a suspiciously missing transistor<br>• But in exchange glued to a sound processor<br>• and a DMA controller | **MOS 6510** @ ~1.02 MHz (NTSC) / ~0.985 MHz (PAL)<br>• A 6502 with a 6-bit I/O port for ROM/RAM banking |
| **System RAM** | **2 KB** of RAM <br>| **64 KB** base system RAM<br>• Bank switching lets you grab RAM from underneath ROMs & I/O space |
| **Video Memory (VRAM)** | **2 KB** internal video VRAM (two 32×30 tile screens) | **16 KB** addressable by VIC-II at any time (selectable across 4 banks in 64 KB RAM)<br>• Plus **1 KB** dedicated 4-bit Color RAM |
| **Character / Tile RAM** | **512 tiles** (two sets of 256 tiles) <br>• 8×8 pixels, 2 bits per pixel (4 colors per tile) | **256 characters** per 2 KB character set <br>• Standard: 8×8 px, 1 bpp (2 colors per cell)<br>• Multicolor: 4×8 double-width px (4 colors per cell)<br>• ECM mode: 64 characters with 4 background colors |
| **Color Palettes** | **64-color master palette** (~54–56 unique visible colors)<br>• Up to 25 colors on screen at once (4 BG palettes of 3 colors + 1 backdrop; 4 Sprite palettes of 3 colors + transparent) | **Fixed 16-color system palette**<br>• Multicolor character mode allows 3 global background colors + 1 unique color per cell from Color RAM |
| **Hardware Scrolling** | **Hardware X/Y fine and coarse scrolling**<br>• Full-screen smooth scrolling across two screens | **Hardware X/Y fine scrolling (0–7 pixels)**<br>• Crossing 8-pixel tile boundaries requires video memory pointer bump|
| **Sprites** | **64 hardware sprites**<br>• 8×8 or 8×16 pixels<br>• 3 colors + transparent (from 4 sprite palettes)<br>• Up to 8 sprites per scanline <br>• Hardware horizontal & vertical flipping | **8 hardware sprites**<br>• 24×21 pixels (Hires, 1 color) or 12×21 pixels (Multicolor, 3 colors)<br>• Hardware 2× X/Y expansion (up to 48×42)<br>• 8 sprites per scanline  |
| **Scanline / Raster IRQ** | **None built-in** (Only VBlank NMI on frame end)<br>• Mid-frame splits require polling Sprite 0 | **Built-in programmable Raster Interrupt** <br>• Can trigger an IRQ cleanly on *any* scanline for mid-frame splits, palette shifts, character set switches, or sprite multiplexing |
| **Mid-Frame Updates** | **VBlank only**<br>• The PPU tends to vomit garbage when you try | **Anytime**<br>• That is, if you can catch the beam |
| **Audio** | **Ricoh APU (5 channels)**:<br>• 2 Pulse/Square waves (with duty cycle control & volume sweeps)<br>• 1 Triangle wave (pseudo-sine/triangle 4-bit DAC)<br>• 1 White Noise channel<br>• 1 DPCM sample channel (1-bit delta modulation) | **MOS 6581 / 8580 SID (3 independent voices)**:<br>• Waveforms per voice: Pulse with 12-bit PWM, Sawtooth, Triangle, Noise<br>• Programmable ADSR envelope generators per voice<br>• Multi-mode resonant analog filter (Low/Band/High/Notch) |

So you can see it's a give/take kinda thing. The good news is that with a c64 you can solve any limitations by throwing enough ram at it. 

## Cartridge & Memory Architecture

The original NES version of *Final Fantasy* was built on the **MMC1** mapper (specifically the SNROM board), featuring:
- **256 KB PRG-ROM** split into sixteen 16 KB banks 
- **8 KB CHR-RAM** for tile graphics.
- **8 KB Save RAM** 

To preserve the logic, structure, and bank layout of the original game as closely as possible while adapting to the C64 hardware, this port targets the **EasyFlash cartridge** (1 MB Flash ROM):

## Building the Port

### Prerequisites
- [cc65](https://cc65.github.io/) toolchain (`ca65` assembler, `ld65` linker)
- `cartconv` (included in project root, from the VICE emulator distribution)
- Python 3 (for build and space-check scripts)
- [VICE](https://vice-emu.sourceforge.io/) or [Retro Debugger](https://retrodebugger.com/) for execution and debugging

### Build Commands
To assemble and generate the `ff1.crt` EasyFlash cartridge image:
```bash
make
```

To run in Retro Debugger with full symbol support:
```bash
make run
```

To run in VICE:
```bash
make vice
```

## Game Input
This does version not support joystick, so the buttons are...
- D-Pad:  W (Up), S (Down), A (Left), D (Right)
- Btn A:  Return or Space
- Btn B:  Backspace (Inst/Del) or Esc (Run/Stop)
- Select: Commodore (C=)
- Start:  F1