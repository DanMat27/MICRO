; *************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;************************************************************************** 
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR 
;************************************************************************** 
; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 

	CONTADOR DB ?                                     ; b-1) Reservamos memoria para una variable de 1B sin inicializar llamada CONTADOR
	TOME DW 0CAFEH                                    ; b-2) Reservamos memoria para una variable de 2B con valor CAFEH llamada TOME
	TABLA100 DB 100 DUP (?) 			              ; b-3) Reservamos memoria para una tabla de 100B sin inicializar llamada TABLA100
	ERROR1 DB "Atencion: Entrada de datos incorrecta" ; b-4) Reservamos memoria para una string inicializada llamada ERROR1
	
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
	
	
	; b-1) Comprobacion de que CONTADOR se reservo bien -> goto ds:0
	; b-2) Comprobacion de que TOME se reservó bien -> goto ds:1
	; b-3) Comprobacion de que TABLA100 se reservo bien -> goto ds:3
	; b-4) Comprobacion de que ERROR1 se reservo bien -> goto ds:67
	
	MOV AH, ERROR1[2]       ; b-5) Movemos el byte de la posicion 2 del string ERROR1 al registro AH
	MOV TABLA100[63H], AH   ; Movemos el valor del registro AH a la posicion 63H de la tabla TABLA100
			                ; 63H = 99, Comprobacion con -> mov AL, TABLA100[63H] 
	            
	MOV AX, TOME	        ; b-6) Movemos el valor de TOME al registro AX
	MOV TABLA100[23H], AH   ; Movemos el byte mas significativo de AX a la posicion 23H de TABLA100
	MOV TABLA100[24H], AL   ; Movemos el byte menos significativo de AX a la posición 24H de TABLA100
	
	MOV AX, TOME            ; B-7) Movemos el valor de TOME al registro AX
	MOV CONTADOR, AH        ; Movemos el byte mas significativo de AX a la variable CONTADOR
			                ; Comprobacion con -> mov BH, CONTADOR o goto ds:1
	
	
	; FIN DEL PROGRAMA 
	MOV AX, 4C00H 
	INT 21H 
INICIO ENDP 
; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END INICIO