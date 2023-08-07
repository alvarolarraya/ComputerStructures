###  Programa: imprimir.s
###  Descripción: imprime un mensaje en el monitor
###  LLamada al sistema operativo write (fd, *buf, count) : manual man 2 write
###  fd: descriptor de fichero del dispositivo donde se imprime; *buf: puntero al string a imprimir ; count: nº de bytes a imprimir.
###  Los argumentos de la función de izda a dcha se pasan a través de los registros EBX, ECX, EDX
	
	## MACROS
        .equ SYS_EXIT  , 1
        .equ SYS_WRITE , 4
        .equ STDOUT_ID , 1
        .equ SUCCESS   , 0

	## VARIABLES LOCALES AL FICHERO
	.data
msg1:	.string "Hola Mundo\n"
	.equ	len1, .  - msg1 	#tamaño en bytes de la cadena msg1
	## len1 : macro
	## . - msg1 : valor asociado a la macro len1
	## . : dirección actual del location counter del assembler según va traduciendo.
chivo:	.int 0xAABBCCDD

        ## INSTRUCCIONES 
        .global _start
	.text

_start:
	## Imprimir en el monitor
	mov 	$SYS_WRITE, %eax	# código de llamada al sistema de la función write()
	mov 	$STDOUT_ID, %ebx	# Descriptor de fichero del dispositivo: el monitor es la salida standard
	mov 	$msg1, %ecx		# dirección que apunta al mensaje a imprimir
	mov 	$len1, %edx		# longitud en bytes del mensaje a imprimir
	int     $0x80			# LLamada al sistema operativo: interrupción software del programa en ejecución.

	## Finalizar el proceso y salir al sistema operativo
        mov     $SYS_EXIT, %eax
        mov     $SUCCESS,  %ebx
        int     $0x80
     
        .end
