	/*
Program:     datos_saltos.s
Descripción: Emplear estructuras de datos con diferentes direccionamientos
	
	*/
	
	## MACROS
	.equ SYS_EXIT,	1
	.equ SUCCESS,	0

	## VARIABLES LOCALES
	.data

	
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


	
	## FLAGS DEL REGISTRO DE BANDERINES EFLAGS
	/*
	los flags se activan al realizar operaciones aritméticas, lógicas, etc dependiendo del resultado de dicha operación
CF: El resultado de la operación tiene llevada del bit MSB del destino
OF: El resultado de la operación con signo se  desborda, su tamaño supera el permitido.
ZF: el resultado de la operación  tiene  valor  cero
SF: el resultado de la oeración tiene valor  negativo
PF: el resultado de la operación tiene el byte LSB con un  número par de bits
	*/
	xor %eax,%eax	       # resultado cero -> activa ZF y PF pero desactiva CF,OF,SF
	inc %eax	       # desactiva ZF y PF
	neg %eax	       # activa SF,PF y CF : realiza la resta de la definición de complemento a 2 :(0-N)
	shr $1,%eax	       # SHift Right : desplazamiento lógico: desplaza n bits el operando destino.   
/* Salen bits por la dcha y entran ceros por la izda.
 El último bit salido queda en CF.
 SF=0 ya que ha entrado un cero en el MSB
 MANUAL INTEL: http://www.cs.nyu.edu/~mwalfish/classes/ut/s13-cs439/ref/i386/SAL.htm
 For SHR, OF is set to the high-order bit of the original operand.
	OF=MSB=1 
 The OF flag is affected only on 1-bit shifts.
 Equivale a dividir 2^n si desplazo a la dcha y a multiplicar 2^n hacia la izda (posible overflow).
*/
	shl $1,%eax
	clc		       # clear CF -> CF=0
	xor %eax,%eax	       # resultado cero -> activa ZF y PF pero desactiva CF,OF,SF
	movw $0xFFFF,%ax       # MOV NO afecta a ningún flag
	addw $0xFFFF,%ax	# activa SF y CF pero no OF
	clc
	movw $0x7FFF,%ax
	addw $1,%ax		#activa OF pero no CF, OF avisa del error en la suma y se puede ver que SF se ha activado
	
	
	## INSTRUCCIONES COMPARATIVAS: TEST,CMP

	## Comprobar si el bit de la posicion 5  es cero con la mascara 0x0010 que aisla dicha posicion
	## test realiza la operación AND afectando a los flags de EFLAGS pero no guarda el resultado en el operando destino
	movw $0xABFF, %ax
	movw $0x0BCF, %bx
	test $0x0010, %ax	# AX^0x0010=0x0010=positivo -> SF=0, low byte=0x10 impar -> PF=0, 
				# El manual dice -> The OF and CF flags are cleared
        test $0xFFFF, %ax	# SF=1 porque AX^0xFFFF=AX= negativo, low byte=AL= par ->  PF=1 
	test $0b0000000000010000, %bx	# SF=0 porque AX^0x0010=positivo ,ZF=1 porque BX[5] es cero, PF=0

	## Comprobar si el valor de una variable es mayor, menor o igual al valor 0x00FF
	## cmp realiza la operacion SUB afectando a los flags de EFLAGS pero no guarda el resultado en el operando destino
	## SUB: It evaluates the result for both signed and unsigned integer operands and sets the OF and CF flags
	## to indicate an overflow in the signed or unsigned result, respectively
	movw $0x01FF, %ax
	movw $0x0001, %bx
	movw $0x00FF, %cx
	cmp  $0x00FF, %ax	#  AX-0x00FF=0x0100 > 0 ->  ZF=0 y SF=0, low byte=00 -> PF=1
	cmp  $0x00FF, %bx	#  BX-0x00FF=0x0001+0xFF01=0xFF02 < 0 -> SF=1, 0x02 impar -> PF=0,
				#  unsigned overflow -> CF=1, signed not overflow OF=0
	cmp  $0x00FF, %cx	#  CX-0x00FF=0 -> ZF=1, SF=0, 0xFF par PF=1, CF=0, OF=0

	## SALTOS CONDICIONALES

	movw $0x01FF, %ax
	movw $0x0001, %bx
	movw $0x00FF, %cx
	cmp  $0x00FF, %ax	#  AX-0x00FF=0x0100 > 0, luego ZF=0 y SF=0, 0x00 para -> PF=1
	jg   salto4		# great jump -> resta de numeros con signo -> SF=0 y salta
	nop
salto4:	cmp  $0x00FF, %bx	# BX-0x00FF=0x0001+0xFF01=0xFF02 < 0, luego ZF=0 , SF=1,
				# unsigned over CF=1 y not signed over OF=0
	jl   salto5		# less jump -> resta de numeros con signo -> SF=1 y salta
	nop
salto5:	movw $0x8000, %ax	# 0x8000 vale -32768 con signo y 32768 sin signo
	cmp  $0x0001, %ax	# Con signo ->0x8000 - 0x1 = 0x8000+0xFFFF=0x7FFFF >0 -> SF=0, 			
				# OF=1 ya que la suma de dos negativos ha dado positivo
                                # CF=0 ya que en binario puro 0x01FF-0x00001=0x01FE, no overflow
				# 0xFF es par -> PF=1 
	
	ja   salto6		# above jump -> resta de números sin signo -> 32768-1>0
	nop
salto6:	cmp  $0x00FF, %cx	# CX-0x00FF = 0, luego ZF=1 y SF=0
	je   salto7		# equal jump
	nop
	
	
	## SALIDA
	
salto7:	mov $SYS_EXIT, %eax	
	mov $SUCCESS,  %ebx
	int $0x80
	
	.end
