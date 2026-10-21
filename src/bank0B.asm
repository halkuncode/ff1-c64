; ==============================================================================
; bank0B.asm - Bank $0B Battle Formations & Data ($8000 - $BFFF)
; ==============================================================================

.segment "BANK_0B"

.export lut_BattleFormations

; $8000 - $83FF: Battle Domains (1024 bytes reserved)
.res $0400, $00

; $8400 - $8BFF: Battle Formations (2048 bytes, 128 formations * 16 bytes)
.align $100
lut_BattleFormations:
    .incbin "../orgsrc/Final Fantasy Disassembly/bin/0B_8400_battleformations.bin"

loop:
    jmp loop
