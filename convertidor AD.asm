;
; convertidor AD.asm
;
; Created: 02/06/2022 04:55:10 p. m.
; Author : marce
;
; Replace with your application code
ldi r16, 0xFF
out DDRD, r16 ;configuro PD como salida
ldi r16, 0x60 ;configuracion de los registros ADC
sts ADMUX, r16
ldi r16, 0x86
sts ADCSRA, r16
clr r16
sts ADCSRB, r16
ldi r16, 0x01
sts DIDR0, r16
ldi r16, 0xC6 
sts ADCSRA, r16 ;Comienzo la conversion
INICIO:
lds r18, ADCSRA
andi r18, 0x10
cpi r18, 0x10 ;Termino la conversion?
breq LECTURA
rjmp INICIO
LECTURA:
lds r19, ADCL ;Leo el dato del registro
lds r17, ADCH ;Leo el dato del registro
out PORTD, r17 ;Escribo el dato en el puerto
rcall RETARDO ;Retardo para darle mas estabilidad a los 
leds
ldi r16, 0xD6 
sts ADCSRA, r16 ;Comienzo la conversion y borro la bandera de fin 
de conversión
rjmp INICIO
RETARDO:
ldi r22, 65
 ldi r23, 236
L1: dec r23
 brne L1
 dec r22
 brne L1
 rjmp PC+1
 ret