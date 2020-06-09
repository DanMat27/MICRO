; *****************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;******************************************************************************
; INFO IMPORTANTE: p4a funciona correctamente para todos los casos descritos
; en la practica. La cadena para codificar y decodificar se pasara en DS:DX y, 
; por nuestra eleccion al no encontrar otra solucion, la tabla de Polibio se 
; pasa por ES:BX, al igual que la cadena anterior.
; Las cadenas decodificadas tienen los pares de digitos separados por espacios.
;******************************************************************************

CODIGO SEGMENT

	ASSUME CS:CODIGO, DS:CODIGO, SS:CODIGO

	ORG 100H

	INICIO:                             ; * * * * INICIO * * * *
	JMP MAIN                            ; Salta a MAIN (Linea 251)


	; Variables globales
	NOMBRESYGRUPO DB 10," Polibio de pareja 06: ",10,"  Daniel Mateo y Daniel Maza",10,"  Grupo 2211",'$'    ; Cadena con los nombres de la pareja y el grupo para imprimir por pantalla
	INSTRUCCIONES DB 10," Bienvenido.",10," Este programa permite instalar y desinstalar las rutinas e interrupciones",10," referentes a Polibio.",10," Para instalar los drivers, introduzca el argumento /I.",10," Para desinstalar los drivers, introduzca el argumento /D.",'$'     ; Cadena con la informacion para imprimir por pantalla
	ESTRELLAS DB 10,"**************************************************************************",'$'     ; Cadena de * por estilo al imprimir por pantalla
	ERRARG DB 10," Error de argumentos. Argumento no valido.",10," No introducir ninguno para ver informacion.",'$'    ; Cadena de error en los argumentos
	INSTA DB 10," Estado de instalacion: Instalado",'$'    ; Cadena con el estado de la instalacion Instalado
	DESINSTA DB 10," Estado de instalacion: No instalado",'$'    ; Cadena con el estado de la instalacion No instalado
	AUX DB 50 DUP (0)    ; Cadena auxiliar que se imprime por pantalla con la codificicacion  o decodificacion de la cadena pasada
	ERRINST DB 10," Error al instalar. Driver ya instalado.",'$'    ; Cadena de error en la instalacion	
	
	RSI_57H PROC FAR                    ; * * * RSI_57H * * *        
										; Rutina de servicio a la interrupción 57H													 
		CMP AH, 10H                     ; Comprobamos si AH = 10H para codificar la cadena
		JE IMPRIMIRC
		
		CMP AH, 11H                     ; Comprobamos si AH = 11H para deccodificar la cadena  
		JE IMPRIMIRD
		
		SALIDA:                         ; * * * * SALIDA * * * *
		IRET                            ; Regresamos de la rutina de atencion a la interrupcion 57H
		
		IMPRIMIRC:                      ; * * * * IMPRIMIRC * * * *
		CALL IMPRIMIRCOD                ; Llamamos a la subrutina de codificacion IMPRIMIRCOD
		JMP SALIDA
	
		IMPRIMIRD:                      ; * * * * IMPRIMIRD * * * *	
		CALL IMPRIMIRDECOD              ; Llamamos a la subrutina de decodificacion IMPRIMIRDECOD
		JMP SALIDA
			
	RSI_57H ENDP
	
	
	IMPRIMIRCOD PROC NEAR               ; * * * IMPRIMIRCOD * * *
			                            ; Rutina para imprimir la codificacion de una cadena normal								
		PUSH DI SI DX AX
		
		MOV DI,DX                       ; Inicializamos indices (DI = OFFSET CADENA PASADA)
		MOV SI,0                        ; (SI = 0)
		
		BUCLE:                          ; * * * * BUCLE * * * *
			MOV AH,DS:[DI]              ; Cargamos un caracter de la cadena
			CMP AH,'$'                  ; Comprobamos si es el fin de cadena
			JE FINALCOD                 ; Si lo es, salta a FINALCOD
			MOV AH,DS:[DI]              ; Cargamos un caracter de la cadena
			CMP AH,32                   ; Comprobamos si es el caracter espacio
			JE ESPA                     ; Si lo es, salta a ESPA
			CMP AH,65                   ; Comprobamos si es el caracter 'A'
			JE A                        ; Si lo es, salta a A
			CMP AH,66                   ; Comprobamos si es una de las otras letras 
			JAE COMPLETRA               ; Si lo es, salta a COMPLETRA
			JMP COMPNUMERO              ; Si no, es un numero, salta a COMPNUMERO
			RETORNO:                    ; * * * * RETORNO * * * *
			MOV AUX[SI], 32             ; Aniade el caracter espacio entre cada caracter codificado
			INC SI                      ; Incrementamos indice SI
			ESPA:                       ; * * * * ESPA * * * *
			INC DI                      ; Incrementamos indice DI
			JMP BUCLE                   ; Salta al inicio del bucle BUCLE

		
		FINALCOD:                       ; * * * * FINALCOD * * * * 
			MOV AUX[SI],'$'             ; Introducimos el fin de cadena a la cadena con la codificacion
			MOV DX, OFFSET AUX          ; Imprimimos la cadena con la codificacion
			MOV AH, 9
			INT 21H
		    POP AX DX SI DI
			RET                         ; Regresamos de la subrutina de codificacion

	
		A:                              ; * * * * A * * * *
			MOV AUX[SI],49              ; Introduce 1 en la cadena (Fila 1)
			INC SI 
			MOV AUX[SI],54              ; Introduce 6 en la cadena (Columna 6)
			INC SI
			JMP RETORNO                 ; Vuelve al bucle en RETORNO 
		
		Z:                              ; * * * * Z * * * *
			MOV AUX[SI],54              ; Introduce 6 en la cadena (Fila 6)
			INC SI 
			MOV AUX[SI],49              ; Introduce 1 en la cadena (Fila 1)
			INC SI
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
			
		COMPLETRA:		                ; * * * * COMPLETRA * * * *
			CMP AH, 71                  ; Compara si se encuentra en la Fila 2
			JBE FILA2                   ; Si es verdad, salta a FILA2
			CMP AH,77                   ; Compara si se encuentra en la Fila 3
			JBE FILA3                   ; Si es verdad, salta a FILA3
			CMP AH,83                   ; Compara si se encuentra en la Fila 4
			JBE FILA4                   ; Si es verdad, salta a FILA4
			CMP AH,89                   ; Compara si se encuentra en la Fila 5
			JBE FILA5                   ; Si es verdad, salta a FILA5
			CMP AH,90                   ; Compara si se encuentra en la Fila 6
			JE Z                        ; Si es verdad, es 'Z', entonces salta a Z
			JMP RETORNO                 ; Vuelve al bucle en RETORNO 
		
		FILA2:                          ; * * * * FILA2 * * * *
			MOV AUX[SI],50              ; Introduce 2 en la cadena (Fila 2)
			INC SI 
			MOV DH,66                   ; Calculamos la columna de la letra en la tabla de Polibio
			SUB AH,DH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII                    
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
		
		FILA3:                          ; * * * * FILA3 * * * *
			MOV AUX[SI],51              ; Introduce 3 en la cadena (Fila 3)
			INC SI
			MOV DH,72                   ; Calculamos la columna de la letra en la tabla de Polibio
			SUB AH,DH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII 
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
		
		FILA4:                          ; * * * * FILA4 * * * *
			MOV AUX[SI],52              ; Introduce 4 en la cadena (Fila 4)
			INC SI
			MOV DH,78                   ; Calculamos la columna de la letra en la tabla de Polibio
			SUB AH,DH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII 
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI	
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
		
		FILA5:                          ; * * * * FILA5 * * * *
			MOV AUX[SI],53              ; Introduce 5 en la cadena (Fila 5)
			INC SI
			MOV DH,84                   ; Calculamos la columna de la letra en la tabla de Polibio
			SUB AH,DH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII 
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI	
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
			
		COMPNUMERO:                     ; * * * * COMPNUMERO * * * *
			CMP AH, 53                  ; Compara si se encuentra en la Fila 1 o 6
			JAE FILA1                   ; Se encuentra en la Fila 1, salta a FILA1
			JMP FILA6                   ; Se encuentra en la Fila 6, salta a FILA6
			
		FILA1:                          ; * * * * FILA1 * * * *
			MOV AUX[SI],49              ; Introduce 1 en la cadena (Fila 1)
			INC SI
			MOV DH,53                   ; Calculamos la columna del numero en la tabla de Polibio
			SUB AH,DH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI	
			JMP RETORNO                 ; Vuelve al bucle en RETORNO
		
		FILA6:                          ; * * * * FILA6 * * * *
		    MOV AUX[SI],54              ; Introduce 6 en la cadena (Fila 6)
			INC SI
			MOV DH,48                   ; Calculamos la columna del numero en la tabla de Polibio
			SUB AH,DH
			INC AH
			INC AH
			ADD AH,48                   ; Pasamos la columna a ASCII
			MOV AUX[SI],AH              ; Introducimos el numero de columna en la cadena
			INC SI	
			JMP RETORNO                 ; Vuelve al bucle en RETORNO	
		
	IMPRIMIRCOD ENDP
		
		
		
		
	IMPRIMIRDECOD proc NEAR             ; * * * IMPRIMIRDECOD * * *      
                                        ; Rutina para imprimir la descodificacion de una cadena en Polibio	
	    PUSH DI SI DX AX CX BX

		MOV DI, DX                      ; Inicializamos indices (DI = OFFSET CADENA PASADA)
		MOV SI, 0                       ; (SI = 0)
		MOV CX, 0                       ; (CX = 0)
		
		BUCLEDEC:                       ; * * * * BUCLEDEC * * * *
			MOV AH, DS:[DI]             ; Cargamos el caracter de Polibio
			CMP AH,'$'                  ; Comprobamos si es el fin de cadena
			JE FINALDECOD               ; Si lo es, salta a FINALDECOD
			CMP AH, 32                  ; Comprobamos si es un espacio 
			JE ESPACIO                  ; Si lo es, salta a ESPACIO
			JMP PRIMER_DIGITO           ; Salta para tratar el primer digito
			PD:                         ; * * * * PD * * * *
			INC DI                      ; Incrementamos el indice DI                   
			MOV AH, DS:[DI]             ; Cargamos el segundo digito de Polibio
			JMP SEGUNDO_DIGITO          ; Salta para tratar el segundo digito      
			ESPACIO:                    ; * * * * ESPACIO * * * * 
			INC DI                      ; Incrementamos el indice DI
			JMP BUCLEDEC                ; Regresa al inicio del bucle BUCLEDEC
		
		FINALDECOD:                     ; * * * * FINALDECOD * * * *
			MOV AUX[SI],'$'             ; Introducimos el fin de cadena a la cadena con la decodificacion
			MOV DX, OFFSET AUX          ; Imprimimos la cadena con la decodificacion
			MOV AH, 9
			INT 21H
			POP BX CX AX DX SI DI
			RET                         ; Regresamos de la subrutina de decodificacion
		
		PRIMER_DIGITO:                  ; * * * * PRIMER_DIGITO * * * *
			SUB AH, 49                  ; Lo pasamos a ASCCI y restamos 1 para que sea indice
			MOV DH, AH                  ; Movemos el primer digito a DH
			JMP PD                      ; Regresamos al bucle en PD 
			
		SEGUNDO_DIGITO:                 ; * * * * SEGUNDO_DIGITO * * * * 
			MOV CX, DI                  ; Guardamos indice DI en CX ya que lo necesitamos aqui
			SUB AH, 49                  ; Lo pasamos a ASCCI y restamos 1 para que sea indice
			MOV DL, AH                  ; Guardamos el segundo digito en DL
			MOV AL, 6                   ; Movemos 6 a AL (6 caracteres por fila)
			MUL DH                      ; Multiplicamos 6*(numero de fila-1)
			ADD AL, DL                  ; Le sumamos (numero de columna-1) al resultado anterior
			MOV DI, AX                  ; Movemos el indice resultado anterior a DI
			ADD DI, BX                  ; Le sumamos a DI el offset de la cadena con la tabla de Polibio pasada en ES:BX
			MOV AH, ES:[DI]             ; Obtenemos el caracter equivalente y aniadimos a la cadena con la decodificacion
			MOV AUX[SI], AH             ; Aniadimos a la cadena con la decodificacion el caracter anterior
			INC SI                      ; Incrementamos el indice SI
			MOV DI, CX                  ; Recuperamos indice DI
			JMP ESPACIO                 ; Regresamos al bucle en ESPACIO
		
	IMPRIMIRDECOD endp
	
	
	
	MAIN:                               ; * * * * MAIN * * * *
	                                    ; Rutina principal del programa
		MOV AH, DS:[80H]
		CMP AH, 0                       ; Comprobamos si no hay argumentos
		JE IMPRIMIR_DATOS               ; Si no, salta a IMPRIMIR_DATOS
		
		MOV AH, DS:[82H]
		CMP AH, 47                      ; Comprobamos si coincide con /
		JNE FIN
		MOV AH, DS:[83H]
		CMP AH, 73                      ; Comprobamos si coincide con /I 
		JE INSTALAR
		CMP AH, 68                      ; Comprobamos si coincide con /D 
		JE DESINSTALAR
	
		MOV DX, OFFSET ERRARG           ; Imprime el error de argumentos por pantalla
		MOV AH, 9
	    INT 21H
		
		JMP FIN                         ; Salta a FIN 
		
		
	INSTALAR:	                        ; * * * * INSTALAR * * * *
		CALL INSTALADOR_57H             ; Llamamos a la rutina de instalacion
		JMP FIN
		
	DESINSTALAR:	                    ; * * * * DESINSTALAR * * * *
		CALL DESINSTALADOR_57H          ; Llamamos a la rutina de desinstalacion
		JMP FIN
		
		
	IMPRIMIR_DATOS:	                    ; * * * * IMPRIMIR_DATOS * * * *
	                                    ; Etiqueta referente al codigo de impresion de informacion por pantalla
		MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)
		MOV AH, 9
	    INT 21H	
	
		MOV DX, OFFSET INSTRUCCIONES    ; Imprime la informacion de uso del programa por pantalla
		MOV AH, 9
	    INT 21H
		
		MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)
		MOV AH, 9
	    INT 21H
	
		MOV DX, OFFSET NOMBRESYGRUPO    ; Imprime los datos de la pareja y grupo por pantalla
		MOV AH, 9
	    INT 21H	
			
		MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)
		MOV AH, 9
	    INT 21H
		
		MOV AX, 0
		MOV ES, AX
		MOV DI, ES:[57H*4 + 2]
		CMP DI, 0
		JNE INSTALADO
		
		MOV DX, OFFSET DESINSTA         ; Imprime que el driver no esta instalado por pantalla
		MOV AH, 9
	    INT 21H
		
		MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)
		MOV AH, 9
	    INT 21H
		
		JMP FIN
		
		INSTALADO:                      ; * * * * INSTALADO * * * *
		MOV DX, OFFSET INSTA            ; Imprime que el driver ya esta instalado por pantalla
		MOV AH, 9
	    INT 21H
		
		MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)
		MOV AH, 9
	    INT 21H
		
	FIN:                                ; * * * * FIN * * * *
	    MOV AX, 4C00H                   ; Fin del programa
	    INT 21H
	
	
	INSTALADOR_57H PROC                 ; * * * INSTALADOR_57H * * *
		                                ; Instalador de los drivers	
		MOV AX, 0
		MOV ES, AX
		MOV DI, ES:[57H*4 + 2]
		CMP DI, 0
		JNE ERRI
										
		MOV AX, OFFSET RSI_57h
		MOV BX, CS

		CLI
		MOV ES:[57H*4], AX              ; Guardamos segmento y offset de la rutina de atencion a la interrupcion 57H
		MOV ES:[57H*4 + 2], BX
		STI
	
		MOV DX, OFFSET INSTALADOR_57H
		INT 27H                         ; Acaba y deja residente
									    ; PSP, variables y rutina RSI_57H
										
		ERRI:                           ; * * * * ERRI * * * *
		MOV DX, OFFSET ERRINST          ; Imprime el error de instalacion por pantalla
		MOV AH, 9
	    INT 21H
		
		MOV AX, 4C00H                   ; Fin del programa
	    INT 21H                        
	
	INSTALADOR_57H ENDP


	
	DESINSTALADOR_57H PROC              ; * * * DESINSTALADOR_57H * * *
	                                    ; Desinstalador de los drivers
										
		PUSH AX BX DX CX DI ES DS
						
		MOV CX, 0
		MOV DS, CX
		MOV DI, DS:[57H*4 + 2]
		CMP DI, 0
		JE RETURN
						
		MOV ES, DI
		MOV BX, ES:[2CH]
		
		MOV AH, 49H
		INT 21H
		MOV ES, BX
		INT 21H
		
		CLI
		MOV DS:[57H*4], CX              ; Ponemos a 0 el vector de interrupcion 57H
		MOV DS:[57H*4 + 2], CX
		STI
		
		RETURN:                         ; * * * * RETURN * * * *
		POP DS ES DI CX DX BX AX   	
		RET
										    
	DESINSTALADOR_57H ENDP
	
	
	
CODIGO ENDS
END INICIO 