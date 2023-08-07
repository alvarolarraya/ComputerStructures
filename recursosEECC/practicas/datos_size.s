### Program: operando_size
### Descripción: declarar y acceder a distintos tamaños de operandos
### Compilación: gcc -nostartfiles -m32 -g -o datos_size datos_size.s

	## MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0

	## VARIABLES LOCALES
	.data

da1:	.byte   0x0A
da2:	.2byte  0x0A0B
da4:	.4byte  0x0A0B0C0D
men1:	.ascii  "hola"
lista:  .int    1,2,3,4,5
	
	## INSTRUCCIONES
	.global _start
	.text
_start:
	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
fin:	int $0x80
	
	.end
