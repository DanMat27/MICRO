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
	
	
	MOV AX, 0535H      ; Cargamos el valor 0535H en el registro AX
	MOV DS, AX         ; Movemos el valor anterior de AX al DS para que empiece en ese valor el segmento
	MOV BX, 0210H      ; Cargamos el valor 0210H en el registro BX
	MOV DI, 1011H      ; Cargamos el valor 1011H en el registro DI
   
	MOV AL, DS:[1234H] ; c-a) Accedemos al registro de segmento DS con un offset de 1234H y movemos el resultado al registro AL
	                   ; Se puede comprobar el funcionamiento viendo el valor en goto ds:1234H y el de AL tras la instruccion
					   ; Direccion real de memoria accedida = 0535Hx10H + 1234H = 06584H
	MOV AX, [BX]       ; c-b) Accedemos al contenido de la direccion de memoria desde DS a un offset igual a BX=0210H
                       ; Se puede comprobar el funcionamiento viendo el valor en goto ds:0210H y el de AX tras la instruccion
					   ; Direccion real de memoria accedida = 0535Hx10H + 0210H = 05560H
	MOV [DI], AL       ; c-c) Accedemos al registro AL y movemos su valor a la direccion de memoria desde DS a ub offset igual a DI=1011H
	                   ; Se puede comprobar el funcionamiento viendo el valor en AL y el de goto ds:1011H tras la instruccion
					   ; Direccion real de memoria accedida = 0535Hx10H + 1011H = 06361H
	
	
	; FIN DEL PROGRAMA 
	MOV AX, 4C00H 
	INT 21H 
INICIO ENDP 
; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END INICIO