;
; Interrupciones.asm
;
; Created: 18/05/2022 04:23:27 p. m.
; Author : Yo
;
;DATA SEGMENT
			.dseg							
			.org	0x100
CERO:		.byte	1
UNO:		.byte	1
DOS:		.byte	1
TRES:		.byte	1
CUATRO:		.byte	1	
CINCO:		.byte	1
SEIS:		.byte	1
SIETE:		.byte	1
OCHO:		.byte	1
NUEVE:		.byte	1
			.def	C_UMIN=r17				;Contador de unidades de minuto.
			.def	C_DMIN=r18				;Contador de decenas de minuto.
			.def	C_UHRS=r19				;Contador de unidades de hora.
			.def	C_DHRS=r20				;Contador de decenas de hora.
			.def	C_CONV=r21				;Contador para rutina de conversión.
			.def	S_CONV=r22				;Combinación de 7 segmentos para dígito.

;CODE SEGMENT (inicio de código ejecutable)
			.cseg
INICIO:		jmp		RESET					;Vector de Reset.
			jmp		EXT_INT0				;Vector de interrupción externa 0.
			jmp		EXT_INT1				;Vector de interrupción externa 1.

;---------------------INICIO DEL PROGRAMA AL ENCENDIDO O NIVEL BAJO EN RESET---------------------------------------

RESET:		rcall	TABLA_SEG
			rcall	CONFIG_PORT				;Rutina para configurar I/O ports.
			rcall	INICIA_CONT				;Rutina para iniciar contador.
			rcall	INICIA_INT1				;Rutina para configurar interrupción externa 1.
			sei								;Global Interrupt Enable.
LAZO:		rcall	DISPLAY					;Muestra valor en el display.
			rjmp	LAZO
TABLA_SEG:	ldi		r16,0xFD				
			sts		CERO,r16
			ldi		r16,0x61
			sts		UNO,r16
			ldi		r16,0xDB
			sts		DOS,r16
			ldi		r16,0xF3
			sts		TRES,r16
			ldi		r16,0x67
			sts		CUATRO,r16
			ldi		r16,0xB7
			sts		CINCO,r16
			ldi		r16,0xBF
			sts		SEIS,r16
			ldi		r16,0xE1
			sts		SIETE,r16
			ldi		r16,0xFF
			sts		OCHO,r16
			ldi		r16,0xF7
			sts		NUEVE,r16	;Fin de tabla
EXT_INT0:	sbi		EIFR,INTF0				;Escribe un 1 en la bandera de interrupción.
			reti
EXT_INT1:	rcall	D_BTTN					;Retardo para estabilizar botón de entrada.
			ldi		r28,0x01				;Bandera para saber sí es la primera vez.
CONTEO_INT:	rcall	CONTEO_I				;Incrementa contador.
			cpi		r28,0x00				;¿Es la primera vez?
			breq	FAST_INC
			rjmp	NORMAL_INC
FAST_INC:	ldi		r29,0x25				;Retardo para incremento rápido (0.4 seg)
			rjmp	AUNES_0
NORMAL_INC:	ldi		r29,0xA6				;Retardo para incremento regular (2 seg)
			rjmp	AUNES_0
AUNES_0:	sbis	PIND,3					;¿Ya se soltó el botón?
			rjmp	AUNES_0_2				;NO->Continúa en interrupción.
			rcall	D_BTTN					;Sí->Retardo para estabilizar botón de entrada.
			sbi		EIFR,INTF1				;Borra bandera, evita regreso a interrupción debido a rebote.
			reti
AUNES_0_2:	clr		r28						;Cambia bandera de primera vez.
			rcall	DISPLAY
			dec		r29
			brne	AUNES_0
			rjmp	CONTEO_INT

INICIA_INT1:ldi		r16,0x08				;X X X X ISC11 ISC10 ISC01 ISC00
			sts		EICRA,r16				;0 0 0 0   1     0     X     X		Sensa transición negativa en INT1.
			sbi		EIMSK,INT1				;X X X X X X INT1 INT0
			ret								;0 0 0 0 0 0  1    0				Habilita interrupción INT1.
CONFIG_PORT:
			ldi		r16,0xFF
			out		DDRB,r16				;Configura Puerto B como salida.
			ldi		r16,0xF0
			out		DDRD,r16				;Configura entradas y salidas del Puerto D.
			ret
INICIA_CONT:clr		C_UMIN
			clr		C_DMIN
			clr		C_UHRS
			clr		C_DHRS
			ret
CONTEO_I:	
INICIO_UM:	inc		C_UMIN
			cpi		C_UMIN,0x0A
			breq	INICIO_DM
			ret
INICIO_DM:	clr		C_UMIN
			inc		C_DMIN
			cpi		C_DMIN,0x0A
			breq	INICIO_UH
			ret
INICIO_UH:	clr		C_UMIN
			clr		C_DMIN
			inc		C_UHRS
			cpi		C_UHRS,0x0A
			breq	INICIO_DH
			ret
INICIO_DH:	clr		C_UMIN
			clr		C_DMIN
			clr		C_UHRS
			inc		C_DHRS
			cpi		C_DHRS,0x0A
			breq	INICIA_CONT
			ret
DISPLAY:	clr		r23
			out		PORTD,r23
			mov		C_CONV,C_UMIN			;Rutina para hacer 1 ciclo de barrido.
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,4
			rcall	D_DISP
			cbi		PORTD,4
			mov		C_CONV,C_DMIN
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,5
			rcall	D_DISP
			cbi		PORTD,5
			mov		C_CONV,C_UHRS
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,6
			rcall	D_DISP
			cbi		PORTD,6
			mov		C_CONV,C_DHRS
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,7
			rcall	D_DISP
			cbi		PORTD,7
			ret
CONV_7SEG:	ldi		r26,0x00				;Rutina que busca en tabla el valor de 7 segmentos para cada dígito.
			ldi		r27,0x01
			add		r26,C_CONV
			ld		S_CONV,X
			ret
;RETARDOS
D_BTTN:		ldi		r25,0x32				;Retardo para estabilizar botón de entrada en interrupción (0x32).
D_25ms:		rcall	D_0_5ms
			dec		r25
			brne	D_25ms
			ret
D_DISP:		ldi		r25,0x06				;Tiempo de encendido de cada dígito en el barrido (0x06).
D_03ms:		rcall	D_0_5ms
			dec		r25
			brne	D_03ms
			ret
D_0_5ms:	ldi		r24,0xA6				;Base de tiempo de 0.5 mseg (0xA6).
D_SALTO:	dec		r24
			brne	D_SALTO
			ret