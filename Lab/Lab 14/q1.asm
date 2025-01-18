[org 0x0100]

	JMP start

; PCB layout: 
; ax,bx,cx,dx,si,di,bp,sp,ip,cs,ds,ss,es,flags,next,dummy 
; 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24, 26 , 28 , 30 
pcb: times 32*16 dw 0 ; space for 32 PCBs 
stack: times 32*256 dw 0 ; space for 32 512 byte stacks 
nextpcb: dw 1 ; index of next free pcb 
current: dw 0 ; index of current pcb 
lineno: dw 0 ; line number for next thread 

; subroutine to register a new thread 
; takes the segment, offset, of the thread routine and a parameter 
; for the target thread subroutine 
initpcb: push bp 
 mov bp, sp 
 push ax 
 push bx 
 push cx 
 push si 
 mov bx, [nextpcb] ; read next available pcb index 
 cmp bx, 17 ; are all PCBs used 
 je exit ; yes, exit 

mov cl, 5 
 shl bx, cl ; multiply by 32 for pcb start 
 mov ax, [bp+8] ; read segment parameter 
 mov [pcb+bx+18], ax ; save in pcb space for cs 
 mov ax, [bp+6] ; read offset parameter 
 mov [pcb+bx+16], ax ; save in pcb space for ip 
 mov [pcb+bx+22], ds ; set stack to our segment 
 mov si, [nextpcb] ; read this pcb index 
 mov cl, 9 
 shl si, cl ; multiply by 512 
 add si, 256*2+stack ; end of stack for this thread 
 mov ax, [bp+4] ; read parameter for subroutine 
 sub si, 2 ; decrement thread stack pointer 
 mov [si], ax ; pushing param on thread stack 
 sub si, 2 ; space for return address 
 mov [pcb+bx+14], si ; save si in pcb space for sp 
 mov word [pcb+bx+26], 0x0200 ; initialize thread flags 
 mov ax, [pcb+28] ; read next of 0th thread in ax 
 mov [pcb+bx+28], ax ; set as next of new thread 
 mov ax, [nextpcb] ; read new thread index 
 mov [pcb+28], ax ; set as next of 0th thread 
 inc word [nextpcb] ; this pcb is now used 
exit: pop si 
 pop cx 
 pop bx 
 pop ax 
 pop bp 
 ret 6 
; timer interrupt service routine 
timer: push ds 
 push bx 
 push cs 
 pop ds ; initialize ds to data segment 
 mov bx, [current] ; read index of current in bx 
 shl bx, 1 
 shl bx, 1 
 shl bx, 1 
 shl bx, 1 
 shl bx, 1 ; multiply by 32 for pcb start 
 mov [pcb+bx+0], ax ; save ax in current pcb 
 mov [pcb+bx+4], cx ; save cx in current pcb 
 mov [pcb+bx+6], dx ; save dx in current pcb 
 mov [pcb+bx+8], si ; save si in current pcb 
 mov [pcb+bx+10], di ; save di in current pcb 
 mov [pcb+bx+12], bp ; save bp in current pcb 
 mov [pcb+bx+24], es ; save es in current pcb 
 pop ax ; read original bx from stack 
 mov [pcb+bx+2], ax ; save bx in current pcb 
 pop ax ; read original ds from stack 
 mov [pcb+bx+20], ax ; save ds in current pcb 
 pop ax ; read original ip from stack 
 mov [pcb+bx+16], ax ; save ip in current pcb 
 pop ax ; read original cs from stack 
 mov [pcb+bx+18], ax ; save cs in current pcb 
 pop ax ; read original flags from stack 
 mov [pcb+bx+26], ax ; save cs in current pcb 
 mov [pcb+bx+22], ss ; save ss in current pcb 
 mov [pcb+bx+14], sp ; save sp in current pcb 
 mov bx, [pcb+bx+28] ; read next pcb of this pcb 
 mov [current], bx ; update current to new pcb 
 mov cl, 5 
 shl bx, cl ; multiply by 32 for pcb start 
 mov cx, [pcb+bx+4] ; read cx of new process 
 mov dx, [pcb+bx+6] ; read dx of new process 
 mov si, [pcb+bx+8] ; read si of new process 
 mov di, [pcb+bx+10] ; read diof new process 
mov bp, [pcb+bx+12] ; read bp of new process 
 mov es, [pcb+bx+24] ; read es of new process 
 mov ss, [pcb+bx+22] ; read ss of new process 
 mov sp, [pcb+bx+14] ; read sp of new process 
 push word [pcb+bx+26] ; push flags of new process 
 push word [pcb+bx+18] ; push cs of new process 
 push word [pcb+bx+16] ; push ip of new process 
 push word [pcb+bx+20] ; push ds of new process 
 mov al, 0x20 
 out 0x20, al ; send EOI to PIC 
 mov ax, [pcb+bx+0] ; read ax of new process 
 mov bx, [pcb+bx+2] ; read bx of new process 
 pop ds ; read ds of new process 
 iret ; return to new process 

delay:
	PUSH CX

	MOV CX, 0xFFFF
delay_loop:
	LOOP delay_loop

	POP CX
	RET

fallingStar:
	PUSH BP
	MOV BP, SP

	MOV AX, 0xB800
	MOV ES, AX

	DEC word [BP + 4]
	MOV DI, [BP + 4]
	SHL DI, 1
	
	print_star:
		MOV word [ES:DI], 0x072A
		CALL delay
		MOV word [ES:DI], 0x0720
		
		ADD DI, 160
		CMP DI, 4000
		JL print_star

		MOV DI, [BP + 4]
		SHL DI, 1

		JMP print_star

	RET 2

start: 
	MOV AX, 0x0003
	INT 0x10

	XOR AX, AX 
	MOV ES, AX
	MOV BX, 80

	CLI 
 	MOV word [ES:8 * 4], timer 
 	MOV [ES:8 * 4 + 2], CS 
 	STI 

nextkey: 
	XOR AH, AH 
 	INT 0x16

	CMP AL, 0x38
	JNE nextkey
 
	PUSH CS 
	PUSH word fallingStar
	PUSH BX
	CALL initpcb

	SUB BX, 5 
	JMP nextkey