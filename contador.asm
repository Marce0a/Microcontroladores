;
; contador.asm
;
; Created: 01/04/2022 07:48:15 a. m.
; Author : marce
;


; Replace with your application code
start:
    ldi r16,0xFF
	out DDRB,r16
	clr r16
	out DDRD,r16
	call delay
lazo:
	in r16,PIND
	out PORTB,r16
	rjmp lazo
delay:
	ldi r17,0x0A
		delay1:
			ldi r18,0xFF
			NOP
				delay2:
					Dec r18
					brne delay2
					Dec r17
					brne delay1
					ret