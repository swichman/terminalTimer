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
#.set BASE2, 0xBF88
.set IFS0, 0x1030
.set IFS0CLR, 0x1034

.ent uart

uart:
#	lui $t1, BASE2
	lw $a1, IFS0($t1)		# load IFS0 (UART1)
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
	sw $a1, IFS0CLR($t1)
	li $a1, 0x401
	mtc0 $a1, $12, 0
	b return
	nop
	
RX:
	lw $a1, URX($t0)
	sw $a1, UTX($t0)
	#sb $a1, 0x0($s0)
	li $a1, 0x18000000
	sw $a1, IFS0CLR($t1)
	li $a1, 0x401
	mtc0 $a1, $12, 0
	nop
	b return
	nop
	
return:
	mfc0 $a1, $14			#
	jr $a1					#

.end uart
