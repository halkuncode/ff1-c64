; ==============================================================================
; bank0C.asm - Bank $0C Data & Vehicle Sprites ($8000 - $BFFF)
; ==============================================================================

.segment "BANK_0C"

.export lut_VehicleSprites

; --- $8000: Vehicle Sprites (vechicles.spr, 3328 bytes = 52 sprites) ---
; Sprites 8..23 contain the Ship in 8 poses (16 sprites x 64 bytes = 1024 bytes)
lut_VehicleSprites:
    .incbin "../res/maps/vechicles/vechicles.spr"
