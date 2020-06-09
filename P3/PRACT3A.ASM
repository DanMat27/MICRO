; *************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 
;**************************************************************************  

; DEFINICION DEL SEGMENTO DE CODIGO 
_TEXT SEGMENT BYTE PUBLIC 'CODE'
ASSUME CS: _TEXT

		
	; * * * * * * _computerControlDigit * * * * * *
	PUBLIC _computeControlDigit
	_computeControlDigit PROC FAR
		PUSH BP               ; Guardamos BP en la pila 
		MOV BP, SP            ; Ponemos BP apuntando donde lo hace SP
		
		PUSH BX SI DX         ;Guardamos valores de registros importantes para recuperarlos antes de salir de la funcion
		
		LES BX, [BP + 6]      ; Guardamos en ES el segmento del parametro
							  ; En BX guardamos el OFFSET del parametro
							  
		
		MOV AX, 0			  ; Bucle para sumar los dígitos impares de la cadena -> A1
		MOV DX, 0
		MOV SI, 0             ; Inicia en el primer byte impar
		INICIO_BUCLE1:        ; * * * * * INICIO_BUCLE1 * * * * *
		MOV AL, ES:[BX + SI] 	  
		SUB AL, 30H           ; Convertimos el caracter ASCII a hexadecimal
		ADD DX, AX            ; Guardamos la suma en DX 
		INC SI                ; Aumentamos en dos el contador SI
		INC SI
		CMP SI, 12            ; Comparamos el contador con el byte impar siguiente al ultimo de la cadena
		JNE INICIO_BUCLE1     ; Salta a INICIO_BUCLE1 si no son iguales
		
		PUSH DX               ; Guardamos el valor de A1 en la pila para despues 
		
		
		MOV AX, 0			  ; Bucle para sumar los dígitos pares multiplicados por 3 de la cadena -> A2
		MOV DX, 0
		MOV SI, 1             ; Inicia en el primer byte par
		INICIO_BUCLE2:		  ; * * * * * INICIO_BUCLE2 * * * * *
		MOV AL, ES:[BX + SI]     
		SUB AL, 30H           ; Convertimos el caracter ASCII a hexadecimal
		MOV AH, 3
		MUL AH                ; Multiplicamos el digito par por 3
		MOV AH, 0
		ADD DX, AX			  ; Guardamos la suma en DX 
		INC SI                ; Aumentamos en dos el contador SI
		INC SI
		CMP SI, 13            ; Comparamos el contador con el byte par siguiente al ultimo de la cadena
		JNE INICIO_BUCLE2     ; Salta a INICIO_BUCLE2 si no son iguales
		
		POP AX
		ADD DX, AX            ; Sumamos el valor de A1 en la pila al obtenido en A2	 -> B		 		
		PUSH DX               ; Volvemos a guardar el valor de DX, obtenido en B, en la pila para despues	
		
		
		MOV AX, 0			  ; Bucle para calcular el numero de la decena superior -> C
		INICIO_BUCLE3:        ; * * * * * INICIO_BUCLE3 * * * * *
		ADD DX, 1             ; Sumamos 1 al valor obtenido en B en cada iteracion
		MOV AX, DX            ; Movemos el valor anterior a AX para dividirlo despues
		PUSH DX
		MOV DX, 10            ; Cargamos el valor 10 en el registro DX 
		DIV DL
		POP DX
		CMP AH, 0
		JNE INICIO_BUCLE3     ; Si el resto no es 0, salta al inicio
		
		POP AX                ; Recuperamos el valor obtenido en B
		SUB DX, AX            ; Restamos los valores obtenidos en C y B -> D
		
		MOV AX, DX            ; Digito obtenido se guarda en AX para el retorno de la funcion
		
		POP DX SI BX          ; Recuperamos los valores de los registros guardados
		
		POP BP                ; Recuperamos el valor de BP para regresar
		
		RET					  ; Regresamos de la funcion
	_computeControlDigit ENDP	
	
	
	
	; * * * * * * _decodeBarCode * * * * * * *
	PUBLIC _decodeBarCode
	_decodeBarCode PROC FAR
		PUSH BP                    ; Guardamos BP en la pila 
		MOV BP, SP                 ; Ponemos BP apuntando donde lo hace SP
		 
		PUSH BX SI DX              ; Guardamos valores de registros importantes para recuperarlos antes de salir de la funcion
		
		LES BX, [BP + 6]           ; Guardamos en ES el segmento del parametro in_barCodeASCII
							       ; En BX guardamos el OFFSET del parametro in_barCodeASCII
		 
		 
		 
		MOV AX, 0
		MOV DX, 0
		MOV SI, 0
		BUCLE_LECTURA_BARCODE:     ; * * * * * BUCLE_LECTURA_BARCODE * * * * *
		MOV AL, ES:[BX + SI] 
		SUB AL, 30H                ; Convertimos el digito leido en ASCII a hexadecimal 
		PUSH AX                    ; Añadimos cada digito de in_barCodeASCII en la pila para despues 
		INC SI
		CMP SI, 13                 ; Comparamos si ya se han leido los digitos
		JNE BUCLE_LECTURA_BARCODE  ; Si no, salta al inicio del bucle de lectura
		
		
		
		                           ; * * * * * COUNTRYCODE * * * * * 
		LES BX, [BP + 10]          ; Guardamos en ES el segmento del parametro countryCode
								   ; En BX guardamos el OFFSET del parametro countryCode
		MOV AX, 0
		MOV DX, 0
		MOV SI, 0	
		MOV AL, [BP - 8]		   ; Cargamos el primer digito en AL
		MOV DX, 100                ; Cargamos el valor 100 en el registro DX 
		MUL DL                     ; Multiplicamos AX por 100
		PUSH AX                    ; Guardamos el dato 0X00d en la pila

		MOV AL, [BP - 10]		   ; Cargamos el segundo digito en AL
		MOV DX, 10                 ; Cargamos el valor 10 en el registro DX 
		MUL DL					   ; Multiplicamos AX por 10
		POP DX                     ; Cargamos el valor anterior 0X00d
		ADD DX, AX                 ; Obtenemos el valor 0XX0d en DX
	
		MOV AL, [BP - 12]		   ; Cargamos el tercer digito en AL
		ADD DX, AX                 ; Obtenemos el valor del countryCode, que es 0XXXd
		
		MOV ES:[BX], DX            ; Guardamos el valor en la variable countryCode
		
		
		
								   ; * * * * * COMPANYCODE * * * * * 
		LES BX, [BP + 14]          ; Guardamos en ES el segmento del parametro companyCode
								   ; En BX guardamos el OFFSET del parametro companyCode	
		MOV AX, 0
		MOV DX, 0
		MOV SI, 0	
		MOV AL, [BP - 14]		   ; Cargamos el cuarto digito en AL
		MOV DX, 1000               ; Cargamos el valor 1000 en el registro DX 
		MUL DX                     ; Multiplicamos AX por 1000
		PUSH AX                    ; Guardamos el dato X000d en la pila
		
		MOV AX, 0
		MOV AL, [BP - 16]		   ; Cargamos el quinto digito en AL
		MOV DX, 100                ; Cargamos el valor 100 en el registro DX 
		MUL DX					   ; Multiplicamos AX por 100
		POP DX                     ; Cargamos el valor anterior X000d
		ADD DX, AX                 ; Obtenemos el valor XX00d en DX sumando el valor de AX
		PUSH DX                    ; Guardamos el dato XX00d en la pila				
		
		MOV AX, 0
		MOV AL, [BP - 18]		   ; Cargamos el sexto digito en AL
		MOV DX, 10                 ; Cargamos el valor 10 en el registro DX 
		MUL DX					   ; Multiplicamos AX por 10
		POP DX                     ; Cargamos el valor anterior XX00d
		ADD DX, AX                 ; Obtenemos el valor XXX0d en DX	

		MOV AX, 0
		MOV AL, [BP - 20]		   ; Cargamos el septimo digito en AL
		ADD DX, AX                 ; Obtenemos el valor del companyCode, que es XXXXd
		
		MOV ES:[BX], DX            ; Guardamos el valor en la variable companyCode
		
		
						
								   ; * * * * * PRODUCTCODE * * * * * 
		LES BX, [BP + 18]          ; Guardamos en ES el segmento del parametro companyCode
								   ; En BX guardamos el OFFSET del parametro companyCode	
		MOV AX, 0
		MOV DX, 0
		MOV SI, 0	
		MOV AL, [BP - 22]		   ; Cargamos el octavo digito en AL
		MOV DX, 10000              ; Cargamos el valor 10000 en el registro DX 
		MUL DX                     ; Multiplicamos AX por 10000
		PUSH DX					   ; Guardamos el dato X0000d en la pila (overflow)
		PUSH AX                    ; Guardamos el dato X0000d en la pila (overflow)
		
		MOV AX, 0
		MOV AL, [BP - 24]		   ; Cargamos el noveno digito en AL
		MOV DX, 1000               ; Cargamos el valor 1000 en el registro DX 
		MUL DX                     ; Multiplicamos AX por 1000
		POP DX                     ; Recogemos el valor del AX anterior (no el de overflow)
		ADD AX, DX                 ; Obtenemos el valor X000d sumando AX y DX
		PUSH AX                    ; Guardamos el dato X000d en la pila 				
			
		MOV AX, 0			
		MOV AL, [BP - 26]		   ; Cargamos el decimo digito en AL
		MOV DX, 100                ; Cargamos el valor 100 en el registro DX 
		MUL DX                     ; Multiplicamos AX por 100
		POP DX                     ; Recogemos el valor del AX anterior (no el de overflow)
		ADD AX, DX                 ; Obtenemos el valor XX00d sumando AX y DX
		PUSH AX                    ; Guardamos el dato XX00d en la pila 		

		MOV AX, 0
		MOV AL, [BP - 28]		   ; Cargamos el undecimo digito en AL
		MOV DX, 10                 ; Cargamos el valor 10 en el registro DX 
		MUL DX                     ; Multiplicamos AX por 10
		POP DX                     ; Recogemos el valor del AX anterior (no el de overflow)
		ADD DX, AX                 ; Obtenemos el valor XXX0d sumando AX y DX	
		
		MOV AX, 0
		MOV AL, [BP - 30]		   ; Cargamos el duodecimo digito en AL
		ADD DX, AX                 ; Obtenemos el valor XXXXd del procuctCode (sin el valor de overflow)
		POP AX                     ; Recuperamos el valor de overflow de la pila 
		
		MOV ES:[BX + 2], AX 
		MOV ES:[BX], DX            ; Guardamos el valor en la variable productCode
				
						
						
								   ; * * * * * CONTROLDIGIT * * * * * 
		LES BX, [BP + 22]          ; Guardamos en ES el segmento del parametro controlDigit
								   ; En BX guardamos el OFFSET del parametro controlDigit
		MOV AX, 0
		MOV AL, [BP - 32]		   ; Cargamos el decimotercer digito en AL					
		MOV ES:[BX], AX            ; Guardamos el valor en la variable controlDigit
					
					
					
		MOV SI, 0                  
		BUCLE_POP:                 ; * * * * * BUCLE_POP * * * * * 
		INC SI                     ; Bucle para hace pop de los 13 digitos introducidos en la pila en BUCLE_LECTURA
		POP AX                     
		CMP SI, 13
		JNE BUCLE_POP
		
		POP DX SI BX               ; Recuperamos los valores de los registros guardados
		
		POP BP                     ; Recuperamos el valor de BP para regresar

		RET                        ; Regresamos de la funcion
	_decodeBarCode ENDP

; FIN DEL SEGMENTO DE CODIGO 
_TEXT ENDS 

END