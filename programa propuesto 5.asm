;
; pp2 ej5.asm
;
; Created: 15/05/2022 05:46:55 p. m.
; Author : marce
;5. Diseñar un programa que seleccione el número positivo del contenido del registro
;(r16) y (r17) y coloque el resultado en el registro (r18).


; Replace with your application code
start:
    ldi r17,-15
	ldi r16, 56 
	clr r18
	tst r16 
	brpl r16pos
	tst r17	
	brpl r17pos
	rjmp fin
r17pos:
	mov r18, r17
	rjmp fin
r16pos:	
	mov r18, r16
	rjmp fin

fin: 
	rjmp fin
