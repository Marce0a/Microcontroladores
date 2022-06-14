;
; PWM.asm
;
; Created: 02/06/2022 04:47:47 p. m.
; Author : marce
;


; Replace with your application code
start:
    ldi r16,0x83
    out TCCR0A,r16
	ldi r16,0x02
	out TCCR0B,r16
	ldi r16,0x1A
	out OCR0A,r16
	sbi DDRD,PD6
	
lazo:
	rjmp lazo
