### Programa: salida.s
### Descripción: Llama al sistema operativo para ejecutar la función del kernel exit().
### Manual de la función exit() -> man exit
### Función exit: void exit(int status); Operación: Llama al Sistema Operativo para finalizar el proceso y salir al sistema.
### Salida: al finalizar el programa ejecutar el comando linux echo $? que imprime el valor recibido por el programa salida
### gcc -m32 -g -nostartfiles -o salida salida.s
### Ensamblaje -> as --32 --gstabs salida.s -o salidas.o
### linker -> ld -melf_i386 -o salida salidas.o

	## MACROS
	.equ  SYS_EXIT, 1
	.equ  SUCCESS, 0
	
	## INSTRUCCIONES
        .global _start		#Etiqueta definida por el linker.
	.text

_start:
	## 
	## Operación: Finaliza el proceso y sale al sistema operativo
	
        mov     $SYS_EXIT, %eax	#Código de la llamada al sistema exit(): 
        mov     $SUCCESS,  %ebx	#status: Argumento de la función exit() que se pasa al S.O antes de finalizar el proceso
        int     $0x80
     
        .end
