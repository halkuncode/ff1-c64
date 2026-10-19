; ==============================================================================
; bank09.asm - Bank $09 Menu CHR and Battle Sprites ($8000 - $BFFF)
; ==============================================================================

.segment "BANK_09"

; $8000 - $87FF: Shop CHR (2048 bytes reserved for shop graphics)
.res $0800, $00

; $8800 - $8FFF: Menu CHR (256 tiles x 8 bytes = 2048 bytes)
; Contains: Font, icons, window borders, and solid block tile 127
.export lut_MenuCHR
lut_MenuCHR:
    .incbin "../res/font/menufont.chr"
; Pad the remainder of the 16KB bank ($9000 - $BFFF = $3000 bytes = 12288 bytes)
.res $3000, $00
