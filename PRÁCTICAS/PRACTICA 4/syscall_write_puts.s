	
	#MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0
	
	#DATOS
	.data
buffer:	.ascii  "Hola\n"

	#INSTRUCCIONES
	.global _start
	.text
_start:
#PUTS

	push $buffer
	call puts

	#WRITE
	#METIENDO LOS ARGUMENTOS EN REGISTROS
	mov $4,%eax
	mov $1,%ebx
	mov $buffer,%ecx
	mov $5,%edx
	int $0x80
	
	#PONIENDO LOS ARGUMENTOS EN LA PILA
	push $buffer
	push $1
	push $4
	call write
	
	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
fin:int $0x80
	.end
