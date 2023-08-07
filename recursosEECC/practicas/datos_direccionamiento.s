### Program:     datos_direccionamiento.s
### Descripción: Emplear estructuras de datos con diferentes direccionamientos
	
	## MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0

	## VARIABLES LOCALES
	.data

	.align 4				     # Alineamiento con direcciones de MP múltiplos de 4
da2:	.2byte  0x0A0B,0b0000111101011100,-21,0xFFFF # Array da2 de elementos de 2 bytes
	.align 4
lista:  .word    1,2,3,4,5	# Array lista de elementos de 2 bytes
	.align 8
buffer:	.space  100		# Array buffer de 100 bytes
	.align 2
saludo:
	.string "Hola"		# Array saludo de elementos de 1 byte por ser caracteres
	
	## INSTRUCCIONES
	.global main
	.text
main:

	## RESET	

	xor  %eax,%eax
	xor  %ebx,%ebx
	xor  %ecx,%ecx
	xor  %edx,%edx
	xor  %esi,%esi
        xor  %edi,%edi

	## ALGORITMO sum1toN

	## Direccionamiento inmediato
	mov $4,%si
	## Direccionamiento indexado
bucle:	add lista(,%esi,2),%di
	## Direccionamiento a registro
	dec %si
	## Direccionamiento relativo al PC
	jns bucle


	## EJERCICIOS SOBRE DIRECCIONAMIENTO
	
	## Direccionamiento indirecto
	lea buffer,%eax		#inicializo el puntero EAX
	## mov da2,(%eax) ERROR: la dirección efectiva de los dos operandos hacen referencia a la memoria principal
	mov da2,%bx
	mov %bx, (%eax)
	## Direccionamiento directo
	incw da2
	## Direccionamiento indexado
	lea  da2,%ebx
	## inc 2(%ebx) ERROR: dirección efectiva a memoria y no hay sufijo
	incw 2(%ebx)
	
	mov $3,%esi
	mov da2(,%esi,2),%ebx
	
	## SALTOS INCONDICIONALES
	
	## Direccionamiento relativo
	jmp salto1		#salto relativo al contador de programa pc -> eip
	xor %esi,%esi
salto1:


	
	## SALIDA
	
	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
	int $0x80
	
	.end
