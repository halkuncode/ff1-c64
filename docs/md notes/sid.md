# APU to SID Sound Translation Architecture

This document details the hardware translation, voice mapping, frequency conversion, and sound effect prioritization for porting NES Final Fantasy 1's 2A03 APU audio engine to the Commodore 64 MOS 6581/8580 SID chip.

---

## 1. Architectural Comparison: NES APU vs. C64 SID

The original Final Fantasy 1 score by Nobuo Uematsu was composed for the NES's Ricoh 2A03 APU. Conveniently, Uematsu arranged nearly all tracks using **three primary melodic channels** (two squares + one bass triangle), which maps cleanly to the C64 SID's **three independent analog voices**:

| Parameter | NES 2A03 APU | Commodore 64 SID (6581 / 8580) |
| :--- | :--- | :--- |
| **Total Voices** | 5 (2 Pulse, 1 Triangle, 1 Noise, 1 DMC) | 3 Independent Synthesizer Voices |
| **Pulse Wave Duty** | 4 Fixed settings (12.5%, 25%, 50%, 75%) | 4096-step Variable Pulse Width (0.025% to 99.9%) |
| **Bass Waveform** | 4-bit Digital Stepped Triangle (Fixed Vol) | Continuous True Analog Triangle |
| **Frequency Resolution** | 11-bit Timer (Course + Fine) | 16-bit High-Resolution Pitch (`$0000`–`$FFFF`) |
| **Volume & Envelopes** | 4-bit Volume (0–15) or Decay Envelope | Full Hardware ADSR (Attack, Decay, Sustain, Release) |
| **Filters** | None | Multi-mode Analog Filter (Low, Band, High, Notch) |

---

## 2. Channel-to-Voice Mapping

```
      NES 2A03 APU Channels                       C64 SID Voices ($D400)
┌─────────────────────────────────┐             ┌───────────────────────────────────┐
│ Square 1 ($4000 - $4003)        │────────────▶│ Voice 1 ($D400 - $D406)           │
│   Lead Melody                   │             │   Pulse Wave (Duty Matching)      │
├─────────────────────────────────┤             ├───────────────────────────────────┤
│ Square 2 ($4004 - $4007)        │────────────▶│ Voice 2 ($D407 - $D40D)           │
│   Harmony / Counter-Melody      │             │   Pulse Wave (Duty Matching)      │
├─────────────────────────────────┤             ├───────────────────────────────────┤
│ Triangle ($4008 - $400B)        │────────────▶│ Voice 3 ($D40E - $D414)           │
│   Bass Line                     │             │   Triangle Wave (Warm Bass)       │
├─────────────────────────────────┤             ├───────────────────────────────────┤
│ Noise ($400C - $400F)           │────────────▶│ Voice 3 / Voice 2 Noise Mode      │
│   Percussion & Sound Effects    │             │   (Dynamic Channel Borrowing)     │
└─────────────────────────────────┘             └───────────────────────────────────┘
```

### Voice Breakdown:
1. **SID Voice 1 (NES Square 1)**: Plays the main melody. Configured for Pulse/Square waveform (`$D404 = $41`). Pulse width matches the NES duty setting.
2. **SID Voice 2 (NES Square 2)**: Plays harmonies and counterpoint. Configured for Pulse/Square waveform (`$D40B = $41`).
3. **SID Voice 3 (NES Triangle & Bass)**: Plays bass lines. Configured for Triangle waveform (`$D412 = $11`). Because the SID triangle is an analog wave, it delivers rich bass without digital stepping buzz.
4. **Noise & Sound Effects**: Handled via **channel borrowing** (Voice 3 or Voice 2 temporarily switches to Noise mode `$81` for percussion hits or sound effects, then resumes music).

---

## 3. Register Translation Map

| NES APU Register | Function | C64 SID Equivalent | Setting / Translation |
| :--- | :--- | :--- | :--- |
| **`$4000` / `$4004`** | Square Duty & Volume | `$D402`/`$D403`, `$D405`/`$D406` | Duty maps to Pulse Width; Volume maps to Sustain level |
| **`$4002` / `$4006`** | Pitch Low (8 bits) | `$D400` / `$D407` / `$D40E` | Frequency Low Byte |
| **`$4003` / `$4007`** | Pitch High (3 bits) | `$D401` / `$D408` / `$D40F` | Frequency High Byte |
| **`$4008`** | Triangle Linear Counter | `$D412` (Gate bit 0) | Triangle Gate on/off |
| **`$400A` / `$400B`** | Triangle Pitch | `$D40E` / `$D40F` | Voice 3 Frequency Low / High |
| **`$400C`** | Noise Volume & Period | `$D412 = $81` (Noise), `$D40E` | Voice 3 Noise mode + Noise Frequency |
| **`$4015`** | Sound Channel Enables | `$D404`, `$D40B`, `$D412` (Gate bits) | Gate bits on each voice control note triggers |

---

## 4. Pulse Width (Duty Cycle) Translation

The NES APU uses two bits (bits 6–7 of `$4000` and `$4004`) to choose one of four fixed pulse duty cycles:

| NES Duty Bits | Duty Cycle | SID 12-bit Pulse Width Value | Registers (`$D402` / `$D403`) |
| :---: | :---: | :---: | :---: |
| `%00` | 12.5% | `$0200` (512 / 4096) | Low = `$00`, High = `$02` |
| `%01` | 25.0% | `$0400` (1024 / 4096) | Low = `$00`, High = `$04` |
| `%10` | 50.0% (Square) | `$0800` (2048 / 4096) | Low = `$00`, High = `$08` |
| `%11` | 75.0% (Inverted 25%) | `$0400` *(Identical acoustic sound)* | Low = `$00`, High = `$04` |

---

## 5. Frequency Translation: Pitch Lookup Tables

On the NES, the music driver does not perform dynamic math to compute frequencies. Instead, it reads an **11-bit pitch value** from a pre-calculated lookup table (`lut_PitchTable`) based on the musical note (Octave 1–6, C through B).

### The C64 Optimization: Direct 16-bit SID Pitch Table
Rather than converting NES 11-bit timer values into SID frequencies at runtime, **we replace the NES pitch table with a native 16-bit SID frequency table**.

* **NES formula**: $\text{Pitch} = \frac{f_{\text{CPU}}}{16 \cdot (t + 1)}$
* **SID formula**: $\text{Freq}_{\text{SID}} = \frac{f_{\text{Note}} \cdot 16777216}{f_{\text{Clock}}}$ ($f_{\text{Clock}} \approx 985248\text{ Hz}$ on PAL, $1022727\text{ Hz}$ on NTSC).

```
Musical Note (e.g., A-4 = 440 Hz)
       │
       ▼
Original NES Driver: Reads 11-bit APU timer ($00FB)
New C64 Driver:      Reads 16-bit SID frequency directly:
                     - Frequency Low  = $E5 ($D400)
                     - Frequency High = $1C ($D401)
```

**Result:** Zero CPU overhead for frequency math. Note lookups take the exact same cycle count as on the NES.

---

## 6. Envelope & Volume Handling

### NES Volume:
* The NES uses a 4-bit volume register (values 0–15) updated every frame.

### SID Translation Options:
* **Option A: Hardware ADSR (Recommended for Authentic Sound)**:
  * Set Attack = 0 (instant attack, like NES).
  * Set Decay = 0.
  * Map the NES 4-bit volume directly into the **Sustain** nybble (bits 4–7 of `$D406` / `$D40D` / `$D414`).
  * Set Release = 0 (instant cutoff when Gate bit is cleared).
* **Option B: Master Volume (`$D418`)**:
  * `$D418` bits 0–3 provide a global 4-bit master volume (0–15).
  * Used for global fade-outs (like screen transitions or battle escapes).

---

## 7. Sound Effect (SFX) Priority & Channel Borrowing

In NES Final Fantasy 1:
* The music driver runs in **Bank `$0D`** (`MusicPlay`).
* When a sound effect triggers (cursor move, confirm, sword slash, magic spell, battle escape):
  1. The SFX routine takes temporary control of **Square 2** or **Noise**.
  2. It writes directly to the channel registers.
  3. When the SFX finishes, the music driver restores the interrupted music channel on the next note event.

### On the C64:
* **Cursor & Menu Beeps**: Play on **Voice 2** as a quick high-pitch pulse blip.
* **Sword Hits & Combat Noise**: Play on **Voice 3** (or Voice 2) with Noise waveform (`$D412 = $81`).
* **Channel Restoration**: Store a shadow variable of the current music track and note for each voice. When the SFX frame counter hits zero, the voice is handed back to the music sequencer.

---

## 8. Tempo & Timing: PAL (50 Hz) vs. NTSC (60 Hz)

* NES Final Fantasy 1 updates audio once per frame during VBlank (60 Hz on NTSC).
* On a PAL C64, VBlank occurs 50 times per second (every 20 ms instead of 16.6 ms).
* **Options**:
  1. **Direct 50 Hz Playback**: Songs play ~17% slower. Common for European C64 releases; still sounds musical and recognizable.
  2. **Timer-Compensated Playback**: Use CIA1 Timer A to fire an audio tick every 16.6 ms (independent of the raster beam), ensuring identical tempo on both PAL and NTSC machines.

