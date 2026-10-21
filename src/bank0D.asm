; ==============================================================================
; bank0D.asm - Bank $0D Intro Story Text ($8000 - $BFFF)
; ==============================================================================

.segment "BANK_0D"

; Reserved $8000 - $BF1F (16,160 bytes)
.export lut_OrbCHR

; Reserved $8000 - $B5FF (13,824 bytes)
.res $3600, $00

; $B600 - $B6FF: Orb graphics for menus (32 tiles * 8 bytes = 256 bytes, 1bpp / hi-res)
lut_OrbCHR:
    .incbin "../res/menu/orbs.chr"

; Reserved $B700 - $BF1F (2,080 bytes)
.res $0820, $00

; $BF20 - $BFFF: Intro Story Text (224 bytes)
; Control codes:
;   $01 = Double line break (down 2 rows, reset column to dest_x)
;   $05 = Single line break (down 1 row, reset column to dest_x)
;   $00 = Null terminator (end of string)
; Encoding:
;   $1A - $69: Dual Tile Encoding (DTE pairs from lut_DTE1 & lut_DTE2)
;   $80 - $FF: Menu font letters, numbers, punctuation, spaces ($FF)
.export lut_IntroStoryText
lut_IntroStoryText:
    ; "    The world is veiled"
    .byte $FF, $FF, $FF, $FF, $9D, $AB, $1A, $BA, $35, $AF, $27, $AC, $1E, $32, $AC, $45
    ; " in" [Double Line Break] "   darkness. The "
    .byte $27, $1F, $01, $FF, $FF, $67, $2F, $AE, $B1, $2C, $B6, $C0, $FF, $9D, $AB, $1A
    ; "wind stops," [Double Line Break]
    .byte $BA, $1F, $A7, $24, $28, $B3, $B6, $BF, $01, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    ; " the sea is wild," [Double Line Break] " and t"
    .byte $1B, $AB, $1A, $B6, $2B, $2D, $1E, $BA, $61, $A7, $BF, $01, $FF, $A4, $3B, $1B
    ; "he earth begins to rot." [Double Line Break]
    .byte $AB, $1A, $2B, $B5, $1C, $31, $A8, $AA, $1F, $B6, $1B, $2E, $4D, $B7, $C0, $01
    ; "        The peopl"
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $9D, $AB, $1A, $B3, $A8, $B2, $B3, $AF
    ; "e wait," [Double Line Break] " their only ho"
    .byte $1A, $5D, $5B, $BF, $01, $FF, $B7, $1D, $AC, $B5, $36, $B1, $AF, $4B, $AB, $B2
    ; "pe, a prophecy...." [Paragraph Break: $05 + $01 = +3 rows] "'Whe"
    .byte $B3, $A8, $BF, $20, $4F, $4D, $B3, $1D, $A6, $BC, $69, $05, $01, $BE, $A0, $1D
    ; "n the world is in darknes"
    .byte $B1, $1B, $AB, $1A, $BA, $35, $AF, $27, $AC, $1E, $1F, $67, $2F, $AE, $B1, $2C
    ; "s" [Double Line Break] "  Four Warriors will c"
    .byte $B6, $01, $FF, $FF, $8F, $26, $44, $A0, $2F, $5C, $35, $1E, $BA, $AC, $4E, $38
    ; "ome....'" [Paragraph Break: $05 + $01 = +3 rows] "  After a long"
    .byte $B2, $34, $69, $BE, $05, $01, $FF, $FF, $8A, $A9, $B7, $25, $20, $65, $B2, $2A
    ; " journey, four" [Double Line Break] "    you"
    .byte $FF, $AD, $26, $B5, $5A, $BC, $BF, $43, $26, $B5, $01, $FF, $FF, $FF, $50, $26
    ; "ng warriors arrive," [Double Line Break]
    .byte $2A, $33, $2F, $5C, $35, $1E, $2F, $5C, $32, $BF, $01, $FF, $FF, $FF, $FF, $FF
    ; "each holding an ORB." [End String: $00]
    .byte $2B, $A6, $AB, $59, $B2, $AF, $A7, $1F, $AA, $20, $29, $98, $9B, $8B, $C0, $00
