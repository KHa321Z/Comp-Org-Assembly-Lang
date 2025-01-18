[org 0x0100]

	JMP start

count:	dw 0
tick:	dw 0
oldkb:	dd 0
oldt:	dd 0

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
	PUSH BX
	PUSH ES

	INC word [CS:tick]
	CMP word [CS:tick], 182
	JNE termt

	MOV BX, SP
	MOV word [BX + 6], term
	MOV [BX + 8], CS

termt:
	MOV AL, 0x20
	OUT 0x20, AL

	POP ES
	POP BX
	POP AX
	IRET

kbisr:
	PUSH AX
	
	IN AL, 0x60
	CMP AL, 0x01
	JGE termkb

	INC word [CS:count]

termkb:
	MOV AL, 0x20
	OUT 0x20, AL

	POP AX
	IRET


start:
	MOV AX, 0x0003
	INT 0x10

	XOR AX, AX
	MOV ES, AX

	MOV AX, [ES:8 * 4]
	MOV [oldt], AX
	MOV AX, [ES: 9 * 4]
	MOV [oldkb], AX
	MOV AX, [ES:8 * 4 + 2]
	MOV [oldt + 2], AX
	MOV AX, [ES:9 * 4 + 2]
	MOV [oldkb + 2], AX

	CLI
	MOV word [ES:8 * 4], counter
	MOV [ES:8 * 4 + 2], CS
	MOV word [ES:9 * 4], kbisr
	MOV [ES:9 * 4 + 2], CS
	STI

	JMP $

term:
	CLI
	MOV AX, [CS:oldt]
	MOV [ES:8 * 4], AX
	MOV AX, [CS:oldkb]
	MOV [ES:9 * 4], AX
	MOV AX, [CS:oldt + 2]
	MOV [ES:8 * 4 + 2], AX
	MOV AX, [CS:oldkb + 2]
	MOV [ES:9 * 4 + 2], AX
	STI

	PUSH word [CS:count]
	CALL printnum

	MOV AX, 0x4C00
	INT 0x21