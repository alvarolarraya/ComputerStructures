### Programa: datos_sufijos.s
### Descripción: utilizar distintos sufijos para los mnemónicos indicado distintos tamaños de operandos
### Compilación: gcc -m32 -g -o datos_sufijos datos_sufijos.s

	## MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0

	## VARIABLES LOCALES
	.data

da1:	.byte   0x0A
da2:	.2byte  0x0A0B
da4:	.4byte  0x0A0B0C0D
da44:	.4byte  0xFFFFFFFF
men1:	.ascii  "hola"
lista:  .int    1,2,3,4,5
	
	## INSTRUCCIONES
	.global _start
	.text
_start:

	## Reset de Registros 
	xor  %eax,%eax
	xor  %ebx,%ebx
	xor  %ecx,%ecx
	xor  %edx,%edx

	## Carga de datos
	## mov da1,da4		ERROR: por referenciar los dos operandos a memoria
	mov  da4,%eax
	movl da4,%ebx
	movw da4,%cx
	movb da4,%dl

	## Reset de Registros
	xor  %eax,%eax
	xor  %ebx,%ebx
	xor  %ecx,%ecx
	xor  %edx,%edx

	## Carga de datos
	## movw  da4,%al	ERROR: incoherencia entre -w y AL
	mov  da4,%al		#aplica el tamaño de DL
	movb da4,%ebx  	        #AVISO, NO error: incoherencia entre el registro BL y el sufijo b
	movb %ebx,da44 	        #AVISO, NO error: incoherencia entre el registro BL y el sufijo b
	mov  %bx,da44		#
  
	mov  da1,%ecx
	mov  da4,%dx

	## Reset de Registros
	xor  %eax,%eax
	xor  %ebx,%ebx
	xor  %ecx,%ecx
	xor  %edx,%edx

	## Carga de datos
	
        mov  da1,%al

	## inc da1     		ERROR:  sin el sufijo en inc por ser referencia sólo a memoria
	incb da1
	incw da2
	incl da4

## salida
	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
	int $0x80
	
	.end
