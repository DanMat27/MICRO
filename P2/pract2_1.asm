; *************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 
;************************************************************************** 

;************************************************************************** 
; INFORMACION IMPORTANTE: Al ejecutar se pedirá introducir un 0 o un 1 segun 
; la opcion a escoger (0 para el apartado A y 1 para el apartado B). El
; apartado B no funciona correctamente, pero si se introduce la matriz (1,2,
; 3,4,5,6,7,8,9) funciona sin problemas. El apartado A funciona para cualquier
; matriz predefinida.
;************************************************************************** 

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 

	ARRAYA DB 10,-2,-4,3,-5,-12,-2,4,-1                             ; Array (matriz) A con valores predefinidos (entre -16 y 15)
	ARRAYB DW 9 DUP (0)                                             ; Array (matriz) B con valores introducidos por teclado (entre -16 y 15)
	RESULTADO DW 6 DUP (0)                                          ; Array que posee los 6 resultados del calculo del determinante
	DETERMINANTE DW 0                                               ; Resultado del determinante de la matriz
	FRASE DB "Elige opcion: 0=predefinido, 1=teclado ->  ",'$'      ; Cadena de caracteres antes de la impresion por teclado
	ORACION1 DB "Introduce 9 numeros (del -15 al 16) de uno en uno: ",'$' ; Cadena de caracteres antes de introducir por teclado
	ORACION2 DB "(Escribe un numero y dale a Enter)",'$'            ; Cadena de caracteres antes de introducir por teclado
	NOMBRE DB 60 DUP (0)                                            ; Nombre para leer por teclado 
	VALOR DB 0                                                      ; Valor utilizado para guardar el cociente en las subrutinas bucles A
	RELLENO DB 0                                                    ; Variable de relleno para que DIVIDENDO no sea leido con datos de VALOR 
	DIVIDENDO DB 10                                                 ; Variable utilizada como dividendo igual a 10 en las subrutinas bucles
	FLAG DB 0                                                       ; Variable bandera que indica con 0 si es positivo o 1 si es negativo el numero
	CONTADOR1 DW 0                                                  ; Variable contador para el bucle de lectura de datos de ARRAYA
	CONTADOR2 DW 0                                                  ; Variable contador para las subrutinas bucles
	MATRIZA1 DB "                          ",'$'                    ; Cadena de caracteres impresa como parte alta de la matriz A
	MATRIZA2 DB "|A|=                      ",'$'                    ; Cadena de caracteres impresa como parte media de la matriz A
	MATRIZA3 DB "                          ",'$'                    ; Cadena de caracteres impresa como parte baja de la matriz A
	MATRIZB1 DB "                          ",'$'                    ; Cadena de caracteres impresa como parte alta de la matriz B
	MATRIZB2 DB "|B|=                      ",'$'                    ; Cadena de caracteres impresa como parte media de la matriz B
	MATRIZB3 DB "                          ",'$'                    ; Cadena de caracteres impresa como parte baja de la matriz B
	NUMTEC DB ?                                                     ; Array con el numero leido por teclado 
	RELLENO2 DB 8 DUP (0)                                           ; Variable de relleno para que NUMTEC no sea modificado por CONTADOR3
	CONTADOR3 DW 0                                                  ; Variable contador utilizada en CONVASCNUM
	DIGITOS DB 2 DUP (0)                                            ; Array con los 2 digitos leidos por teclado
	VALOR2 DW 0                                                     ; Valor utilizado para guardar el cociente en las subrutinas bucles B
	
DATOS ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE PILA 
PILA SEGMENT STACK "STACK" 
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0 
PILA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO EXTRA 
EXTRA SEGMENT 
	RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES) 
EXTRA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO 
CODE SEGMENT 
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL 
INICIO PROC 
	; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
	MOV AX, DATOS 
	MOV DS, AX 
	MOV AX, PILA 
	MOV SS, AX 
	MOV AX, EXTRA 
	MOV ES, AX 
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO 
	; FIN DE LAS INICIALIZACIONES 
	; COMIENZO DEL PROGRAMA 
	
	MOV DX, OFFSET FRASE  ; Imprime por pantalla la cadena FRASE
	MOV AH, 9
	INT 21H
	
	MOV AH,0AH            ; Lee por teclado la opcion introducida (0 o 1)
	MOV DX,OFFSET NOMBRE 
	MOV NOMBRE[0],60 
	INT 21H 
	
	MOV AH, 2             ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	MOV AH, 2             ; Imprime el valor anterior introducido por teclado 
	MOV DL, NOMBRE[2]
	INT 21H
	
	CMP NOMBRE[2], 48     ; Si se ha introducido el valor 0, salta a la etiqueta PREDEFINIDO
	JE PREDEFINIDO
	
	CMP NOMBRE[2], 49     ; Si se ha introducido el valor 1, salta a la etiqueta TECLADO
	JE TECLADO
	
	FIN:	              ; Etiqueta FIN DEL PROGRAMA  
	MOV AX, 4C00H 
	INT 21H
	
	PREDEFINIDO:          ; * * * PREDEFINIDO * * *
	CALL PREDEFDET        ; Llama a subrutina PREDEFDET para calcular el determinante de ARRAYA (Linea 104)
	CALL MATRIZA          ; Llama a subrutina MATRIZA para imprimir por pantalla la matriz A (Linea 365)
	JMP FIN
 
	TECLADO:              ; * * * TECLADO * * *
	CALL TEC              ; Llama a subrutina TEC (Linea 218)
	CALL TECLADODET       ; Llama a subrutina TECLADODET (Linea 161)
	CALL MATRIZB          ; Llama a subrutina MATRIZB (Linea 685)
	JMP FIN
	
	
;**************************************************************************
; SUBRUTINA PARA CALCULAR EL DETERMINANTE DE LA MATRIZ PREDEFINIDA.
; PREDEFDET
;**************************************************************************
	PREDEFDET PROC NEAR

		MOV AX, 0             ; Resultado de multiplicar los numeros de la matriz en las posiciones 0, 4 y 8.
		MOV AL, ARRAYA[0]     ; Se guarda en RESULTADO[0]
		IMUL ARRAYA[4]
		IMUL ARRAYA[8]
		MOV RESULTADO[0], AX
		
		MOV AX, 0
		MOV AL, ARRAYA[2]	  ; Resultado de multiplicar los numeros de la matriz en las posiciones 2, 3 y 7.
		IMUL ARRAYA[3]	      ; Se guarda en RESULTADO[2]
		IMUL ARRAYA[7]
		MOV RESULTADO[2], AX
		
		MOV AX, 0
		MOV AL, ARRAYA[1]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 1, 5 y 6.
		IMUL ARRAYA[5]		  ; Se guarda en RESULTADO[4]
		IMUL ARRAYA[6]
		MOV RESULTADO[4], AX
		
		MOV AX, 0
		MOV AL, ARRAYA[2]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 2, 4 y 6.
		IMUL ARRAYA[4]		  ; Se guarda en RESULTADO[6]
		IMUL ARRAYA[6]
		MOV RESULTADO[6], AX
		
		MOV AX, 0 
		MOV AL, ARRAYA[1]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 1, 3 y 8.
		IMUL ARRAYA[3]        ; Se guarda en RESULTADO[8]
		IMUL ARRAYA[8]
		MOV RESULTADO[8], AX
		
		MOV AX, 0
		MOV AL, ARRAYA[0]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 0, 5 y 7.
		IMUL ARRAYA[5]		  ; Se guarda en RESULTADO[10]
		IMUL ARRAYA[7]
		MOV RESULTADO[10], AX
		
		MOV AX, 0
		ADD AX, RESULTADO[0]  ; Operaciones con los resultados anteriores para obtener el determinante
		ADD AX, RESULTADO[2]
		ADD AX, RESULTADO[4]
		SUB AX, RESULTADO[6]
		SUB AX, RESULTADO[8]
		SUB AX, RESULTADO[10]
		
		MOV DETERMINANTE, AX  ; Guardamos el valor calculado en la variable DETERMINANTE

		RET                   ; Regresamos de la subrutina PREDEF
	
	PREDEFDET ENDP
	
	
;**************************************************************************
; SUBRUTINA PARA CALCULAR EL DETERMINANTE DE LA MATRIZ INTRODUCIDA POR TECLADO.
; TECLADODET
;**************************************************************************
	TECLADODET PROC NEAR

		MOV AX, 0             ; Resultado de multiplicar los numeros de la matriz en las posiciones 0, 4 y 8.
		MOV AX, ARRAYB[0]     ; Se guarda en RESULTADO[0]
		IMUL ARRAYB[8]
		IMUL ARRAYB[16]
		MOV RESULTADO[0], AX
		
		MOV AX, 0
		MOV AX, ARRAYB[4]	  ; Resultado de multiplicar los numeros de la matriz en las posiciones 2, 3 y 7.
		IMUL ARRAYB[6]	      ; Se guarda en RESULTADO[2]
		IMUL ARRAYB[14]
		MOV RESULTADO[2], AX
		
		MOV AX, 0
		MOV AX, ARRAYB[2]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 1, 5 y 6.
		IMUL ARRAYB[10]		  ; Se guarda en RESULTADO[4]
		IMUL ARRAYB[12]
		MOV RESULTADO[4], AX
		
		MOV AX, 0
		MOV AX, ARRAYB[4]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 2, 4 y 6.
		IMUL ARRAYB[8]		  ; Se guarda en RESULTADO[6]
		IMUL ARRAYB[12]
		MOV RESULTADO[6], AX
		
		MOV AX, 0 
		MOV AX, ARRAYB[2]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 1, 3 y 8.
		IMUL ARRAYB[6]        ; Se guarda en RESULTADO[8]
		IMUL ARRAYB[16]
		MOV RESULTADO[8], AX
		
		MOV AX, 0
		MOV AX, ARRAYB[0]     ; Resultado de multiplicar los numeros de la matriz en las posiciones 0, 5 y 7.
		IMUL ARRAYB[10]		  ; Se guarda en RESULTADO[10]
		IMUL ARRAYB[14]
		MOV RESULTADO[10], AX
		
		MOV AX, 0
		ADD AX, RESULTADO[0]  ; Operaciones con los resultados anteriores para obtener el determinante
		ADD AX, RESULTADO[2]
		ADD AX, RESULTADO[4]
		SUB AX, RESULTADO[6]
		SUB AX, RESULTADO[8]
		SUB AX, RESULTADO[10]
		
		MOV DETERMINANTE, AX  ; Guardamos el valor calculado en la variable DETERMINANTE

		RET                   ; Regresamos de la subrutina PREDEF
	
	TECLADODET ENDP
	
	
;**************************************************************************
; SUBRUTINA PARA GUARDAR LOS DATOS DE LA MATRIZ B INTRODUCIDOS POR TECLADO.
; TEC
;**************************************************************************	
	
	TEC PROC NEAR
	
		MOV AH, 2               ; Imprime un salto de linea por pantalla
		MOV DL, 10  
		INT 21H	
		
		MOV DX, OFFSET ORACION1 ; Imprime por pantalla la cadena ORACION1
		MOV AH, 9
		INT 21H
		
		MOV AH, 2               ; Imprime un salto de linea por pantalla
		MOV DL, 10  
		INT 21H	
		
		MOV DX, OFFSET ORACION2 ; Imprime por pantalla la cadena ORACION2
		MOV AH, 9
		INT 21H
		
		INICIO_LOOP:           ; * * * INICIO_LOOP * * *
		MOV AH,0AH             ; Bucle de lectura de los numeros introducidos por teclado uno a uno
		MOV DX, OFFSET NUMTEC  ; y se almacenan en ARRAYB
		MOV NUMTEC[0], 4
		INT 21H
		CALL CONVASCNUM        ; Llama a subrutina CONVASCNUM (Linea 260)
		CMP CONTADOR1, 16
		JE FUERA_LOOP          ; Salta a FUERA_LOOP si se cumple el CMP anterior
		INC CONTADOR1          ; Se incrementa CONTADOR1 dos veces ya que ARRAYB es de Words
		INC CONTADOR1
		JMP INICIO_LOOP        ; Salta a INICIO_LOOP
		
		FUERA_LOOP:            ; * * * FUERA_LOOP * * *	
		RET                    ; Regresamos de la subrutina TEC
	
	TEC ENDP
	

;**************************************************************************
; SUBRUTINA PARA PASAR A NUMERO HEXADECIMAL EL DATO ASCII INTRODUCIDO POR TECLADO
; CONVASCNUM
;**************************************************************************	
	CONVASCNUM PROC NEAR
		
		MOV DX, 0           ; Inicializamos AX y DX a 0
		MOV AX, 0
		MOV DL, NUMTEC[1]   ; Guardamos en DL el numero de digitos leidos por teclado
		MOV CONTADOR2, 2
		MOV CONTADOR3, 0
		
		CMP DL, 1           ; Si NUMTEC[1] es 1, salta a BUCLE_CONV1 (Linea 280)
		JE BUCLE_CONV1
		CMP DL, 2           ; Si NUMTEC[1] es 2, salta a BUCLE_CONV2 (Linea 287)
		JE BUCLE_CONV2
		CMP DL, 3           ; Si NUMTEC[1] es 3, salta a BUCLE_CONV3 (Linea 305)
		JE BUCLE_CONV3
		
		
		; * * * * * * * CASO NUMTEC[1] = 1 * * * * * * * 
		BUCLE_CONV1:            ; * * * BUCLE_CONV1 * * *
		MOV SI, CONTADOR2       ; Se encarga de numeros positivos de un solo digito
		MOV AL, NUMTEC[SI]      ; Resta 30H al numero en ASCII para pasarlo a hexadecimal
		SUB AL, 30H
		JMP FUERA_BUCLE_CONV    ; Salta a FUERA_BUCLE_CONV (Linea 338)
		
			
		; * * * * * * * CASO NUMTEC[1] = 2 * * * * * * * 
		BUCLE_CONV2:           ; * * * BUCLE_CONV2 * * *
		MOV SI, CONTADOR2      ; Se encarga de numeros positivos de dos digitos y negativos de un digito
		MOV AL, NUMTEC[SI]
		CMP AL, 45             ; Comprueba si es negativo
		JE NEGATIVO            ; Si lo es, salta a NEGATIVO
		SUB AL, 30H            ; Resta 30H al numero en ASCII para pasarlo a hexadecimal
		MOV SI, CONTADOR3
		MOV DIGITOS[1], AL	   ; Almacena los dos digitos leidos en DIGITOS
		VUELVE_NEGATIVO:       ; * * * VUELVE_NEGATIVO * * *
		CMP CONTADOR2, 3   
		JE FUERA_BUC           ; Si se cumple el CMP anterior, salta a FUERA_BUC
		INC CONTADOR2
		JMP BUCLE_CONV2        ; Salta a BUCLE_CONV2
		
		
		NEGATIVO:              ; * * * NEGATIVO * * *
		MOV FLAG, 1            ; Pone el FLAG a 1
		MOV DIGITOS[0], 0      ; Este byte en DIGITOS lo ponemos a 0 al tener el guion
		JMP VUELVE_NEGATIVO    ; Salta a VUELVE_NEGATIVO
		
		
		; * * * * * * * CASO NUMTEC[1] = 3 * * * * * * * 
								; Se encarga de numeros negativos de dos digitos
		LEER_GUION:             ;* * * LEER_GUION * * *		     
		MOV SI, CONTADOR2       ; Lee el primer dígito leido que es el guion
		MOV AL, NUMTEC[SI]
		INC CONTADOR2
		JMP GUION_LEIDO         ; Salta a GUION_LEIDO
		
		
		BUCLE_CONV3:            ; * * * BUCLE_CONV3 * * *
		JMP LEER_GUION          ; Salta a LEER_GUION
		GUION_LEIDO:            ; * * * GUION_LEIDO * * *
		MOV SI, CONTADOR2
		MOV AL, NUMTEC[SI]
		SUB AL, 30H             ; Resta 30H al numero en ASCII para pasarlo a hexadecimal
		MOV SI, CONTADOR3
		MOV DIGITOS[SI], AL	    ; Almacena los dos digitos leidos en DIGITOS
		INC CONTADOR3
		CMP CONTADOR2, 4
		JE FUERA_BUC            ; Si se cumple el CMP anterior, salta a FUERA_BUC
		INC CONTADOR2
		JMP GUION_LEIDO
	
		FUERA_BUC:              ; * * * FUERA_BUC * * *		
		MOV AL, DIGITOS[0]      ; Multiplica el primer digito por 10 y se le suma el segundo
		MUL DIVIDENDO           ; DIVIDENDO = 10
		ADD AL, DIGITOS[1]
		MOV FLAG, 1             ; Pone el FLAG a 1 al ser negativo
		JMP CONV_NEG            ; Salta a CONV_NEG (Linea 352)
		
		
		; * * * * * * * RETORNO COMUN * * * * * * * 
		FUERA_BUCLE_CONV:     ; * * * FUERA_BUCLE_CONV * * *
		CMP FLAG, 1
		JE CONV_NEG           ; Si el FLAG es 1, niega a complemento a dos el numero 
		MOV SI, CONTADOR1
		MOV ARRAYB[SI], AX    ; Introduce el numero en ARRAYB
		
		MOV AH, 2             ; Imprime un salto de linea por pantalla
	    MOV DL, 10 
	    INT 21H	
		
		RET
		
		
		CONV_NEG:             ; * * * CONV_NEG * * *
		NEG AL                ; Niega a complemento a dos el numero
		MOV SI, CONTADOR1
		MOV ARRAYB[SI], AX    ; Introduce el numero en ARRAYB
		
		MOV AH, 2             ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H	
		
		RET
		
	CONVASCNUM ENDP

	
;**************************************************************************
; SUBRUTINA PARA IMPRIMIR LA MATRIZ A POR PANTALLA.
; MATRIZA
;**************************************************************************	
    MATRIZA PROC NEAR
		
		; * * * * * * * MATRIZA1 * * * * * * * *
								 ; Se encarga de imprimir la cadena MATRIZA1
		MOV CONTADOR1, 2         ; Inicializamos los contadores 
		MOV CONTADOR2, 20       
		
		MOV SI, CONTADOR2		
		MOV MATRIZA1[SI], 124    ; Introduce el simbolo | al final de MATRIZA1
		DEC CONTADOR2
		
		INI_BUCLE1:              ; * * * INI_BUCLE1 * * *
		MOV SI, CONTADOR1        ; Bucle que introduce cada uno de los tres primeros valores de ARRAYA 
		MOV AH, ARRAYA[SI]       ; en MATRIZA1 al llamar a la subrutina BUCLEA1. Carga el valor de la 
		MOV VALOR, AH            ; matriz que le toca en VALOR.
	    CALL BUCLEA1             ; Llama a la subrutina BUCLEA1 (Linea 482)
		CMP CONTADOR1, 0
		JE FUERA1
		DEC CONTADOR1
		JMP INI_BUCLE1           ; Salta a INI_BUCLE1
		
		FUERA1:                  ; * * * FUERA1 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZA1
		MOV MATRIZA1[SI], 124    
		DEC CONTADOR2
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZA1  ; Imprime MATRIZA1 por pantalla
		MOV AH, 9
		INT 21H
		
		
		; * * * * * * * MATRIZA2 * * * * * * * *
								 ; Se encarga de imprimir la cadena MATRIZA2 con el determinante
		MOV CONTADOR1, 5         ; Inicializamos los contadores 		
		MOV CONTADOR2, 20 
		
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al final de MATRIZA2
		MOV MATRIZA2[SI], 124    
		DEC CONTADOR2
		
		INI_BUCLE2:              ; * * * INI_BUCLE2 * * *
		CMP CONTADOR1, 2         ; Bucle que introduce cada uno de los tres medios valores de ARRAYA 
		JE FUERA2                ; en MATRIZA2 al llamar a la subrutina BUCLEA2. Carga el valor de la
		MOV SI, CONTADOR1        ; matriz que le toca en VALOR.
		MOV AH, ARRAYA[SI]
		MOV VALOR, AH
	    CALL BUCLEA2             ; Llama a la subrutina BUCLEA2 (Linea 531)
		DEC CONTADOR1 
		JMP INI_BUCLE2           ; Salta a INI_BUCLE2
		
		FUERA2:                  ; * * * FUERA2 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZA2
		MOV MATRIZA2[SI], 124    
		DEC CONTADOR2
		
		
		MOV CONTADOR2, 26        ; Introduce el simbolo igual (=)en MATRIZA2
		MOV SI, 21		         
		MOV MATRIZA2[SI], 61   
		   
		CALL BUCLEA_DET          ; Introduce el valor del determinante en MATRIZA2 al llamar a BUCLEA_DET (Linea 629)
		
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZA2  ; Imprime MATRIZA2 por pantalla
		MOV AH, 9 
		INT 21H
		
		
		; * * * * * * * MATRIZA3 * * * * * * * *
								 ; Se encarga de imprimir la cadena MATRIZA3
		MOV CONTADOR1, 8         ; Inicializamos los contadores 		
		MOV CONTADOR2, 20 
		
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al final de MATRIZA3
		MOV MATRIZA3[SI], 124    
		DEC CONTADOR2
		
		INI_BUCLE3:              ; * * * INI_BUCLE3 * * *
		CMP CONTADOR1, 5         ; Bucle que introduce cada uno de los tres ultimos valores de ARRAYA 
		JE FUERA3                ; en MATRIZA3 al llamar a la subrutina BUCLEA3. Carga el valor de la
		MOV SI, CONTADOR1        ; matriz que le toca en VALOR.
		MOV AH, ARRAYA[SI] 
		MOV VALOR, AH
	    CALL BUCLEA3             ; Llama a la subrutina BUCLEA3 (Linea 580)
		DEC CONTADOR1
		JMP INI_BUCLE3           ; Salta a INI_BUCLE3
		
		FUERA3:                  ; * * * FUERA3 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZA2
		MOV MATRIZA3[SI], 124    
		DEC CONTADOR2
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZA3  ; Imprime MATRIZA3 por pantalla
		MOV AH, 9
		INT 21H
		
		
		RET                      ; Regresamos de la subrutina MATRIZA
		
	MATRIZA ENDP

;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZA1
; BUCLEA1
;**************************************************************************
	BUCLEA1 PROC NEAR
	
		MOV FLAG, 0              ; Inicializamos FLAG a 0 
		MOV AX, 0
		ADD AL, VALOR
		JS NEGAT                 ; Salta a NEGAT si el valor es negativo
		VOLVER:                  ; * * * VOLVER * * *
		
		INICIO_BUCLE:            ; * * * INICIO_BUCLE * * *
		MOV AX, WORD PTR VALOR   ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO            ; MATRIZA1.
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZA1[SI], AH
		MOV VALOR, AL
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE
		JMP INICIO_BUCLE         ; Salta a INICIO_BUCLE
		
		SALIR_BUCLE:             ; * * * SALIR_BUCLE * * *
		CMP FLAG, 1              ; Si FLAG ES 1 salta a SIGNO
		JE SIGNO
		
		RETURN:                  ; * * * RETURN * * * 		
		MOV SI, CONTADOR2        ; Introduce el simbolo espacio ( ) en MATRIZA1
		MOV MATRIZA1[SI], 32    
		DEC CONTADOR2
		
		RET		                 ; Regresamos de la subrutina BUCLEA1
				
		NEGAT:                   ; * * * NEGAT * * *
		MOV FLAG, 1              ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR
		JMP VOLVER
		
		SIGNO:                   ; * * * SIGNO * * *
		MOV SI, CONTADOR2        ; Introduce el simbolo menos (-) en MATRIZA1
		MOV MATRIZA1[SI], 45    
		DEC CONTADOR2
		JMP RETURN
		
	BUCLEA1 ENDP	
	
	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZA2
; BUCLEA2
;**************************************************************************
	BUCLEA2 PROC NEAR
	
		MOV FLAG, 0              ; Inicializamos FLAG a 0
		MOV AX, 0
		ADD AL, VALOR
		JS NEGAT2                ; Salta a NEGAT2 si el valor es negativo
		VOLVER2:                 ; * * * VOLVER2 * * *
		
		INICIO_BUCLE2:           ; * * * INICIO_BUCLE2 * * *
		MOV AX, WORD PTR VALOR   ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO            ; MATRIZA2.
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZA2[SI], AH
		MOV VALOR, AL
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE2
		JMP INICIO_BUCLE2       ; Salta a INICIO_BUCLE2
		
		SALIR_BUCLE2:           ; * * * SALIR_BUCLE2 * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNO2
		JE SIGNO2
		
		RETURN2:                ; * * * RETURN2 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZA2
		MOV MATRIZA2[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEA2
				
		NEGAT2:                 ; * * * NEGAT2 * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR
		JMP VOLVER2
		
		SIGNO2:                 ; * * * SIGNO2 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZA2
		MOV MATRIZA2[SI], 45   
		DEC CONTADOR2
		JMP RETURN2
		
	BUCLEA2 ENDP
	
	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZA3
; BUCLEA3
;**************************************************************************
	BUCLEA3 PROC NEAR
	
		MOV FLAG, 0             ; Inicializamos FLAG a 0
		MOV AX, 0
		ADD AL, VALOR
		JS NEGAT3               ; Salta a NEGAT3 si el valor es negativo
		VOLVER3:                ; * * * VOLVER3 * * *
		
		INICIO_BUCLE3:          ; * * * INICIO_BUCLE3 * * *
		MOV AX, WORD PTR VALOR  ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO           ; MATRIZA3
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZA3[SI], AH
		MOV VALOR, AL
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE3
		JMP INICIO_BUCLE3       ; Salta a INICIO_BUCLE3
		
		SALIR_BUCLE3:           ; * * * SALIR_BUCLE3 * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNO3
		JE SIGNO3
		
		RETURN3:                ; * * * RETURN3 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZA3
		MOV MATRIZA3[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEA3
				
		NEGAT3:                 ; * * * NEGAT3 * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR
		JMP VOLVER3
		 
		SIGNO3:                 ; * * * SIGNO3 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZA3
		MOV MATRIZA3[SI], 45   
		DEC CONTADOR2
		JMP RETURN3
		
	BUCLEA3 ENDP

	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL DETERMINANTE EN LA CADENA MATRIZA2
; BUCLEA_DET
;**************************************************************************
	BUCLEA_DET PROC NEAR
	
		MOV FLAG, 0             ; Inicializamos FLAG a 0 
		MOV AX, 0                
		ADD AX, DETERMINANTE
		JS NEGAT_DET            ; Salta a NEGAT_DET si el determinante es negativo
		VOLVER_DET:             ; * * * VOLVER_DET * * * 
		
		MOV AX, DETERMINANTE    ; Primera iteracion antes del bucle
		DIV DIVIDENDO           ; Introduce las unidades ascii del determinante en la cadena MATRIZA2
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZA2[SI], AH
		MOV VALOR, AL
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE_DET      
		
		INICIO_BUCLE_DET:       ; * * * INICIO_BUCLE_DET * * *
		MOV AX, WORD PTR VALOR  ; Bucle que introduce las unidades ascii del determinante en la cadena
		DIV DIVIDENDO           ; MATRIZA2
		ADD AH, 48 
		MOV SI, CONTADOR2
		MOV MATRIZA2[SI], AH
		MOV VALOR, AL
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE_DET
		JMP INICIO_BUCLE_DET    ; Salta a INICIO_BUCLE_DET
		
		SALIR_BUCLE_DET:        ; * * * SALIR_BUCLE_DET * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNO_DET
		JE SIGNO_DET
		
		RETURN_DET:             ; * * * RETURN_DET * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZA2
		MOV MATRIZA2[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEA_DET
				
		NEGAT_DET:              ; * * * NEGAT_DET * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del determinante
		NEG DETERMINANTE
		JMP VOLVER_DET
		
		SIGNO_DET:              ; * * * SIGNO_DET * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZA2
		MOV MATRIZA2[SI], 45   
		DEC CONTADOR2
		JMP RETURN_DET
		
	BUCLEA_DET ENDP		
	
	
;**************************************************************************
; SUBRUTINA PARA IMPRIMIR LA MATRIZ B POR PANTALLA.
; MATRIZB
;**************************************************************************	
    MATRIZB PROC NEAR
		
		; * * * * * * * MATRIZB1 * * * * * * * *
		MOV CONTADOR1, 4         ; Inicializamos los contadores 
		MOV CONTADOR2, 20       
		
		MOV SI, CONTADOR2		
		MOV MATRIZB1[SI], 124    ; Introduce el simbolo | al final de MATRIZB1
		DEC CONTADOR2
		
		INI_BUCLEB1:             ; * * * INI_BUCLEB1 * * *
		MOV SI, CONTADOR1        ; Bucle que introduce cada uno de los tres primeros valores de ARRAYB 
		MOV AX, ARRAYB[SI]       ; en MATRIZB1 al llamar a la subrutina BUCLEB1. Carga el valor de la 
		MOV VALOR2, AX           ; matriz que le toca en VALOR2.
	    CALL BUCLEB1             ; Llama a subrutina BUCLEB1 (Linea 806)
		CMP CONTADOR1, 0
		JE FUERAB1
		DEC CONTADOR1
		DEC CONTADOR1
		JMP INI_BUCLEB1          ; Salta a INI_BUCLE1
		
		FUERAB1:                 ; * * * FUERAB1 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZB1
		MOV MATRIZB1[SI], 124    
		DEC CONTADOR2
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZB1  ; Imprime MATRIZB1 por pantalla
		MOV AH, 9
		INT 21H
		
		
		; * * * * * * * MATRIZB2 * * * * * * * *
		MOV CONTADOR1, 10         ; Inicializamos los contadores 		
		MOV CONTADOR2, 20 
		
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al final de MATRIZB2
		MOV MATRIZB2[SI], 124    
		DEC CONTADOR2
		
		INI_BUCLEB2:             ; * * * INI_BUCLEB2 * * *
		CMP CONTADOR1, 4         ; Bucle que introduce cada uno de los tres medios valores de ARRAYB 
		JE FUERAB2               ; en MATRIZB2 al llamar a la subrutina BUCLEB2. Carga el valor de la
		MOV SI, CONTADOR1        ; matriz que le toca en VALOR2.
		MOV AX, ARRAYB[SI]
		MOV VALOR2, AX
	    CALL BUCLEB2             ; Llama a subrutina BUCLEB2 (Linea 855)
		DEC CONTADOR1
		DEC CONTADOR1
		JMP INI_BUCLEB2          ; Salta a INI_BUCLEB2
		
		FUERAB2:                 ; * * * FUERAB2 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZB2
		MOV MATRIZB2[SI], 124    
		DEC CONTADOR2
		
		
		MOV CONTADOR2, 26        ; Introduce el simbolo igual (=) en MATRIZB2
		MOV SI, 21		         
		MOV MATRIZB2[SI], 61   
		   
		CALL BUCLEB_DET          ; Introduce el valor del determinante en MATRIZB2 al llamar a BUCLEB_DET (Linea 953)
		
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZB2  ; Imprime MATRIZA2 por pantalla
		MOV AH, 9 
		INT 21H
		
		
		; * * * * * * * MATRIZB3 * * * * * * * *
		MOV CONTADOR1, 16        ; Inicializamos los contadores 		
		MOV CONTADOR2, 20 
		
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al final de MATRIZB3
		MOV MATRIZB3[SI], 124    
		DEC CONTADOR2
		
		INI_BUCLEB3:             ; * * * INI_BUCLEB3 * * *
		CMP CONTADOR1, 10        ; Bucle que introduce cada uno de los tres ultimos valores de ARRAYB 
		JE FUERAB3               ; en MATRIZB3 al llamar a la subrutina BUCLEB3. Carga el valor de la
		MOV SI, CONTADOR1        ; matriz que le toca en VALOR2.
		MOV AX, ARRAYB[SI] 
		MOV VALOR2, AX
	    CALL BUCLEB3             ; Llama a subrutina BUCLEB3 (Linea 904)
		DEC CONTADOR1
		DEC CONTADOR1
		JMP INI_BUCLEB3          ; Salta a INI_BUCLEB3
		
		FUERAB3:                 ; * * * FUERAB3 * * *
		MOV SI, CONTADOR2		 ; Introduce el simbolo | al inicio de MATRIZB2
		MOV MATRIZB3[SI], 124    
		DEC CONTADOR2
		
		MOV AH, 2                ; Imprime un salto de linea por pantalla
		MOV DL, 10 
		INT 21H
	
		MOV DX, OFFSET MATRIZB3  ; Imprime MATRIZA3 por pantalla
		MOV AH, 9
		INT 21H
		
		
		RET                      ; Regresamos de la subrutina MATRIZA
		
	MATRIZB ENDP	
	

;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZB1
; BUCLEB1
;**************************************************************************
	BUCLEB1 PROC NEAR
	
		MOV FLAG, 0              ; Inicializamos FLAG a 0 
		MOV AX, 0
		ADD AX, VALOR2
		JS NEGATB                ; Salta a NEGATB si el valor es negativo
		VOLVERB:                 ; * * * VOLVERB * * *
		
		INICIO_BUCLEB:           ; * * * INICIO_BUCLEB * * *
		MOV AX, VALOR2           ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO            ; MATRIZB1.
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZB1[SI], AH
		MOV VALOR2, AX
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLEB
		JMP INICIO_BUCLEB        
		
		SALIR_BUCLEB:            ; * * * SALIR_BUCLEB * * *
		CMP FLAG, 1              ; Si FLAG ES 1 salta a SIGNO
		JE SIGNOB
		
		RETURNB:                 ; * * * RETURNB * * * 		
		MOV SI, CONTADOR2        ; Introduce el simbolo espacio ( ) en MATRIZB1
		MOV MATRIZB1[SI], 32    
		DEC CONTADOR2
		
		RET		                 ; Regresamos de la subrutina BUCLEB1
				
		NEGATB:                  ; * * * NEGATB * * *
		MOV FLAG, 1              ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR2
		JMP VOLVERB
		
		SIGNOB:                  ; * * * SIGNOB * * *
		MOV SI, CONTADOR2        ; Introduce el simbolo menos (-) en MATRIZB1
		MOV MATRIZB1[SI], 45    
		DEC CONTADOR2
		JMP RETURNB
		
	BUCLEB1 ENDP	
	
	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZB2
; BUCLEB2
;**************************************************************************
	BUCLEB2 PROC NEAR
	
		MOV FLAG, 0              ; Inicializamos FLAG a 0
		MOV AX, 0
		ADD AX, VALOR2
		JS NEGATB2               ; Salta a NEGATB2 si el valor es negativo
		VOLVERB2:                ; * * * VOLVERB2 * * *
		
		INICIO_BUCLEB2:          ; * * * INICIO_BUCLEB2 * * *
		MOV AX, VALOR2           ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO            ; MATRIZB2.
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZB2[SI], AH
		MOV VALOR2, AX
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLEB2
		JMP INICIO_BUCLEB2
		
		SALIR_BUCLEB2:          ; * * * SALIR_BUCLEB2 * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNOB2
		JE SIGNOB2
		
		RETURNB2:               ; * * * RETURNB2 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZB2
		MOV MATRIZB2[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEB2
				
		NEGATB2:                ; * * * NEGATB2 * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR2
		JMP VOLVERB2
		
		SIGNOB2:                ; * * * SIGNOB2 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZB2
		MOV MATRIZB2[SI], 45   
		DEC CONTADOR2
		JMP RETURNB2
		
	BUCLEB2 ENDP
	
	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL VALOR EN LA CADENA MATRIZB3
; BUCLEB3
;**************************************************************************
	BUCLEB3 PROC NEAR
	
		MOV FLAG, 0             ; Inicializamos FLAG a 0
		MOV AX, 0
		ADD AX, VALOR2
		JS NEGATB3              ; Salta a NEGATB3 si el valor es negativo
		VOLVERB3:               ; * * * VOLVERB3 * * *
		
		INICIO_BUCLEB3:         ; * * * INICIO_BUCLEB3 * * *
		MOV AX, VALOR2          ; Bucle que introduce las unidades ascii del valor pasado en la cadena
		DIV DIVIDENDO           ; MATRIZB3
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZB3[SI], AH
		MOV VALOR2, AX
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLEB3
		JMP INICIO_BUCLEB3
		
		SALIR_BUCLEB3:          ; * * * SALIR_BUCLEB3 * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNOB3
		JE SIGNOB3
		
		RETURNB3:               ; * * * RETURNB3 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZB3
		MOV MATRIZB3[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEA3
				
		NEGATB3:                ; * * * NEGATB3 * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del valor pasado
		NEG VALOR2
		JMP VOLVERB3
		 
		SIGNOB3:                ; * * * SIGNOB3 * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZB3
		MOV MATRIZB3[SI], 45   
		DEC CONTADOR2
		JMP RETURNB3
		
	BUCLEB3 ENDP
	
	
;**************************************************************************
; SUBRUTINA BUCLE PARA CONVERTIR DE DEC A ASCII E INTRODUCIR EL DETERMINANTE EN LA CADENA MATRIZB2
; BUCLEB_DET
;**************************************************************************
	BUCLEB_DET PROC NEAR
	
		MOV FLAG, 0             ; Inicializamos FLAG a 0 
		MOV AX, 0                
		ADD AX, DETERMINANTE
		JS NEGAT_DETB           ; Salta a NEGATB_DET si el determinante es negativo
		VOLVER_DETB:            ; * * * VOLVER_DETB * * * 
		
		MOV AX, DETERMINANTE    ; Primera iteracion antes del bucle
		DIV DIVIDENDO           ; Introduce las unidades ascii del determinante en la cadena MATRIZB2
		ADD AH, 48
		MOV SI, CONTADOR2
		MOV MATRIZB2[SI], AH
		MOV VALOR2, AX
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE_DETB
		
		INICIO_BUCLE_DETB:      ; * * * INICIO_BUCLE_DETB * * *
		MOV AX, VALOR2          ; Bucle que introduce las unidades ascii del determinante en la cadena
		DIV DIVIDENDO           ; MATRIZB2
		ADD AH, 48 
		MOV SI, CONTADOR2
		MOV MATRIZB2[SI], AH
		MOV VALOR2, AX
		DEC CONTADOR2
		CMP AL, 0
		JE SALIR_BUCLE_DETB
		JMP INICIO_BUCLE_DETB
		
		SALIR_BUCLE_DETB:       ; * * * SALIR_BUCLE_DETB * * *
		CMP FLAG, 1             ; Si FLAG es 1 salta a SIGNO_DETB
		JE SIGNO_DETB
		
		RETURN_DETB:            ; * * * RETURN_DETB * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo espacio ( ) en MATRIZB2
		MOV MATRIZB2[SI], 32    
		DEC CONTADOR2
		
		RET		                ; Regresamos de la subrutina BUCLEA_DETB
				
		NEGAT_DETB:             ; * * * NEGAT_DETB * * *
		MOV FLAG, 1             ; Pone el FLAG a 1 y realiza el complemento a dos del determinante
		NEG DETERMINANTE
		JMP VOLVER_DETB
		
		SIGNO_DETB:             ; * * * SIGNO_DETB * * *
		MOV SI, CONTADOR2       ; Introduce el simbolo menos (-) en MATRIZB2
		MOV MATRIZB2[SI], 45   
		DEC CONTADOR2
		JMP RETURN_DETB
		
	BUCLEB_DET ENDP	
	

INICIO ENDP 
	
; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END INICIO