; *************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;**************************************************************************
; INFO IMPORTANTE: Para que p4c funcione correctamente es necesario haber
; ejecutado p4a e instalado la interrupcion 57H (> p4a /I). La cadena para
; decodificar debe introducirse con un espacio entre los pares de digitos.
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 

	POLIBIO_PANTALLA DB 10,"     1 2 3 4 5 6",10,"     - - - - - -",10," 1 | 5 6 7 8 9 A",10," 2 | B C D E F G",10," 3 | H I J K L M",10," 4 | N O P Q R S",10," 5 | T U V W X Y",10," 6 | Z 0 1 2 3 4",'$'   ; Tabla de Polibio que se imprimira por pantalla
	INFO_COD DB 10," Se va a codificar el mensaje predefinido: ",'$'     ; Cadena con informacion de lo que se va a realizar (codificar)
	INFO_DECOD DB 10," Se va a decodificar el mensaje predefinido: ",'$'     ; Cadena con informacion de lo que se va a realizar (decodificar)
	ESTRELLAS DB 10,"**************************************************************************",'$'     ; Cadena de * por estilo al imprimir por pantalla
	INFO_POLIBIO DB 10,"La tabla de Polibio a utilizar es:",'$'     ; Cadena con informacion de la tabla para imprimir por pantalla
	CODI DB 10," Codificacion obtenida: ",'$'     ; Cadena con informacion introductoria para imprimir por pantalla
	DECODI DB 10," Decodificacion obtenida: ",'$'     ; Cadena con informacion introductoria para imprimir por pantalla
	INFO DB 10,"Introduce una de las instrucciones siguientes: cod, decod o quit.",'$'
	ERRORINS DB 10,"Instruccion introducida invalida",'$'
	CADENA DB 60 DUP (0)    ; Cadena con la instruccion leida por pantalla
	CADENA2 DB 60 DUP (0)
	AUXI DB ?    ; Cadena con la cadena para codificar o decodificar
	
DATOS ENDS
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE PILA 
PILA SEGMENT STACK "STACK" 

PILA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO EXTRA 
EXTRA SEGMENT 
	POLIBIO DB "56789ABCDEFGHIJKLMNOPQRSTUVWXYZ01234",'$'     ; Tabla de Polibio de la que sacar los caracteres de la decodificiacion
EXTRA ENDS 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE CODIGO 
CODE SEGMENT 
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA 


INICIO PROC

	MOV AX, DATOS 
	MOV DS, AX 
	MOV AX, PILA 
	MOV SS, AX 
	MOV AX, EXTRA 
	MOV ES, AX 
	MOV SP, 64 
	
	MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)        
	MOV AH, 9
	INT 21H

	MOV DX, OFFSET INFO_POLIBIO     ; Imprime informacion sobre la tabla de Polibio
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET POLIBIO_PANTALLA ; Imprime la tabla de Polibio por pantalla
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)   
	MOV AH, 9
	INT 21H
	
	BUCLE:                          ; * * * * BUCLE * * * *
	
	MOV DX, OFFSET INFO             ; Imprime cadena con informacion de las instrucciones posibles a elegir  
	MOV AH, 9
	INT 21H
	
	MOV AH, 2                       ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	MOV AH,0AH                      ; Lee por teclado la opcion introducida 
	MOV DX,OFFSET CADENA 
	MOV CADENA[0],60 
	INT 21H 

	CALL INSTRUC                    ; Comprobamos que argumento es y devuelve un numero en DX que lo indica
	CMP DX, 0
	JE INVALIDO
	CMP DX, 1
	JE CODIFICAR
	CMP DX, 2
	JE DECODIFICAR
	CMP DX, 3
	JE FIN	
	
	
	INVALIDO:                       ; * * * * INVALIDO * * * *
	MOV DX, OFFSET ERRORINS         ; Imprime cadena con error de instruccion
	MOV AH, 9
	INT 21H
	
	JMP ITERAR                      ; Volvemos al inicio del bucle en ITERAR
	
	
	CODIFICAR:                      ; * * * * CODIFICAR * * * *
	MOV AH, 2                       ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	CALL LEER_CADENA_COD            ; Llamamos LEER_CADENA_COD para leer la cadena por pantalla
	
	MOV DX, OFFSET AUXI             ; Movemos el offset de la cadena a DX ya que debe estar en DS:DX
	
	MOV AH, 10H                     ; Llamamos a la interrupcion 57H tras instalarla en p4a (10H = Codificar)
	INT 57H
	
	MOV AH, 2                       ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	MOV DX, OFFSET AUXI             ; Imprimimos la cadena codificada            
	MOV AH, 9
	INT 21H
	
	JMP ITERAR                      ; Volvemos al inicio del bucle en ITERAR
	
	
	DECODIFICAR:                    ; * * * * DECODIFICAR * * * *
	MOV AH, 2                       ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	CALL LEER_CADENA_DECOD          ; Llamamos LEER_CADENA_DECOD para leer la cadena por pantalla
	
	MOV BX, OFFSET POLIBIO          ; Movemos el offset de la tabla de Polibio a BX para que este en ES:BX
	MOV DX, OFFSET AUXI             ; Movemos el offset de la cadena a DX ya que debe estar en DS:DX
	
	MOV AH, 11H                     ; Llamamos a la interrupcion 57H tras instalarla en p4a (11H = Decodificar)
	INT 57H
	
	MOV AH, 2                       ; Imprime un salto de linea por pantalla
	MOV DL, 10 
	INT 21H
	
	MOV DX, OFFSET AUXI             ; Imprimimos la cadena decodificada   
	MOV AH, 9
	INT 21H
	
	
	ITERAR:                         ; * * * * ITERAR * * * *
	JMP BUCLE                       ; Salta al inicio del bucle BUCLE
	
	
	FIN:                            ; * * * * FIN * * * *
	MOV AX, 4C00H                   ; Fin del programa
	INT 21H
	
INICIO ENDP 
	
	
INSTRUC PROC NEAR                   ; * * * INSTRUC * * *
									; Idenfifica el tipo de instruccion indicada a llevar a cabo.
	PUSH SI
	
	MOV SI, 3

	CMP CADENA[2], 'c'          
	JE COD
	CMP CADENA[2], 'd'
	JE DECOD
	CMP CADENA[2], 'q'
	JE QUIT
	ERRI:
	MOV DX, 0
	JMP VOLVER 
	
	COD:                            ; * * * * COD * * * *
	CMP CADENA[SI], 'o'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 'd'
	JNE ERRI
	MOV DX, 1
	JMP VOLVER
	
	
	DECOD:                          ; * * * * DECOD * * * * 
	CMP CADENA[SI], 'e'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 'c'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 'o'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 'd'
	JNE ERRI
	MOV DX, 2
	JMP VOLVER


	QUIT:                          ; * * * * QUIT * * * * 
	CMP CADENA[SI], 'u'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 'i'
	JNE ERRI
	INC SI
	CMP CADENA[SI], 't'
	JNE ERRI
	MOV DX, 3
	JMP VOLVER
	

	VOLVER:                         ; * * * * VOLVER * * * *
	POP SI
	RET
	
INSTRUC ENDP
	
	
LEER_CADENA_COD PROC NEAR           ; * * * LEER_CADENA_COD * * * 
									; Lee la cadena introducida por teclado y la introduce en AUXI para codificar
	PUSH SI AX DI

	MOV AH,0AH                      ; Lee por teclado la cadena 
	MOV DX,OFFSET CADENA2
	MOV CADENA2[0],60 
	INT 21H 
	
	MOV SI, 2 
	MOV DI, 0
	MOV DX, 0
	
	BUCLE_COD:                      ; * * * * BUCLE_COD * * * *
	MOV AL, CADENA2[SI]
	CMP AL, 0 
	JE FIN_COD
	MOV AUXI[DI], AL
	INC SI
	INC DI
	JMP BUCLE_COD                   ; Volvemos al inicio del bucle BUCLE_COD
	
	
	FIN_COD:                        ; * * * * FIN_COD * * * *
	MOV AUXI[DI], '$'               ; Aniadimos el final a la cadena AUXI
	
	POP DI AX SI
	RET

LEER_CADENA_COD ENDP


LEER_CADENA_DECOD PROC NEAR         ; * * * LEER_CADENA_DECOD * * *
									; Lee la cadena introducida por teclado y la introduce en AUXI para decodificar
	PUSH SI AX DI

	MOV AH,0AH                      ; Lee por teclado la cadena 
	MOV DX,OFFSET CADENA2
	MOV CADENA2[0],60 
	INT 21H 
	
	MOV SI, 2                        ; Iniciamos indices
	MOV DI, 0
	MOV DX, 0
	
	BUCLE_DECOD:                     ; * * * * BUCLE_DECOD * * * *
	MOV AL, CADENA2[SI]              ; Leemos primer digito del par
	MOV AUXI[DI], AL
	INC SI
	INC DI
	MOV AL, CADENA2[SI]              ; Leemos segundo digito del par
	MOV AUXI[DI], AL
	INC SI
	INC DI
	MOV AL, CADENA2[SI]              ; Leemos el valor del caracter tras el par	
	MOV AUXI[DI], 32                 ; Introducimos el caracter de espacio en la cadena entre los pares de digitos
	INC SI
	INC DI
	CMP AL, 0                        ; Comprobamos si es 0, por lo que terminaria el bucle
	JE FIN_DECOD
	JMP BUCLE_DECOD                  ; Volvemos al inicio del bucle BUCLE_DECOD
	
	 
	FIN_DECOD:                       ; * * * * FIN_DECOD * * * *
	MOV AUXI[DI], '$'                ; Aniadimos el final a la cadena AUXI
	
	 
	POP DI AX SI
	RET
LEER_CADENA_DECOD ENDP


CODE ENDS 
END INICIO	