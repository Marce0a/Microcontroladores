;
; carro dir.asm
;
; Created: 15/04/2022 10:19:13 p. m.
; Author : marce
;


; Replace with your application code
start:
      ldi r16,0xFF
	  out DDRB,r16
	  clr r16
	  out DDRD,r16
	  ldi r16,0xFF
	  out PORTD,r16
lazo:
      clr r16
	  out PORTB,r16
	  sbis PIND,2 ;Si switch intermitente es 0
	  rjmp intermitentes
	  sbis PIND,1 ;si switch dir_derecha es 0
	  rjmp dir_derecha
	  sbis PIND,0 ;si switch dir_izquierda es 0
	  rjmp dir_izquierda
	  rjmp lazo
	  rjmp lazo

intermitentes:
      ldi r20,0x03
	  out PORTB,r20
	  rcall delay
	  clr r20
	  out PORTB,r20
	  rcall delay
	  rjmp lazo

dir_derecha:
      ldi r20,0x01
	  out PORTB,r20
	  rcall delay
	  clr r20
	  out PORTB,r20
	  rcall delay
	  rjmp lazo

dir_izquierda:
      ldi r20,0x02
	  out PORTB,r20
	  rcall delay
	  clr r20
	  out PORTB,r20
	  rcall delay
	  rjmp lazo

;Subrutina
delay:
    ldi r17,0x05
	delay1:
	  ldi r18,0xC8
	    delay2:
		  ldi r19,0xA6
		  NOP
		  delay3:
		     dec r19
			 brne delay3
			 dec r18
			 brne delay2
			 dec r17
			 brne delay1
ret
