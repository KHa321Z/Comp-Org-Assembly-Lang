[org 0x0100]

	JMP start

tick:	dw 0

printnum: push bp 
 mov bp, sp 
 push es 
 push ax 
 push bx 
 push cx 
 push dx 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov ax, [bp+4] ; load number in ax 
 mov bx, 10 ; use base 10 for division 
 mov cx, 0 ; initialize count of digits 
nextdigit: mov dx, 0 ; zero upper half of dividend 
 div bx ; divide by 10 
 add dl, 0x30 ; convert digit into ascii value 
 push dx ; save ascii value on stack 
 inc cx ; increment count of values 
 cmp ax, 0 ; is the quotient zero 
 jnz nextdigit ; if no divide it again 
 mov di, 0 ; point di to top left column
nextpos: pop dx ; remove a digit from the stack 
 mov dh, 0x07 ; use normal attribute 
 mov [es:di], dx ; print char on screen 
 add di, 2 ; move to next screen location 
 loop nextpos ; repeat for all digits on stack
 pop di 
 pop dx 
 pop cx 
 pop bx 
 pop ax 
 pop es 
 pop bp 
 ret 2

counter:
	PUSH AX
	PUSH ES

	INC word [CS:tick]
	PUSH word [CS:tick]
	CALL printnum

	XOR AX, AX
	MOV ES, AX
	MOV word [ES:8 * 4], toggle

	MOV AL, 0x20
	OUT 0x20, AL

	POP ES
	POP AX
	IRET

toggle:
	PUSH AX
	PUSH ES

	PUSH word 0xB800
	POP ES

	CMP byte [ES:160], 'A'
	JNE printB

	MOV word [ES:160], 0x0742
	JMP termtimer

printB:
	MOV word [ES:160], 0x0741

termtimer:
	XOR AX, AX
	MOV ES, AX
	MOV word [ES:8 * 4], counter
	
	MOV AL, 0x20
	OUT 0x20, AL

	POP ES
	POP AX
	IRET

start:
	MOV AX, 0x0003
	INT 0x10

	XOR AX, AX
	MOV ES, AX

	CLI
	MOV word [ES:8 * 4], toggle
	MOV [ES:8 * 4 + 2], CS
	STI

	JMP $