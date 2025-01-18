[org 0x0100]

	JMP start

string:	db 'My name and roll number are: '
s_s:	dw $ - string
name:	db 'Hammad '
name_s:	dw $ - name
roll:	db '23L-0700'
roll_s:	dw $ - roll

printstr: push bp 
 mov bp, sp 
 push es 
 push ax 
 push cx 
 push si 
 push di 
 mov ax, 0xb800 
 mov es, ax ; point es to video base 
 mov al, 80 ; load al with columns per row 
 mul byte [bp+10] ; multiply with y position 
 add ax, [bp+12] ; add x position 
 shl ax, 1 ; turn into byte offset 
 mov di,ax ; point di to required location 
 mov si, [bp+6] ; point si to string 
 mov cx, [bp+4] ; load length of string in cx 
 mov ah, [bp+8] ; load attribute in ah 
 cld ; auto increment mode 
nextchar: lodsb ; load next char in al 
 stosw ; print char/attribute pair 
 loop nextchar ; repeat for the whole string 
 pop di 
 pop si 
 pop cx 
 pop ax 
 pop es 
 pop bp 
 ret 10

int9:
	PUSHA

	PUSH word 0
	PUSH word 0
	PUSH word 7
	PUSH word string
	PUSH word [CS:s_s]
	CALL printstr
	
	IN AL, 0x60
	
	CMP AL, 0x3B
	JNE f2

	MOV AX, [CS:s_s]

	PUSH word AX
	PUSH word 0
	PUSH word 7
	PUSH word name
	PUSH word [CS:name_s]
	CALL printstr

f2:
	CMP AL, 0x3C
	JNE nomatch

	MOV AX, [CS:s_s]
	ADD AX, [CS:name_s]

	PUSH word AX
	PUSH word 0
	PUSH word 7
	PUSH word roll
	PUSH word [CS:roll_s]
	CALL printstr

nomatch:
	MOV AL, 0x20
	OUT 0x20, AL

	POPA
	
	IRET

start:
	MOV AX, 0x0003
	INT 0x10

	MOV AX, 0x2509
	MOV DX, int9
	INT 0x21

	JMP $