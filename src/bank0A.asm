; ==============================================================================
; bank0A.asm - Bank $0A Dialogue & Item Names ($8000 - $BFFF)
; Contains: 256 Dialogue Strings (DTE Encoded), Enemy Attacks, Item Names
; ==============================================================================

.segment "BANK_0A"

.export lut_DialoguePtrTbl
.export lut_EnemyAttack
.export lut_ItemNamePtrTbl

; --- $8000: Dialogue Pointer Table & Strings (13824 bytes = $3600) ---
lut_DialoguePtrTbl:
    .incbin "res/data/bank0A.dat", 0, $3600

; --- $B600: Enemy Attack Names & Data (256 bytes = $0100) ---
lut_EnemyAttack:
    .incbin "res/data/bank0A.dat", $3600, $0100

; --- $B700: Item Name Pointer Table & Item/Class Names (2304 bytes = $0900) ---
lut_ItemNamePtrTbl:
    .incbin "res/data/bank0A.dat", $3700, $0900
