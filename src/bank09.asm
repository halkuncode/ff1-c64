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
    .incbin "../res/menu/menufont.chr"

; $9000 - $907F: Finger Cursor Sprites (128 bytes)
; Sprite 0: Multicolor Base (64 bytes)
; Sprite 1: Hi-Res Overlay (64 bytes)
.export lut_FingerSprite
lut_FingerSprite:
    ; Sprite 0: Multicolor Base
    .byte $05,$40,$00,$17,$40,$00,$1f,$d4
    .byte $00,$3f,$ff,$00,$7f,$ff,$00,$7f
    .byte $fc,$00,$7f,$f4,$00,$7f,$d0,$00
    .byte $7f,$c0,$00,$7f,$c0,$00,$7f,$c0
    .byte $00,$1f,$c0,$00,$15,$54,$00,$55
    .byte $55,$00,$55,$54,$00,$15,$50,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$81

    ; Sprite 1: Hi-Res Overlay
    .byte $00,$00,$00,$07,$80,$00,$1c,$00
    .byte $00,$1f,$fe,$00,$5f,$fe,$00,$7f
    .byte $e0,$00,$5f,$c0,$00,$5f,$c0,$00
    .byte $5f,$80,$00,$4f,$80,$00,$07,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$01

; Pad the remainder of the 16KB bank ($9080 - $BFFF = 12160 bytes)
.res $3000 - 128, $00
