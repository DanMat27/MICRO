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

	;-- rellenar con los datos solicitados 
	
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
	
	
	MOV AX, 15H 	  ; a-1) Movemos el valor 15h en el registro AX
	
	MOV BX, 0BBH      ; a-2) Movemos el valor BBh al registro BX
	
	MOV CX, 3412H 	  ; a-3) Movemos el valor 3412h en el registro CX
	
	MOV DX, CX		  ; a-4) Movemos el contenido del registro CX al registro DX
	
	MOV AX, 6500H     ; a-5) Movemos el valor 6500h en el registro AX
	MOV DS, AX        ; Movemos el contenido del registro AX al registro de segmento DS 
	MOV BH, DS:[536H] ; Movemos el contenido del registro de segmento DS con un offset de 536h en el registro BH
	MOV BL, DS:[537H] ; Movemos el contenido del registro de segmento DS con un offset de 537h en el registro BL
	
	MOV AX, 5000H     ; a-6) Movemos el valor 5000h en el registro AX
	MOV DS, AX        ; Movemos el contenido del registro AX al registro de segmento DS 
	MOV DS:[05H], CH  ; Movemos el contenido del registro CH en el registro de segmento DS con un offset de 5h 
	
	MOV AX, [SI]      ; a-7) Movemos el valor de la direccion del Source Index SI en el registro AX
	
	MOV BX, [BP + 10] ; a-8) Movemos el valor de la direccion 10 posiciones más del Base Pointer BP en el registro BX
	
	
	; FIN DEL PROGRAMA 
	MOV AX, 4C00H 
	INT 21H 
INICIO ENDP 
; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END INICIO