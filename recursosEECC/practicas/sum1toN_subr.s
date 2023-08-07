### Programa: sum1toN_subr.s
### Descripción: realiza la suma de la serie 1,2,3,...N
### Es el programa en lenguaje AT&T i386 equivalente a sum1toN.ias de la máquina IAS de von Neumann
### gcc -m32 -g -nostartfiles -o sum1toN_subr sum1toN_subr.s
### Ensamblaje as --32 --gstabs sum1toN_subr.s -o sum1toN_subr.o
### linker -> ld -melf_i386    -o sum1toN_subr sum1toN_subr.o 

	## MACROS
	.equ	SYS_EXIT,	1
	## DATOS
	.section .data

	## INSTRUCCIONES
	.section .text
	.globl _start
_start:
	## Paso los argumentos a la subrutina a través de la pila
	pushl $5	#push    second argument
	pushl $1	#push    first argument
	
	## Llamada a la subrutina sum1toN
	call  sum1toN    

	## Paso la salida de sum11toN al argumento a la llamada al sistema exit()
	mov  %eax, %ebx
	## Código de la llamada al sistema operativo
	movl  $SYS_EXIT, %eax	    #exit (%ebx is returned)
	## Interrumpo la rutina y llamo al S.O.
	int   $0x80

### Subrutina: sum1toN
### Descripción: calcula la suma de números enteros en secuencia desde el 1º sumando hasta el 2º sumando
### Argumentos de entrada: 1º sumando y 2º sumando
### 		     	: los argumentos los pasa la rutina principal a través de la pila:
###        		1º se apila el último argumento y finalmente se apila el 1º argumento.
### Argumento de salida: es el resultado de la suma y se pasa a la rutina principal a través del registro EAX.
### Variables locales: se implementa una variable local en la pila pero no se utiliza
### 
	.type sum1toN, @function # declara la etiqueta sum1toN
sum1toN:
	## Próĺogo: Crea el nuevo frame del stack
	pushl %ebp           #salvar el frame pointer antiguo
	movl  %esp, %ebp     #actualizar el frame pointer nuevo
	## Reserva una palabra en la pila como variable local
	## Variable local en memoria externa: suma
	subl  $4, %esp       
	## Captura de argumentos
	movl  8(%ebp), %ebx  #1º argumento copiado en %ebx
	movl  12(%ebp), %ecx #2º argumento copiado en %ecx


	## suma la secuencia entre el valor del 1ºarg y el valor del 2ºarg
	## 1º arg < 2ºarg
	## utilizo como variable local EDX en lugar de la reserva externa para variable local: optimiza velocidad
	## Inicializo  la variable local suma
	movl  $0,%edx 
	
	## Número de iteracciones
	mov %ecx,%eax
	sub %ebx,%eax
	
bucle:
        add %ebx,%edx
	inc %ebx
        sub $1,%eax
        jns bucle

	## Salvo el valor de retorno
	movl  %edx, %eax  

	## Epílogo: Recupera el frame antiguo
	movl  %ebp, %esp      #restauro el stack pointer
	popl  %ebp            #restauro el frame pointer
	
	## Retorno a la rutina principal
	ret
	.end 
