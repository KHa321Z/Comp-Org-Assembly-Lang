[org 0x0100]

	MOV AX, [num]
	MOV BX, num
	XCHG AX, [BX + 8]
	XCHG AX, [BX + 6]
	XCHG AX, [BX + 2]
	XCHG AX, [BX + 4]
	MOV [BX], AX

	MOV AX, 0x4C00
	INT 0x21

num: 	dw 2, 1, 0, 0, 1, 3, -1
