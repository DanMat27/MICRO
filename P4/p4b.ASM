; *************************************************************************
; PAREJA 06: 
; 	DANIEL MAZA SANTOS
; 	DANIEL MATEO MORENO
;
;**************************************************************************
; INFO IMPORTANTE: Para que p4b funcione correctamente es necesario haber
; ejecutado p4a e instalado la interrupcion 57H (> p4a /I). Se muestra por  
; pantalla nuestra tabla de Polibio y la codificacion y decodificacion de 
; dos cadenas predefinidas (POLIBIO en normal y HOLAMUNDO en Polibio).
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 
DATOS SEGMENT 

	POLIBIO_PANTALLA DB 10,"     1 2 3 4 5 6",10,"     - - - - - -",10," 1 | 5 6 7 8 9 A",10," 2 | B C D E F G",10," 3 | H I J K L M",10," 4 | N O P Q R S",10," 5 | T U V W X Y",10," 6 | Z 0 1 2 3 4",'$'   ; Tabla de Polibio que se imprimira por pantalla
	INFO_COD DB 10," Se va a codificar el mensaje predefinido: ",'$'     ; Cadena con informacion de lo que se va a realizar (codificar)
	INFO_DECOD DB 10," Se va a decodificar el mensaje predefinido: ",'$'     ; Cadena con informacion de lo que se va a realizar (decodificar)
	MSG_COD DB "POLIBIO",'$'     ; Cadena con el mensaje para codificar
	MSG_DECOD DB "31 42 35 16 36 52 41 23 42",'$'     ; Cadena con el mensaje para decodificar
	ESTRELLAS DB 10,"**************************************************************************",'$'     ; Cadena de * por estilo al imprimir por pantalla
	INFO_POLIBIO DB 10,"La tabla de Polibio a utilizar es:",'$'     ; Cadena con informacion de la tabla para imprimir por pantalla
	CODI DB 10," Codificacion obtenida: ",'$'     ; Cadena con informacion introductoria para imprimir por pantalla
	DECODI DB 10," Decodificacion obtenida: ",'$'     ; Cadena con informacion introductoria para imprimir por pantalla
	
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
	
	MOV DX, OFFSET INFO_COD         ; Imprime una introduccion de que se va a realizar la codificacion 
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET MSG_COD          ; Imprime la cadena predefinida para codificar (POLIBIO)   
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET CODI             ; Imprime una introduccion antes de mostrar la cadena codificada
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET MSG_COD          ; Movemos el offset de la cadena a DX ya que debe estar en DS:DX
	
	MOV AH, 10H                     ; Llamamos a la interrupcion 57H tras instalarla en p4a (10H = Decodificar)
	INT 57H
	
	MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)   
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET INFO_DECOD       ; Imprime una introduccion de que se va a realizar la decodificacion 
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET MSG_DECOD        ; Imprime la cadena predefinida para decodificar (HOLAMUNDO en codigo Polibio)
	MOV AH, 9
	INT 21H
	
	MOV DX, OFFSET DECODI            ; Imprime una introduccion antes de mostrar la cadena decodificada
	MOV AH, 9
	INT 21H
	
	MOV BX, OFFSET POLIBIO          ; Movemos el offset de la tabla de Polibio a BX para que este en ES:BX
	MOV DX, OFFSET MSG_DECOD        ; Movemos el offset de la cadena a DX ya que debe estar en DS:DX
	
	MOV AH, 11H                     ; Llamamos a la interrupcion 57H tras instalarla en p4a (11H = Decodificar)
	INT 57H
	
	MOV DX, OFFSET ESTRELLAS        ; Imprime una linea de estrellas (estilo)   
	MOV AH, 9
	INT 21H
	
	FIN:                            ; * * * * FIN * * * *
	MOV AX, 4C00H                   ; Fin del programa
	INT 21H
	
INICIO ENDP 
	

CODE ENDS 
END INICIO	
	
	