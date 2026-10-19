; ==============================================================================
; c64.inc - Commodore 64 Hardware Registers & Constants
; ==============================================================================

.ifndef C64_INC
C64_INC = 1

; ------------------------------------------------------------------------------
; 6510 On-Chip I/O Port ($0000 - $0001)
; ------------------------------------------------------------------------------
DDR             = $0000     ; Data Direction Register (default $2F)
PORT            = $0001     ; Processor Port (Memory banking: BASIC/KERNAL/IO)
LORAM           = $01       ; Bit 0: RAM at $A000-$BFFF (0=RAM, 1=BASIC ROM)
HIRAM           = $02       ; Bit 1: RAM at $E000-$FFFF (0=RAM, 1=KERNAL ROM)
CHAREN          = $04       ; Bit 2: Character ROM / IO ($D000-$DFFF)

; Common banking configs for PORT ($01):
BANK_ALL_RAM    = $30       ; All 64K RAM, no ROMs, no I/O
BANK_RAM_IO     = $35       ; 64K RAM with I/O ($D000-$DFFF) visible, no KERNAL/BASIC
BANK_DEFAULT    = $37       ; Standard C64: BASIC, KERNAL, I/O enabled

; ------------------------------------------------------------------------------
; VIC-II Video Controller ($D000 - $D02E)
; ------------------------------------------------------------------------------
VIC_BASE        = $D000

; Sprite Coordinates (X: 0-511, Y: 0-255)
SP0X            = $D000
SP0Y            = $D001
SP1X            = $D002
SP1Y            = $D003
SP2X            = $D004
SP2Y            = $D005
SP3X            = $D006
SP3Y            = $D007
SP4X            = $D008
SP4Y            = $D009
SP5X            = $D00A
SP5Y            = $D00B
SP6X            = $D00C
SP6Y            = $D00D
SP7X            = $D00E
SP7Y            = $D00F
MSIGX           = $D010     ; Most Significant Bit of Sprite 0-7 X-Coordinates

; Control & Screen Registers
SCROLY          = $D011     ; Control Register 1 (Bit 7: Raster bit 8, Bit 4: Screen On, Bit 3: 25/24 rows, Bits 0-2: Y Scroll)
RASTER          = $D012     ; Raster Counter (Read: current scanline, Write: IRQ scanline)
LPENX           = $D013     ; Light Pen X
LPENY           = $D014     ; Light Pen Y
SPENA           = $D015     ; Sprite Enable Register (Bits 0-7 for Sprites 0-7)
SCROLX          = $D016     ; Control Register 2 (Bit 4: MultiColor, Bit 3: 40/38 cols, Bits 0-2: X Scroll)
YEXP            = $D017     ; Sprite Y Expansion (Bits 0-7)
VMCSB           = $D018     ; VIC Memory Control (Bits 7-4: Screen RAM offset, Bits 3-1: Char/Bitmap offset)
VICIRQ          = $D019     ; VIC Interrupt Flag Register (Write 1 to clear)
IRQMSK          = $D01A     ; VIC Interrupt Mask Register (Bit 0: Raster, Bit 1: Sprite-BG, Bit 2: Sprite-Sprite)

; Sprite Priority & Collision
SPBGPR          = $D01B     ; Sprite to Background Priority (0=Sprite in front, 1=BG in front)
SPMC            = $D01C     ; Sprite MultiColor Select (0=Standard Hi-Res, 1=MultiColor)
XEXP            = $D01D     ; Sprite X Expansion (Bits 0-7)
SPSPCL          = $D01E     ; Sprite to Sprite Collision (Read clears)
SPBGCL          = $D01F     ; Sprite to Background Collision (Read clears)

; Color Registers
EXTCOL          = $D020     ; Border Color
BGCOL0          = $D021     ; Background Color 0
BGCOL1          = $D022     ; Background Color 1 (MultiColor character/bitmap mode)
BGCOL2          = $D023     ; Background Color 2 (MultiColor character/bitmap mode)
BGCOL3          = $D024     ; Background Color 3
SPMC0           = $D025     ; Sprite MultiColor Register 0 (Shared Sprite Color 1)
SPMC1           = $D026     ; Sprite MultiColor Register 1 (Shared Sprite Color 2)
SP0COL          = $D027     ; Sprite 0 Color (Individual)
SP1COL          = $D028     ; Sprite 1 Color
SP2COL          = $D029     ; Sprite 2 Color
SP3COL          = $D02A     ; Sprite 3 Color
SP4COL          = $D02B     ; Sprite 4 Color
SP5COL          = $D02C     ; Sprite 5 Color
SP6COL          = $D02D     ; Sprite 6 Color
SP7COL          = $D02E     ; Sprite 7 Color

; ------------------------------------------------------------------------------
; Fixed Color RAM ($D800 - $DBE7)
; ------------------------------------------------------------------------------
COLOR_RAM       = $D800     ; 1000 nibbles (lower 4 bits = color)

; ------------------------------------------------------------------------------
; C64 Standard Color Codes
; ------------------------------------------------------------------------------
COLOR_BLACK         = $00
COLOR_WHITE         = $01
COLOR_RED           = $02
COLOR_CYAN          = $03
COLOR_PURPLE        = $04
COLOR_GREEN         = $05
COLOR_BLUE          = $06
COLOR_YELLOW        = $07
COLOR_ORANGE        = $08
COLOR_BROWN         = $09
COLOR_LIGHTRED      = $0A
COLOR_DARKGREY      = $0B
COLOR_GREY          = $0C
COLOR_LIGHTGREEN    = $0D
COLOR_LIGHTBLUE     = $0E
COLOR_LIGHTGREY     = $0F

; ------------------------------------------------------------------------------
; SID Sound Interface Device ($D400 - $D41C)
; ------------------------------------------------------------------------------
SID_BASE        = $D400

; Voice 1
V1FREQ_L        = $D400     ; Frequency Low Byte
V1FREQ_H        = $D401     ; Frequency High Byte
V1PW_L          = $D402     ; Pulse Width Low Byte
V1PW_H          = $D403     ; Pulse Width High (Bits 0-3)
V1CR            = $D404     ; Control Register (Bit 7: Noise, 6: Pulse, 5: Saw, 4: Tri, 1: Sync, 0: Gate)
V1AD            = $D405     ; Attack (Bits 7-4) / Decay (Bits 3-0)
V1SR            = $D406     ; Sustain (Bits 7-4) / Release (Bits 3-0)

; Voice 2
V2FREQ_L        = $D407
V2FREQ_H        = $D408
V2PW_L          = $D409
V2PW_H          = $D40A
V2CR            = $D40B
V2AD            = $D40C
V2SR            = $D40D

; Voice 3
V3FREQ_L        = $D40E
V3FREQ_H        = $D40F
V3PW_L          = $D410
V3PW_H          = $D411
V3CR            = $D412
V3AD            = $D413
V3SR            = $D414

; Filter & Volume
FCLO            = $D415     ; Filter Cutoff Frequency Low (Bits 0-2)
FCHI            = $D416     ; Filter Cutoff Frequency High (Bits 0-7)
RESFLT          = $D417     ; Filter Resonance (Bits 7-4) & Voice Filter Enables (Bits 0-3)
SIGVOL          = $D418     ; Master Volume (Bits 0-3) & Filter Modes (Bits 4-6)

; Analog Inputs & Random
POTX            = $D419     ; Paddle / Potentiometer X (Analog input, 2-button Fire 2)
POTY            = $D41A     ; Paddle / Potentiometer Y (Analog input, 2-button Fire 2)
OSC3            = $D41B     ; Voice 3 Oscillator Output (Read: pseudo-random noise)
ENV3            = $D41C     ; Voice 3 Envelope Output

; SID Waveform / Control Bits
SID_GATE        = $01
SID_SYNC        = $02
SID_RING        = $04
SID_TEST        = $08
SID_TRI         = $10
SID_SAW         = $20
SID_PULSE       = $40
SID_NOISE       = $80

; ------------------------------------------------------------------------------
; CIA 1 ($DC00 - $DC0F) - Keyboard, Joysticks, Timers, IRQ
; ------------------------------------------------------------------------------
CIA1_BASE       = $DC00
CIAPRA          = $DC00     ; Port A (Data / Joystick 2 / Keyboard Matrix Columns)
CIAPRB          = $DC01     ; Port B (Data / Joystick 1 / Keyboard Matrix Rows)
CIDDRA          = $DC02     ; Data Direction Register Port A
CIDDRB          = $DC03     ; Data Direction Register Port B
TIMALO          = $DC04     ; Timer A Low Byte
TIMAHI          = $DC05     ; Timer A High Byte
TIMBLO          = $DC06     ; Timer B Low Byte
TIMBHI          = $DC07     ; Timer B High Byte
TODTEN          = $DC08     ; Time of Day 1/10s
TODSEC          = $DC09     ; Time of Day Seconds
TODMIN          = $DC0A     ; Time of Day Minutes
TODHRS          = $DC0B     ; Time of Day Hours
CIASDR          = $DC0C     ; Serial Shift Register
CIAICR          = $DC0D     ; Interrupt Control / Status Register
CIACRA          = $DC0E     ; Timer A Control Register
CIACRB          = $DC0F     ; Timer B Control Register

; ------------------------------------------------------------------------------
; CIA 2 ($DD00 - $DD0F) - VIC-II Banking, RS-232, Timers, NMI
; ------------------------------------------------------------------------------
CIA2_BASE       = $DD00
CI2PRA          = $DD00     ; Port A (Bits 0-1: VIC-II Bank Selection, inverted)
CI2PRB          = $DD01     ; Port B (RS-232 / User Port)
CI2DRA          = $DD02     ; Data Direction Register Port A
CI2DRB          = $DD03     ; Data Direction Register Port B
CI2ICR          = $DD0D     ; Interrupt Control / Status Register (Controls NMIs)
CI2CRA          = $DD0E     ; Timer A Control Register
CI2CRB          = $DD0F     ; Timer B Control Register

; VIC-II Bank Selection constants for CI2PRA ($DD00):
VIC_BANK0       = $03       ; $0000-$3FFF (bits: %xx000011)
VIC_BANK1       = $02       ; $4000-$7FFF (bits: %xx000010) [FF1 Game Bank]
VIC_BANK2       = $01       ; $8000-$BFFF (bits: %xx000001)
VIC_BANK3       = $00       ; $C000-$FFFF (bits: %xx000000)

; ------------------------------------------------------------------------------
; EasyFlash Cartridge Registers ($DE00 - $DE02)
; ------------------------------------------------------------------------------
EASYFLASH_BANK  = $DE00     ; Bank Register (0-63)
EASYFLASH_SLOT  = $DE01     ; Flash Memory Control
EASYFLASH_CTRL  = $DE02     ; Control Register ($87 = 16K Mode, LED ON)

.endif ; C64_INC

