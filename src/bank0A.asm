; ==============================================================================
; bank0A.asm - Bank $0A Dialogue & Item Names ($8000 - $BFFF)
; Contains: 256 Dialogue Strings (DTE Encoded), Enemy Attacks, Item Names
; ==============================================================================

.segment "BANK_0A"

.export lut_DialoguePtrTbl
.export lut_EnemyAttack
.export lut_ItemNamePtrTbl

; --- $8000: Dialogue Pointer Table (256 pointers = 512 bytes) ---
lut_DialoguePtrTbl:
    .byte $00, $82, $09, $82, $5C, $82, $BD, $82, $D9, $82, $30, $83, $53, $83, $D1, $83
    .byte $FF, $83, $5E, $84, $78, $84, $94, $84, $CF, $84, $08, $85, $27, $85, $80, $85
    .byte $95, $85, $9C, $85, $EF, $85, $4C, $86, $7B, $86, $D9, $86, $2A, $87, $73, $87
    .byte $AD, $87, $CE, $87, $18, $88, $33, $88, $60, $88, $A4, $88, $D9, $88, $24, $89
    .byte $75, $89, $B2, $89, $FA, $89, $23, $8A, $70, $8A, $9D, $8A, $E4, $8A, $17, $8B
    .byte $4C, $8B, $52, $8B, $63, $8B, $B9, $8B, $23, $8C, $91, $8C, $F8, $8C, $57, $8D
    .byte $AF, $8D, $04, $8E, $43, $8E, $6C, $8E, $80, $8E, $9B, $8E, $C0, $8E, $DF, $8E
    .byte $02, $8F, $1A, $8F, $35, $8F, $62, $8F, $9B, $8F, $B4, $8F, $C0, $8F, $D9, $8F
    .byte $0E, $90, $3B, $90, $9E, $90, $C3, $90, $17, $91, $49, $91, $B3, $91, $BE, $91
    .byte $D2, $91, $EA, $91, $0C, $92, $38, $92, $64, $92, $6D, $92, $B8, $92, $F3, $92
    .byte $35, $93, $79, $93, $C7, $93, $F1, $93, $2D, $94, $70, $94, $8B, $94, $BB, $94
    .byte $C1, $94, $E9, $94, $0F, $95, $2D, $95, $54, $95, $A1, $95, $DD, $95, $FB, $95
    .byte $36, $96, $7C, $96, $88, $96, $AA, $96, $F8, $96, $23, $97, $46, $97, $7B, $97
    .byte $9C, $97, $C3, $97, $0C, $98, $54, $98, $7F, $98, $B5, $98, $D6, $98, $F5, $98
    .byte $09, $99, $25, $99, $5B, $99, $79, $99, $A4, $99, $C6, $99, $F5, $99, $22, $9A
    .byte $2B, $9A, $48, $9A, $84, $9A, $9E, $9A, $CA, $9A, $FF, $9A, $09, $9B, $34, $9B
    .byte $53, $9B, $92, $9B, $AA, $9B, $DD, $9B, $02, $9C, $3F, $9C, $6F, $9C, $A1, $9C
    .byte $D2, $9C, $00, $9D, $1E, $9D, $3D, $9D, $6F, $9D, $9D, $9D, $EA, $9D, $1F, $9E
    .byte $83, $9E, $E8, $9E, $08, $9F, $27, $9F, $69, $9F, $97, $9F, $D6, $9F, $24, $A0
    .byte $70, $A0, $9E, $A0, $F7, $A0, $5B, $A1, $D1, $A1, $00, $A2, $4E, $A2, $6D, $A2
    .byte $A3, $A2, $E9, $A2, $03, $A3, $5C, $A3, $78, $A3, $8A, $A3, $95, $A3, $BB, $A3
    .byte $E5, $A3, $35, $A4, $65, $A4, $94, $A4, $DA, $A4, $F8, $A4, $16, $A5, $5C, $A5
    .byte $7D, $A5, $CA, $A5, $0F, $A6, $30, $A6, $4F, $A6, $89, $A6, $A1, $A6, $CB, $A6
    .byte $DF, $A6, $23, $A7, $3D, $A7, $63, $A7, $94, $A7, $F1, $A7, $1E, $A8, $4E, $A8
    .byte $6E, $A8, $7C, $A8, $CF, $A8, $12, $A9, $36, $A9, $6F, $A9, $9D, $A9, $C1, $A9
    .byte $F5, $A9, $2F, $AA, $5D, $AA, $72, $AA, $96, $AA, $B6, $AA, $D8, $AA, $FF, $AA
    .byte $38, $AB, $48, $AB, $89, $AB, $CA, $AB, $28, $AC, $73, $AC, $BC, $AC, $05, $AD
    .byte $51, $AD, $76, $AD, $C2, $AD, $DE, $AD, $07, $AE, $34, $AE, $6D, $AE, $9A, $AE
    .byte $B9, $AE, $C7, $AE, $EB, $AE, $22, $AF, $53, $AF, $7B, $AF, $A2, $AF, $D3, $AF
    .byte $21, $B0, $42, $B0, $87, $B0, $B4, $B0, $E9, $B0, $FD, $B0, $1D, $B1, $28, $B1
    .byte $6F, $B1, $89, $B1, $9A, $B1, $AF, $B1, $C0, $B1, $D1, $B1, $E2, $B1, $F3, $B1
    .byte $18, $B2, $33, $B2, $9C, $B2, $F2, $B2, $68, $B3, $D2, $B3, $3D, $B4, $56, $B4

; --- $8200: Dialogue Text Strings (DTE compressed, decoded below) ---
data_DialogueStrings:
; Dialogue   0 ($8200): "Nothinghere."
    .byte $97, $B2, $1C, $1F, $47, $1D, $23, $C0, $00
; Dialogue   1 ($8209): "LIGHTWARRIORS..Just as\ninLukahn'sprophecy.\nGarla"
    .byte $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $69, $FF
    .byte $93, $B8, $37, $20, $B6, $05, $AC, $B1, $FF, $95, $B8, $AE, $A4, $AB, $B1, $BE
    .byte $1E, $B3, $4D, $B3, $1D, $A6, $BC, $C0, $05, $90, $A4, $B5, $AF, $22, $27, $41
    .byte $1E, $AE, $AC, $A7, $B1, $A4, $B3, $B3, $40, $05, $B7, $AB, $1A, $99, $B5, $1F
    .byte $A6, $2C, $B6, $C0, $FF, $99, $AF, $2B, $3E, $05, $AB, $A8, $AF, $B3, $59, $25
    .byte $C4, $C4, $00
; Dialogue   2 ($825C): "Thank you for saving the\nPrincess.To aidyour\nque"
    .byte $9D, $AB, $22, $AE, $50, $26, $43, $35, $24, $A4, $B9, $1F, $AA, $1B, $1D, $05
    .byte $99, $B5, $1F, $A6, $2C, $B6, $C0, $FF, $9D, $B2, $20, $AC, $27, $BC, $26, $B5
    .byte $05, $B4, $B8, $2C, $21, $92, $FF, $35, $A7, $A8, $23, $A7, $20, $31, $5C, $A7
    .byte $66, $05, $A5, $B8, $61, $B7, $1B, $2E, $1C, $1A, $A6, $3C, $B7, $1F, $3A, $B7
    .byte $C0, $05, $90, $B2, $FF, $B1, $46, $BF, $20, $B1, $27, $B0, $A4, $AE, $1A, $1C
    .byte $A8, $05, $98, $9B, $8B, $9C, $24, $AB, $1F, $1A, $A4, $AA, $A4, $1F, $C4, $C4
    .byte $00
; Dialogue   3 ($82BD): "ThePrincessalways\nworriesaboutyou."
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $2C, $1E, $5F, $5D, $BC, $B6, $05, $BA, $B2
    .byte $B5, $5C, $A8, $1E, $A4, $A5, $26, $21, $BC, $26, $C0, $00
; Dialogue   4 ($82D9): "No onetouchesmy\nPrincess!!\nLIGHTWARRIORS??\nYou "
    .byte $97, $B2, $36, $B1, $1A, $B7, $26, $A6, $1D, $1E, $B0, $BC, $05, $99, $B5, $1F
    .byte $A6, $2C, $B6, $C4, $C4, $05, $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B
    .byte $92, $98, $9B, $9C, $C5, $C5, $05, $A2, $B2, $B8, $2D, $B0, $B3, $25, $B7, $1F
    .byte $3A, $21, $A9, $B2, $B2, $AF, $B6, $C0, $05, $92, $BF, $FF, $90, $2F, $AF, $22
    .byte $A7, $BF, $33, $AC, $4E, $FF, $AE, $B1, $B2, $A6, $AE, $05, $BC, $B2, $B8, $20
    .byte $4E, $67, $46, $B1, $C4, $C4, $00
; Dialogue   5 ($8330): "So, you arethe\nLIGHTWARRIORS!\nThank you."
    .byte $9C, $B2, $BF, $50, $26, $20, $B5, $1A, $1C, $A8, $05, $95, $92, $90, $91, $9D
    .byte $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C4, $05, $9D, $AB, $22, $AE, $50
    .byte $26, $C0, $00
; Dialogue   6 ($8353): "ThisLUTEhasbeen\npasseddownfromQueen\ntoPrincessfo"
    .byte $9D, $AB, $AC, $1E, $95, $9E, $9D, $8E, $FF, $41, $1E, $62, $3A, $05, $B3, $A4
    .byte $B6, $3E, $27, $A7, $46, $29, $A9, $B5, $49, $FF, $9A, $B8, $A8, $3A, $05, $B7
    .byte $B2, $FF, $99, $B5, $1F, $A6, $2C, $1E, $A9, $35, $FF, $82, $80, $80, $80, $05
    .byte $BC, $A8, $2F, $B6, $C0, $FF, $90, $2F, $AF, $22, $A7, $24, $28, $AF, $1A, $5B
    .byte $05, $BA, $AB, $A8, $29, $AB, $1A, $AE, $AC, $A7, $B1, $A4, $B3, $B3, $A8, $27
    .byte $34, $C0, $05, $99, $AF, $2B, $B6, $1A, $5E, $48, $B3, $21, $5B, $20, $1E, $B0
    .byte $BC, $05, $AA, $AC, $A9, $B7, $BF, $2D, $21, $AD, $B8, $B6, $21, $B0, $AC, $AA
    .byte $AB, $21, $A6, $B2, $34, $05, $AC, $B1, $59, $22, $A7, $BC, $C0, $00
; Dialogue   7 ($83D1): "Now,getready for your\ntrip, andmaketheORBS\nshine"
    .byte $97, $B2, $BA, $BF, $FF, $66, $21, $23, $A4, $A7, $BC, $43, $35, $50, $26, $B5
    .byte $05, $B7, $B5, $AC, $B3, $BF, $20, $B1, $27, $B0, $A4, $AE, $1A, $1C, $1A, $98
    .byte $9B, $8B, $9C, $05, $B6, $AB, $1F, $1A, $A4, $AA, $A4, $1F, $C0, $00
; Dialogue   8 ($83FF): "Aye,I amBikkethe\nPirate, and surprisedI\nam thaty"
    .byte $8A, $BC, $A8, $BF, $FF, $92, $20, $B0, $FF, $8B, $AC, $AE, $AE, $1A, $1C, $A8
    .byte $05, $99, $AC, $B5, $39, $A8, $BF, $20, $3B, $24, $55, $B3, $B5, $30, $A8, $27
    .byte $92, $05, $A4, $B0, $1B, $41, $21, $BC, $26, $24, $A6, $55, $B9, $4B, $A7, $B2
    .byte $AA, $B6, $05, $AB, $A4, $B9, $1A, $1C, $1A, $B1, $25, $B9, $1A, $28, $43, $A4
    .byte $48, $05, $B0, $A8, $C0, $05, $96, $A4, $B7, $2C, $C4, $05, $90, $A8, $B7, $1B
    .byte $AB, $B2, $B6, $1A, $AF, $22, $A7, $AF, $B8, $A5, $A5, $25, $B6, $C4, $00
; Dialogue   9 ($845E): "Okay, yougotme.\nTakemySHIP."
    .byte $98, $AE, $A4, $BC, $BF, $50, $26, $FF, $AA, $B2, $21, $34, $C0, $05, $9D, $A4
    .byte $AE, $1A, $B0, $4B, $9C, $91, $92, $99, $C0, $00
; Dialogue  10 ($8478): "Iwon'tbeany more\nbother.I promise."
    .byte $92, $FF, $BA, $3C, $BE, $21, $A5, $1A, $22, $BC, $42, $B2, $23, $05, $A5, $B2
    .byte $1C, $25, $C0, $FF, $92, $4F, $B5, $49, $30, $A8, $C0, $00
; Dialogue  11 ($8494): "For fiveyears the\nPrincehasslept\nunderAstos' spe"
    .byte $8F, $B2, $B5, $43, $AC, $B9, $1A, $BC, $2B, $63, $1B, $1D, $05, $99, $B5, $1F
    .byte $A6, $1A, $41, $1E, $B6, $45, $B3, $B7, $05, $B8, $B1, $A7, $25, $FF, $8A, $B6
    .byte $28, $B6, $BE, $24, $B3, $A8, $4E, $C0, $05, $98, $B1, $AF, $4B, $91, $8E, $9B
    .byte $8B, $38, $22, $33, $A4, $AE, $1A, $3D, $B0, $C4, $00
; Dialogue  12 ($84CF): "Oh, thisHERB will\nreleasethePrincefrom\nAstos' cu"
    .byte $98, $AB, $BF, $1B, $3D, $1E, $91, $8E, $9B, $8B, $33, $AC, $4E, $05, $B5, $A8
    .byte $AF, $2B, $B6, $1A, $1C, $1A, $99, $B5, $1F, $A6, $1A, $A9, $B5, $49, $05, $8A
    .byte $B6, $28, $B6, $BE, $38, $55, $3E, $C0, $FF, $95, $B2, $B2, $AE, $C4, $05, $91
    .byte $A8, $2D, $1E, $5D, $AE, $1F, $AA, $69, $00
; Dialogue  13 ($8508): "Thank you.\nPeacewillreturn to\nElfLand."
    .byte $9D, $AB, $22, $AE, $50, $26, $C0, $05, $99, $A8, $5E, $1A, $BA, $AC, $4E, $FF
    .byte $23, $B7, $55, $B1, $1B, $B2, $05, $8E, $AF, $A9, $95, $22, $A7, $C0, $00
; Dialogue  14 ($8527): "Is thisa dream?..\nAreyou, the\nLIGHTWARRIORS?..\n"
    .byte $92, $B6, $1B, $3D, $1E, $A4, $67, $23, $A4, $B0, $C5, $69, $05, $8A, $B5, $1A
    .byte $BC, $26, $BF, $1B, $1D, $05, $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B
    .byte $92, $98, $9B, $9C, $C5, $69, $05, $92, $B6, $1B, $3D, $1E, $A9, $35, $FF, $23
    .byte $5F, $C5, $69, $05, $9C, $B2, $BF, $20, $1E, $45, $AA, $3A, $A7, $24, $A4, $BC
    .byte $B6, $BF, $05, $92, $FF, $AA, $AC, $B9, $1A, $BC, $26, $1B, $AB, $1A, $B0, $BC
    .byte $37, $AC, $A6, $05, $94, $8E, $A2, $C0, $00
; Dialogue  15 ($8580): "Ifeelfinenow.\nThank you."
    .byte $92, $FF, $A9, $A8, $A8, $58, $A9, $1F, $1A, $B1, $46, $C0, $05, $9D, $AB, $22
    .byte $AE, $50, $26, $C0, $00
; Dialogue  16 ($8595): "z....z...."
    .byte $BD, $C3, $C3, $BD, $C3, $C3, $00
; Dialogue  17 ($859C): "Astosdouble-crossedus.\nGo south, totheCaveof\nMar"
    .byte $8A, $B6, $28, $1E, $A7, $26, $A5, $45, $C2, $A6, $4D, $B6, $3E, $27, $B8, $B6
    .byte $C0, $05, $90, $B2, $24, $26, $1C, $BF, $1B, $2E, $1C, $1A, $8C, $A4, $B9, $1A
    .byte $4C, $05, $96, $A4, $63, $AB, $BF, $1B, $2E, $23, $B7, $5C, $A8, $B9, $1A, $1C
    .byte $A8, $05, $8C, $9B, $98, $A0, $97, $C0, $FF, $9D, $1D, $B1, $BF, $31, $B5, $1F
    .byte $AA, $2D, $B7, $05, $A7, $AC, $23, $A6, $B7, $AF, $BC, $31, $5E, $AE, $1B, $2E
    .byte $34, $C4, $00
; Dialogue  18 ($85EF): "HA,HA,HA!I amAstos,\nKing of theDarkElves.\nIhaveM"
    .byte $91, $8A, $BF, $FF, $91, $8A, $BF, $FF, $91, $8A, $C4, $FF, $92, $20, $B0, $FF
    .byte $8A, $B6, $28, $B6, $BF, $05, $94, $AC, $2A, $36, $A9, $1B, $AB, $1A, $8D, $2F
    .byte $AE, $FF, $8E, $AF, $B9, $2C, $C0, $05, $92, $FF, $41, $B9, $1A, $96, $A4, $28
    .byte $BC, $A4, $BE, $1E, $8C, $9B, $A2, $9C, $9D, $8A, $95, $BF, $05, $A4, $B1, $27
    .byte $BC, $26, $24, $41, $4E, $FF, $AA, $AC, $B9, $1A, $34, $05, $B7, $AB, $A4, $21
    .byte $8C, $9B, $98, $A0, $97, $BF, $FF, $B1, $46, $C4, $C4, $C4, $00
; Dialogue  19 ($864C): "Arock blocks\nconstructionof my\ncanal.\nIfI onlyh"
    .byte $8A, $FF, $4D, $A6, $AE, $31, $AF, $B2, $A6, $AE, $B6, $05, $A6, $B2, $B1, $37
    .byte $B5, $B8, $A6, $57, $B2, $29, $4C, $42, $BC, $05, $A6, $A4, $B1, $5F, $C0, $05
    .byte $92, $A9, $FF, $92, $36, $B1, $AF, $4B, $41, $27, $9D, $97, $9D, $C0, $00
; Dialogue  20 ($867B): "Oh, wonderful!\nNicework!Yes, yes\nindeed, thisTNT"
    .byte $98, $AB, $BF, $33, $B2, $3B, $25, $A9, $B8, $AF, $C4, $05, $97, $AC, $A6, $1A
    .byte $BA, $35, $AE, $C4, $FF, $A2, $2C, $BF, $50, $2C, $05, $AC, $B1, $A7, $A8, $40
    .byte $BF, $1B, $3D, $1E, $9D, $97, $9D, $2D, $1E, $AD, $B8, $37, $05, $BA, $AB, $A4
    .byte $21, $92, $FF, $5A, $40, $1B, $2E, $A9, $1F, $30, $AB, $42, $BC, $05, $A6, $A4
    .byte $B1, $5F, $C0, $FF, $97, $46, $FF, $A8, $BB, $A6, $B8, $B6, $1A, $34, $05, $BA
    .byte $AB, $61, $1A, $92, $FF, $66, $B7, $1B, $2E, $BA, $35, $AE, $C4, $00
; Dialogue  21 ($86D9): "For theLIGHT\nWARRIORSI will makea\ntrulylegendary"
    .byte $8F, $B2, $B5, $1B, $AB, $1A, $95, $92, $90, $91, $9D, $05, $A0, $8A, $9B, $9B
    .byte $92, $98, $9B, $9C, $FF, $92, $33, $AC, $4E, $42, $A4, $AE, $1A, $A4, $05, $B7
    .byte $B5, $B8, $AF, $4B, $45, $AA, $3A, $A7, $2F, $BC, $24, $BA, $35, $A7, $C0, $05
    .byte $91, $B2, $60, $B9, $25, $BF, $42, $BC, $24, $B8, $B3, $B3, $AF, $BC, $36, $A9
    .byte $05, $8A, $8D, $8A, $52, $97, $9D, $2D, $1E, $A8, $BB, $41, $B8, $37, $40, $C0
    .byte $00
; Dialogue  22 ($872A): "ADAMANT!!\nNowletmemake\ntheswordfor you..\nHere, "
    .byte $8A, $8D, $8A, $52, $97, $9D, $C4, $C4, $05, $97, $B2, $BA, $FF, $45, $21, $B0
    .byte $1A, $B0, $A4, $AE, $A8, $05, $B7, $AB, $1A, $B6, $BA, $35, $27, $A9, $35, $50
    .byte $26, $69, $05, $91, $A8, $23, $BF, $1B, $AB, $1A, $A5, $2C, $21, $BA, $35, $AE
    .byte $FF, $92, $BE, $32, $05, $A8, $B9, $25, $67, $3C, $A8, $C0, $05, $92, $B7, $2D
    .byte $1E, $B0, $4B, $AA, $AC, $A9, $B7, $C0, $00
; Dialogue  23 ($8773): "WhereismyCRYSTAL?\nIcan'tseeanything\nwithoutit..W"
    .byte $A0, $AB, $25, $1A, $AC, $1E, $B0, $4B, $8C, $9B, $A2, $9C, $9D, $8A, $95, $C5
    .byte $05, $92, $FF, $A6, $22, $BE, $21, $3E, $1A, $22, $BC, $1C, $1F, $AA, $05, $BA
    .byte $AC, $1C, $26, $21, $5B, $69, $FF, $A0, $AB, $B2, $24, $28, $45, $05, $B0, $BC
    .byte $FF, $8C, $9B, $A2, $9C, $9D, $8A, $95, $C5, $00
; Dialogue  24 ($87AD): "WARRIORS.\nRevivethePower of\ntheORBS!"
    .byte $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $05, $9B, $A8, $B9, $AC, $B9, $1A
    .byte $1C, $1A, $99, $46, $25, $36, $A9, $05, $B7, $AB, $1A, $98, $9B, $8B, $9C, $C4
    .byte $00
; Dialogue  25 ($87CE): "ThePrinceneedsHERB?\nI'll tradethemost\npowerfulHE"
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $1A, $5A, $40, $1E, $91, $8E, $9B, $8B, $C5
    .byte $05, $92, $BE, $4E, $1B, $B5, $A4, $A7, $1A, $1C, $1A, $B0, $B2, $37, $05, $B3
    .byte $B2, $BA, $25, $A9, $B8, $58, $91, $8E, $9B, $8B, $1B, $2E, $66, $21, $B0, $BC
    .byte $05, $8C, $9B, $A2, $9C, $9D, $8A, $95, $31, $5E, $AE, $69, $05, $98, $AB, $C4
    .byte $FF, $92, $38, $22, $24, $A8, $A8, $C4, $C4, $00
; Dialogue  26 ($8818): "Youhavenomore\nbusinesshere.Go!!"
    .byte $A2, $B2, $64, $41, $B9, $1A, $B1, $2E, $B0, $B2, $23, $05, $A5, $B8, $B6, $1F
    .byte $2C, $1E, $1D, $23, $C0, $FF, $90, $B2, $C4, $C4, $00
; Dialogue  27 ($8833): "Everybodyknowsme.\nWhat?!You'venever\nheardofDr.Un"
    .byte $8E, $B9, $25, $BC, $A5, $B2, $A7, $4B, $AE, $B1, $46, $1E, $34, $C0, $05, $A0
    .byte $AB, $39, $C5, $C4, $FF, $A2, $26, $BE, $B9, $1A, $5A, $B9, $25, $05, $AB, $A8
    .byte $2F, $27, $4C, $FF, $8D, $B5, $C0, $FF, $9E, $B1, $5A, $C5, $00
; Dialogue  28 ($8860): "ASLAB!!\nThisSLAB will leadus\nto solvetheriddleof"
    .byte $8A, $FF, $9C, $95, $8A, $8B, $C4, $C4, $05, $9D, $AB, $AC, $1E, $9C, $95, $8A
    .byte $8B, $33, $AC, $4E, $65, $2B, $27, $B8, $B6, $05, $B7, $B2, $24, $B2, $AF, $B9
    .byte $1A, $1C, $1A, $5C, $A7, $A7, $AF, $1A, $4C, $05, $B7, $AB, $1A, $95, $A8, $A9
    .byte $A8, $1F, $30, $AB, $C4, $C4, $05, $97, $B2, $BA, $BF, $65, $30, $B7, $3A, $1B
    .byte $2E, $34, $69, $00
; Dialogue  29 ($88A4): "Allliving thingswere\nborn todie.\nNo onecan defea"
    .byte $8A, $AF, $58, $68, $B9, $1F, $AA, $1B, $AB, $1F, $AA, $1E, $60, $23, $05, $A5
    .byte $B2, $B5, $B1, $1B, $2E, $A7, $AC, $A8, $C0, $05, $97, $B2, $36, $B1, $1A, $A6
    .byte $22, $67, $A8, $A9, $2B, $21, $34, $BF, $05, $B7, $AB, $1A, $9F, $A4, $B0, $B3
    .byte $AC, $23, $C4, $C4, $00
; Dialogue  30 ($88D9): "UsethisROD behind the\nVampire'sroom.Hiding\ndeepi"
    .byte $9E, $B6, $1A, $1C, $AC, $1E, $9B, $98, $8D, $31, $A8, $AB, $1F, $A7, $1B, $1D
    .byte $05, $9F, $A4, $B0, $B3, $AC, $23, $BE, $1E, $4D, $49, $C0, $FF, $91, $AC, $A7
    .byte $1F, $AA, $05, $A7, $A8, $A8, $B3, $FF, $1F, $B6, $AC, $A7, $1A, $BC, $26, $33
    .byte $AC, $4E, $05, $A9, $AC, $3B, $1B, $AB, $1A, $51, $B8, $B6, $1A, $4C, $1B, $1D
    .byte $05, $A8, $A4, $B5, $1C, $BE, $1E, $4D, $B7, $C0, $00
; Dialogue  31 ($8924): "IamBAHAMUT,King of\ntheDragons.Bringme\nproof of y"
    .byte $92, $FF, $A4, $B0, $FF, $8B, $8A, $91, $8A, $96, $9E, $9D, $BF, $FF, $94, $1F
    .byte $AA, $36, $A9, $05, $B7, $AB, $1A, $8D, $B5, $A4, $AA, $3C, $B6, $C0, $FF, $8B
    .byte $B5, $1F, $47, $34, $05, $B3, $B5, $B2, $4C, $36, $A9, $50, $26, $B5, $38, $26
    .byte $B5, $A4, $66, $BF, $05, $B7, $B2, $FF, $23, $48, $AC, $B9, $1A, $1C, $1A, $AB
    .byte $3C, $35, $05, $A7, $B8, $1A, $B7, $B5, $B8, $1A, $A0, $2F, $5C, $35, $B6, $C0
    .byte $00
; Dialogue  32 ($8975): "TheTAIL of aratproves\nyour courage.I shall\ngivey"
    .byte $9D, $AB, $1A, $9D, $8A, $92, $95, $36, $A9, $20, $FF, $B5, $A4, $21, $B3, $4D
    .byte $B9, $2C, $05, $BC, $B2, $55, $38, $B2, $55, $A4, $66, $C0, $FF, $92, $24, $41
    .byte $4E, $05, $AA, $AC, $B9, $1A, $BC, $26, $1B, $AB, $1A, $AB, $3C, $35, $67, $B8
    .byte $A8, $05, $B7, $B5, $B8, $1A, $A0, $2F, $5C, $35, $B6, $C0, $00
; Dialogue  33 ($89B2): "ThefourORBSnow cover\ntheblackORB..\nTo takea step"
    .byte $9D, $AB, $1A, $A9, $26, $44, $98, $9B, $8B, $9C, $FF, $B1, $46, $38, $B2, $B9
    .byte $25, $05, $B7, $AB, $1A, $A5, $AF, $5E, $AE, $FF, $98, $9B, $8B, $69, $05, $9D
    .byte $B2, $1B, $A4, $AE, $1A, $A4, $24, $53, $B3, $43, $35, $BA, $2F, $A7, $05, $AC
    .byte $B6, $1B, $2E, $AA, $B2, $31, $5E, $AE, $FF, $82, $80, $80, $80, $50, $2B, $63
    .byte $05, $AC, $B1, $1B, $AC, $34, $C0, $00
; Dialogue  34 ($89FA): "TheblackORB\nglittersominously..\nButnothinghappen"
    .byte $9D, $AB, $1A, $A5, $AF, $5E, $AE, $FF, $98, $9B, $8B, $05, $AA, $AF, $5B, $B7
    .byte $25, $1E, $49, $1F, $26, $B6, $AF, $BC, $69, $05, $8B, $B8, $21, $B1, $B2, $1C
    .byte $1F, $47, $41, $B3, $B3, $3A, $B6, $C0, $00
; Dialogue  35 ($8A23): "Thatpiratetrappedme\nin theBOTTLE.\nIwill drawOXYA"
    .byte $9D, $AB, $A4, $21, $B3, $AC, $B5, $39, $1A, $B7, $B5, $A4, $B3, $B3, $A8, $27
    .byte $34, $05, $AC, $B1, $1B, $AB, $1A, $8B, $98, $9D, $9D, $95, $8E, $C0, $05, $92
    .byte $FF, $BA, $AC, $4E, $67, $B5, $A4, $BA, $FF, $98, $A1, $A2, $8A, $95, $8E, $43
    .byte $B5, $49, $05, $B7, $AB, $1A, $A5, $B2, $B7, $28, $B0, $36, $A9, $1B, $AB, $1A
    .byte $B6, $B3, $B5, $1F, $AA, $05, $A9, $B2, $44, $BC, $26, $C0, $00
; Dialogue  36 ($8A70): "Thank you for savingme.\nRemember!OXYALE will\ngiv"
    .byte $9D, $AB, $22, $AE, $50, $26, $43, $35, $24, $A4, $B9, $1F, $47, $34, $C0, $05
    .byte $9B, $A8, $34, $B0, $A5, $25, $C4, $FF, $98, $A1, $A2, $8A, $95, $8E, $33, $AC
    .byte $4E, $05, $AA, $AC, $B9, $1A, $BC, $26, $20, $AC, $B5, $C0, $00
; Dialogue  37 ($8A9D): "Imadea submarineto\nsavethemermaids.But,\ntogo dee"
    .byte $92, $FF, $B0, $A4, $A7, $1A, $A4, $24, $B8, $A5, $B0, $2F, $1F, $1A, $28, $05
    .byte $B6, $A4, $B9, $1A, $1C, $1A, $B0, $25, $B0, $A4, $AC, $A7, $B6, $C0, $FF, $8B
    .byte $B8, $B7, $BF, $05, $B7, $B2, $FF, $AA, $B2, $67, $A8, $A8, $B3, $FF, $3A, $26
    .byte $AA, $AB, $2D, $B7, $05, $BA, $AC, $4E, $FF, $23, $B4, $B8, $AC, $B5, $1A, $98
    .byte $A1, $A2, $8A, $95, $8E, $C0, $00
; Dialogue  38 ($8AE4): "WARRIORS, youhave\nOXYALE.Themermaids\nwait, pleas"
    .byte $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $BF, $50, $26, $FF, $41, $32, $05, $98
    .byte $A1, $A2, $8A, $95, $8E, $C0, $FF, $9D, $AB, $1A, $B0, $25, $B0, $A4, $AC, $A7
    .byte $B6, $05, $BA, $A4, $5B, $BF, $4F, $AF, $2B, $B6, $1A, $1D, $AF, $B3, $1B, $1D
    .byte $B0, $C4, $00
; Dialogue  39 ($8B17): "TakethisCUBE.With it,\nyou can transfer tothe\nFLO"
    .byte $9D, $A4, $AE, $1A, $1C, $AC, $1E, $8C, $9E, $8B, $8E, $C0, $FF, $A0, $AC, $1C
    .byte $2D, $B7, $BF, $05, $BC, $B2, $B8, $38, $22, $1B, $B5, $22, $B6, $A9, $25, $1B
    .byte $2E, $1C, $A8, $05, $8F, $95, $98, $8A, $9D, $92, $97, $90, $FF, $8C, $8A, $9C
    .byte $9D, $95, $8E, $C0, $00
; Dialogue  40 ($8B4C): "Please.."
    .byte $99, $AF, $2B, $3E, $69, $00
; Dialogue  41 ($8B52): "No onepasses thisroad."
    .byte $97, $B2, $36, $B1, $1A, $B3, $3F, $B6, $2C, $1B, $3D, $1E, $4D, $A4, $A7, $C0
    .byte $00
; Dialogue  42 ($8B63): "If you wantpass,give\nme theRUBY..\nCrunch, crunch"
    .byte $92, $A9, $50, $26, $33, $22, $21, $B3, $3F, $B6, $BF, $FF, $AA, $AC, $32, $05
    .byte $B0, $A8, $1B, $1D, $FF, $9B, $9E, $8B, $A2, $69, $05, $8C, $B5, $B8, $B1, $A6
    .byte $AB, $BF, $38, $B5, $B8, $B1, $A6, $AB, $BF, $38, $B5, $B8, $B1, $A6, $AB, $BF
    .byte $05, $B0, $B0, $B0, $BF, $2D, $B7, $1B, $A4, $37, $A8, $1E, $B6, $B2, $24, $60
    .byte $A8, $B7, $C0, $05, $9B, $B8, $A5, $AC, $A8, $1E, $2F, $1A, $B0, $BC, $43, $A4
    .byte $B9, $35, $AC, $53, $C0, $00
; Dialogue  43 ($8BB9): "Greatjobvanquishing\ntheEarthFIEND.Now,\ntheFireFI"
    .byte $90, $B5, $2B, $21, $AD, $B2, $A5, $FF, $B9, $22, $B4, $B8, $30, $AB, $1F, $AA
    .byte $05, $B7, $AB, $1A, $8E, $2F, $B7, $AB, $FF, $8F, $92, $8E, $97, $8D, $C0, $FF
    .byte $97, $46, $BF, $05, $B7, $AB, $1A, $8F, $AC, $B5, $1A, $8F, $92, $8E, $97, $8D
    .byte $33, $A4, $AE, $2C, $C0, $05, $A0, $AC, $1C, $1B, $3D, $1E, $8C, $8A, $97, $98
    .byte $8E, $FF, $AA, $B2, $1B, $B2, $05, $B7, $AB, $1A, $9F, $98, $95, $8C, $8A, $97
    .byte $98, $BF, $20, $B1, $27, $A7, $A8, $A9, $2B, $B7, $05, $B7, $AB, $A4, $21, $8F
    .byte $92, $8E, $97, $8D, $20, $AF, $B6, $B2, $C4, $00
; Dialogue  44 ($8C23): "400 yearsago, welost\ncontrol of theWind.\n200 yea"
    .byte $84, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $BF, $33, $1A, $AF, $B2, $37
    .byte $05, $A6, $B2, $B1, $B7, $4D, $AF, $36, $A9, $1B, $AB, $1A, $A0, $1F, $A7, $C0
    .byte $05, $82, $80, $80, $50, $2B, $B5, $1E, $AF, $39, $25, $33, $1A, $AF, $B2, $37
    .byte $05, $B7, $AB, $1A, $A0, $39, $25, $BF, $1B, $1D, $29, $8E, $2F, $B7, $AB, $BF
    .byte $05, $A4, $B1, $27, $8F, $AC, $B5, $1A, $A9, $B2, $4E, $46, $40, $C0, $FF, $9D
    .byte $1D, $05, $99, $B2, $BA, $25, $B6, $1B, $41, $21, $A5, $1F, $A7, $1B, $AB, $30
    .byte $05, $BA, $B2, $B5, $AF, $A7, $20, $B5, $1A, $AA, $3C, $A8, $C0, $00
; Dialogue  45 ($8C91): "Possessionof theCROWN\nisrequired totestyour\ncour"
    .byte $99, $B2, $B6, $B6, $2C, $B6, $AC, $B2, $29, $4C, $1B, $AB, $1A, $8C, $9B, $98
    .byte $A0, $97, $05, $AC, $B6, $FF, $23, $B4, $B8, $AC, $23, $A7, $1B, $2E, $B7, $2C
    .byte $21, $BC, $26, $B5, $05, $A6, $B2, $55, $A4, $66, $C0, $FF, $9D, $A4, $AE, $1A
    .byte $5B, $1B, $2E, $1C, $A8, $05, $B5, $B2, $BC, $5F, $1B, $AB, $B5, $3C, $A8, $BF
    .byte $20, $B1, $27, $A5, $B5, $1F, $AA, $05, $A5, $A4, $A6, $AE, $4F, $4D, $4C, $36
    .byte $A9, $50, $26, $B5, $05, $A6, $B2, $55, $A4, $66, $C0, $FF, $90, $98, $98, $8D
    .byte $FF, $95, $9E, $8C, $94, $C4, $00
; Dialogue  46 ($8CF8): "Rememberme,Garland?\nYourpunylot thoughtit\nhaddef"
    .byte $9B, $A8, $34, $B0, $A5, $25, $FF, $34, $BF, $FF, $90, $2F, $AF, $22, $A7, $C5
    .byte $05, $A2, $B2, $B8, $44, $B3, $B8, $B1, $4B, $AF, $B2, $B7, $1B, $AB, $B2, $B8
    .byte $AA, $AB, $21, $5B, $05, $AB, $A4, $27, $A7, $A8, $A9, $2B, $53, $27, $34, $C0
    .byte $FF, $8B, $B8, $B7, $BF, $05, $B7, $AB, $1A, $8F, $26, $44, $8F, $92, $8E, $97
    .byte $8D, $9C, $24, $3A, $21, $34, $05, $A5, $A4, $A6, $AE, $FF, $82, $80, $80, $80
    .byte $50, $2B, $B5, $1E, $1F, $28, $05, $B7, $AB, $1A, $B3, $A4, $37, $C0, $00
; Dialogue  47 ($8D57): "FromhereI sent the\nFourFIENDS tothe\nfuture.TheFI"
    .byte $8F, $B5, $49, $FF, $1D, $B5, $1A, $92, $24, $3A, $B7, $1B, $1D, $05, $8F, $B2
    .byte $B8, $44, $8F, $92, $8E, $97, $8D, $9C, $1B, $2E, $1C, $A8, $05, $A9, $B8, $B7
    .byte $B8, $23, $C0, $FF, $9D, $AB, $1A, $8F, $92, $8E, $97, $8D, $9C, $33, $AC, $4E
    .byte $05, $B6, $A8, $B1, $27, $B0, $1A, $A5, $5E, $AE, $1B, $2E, $1D, $23, $BF, $05
    .byte $A4, $B1, $A7, $1B, $AB, $1A, $9D, $AC, $34, $C2, $95, $B2, $B2, $B3, $33, $AC
    .byte $4E, $05, $AA, $B2, $36, $B1, $C0, $00
; Dialogue  48 ($8DAF): "After2000 years,I will\nbe forgotten, and the\nTim"
    .byte $8A, $A9, $B7, $25, $FF, $82, $80, $80, $80, $50, $2B, $63, $BF, $FF, $92, $33
    .byte $AC, $4E, $05, $A5, $A8, $43, $35, $AA, $B2, $B7, $B7, $3A, $BF, $20, $3B, $1B
    .byte $1D, $05, $9D, $AC, $34, $C2, $95, $B2, $B2, $B3, $33, $AC, $4E, $38, $AF, $B2
    .byte $3E, $C0, $FF, $92, $05, $BA, $AC, $4E, $65, $AC, $B9, $1A, $A9, $B2, $23, $B9
    .byte $25, $BF, $20, $3B, $05, $BC, $B2, $B8, $24, $41, $4E, $FF, $34, $A8, $21, $A7
    .byte $B2, $49, $C4, $C4, $00
; Dialogue  49 ($8E04): "TheKing islooking for\ntheLIGHTWARRIORS.You\ndonot"
    .byte $9D, $AB, $1A, $94, $1F, $AA, $2D, $1E, $AF, $B2, $B2, $AE, $1F, $AA, $43, $35
    .byte $05, $B7, $AB, $1A, $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B, $92, $98
    .byte $9B, $9C, $C0, $FF, $A2, $26, $05, $A7, $B2, $FF, $B1, $B2, $21, $41, $B3, $B3
    .byte $3A, $1B, $B2, $31, $1A, $1C, $A8, $B0, $05, $A7, $B2, $50, $26, $C5, $00
; Dialogue  50 ($8E43): "YesSir!!\nIbelong totheHonor\nGuardofCastleConeria"
    .byte $A2, $A8, $1E, $9C, $AC, $B5, $C4, $C4, $05, $92, $FF, $62, $AF, $B2, $2A, $1B
    .byte $2E, $1C, $1A, $91, $3C, $35, $05, $90, $B8, $2F, $27, $4C, $FF, $8C, $A4, $37
    .byte $AF, $1A, $8C, $3C, $25, $AC, $A4, $C0, $00
; Dialogue  51 ($8E6C): "Please!\nSavethePrincess!"
    .byte $99, $AF, $2B, $3E, $C4, $05, $9C, $A4, $B9, $1A, $1C, $1A, $99, $B5, $1F, $A6
    .byte $2C, $B6, $C4, $00
; Dialogue  52 ($8E80): "Thank you forrescuing\nthePrincess."
    .byte $9D, $AB, $22, $AE, $50, $26, $43, $35, $FF, $23, $B6, $A6, $B8, $1F, $AA, $05
    .byte $B7, $AB, $1A, $99, $B5, $1F, $A6, $2C, $B6, $C0, $00
; Dialogue  53 ($8E9B): "Legend says that the\nLUTE can break theevil\ngate"
    .byte $95, $A8, $AA, $3A, $A7, $24, $A4, $BC, $B6, $1B, $AB, $39, $1B, $1D, $05, $95
    .byte $9E, $9D, $8E, $38, $22, $31, $23, $A4, $AE, $1B, $AB, $1A, $A8, $B9, $61, $05
    .byte $AA, $A4, $53, $C0, $00
; Dialogue  54 ($8EC0): "Garlandused tobea\ngoodknightuntil.."
    .byte $90, $A4, $B5, $AF, $22, $27, $B8, $3E, $A7, $1B, $2E, $A5, $1A, $A4, $05, $AA
    .byte $B2, $B2, $27, $AE, $B1, $AC, $AA, $AB, $21, $B8, $B1, $57, $AF, $69, $00
; Dialogue  55 ($8EDF): "In sadness, theQueen\nlockedherselfinside."
    .byte $92, $B1, $24, $A4, $A7, $B1, $2C, $B6, $BF, $1B, $AB, $1A, $9A, $B8, $A8, $3A
    .byte $05, $AF, $B2, $A6, $AE, $A8, $27, $1D, $B5, $3E, $AF, $54, $1F, $B6, $AC, $A7
    .byte $A8, $C0, $00
; Dialogue  56 ($8F02): "ThePrincesswas\nlooking for you!"
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $2C, $1E, $BA, $3F, $05, $AF, $B2, $B2, $AE
    .byte $1F, $AA, $43, $35, $50, $26, $C4, $00
; Dialogue  57 ($8F1A): "So, you arethe\nLIGHTWARRIORS?"
    .byte $9C, $B2, $BF, $50, $26, $20, $B5, $1A, $1C, $A8, $05, $95, $92, $90, $91, $9D
    .byte $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C5, $00
; Dialogue  58 ($8F35): "Don'tbegreedy.You\nalreadyhavetoomany\nweapons toc"
    .byte $8D, $B2, $B1, $BE, $21, $A5, $1A, $AA, $23, $40, $BC, $C0, $FF, $A2, $26, $05
    .byte $A4, $AF, $23, $A4, $A7, $4B, $41, $B9, $1A, $28, $2E, $B0, $22, $BC, $05, $BA
    .byte $A8, $A4, $B3, $3C, $B6, $1B, $2E, $A6, $2F, $B5, $BC, $C0, $00
; Dialogue  59 ($8F62): "IamJane,Queenof\nConeria.Pleasesavemy\ndaughter,Pr"
    .byte $92, $FF, $A4, $B0, $FF, $93, $22, $A8, $BF, $FF, $9A, $B8, $A8, $A8, $29, $4C
    .byte $05, $8C, $B2, $B1, $25, $AC, $A4, $C0, $FF, $99, $AF, $2B, $B6, $1A, $B6, $A4
    .byte $B9, $1A, $B0, $BC, $05, $A7, $A4, $B8, $AA, $AB, $B7, $25, $BF, $FF, $99, $B5
    .byte $1F, $A6, $2C, $1E, $9C, $2F, $A4, $C0, $00
; Dialogue  60 ($8F9B): "Thank you for saving\nPrincessSara."
    .byte $9D, $AB, $22, $AE, $50, $26, $43, $35, $24, $A4, $B9, $1F, $AA, $05, $99, $B5
    .byte $1F, $A6, $2C, $1E, $9C, $2F, $A4, $C0, $00
; Dialogue  61 ($8FB4): "Oh..My sister.."
    .byte $98, $AB, $69, $FF, $96, $BC, $24, $30, $B7, $25, $69, $00
; Dialogue  62 ($8FC0): "My sister isback safe!\nThank you."
    .byte $96, $BC, $24, $30, $B7, $25, $2D, $1E, $A5, $5E, $AE, $24, $A4, $A9, $A8, $C4
    .byte $05, $9D, $AB, $22, $AE, $50, $26, $C0, $00
; Dialogue  63 ($8FD9): "Reportssay thatGarland\nholds thePrincessin a\nTem"
    .byte $9B, $A8, $B3, $35, $B7, $1E, $B6, $A4, $BC, $1B, $41, $21, $90, $2F, $AF, $22
    .byte $A7, $05, $AB, $B2, $AF, $A7, $B6, $1B, $AB, $1A, $99, $B5, $1F, $A6, $2C, $1E
    .byte $1F, $20, $05, $9D, $A8, $B0, $B3, $AF, $1A, $28, $1B, $AB, $1A, $B1, $35, $1C
    .byte $BA, $2C, $B7, $C0, $00
; Dialogue  64 ($900E): "UsethatKEY.Inside\nwhatyou findwill be\nquitehelpf"
    .byte $9E, $B6, $1A, $1C, $A4, $21, $94, $8E, $A2, $C0, $FF, $92, $B1, $B6, $AC, $A7
    .byte $A8, $05, $BA, $AB, $A4, $21, $BC, $26, $43, $1F, $27, $BA, $AC, $4E, $31, $A8
    .byte $05, $B4, $B8, $5B, $1A, $1D, $AF, $B3, $A9, $B8, $AF, $C0, $00
; Dialogue  65 ($903B): "400 yearsago the\nTreasury waslockedby\nthemysticK"
    .byte $84, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $1B, $1D, $05, $9D, $B5, $2B
    .byte $B6, $55, $BC, $33, $A4, $1E, $AF, $B2, $A6, $AE, $A8, $27, $A5, $BC, $05, $B7
    .byte $AB, $1A, $B0, $BC, $37, $AC, $A6, $FF, $94, $8E, $A2, $C0, $FF, $98, $55, $05
    .byte $A4, $B1, $A6, $2C, $28, $B5, $1E, $AA, $A4, $B9, $1A, $1C, $1A, $94, $8E, $A2
    .byte $05, $B7, $B2, $1B, $AB, $1A, $99, $B5, $1F, $A6, $1A, $4C, $FF, $8E, $AF, $A9
    .byte $95, $22, $A7, $05, $A9, $B2, $B5, $24, $A4, $A9, $A8, $AE, $A8, $A8, $B3, $1F
    .byte $AA, $C0, $00
; Dialogue  66 ($909E): "This treasureroom is\nlockedwith themystical\nKEY."
    .byte $9D, $AB, $30, $1B, $23, $3F, $55, $1A, $4D, $49, $2D, $B6, $05, $AF, $B2, $A6
    .byte $AE, $A8, $27, $BA, $AC, $1C, $1B, $AB, $1A, $B0, $BC, $37, $AC, $51, $AF, $05
    .byte $94, $8E, $A2, $C0, $00
; Dialogue  67 ($90C3): "TheKing issurethat\nsomeday theLIGHT\nWARRIORS wil"
    .byte $9D, $AB, $1A, $94, $1F, $AA, $2D, $1E, $B6, $55, $1A, $1C, $39, $05, $B6, $B2
    .byte $34, $A7, $A4, $BC, $1B, $AB, $1A, $95, $92, $90, $91, $9D, $05, $A0, $8A, $9B
    .byte $9B, $92, $98, $9B, $9C, $33, $AC, $4E, $38, $49, $1A, $28, $05, $B6, $A4, $B9
    .byte $1A, $1C, $1A, $99, $B5, $1F, $A6, $2C, $B6, $BF, $05, $AD, $B8, $37, $20, $1E
    .byte $1F, $FF, $95, $B8, $AE, $A4, $AB, $B1, $BE, $B6, $05, $B3, $B5, $B2, $B3, $1D
    .byte $A6, $BC, $C0, $00
; Dialogue  68 ($9117): "Lukahnleft this town,\ntojoinhiscolleagues\natCres"
    .byte $95, $B8, $AE, $A4, $AB, $29, $45, $A9, $B7, $1B, $AB, $30, $1B, $46, $B1, $BF
    .byte $05, $B7, $B2, $FF, $AD, $B2, $1F, $FF, $3D, $1E, $A6, $B2, $4E, $2B, $AA, $B8
    .byte $2C, $05, $A4, $B7, $FF, $8C, $23, $B6, $A6, $3A, $B7, $FF, $95, $A4, $AE, $A8
    .byte $C0, $00
; Dialogue  69 ($9149): "Aslegendforetold, once\nagain theORBS shine!!\nQui"
    .byte $8A, $B6, $FF, $45, $AA, $3A, $27, $A9, $B2, $23, $28, $AF, $A7, $BF, $36, $B1
    .byte $48, $05, $A4, $AA, $A4, $1F, $1B, $AB, $1A, $98, $9B, $8B, $9C, $24, $AB, $1F
    .byte $A8, $C4, $C4, $05, $9A, $B8, $AC, $A6, $AE, $AF, $BC, $BF, $1B, $2E, $A9, $B8
    .byte $AF, $A9, $AC, $4E, $1B, $1D, $05, $AF, $A8, $AA, $3A, $A7, $BF, $1B, $A4, $AE
    .byte $1A, $1C, $A8, $B0, $1B, $2E, $1C, $A8, $05, $9D, $A8, $B0, $B3, $AF, $1A, $B1
    .byte $35, $1C, $36, $54, $1D, $23, $BF, $05, $A4, $B1, $A7, $24, $B7, $A4, $B1, $27
    .byte $1F, $1B, $AB, $1A, $A6, $3A, $B7, $25, $C0, $00
; Dialogue  70 ($91B3): "Go totheKing."
    .byte $90, $B2, $1B, $2E, $1C, $1A, $94, $1F, $AA, $C0, $00
; Dialogue  71 ($91BE): "IamArylon, theDancer!"
    .byte $92, $FF, $A4, $B0, $FF, $8A, $B5, $BC, $AF, $3C, $BF, $1B, $AB, $1A, $8D, $22
    .byte $A6, $25, $C4, $00
; Dialogue  72 ($91D2): "ThisisConeria, the\ndream city."
    .byte $9D, $AB, $AC, $1E, $30, $FF, $8C, $3C, $25, $AC, $A4, $BF, $1B, $1D, $05, $A7
    .byte $B5, $2B, $B0, $38, $5B, $BC, $C0, $00
; Dialogue  73 ($91EA): "North ofConeria lives\nawitchnamedMatoya."
    .byte $97, $B2, $B5, $1C, $36, $54, $8C, $3C, $25, $AC, $A4, $65, $AC, $B9, $2C, $05
    .byte $A4, $FF, $BA, $5B, $A6, $AB, $FF, $B1, $A4, $34, $27, $96, $A4, $28, $BC, $A4
    .byte $C0, $00
; Dialogue  74 ($920C): "Matoyahaspoor\neyesight.Sheneeds the\nCRYSTAL to s"
    .byte $96, $A4, $28, $BC, $A4, $FF, $41, $1E, $B3, $B2, $35, $05, $A8, $BC, $2C, $AC
    .byte $AA, $AB, $B7, $C0, $FF, $9C, $AB, $1A, $5A, $40, $B6, $1B, $1D, $05, $8C, $9B
    .byte $A2, $9C, $9D, $8A, $95, $1B, $B2, $24, $A8, $A8, $C0, $00
; Dialogue  75 ($9238): "My homeisPravoka, a\nbeautiful portcity far\neasto"
    .byte $96, $BC, $59, $49, $1A, $AC, $1E, $99, $B5, $A4, $B9, $B2, $AE, $A4, $BF, $20
    .byte $05, $A5, $A8, $A4, $B8, $57, $A9, $B8, $AF, $4F, $35, $21, $A6, $5B, $BC, $43
    .byte $2F, $05, $A8, $A4, $B6, $21, $4C, $FF, $1D, $23, $C0, $00
; Dialogue  76 ($9264): "Kee..Kee.."
    .byte $94, $A8, $A8, $69, $94, $A8, $A8, $69, $00
; Dialogue  77 ($926D): "Help!TheFIEND'scurse\nturnedusinto bats.\nWith the"
    .byte $91, $A8, $AF, $B3, $C4, $FF, $9D, $AB, $1A, $8F, $92, $8E, $97, $8D, $BE, $1E
    .byte $A6, $55, $3E, $05, $B7, $B8, $B5, $5A, $27, $B8, $1E, $1F, $28, $31, $39, $B6
    .byte $C0, $05, $A0, $AC, $1C, $1B, $AB, $1A, $98, $9B, $8B, $9C, $24, $AB, $1F, $AC
    .byte $2A, $05, $A4, $B1, $A8, $BA, $BF, $36, $B1, $A6, $1A, $A4, $AA, $A4, $1F, $33
    .byte $A8, $05, $A6, $A4, $B1, $24, $B3, $2B, $AE, $C4, $00
; Dialogue  78 ($92B8): "TheFourFIENDS power\nisrooted2000 years\nago.There"
    .byte $9D, $AB, $1A, $8F, $26, $44, $8F, $92, $8E, $97, $8D, $9C, $4F, $46, $25, $05
    .byte $AC, $B6, $FF, $4D, $B2, $53, $27, $82, $80, $80, $80, $50, $2B, $63, $05, $A4
    .byte $AA, $B2, $C0, $FF, $9D, $AB, $1A, $23, $A4, $58, $3A, $A8, $B0, $BC, $2D, $B6
    .byte $05, $AC, $B1, $1B, $AB, $39, $1B, $AC, $34, $C0, $00
; Dialogue  79 ($92F3): "When the4ORBS cover\ntheblackORBin the\ncenter of "
    .byte $A0, $AB, $3A, $1B, $AB, $1A, $84, $FF, $98, $9B, $8B, $9C, $38, $B2, $B9, $25
    .byte $05, $B7, $AB, $1A, $A5, $AF, $5E, $AE, $FF, $98, $9B, $8B, $FF, $1F, $1B, $1D
    .byte $05, $A6, $A8, $B1, $B7, $25, $36, $A9, $1B, $AB, $1A, $B3, $5F, $5E, $A8, $BF
    .byte $05, $B7, $AB, $1A, $9D, $AC, $B0, $1A, $90, $39, $1A, $A6, $22, $36, $B3, $3A
    .byte $C0, $00
; Dialogue  80 ($9335): "You must travel backin\ntime2000 years.Now,\nwith "
    .byte $A2, $B2, $B8, $42, $B8, $37, $1B, $B5, $A4, $32, $AF, $31, $5E, $AE, $FF, $1F
    .byte $05, $B7, $AC, $B0, $1A, $82, $80, $80, $80, $50, $2B, $63, $C0, $FF, $97, $46
    .byte $BF, $05, $BA, $AC, $1C, $1B, $AB, $1A, $98, $9B, $8B, $9C, $24, $AB, $1F, $AC
    .byte $2A, $BF, $05, $B6, $B7, $22, $27, $1F, $1B, $AB, $1A, $9D, $AC, $B0, $1A, $90
    .byte $39, $A8, $C0, $00
; Dialogue  81 ($9379): "We are the five lost\nSKYWARRIORS.400 years\nagowe"
    .byte $A0, $A8, $20, $23, $1B, $1D, $43, $AC, $32, $65, $B2, $37, $05, $9C, $94, $A2
    .byte $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $FF, $84, $80, $80, $50, $2B
    .byte $63, $05, $A4, $AA, $2E, $BA, $1A, $A5, $39, $B7, $AF, $40, $20, $AA, $A4, $1F
    .byte $37, $05, $B7, $AB, $1A, $51, $B8, $B6, $1A, $4C, $1B, $AB, $1A, $BA, $35, $AF
    .byte $A7, $BE, $B6, $05, $A7, $A8, $37, $B5, $B8, $A6, $57, $3C, $C0, $00
; Dialogue  82 ($93C7): "Thank you.Wedon'tneed\nto beafraidof pirates\nanym"
    .byte $9D, $AB, $22, $AE, $50, $26, $C0, $FF, $A0, $1A, $A7, $3C, $BE, $21, $5A, $40
    .byte $05, $B7, $B2, $31, $1A, $A4, $A9, $B5, $A4, $AC, $27, $4C, $4F, $AC, $B5, $39
    .byte $2C, $05, $A4, $B1, $BC, $B0, $B2, $23, $C0, $00
; Dialogue  83 ($93F1): "Ihaveescapedfrom\nMelmond,in thewest.\nMy townisin"
    .byte $92, $FF, $41, $B9, $1A, $2C, $51, $B3, $A8, $27, $A9, $B5, $49, $05, $96, $A8
    .byte $AF, $B0, $B2, $3B, $BF, $FF, $1F, $1B, $AB, $1A, $BA, $2C, $B7, $C0, $05, $96
    .byte $BC, $1B, $46, $29, $AC, $1E, $1F, $1B, $B5, $26, $A5, $45, $C0, $05, $99, $AF
    .byte $2B, $B6, $1A, $1D, $AF, $B3, $1B, $1D, $B0, $C4, $C4, $00
; Dialogue  84 ($942D): "TheElvesliveacross\nthesea.Matoya'sHERB\nis theonl"
    .byte $9D, $AB, $1A, $8E, $AF, $32, $1E, $68, $B9, $1A, $5E, $4D, $B6, $B6, $05, $B7
    .byte $AB, $1A, $B6, $2B, $C0, $FF, $96, $A4, $28, $BC, $A4, $BE, $1E, $91, $8E, $9B
    .byte $8B, $05, $AC, $B6, $1B, $AB, $1A, $3C, $AF, $BC, $1B, $AB, $1F, $AA, $1B, $AB
    .byte $39, $05, $BA, $AC, $4E, $33, $A4, $AE, $1A, $1C, $A8, $AC, $44, $99, $B5, $1F
    .byte $48, $C0, $00
; Dialogue  85 ($9470): "This townhasbeen\ninvadedbypirates."
    .byte $9D, $AB, $30, $1B, $46, $29, $41, $1E, $62, $3A, $05, $AC, $B1, $B9, $A4, $A7
    .byte $A8, $27, $A5, $4B, $B3, $AC, $B5, $39, $2C, $C0, $00
; Dialogue  86 ($948B): "Shipscan stop only at\nports.Thereareno\nportsin t"
    .byte $9C, $AB, $AC, $B3, $1E, $A6, $22, $24, $28, $B3, $36, $B1, $AF, $BC, $20, $B7
    .byte $05, $B3, $B2, $B5, $B7, $B6, $C0, $FF, $9D, $1D, $B5, $1A, $2F, $1A, $B1, $B2
    .byte $05, $B3, $B2, $B5, $B7, $1E, $1F, $1B, $AB, $1A, $B1, $B2, $B5, $1C, $C0, $00
; Dialogue  87 ($94BB): "Help!"
    .byte $91, $A8, $AF, $B3, $C4, $00
; Dialogue  88 ($94C1): "Therearemanydangerous\nmonstersin thesea.\nBe care"
    .byte $9D, $AB, $25, $1A, $2F, $1A, $B0, $22, $4B, $A7, $22, $AA, $25, $26, $B6, $05
    .byte $B0, $B2, $B1, $37, $25, $1E, $1F, $1B, $AB, $1A, $B6, $2B, $C0, $05, $8B, $A8
    .byte $38, $A4, $23, $A9, $B8, $AF, $C4, $00
; Dialogue  89 ($94E9): "Astosput thePrinceto\nsleep.\nPlease!Savehim!"
    .byte $8A, $B6, $28, $1E, $B3, $B8, $B7, $1B, $AB, $1A, $99, $B5, $1F, $A6, $1A, $28
    .byte $05, $B6, $AF, $A8, $A8, $B3, $C0, $05, $99, $AF, $2B, $3E, $C4, $FF, $9C, $A4
    .byte $B9, $1A, $3D, $B0, $C4, $00
; Dialogue  90 ($950F): "ThePrinceisawake!\nThank you somuch."
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $1A, $AC, $1E, $A4, $5D, $AE, $A8, $C4, $05
    .byte $9D, $AB, $22, $AE, $50, $26, $24, $2E, $B0, $B8, $A6, $AB, $C0, $00
; Dialogue  91 ($952D): "TheCaveofDwarf isat\nthewestendof theAldi\nSea."
    .byte $9D, $AB, $1A, $8C, $A4, $B9, $1A, $4C, $FF, $8D, $BA, $2F, $A9, $2D, $1E, $39
    .byte $05, $B7, $AB, $1A, $BA, $2C, $21, $3A, $27, $4C, $1B, $AB, $1A, $8A, $AF, $A7
    .byte $AC, $05, $9C, $A8, $A4, $C0, $00
; Dialogue  92 ($9554): "Withoutwarning,Astos\nattackedour castle.Our\nPrin"
    .byte $A0, $AC, $1C, $26, $21, $BA, $2F, $B1, $1F, $AA, $BF, $FF, $8A, $B6, $28, $B6
    .byte $05, $A4, $B7, $B7, $5E, $AE, $A8, $27, $26, $B5, $38, $A4, $37, $45, $C0, $FF
    .byte $98, $55, $05, $99, $B5, $1F, $A6, $1A, $5D, $1E, $AF, $A4, $AC, $27, $B8, $3B
    .byte $25, $20, $05, $A6, $B8, $B5, $3E, $BF, $20, $B1, $27, $26, $B5, $1B, $23, $3F
    .byte $B8, $B5, $BC, $05, $B5, $A4, $B1, $B6, $5E, $AE, $40, $C0, $00
; Dialogue  93 ($95A1): "It issaid thereisa\nwitch whohasHERBS.\nIbelieveth"
    .byte $92, $B7, $2D, $1E, $B6, $A4, $AC, $A7, $1B, $1D, $B5, $1A, $AC, $1E, $A4, $05
    .byte $BA, $AC, $B7, $A6, $AB, $33, $AB, $2E, $41, $1E, $91, $8E, $9B, $8B, $9C, $C0
    .byte $05, $92, $FF, $62, $68, $A8, $B9, $1A, $1C, $A4, $21, $1D, $44, $B1, $A4, $34
    .byte $05, $AC, $B6, $69, $05, $96, $A4, $28, $BC, $A4, $C4, $00
; Dialogue  94 ($95DD): "Is thatit?TheHERB to\nsavethePrince?"
    .byte $92, $B6, $1B, $41, $21, $5B, $C5, $FF, $9D, $AB, $1A, $91, $8E, $9B, $8B, $1B
    .byte $B2, $05, $B6, $A4, $B9, $1A, $1C, $1A, $99, $B5, $1F, $48, $C5, $00
; Dialogue  95 ($95FB): "ThePrincekeeps the\nmysticKEYuntil the\ncoming of "
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $1A, $AE, $A8, $A8, $B3, $B6, $1B, $1D, $05
    .byte $B0, $BC, $37, $AC, $A6, $FF, $94, $8E, $A2, $FF, $B8, $B1, $57, $AF, $1B, $1D
    .byte $05, $A6, $B2, $B0, $1F, $AA, $36, $A9, $1B, $1D, $05, $95, $92, $90, $91, $9D
    .byte $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $00
; Dialogue  96 ($9636): "Maybeit'sonlyrumour,\nbut,I think thecause\nof all"
    .byte $96, $A4, $BC, $A5, $1A, $5B, $BE, $1E, $3C, $AF, $4B, $B5, $B8, $B0, $26, $B5
    .byte $BF, $05, $A5, $B8, $B7, $BF, $FF, $92, $1B, $AB, $1F, $AE, $1B, $AB, $1A, $51
    .byte $B8, $3E, $05, $B2, $A9, $20, $4E, $4F, $4D, $A5, $45, $B0, $1E, $30, $1B, $B2
    .byte $05, $A5, $A8, $43, $26, $B1, $27, $1F, $1B, $1D, $38, $A4, $32, $36, $A9, $05
    .byte $96, $A4, $63, $AB, $C0, $00
; Dialogue  97 ($967C): "SaveourPrince!"
    .byte $9C, $A4, $B9, $1A, $26, $44, $99, $B5, $1F, $48, $C4, $00
; Dialogue  98 ($9688): "OurPrincewas to\nbecometheKing of\nElfLand."
    .byte $98, $B8, $44, $99, $B5, $1F, $A6, $1A, $BA, $3F, $1B, $B2, $05, $A5, $A8, $A6
    .byte $49, $1A, $1C, $1A, $94, $1F, $AA, $36, $A9, $05, $8E, $AF, $A9, $95, $22, $A7
    .byte $C0, $00
; Dialogue  99 ($96AA): "Long agoI wandered to\ntheNorthwest.I found\nan an"
    .byte $95, $B2, $2A, $20, $AA, $2E, $92, $33, $22, $A7, $A8, $23, $A7, $1B, $B2, $05
    .byte $B7, $AB, $1A, $97, $35, $B7, $AB, $BA, $2C, $B7, $C0, $FF, $92, $43, $26, $3B
    .byte $05, $A4, $B1, $20, $B1, $A6, $AC, $3A, $21, $51, $37, $AF, $1A, $1C, $39, $05
    .byte $BA, $A4, $1E, $B6, $B2, $24, $B3, $B2, $B2, $AE, $BC, $BF, $FF, $92, $FF, $45
    .byte $A9, $B7, $05, $AC, $B0, $34, $A7, $AC, $39, $A8, $AF, $BC, $C0, $00
; Dialogue 100 ($96F8): "Astoshasbeendefeated?\nPeacewillnowreturn to\nElfL"
    .byte $8A, $B6, $28, $1E, $41, $1E, $62, $A8, $29, $A7, $A8, $A9, $2B, $B7, $40, $C5
    .byte $05, $99, $A8, $5E, $1A, $BA, $AC, $4E, $FF, $B1, $46, $FF, $23, $B7, $55, $B1
    .byte $1B, $B2, $05, $8E, $AF, $A9, $95, $22, $A7, $C0, $00
; Dialogue 101 ($9723): "Astoswearsa disguise,\nandlurksin seclusion."
    .byte $8A, $B6, $28, $1E, $BA, $2B, $B5, $1E, $A4, $67, $30, $AA, $B8, $30, $A8, $BF
    .byte $05, $A4, $B1, $27, $AF, $55, $AE, $1E, $1F, $24, $A8, $A6, $AF, $B8, $B6, $AC
    .byte $3C, $C0, $00
; Dialogue 102 ($9746): "ThePrincemustwake\nsoon,or thepower of\ntheDarkElf"
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $1A, $B0, $B8, $B6, $21, $5D, $AE, $A8, $05
    .byte $B6, $B2, $3C, $BF, $FF, $35, $1B, $AB, $1A, $B3, $46, $25, $36, $A9, $05, $B7
    .byte $AB, $1A, $8D, $2F, $AE, $FF, $8E, $AF, $A9, $33, $AC, $4E, $05, $A7, $B2, $B0
    .byte $1F, $39, $A8, $C4, $00
; Dialogue 103 ($977B): "Legend saysanAIRSHIP\nis buried somewhere."
    .byte $95, $A8, $AA, $3A, $A7, $24, $A4, $BC, $1E, $22, $FF, $8A, $92, $9B, $9C, $91
    .byte $92, $99, $05, $AC, $B6, $31, $55, $AC, $40, $24, $B2, $34, $BA, $1D, $23, $C0
    .byte $00
; Dialogue 104 ($979C): "Swordsand armorsmade\nof silver are\nverypowerful."
    .byte $9C, $BA, $35, $A7, $1E, $22, $A7, $20, $B5, $B0, $35, $1E, $B0, $A4, $A7, $A8
    .byte $05, $B2, $A9, $24, $61, $B9, $25, $20, $23, $05, $B9, $A8, $B5, $4B, $B3, $46
    .byte $A8, $B5, $A9, $B8, $AF, $C0, $00
; Dialogue 105 ($97C3): "Ican seeacaveabove\nthecrescent..\nTo thenorth of "
    .byte $92, $FF, $A6, $22, $24, $A8, $1A, $A4, $FF, $51, $B9, $1A, $A4, $A5, $B2, $32
    .byte $05, $B7, $AB, $1A, $A6, $23, $B6, $A6, $3A, $B7, $69, $05, $9D, $B2, $1B, $AB
    .byte $1A, $B1, $35, $1C, $36, $A9, $1B, $1D, $05, $B9, $B2, $AF, $A6, $22, $B2, $BF
    .byte $1B, $1D, $B5, $1A, $BC, $26, $33, $AC, $4E, $05, $A9, $AC, $3B, $1B, $AB, $1A
    .byte $8F, $95, $98, $8A, $9D, $8E, $9B, $C0, $00
; Dialogue 106 ($980C): "In thedesertsouth of\nthecrescent, something\nisem"
    .byte $92, $B1, $1B, $AB, $1A, $A7, $2C, $25, $21, $B6, $26, $1C, $36, $A9, $05, $B7
    .byte $AB, $1A, $A6, $23, $B6, $A6, $3A, $B7, $BF, $24, $B2, $34, $B7, $AB, $1F, $AA
    .byte $05, $AC, $B6, $FF, $A8, $B0, $25, $AA, $1F, $AA, $43, $B5, $49, $31, $A8, $AF
    .byte $46, $05, $B7, $AB, $1A, $B6, $22, $A7, $69, $05, $9E, $B6, $1A, $1C, $1A, $8F
    .byte $95, $98, $8A, $9D, $8E, $9B, $C4, $00
; Dialogue 107 ($9854): "ThePrincemustwake\nsoon,or theDarkElf\nwill domina"
    .byte $9D, $AB, $1A, $99, $B5, $1F, $A6, $1A, $B0, $B8, $B6, $21, $5D, $AE, $A8, $05
    .byte $B6, $B2, $3C, $BF, $FF, $35, $1B, $AB, $1A, $8D, $2F, $AE, $FF, $8E, $AF, $A9
    .byte $05, $BA, $AC, $4E, $67, $49, $1F, $39, $A8, $C4, $00
; Dialogue 108 ($987F): "I'm looking for the\nFLOATER.I'll betwith\nitI cou"
    .byte $92, $BE, $B0, $65, $B2, $B2, $AE, $1F, $AA, $43, $35, $1B, $1D, $05, $8F, $95
    .byte $98, $8A, $9D, $8E, $9B, $C0, $FF, $92, $BE, $4E, $31, $A8, $21, $BA, $AC, $1C
    .byte $05, $AC, $B7, $FF, $92, $38, $26, $AF, $27, $A9, $AF, $B2, $39, $05, $A4, $B1
    .byte $BC, $1C, $1F, $AA, $C0, $00
; Dialogue 109 ($98B5): "OldNerrick isavery\nrespectableDwarf."
    .byte $98, $AF, $27, $97, $25, $5C, $A6, $AE, $2D, $1E, $A4, $FF, $B9, $25, $BC, $05
    .byte $B5, $A8, $B6, $B3, $A8, $A6, $B7, $A4, $A5, $AF, $1A, $8D, $BA, $2F, $A9, $C0
    .byte $00
; Dialogue 110 ($98D6): "Thatsound?\nNerrick isdigging a\ncanal."
    .byte $9D, $AB, $A4, $21, $B6, $26, $3B, $C5, $05, $97, $A8, $B5, $5C, $A6, $AE, $2D
    .byte $1E, $A7, $AC, $AA, $AA, $1F, $AA, $20, $05, $A6, $A4, $B1, $5F, $C0, $00
; Dialogue 111 ($98F5): "Dwarvescan seein the\ndark!"
    .byte $8D, $BA, $2F, $32, $1E, $A6, $22, $24, $A8, $1A, $1F, $1B, $1D, $05, $A7, $A4
    .byte $B5, $AE, $C4, $00
; Dialogue 112 ($9909): "DidyoumeetSmith,\nour blacksmith?"
    .byte $8D, $AC, $27, $BC, $26, $FF, $34, $A8, $21, $9C, $B0, $AC, $1C, $BF, $05, $B2
    .byte $B8, $B5, $31, $AF, $5E, $AE, $B6, $B0, $AC, $1C, $C5, $00
; Dialogue 113 ($9925): "With theCRYSTAL,even\ntheblindcan see.\nAstosstole"
    .byte $A0, $AC, $1C, $1B, $AB, $1A, $8C, $9B, $A2, $9C, $9D, $8A, $95, $BF, $FF, $A8
    .byte $32, $B1, $05, $B7, $AB, $1A, $A5, $AF, $1F, $27, $A6, $22, $24, $A8, $A8, $C0
    .byte $05, $8A, $B6, $28, $1E, $B6, $28, $AF, $1A, $AC, $21, $A9, $B5, $49, $05, $96
    .byte $A4, $28, $BC, $A4, $C0, $00
; Dialogue 114 ($995B): "Theearth isrotting\nslowly from thewest.."
    .byte $9D, $AB, $1A, $2B, $B5, $1C, $2D, $1E, $4D, $B7, $B7, $1F, $AA, $05, $B6, $AF
    .byte $46, $AF, $BC, $43, $B5, $49, $1B, $AB, $1A, $BA, $2C, $B7, $69, $00
; Dialogue 115 ($9979): "Theearth isreviving!\nThanks toyou,\nLIGHTWARRIORS"
    .byte $9D, $AB, $1A, $2B, $B5, $1C, $2D, $1E, $23, $B9, $AC, $B9, $1F, $AA, $C4, $05
    .byte $9D, $AB, $22, $AE, $B6, $1B, $2E, $BC, $26, $BF, $05, $95, $92, $90, $91, $9D
    .byte $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C4, $00
; Dialogue 116 ($99A4): "The[DE]..braceletcan\nprotectyou, like\narmor."
    .byte $9D, $AB, $1A, $DE, $69, $A5, $B5, $A4, $48, $45, $21, $A6, $22, $05, $B3, $B5
    .byte $B2, $53, $A6, $21, $BC, $26, $BF, $65, $AC, $AE, $A8, $05, $A4, $B5, $B0, $35
    .byte $C0, $00
; Dialogue 117 ($99C6): "Oh, didyou seethat\ncanal?OldNerrick truly\nisgrea"
    .byte $98, $AB, $BF, $67, $AC, $27, $BC, $26, $24, $A8, $1A, $1C, $39, $05, $A6, $A4
    .byte $B1, $5F, $C5, $FF, $98, $AF, $27, $97, $25, $5C, $A6, $AE, $1B, $B5, $B8, $AF
    .byte $BC, $05, $AC, $B6, $FF, $AA, $23, $A4, $21, $1F, $A7, $A8, $40, $C0, $00
; Dialogue 118 ($99F5): "Long ago,Coneria's\nTreasury safeguarded\ntheuseof"
    .byte $95, $B2, $2A, $20, $AA, $B2, $BF, $FF, $8C, $3C, $25, $AC, $A4, $BE, $B6, $05
    .byte $9D, $B5, $2B, $B6, $55, $BC, $24, $A4, $A9, $A8, $AA, $B8, $2F, $A7, $40, $05
    .byte $B7, $AB, $1A, $B8, $B6, $1A, $4C, $FF, $9D, $97, $9D, $C0, $00
; Dialogue 119 ($9A22): "Hurray!!"
    .byte $91, $B8, $B5, $B5, $A4, $BC, $C4, $C4, $00
; Dialogue 120 ($9A2B): "....TCELESBHSUP\nAmagic spell?"
    .byte $C3, $C3, $9D, $8C, $8E, $95, $8E, $9C, $FF, $8B, $FF, $91, $9C, $9E, $99, $05
    .byte $8A, $FF, $B0, $A4, $AA, $AC, $A6, $24, $B3, $A8, $4E, $C5, $00
; Dialogue 121 ($9A48): "TheVampireof theEarth\nCaveisstealing the\nPower o"
    .byte $9D, $AB, $1A, $9F, $A4, $B0, $B3, $AC, $B5, $1A, $4C, $1B, $AB, $1A, $8E, $2F
    .byte $1C, $05, $8C, $A4, $B9, $1A, $AC, $1E, $37, $2B, $AF, $1F, $AA, $1B, $1D, $05
    .byte $99, $B2, $BA, $25, $36, $A9, $1B, $AB, $1A, $2B, $B5, $1C, $C0, $05, $A0, $A8
    .byte $FF, $5A, $A8, $27, $BC, $26, $44, $1D, $AF, $B3, $C0, $00
; Dialogue 122 ($9A84): "Melmondwasoncea\nbeautiful town."
    .byte $96, $A8, $AF, $B0, $3C, $27, $5D, $1E, $3C, $A6, $1A, $A4, $05, $A5, $A8, $A4
    .byte $B8, $57, $A9, $B8, $AF, $1B, $46, $B1, $C0, $00
; Dialogue 123 ($9A9E): "TheTitan wholivesin\nthetunneleatsgems.\nHe lovesR"
    .byte $9D, $AB, $1A, $9D, $5B, $22, $33, $AB, $2E, $68, $32, $1E, $1F, $05, $B7, $AB
    .byte $1A, $B7, $B8, $B1, $5A, $58, $2B, $B7, $1E, $66, $B0, $B6, $C0, $05, $91, $A8
    .byte $65, $B2, $32, $1E, $9B, $9E, $8B, $92, $8E, $9C, $C0, $00
; Dialogue 124 ($9ACA): "TheVampireisgone, but\ntheearth continues to\nrot."
    .byte $9D, $AB, $1A, $9F, $A4, $B0, $B3, $AC, $B5, $1A, $AC, $1E, $AA, $3C, $A8, $BF
    .byte $31, $B8, $B7, $05, $B7, $AB, $1A, $2B, $B5, $B7, $AB, $38, $3C, $B7, $1F, $B8
    .byte $2C, $1B, $B2, $05, $B5, $B2, $B7, $C0, $FF, $A0, $41, $21, $51, $B8, $B6, $2C
    .byte $1B, $AB, $30, $C5, $00
; Dialogue 125 ($9AFF): "I'm a farmer."
    .byte $92, $BE, $B0, $20, $43, $2F, $B0, $25, $C0, $00
; Dialogue 126 ($9B09): "TheEarthCaveison\nthepeninsula southwest\nof this "
    .byte $9D, $AB, $1A, $8E, $2F, $1C, $FF, $8C, $A4, $B9, $1A, $AC, $1E, $3C, $05, $B7
    .byte $AB, $1A, $B3, $3A, $1F, $B6, $B8, $AF, $A4, $24, $26, $B7, $AB, $BA, $2C, $B7
    .byte $05, $B2, $A9, $1B, $AB, $30, $1B, $46, $B1, $C0, $00
; Dialogue 127 ($9B34): "Look!TheEarthORB is\nshining again."
    .byte $95, $B2, $B2, $AE, $C4, $FF, $9D, $AB, $1A, $8E, $2F, $1C, $FF, $98, $9B, $8B
    .byte $2D, $B6, $05, $B6, $AB, $1F, $AC, $2A, $20, $AA, $A4, $AC, $B1, $C0, $00
; Dialogue 128 ($9B53): "This townwasinvadedby\ntheVampire.TheClinic\nwasde"
    .byte $9D, $AB, $30, $1B, $46, $29, $5D, $1E, $1F, $B9, $A4, $A7, $A8, $27, $A5, $BC
    .byte $05, $B7, $AB, $1A, $9F, $A4, $B0, $B3, $AC, $23, $C0, $FF, $9D, $AB, $1A, $8C
    .byte $AF, $1F, $AC, $A6, $05, $BA, $A4, $1E, $A7, $2C, $B7, $4D, $BC, $40, $20, $3B
    .byte $1B, $1D, $05, $B7, $B2, $BA, $29, $5D, $1E, $A6, $55, $3E, $A7, $C0, $00
; Dialogue 129 ($9B92): "Areyou the\nLIGHTWARRIORS?"
    .byte $8A, $B5, $1A, $BC, $26, $1B, $1D, $05, $95, $92, $90, $91, $9D, $FF, $A0, $8A
    .byte $9B, $9B, $92, $98, $9B, $9C, $C5, $00
; Dialogue 130 ($9BAA): "Pass through theTitan's\nTunnel, then south to\nfi"
    .byte $99, $A4, $B6, $B6, $1B, $AB, $B5, $26, $AA, $AB, $1B, $AB, $1A, $9D, $5B, $22
    .byte $BE, $B6, $05, $9D, $B8, $B1, $5A, $AF, $BF, $1B, $1D, $B1, $24, $26, $1C, $1B
    .byte $B2, $05, $A9, $AC, $B1, $27, $9C, $2F, $A7, $A4, $BF, $1B, $AB, $1A, $9C, $A4
    .byte $66, $C0, $00
; Dialogue 131 ($9BDD): "TheVampireisgone, but\ntheearth stillrots?.."
    .byte $9D, $AB, $1A, $9F, $A4, $B0, $B3, $AC, $B5, $1A, $AC, $1E, $AA, $3C, $A8, $BF
    .byte $31, $B8, $B7, $05, $B7, $AB, $1A, $2B, $B5, $B7, $AB, $24, $57, $4E, $FF, $4D
    .byte $B7, $B6, $C5, $69, $00
; Dialogue 132 ($9C02): "In thenorthernworld,\nthereoncewasa\nprosperousciv"
    .byte $92, $B1, $1B, $AB, $1A, $B1, $35, $1C, $25, $29, $BA, $35, $AF, $A7, $BF, $05
    .byte $B7, $AB, $25, $1A, $3C, $A6, $1A, $5D, $1E, $A4, $05, $B3, $B5, $B2, $B6, $B3
    .byte $25, $26, $1E, $A6, $AC, $B9, $61, $AC, $BD, $39, $AC, $3C, $BF, $05, $A5, $B8
    .byte $21, $B1, $46, $2D, $21, $AC, $1E, $B5, $B8, $1F, $B6, $C0, $00
; Dialogue 133 ($9C3F): "If theORB ofEarth\nbegins to shineagain,\ntheearth"
    .byte $92, $A9, $1B, $AB, $1A, $98, $9B, $8B, $36, $54, $8E, $2F, $1C, $05, $A5, $A8
    .byte $AA, $1F, $B6, $1B, $B2, $24, $AB, $1F, $1A, $A4, $AA, $A4, $1F, $BF, $05, $B7
    .byte $AB, $1A, $2B, $B5, $B7, $AB, $24, $41, $4E, $FF, $23, $B9, $AC, $32, $C0, $00
; Dialogue 134 ($9C6F): "LIGHTWARRIORS..\nThanks toyou, theearth\nis beginn"
    .byte $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $69, $05
    .byte $9D, $AB, $22, $AE, $B6, $1B, $2E, $BC, $26, $BF, $1B, $AB, $1A, $2B, $B5, $1C
    .byte $05, $AC, $B6, $31, $A8, $AA, $1F, $B1, $AC, $2A, $1B, $2E, $23, $B9, $AC, $32
    .byte $69, $00
; Dialogue 135 ($9CA1): "They say theancient\npeopleused a stoneto\nmakethe"
    .byte $9D, $AB, $A8, $BC, $24, $A4, $BC, $1B, $AB, $1A, $22, $A6, $AC, $3A, $B7, $05
    .byte $B3, $A8, $B2, $B3, $AF, $1A, $B8, $3E, $A7, $20, $24, $28, $B1, $1A, $28, $05
    .byte $B0, $A4, $AE, $1A, $1C, $A8, $AC, $B5, $24, $3D, $B3, $43, $AF, $B2, $39, $C0
    .byte $00
; Dialogue 136 ($9CD2): "OH!AnAIRSHIP!\nThefablesaretrue, it\nreallyexists!"
    .byte $98, $91, $C4, $FF, $8A, $29, $8A, $92, $9B, $9C, $91, $92, $99, $C4, $05, $9D
    .byte $AB, $1A, $A9, $A4, $A5, $45, $1E, $2F, $1A, $B7, $B5, $B8, $A8, $BF, $2D, $B7
    .byte $05, $B5, $A8, $A4, $4E, $4B, $A8, $BB, $30, $B7, $B6, $C4, $C4, $00
; Dialogue 137 ($9D00): "Sarda doesnotfear the\nevilsof thecave."
    .byte $9C, $A4, $B5, $A7, $A4, $67, $B2, $A8, $1E, $B1, $B2, $21, $A9, $2B, $B5, $1B
    .byte $1D, $05, $A8, $B9, $61, $1E, $4C, $1B, $AB, $1A, $51, $32, $C0, $00
; Dialogue 138 ($9D1E): "Well, well..\nYouhavebecomefine\nWarriors."
    .byte $A0, $A8, $4E, $BF, $33, $A8, $4E, $69, $05, $A2, $B2, $64, $41, $B9, $1A, $62
    .byte $A6, $49, $1A, $A9, $1F, $A8, $05, $A0, $A4, $B5, $5C, $35, $B6, $C0, $00
; Dialogue 139 ($9D3D): "IamJim.Myhomeis the\nDwarfVillage, butI am\nherein"
    .byte $92, $FF, $A4, $B0, $FF, $93, $AC, $B0, $C0, $FF, $96, $4B, $AB, $49, $1A, $30
    .byte $1B, $1D, $05, $8D, $BA, $2F, $54, $9F, $AC, $4E, $A4, $66, $BF, $31, $B8, $21
    .byte $92, $20, $B0, $05, $AB, $A8, $B5, $1A, $1F, $B9, $2C, $57, $AA, $39, $1F, $AA
    .byte $C0, $00
; Dialogue 140 ($9D6F): "We, theTwelveSages,\nwereleadhereby the\nstarsandp"
    .byte $A0, $A8, $BF, $1B, $AB, $1A, $9D, $60, $AF, $B9, $1A, $9C, $A4, $AA, $2C, $BF
    .byte $05, $BA, $A8, $B5, $1A, $AF, $2B, $27, $1D, $B5, $1A, $A5, $BC, $1B, $1D, $05
    .byte $B6, $B7, $2F, $1E, $22, $27, $B3, $4D, $B3, $1D, $A6, $BC, $C0, $00
; Dialogue 141 ($9D9D): "OncetheORBS shined\nwith thepower ofEarth,\nWind,F"
    .byte $98, $B1, $A6, $1A, $1C, $1A, $98, $9B, $8B, $9C, $24, $AB, $1F, $40, $05, $BA
    .byte $AC, $1C, $1B, $AB, $1A, $B3, $46, $25, $36, $54, $8E, $2F, $1C, $BF, $05, $A0
    .byte $AC, $3B, $BF, $FF, $8F, $AC, $23, $BF, $20, $B1, $27, $A0, $39, $25, $C0, $05
    .byte $9D, $AB, $1A, $A9, $26, $44, $8F, $92, $8E, $97, $8D, $9C, $24, $A8, $AC, $BD
    .byte $40, $05, $B7, $AB, $B2, $B6, $1A, $99, $46, $25, $B6, $C0, $00
; Dialogue 142 ($9DEA): "Earth,Wind,Fire, and\nWater..\nTheworldisboundby\n"
    .byte $8E, $A4, $B5, $1C, $BF, $FF, $A0, $1F, $A7, $BF, $FF, $8F, $AC, $23, $BF, $20
    .byte $3B, $05, $A0, $A4, $B7, $25, $69, $05, $9D, $AB, $1A, $BA, $35, $AF, $27, $AC
    .byte $1E, $A5, $26, $B1, $27, $A5, $BC, $05, $B7, $AB, $2C, $1A, $A9, $26, $44, $99
    .byte $46, $25, $B6, $C0, $00
; Dialogue 143 ($9E1F): "Eachelement'spower\nfocusesatitsAltar.\nLocate, an"
    .byte $8E, $A4, $A6, $AB, $FF, $A8, $45, $34, $B1, $B7, $BE, $1E, $B3, $46, $25, $05
    .byte $A9, $B2, $A6, $B8, $3E, $1E, $A4, $21, $5B, $1E, $8A, $AF, $B7, $2F, $C0, $05
    .byte $95, $B2, $A6, $39, $A8, $BF, $20, $B1, $27, $A6, $B5, $B8, $B6, $AB, $1B, $1D
    .byte $05, $8F, $AC, $3A, $A7, $C0, $FF, $9D, $1D, $B1, $1B, $2E, $B0, $A4, $AE, $A8
    .byte $05, $AC, $B7, $24, $AB, $1F, $A8, $BF, $4F, $AF, $5E, $1A, $1C, $1A, $98, $9B
    .byte $8B, $05, $B2, $B1, $1B, $AB, $1A, $8A, $AF, $B7, $2F, $2D, $21, $AA, $B8, $2F
    .byte $A7, $40, $C4, $00
; Dialogue 144 ($9E83): "FourFIENDS arebenton\ntheworld'sdestruction.\n200 "
    .byte $8F, $B2, $B8, $44, $8F, $92, $8E, $97, $8D, $9C, $20, $B5, $1A, $A5, $3A, $21
    .byte $3C, $05, $B7, $AB, $1A, $BA, $35, $AF, $A7, $BE, $1E, $A7, $2C, $B7, $B5, $B8
    .byte $A6, $57, $3C, $C0, $05, $82, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $BF
    .byte $1B, $AB, $1A, $8F, $92, $8E, $97, $8D, $05, $B2, $A9, $FF, $A0, $1F, $A7, $1B
    .byte $2B, $34, $27, $BA, $AC, $1C, $1B, $AB, $39, $05, $B2, $A9, $1B, $AB, $1A, $A0
    .byte $39, $25, $1B, $2E, $A7, $2C, $B7, $4D, $BC, $05, $A6, $AC, $B9, $61, $AC, $BD
    .byte $39, $AC, $3C, $C0, $00
; Dialogue 145 ($9EE8): "TheEarthFIEND causes\ntherotofourland."
    .byte $9D, $AB, $1A, $8E, $2F, $1C, $FF, $8F, $92, $8E, $97, $8D, $38, $A4, $B8, $B6
    .byte $2C, $05, $B7, $AB, $1A, $4D, $21, $4C, $FF, $26, $44, $AF, $22, $A7, $C0, $00
; Dialogue 146 ($9F08): "TheFireFIEND will\nburneverythingup!"
    .byte $9D, $AB, $1A, $8F, $AC, $B5, $1A, $8F, $92, $8E, $97, $8D, $33, $AC, $4E, $05
    .byte $A5, $B8, $B5, $29, $A8, $B9, $25, $BC, $1C, $1F, $47, $B8, $B3, $C4, $00
; Dialogue 147 ($9F27): "As yourestorelight to\ntheORBS, wewillreveal\nmore"
    .byte $8A, $B6, $50, $26, $FF, $23, $B6, $28, $B5, $1A, $68, $AA, $AB, $B7, $1B, $B2
    .byte $05, $B7, $AB, $1A, $98, $9B, $8B, $9C, $BF, $33, $1A, $BA, $AC, $4E, $FF, $23
    .byte $B9, $2B, $AF, $05, $B0, $B2, $B5, $1A, $3E, $A6, $23, $B7, $B6, $BF, $4F, $AF
    .byte $2B, $B6, $1A, $3E, $A8, $05, $B8, $B6, $FF, $23, $B3, $2B, $B7, $40, $AF, $BC
    .byte $C0, $00
; Dialogue 148 ($9F69): "LIGHTWARRIORS,\nonlyyou can makethe\nORBS shineaga"
    .byte $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $BF, $05
    .byte $B2, $B1, $AF, $4B, $BC, $26, $38, $22, $42, $A4, $AE, $1A, $1C, $A8, $05, $98
    .byte $9B, $8B, $9C, $24, $AB, $1F, $1A, $A4, $AA, $A4, $1F, $C4, $C4, $00
; Dialogue 149 ($9F97): "Quickly, beforeall is\nburnt, hurry toGurgu\nVolca"
    .byte $9A, $B8, $AC, $A6, $AE, $AF, $BC, $BF, $31, $A8, $A9, $35, $1A, $A4, $4E, $2D
    .byte $B6, $05, $A5, $B8, $B5, $B1, $B7, $BF, $59, $B8, $B5, $B5, $BC, $1B, $2E, $90
    .byte $B8, $B5, $AA, $B8, $05, $9F, $B2, $AF, $A6, $22, $B2, $20, $3B, $24, $28, $B3
    .byte $1B, $1D, $05, $8F, $92, $8E, $97, $8D, $36, $54, $8F, $AC, $23, $C0, $00
; Dialogue 150 ($9FD6): "TheTempleofFIENDS is\nin thecenter of the\nFourAlt"
    .byte $9D, $AB, $1A, $9D, $A8, $B0, $B3, $AF, $1A, $4C, $FF, $8F, $92, $8E, $97, $8D
    .byte $9C, $2D, $B6, $05, $AC, $B1, $1B, $AB, $1A, $A6, $3A, $B7, $25, $36, $A9, $1B
    .byte $1D, $05, $8F, $B2, $B8, $44, $8A, $AF, $B7, $2F, $B6, $C0, $FF, $9D, $AB, $1A
    .byte $57, $34, $05, $AB, $A4, $1E, $A6, $49, $1A, $28, $67, $2C, $B7, $4D, $BC, $1B
    .byte $1D, $05, $B6, $B2, $55, $A6, $1A, $4C, $FF, $A8, $B9, $61, $C0, $00
; Dialogue 151 ($A024): "With thefourORBS\nshining again theTime\nGatecan b"
    .byte $A0, $AC, $1C, $1B, $AB, $1A, $A9, $26, $44, $98, $9B, $8B, $9C, $05, $B6, $AB
    .byte $1F, $AC, $2A, $20, $AA, $A4, $AC, $B1, $1B, $AB, $1A, $9D, $AC, $34, $05, $90
    .byte $A4, $B7, $1A, $A6, $22, $31, $1A, $A5, $4D, $AE, $3A, $C0, $FF, $9D, $1D, $05
    .byte $B7, $B5, $B8, $1A, $3A, $A8, $B0, $BC, $2D, $1E, $82, $80, $80, $80, $50, $2B
    .byte $63, $05, $AC, $B1, $1B, $AB, $1A, $B3, $A4, $37, $C0, $00
; Dialogue 152 ($A070): "Theworldwassuddenly\nthrowninto disorder.\nYou mus"
    .byte $9D, $AB, $1A, $BA, $35, $AF, $27, $5D, $1E, $B6, $B8, $A7, $A7, $3A, $AF, $BC
    .byte $05, $B7, $AB, $B5, $46, $29, $1F, $28, $67, $30, $35, $A7, $25, $C0, $05, $A2
    .byte $B2, $B8, $42, $B8, $B6, $21, $23, $B6, $28, $B5, $1A, $5B, $C0, $00
; Dialogue 153 ($A09E): "Timeisrepeating.\nInorder tobreak the\nTime-Loop y"
    .byte $9D, $AC, $B0, $1A, $AC, $1E, $23, $B3, $2B, $B7, $1F, $AA, $C0, $05, $92, $B1
    .byte $FF, $35, $A7, $25, $1B, $2E, $A5, $23, $A4, $AE, $1B, $1D, $05, $9D, $AC, $34
    .byte $C2, $95, $B2, $B2, $B3, $50, $26, $42, $B8, $37, $05, $A8, $AF, $AC, $B0, $1F
    .byte $39, $1A, $1C, $1A, $3A, $A8, $B0, $BC, $33, $AB, $B2, $05, $A6, $B2, $B1, $B7
    .byte $4D, $AF, $1E, $A9, $B5, $49, $FF, $82, $80, $80, $80, $50, $2B, $63, $05, $AC
    .byte $B1, $1B, $AB, $1A, $B3, $A4, $37, $C0, $00
; Dialogue 154 ($A0F7): "Someonetravelled2000\nyears tothepast.The\nfourFIE"
    .byte $9C, $B2, $34, $3C, $1A, $B7, $B5, $A4, $32, $AF, $45, $27, $82, $80, $80, $80
    .byte $05, $BC, $A8, $2F, $B6, $1B, $2E, $1C, $1A, $B3, $A4, $37, $C0, $FF, $9D, $1D
    .byte $05, $A9, $B2, $B8, $44, $8F, $92, $8E, $97, $8D, $9C, $33, $25, $1A, $B6, $3A
    .byte $B7, $05, $A9, $B2, $B5, $BA, $2F, $27, $1F, $1B, $AC, $34, $C0, $FF, $9D, $AB
    .byte $B2, $3E, $05, $8F, $92, $8E, $97, $8D, $9C, $1B, $AB, $23, $39, $3A, $1B, $B2
    .byte $05, $A7, $A8, $37, $4D, $BC, $1B, $AB, $1A, $BA, $35, $AF, $A7, $1B, $B2, $A7
    .byte $A4, $BC, $C0, $00
; Dialogue 155 ($A15B): "Iseenow.\nSomeonewho travelled\nback2000 yearsis t"
    .byte $92, $FF, $3E, $1A, $B1, $46, $C0, $05, $9C, $B2, $34, $3C, $1A, $BA, $AB, $B2
    .byte $1B, $B5, $A4, $32, $4E, $40, $05, $A5, $A4, $A6, $AE, $FF, $82, $80, $80, $80
    .byte $50, $2B, $B5, $1E, $30, $1B, $1D, $05, $A6, $A4, $B8, $B6, $1A, $4C, $1B, $AB
    .byte $1A, $BA, $35, $AF, $A7, $BE, $B6, $05, $A7, $A8, $37, $B5, $B8, $A6, $57, $3C
    .byte $C0, $FF, $8A, $A9, $B7, $25, $FF, $82, $80, $80, $80, $05, $BC, $A8, $2F, $1E
    .byte $AB, $1A, $BA, $AC, $4E, $1B, $B5, $A4, $32, $AF, $05, $A5, $A4, $A6, $AE, $20
    .byte $AA, $A4, $1F, $69, $05, $9D, $AB, $3A, $20, $AA, $A4, $1F, $69, $9D, $AB, $3A
    .byte $20, $AA, $A4, $1F, $69, $00
; Dialogue 156 ($A1D1): "Timewillrepeatitself\nevery2000 years.\nBreak theT"
    .byte $9D, $AC, $B0, $1A, $BA, $AC, $4E, $FF, $23, $B3, $2B, $21, $5B, $3E, $AF, $A9
    .byte $05, $A8, $B9, $25, $4B, $82, $80, $80, $80, $50, $2B, $63, $C0, $05, $8B, $B5
    .byte $2B, $AE, $1B, $AB, $1A, $9D, $AC, $34, $C2, $95, $B2, $B2, $B3, $C4, $00
; Dialogue 157 ($A200): "In theTempleofFIENDS\naretheremainingSKY\nWARRIORS"
    .byte $92, $B1, $1B, $AB, $1A, $9D, $A8, $B0, $B3, $AF, $1A, $4C, $FF, $8F, $92, $8E
    .byte $97, $8D, $9C, $05, $A4, $B5, $1A, $1C, $1A, $23, $B0, $A4, $1F, $AC, $2A, $FF
    .byte $9C, $94, $A2, $05, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $FF, $9D, $1D
    .byte $BC, $43, $26, $AA, $AB, $B7, $05, $B7, $AB, $1A, $8F, $92, $8E, $97, $8D, $9C
    .byte $20, $3B, $20, $B5, $1A, $B1, $46, $05, $A5, $A4, $B7, $B6, $C4, $00
; Dialogue 158 ($A24E): "We mustuse force only\nforjustpurposes."
    .byte $A0, $A8, $42, $B8, $B6, $21, $B8, $3E, $43, $35, $48, $36, $B1, $AF, $BC, $05
    .byte $A9, $B2, $44, $AD, $B8, $B6, $21, $B3, $55, $B3, $B2, $B6, $2C, $C0, $00
; Dialogue 159 ($A26D): "For tenyearsI probed\nfor theFLOATER.CANOE\nnorth,"
    .byte $8F, $B2, $B5, $1B, $A8, $29, $BC, $2B, $B5, $1E, $92, $4F, $4D, $A5, $40, $05
    .byte $A9, $B2, $B5, $1B, $AB, $1A, $8F, $95, $98, $8A, $9D, $8E, $9B, $C0, $FF, $8C
    .byte $8A, $97, $98, $8E, $05, $B1, $B2, $B5, $1C, $BF, $1B, $2E, $1C, $1A, $92, $A6
    .byte $1A, $8C, $A4, $32, $C0, $00
; Dialogue 160 ($A2A3): "IamLukahn.\nNow alllegendsand\nprophecy will be\nf"
    .byte $92, $FF, $A4, $B0, $FF, $95, $B8, $AE, $A4, $AB, $B1, $C0, $05, $97, $B2, $BA
    .byte $20, $4E, $FF, $45, $AA, $3A, $A7, $1E, $22, $A7, $05, $B3, $B5, $B2, $B3, $1D
    .byte $A6, $BC, $33, $AC, $4E, $31, $A8, $05, $A9, $B8, $AF, $A9, $AC, $4E, $40, $C0
    .byte $FF, $98, $B8, $44, $B3, $A4, $1C, $59, $3F, $05, $A5, $A8, $A8, $29, $A7, $A8
    .byte $A6, $AC, $A7, $40, $C0, $00
; Dialogue 161 ($A2E9): "LIGHTWARRIORS, you can\ndo it!"
    .byte $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $BF, $50
    .byte $26, $38, $22, $05, $A7, $B2, $2D, $B7, $C4, $00
; Dialogue 162 ($A303): "My brotherDr.Unnehas\nstudiedLefeinish, the\nlangu"
    .byte $96, $BC, $31, $4D, $1C, $25, $FF, $8D, $B5, $C0, $FF, $9E, $B1, $B1, $1A, $AB
    .byte $3F, $05, $B6, $B7, $B8, $A7, $AC, $A8, $27, $95, $A8, $A9, $A8, $1F, $30, $AB
    .byte $BF, $1B, $1D, $05, $AF, $A4, $2A, $B8, $A4, $AA, $1A, $4C, $1B, $AB, $1A, $9C
    .byte $94, $A2, $05, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $FF, $92, $54, $AB
    .byte $1A, $41, $A7, $1B, $1D, $05, $9C, $95, $8A, $8B, $BF, $59, $1A, $A6, $26, $AF
    .byte $A7, $1B, $2B, $A6, $AB, $2D, $B7, $C0, $00
; Dialogue 163 ($A35C): "Soar tomy brotherUnne\nwith theSLAB!"
    .byte $9C, $B2, $2F, $1B, $2E, $B0, $BC, $31, $4D, $1C, $25, $FF, $9E, $B1, $5A, $05
    .byte $BA, $AC, $1C, $1B, $AB, $1A, $9C, $95, $8A, $8B, $C4, $00
; Dialogue 164 ($A378): "Haveyou foundOXYALE?"
    .byte $91, $A4, $B9, $1A, $BC, $26, $43, $26, $B1, $27, $98, $A1, $A2, $8A, $95, $8E
    .byte $C5, $00
; Dialogue 165 ($A38A): "Youhavelegs!"
    .byte $A2, $B2, $64, $41, $B9, $1A, $45, $AA, $B6, $C4, $00
; Dialogue 166 ($A395): "Mylegsarebeautiful!\nIt'ssonicetohave\nlegs."
    .byte $96, $BC, $FF, $45, $AA, $1E, $2F, $1A, $A5, $2B, $B8, $57, $A9, $B8, $AF, $C4
    .byte $05, $92, $B7, $BE, $1E, $B6, $2E, $B1, $AC, $A6, $1A, $28, $FF, $41, $32, $05
    .byte $AF, $A8, $AA, $B6, $C0, $00
; Dialogue 167 ($A3BB): "Underhill, theCaravan\nMaster,had something\nvery "
    .byte $9E, $B1, $A7, $25, $3D, $4E, $BF, $1B, $AB, $1A, $8C, $2F, $A4, $B9, $22, $05
    .byte $96, $A4, $37, $25, $BF, $FF, $41, $A7, $24, $B2, $34, $1C, $1F, $AA, $05, $B9
    .byte $A8, $B5, $BC, $24, $B7, $B5, $22, $66, $69, $00
; Dialogue 168 ($A3E5): "Until200 yearsago the\nMermaidslivedin the\nShrine"
    .byte $9E, $B1, $57, $58, $82, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $1B, $1D
    .byte $05, $96, $A8, $B5, $B0, $A4, $AC, $A7, $1E, $68, $32, $27, $1F, $1B, $1D, $05
    .byte $9C, $AB, $B5, $1F, $A8, $C0, $FF, $9D, $1D, $B1, $BF, $FF, $1F, $43, $AC, $23
    .byte $05, $A4, $B1, $A7, $24, $B0, $B2, $AE, $A8, $BF, $2D, $21, $B6, $A4, $B1, $AE
    .byte $C0, $FF, $9D, $1D, $05, $96, $A8, $B5, $B0, $A4, $AC, $A7, $B6, $C5, $69, $00
; Dialogue 169 ($A435): "Until200 yearsago, the\nPower ofWater brought\nusg"
    .byte $9E, $B1, $57, $58, $82, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $BF, $1B
    .byte $1D, $05, $99, $B2, $BA, $25, $36, $54, $A0, $39, $25, $31, $B5, $26, $AA, $AB
    .byte $B7, $05, $B8, $B6, $FF, $AA, $B2, $B2, $27, $A9, $35, $B7, $B8, $5A, $C0, $00
; Dialogue 170 ($A465): "Thepower ofWater!!\nNow,our country will\nprosper "
    .byte $9D, $AB, $1A, $B3, $46, $25, $36, $54, $A0, $39, $25, $C4, $C4, $05, $97, $B2
    .byte $BA, $BF, $FF, $26, $B5, $38, $26, $B1, $B7, $B5, $BC, $33, $AC, $4E, $05, $B3
    .byte $B5, $B2, $B6, $B3, $25, $65, $AC, $AE, $1A, $62, $A9, $B2, $23, $C0, $00
; Dialogue 171 ($A494): "IsawBAHAMUT, but, to\nbe honored asa true\nwarrior"
    .byte $92, $FF, $B6, $A4, $BA, $FF, $8B, $8A, $91, $8A, $96, $9E, $9D, $BF, $31, $B8
    .byte $B7, $BF, $1B, $B2, $05, $A5, $A8, $59, $3C, $B2, $23, $A7, $20, $1E, $A4, $1B
    .byte $B5, $B8, $A8, $05, $BA, $A4, $B5, $5C, $35, $FF, $92, $42, $B8, $B6, $21, $23
    .byte $B7, $55, $B1, $05, $BA, $AC, $1C, $4F, $4D, $4C, $36, $A9, $42, $BC, $05, $A6
    .byte $B2, $55, $A4, $66, $C0, $00
; Dialogue 172 ($A4DA): "Well, well..\nIseeyouhavebeen\nhonored."
    .byte $A0, $A8, $4E, $BF, $33, $A8, $4E, $69, $05, $92, $FF, $3E, $1A, $BC, $26, $FF
    .byte $41, $B9, $1A, $62, $3A, $05, $AB, $B2, $B1, $B2, $23, $A7, $C0, $00
; Dialogue 173 ($A4F8): "Avastyelandlubbers!\nStayoutof meway."
    .byte $8A, $B9, $3F, $21, $BC, $1A, $AF, $22, $A7, $AF, $B8, $A5, $A5, $25, $B6, $C4
    .byte $05, $9C, $B7, $A4, $4B, $26, $21, $4C, $42, $1A, $5D, $BC, $C0, $00
; Dialogue 174 ($A516): "My fatherruns the\ncaravan.Heishaving a\ncloseouts"
    .byte $96, $BC, $43, $A4, $1C, $25, $FF, $B5, $B8, $B1, $B6, $1B, $1D, $05, $A6, $A4
    .byte $B5, $A4, $B9, $22, $C0, $FF, $91, $1A, $AC, $1E, $41, $B9, $1F, $AA, $20, $05
    .byte $A6, $AF, $B2, $B6, $1A, $26, $21, $B6, $5F, $1A, $B1, $2B, $B5, $1B, $1D, $05
    .byte $B2, $A4, $B6, $AC, $1E, $1F, $1B, $AB, $1A, $BA, $2C, $B7, $25, $B1, $05, $A7
    .byte $A8, $B6, $25, $B7, $C0, $00
; Dialogue 175 ($A55C): "Kope'says' hesaw a\nshining objectfall."
    .byte $94, $B2, $B3, $1A, $BE, $B6, $A4, $BC, $B6, $BE, $59, $1A, $B6, $A4, $BA, $20
    .byte $05, $B6, $AB, $1F, $AC, $2A, $36, $A5, $AD, $A8, $A6, $21, $A9, $A4, $4E, $C0
    .byte $00
; Dialogue 176 ($A57D): "Fablessay thatwhen\ntheshrinesank, many\ntreasures"
    .byte $8F, $A4, $A5, $45, $1E, $B6, $A4, $BC, $1B, $41, $21, $BA, $1D, $B1, $05, $B7
    .byte $AB, $1A, $B6, $AB, $B5, $1F, $1A, $B6, $22, $AE, $BF, $42, $22, $BC, $05, $B7
    .byte $B5, $2B, $B6, $55, $A8, $1E, $BA, $25, $1A, $AF, $B2, $37, $C0, $05, $8A, $AF
    .byte $B6, $B2, $BF, $1B, $1D, $BC, $1B, $A8, $4E, $36, $A9, $20, $05, $A6, $B5, $BC
    .byte $B3, $57, $A6, $24, $28, $B1, $1A, $B3, $AF, $39, $A8, $C0, $00
; Dialogue 177 ($A5CA): "MynameisKope.\nIsaw itnorth,near the\nwaterfall.Be"
    .byte $96, $BC, $FF, $B1, $A4, $B0, $1A, $AC, $1E, $94, $B2, $B3, $A8, $C0, $05, $92
    .byte $FF, $B6, $A4, $BA, $2D, $21, $B1, $35, $1C, $BF, $FF, $B1, $2B, $B5, $1B, $1D
    .byte $05, $BA, $A4, $B7, $25, $A9, $A4, $4E, $C0, $FF, $8B, $A8, $68, $A8, $B9, $1A
    .byte $34, $C4, $FF, $92, $05, $B7, $AB, $1F, $AE, $2D, $21, $5D, $1E, $A4, $FF, $4D
    .byte $A5, $B2, $B7, $C0, $00
; Dialogue 178 ($A60F): "This townused tobe\nprosperous200 years\nago."
    .byte $9D, $AB, $30, $1B, $46, $29, $B8, $3E, $A7, $1B, $2E, $62, $05, $B3, $B5, $B2
    .byte $B6, $B3, $25, $26, $1E, $82, $80, $80, $50, $2B, $63, $05, $A4, $AA, $B2, $C0
    .byte $00
; Dialogue 179 ($A630): "No!\nThatisjust an\nunusablesample."
    .byte $97, $B2, $C4, $05, $9D, $AB, $A4, $21, $AC, $1E, $AD, $B8, $37, $20, $B1, $05
    .byte $B8, $B1, $B8, $B6, $A4, $A5, $AF, $1A, $B6, $A4, $B0, $B3, $45, $C0, $00
; Dialogue 180 ($A64F): "If wecannotregain the\nPower ofWater, wewill\nbeco"
    .byte $92, $A9, $33, $1A, $A6, $22, $B1, $B2, $21, $23, $AA, $A4, $1F, $1B, $1D, $05
    .byte $99, $B2, $BA, $25, $36, $54, $A0, $39, $25, $BF, $33, $1A, $BA, $AC, $4E, $05
    .byte $A5, $A8, $A6, $49, $1A, $A5, $B8, $A5, $A5, $AF, $2C, $BF, $1B, $1D, $B1, $05
    .byte $A7, $AC, $B6, $A4, $B3, $B3, $2B, $B5, $C0, $00
; Dialogue 181 ($A689): "Arewegoing tobecome\nbubbles?"
    .byte $8A, $B5, $1A, $60, $FF, $AA, $B2, $1F, $AA, $1B, $2E, $62, $A6, $B2, $34, $05
    .byte $A5, $B8, $A5, $A5, $AF, $2C, $C5, $00
; Dialogue 182 ($A6A1): "As long as theFIEND of\nWater lives, we..\nOh, boo"
    .byte $8A, $B6, $65, $B2, $2A, $20, $B6, $1B, $AB, $1A, $8F, $92, $8E, $97, $8D, $36
    .byte $A9, $05, $A0, $A4, $B7, $25, $65, $AC, $B9, $2C, $BF, $33, $A8, $69, $05, $98
    .byte $AB, $BF, $31, $B2, $2E, $AB, $B2, $B2, $C0, $00
; Dialogue 183 ($A6CB): "Youhaveresponded\ntome!!"
    .byte $A2, $B2, $64, $41, $B9, $1A, $23, $B6, $B3, $B2, $3B, $40, $05, $B7, $B2, $FF
    .byte $34, $C4, $C4, $00
; Dialogue 184 ($A6DF): "Thisis theShrine's top\nfloor.TheFIEND of\nWater,K"
    .byte $9D, $AB, $AC, $1E, $30, $1B, $AB, $1A, $9C, $AB, $B5, $1F, $A8, $BE, $B6, $1B
    .byte $B2, $B3, $05, $A9, $AF, $B2, $35, $C0, $FF, $9D, $AB, $1A, $8F, $92, $8E, $97
    .byte $8D, $36, $A9, $05, $A0, $A4, $B7, $25, $BF, $FF, $94, $9B, $8A, $94, $8E, $97
    .byte $65, $AC, $32, $1E, $3C, $05, $B7, $AB, $1A, $A5, $B2, $B7, $28, $B0, $43, $AF
    .byte $B2, $35, $C0, $00
; Dialogue 185 ($A723): "Isupposeyou arethe\nlegendary.."
    .byte $92, $FF, $B6, $B8, $B3, $B3, $B2, $B6, $1A, $BC, $26, $20, $B5, $1A, $1C, $A8
    .byte $05, $AF, $A8, $AA, $3A, $A7, $2F, $BC, $69, $00
; Dialogue 186 ($A73D): "Pleasesavethesea,\nandmaketheORB shine\nagain!"
    .byte $99, $AF, $2B, $B6, $1A, $B6, $A4, $B9, $1A, $1C, $1A, $B6, $2B, $BF, $05, $A4
    .byte $B1, $27, $B0, $A4, $AE, $1A, $1C, $1A, $98, $9B, $8B, $24, $AB, $1F, $A8, $05
    .byte $A4, $AA, $A4, $1F, $C4, $00
; Dialogue 187 ($A763): "Now,orderhasreturned.\nThesea will beasit\nwasbefo"
    .byte $97, $B2, $BA, $BF, $FF, $35, $A7, $25, $FF, $41, $1E, $23, $B7, $55, $B1, $40
    .byte $C0, $05, $9D, $AB, $1A, $B6, $2B, $33, $AC, $4E, $31, $1A, $A4, $1E, $5B, $05
    .byte $BA, $A4, $1E, $62, $A9, $B2, $23, $BF, $31, $2B, $B8, $57, $A9, $B8, $AF, $C0
    .byte $00
; Dialogue 188 ($A794): "My friendDarryl went to\ntheland, thennever\nretur"
    .byte $96, $BC, $43, $5C, $3A, $27, $8D, $2F, $B5, $BC, $AF, $33, $3A, $B7, $1B, $B2
    .byte $05, $B7, $AB, $1A, $AF, $22, $A7, $BF, $1B, $1D, $29, $5A, $B9, $25, $05, $B5
    .byte $A8, $B7, $55, $B1, $40, $C0, $FF, $92, $BE, $B9, $1A, $4C, $B7, $3A, $05, $BA
    .byte $B2, $3B, $A8, $23, $27, $BA, $41, $21, $AB, $A4, $B3, $B3, $3A, $40, $69, $05
    .byte $96, $A4, $BC, $62, $BF, $24, $AB, $1A, $AA, $23, $BA, $FF, $45, $AA, $1E, $22
    .byte $A7, $05, $BA, $A4, $AF, $AE, $40, $20, $BA, $A4, $BC, $C5, $00
; Dialogue 189 ($A7F1): "Unbelievable!!\nYou can breathe\nunderwater?!\nI'm"
    .byte $9E, $B1, $62, $68, $A8, $B9, $A4, $A5, $45, $C4, $C4, $05, $A2, $B2, $B8, $38
    .byte $22, $31, $23, $A4, $1C, $A8, $05, $B8, $B1, $A7, $25, $BA, $39, $25, $C5, $C4
    .byte $05, $92, $BE, $B0, $2D, $B0, $B3, $23, $B6, $3E, $A7, $C4, $00
; Dialogue 190 ($A81E): "Tounlock theMirage\nTower theLefeinish\nused a mus"
    .byte $9D, $B2, $FF, $B8, $B1, $AF, $B2, $A6, $AE, $1B, $AB, $1A, $96, $AC, $B5, $A4
    .byte $66, $05, $9D, $B2, $BA, $25, $1B, $AB, $1A, $95, $A8, $A9, $A8, $1F, $30, $AB
    .byte $05, $B8, $B6, $40, $20, $42, $B8, $B6, $AC, $51, $AF, $1B, $3C, $A8, $C0, $00
; Dialogue 191 ($A84E): "Thisdoor islockedby\nthemysticKEY."
    .byte $9D, $AB, $AC, $1E, $A7, $B2, $35, $2D, $1E, $AF, $B2, $A6, $AE, $A8, $27, $A5
    .byte $BC, $05, $B7, $AB, $1A, $B0, $BC, $37, $AC, $A6, $FF, $94, $8E, $A2, $C0, $00
; Dialogue 192 ($A86E): "This townisGaia.."
    .byte $9D, $AB, $30, $1B, $46, $29, $AC, $1E, $90, $A4, $AC, $A4, $69, $00
; Dialogue 193 ($A87C): "Haveyou been tothe\ncity south ofhere?I\njustcanno"
    .byte $91, $A4, $B9, $1A, $BC, $26, $31, $A8, $3A, $1B, $2E, $1C, $A8, $05, $A6, $AC
    .byte $B7, $BC, $24, $26, $1C, $36, $54, $1D, $23, $C5, $FF, $92, $05, $AD, $B8, $B6
    .byte $21, $A6, $22, $B1, $B2, $21, $B8, $3B, $25, $37, $22, $A7, $05, $A4, $FF, $BA
    .byte $35, $A7, $24, $B3, $B2, $AE, $3A, $1B, $1D, $23, $C0, $05, $92, $FF, $41, $B9
    .byte $1A, $BA, $B2, $3B, $A8, $23, $27, $BA, $AB, $39, $05, $AF, $A4, $2A, $B8, $A4
    .byte $66, $69, $00
; Dialogue 194 ($A8CF): "Legend says theSKY\nWARRIORS flew about,\nhereand "
    .byte $95, $A8, $AA, $3A, $A7, $24, $A4, $BC, $B6, $1B, $AB, $1A, $9C, $94, $A2, $05
    .byte $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $43, $45, $BA, $20, $A5, $26, $B7, $BF
    .byte $05, $AB, $A8, $B5, $1A, $22, $A7, $1B, $AB, $A8, $23, $BF, $43, $B5, $49, $20
    .byte $05, $A6, $A4, $37, $AF, $1A, $3D, $AA, $AB, $FF, $1F, $1B, $AB, $1A, $B6, $AE
    .byte $BC, $C0, $00
; Dialogue 195 ($A912): "Isaw ashining object\nflying towards theeast."
    .byte $92, $FF, $B6, $A4, $BA, $20, $FF, $B6, $AB, $1F, $AC, $2A, $36, $A5, $AD, $A8
    .byte $A6, $B7, $05, $A9, $AF, $BC, $1F, $AA, $1B, $46, $2F, $A7, $B6, $1B, $AB, $1A
    .byte $2B, $37, $C0, $00
; Dialogue 196 ($A936): "Unbelievable!\nYou areoutsiders,\nright?\nHow didy"
    .byte $9E, $B1, $62, $68, $A8, $B9, $A4, $A5, $45, $C4, $05, $A2, $B2, $B8, $20, $B5
    .byte $1A, $B2, $B8, $B7, $B6, $AC, $A7, $25, $B6, $BF, $05, $B5, $AC, $AA, $AB, $B7
    .byte $C5, $05, $91, $B2, $BA, $67, $AC, $27, $BC, $26, $FF, $66, $B7, $1B, $3D, $1E
    .byte $A9, $2F, $05, $B1, $B2, $B5, $1C, $C5, $00
; Dialogue 197 ($A96F): "Letmesee..Yes, there\nwasa professor that\nstudied"
    .byte $95, $A8, $21, $B0, $1A, $3E, $A8, $69, $FF, $A2, $2C, $BF, $1B, $1D, $23, $05
    .byte $BA, $A4, $1E, $A4, $4F, $B5, $4C, $2C, $B6, $35, $1B, $AB, $39, $05, $B6, $B7
    .byte $B8, $A7, $AC, $A8, $27, $95, $A8, $A9, $A8, $1F, $30, $AB, $C0, $00
; Dialogue 198 ($A99D): "Only a fairy can draw\nOXYALE from thespring."
    .byte $98, $B1, $AF, $BC, $20, $43, $A4, $AC, $B5, $BC, $38, $22, $67, $B5, $A4, $BA
    .byte $05, $98, $A1, $A2, $8A, $95, $8E, $43, $B5, $49, $1B, $AB, $1A, $B6, $B3, $B5
    .byte $1F, $AA, $C0, $00
; Dialogue 199 ($A9C1): "Everyonethinks the\ntowerinYahnikurm\nDesertisa mi"
    .byte $8E, $B9, $25, $BC, $3C, $1A, $1C, $1F, $AE, $B6, $1B, $1D, $05, $B7, $B2, $BA
    .byte $25, $FF, $1F, $FF, $A2, $A4, $AB, $B1, $AC, $AE, $55, $B0, $05, $8D, $A8, $B6
    .byte $25, $21, $AC, $1E, $A4, $42, $AC, $B5, $A4, $66, $C0, $05, $92, $FF, $BA, $B2
    .byte $3B, $25, $69, $00
; Dialogue 200 ($A9F5): "Hardyhar, you aretoo\nlate!IBOTTLED the\nfairy and"
    .byte $91, $A4, $B5, $A7, $4B, $41, $B5, $BF, $50, $26, $20, $B5, $1A, $28, $B2, $05
    .byte $AF, $A4, $53, $C4, $FF, $92, $FF, $8B, $98, $9D, $9D, $95, $8E, $8D, $1B, $1D
    .byte $05, $A9, $A4, $AC, $B5, $BC, $20, $3B, $24, $B2, $AF, $27, $1D, $B5, $1B, $B2
    .byte $20, $05, $A6, $A4, $B5, $A4, $B9, $22, $C0, $00
; Dialogue 201 ($AA2F): "Legendssay that the\ncastlein thewestisa\nplaceto "
    .byte $95, $A8, $AA, $3A, $A7, $1E, $B6, $A4, $BC, $1B, $AB, $39, $1B, $1D, $05, $A6
    .byte $A4, $37, $AF, $1A, $1F, $1B, $AB, $1A, $BA, $2C, $21, $AC, $1E, $A4, $05, $B3
    .byte $AF, $5E, $1A, $28, $1B, $2C, $21, $A6, $26, $B5, $A4, $66, $C0, $00
; Dialogue 202 ($AA5D): "?rewoP taergevahuoy oD"
    .byte $C5, $B5, $A8, $BA, $B2, $99, $1B, $A4, $25, $47, $A8, $B9, $A4, $AB, $FF, $B8
    .byte $B2, $BC, $36, $8D, $00
; Dialogue 203 ($AA72): "What's thatbroomup to?\nIt's talking backwards!"
    .byte $A0, $AB, $39, $BE, $B6, $1B, $41, $21, $A5, $4D, $49, $FF, $B8, $B3, $1B, $B2
    .byte $C5, $05, $92, $B7, $BE, $B6, $1B, $5F, $AE, $1F, $AA, $31, $5E, $AE, $BA, $2F
    .byte $A7, $B6, $C4, $00
; Dialogue 204 ($AA96): "Thefairy at thespring\nwaskidnapped."
    .byte $9D, $AB, $1A, $A9, $A4, $AC, $B5, $BC, $20, $B7, $1B, $AB, $1A, $B6, $B3, $B5
    .byte $1F, $AA, $05, $BA, $A4, $1E, $AE, $AC, $A7, $B1, $A4, $B3, $B3, $40, $C0, $00
; Dialogue 205 ($AAB6): "With thisCHIME you can\nenter theMirageTower."
    .byte $A0, $AC, $1C, $1B, $3D, $1E, $8C, $91, $92, $96, $8E, $50, $26, $38, $22, $05
    .byte $A8, $B1, $B7, $25, $1B, $AB, $1A, $96, $AC, $B5, $A4, $AA, $1A, $9D, $46, $25
    .byte $C0, $00
; Dialogue 206 ($AAD8): "TheMirageTower was the\ngateway toourhomein\nthesk"
    .byte $9D, $AB, $1A, $96, $AC, $B5, $A4, $AA, $1A, $9D, $46, $25, $33, $3F, $1B, $1D
    .byte $05, $AA, $A4, $53, $5D, $BC, $1B, $2E, $26, $44, $AB, $49, $1A, $1F, $05, $B7
    .byte $AB, $1A, $B6, $AE, $BC, $C0, $00
; Dialogue 207 ($AAFF): "400 yearsago, wehad an\nadvancedcivilization.\nOur"
    .byte $84, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $B2, $BF, $33, $1A, $41, $A7, $20
    .byte $B1, $05, $A4, $A7, $B9, $22, $48, $27, $A6, $AC, $B9, $61, $AC, $BD, $39, $AC
    .byte $3C, $C0, $05, $98, $B8, $44, $1F, $53, $23, $B6, $21, $BA, $3F, $1B, $1D, $05
    .byte $B8, $B1, $AC, $B9, $25, $3E, $C4, $C4, $00
; Dialogue 208 ($AB38): "Lu..pa..?\nLu..pa..?"
    .byte $95, $B8, $69, $B3, $A4, $69, $C5, $05, $95, $B8, $69, $B3, $A4, $69, $C5, $00
; Dialogue 209 ($AB48): "We are theLefeinish.\nOnlyour bravestbecame\nSKYWA"
    .byte $A0, $A8, $20, $23, $1B, $1D, $FF, $95, $A8, $A9, $A8, $1F, $30, $AB, $C0, $05
    .byte $98, $B1, $AF, $4B, $26, $B5, $31, $B5, $A4, $B9, $2C, $21, $62, $51, $34, $05
    .byte $9C, $94, $A2, $FF, $A0, $8A, $9B, $9B, $92, $98, $9B, $9C, $C0, $FF, $A2, $26
    .byte $B5, $05, $8A, $92, $9B, $9C, $91, $92, $99, $33, $3F, $1B, $1D, $AC, $63, $C0
    .byte $00
; Dialogue 210 ($AB89): "TheFLOATINGCASTLE..\nOur ancestorslived\nthere.The"
    .byte $9D, $AB, $1A, $8F, $95, $98, $8A, $9D, $92, $97, $90, $FF, $8C, $8A, $9C, $9D
    .byte $95, $8E, $69, $05, $98, $B8, $B5, $20, $B1, $A6, $2C, $28, $B5, $1E, $68, $32
    .byte $A7, $05, $B7, $AB, $A8, $23, $C0, $FF, $9D, $AB, $1A, $96, $AC, $B5, $A4, $AA
    .byte $1A, $9D, $46, $25, $05, $AC, $B6, $1B, $AB, $1A, $3A, $B7, $B5, $22, $48, $C0
    .byte $00
; Dialogue 211 ($ABCA): "At thetimeof\ndestruction alegendwas\nborn..In400 "
    .byte $8A, $B7, $1B, $AB, $1A, $57, $B0, $1A, $4C, $05, $A7, $A8, $37, $B5, $B8, $A6
    .byte $57, $3C, $20, $FF, $45, $AA, $3A, $27, $BA, $3F, $05, $A5, $B2, $B5, $B1, $69
    .byte $FF, $FF, $92, $29, $84, $80, $80, $50, $2B, $63, $BF, $05, $A0, $8A, $9B, $9B
    .byte $92, $98, $9B, $9C, $33, $AC, $1C, $FF, $98, $9B, $8B, $9C, $33, $AC, $4E, $05
    .byte $A4, $B3, $B3, $2B, $B5, $1B, $B2, $24, $A4, $B9, $1A, $26, $B5, $05, $B3, $A8
    .byte $B2, $B3, $45, $FF, $C0, $05, $8A, $B5, $1A, $BC, $26, $C5, $69, $00
; Dialogue 212 ($AC28): "We foughtwithTIAMAT,\nbutwereunsuccessful.\nTheFIE"
    .byte $A0, $A8, $43, $26, $AA, $AB, $21, $BA, $AC, $1C, $FF, $9D, $92, $8A, $52, $9D
    .byte $BF, $05, $A5, $B8, $21, $BA, $25, $1A, $B8, $B1, $B6, $B8, $A6, $A6, $2C, $B6
    .byte $A9, $B8, $AF, $C0, $05, $9D, $AB, $1A, $8F, $92, $8E, $97, $8D, $FF, $B1, $46
    .byte $FF, $1F, $41, $A5, $5B, $B6, $05, $B2, $B8, $44, $8F, $95, $98, $8A, $9D, $92
    .byte $97, $90, $FF, $8C, $8A, $9C, $9D, $95, $8E, $C0, $00
; Dialogue 213 ($AC73): "OurlastfiveWarriors\nleft tofind thecause\nof thew"
    .byte $98, $B8, $44, $AF, $3F, $21, $A9, $AC, $B9, $1A, $A0, $2F, $5C, $35, $B6, $05
    .byte $AF, $A8, $A9, $B7, $1B, $2E, $A9, $1F, $A7, $1B, $AB, $1A, $51, $B8, $3E, $05
    .byte $B2, $A9, $1B, $AB, $1A, $BA, $35, $AF, $A7, $BE, $1E, $A7, $A8, $51, $BC, $C0
    .byte $05, $A0, $A8, $FF, $94, $B1, $46, $1B, $1D, $4B, $68, $32, $BF, $31, $B8, $B7
    .byte $BF, $05, $A4, $B6, $31, $39, $B6, $C0, $00
; Dialogue 214 ($ACBC): "Weknew that agreat\npower controlled the\nFIENDS.O"
    .byte $A0, $A8, $FF, $AE, $5A, $BA, $1B, $AB, $39, $20, $FF, $AA, $23, $39, $05, $B3
    .byte $B2, $BA, $25, $38, $3C, $B7, $4D, $4E, $40, $1B, $1D, $05, $8F, $92, $8E, $97
    .byte $8D, $9C, $C0, $FF, $98, $55, $43, $AC, $B9, $1A, $A5, $B5, $A4, $B9, $2C, $B7
    .byte $05, $A0, $A4, $B5, $5C, $35, $1E, $45, $A9, $B7, $BF, $FF, $5A, $B9, $25, $1B
    .byte $B2, $05, $B5, $A8, $B7, $55, $B1, $C0, $00
; Dialogue 215 ($AD05): "Wehave passedon the\nlegendsfromgeneration\ntogene"
    .byte $A0, $A8, $FF, $41, $32, $4F, $3F, $3E, $27, $3C, $1B, $1D, $05, $AF, $A8, $AA
    .byte $3A, $A7, $1E, $A9, $B5, $49, $FF, $AA, $3A, $25, $39, $AC, $3C, $05, $B7, $B2
    .byte $FF, $AA, $3A, $25, $39, $AC, $3C, $C0, $FF, $8B, $B8, $21, $84, $80, $80, $05
    .byte $BC, $A8, $2F, $1E, $41, $B9, $1A, $51, $B8, $3E, $27, $26, $B5, $05, $B0, $A8
    .byte $B0, $35, $AC, $2C, $1B, $2E, $A9, $A4, $A7, $A8, $C0, $00
; Dialogue 216 ($AD51): "Oh, theLIGHTWARRIORS!!\nThelegendis true!"
    .byte $98, $AB, $BF, $1B, $AB, $1A, $95, $92, $90, $91, $9D, $FF, $A0, $8A, $9B, $9B
    .byte $92, $98, $9B, $9C, $C4, $C4, $05, $9D, $AB, $1A, $45, $AA, $3A, $27, $30, $1B
    .byte $B5, $B8, $A8, $C4, $00
; Dialogue 217 ($AD76): "Until400 yearsagowe\ncontrolled thePower of\ntheWi"
    .byte $9E, $B1, $57, $58, $84, $80, $80, $50, $2B, $B5, $1E, $A4, $AA, $2E, $60, $05
    .byte $A6, $B2, $B1, $B7, $4D, $4E, $40, $1B, $AB, $1A, $99, $46, $25, $36, $A9, $05
    .byte $B7, $AB, $1A, $A0, $1F, $A7, $C0, $FF, $9D, $3D, $1E, $3A, $A4, $A5, $AF, $40
    .byte $05, $B8, $B6, $1B, $B2, $24, $B8, $B6, $B3, $3A, $A7, $1B, $AB, $1A, $51, $37
    .byte $45, $05, $AC, $B1, $1B, $AB, $1A, $A4, $AC, $B5, $C0, $00
; Dialogue 218 ($ADC2): "Thepower ofWindwas\ntakenbyTIAMAT."
    .byte $9D, $AB, $1A, $B3, $46, $25, $36, $54, $A0, $1F, $27, $BA, $3F, $05, $B7, $A4
    .byte $AE, $A8, $29, $A5, $4B, $9D, $92, $8A, $52, $9D, $C0, $00
; Dialogue 219 ($ADDE): "HereliesErdrick\n837-866\nR.I.P."
    .byte $91, $A8, $B5, $1A, $68, $A8, $1E, $8E, $B5, $A7, $5C, $A6, $AE, $05, $FF, $FF
    .byte $FF, $FF, $88, $83, $87, $FF, $C2, $FF, $88, $86, $86, $05, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $9B, $C0, $92, $C0, $99, $C0, $00
; Dialogue 220 ($AE07): "Iwonder if therobots\nmadebyour ancestors\narestil"
    .byte $92, $FF, $BA, $B2, $3B, $25, $2D, $A9, $1B, $AB, $1A, $4D, $A5, $B2, $B7, $B6
    .byte $05, $B0, $A4, $A7, $1A, $A5, $4B, $26, $B5, $20, $B1, $A6, $2C, $28, $63, $05
    .byte $A4, $B5, $1A, $37, $AC, $4E, $42, $B2, $B9, $1F, $AA, $C5, $00
; Dialogue 221 ($AE34): "TheFLOATINGCASTLE\nfloatshighin the\nsky, seemingl"
    .byte $9D, $AB, $1A, $8F, $95, $98, $8A, $9D, $92, $97, $90, $FF, $8C, $8A, $9C, $9D
    .byte $95, $8E, $05, $A9, $AF, $B2, $39, $1E, $3D, $AA, $AB, $FF, $1F, $1B, $1D, $05
    .byte $B6, $AE, $BC, $BF, $24, $A8, $A8, $B0, $1F, $AA, $AF, $BC, $20, $B0, $B2, $2A
    .byte $05, $B7, $AB, $1A, $37, $2F, $B6, $C0, $00
; Dialogue 222 ($AE6D): "Oneofusescapedwith\naCUBE.Hefloatedfar\nto thewest"
    .byte $98, $B1, $1A, $4C, $FF, $B8, $1E, $2C, $51, $B3, $A8, $27, $BA, $AC, $1C, $05
    .byte $A4, $FF, $8C, $9E, $8B, $8E, $C0, $FF, $91, $1A, $A9, $AF, $B2, $39, $A8, $27
    .byte $A9, $2F, $05, $B7, $B2, $1B, $AB, $1A, $BA, $2C, $B7, $C0, $00
; Dialogue 223 ($AE9A): "Transporter operation\nrequiresaCUBE."
    .byte $9D, $B5, $22, $B6, $B3, $35, $B7, $25, $36, $B3, $25, $39, $AC, $3C, $05, $B5
    .byte $A8, $B4, $B8, $AC, $B5, $A8, $1E, $A4, $FF, $8C, $9E, $8B, $8E, $C0, $00
; Dialogue 224 ($AEB9): "Areyou themaster?"
    .byte $8A, $B5, $1A, $BC, $26, $1B, $AB, $1A, $B0, $A4, $37, $25, $C5, $00
; Dialogue 225 ($AEC7): "You can look outover\ntheworldfrom this\nwindow."
    .byte $A2, $B2, $B8, $38, $22, $65, $B2, $B2, $AE, $36, $B8, $21, $B2, $B9, $25, $05
    .byte $B7, $AB, $1A, $BA, $35, $AF, $27, $A9, $B5, $49, $1B, $AB, $30, $05, $BA, $AC
    .byte $3B, $46, $C0, $00
; Dialogue 226 ($AEEB): "If you arebraveenough,\ntrymeeting theKing of\nthe"
    .byte $92, $A9, $50, $26, $20, $B5, $1A, $A5, $B5, $A4, $B9, $1A, $3A, $26, $AA, $AB
    .byte $BF, $05, $B7, $B5, $4B, $34, $A8, $B7, $1F, $AA, $1B, $AB, $1A, $94, $1F, $AA
    .byte $36, $A9, $05, $B7, $AB, $1A, $8D, $B5, $A4, $AA, $3C, $B6, $BF, $FF, $8B, $8A
    .byte $91, $8A, $96, $9E, $9D, $C0, $00
; Dialogue 227 ($AF22): "Unprofitablebusiness\nisnot a practiceof the\nDrag"
    .byte $9E, $B1, $B3, $B5, $4C, $5B, $A4, $A5, $AF, $1A, $A5, $B8, $B6, $1F, $2C, $B6
    .byte $05, $AC, $B6, $FF, $B1, $B2, $B7, $20, $4F, $B5, $5E, $57, $A6, $1A, $4C, $1B
    .byte $1D, $05, $8D, $B5, $A4, $AA, $3C, $1E, $4C, $FF, $8C, $2F, $A7, $AC, $A4, $C0
    .byte $00
; Dialogue 228 ($AF53): "Long ago,Dragonsand\nhumanslived and traded\ntoget"
    .byte $95, $B2, $2A, $20, $AA, $B2, $BF, $FF, $8D, $B5, $A4, $AA, $3C, $1E, $22, $A7
    .byte $05, $AB, $B8, $B0, $22, $1E, $68, $32, $A7, $20, $3B, $1B, $B5, $A4, $A7, $40
    .byte $05, $B7, $B2, $66, $1C, $25, $C0, $00
; Dialogue 229 ($AF7B): "You arenot afraidof\nme??\nThen,I am impressed!"
    .byte $A2, $B2, $B8, $20, $B5, $1A, $B1, $B2, $B7, $20, $A9, $B5, $A4, $AC, $27, $4C
    .byte $05, $B0, $A8, $C5, $C5, $05, $9D, $AB, $3A, $BF, $FF, $92, $20, $B0, $2D, $B0
    .byte $B3, $23, $B6, $3E, $A7, $C4, $00
; Dialogue 230 ($AFA2): "Seeyour faceupon the\nclean water.How dirty!\nCome"
    .byte $9C, $A8, $1A, $BC, $26, $B5, $43, $5E, $1A, $B8, $B3, $3C, $1B, $1D, $05, $A6
    .byte $AF, $A8, $22, $33, $39, $25, $C0, $FF, $91, $46, $67, $AC, $B5, $B7, $BC, $C4
    .byte $05, $8C, $B2, $34, $C4, $FF, $A0, $3F, $AB, $50, $26, $B5, $43, $A4, $48, $C4
    .byte $00
; Dialogue 231 ($AFD3): "We aregoing tothe\nCastleofOrdeal tothe\nnortheast"
    .byte $A0, $A8, $20, $23, $FF, $AA, $B2, $1F, $AA, $1B, $2E, $1C, $A8, $05, $8C, $A4
    .byte $37, $AF, $1A, $4C, $FF, $98, $B5, $A7, $2B, $AF, $1B, $2E, $1C, $A8, $05, $B1
    .byte $B2, $B5, $1C, $2B, $37, $C0, $FF, $9D, $1D, $B5, $1A, $60, $33, $AC, $4E, $05
    .byte $B7, $A8, $37, $BF, $20, $B1, $27, $A5, $B5, $1F, $AA, $31, $5E, $AE, $05, $B3
    .byte $B5, $B2, $4C, $36, $54, $26, $B5, $38, $26, $B5, $A4, $66, $C0, $00
; Dialogue 232 ($B021): "Theproof of your\ncouragemightbe\nanything."
    .byte $9D, $AB, $1A, $B3, $4D, $4C, $36, $A9, $50, $26, $B5, $05, $A6, $B2, $55, $A4
    .byte $AA, $1A, $B0, $AC, $AA, $AB, $21, $62, $05, $A4, $B1, $BC, $1C, $1F, $AA, $C0
    .byte $00
; Dialogue 233 ($B042): "HaveyoumetBAHAMUT,\ntheDragonKing?He\nhonors those"
    .byte $91, $A4, $B9, $1A, $BC, $26, $FF, $34, $21, $8B, $8A, $91, $8A, $96, $9E, $9D
    .byte $BF, $05, $B7, $AB, $1A, $8D, $B5, $A4, $AA, $B2, $29, $94, $1F, $AA, $C5, $FF
    .byte $91, $A8, $05, $AB, $B2, $B1, $35, $B6, $1B, $AB, $B2, $B6, $1A, $BA, $AC, $1C
    .byte $05, $A6, $B2, $55, $A4, $AA, $1A, $3F, $1B, $B5, $B8, $A8, $05, $BA, $A4, $B5
    .byte $5C, $35, $B6, $C0, $00
; Dialogue 234 ($B087): "Only thecourageousones\nbring back theproof of\nth"
    .byte $98, $B1, $AF, $BC, $1B, $AB, $1A, $A6, $26, $B5, $A4, $66, $26, $1E, $3C, $2C
    .byte $05, $A5, $B5, $1F, $AA, $31, $5E, $AE, $1B, $AB, $1A, $B3, $4D, $4C, $36, $A9
    .byte $05, $B7, $AB, $A8, $AC, $B5, $38, $26, $B5, $A4, $66, $C0, $00
; Dialogue 235 ($B0B4): "Oncein thenorth, there\nwerebeautiful palaces\nand"
    .byte $98, $B1, $A6, $1A, $1F, $1B, $AB, $1A, $B1, $35, $1C, $BF, $1B, $1D, $23, $05
    .byte $BA, $A8, $B5, $1A, $A5, $2B, $B8, $57, $A9, $B8, $AF, $4F, $5F, $5E, $2C, $05
    .byte $A4, $B1, $27, $A5, $AC, $47, $34, $A6, $41, $B1, $AC, $51, $AF, $05, $A6, $A4
    .byte $37, $AF, $2C, $C0, $00
; Dialogue 236 ($B0E9): "ThisisBAHAMUT'sroom."
    .byte $9D, $AB, $AC, $1E, $30, $FF, $8B, $8A, $91, $8A, $96, $9E, $9D, $BE, $B6, $FF
    .byte $4D, $49, $C0, $00
; Dialogue 237 ($B0FD): "BAHAMUTverifies the\ntruecourageof all."
    .byte $8B, $8A, $91, $8A, $96, $9E, $9D, $FF, $B9, $25, $AC, $A9, $AC, $2C, $1B, $1D
    .byte $05, $B7, $B5, $B8, $1A, $A6, $26, $B5, $A4, $AA, $1A, $4C, $20, $4E, $C0, $00
; Dialogue 238 ($B11D): "Thisis a tomb."
    .byte $9D, $AB, $AC, $1E, $30, $20, $1B, $49, $A5, $C0, $00
; Dialogue 239 ($B128): "Thisis a well.You\nmight think that there\nis some"
    .byte $9D, $AB, $AC, $1E, $30, $20, $33, $A8, $4E, $C0, $FF, $A2, $26, $05, $B0, $AC
    .byte $AA, $AB, $B7, $1B, $AB, $1F, $AE, $1B, $AB, $39, $1B, $1D, $23, $05, $AC, $B6
    .byte $24, $B2, $34, $1C, $1F, $AA, $1B, $B2, $2D, $B7, $69, $05, $8B, $B8, $21, $1F
    .byte $43, $5E, $21, $5B, $2D, $1E, $AD, $B8, $37, $05, $A4, $B1, $FF, $35, $A7, $1F
    .byte $2F, $BC, $33, $A8, $4E, $C0, $00
; Dialogue 240 ($B16F): "In thetreasurebox,\nyou found..[01][02]"
    .byte $92, $B1, $1B, $AB, $1A, $B7, $23, $3F, $55, $1A, $A5, $B2, $BB, $BF, $05, $BC
    .byte $B2, $B8, $43, $B2, $B8, $3B, $69, $01, $02, $00
; Dialogue 241 ($B189): "Can'thold anymore."
    .byte $8C, $A4, $B1, $BE, $21, $AB, $B2, $AF, $A7, $20, $B1, $BC, $B0, $B2, $23, $C0
    .byte $00
; Dialogue 242 ($B19A): "Thetreasurebox is\nempty!"
    .byte $9D, $AB, $1A, $B7, $23, $3F, $55, $1A, $A5, $B2, $BB, $2D, $B6, $05, $A8, $B0
    .byte $B3, $B7, $BC, $C4, $00
; Dialogue 243 ($B1AF): "TheAltar of theEarth."
    .byte $9D, $AB, $1A, $8A, $AF, $B7, $2F, $36, $A9, $1B, $AB, $1A, $8E, $2F, $1C, $C0
    .byte $00
; Dialogue 244 ($B1C0): "TheAltar of theFire."
    .byte $9D, $AB, $1A, $8A, $AF, $B7, $2F, $36, $A9, $1B, $AB, $1A, $8F, $AC, $23, $C0
    .byte $00
; Dialogue 245 ($B1D1): "TheAltar of theWater."
    .byte $9D, $AB, $1A, $8A, $AF, $B7, $2F, $36, $A9, $1B, $AB, $1A, $A0, $39, $25, $C0
    .byte $00
; Dialogue 246 ($B1E2): "TheAltar of theWind."
    .byte $9D, $AB, $1A, $8A, $AF, $B7, $2F, $36, $A9, $1B, $AB, $1A, $A0, $1F, $A7, $C0
    .byte $00
; Dialogue 247 ($B1F3): "At thebottom of the\nspring, something is\nflowing"
    .byte $8A, $B7, $1B, $AB, $1A, $A5, $B2, $B7, $28, $B0, $36, $A9, $1B, $1D, $05, $B6
    .byte $B3, $B5, $1F, $AA, $BF, $24, $B2, $34, $1C, $1F, $AA, $2D, $B6, $05, $A9, $AF
    .byte $46, $1F, $AA, $C0, $00
; Dialogue 248 ($B218): "TIAMAT is theFIEND of\ntheWIND.."
    .byte $9D, $92, $8A, $52, $9D, $2D, $B6, $1B, $AB, $1A, $8F, $92, $8E, $97, $8D, $36
    .byte $A9, $05, $B7, $AB, $1A, $A0, $92, $97, $8D, $69, $00
; Dialogue 249 ($B233): "From thiswindow onecan\nseetheentireworld.\nTheFou"
    .byte $8F, $B5, $49, $1B, $3D, $1E, $BA, $1F, $A7, $46, $36, $B1, $1A, $A6, $22, $05
    .byte $B6, $A8, $1A, $1C, $1A, $3A, $57, $B5, $1A, $BA, $35, $AF, $A7, $C0, $05, $9D
    .byte $AB, $1A, $8F, $26, $44, $8F, $35, $48, $1E, $A4, $23, $05, $A9, $AF, $46, $1F
    .byte $AA, $1B, $B2, $66, $1C, $25, $BF, $FF, $1F, $28, $05, $B7, $AB, $1A, $A6, $3A
    .byte $B7, $25, $36, $A9, $1B, $AB, $1A, $8F, $26, $B5, $05, $8A, $AF, $B7, $2F, $B6
    .byte $C0, $FF, $92, $B1, $28, $1B, $AB, $1A, $9D, $A8, $B0, $B3, $45, $05, $B2, $A9
    .byte $FF, $8F, $92, $8E, $97, $8D, $9C, $C0, $00
; Dialogue 250 ($B29C): "TheFIEND'sball cracks\nopen..Anominouscloud\nrises"
    .byte $9D, $AB, $1A, $8F, $92, $8E, $97, $8D, $BE, $1E, $A5, $A4, $4E, $38, $B5, $5E
    .byte $AE, $B6, $05, $B2, $B3, $3A, $69, $FF, $8A, $29, $49, $1F, $26, $1E, $A6, $AF
    .byte $26, $A7, $05, $B5, $AC, $B6, $2C, $BF, $20, $3B, $20, $29, $A8, $B9, $61, $24
    .byte $41, $B3, $A8, $05, $A6, $B2, $2A, $2B, $AF, $B6, $69, $05, $92, $B7, $2D, $1E
    .byte $95, $92, $8C, $91, $BF, $1B, $AB, $1A, $8F, $92, $8E, $97, $8D, $36, $A9, $05
    .byte $8E, $A4, $B5, $1C, $C0, $00
; Dialogue 251 ($B2F2): "Is ityou, thetinder\nthatdefeated theFIEND\nof the"
    .byte $92, $B6, $2D, $21, $BC, $26, $BF, $1B, $AB, $1A, $B7, $1F, $A7, $25, $05, $B7
    .byte $AB, $A4, $21, $A7, $A8, $A9, $2B, $B7, $40, $1B, $AB, $1A, $8F, $92, $8E, $97
    .byte $8D, $05, $B2, $A9, $1B, $AB, $1A, $8E, $2F, $1C, $BF, $20, $3B, $05, $A7, $AC
    .byte $37, $55, $62, $27, $B0, $BC, $24, $45, $A8, $B3, $C5, $05, $92, $BF, $FF, $94
    .byte $8A, $9B, $A2, $33, $AC, $4E, $FF, $B1, $46, $24, $AB, $46, $05, $BC, $B2, $B8
    .byte $1B, $AB, $1A, $A9, $35, $A6, $1A, $4C, $FF, $8F, $AC, $23, $BF, $05, $A4, $B1
    .byte $27, $BC, $26, $24, $41, $4E, $31, $55, $29, $1F, $05, $AC, $B7, $1E, $A9, $AF
    .byte $A4, $B0, $2C, $C4, $C4, $00
; Dialogue 252 ($B368): "TheFIEND'sball is\nshattered,evaporating\nall thew"
    .byte $9D, $AB, $1A, $8F, $92, $8E, $97, $8D, $BE, $1E, $A5, $A4, $4E, $2D, $B6, $05
    .byte $B6, $AB, $39, $53, $23, $A7, $BF, $FF, $A8, $B9, $A4, $B3, $35, $39, $1F, $AA
    .byte $05, $A4, $AF, $AF, $1B, $AB, $1A, $BA, $39, $25, $C0, $05, $91, $B2, $BF, $FF
    .byte $91, $B2, $BF, $FF, $91, $B2, $69, $05, $91, $B2, $BA, $43, $B2, $B2, $AF, $AB
    .byte $2F, $A7, $BC, $1B, $2E, $A7, $A4, $23, $05, $A6, $AB, $5F, $45, $2A, $1A, $34
    .byte $BF, $FF, $94, $9B, $8A, $94, $8E, $97, $1B, $1D, $05, $8F, $92, $8E, $97, $8D
    .byte $36, $A9, $1B, $AB, $1A, $A0, $39, $25, $C0, $00
; Dialogue 253 ($B3D2): "Lightningeruptsfrom\ntheFIEND'sball..\nSo, youhave"
    .byte $95, $AC, $AA, $AB, $B7, $B1, $1F, $47, $25, $B8, $B3, $B7, $1E, $A9, $B5, $49
    .byte $05, $B7, $AB, $1A, $8F, $92, $8E, $97, $8D, $BE, $1E, $A5, $A4, $4E, $69, $05
    .byte $9C, $B2, $BF, $50, $26, $FF, $41, $B9, $1A, $A6, $49, $1A, $1C, $30, $05, $A9
    .byte $A4, $B5, $69, $05, $92, $BF, $FF, $9D, $92, $8A, $52, $9D, $1B, $AB, $1A, $8F
    .byte $92, $8E, $97, $8D, $36, $A9, $05, $B7, $AB, $1A, $A0, $1F, $27, $BA, $AC, $4E
    .byte $FF, $B1, $46, $4F, $B8, $B7, $20, $B1, $05, $A8, $B1, $A7, $1B, $2E, $BC, $26
    .byte $B5, $20, $A7, $32, $B1, $B7, $B8, $23, $C4, $C4, $00
; Dialogue 254 ($B43D): "What??\nYou can speakLefeinish?"
    .byte $A0, $AB, $39, $C5, $C5, $05, $A2, $B2, $B8, $38, $22, $24, $B3, $2B, $AE, $FF
    .byte $95, $A8, $A9, $A8, $1F, $30, $AB, $C5, $00
; Dialogue 255 ($B456): "Thereisa stoneplate\non thefloor..\nYou sensesomet"
    .byte $9D, $AB, $25, $1A, $AC, $1E, $A4, $24, $28, $B1, $1A, $B3, $AF, $39, $A8, $05
    .byte $B2, $B1, $1B, $AB, $1A, $A9, $AF, $B2, $35, $69, $05, $A2, $B2, $B8, $24, $3A
    .byte $B6, $1A, $B6, $B2, $34, $1C, $1F, $AA, $69, $05, $8E, $B9, $61, $C5, $69, $00

; --- $B600: Enemy Attack Names & Data (256 bytes) ---
lut_EnemyAttack:
    .byte $34, $B6, $3A, $B6, $3F, $B6, $46, $B6, $4B, $B6, $51, $B6, $58, $B6, $5E, $B6
    .byte $65, $B6, $6B, $B6, $71, $B6, $7A, $B6, $80, $B6, $88, $B6, $90, $B6, $97, $B6
    .byte $9E, $B6, $A5, $B6, $AD, $B6, $B3, $B6, $BC, $B6, $C4, $B6, $C8, $B6, $D0, $B6
    .byte $D7, $B6, $DD, $B6, $8F, $9B, $98, $9C, $9D, $00, $91, $8E, $8A, $9D, $00, $90
    .byte $95, $8A, $97, $8C, $8E, $00, $90, $8A, $A3, $8E, $00, $8F, $95, $8A, $9C, $91
    .byte $00, $9C, $8C, $98, $9B, $8C, $91, $00, $8C, $9B, $8A, $8C, $94, $00, $9C, $9A
    .byte $9E, $92, $97, $9D, $00, $9C, $9D, $8A, $9B, $8E, $00, $90, $95, $8A, $9B, $8E
    .byte $00, $8B, $95, $92, $A3, $A3, $8A, $9B, $8D, $00, $8B, $95, $8A, $A3, $8E, $00
    .byte $92, $97, $8F, $8E, $9B, $97, $98, $00, $8C, $9B, $8E, $96, $8A, $9D, $8E, $00
    .byte $99, $98, $92, $9C, $98, $97, $00, $9D, $9B, $8A, $97, $8C, $8E, $00, $99, $98
    .byte $92, $9C, $98, $97, $00, $9D, $91, $9E, $97, $8D, $8E, $9B, $00, $9D, $98, $A1
    .byte $92, $8C, $00, $9C, $97, $98, $9B, $9D, $92, $97, $90, $00, $97, $9E, $8C, $95
    .byte $8E, $8A, $9B, $00, $92, $97, $94, $00, $9C, $9D, $92, $97, $90, $8E, $9B, $00
    .byte $8D, $8A, $A3, $A3, $95, $8E, $00, $9C, $A0, $92, $9B, $95, $00, $9D, $98, $9B
    .byte $97, $8A, $8D, $98, $00, $8B, $AD, $95, $A2, $8F, $59, $9D, $00, $F1, $6F, $F6
    .byte $FF, $FF, $FF, $FF, $00, $8F, $B5, $9C, $59, $91, $B4, $FF, $00, $97, $8B, $56

; --- $B700: Item Name Pointer Table (256 pointers = 512 bytes) ---
lut_ItemNamePtrTbl:
    .byte $00, $B9, $01, $B9, $09, $B9, $11, $B9, $19, $B9, $21, $B9, $29, $B9, $31, $B9
    .byte $39, $B9, $41, $B9, $49, $B9, $51, $B9, $59, $B9, $61, $B9, $69, $B9, $71, $B9
    .byte $79, $B9, $81, $B9, $89, $B9, $8B, $B9, $8D, $B9, $8F, $B9, $91, $B9, $99, $B9
    .byte $A1, $B9, $A9, $B9, $AF, $B9, $B5, $B9, $BD, $B9, $C5, $B9, $CD, $B9, $D5, $B9
    .byte $DD, $B9, $E5, $B9, $ED, $B9, $F5, $B9, $FD, $B9, $05, $BA, $0D, $BA, $15, $BA
    .byte $1D, $BA, $25, $BA, $2D, $BA, $35, $BA, $3D, $BA, $45, $BA, $4D, $BA, $55, $BA
    .byte $5D, $BA, $65, $BA, $6D, $BA, $75, $BA, $7D, $BA, $85, $BA, $8D, $BA, $95, $BA
    .byte $9D, $BA, $A5, $BA, $AD, $BA, $B5, $BA, $BD, $BA, $C5, $BA, $CD, $BA, $D5, $BA
    .byte $DD, $BA, $E5, $BA, $ED, $BA, $F5, $BA, $FD, $BA, $05, $BB, $0D, $BB, $15, $BB
    .byte $1D, $BB, $25, $BB, $2D, $BB, $35, $BB, $3D, $BB, $45, $BB, $4D, $BB, $55, $BB
    .byte $5D, $BB, $65, $BB, $6D, $BB, $75, $BB, $7D, $BB, $85, $BB, $8D, $BB, $95, $BB
    .byte $9D, $BB, $A5, $BB, $AD, $BB, $B5, $BB, $BD, $BB, $C5, $BB, $CD, $BB, $D5, $BB
    .byte $DD, $BB, $E5, $BB, $ED, $BB, $F5, $BB, $FE, $BB, $06, $BC, $0E, $BC, $16, $BC
    .byte $1E, $BC, $26, $BC, $2E, $BC, $36, $BC, $3E, $BC, $43, $BC, $48, $BC, $4D, $BC
    .byte $52, $BC, $57, $BC, $5C, $BC, $61, $BC, $67, $BC, $6D, $BC, $73, $BC, $79, $BC
    .byte $7F, $BC, $85, $BC, $8B, $BC, $91, $BC, $97, $BC, $9D, $BC, $A3, $BC, $A9, $BC
    .byte $AF, $BC, $B5, $BC, $BB, $BC, $C1, $BC, $C7, $BC, $CD, $BC, $D3, $BC, $D9, $BC
    .byte $DF, $BC, $E5, $BC, $EB, $BC, $F1, $BC, $F8, $BC, $FF, $BC, $06, $BD, $0D, $BD
    .byte $14, $BD, $1B, $BD, $22, $BD, $29, $BD, $30, $BD, $37, $BD, $3E, $BD, $45, $BD
    .byte $4C, $BD, $53, $BD, $5A, $BD, $61, $BD, $68, $BD, $6F, $BD, $76, $BD, $7D, $BD
    .byte $84, $BD, $8B, $BD, $93, $BD, $9B, $BD, $A3, $BD, $AB, $BD, $B3, $BD, $BB, $BD
    .byte $C3, $BD, $CB, $BD, $D3, $BD, $DB, $BD, $E3, $BD, $EB, $BD, $F3, $BD, $FB, $BD
    .byte $03, $BE, $08, $BE, $0D, $BE, $12, $BE, $17, $BE, $1C, $BE, $21, $BE, $26, $BE
    .byte $2B, $BE, $30, $BE, $35, $BE, $3A, $BE, $3F, $BE, $44, $BE, $49, $BE, $4E, $BE
    .byte $53, $BE, $58, $BE, $5D, $BE, $62, $BE, $67, $BE, $6C, $BE, $71, $BE, $76, $BE
    .byte $7B, $BE, $80, $BE, $85, $BE, $8A, $BE, $8F, $BE, $94, $BE, $99, $BE, $9E, $BE
    .byte $A3, $BE, $A8, $BE, $AD, $BE, $B2, $BE, $B7, $BE, $BC, $BE, $C1, $BE, $C6, $BE
    .byte $CB, $BE, $D0, $BE, $D5, $BE, $DA, $BE, $DF, $BE, $E4, $BE, $E9, $BE, $EE, $BE
    .byte $F3, $BE, $F8, $BE, $FD, $BE, $02, $BF, $07, $BF, $0C, $BF, $11, $BF, $16, $BF
    .byte $1B, $BF, $20, $BF, $25, $BF, $2A, $BF, $2F, $BF, $34, $BF, $39, $BF, $3E, $BF
    .byte $43, $BF, $4B, $BF, $53, $BF, $5B, $BF, $63, $BF, $6B, $BF, $73, $BF, $7B, $BF
    .byte $83, $BF, $8B, $BF, $93, $BF, $9B, $BF, $A3, $BF, $A7, $BF, $AB, $BF, $AF, $BF

; --- $B900: Item & Weapon Names (decoded with Standard Table) ---
data_ItemNames:
; Item  0 ($B900): 
    .byte $00
; Item  1 ($B901): LUTE
    .byte $95, $9E, $9D, $8E, $FF, $FF, $FF, $00
; Item  2 ($B909): CROWN
    .byte $8C, $9B, $98, $A0, $97, $FF, $FF, $00
; Item  3 ($B911): CRYSTAL
    .byte $8C, $9B, $A2, $9C, $9D, $8A, $95, $00
; Item  4 ($B919): HERB
    .byte $91, $8E, $9B, $8B, $FF, $FF, $FF, $00
; Item  5 ($B921): KEY
    .byte $94, $8E, $A2, $FF, $FF, $FF, $FF, $00
; Item  6 ($B929): TNT
    .byte $9D, $97, $9D, $FF, $FF, $FF, $FF, $00
; Item  7 ($B931): ADAMANT
    .byte $8A, $8D, $8A, $96, $8A, $97, $9D, $00
; Item  8 ($B939): SLAB
    .byte $9C, $95, $8A, $8B, $FF, $FF, $FF, $00
; Item  9 ($B941): RUBY
    .byte $9B, $9E, $8B, $A2, $FF, $FF, $FF, $00
; Item 10 ($B949): ROD
    .byte $9B, $98, $8D, $FF, $FF, $FF, $FF, $00
; Item 11 ($B951): FLOATER
    .byte $8F, $95, $98, $8A, $9D, $8E, $9B, $00
; Item 12 ($B959): CHIME
    .byte $8C, $91, $92, $96, $8E, $FF, $FF, $00
; Item 13 ($B961): TAIL
    .byte $9D, $8A, $92, $95, $FF, $FF, $FF, $00
; Item 14 ($B969): CUBE
    .byte $8C, $9E, $8B, $8E, $FF, $FF, $FF, $00
; Item 15 ($B971): BOTTLE
    .byte $8B, $98, $9D, $9D, $95, $8E, $FF, $00
; Item 16 ($B979): OXYALE
    .byte $98, $A1, $A2, $8A, $95, $8E, $FF, $00
; Item 17 ($B981): CANOE
    .byte $8C, $8A, $97, $98, $8E, $FF, $FF, $00
; Item 18 ($B989): 
    .byte $FF, $00
; Item 19 ($B98B): 
    .byte $FF, $00
; Item 20 ($B98D): 
    .byte $FF, $00
; Item 21 ($B98F): 
    .byte $FF, $00
; Item 22 ($B991): TENT
    .byte $9D, $8E, $97, $9D, $FF, $FF, $FF, $00
; Item 23 ($B999): CABIN
    .byte $8C, $8A, $8B, $92, $97, $FF, $FF, $00
; Item 24 ($B9A1): HOUSE
    .byte $91, $98, $9E, $9C, $8E, $FF, $FF, $00
; Item 25 ($B9A9): HEAL@P
    .byte $91, $8E, $8A, $95, $E1, $00
; Item 26 ($B9AF): PURE@P
    .byte $99, $9E, $9B, $8E, $E1, $00
; Item 27 ($B9B5): SOFT@P
    .byte $9C, $98, $8F, $9D, $E1, $FF, $FF, $00
; Item 28 ($B9BD): Wooden@N
    .byte $A0, $B2, $B2, $A7, $A8, $B1, $D9, $00
; Item 29 ($B9C5): Small@K
    .byte $9C, $B0, $A4, $AF, $AF, $FF, $D6, $00
; Item 30 ($B9CD): Wooden@F
    .byte $A0, $B2, $B2, $A7, $A8, $B1, $D8, $00
; Item 31 ($B9D5): Rapier
    .byte $9B, $A4, $B3, $AC, $A8, $B5, $FF, $00
; Item 32 ($B9DD): Iron@H
    .byte $92, $B5, $B2, $B1, $FF, $FF, $D5, $00
; Item 33 ($B9E5): Short@S
    .byte $9C, $AB, $B2, $B5, $B7, $FF, $D4, $00
; Item 34 ($B9ED): Hand@X
    .byte $91, $A4, $B1, $A7, $FF, $FF, $D7, $00
; Item 35 ($B9F5): Scimtar
    .byte $9C, $A6, $AC, $B0, $B7, $A4, $B5, $00
; Item 36 ($B9FD): Iron@N
    .byte $92, $B5, $B2, $B1, $FF, $FF, $D9, $00
; Item 37 ($BA05): Large@K
    .byte $95, $A4, $B5, $AA, $A8, $FF, $D6, $00
; Item 38 ($BA0D): Iron@F
    .byte $92, $B5, $B2, $B1, $FF, $FF, $D8, $00
; Item 39 ($BA15): Sabre
    .byte $9C, $A4, $A5, $B5, $A8, $FF, $FF, $00
; Item 40 ($BA1D): Long@S
    .byte $95, $B2, $B1, $AA, $FF, $FF, $D4, $00
; Item 41 ($BA25): Great@X
    .byte $90, $B5, $A8, $A4, $B7, $FF, $D7, $00
; Item 42 ($BA2D): Falchon
    .byte $8F, $A4, $AF, $A6, $AB, $B2, $B1, $00
; Item 43 ($BA35): Silver@K
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $D6, $00
; Item 44 ($BA3D): Silver@S
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $D4, $00
; Item 45 ($BA45): Silver@H
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $D5, $00
; Item 46 ($BA4D): Silver@X
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $D7, $00
; Item 47 ($BA55): Flame@S
    .byte $8F, $AF, $A4, $B0, $A8, $FF, $D4, $00
; Item 48 ($BA5D): Ice@S
    .byte $92, $A6, $A8, $FF, $FF, $FF, $D4, $00
; Item 49 ($BA65): Dragon@S
    .byte $8D, $B5, $A4, $AA, $B2, $B1, $D4, $00
; Item 50 ($BA6D): Giant@S
    .byte $90, $AC, $A4, $B1, $B7, $FF, $D4, $00
; Item 51 ($BA75): Sun@S
    .byte $9C, $B8, $B1, $FF, $FF, $FF, $D4, $00
; Item 52 ($BA7D): Coral@S
    .byte $8C, $B2, $B5, $A4, $AF, $FF, $D4, $00
; Item 53 ($BA85): Were@S
    .byte $A0, $A8, $B5, $A8, $FF, $FF, $D4, $00
; Item 54 ($BA8D): Rune@S
    .byte $9B, $B8, $B1, $A8, $FF, $FF, $D4, $00
; Item 55 ($BA95): Power@F
    .byte $99, $B2, $BA, $A8, $B5, $FF, $D8, $00
; Item 56 ($BA9D): Light@X
    .byte $95, $AC, $AA, $AB, $B7, $FF, $D7, $00
; Item 57 ($BAA5): Heal@F
    .byte $91, $A8, $A4, $AF, $FF, $FF, $D8, $00
; Item 58 ($BAAD): Mage@F
    .byte $96, $A4, $AA, $A8, $FF, $FF, $D8, $00
; Item 59 ($BAB5): Defense
    .byte $8D, $A8, $A9, $A8, $B1, $B6, $A8, $00
; Item 60 ($BABD): Wizard@F
    .byte $A0, $AC, $BD, $A4, $B5, $A7, $D8, $00
; Item 61 ($BAC5): Vorpal
    .byte $9F, $B2, $B5, $B3, $A4, $AF, $FF, $00
; Item 62 ($BACD): CatClaw
    .byte $8C, $A4, $B7, $8C, $AF, $A4, $BA, $00
; Item 63 ($BAD5): Thor@H
    .byte $9D, $AB, $B2, $B5, $FF, $FF, $D5, $00
; Item 64 ($BADD): Bane@S
    .byte $8B, $A4, $B1, $A8, $FF, $FF, $D4, $00
; Item 65 ($BAE5): Katana
    .byte $94, $A4, $B7, $A4, $B1, $A4, $FF, $00
; Item 66 ($BAED): Xcalber
    .byte $A1, $A6, $A4, $AF, $A5, $A8, $B5, $00
; Item 67 ($BAF5): Masmune
    .byte $96, $A4, $B6, $B0, $B8, $B1, $A8, $00
; Item 68 ($BAFD): Cloth
    .byte $8C, $AF, $B2, $B7, $AB, $FF, $FF, $00
; Item 69 ($BB05): Wooden@A
    .byte $A0, $B2, $B2, $A7, $A8, $B1, $DA, $00
; Item 70 ($BB0D): Chain@A
    .byte $8C, $AB, $A4, $AC, $B1, $FF, $DA, $00
; Item 71 ($BB15): Iron@A
    .byte $92, $B5, $B2, $B1, $FF, $FF, $DA, $00
; Item 72 ($BB1D): Steel@A
    .byte $9C, $B7, $A8, $A8, $AF, $FF, $DA, $00
; Item 73 ($BB25): Silver@A
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $DA, $00
; Item 74 ($BB2D): Flame@A
    .byte $8F, $AF, $A4, $B0, $A8, $FF, $DA, $00
; Item 75 ($BB35): Ice@A
    .byte $92, $A6, $A8, $FF, $FF, $FF, $DA, $00
; Item 76 ($BB3D): Opal@A
    .byte $98, $B3, $A4, $AF, $FF, $FF, $DA, $00
; Item 77 ($BB45): Dragon@A
    .byte $8D, $B5, $A4, $AA, $B2, $B1, $DA, $00
; Item 78 ($BB4D): Copper@B
    .byte $8C, $B2, $B3, $B3, $A8, $B5, $DE, $00
; Item 79 ($BB55): Silver@B
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $DE, $00
; Item 80 ($BB5D): Gold@B
    .byte $90, $B2, $AF, $A7, $FF, $FF, $DE, $00
; Item 81 ($BB65): Opal@B
    .byte $98, $B3, $A4, $AF, $FF, $FF, $DE, $00
; Item 82 ($BB6D): White@T
    .byte $A0, $AB, $AC, $B7, $A8, $FF, $DF, $00
; Item 83 ($BB75): Black@T
    .byte $8B, $AF, $A4, $A6, $AE, $FF, $DF, $00
; Item 84 ($BB7D): Wooden@s
    .byte $A0, $B2, $B2, $A7, $A8, $B1, $DB, $00
; Item 85 ($BB85): Iron@s
    .byte $92, $B5, $B2, $B1, $FF, $FF, $DB, $00
; Item 86 ($BB8D): Silver@s
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $DB, $00
; Item 87 ($BB95): Flame@s
    .byte $8F, $AF, $A4, $B0, $A8, $FF, $DB, $00
; Item 88 ($BB9D): Ice@s
    .byte $92, $A6, $A8, $FF, $FF, $FF, $DB, $00
; Item 89 ($BBA5): Opal@s
    .byte $98, $B3, $A4, $AF, $FF, $FF, $DB, $00
; Item 90 ($BBAD): Aegis@s
    .byte $8A, $A8, $AA, $AC, $B6, $FF, $DB, $00
; Item 91 ($BBB5): Buckler
    .byte $8B, $B8, $A6, $AE, $AF, $A8, $B5, $00
; Item 92 ($BBBD): ProCape
    .byte $99, $B5, $B2, $8C, $A4, $B3, $A8, $00
; Item 93 ($BBC5): Cap
    .byte $8C, $A4, $B3, $FF, $FF, $FF, $FF, $00
; Item 94 ($BBCD): Wooden@h
    .byte $A0, $B2, $B2, $A7, $A8, $B1, $DC, $00
; Item 95 ($BBD5): Iron@h
    .byte $92, $B5, $B2, $B1, $FF, $FF, $DC, $00
; Item 96 ($BBDD): Silver@h
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $DC, $00
; Item 97 ($BBE5): Opal@h
    .byte $98, $B3, $A4, $AF, $FF, $FF, $DC, $00
; Item 98 ($BBED): Heal@h
    .byte $91, $A8, $A4, $AF, $FF, $FF, $DC, $00
; Item 99 ($BBF5): Ribbon
    .byte $9B, $AC, $A5, $A5, $B2, $B1, $FF, $FF, $00
; Item 100 ($BBFE): Gloves
    .byte $90, $AF, $B2, $B9, $A8, $B6, $FF, $00
; Item 101 ($BC06): Copper@G
    .byte $8C, $B2, $B3, $B3, $A8, $B5, $DD, $00
; Item 102 ($BC0E): Iron@G
    .byte $92, $B5, $B2, $B1, $FF, $FF, $DD, $00
; Item 103 ($BC16): Silver@G
    .byte $9C, $AC, $AF, $B9, $A8, $B5, $DD, $00
; Item 104 ($BC1E): Zeus@G
    .byte $A3, $A8, $B8, $B6, $FF, $FF, $DD, $00
; Item 105 ($BC26): Power@G
    .byte $99, $B2, $BA, $A8, $B5, $FF, $DD, $00
; Item 106 ($BC2E): Opal@G
    .byte $98, $B3, $A4, $AF, $FF, $FF, $DD, $00
; Item 107 ($BC36): ProRing
    .byte $99, $B5, $B2, $9B, $AC, $B1, $AA, $00
; Item 108 ($BC3E): 10G
    .byte $81, $80, $FF, $90, $00
; Item 109 ($BC43): 20G
    .byte $82, $80, $FF, $90, $00
; Item 110 ($BC48): 25G
    .byte $82, $85, $FF, $90, $00
; Item 111 ($BC4D): 30G
    .byte $83, $80, $FF, $90, $00
; Item 112 ($BC52): 55G
    .byte $85, $85, $FF, $90, $00
; Item 113 ($BC57): 70G
    .byte $87, $80, $FF, $90, $00
; Item 114 ($BC5C): 85G
    .byte $88, $85, $FF, $90, $00
; Item 115 ($BC61): 110G
    .byte $81, $81, $80, $FF, $90, $00
; Item 116 ($BC67): 135G
    .byte $81, $83, $85, $FF, $90, $00
; Item 117 ($BC6D): 155G
    .byte $81, $85, $85, $FF, $90, $00
; Item 118 ($BC73): 160G
    .byte $81, $86, $80, $FF, $90, $00
; Item 119 ($BC79): 180G
    .byte $81, $88, $80, $FF, $90, $00
; Item 120 ($BC7F): 240G
    .byte $82, $84, $80, $FF, $90, $00
; Item 121 ($BC85): 255G
    .byte $82, $85, $85, $FF, $90, $00
; Item 122 ($BC8B): 260G
    .byte $82, $86, $80, $FF, $90, $00
; Item 123 ($BC91): 295G
    .byte $82, $89, $85, $FF, $90, $00
; Item 124 ($BC97): 300G
    .byte $83, $80, $80, $FF, $90, $00
; Item 125 ($BC9D): 315G
    .byte $83, $81, $85, $FF, $90, $00
; Item 126 ($BCA3): 330G
    .byte $83, $83, $80, $FF, $90, $00
; Item 127 ($BCA9): 350G
    .byte $83, $85, $80, $FF, $90, $00