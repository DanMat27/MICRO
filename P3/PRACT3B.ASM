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

	; * * * * * * _createBarCode * * * * * * *
	PUBLIC _createBarCode
	_createBarCode PROC FAR
		PUSH BP                  ; Guardamos BP en la pila 
		MOV BP, SP               ; Ponemos BP apuntando donde lo hace SP
		
		PUSH BX SI DX            ;Guardamos valores de registros importantes para recuperarlos antes de salir de la funcion
		 
		 
		 
		MOV AX, [BP + 6]         ; Cargamos el valor de countryCode en AX
		
		BUCLE_COUNTRY_CODE:      ; * * * * * BUCLE_COUNTRY_CODE * * * * *
		MOV DX, 10
		DIV DL                   ; Dividimos el valor de countryCode entre 10 para obtener cada digito en el cociente
		MOV DL, AL
		CMP AL, 0
	    MOV AL, AH
		MOV AH, 0
		PUSH AX
		MOV AL, DL
		JNE BUCLE_COUNTRY_CODE   ; Si el resto no es 0, repetimos el bucle BUCLE_COUNTRY_CODE
		
		
		
		MOV AX, [BP + 8]         ; Cargamos el valor de companyCode en AX
		
		BUCLE_COMPANY_CODE:      ; * * * * * BUCLE_COMPANY_CODE * * * * *
		MOV CX, 10               
		DIV CX                   ; Dividimos DX:AX entre 10 para obtener cada digito en el cociente
		CMP AX, 0
		PUSH DX
		MOV DX, 0
		JNE BUCLE_COMPANY_CODE   ; Si el resto no es 0, repetimos el bucle BUCLE_COMPANY_CODE
		
		
		
		MOV AX, [BP + 10]        ; Cargamos el valor de companyCode en AX	
		MOV DX, [BP + 12]        ; Cargamos el valor desbordado de companyCode en DX
		CMP DX, 1
		JE BUCLE_PRODUCT_CODE    ; Si DX es 1, entonces ya tiene overflow
		CMP AX, 270FH            ; Si es menor que 270F, el quinto digito es 0
		JLE QUINTO_DIGITO_CERO
		
		
		
		BUCLE_PRODUCT_CODE:      ; * * * * * BUCLE_PRODUCT_CODE * * * * *
		MOV CX, 10               
		DIV CX                   ; Dividimos DX:AX entre 10 para obtener cada digito en el cociente
		CMP AX, 0
		PUSH DX
		MOV DX, 0
		JNE BUCLE_PRODUCT_CODE   ; Si el resto no es 0, repetimos el bucle BUCLE_PRODUCT_CODE		
		JMP CONTROL_DIGIT
		
		
		
		QUINTO_DIGITO_CERO:      ; * * * * * QUINTO_DIGITO_CERO * * * * *
		MOV CX, 10               
		DIV CX                   ; Dividimos DX:AX entre 10 para obtener cada digito en el cociente
		CMP AX, 0
		PUSH DX
		MOV DX, 0
		JNE QUINTO_DIGITO_CERO   ; Si el resto no es 0, repetimos el bucle BUCLE_PRODUCT_CODE
		MOV AX, 0		
		PUSH AX                  ; Introducimos el quinto digito 0
		
		
		
		CONTROL_DIGIT:           ; * * * * * CONTROL_DIGIT  * * * * *
		MOV AX, [BP + 14]        ; Cargamos el valor de controlDigit en AX
		ADD AX, 30H              ; Pasamos el digito a ASCII
		LES BX, [BP + 16]        ; Accedemos a la memoria de la variable out_barCodeASCII
		MOV ES:[BX + 12], AL     ; Metemos el valor de controlDigit en el ultimo byte de la cadena out_barCodeASCII
		
		
		
		MOV SI, 6
		BUCLE_DIGITOS_1:         ; * * * * * BUCLE_DIGITOS_1 * * * * * 
		INC SI
		POP AX                   ; Recuperamos los 5 digitos del productCode
		ADD AX, 30H              ; Pasamos el digito a ASCII
		MOV ES:[BX + SI], AL     ; Metemos el valor de productCode en la cadena out_barCodeASCII	
		CMP SI , 11		
		JNE BUCLE_DIGITOS_1       
		
		
		
		MOV SI, 2
		BUCLE_DIGITOS_2:         ; * * * * * BUCLE_DIGITOS_2 * * * * * 
		INC SI
		POP AX                   ; Recuperamos los 4 digitos del companyCode
		ADD AX, 30H              ; Pasamos el digito a ASCII
		MOV ES:[BX + SI], AL     ; Metemos el valor de companyCode en la cadena out_barCodeASCII	
		CMP SI , 6		
		JNE BUCLE_DIGITOS_2
		
		
		
		MOV SI, 0
		BUCLE_DIGITOS_3:         ; * * * * * BUCLE_DIGITOS_3 * * * * * 
		POP AX                   ; Recuperamos los 4 digitos del countryCode
		ADD AX, 30H              ; Pasamos el digito a ASCII
		MOV ES:[BX + SI], AL     ; Metemos el valor de countryCode en la cadena out_barCodeASCII
		INC SI		
		CMP SI , 3		
		JNE BUCLE_DIGITOS_3
		
		
		
		MOV AL, 0;              
		MOV ES:[BX + 13], AL	 ; Introducimos el valor de fin de cadena al final de la cadena out_barCodeASCII	
		
		

		POP DX SI BX             ; Recuperamos los valores de los registros guardados
		
		POP BP                   ; Recuperamos el valor de BP para regresar 

		RET                      ; Regresamos de la funcion
	_createBarCode ENDP
	
; FIN DEL SEGMENTO DE CODIGO 
_TEXT ENDS 

END