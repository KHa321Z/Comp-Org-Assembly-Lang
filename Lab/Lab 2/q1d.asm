[org 0x0100]

	MOV BX, 0
	MOV AX, [12Ch + BX]
	
	ADD BX, 2
	MOV AX, [12Ch + BX]

	ADD BX, 2
	MOV AX, [12Ch + BX]

	ADD BX, 2
	MOV AX, [12Ch + BX]

	ADD BX, 2
	MOV AX, [12Ch + BX]

	MOV AX, 0x4C00
	INT 0x21

num1: 	dw 12, 25, 38, 44, 105
