org 0x7e00
jmp 0x0000:start

start:
	call Video_mode
	call Set_video_memory
	call Set_Snake_Head
	call Hide_Cursor
	call game_running
game_running:
	call Clear_Screen
	call Draw_snake
	call Draw_apple
	call Move_Snake
	call Check_Conditions
	call Get_Player_Input
	check_apple:
		call Apple_Checking
	next_apple:
		call Apple_Appearing
	call Index_And_Looping_Count
	call Check_Looping
	Delay_Loop:
		call Delay_Looping
jmp game_running

Video_mode:
	mov ax, 0003h
	int 10h
	ret

Set_video_memory:
	mov ax, VIDMEM
	mov es, ax
	ret

Set_Snake_Head:
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax
	ret

Hide_Cursor:
	mov ah, 02h
	mov dx, 2600h
	int 10h
	ret

Clear_Screen:
	mov ax, BGCOLOR
	xor di, di
	mov cx, SCREENW*SCREENH
	rep stosw				
	ret

Lose_Screen:
	mov ax, 4020h
	xor di, di
	mov bl,0eh 
	mov cx, SCREENW*SCREENH
	rep stosw				
	ret	

Draw_snake:
	xor bx, bx				
	mov cx, [snakeLength]	
	mov ax, SNAKECOLOR
	.snake_loop:
		imul di, [SNAKEYARRAY+bx], SCREENW*2	
		imul dx, [SNAKEXARRAY+bx], 2			
		add di, dx
		stosw
		inc bx
		inc bx
	loop .snake_loop
	ret

Draw_apple:
	imul di, [appleY], SCREENW*2
	imul dx, [appleX], 2
	add di, dx
	mov ax, APPLECOLOR
	stosw
	ret

Move_Snake:
	mov al, [direction]
    mov si, [playerX]
    mov di, [playerY]

	cmp al, UP
	je move_up
	cmp al, DOWN
	je move_down
	cmp al, LEFT
	je move_left
	cmp al, RIGHT
	je move_right

	jmp update_snake

	move_up:
		dec di		
		jmp update_snake

	move_down:
		inc di		
		jmp update_snake

	move_left:
		dec si		
		jmp update_snake

	move_right:
		inc si		

	update_snake:
        mov word [playerX], si  
        mov word [playerY], di

		
		imul bx, [snakeLength], 2	
		call Snake_Looping

	
	mov word [SNAKEXARRAY], si
	mov word [SNAKEYARRAY], di
	ret
Snake_Looping:
	.snake_loop:
		mov ax, [SNAKEXARRAY-2+bx]	
		mov word [SNAKEXARRAY+bx], ax
		mov ax, [SNAKEYARRAY-2+bx]			
		mov word [SNAKEYARRAY+bx], ax
		
		dec bx								
		dec bx
	jnz .snake_loop							
	ret
Check_Conditions:
	call Condition_Outside
	call Condition_Snake_Hit_Snake
	ret
Condition_Outside:
	cmp di, -1		
	je game_lost
	cmp di, SCREENH	
	je game_lost
	cmp si, -1		
	je game_lost
	cmp si, SCREENW 
	je game_lost
	ret
Condition_Snake_Hit_Snake:
	cmp word [snakeLength], 1	
	je Get_Player_Input

	mov bx, 2					
	mov cx, [snakeLength]		
	check_hit_snake_loop:
		cmp si, [SNAKEXARRAY+bx]
		jne .increment

		cmp di, [SNAKEYARRAY+bx]
		je game_lost				

		.increment:
			inc bx
			inc bx
	loop check_hit_snake_loop
	ret

Get_Player_Input:
	mov bl, [direction]		
	mov ah, 1
	int 16h					
	jz check_apple			
	call Get_Key
	jmp check_apple
	call Check_Key_Pressed
	ret

Get_Key:
	xor ah, ah
	int 16h					
	
	cmp al, 'w'
	je w_pressed
	cmp al, 's'
	je s_pressed
	cmp al, 'a'
	je a_pressed
	cmp al, 'd'
	je d_pressed
	cmp al, 'r'
	je r_pressed
	ret
Check_Key_Pressed:
	w_pressed:
		
		mov bl, UP
		jmp check_apple

	s_pressed:
		
		mov bl, DOWN
		jmp check_apple

	a_pressed:
		
		mov bl, LEFT
		jmp check_apple

	d_pressed:
		
		mov bl, RIGHT
		jmp check_apple

	r_pressed:
		int 19h     
	ret	
Apple_Checking:
	mov byte [direction], bl		
	
	mov ax, si
	cmp ax, [appleX]
	jne Delay_Loop

	mov ax, di
	cmp ax, [appleY]
	jne Delay_Loop

	inc word [snakeLength]
	cmp word [snakeLength], WINCOND
	je game_won	
	ret
Apple_Appearing:
	xor ah, ah
	int 1Ah			
	mov ax, dx		
	xor dx, dx		
	mov cx, SCREENW
	div cx			
	mov word [appleX], dx
		
	xor ah, ah
	int 1Ah			
	mov ax, dx		
	xor dx, dx		
	mov cx, SCREENH
	div cx			
	mov word [appleY], dx
	ret

Index_And_Looping_Count:
	xor bx, bx				
	mov cx, [snakeLength]	
	ret

Check_Looping:
	.check_loop:
		mov ax, [appleX]
		cmp ax, [SNAKEXARRAY+bx]
		jne .increment

		mov ax, [appleY]
		cmp ax, [SNAKEYARRAY+bx]
		je next_apple				
		
		.increment:
			inc bx
			inc bx
	loop .check_loop
	ret	
Delay_Looping:
	mov bx, [TIMER]
	inc bx
	inc bx
	.delay:
		cmp [TIMER], bx
		jl .delay
	ret

set_position:
	mov ah, 02h
	mov bh, 0
	int 10h
	ret

putchar:
 	mov ah, 0x0e
 	int 10h
 	ret
prints:            
 	.loop:
 		lodsb           
 		cmp al, 0
 		je .endloop
 		call putchar
 		jmp .loop
 	.endloop:
 	ret	

game_won:
	mov dl, 35
	mov dh, 1
	call set_position

	mov bl, 7
	mov si, str_start0
	call prints
	call reset
	
game_lost:
	call Lose_Screen
	mov dl, 10
	mov dh, 5
	call set_position

	mov bl, 8
	mov si, str_start1
	call prints
	call reset
	
reset:
	xor ah, ah
    int 16h
	int 19h
data:
	str_start0      db 'Ganhou',0 
	str_start1      db 'Voce Perdeu!, Aperte qualquer tecla para tentar novamente',0

	VIDMEM		equ 0B800h
	SCREENW		equ 80
	SCREENH		equ 25
	WINCOND		equ 20
	BGCOLOR		equ 1020h
	APPLECOLOR  equ 4020h
	SNAKECOLOR  equ 2020h
	TIMER       equ 046Ch
	SNAKEXARRAY equ 1000h
	SNAKEYARRAY equ 2000h
	UP			equ 0
	DOWN		equ 1
	LEFT		equ 2
	RIGHT		equ 3

	playerX:	 dw 40
	playerY:	 dw 12
	appleX:		 dw 16
	appleY:		 dw 8
	direction:	 db 4
	snakeLength: dw 1
jmp $