[org 0x0100]

	MOV AX, 25h
	MOV BX, 10h

	SHL AL, 1
	RCL BL, 1

	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	RCL AL, 1
	RCL BL, 1
	SHL AL, 1

	MOV SI, 0x270
	MOV word [SI], 1234h

	MOV AX, 0x4C00
	INT 0x21
