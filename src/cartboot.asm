.include "c64.inc"

.segment "BOOT_LO"

.segment "BOOT_HI"

.import OnReset, OnIRQ, OnNMI

reset:
    sei             ; disable interrupts
    cld             ; clear decimal mode
    ldx #$FF
    txs             ; initialize stack pointer

    ; Set standard 6510 I/O port
    lda #$2F
    sta DDR
    lda #BANK_DEFAULT
    sta PORT

    ; Copy loader routine to RAM at $0300
    ldx #$00
CopySelfToRAM:
    lda SelfCopyRoutine,X
    sta $0300,X
    inx
    cpx #(SelfCopyEnd - SelfCopyRoutine)
    bne CopySelfToRAM

    ; Jump to routine running in RAM at $0300
    jmp $0300

SelfCopyRoutine:
; Use $02 and $04 for temporary pointers (unused by both C64 and FF1)
ptr1 = $02
ptr2 = $04

EASYFLASH_16K     = $07
EASYFLASH_LED     = $80

    ; 1. Switch EasyFlash to 16K cartridge mode (with LED on).
    ; In 16K mode, full RAM $0000-$7FFF is enabled, and the
    ; selected bank maps to $8000-$BFFF (ROML at $8000, ROMH at $A000).
    lda #(EASYFLASH_16K | EASYFLASH_LED)
    sta EASYFLASH_CTRL

    ; 2. Switch to Bank $0F (where bank0F is stored)
    lda #$0F
    sta EASYFLASH_BANK

    ; 3. Source: $8000 (Start of Bank $0F in 16K mode)
    lda #<$8000
    sta ptr1
    lda #>$8000
    sta ptr1+1

    ; Destination: $1000 (RAM)
    lda #<$1000
    sta ptr2
    lda #>$1000
    sta ptr2+1

    ; Copy 64 pages (16KB) from Cartridge ROM to RAM
    ldx #64
copy_16k:
    ldy #0
copy_page:
    lda (ptr1),y
    sta (ptr2),y
    iny
    bne copy_page

    inc ptr1+1
    inc ptr2+1

    dex
    bne copy_16k

    ; 4. Ensure Cartridge ROML ($8000-$9FFF) and ROMH ($A000-$BFFF) are active
    lda #BANK_DEFAULT
    sta PORT

    ; 5. Install Hardware Interrupt Vectors into indirect vector table ($0314/$0318) and RAM vectors
    lda #<OnIRQ
    sta $0314
    lda #>OnIRQ
    sta $0315

    lda #<OnNMI
    sta $0318
    lda #>OnNMI
    sta $0319

    lda #<OnNMI
    sta $FFFA
    lda #>OnNMI
    sta $FFFB

    lda #<reset
    sta $FFFC
    lda #>reset
    sta $FFFD

    lda #<OnIRQ
    sta $FFFE
    lda #>OnIRQ
    sta $FFFF

    ; 6. Silence CIA timer interrupts
    lda #$7F
    sta CIAICR      ; Disable CIA1 keyboard timer IRQs
    sta CI2ICR      ; Disable CIA2 NMI timers
    lda CIAICR      ; Acknowledge any pending CIA interrupts
    lda CI2ICR

    ; 7. Setup VIC-II Bank 1 ($4000-$7FFF)
    lda CI2DRA
    ora #$03        ; Ensure bits 0-1 of CIA2 Port A are outputs
    sta CI2DRA

    lda CI2PRA
    and #$FC        ; Clear bits 0-1
    ora #VIC_BANK1  ; Select Bank 1 ($4000-$7FFF)
    sta CI2PRA

    ; Default screen at $4000 (offset $0000 in bank 1), charset at $4800 (offset $0800)
    lda #$02
    sta VMCSB

    ; 8. Setup VIC-II Raster IRQ on scanline 250 (VBlank)
    lda #$01
    sta IRQMSK      ; Enable Raster IRQ
    lda #250
    sta RASTER      ; Trigger at raster line 250
    lda SCROLY
    and #$7F        ; Clear bit 8 of raster line
    sta SCROLY
    lda #$FF
    sta VICIRQ      ; Clear pending VIC-II IRQ flags

    ; 9. Jumps to OnReset in the newly moved kernel
    jmp OnReset

SelfCopyEnd:

nmi:
    rti

irq:
    rti

.segment "BOOT_VECTORS"
.word nmi
.word reset
.word irq
