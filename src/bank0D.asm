; ==============================================================================
; bank0D.asm - Bank $0D Music Engine & Intro Story Text ($8000 - $BFFF)
; ==============================================================================

.include "constants.inc"
.include "variables.inc"
.include "c64.inc"

.segment "BANK_0D"

.export lut_ScoreData
.export MusicPlay_L, MusicPlay
.export lut_IntroStoryText

; ==============================================================================
; $8000 - $9D9F: Music Score Bytecode Data (7,584 bytes)
; Starts with 8-byte pointer records per song (Sq1, Sq2, Tri, 2 padding bytes).
; ==============================================================================
lut_ScoreData:
    .incbin "../res/audio/scoredata.bin"

; Reserved $9DA0 - $AFFF ($1260 = 4,704 bytes)
.res $1260, $00

; ==============================================================================
; $B000: SID Music Driver
; ==============================================================================

MusicPlay_L:
    jmp MusicPlay

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Music_NewSong
;   Called when music_track is nonzero ($40+ on first frame).
;   Primes the 3 channels across 3 frames, then starts playback.
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Music_NewSong:
    cmp #$40
    bcc @PrimeChannel

    ; First frame of new track
    and #$3F
    sta music_track

    lda #0
    sta mu_chanprimer
    sta sq2_sfx

    ; Silence SID voices
    sta V1CR
    sta V2CR
    sta V3CR
    sta V1FREQ_L
    sta V1FREQ_H
    sta V2FREQ_L
    sta V2FREQ_H
    sta V3FREQ_L
    sta V3FREQ_H

    ; Set Pulse Widths: Voice 1 = 25% ($0400), Voice 2 = 12.5% ($0200)
    lda #<$0400
    sta V1PW_L
    lda #>$0400
    sta V1PW_H

    lda #<$0200
    sta V2PW_L
    lda #>$0200
    sta V2PW_H

    ; Master Volume = 15 (Max), No filters
    lda #$0F
    sta SIGVOL

    ; Triangle default ADSR: instant attack, full sustain
    lda #$00
    sta V3AD
    lda #$F0
    sta V3SR

@PrimeChannel:
    lda music_track
    sec
    sbc #1
    asl a
    asl a
    asl a
    ora mu_chanprimer
    sta tmp
    lda #>lut_ScoreData
    sta tmp+1

    ldx mu_chanprimer
    lda lut_PrimerToChan, x
    sta mu_chan
    tax

    ldy #0
    lda (tmp), y
    sta ch_scoreptr, x
    iny
    lda (tmp), y
    sta ch_scoreptr+1, x

    ; Initialize default length and frequency table pointers
    lda #<lut_NoteLengths
    sta ch_lentblptr, x
    lda #>lut_NoteLengths
    sta ch_lentblptr+1, x

    cpx #CHAN_TRI
    beq @InitTri
    lda #<lut_NoteFreqs_Pulse
    sta ch_frqtblptr, x
    lda #>lut_NoteFreqs_Pulse
    sta ch_frqtblptr+1, x
    jmp @DoScore

@InitTri:
    lda #<lut_NoteFreqs_Tri
    sta ch_frqtblptr, x
    lda #>lut_NoteFreqs_Tri
    sta ch_frqtblptr+1, x

@DoScore:
    jsr Music_ChannelScore

    lda mu_chanprimer
    clc
    adc #2
    sta mu_chanprimer

    cmp #2*3            ; 3 channels primed?
    bcc @Exit

    ; All 3 channels primed: mark track as running
    lda #0
    sta music_track
    sta ch_loopctr+CHAN_SQ1
    sta ch_loopctr+CHAN_SQ2
    sta ch_loopctr+CHAN_TRI
    sta ch_loopctr+CHAN_STOP

@Exit:
    rts

lut_PrimerToChan:
    .byte CHAN_SQ1, CHAN_SQ1
    .byte CHAN_SQ2, CHAN_SQ2
    .byte CHAN_TRI, CHAN_TRI
    .byte CHAN_STOP, CHAN_STOP


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MusicPlay
;   Called once per frame (60 Hz) to update SID voices and score counters.
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MusicPlay:
    lda music_track
    bpl @Play
    cmp #$80
    bne @Exit

    ; Song finished: silence all voices
    lda #0
    sta V1CR
    sta V2CR
    sta V3CR
    inc music_track     ; $81 = channels silenced
@Exit:
    rts

@Play:
    beq @Resume
    jmp Music_NewSong

@Resume:
    ; ----------------------------------------------------
    ; Voice 1 (Square 1 -> SID Voice 1)
    ; ----------------------------------------------------
    lda CHAN_SQ1 + ch_freq+1
    bmi @Sq1_Done               ; High bit set = frequency already written

    lda CHAN_SQ1 + ch_freq
    sta V1FREQ_L
    lda CHAN_SQ1 + ch_freq+1
    and #$7F
    sta V1FREQ_H

    ; Retrigger Gate (0 -> 1) to initiate ADSR attack
    lda #SID_PULSE
    sta V1CR
    lda #(SID_PULSE | SID_GATE)
    sta V1CR

    lda #$80
    sta CHAN_SQ1 + ch_freq+1    ; Mark frequency as written
@Sq1_Done:

    ; ----------------------------------------------------
    ; Voice 2 (Square 2 -> SID Voice 2)
    ; ----------------------------------------------------
    lda sq2_sfx
    beq @Sq2_Update
    dec sq2_sfx
    bne @Sq2_Done
    beq @Sq2_FreqChange

@Sq2_Update:
    lda CHAN_SQ2 + ch_freq+1
    bmi @Sq2_Done

@Sq2_FreqChange:
    lda CHAN_SQ2 + ch_freq
    sta V2FREQ_L
    lda CHAN_SQ2 + ch_freq+1
    and #$7F
    sta V2FREQ_H

    lda #SID_PULSE
    sta V2CR
    lda #(SID_PULSE | SID_GATE)
    sta V2CR

    lda #$80
    sta CHAN_SQ2 + ch_freq+1
@Sq2_Done:

    ; ----------------------------------------------------
    ; Voice 3 (Triangle -> SID Voice 3)
    ; ----------------------------------------------------
    lda CHAN_TRI + ch_freq+1
    bmi @Tri_HighBitSet

    lda CHAN_TRI + ch_freq
    sta V3FREQ_L
    lda CHAN_TRI + ch_freq+1
    and #$7F
    sta V3FREQ_H

    lda #SID_TRI
    sta V3CR
    lda #(SID_TRI | SID_GATE)
    sta V3CR

    lda #$80
    sta CHAN_TRI + ch_freq+1
    jmp @Tri_Done

@Tri_HighBitSet:
    cmp #$FF                    ; Rest marker for triangle
    bne @Tri_Done
    lda #SID_TRI                ; Gate = 0 silences triangle
    sta V3CR
@Tri_Done:

    ; ----------------------------------------------------
    ; Step length counters and process score data
    ; ----------------------------------------------------
    lda #CHAN_START
    sta mu_chan

@UpdateLoop:
    ldx mu_chan
    dec ch_lenctr, x
    bne @UpdateNext

    jsr Music_ChannelScore

@UpdateNext:
    lda mu_chan
    clc
    adc #CHAN_BYTES
    sta mu_chan
    cmp #CHAN_STOP
    bcc @UpdateLoop
    rts


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Music_ChannelScore & Music_DoScore
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Music_ChannelScore:
    lda ch_scoreptr, x
    sta mu_scoreptr
    lda ch_scoreptr+1, x
    sta mu_scoreptr+1
    jmp Music_DoScore

Music_DoScore_IncByA:
    clc
    adc ch_scoreptr, x
    sta ch_scoreptr, x
    sta mu_scoreptr
    lda ch_scoreptr+1, x
    adc #0
    sta ch_scoreptr+1, x
    sta mu_scoreptr+1

Music_DoScore:
    ldy #0
    lda (mu_scoreptr), y
    cmp #$C0
    bcs @Code_C0_FF

    jsr Music_Note

@Done:
    lda ch_scoreptr, x
    clc
    adc #1
    sta ch_scoreptr, x
    lda ch_scoreptr+1, x
    adc #0
    sta ch_scoreptr+1, x
    rts

@Code_C0_FF:
    cmp #$D0
    bcs @Code_D0_FF

    jsr Music_Rest
    jmp @Done

@Code_D0_FF:
    cmp #$D8
    bcs @Code_D8_FF

    jsr Music_LoopCode
    jmp Music_DoScore

@Code_D8_FF:
    cmp #$E0
    bcs @Code_E0_FF

    jsr Music_SetOctave
    lda #1
    jmp Music_DoScore_IncByA

@Code_E0_FF:
    cmp #$F0
    bcs @Code_F0_FF

    jsr Music_SetEnvPattern
    lda #1
    jmp Music_DoScore_IncByA

@Code_F0_FF:
    cmp #$FF
    bne @Code_F0_FE

    lda #$80
    sta music_track
    rts

@Code_F0_FE:
    cmp #$F8
    bne @Code_Fx

    ; $F8 = Envelope speed (followed by 1 byte)
    lda #2
    jmp Music_DoScore_IncByA

@Code_Fx:
    cmp #$F9
    bcc @Code_F0_F7

    jsr Music_SetTempo
    lda #1
    jmp Music_DoScore_IncByA

@Code_F0_F7:
    lda #1
    jmp Music_DoScore_IncByA


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Music_LoopCode ($D0 - $D7)
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Music_LoopCode:
    and #$0F
    sta tmp

    lda ch_loopctr, x
    beq @StartLoop
    dec ch_loopctr, x
    bne @ResumeLoop

    lda ch_scoreptr, x
    clc
    adc #3
    sta ch_scoreptr, x
    sta mu_scoreptr
    lda ch_scoreptr+1, x
    adc #0
    sta ch_scoreptr+1, x
    sta mu_scoreptr+1
    rts

@ResumeLoop:
    ldy #1
    lda (mu_scoreptr), y
    sta ch_scoreptr, x
    sta tmp
    iny
    lda (mu_scoreptr), y
    sta ch_scoreptr+1, x
    sta mu_scoreptr+1
    lda tmp
    sta mu_scoreptr
    rts

@StartLoop:
    lda tmp
    sta ch_loopctr, x
    jmp @ResumeLoop


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note & Rest Processing
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Music_Note:
    sta tmp+14
    jsr Music_ApplyTone
    lda tmp+14
    jmp Music_ApplyLength

Music_Rest:
    jsr Music_ApplyLength_Rest
    lda mu_chan
    cmp #CHAN_TRI
    bne @Exit
    lda #$FF
    sta CHAN_TRI + ch_freq+1
@Exit:
    rts

Music_ApplyTone:
    lsr a
    lsr a
    lsr a
    and #($F0 >> 3)
    tay

    lda ch_frqtblptr, x
    sta tmp
    lda ch_frqtblptr+1, x
    sta tmp+1

    lda (tmp), y
    sta ch_freq, x
    iny
    lda (tmp), y
    sta ch_freq+1, x
    rts

Music_ApplyLength:
    and #$0F
    tay

    lda ch_lentblptr, x
    sta tmp
    lda ch_lentblptr+1, x
    sta tmp+1

    lda (tmp), y
    sta ch_lenctr, x
    lda #0
    sta ch_envpos, x
    sta ch_envrem, x
    rts

Music_ApplyLength_Rest:
    and #$0F
    tay

    lda ch_lentblptr, x
    sta tmp
    lda ch_lentblptr+1, x
    sta tmp+1

    lda (tmp), y
    sta ch_lenctr, x
    rts


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control Code Handlers: Tempo, Octave, Envelope
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Music_SetTempo:
    sec
    sbc #$09
    and #$0F
    asl a
    asl a
    asl a
    asl a
    clc
    adc #<lut_NoteLengths
    sta ch_lentblptr, x
    lda #>lut_NoteLengths
    adc #0
    sta ch_lentblptr+1, x
    rts

Music_SetOctave:
    and #$07
    tay
    cpx #CHAN_TRI
    beq @TriOctave

    lda #<lut_NoteFreqs_Pulse
    clc
    adc lut_OctaveOffset, y
    sta ch_frqtblptr, x
    lda #>lut_NoteFreqs_Pulse
    adc #0
    sta ch_frqtblptr+1, x
    rts

@TriOctave:
    lda #<lut_NoteFreqs_Tri
    clc
    adc lut_OctaveOffset, y
    sta ch_frqtblptr, x
    lda #>lut_NoteFreqs_Tri
    adc #0
    sta ch_frqtblptr+1, x
    rts

Music_SetEnvPattern:
    and #$0F
    tay
    cpx #CHAN_SQ1
    bne :+
    lda lut_SID_AD, y
    sta V1AD
    lda lut_SID_SR, y
    sta V1SR
    rts
:   cpx #CHAN_SQ2
    bne :+
    lda lut_SID_AD, y
    sta V2AD
    lda lut_SID_SR, y
    sta V2SR
:   rts


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Frequency, Length, and ADSR Tables
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lut_OctaveOffset:
    .byte 0*12*2
    .byte 1*12*2
    .byte 2*12*2
    .byte 3*12*2
    .byte 4*12*2
    .byte 5*12*2

; NTSC SID frequencies for Voices 1 & 2 (Square 1 & 2): 4 octaves C3 to B6
lut_NoteFreqs_Pulse:
    ;       C     C#    D     D#    E     F     F#    G     G#    A     A#    B
    .word $0862,$08E2,$0969,$09F8,$0A90,$0B30,$0BDB,$0C8F,$0D4E,$0E19,$0EF0,$0FD3 ; Octave 0
    .word $10C4,$11C3,$12D1,$13F0,$151F,$1661,$17B6,$191E,$1A9D,$1C32,$1DDF,$1FA6 ; Octave 1
    .word $2188,$2386,$25A3,$27E0,$2A3F,$2CC2,$2F6B,$323D,$353A,$3864,$3BBE,$3F4C ; Octave 2
    .word $430F,$470C,$4B46,$4FBF,$547D,$5984,$5ED6,$647A,$6A73,$70C8,$777D,$7E97 ; Octave 3

; NTSC SID frequencies for Voice 3 (Triangle - 1 octave lower): 4 octaves C2 to B5
lut_NoteFreqs_Tri:
    ;       C     C#    D     D#    E     F     F#    G     G#    A     A#    B
    .word $0431,$0471,$04B4,$04FC,$0548,$0598,$05ED,$0648,$06A7,$070C,$0778,$07E9 ; Octave 0
    .word $0862,$08E2,$0969,$09F8,$0A90,$0B30,$0BDB,$0C8F,$0D4E,$0E19,$0EF0,$0FD3 ; Octave 1
    .word $10C4,$11C3,$12D1,$13F0,$151F,$1661,$17B6,$191E,$1A9D,$1C32,$1DDF,$1FA6 ; Octave 2
    .word $2188,$2386,$25A3,$27E0,$2A3F,$2CC2,$2F6B,$323D,$353A,$3864,$3BBE,$3F4C ; Octave 3

lut_NoteLengths:
    .byte $C0,$60,$30,$18,$0C,$90,$48,$24,$C0,$60,$30,$18,$0C,$90,$48,$24
    .byte $78,$3C,$1E,$0F,$07,$5A,$28,$14,$78,$3C,$1E,$0F,$07,$5A,$28,$14
    .byte $90,$60,$48,$30,$24,$18,$12,$0C,$09,$06,$03,$03,$04,$10,$08,$08
    .byte $78,$50,$3C,$28,$1E,$14,$0F,$0A,$07,$05,$03,$02,$0E,$0D,$07,$06
    .byte $6C,$48,$36,$24,$1B,$12,$0E,$09,$07,$04,$03,$03,$0E,$60,$40,$30
    .byte $60,$40,$30,$20,$18,$10,$0C,$08,$06,$04,$02,$02,$0B,$0A,$06,$05

; SID ADSR mapping for the 16 NES envelope presets ($E0 - $EF)
lut_SID_AD:
    .byte $08, $07, $06, $05   ; E0-E3: decays (instant attack, varying decay)
    .byte $45, $34, $23, $08   ; E4-E6: swells, E7: sustained lead
    .byte $07, $06, $55, $44   ; E8-E9: leads, EA-EB: swells
    .byte $18, $17, $35, $45   ; EC-EF: vibrato / tremolo styles

lut_SID_SR:
    .byte $01, $01, $01, $01   ; E0-E3: sustain 0 (pluck/decay), short release
    .byte $E3, $B3, $82, $C3   ; E4-E6: swells, E7: lead with sustain C
    .byte $A3, $62, $F3, $C3   ; E8-E9: leads, EA-EB: swells
    .byte $B3, $93, $A3, $83   ; EC-EF: sustained with release

; Pad from driver end up to $B600 ($01F2 = 498 bytes)
.res $01F2, $00

; ==============================================================================
; $B600 - $B6FF: Orb graphics for menus (32 tiles * 8 bytes = 256 bytes)
; ==============================================================================
orb_chr_data:
    .incbin "../res/menu/orbs.chr"

; Reserved $B700 - $BF1F (2,080 bytes)
.res $0820, $00

; ==============================================================================
; $BF20 - $BFFF: Intro Story Text (224 bytes)
; Control codes:
;   $01 = Double line break (down 2 rows, reset column to dest_x)
;   $05 = Single line break (down 1 row, reset column to dest_x)
;   $00 = Null terminator (end of string)
; Encoding:
;   $1A - $69: Dual Tile Encoding (DTE pairs from lut_DTE1 & lut_DTE2)
;   $80 - $FF: Menu font letters, numbers, punctuation, spaces ($FF)
; ==============================================================================
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
