org 0x7e00
jmp 0x0000:start

set_position:
	mov ah, 02h
	mov bh, 0
	int 10h
	ret

hold_till_space:
	mov di, string
	call getchar
	cmp al, ' '
	jne hold_till_space

	ret
start_screen:

	call video

	mov dl, 35
	mov dh, 1
	call set_position

	mov bl, 3
	mov si, str_start0
	call prints

	mov dl, 30
	mov dh, 8
	call set_position

	mov bl, 15
	mov si, str_start1
	call prints

	mov dl, 30
	mov dh, 16
	call set_position

	mov bl, 15
	mov si, str_start2
	call prints

	mov dl, 30
	mov dh, 24
	call set_position

	mov bl, 15
	mov si, str_start3
	call prints

	call hold_till_space

	ret

video:
	mov ah, 0
	mov al, 12h
	int 10h
	ret

red_background:
	mov ah, 0xb
	mov bh, 0
	mov bl, 4
	int 10h

	ret
gets:               ; mov di, string
 	 xor cx, cx          ; zerar contador
 	.Loop1:
 		call getchar
 		cmp al, 0x08      ; backspace
 		je .backspace
 	cmp al, 0x0d      ; carriage return
 	je .Done
 	cmp cl, 10        ; string limit checker
 	je .Loop1
    
 	stosb
 	inc cl
 	call putchar
    
    jmp .Loop1
    .backspace:
      cmp cl, 0       ; is empty?
      je .Loop1
      dec di
      dec cl
      mov byte[di], 0
      call delchar
    jmp .Loop1
  .Done:
  mov al, 0
  stosb
  call endl
  ret

getchar:
 	mov ah, 0x00
 	int 16h
   	ret

putchar:
 	mov ah, 0x0e
 	int 10h
 	ret

delchar:
	mov al, 0x08          ; backspace
 	call putchar
 	mov al, ' '
 	call putchar
 	mov al, 0x08          ; backspace
 	call putchar
 	ret

endl:
  mov al, 0x0a          ; line feed
  call putchar
  mov al, 0x0d          ; carriage return
  call putchar
  ret

strcmp:             ; mov si, string1, mov di, string2
	.loop1:
		lodsb
		cmp al, byte[di]
		jne .notequal
		cmp al, 0
		je .equal
		inc di
		jmp .loop1
	.notequal:
		clc
		ret
	.equal:
		stc
		ret

prints:             ; mov si, string
 	.loop:
 		lodsb           ; bota character em al 
 		cmp al, 0
 		je .endloop
 		call putchar
 		jmp .loop
 	.endloop:
 	ret

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    call start_screen



    
    ;Código do projeto...
data:
	string times 20 db 0
	str_start0      db 'Viagens pelo Brasil',0 
	str_start1      db 'Somente viagem de ida',0
	str_start2      db 'Viagem de ida e volta',0
	str_start3      db 'Sair do programa',0

   

jmp $