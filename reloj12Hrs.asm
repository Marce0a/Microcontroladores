;
; 12HRS1.asm
;
; Created: 29/04/2022 07:26:47 p. m.
; Author : marce
;
; Display multidígito de 7 segmentos (Cátodo Común) para un reloj en formato de 12 Hrs.
;-------------------Declarar variables--------------------------------------------------------------------
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
			.def	UN_MIN=r21				
			.def	DC_MIN=r22
			.def	UN_HRS=r23
			.def	DC_HRS=r24
;-------------------Inicio de código------------------------------------------------------------------------
			.cseg
PRINCIPAL:	ldi		r16,0x3C
			out		DDRD,r16				;Configura entradas y salidas del Port D como salida.
			ldi		r16,0xFF
			out		DDRB,r16				;Programa Port B como salida.
			ldi		r16,0x7F
			out		PORTC,r16				;Activa las resistencias de Pull Up.
;----------Creación de tabla---------------------------------------------------------------------------------
			ldi		r16,0xFD				
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
			sts		NUEVE,r16	
;-----------------Fin de tabla------------------------------------------------------------------------------------------
INICIO:		clr		r17
			clr		r18
			clr		r19
			clr		r20
			rjmp	LAZO_RELOJ
;-------------------Código del reloj------------------------------------------------------------------------------------
INICIO_DH:	clr		r17						;Regresa a 0 un de min.
			clr		r18						;Regresa a 0 dec de min.
			clr		r19						;Regresa a 0 un de hr.
			inc		r20						;Incrementa valor de dec de hr.
			rjmp	LAZO_RELOJ
INICIO_UH:	clr		r17						;Regresa a 0 un de min.
			clr		r18						;Regresa a 0 dec_minuto.
			inc		r19						;Incrementa valor de las uni_hora.
			cpi		r19,0x0A				;Llega a 9:59 hrs para cambiar la dec
			breq	INICIO_DH
			rjmp	LAZO_RELOJ
INICIO_DM:	clr		r17						;Regresa a 0 unidades de minuto.
			inc		r18						;Incrementa valor de las dec_minuto.
			cpi		r18,0x06				;Llega a 59 min para cambiar la hora
			breq	INICIO_UH
			rjmp	LAZO_RELOJ
LAZO_RELOJ:	ldi		r25,0x32				;Crear retardo y poder visualizar la hora (0x32)
SHOW_2:		rcall	SHOW
			dec		r25
			brne	SHOW_2
L_RELOJ_3:	lds		r29,UNO
			cp		DC_HRS,r29				;1
			brne	L_RELOJ_4
			lds		r29,UNO
			cp		UN_HRS,r29				;1
			brne	L_RELOJ_4
			lds		r29,CINCO
			cp		DC_MIN,r29				;5
			brne	L_RELOJ_4
			lds		r29,NUEVE
			cp		UN_MIN,r29				;9
			breq	INICIO					;Ya pasaron 11:59 Hrs
L_RELOJ_4:	inc		r17						;Incrementa valor de las unidades de minuto.
			cpi		r17,0x0A
			breq	INICIO_DM
			rjmp	LAZO_RELOJ
UM_7SEG:	ldi		r26,0x00				;Rutina para buscar en tabla valor de unidades de minuto.
			ldi		r27,0x01
			add		r26,r17
			ld		UN_MIN,X
			ret
DM_7SEG:	ldi		r26,0x00				;Rutina para buscar en tabla valor de decenas de minuto.
			ldi		r27,0x01
			add		r26,r18
			ld		DC_MIN,X
			ret
UH_7SEG:	ldi		r26,0x00				;Rutina para buscar en tabla valor de unidades de hora.
			ldi		r27,0x01
			add		r26,r19
			ld		UN_HRS,X
			ret
DH_7SEG:	ldi		r26,0x00				;Rutina para buscar en tabla valor de decenas de hora.
			ldi		r27,0x01
			add		r26,r20
			ld		DC_HRS,X
			ret
SHOW:		rcall	UM_7SEG					;Rutina para hacer 1 ciclo de barrido.
			ldi		r29,0x38
			out		PORTD,r29
			out		PORTB,UN_MIN
			rcall	DELAY
			clr		r29
			out		PORTD,r29
			rcall	DM_7SEG
			ldi		r29,0x34
			out		PORTD,r29
			out		PORTB,DC_MIN
			rcall	DELAY
			clr		r29
			out		PORTD,r29
			rcall	UH_7SEG
			ldi		r29,0x2C
			out		PORTD,r29
			out		PORTB,UN_HRS
			rcall	DELAY
			clr		r29
			out		PORTD,r29
			rcall	DH_7SEG
			ldi		r29,0x1C
			out		PORTD,r29
			out		PORTB,DC_HRS
			rcall	DELAY
			clr		r29
			out		PORTD,r29
			ret

DELAY:		ldi		r31,0x0A					;Retardo entre encendido de cada dígito en el barrido (0x0A)-(0xA6)
Del5_ms:	ldi		r30,0xA6
Del0_5_ms:	dec		r30
			brne	Del0_5_ms
			dec		r31
			brne	Del5_ms
			ret



