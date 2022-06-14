;
; Display_7_seg_Reloj_12_H.asm
;
; Created: 26/04/2022 07:30:47 a. m.
; Author : Melanie-Sofia
;
;Display multidígito de 7 segmentos (CA) para crear un reloj en formato de 12 Hrs.
;
;-------------------DATA SEGMENT (declaración de variables)-------------------------------------------------
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
			.def	C_CONV=r21				;Almacena conteo para rutina de conversión.
			.def	S_CONV=r22				;Combinación de 7 segmentos para dígito.
;-------------------CODE SEGMENT (inicio de código ejecutable)-----------------------------------------------
			.cseg
PRINCIPAL:	ldi		r16,0x00
			out		DDRC,r16				;Programa Port C como entrada.
			ldi		r16,0x1E
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
;---------------Fin de tabla------------------------------------------------
INICIO:		clr		C_UMIN
			clr		C_DMIN
			clr		C_UHRS
			clr		C_DHRS
			rjmp	LAZO_RELOJ
PARO:		rcall	SHOW
			rjmp	LAZO_IN
;-------------------Código para funcionamiento del reloj-----------------------------------------------------
INICIO_DH:	clr		C_UMIN					;Regresa a 0 unidades de minuto.
			clr		C_DMIN					;Regresa a 0 decenas de minuto.
			clr		C_UHRS					;Regresa a 0 unidades de hora.
			inc		C_DHRS					;Incrementa valor de decenas de hora.
			rjmp	LAZO_RELOJ
INICIO_UH:	clr		C_UMIN					;Regresa a 0 unidades de minuto.
			clr		C_DMIN					;Regresa a 0 decenas de minuto.
			inc		C_UHRS					;Incrementa valor de las unidades de hora.
			cpi		C_DHRS,0x01				;*
			brne	INICIO_UH2				;*** Condiciones para saber si 
			cpi		C_UHRS,0x02				;*** ya son las 12:00 y reiniciar.
			breq	INICIO					;*
INICIO_UH2:	cpi		r19,0x0A				;¿Ya se completarón 10 hrs?
			breq	INICIO_DH				;Salta a rutina de decenas de hora.
			rjmp	LAZO_RELOJ
INICIO_DM:	clr		C_UMIN					;Regresa a 0 unidades de minuto.
			inc		C_DMIN					;Incrementa valor de las decenas de minuto.
			cpi		r18,0x06				;¿Ya se completaron 60 min?
			breq	INICIO_UH				;Salta a rutina de unidades de hora.
			rjmp	LAZO_RELOJ
LAZO_RELOJ:	ldi		r25,0x53				;Valor para crear retardo y poder visualizar la hora (0x53)
SHOW_2:		rcall	SHOW
			dec		r25
LAZO_IN:	in		r16,PINC				;Lee el edo de los interruptores.
			andi	r16,0x30				;Aplica máscara al puerto de entrada.
			cpi		r16,0x30				;¿RESET-> OFF	PARO-> OFF?
			breq	L_RELOJ_2				;Si ningún bótón está activo, va a la subrutina LAZO_RELOJ.
			cpi		r16,0x20				;¿RESET-> OFF	PARO-> ON?
			breq	PARO					;Si está activo el botón de paro, va a la subrutina PARO.
			cpi		r16,0x10				;¿RESET-> ON	PARO-> OFF?
			breq	INICIO					;Si está activo el botón de reset, va a la subrutina INICIO.
			cpi		r16,0x00				;¿RESET-> ON	PARO-> ON?
			breq	INICIO					;Si ambos botones están activos, va a la subrutina INICIO.
L_RELOJ_2:	cpi		r25,0x00
			brne	SHOW_2
L_RELOJ_4:	inc		C_UMIN					;Incrementa valor de las unidades de minuto.
			cpi		C_UMIN,0x0A
			breq	INICIO_DM
			rjmp	LAZO_RELOJ
SHOW:		ldi		r23,0x3C
			out		PORTD,r23
			mov		C_CONV,C_UMIN			;Rutina para hacer 1 ciclo de barrido.
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,1
			rcall	DELAY
			cbi		PORTD,1
			mov		C_CONV,C_DMIN
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,2
			rcall	DELAY
			cbi		PORTD,2
			mov		C_CONV,C_UHRS
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,3
			rcall	DELAY
			cbi		PORTD,3
			mov		C_CONV,C_DHRS
			rcall	CONV_7SEG
			out		PORTB,S_CONV
			sbi		PORTD,4
			rcall	DELAY
			cbi		PORTD,4
			ret
CONV_7SEG:	ldi		r26,0x00				;Rutina que busca en tabla valor de 7 segmentos para cada dígito.
			ldi		r27,0x01
			add		r26,C_CONV
			ld		S_CONV,X
			ret
DELAY:		ldi		r31,0x06				;Retardo entre encendido de cada dígito en el barrido (0x06)-(0xA6)
D_3_ms:		ldi		r30,0xA6
D_0_5_ms:	dec		r30
			brne	D_0_5_ms
			dec		r31
			brne	D_3_ms
			ret