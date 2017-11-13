.global uart
.text
.set noreorder


#UART1
.set UMODE, 0x6000
.set USTA, 0x6010
.set UTX, 0x6020
.set URX, 0x6030
.set UBRG, 0x6040
/*
#UART2
.set UMODE, 0x6200
.set USTA, 0x6210
.set UTX, 0x6220
.set URX, 0x6230
.set UBRG, 0x6240
*/

.ent uart

uart:
	lw $a1, 0x81030($t1)		# load IFS0 (UART1)
	#lw $t0, 0x81040			# load IFS1 (UART2)
	li $a2, 0x10000000
	and $a2, $a2, $a1
	bgtz $a2, TX
	nop
	li $a2, 0x08000000
	and $a2, $a2, $a1
	bgtz $a2, RX
	nop
	b return
	nop
	
TX:
	li $a1, 0x10000000
	sw $a1, 0x8103C($t1)
	li $a1, 0x401
	mtc0 $a1, $12, 0
	nop
	jr $ra
	nop

RX:
	lw $a1, URX($t1)
	sw $a1, UTX($t1)
	sb $a1, 0x0($s0)
	li $a1, 0x18000000
	sw $a1, 0x8103C($t1)
	li $a1, 0x401
	mtc0 $a1, $12, 0
	nop
	jr $ra
	nop
return:
	#la $a1, rotate			#
	jr $ra					#

.end uart
