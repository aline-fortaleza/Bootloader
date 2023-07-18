org 0x7e00
jmp 0x0000:start


;; BASE DO PROGAMA ;;

start:
	call Menu_mode
	call Get_Key 
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

Hide_Cursor:
	mov ah, 02h
	mov dx, 2600h
	int 10h
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

print_str:            
 	.loop:
 		lodsb           
 		cmp al, 0
 		je .endloop
 		call putchar
 		jmp .loop
 	.endloop:
 	ret	
	
reset:
	xor ah, ah
    int 16h
	int 19h




;; CRIANDO A TELA INICIAL DO JOGO ;;

Menu_mode:
	call Video_mode
	mov ah, 0xb 
	mov bh, 0
	mov bl, 9 ; fundo azul claro
	int 10h 
	xor di,di
	mov cx, SCREENW*SCREENH
	;rep stosw 

	xor si,si
	mov si, str_start2
	call print_str

	xor si,si
	mov si, str_start3
	call print_str 
	
	ret

Set_video_memory:
	mov ax, VIDMEM
	mov es, ax
	ret

Set_Snake_Head:
	mov ax, [X_snake]
	mov word [SNAKE_X_ARRAY], ax
	mov ax, [Y_snake]
	mov word [SNAKE_Y_ARRAY], ax
	ret

Clear_Screen:
	mov ax, BGCOLOR
	xor di, di
	mov cx, SCREENW*SCREENH
	rep stosw				
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



;; FUNCIONALIDADE DA COBRA ;;

Draw_snake:
	xor bx, bx				
	mov cx, [snakeLength]	
	mov ax, SNAKECOLOR
	.snake_loop:
		imul di, [SNAKE_Y_ARRAY+bx], SCREENW*2	
		imul dx, [SNAKE_X_ARRAY+bx], 2			
		add di, dx
		stosw
		inc bx
		inc bx
	loop .snake_loop
	ret

Move_Snake:
	mov al, [direction]
    mov si, [X_snake]
    mov di, [Y_snake]

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
        mov word [X_snake], si  
        mov word [Y_snake], di

		
		imul bx, [snakeLength], 2	
		call Snake_Looping

	
	mov word [SNAKE_X_ARRAY], si
	mov word [SNAKE_Y_ARRAY], di
	ret

Snake_Looping:
	.snake_loop:
		mov ax, [SNAKE_X_ARRAY-2+bx]	
		mov word [SNAKE_X_ARRAY+bx], ax
		mov ax, [SNAKE_Y_ARRAY-2+bx]			
		mov word [SNAKE_Y_ARRAY+bx], ax
		
		dec bx								
		dec bx
	jnz .snake_loop							
	ret




;; FUNCIONALIDADE DAS MACAS ;;

Draw_apple:
	imul di, [Y_apple], SCREENW*2
	imul dx, [X_apple], 2
	add di, dx
	mov ax, APPLECOLOR
	stosw
	ret

Apple_Checking:
	mov byte [direction], bl		
	
	mov ax, si
	cmp ax, [X_apple]
	jne Delay_Loop

	mov ax, di
	cmp ax, [Y_apple]
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
	mov word [X_apple], dx
		
	xor ah, ah
	int 1Ah			
	mov ax, dx		
	xor dx, dx		
	mov cx, SCREENH
	div cx			
	mov word [Y_apple], dx
	ret



;; GAME LOSE ;;

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
		cmp si, [SNAKE_X_ARRAY+bx]
		jne .increment

		cmp di, [SNAKE_Y_ARRAY+bx]
		je game_lost				

		.increment:
			inc bx
			inc bx
	loop check_hit_snake_loop
	ret

Lose_Screen:
	mov ax, 4020h
	xor di, di
	mov bl, 4 ; fundo vermelho 
	mov cx, SCREENW*SCREENH
	rep stosw				
	ret	

game_lost:
	call Lose_Screen
	mov dl, 14
	mov dh, 7
	call set_position

	mov bl, 8
	mov si, str_start1
	call print_str
	call reset



;; GAME WIN ;;

Win_Screen:
	mov ax, 2020h
	xor di, di
	mov bl, 2  
	mov cx, SCREENW*SCREENH
	rep stosw				
	ret

game_won:
	call Win_Screen
	mov dl, 14
	mov dh, 7
	call set_position

	mov bl, 8
	mov si, str_start0
	call print_str
	call reset


;; FUNÇÕES DE LOOPING AUXILIARES ;; 

Index_And_Looping_Count:
	xor bx, bx				
	mov cx, [snakeLength]	
	ret

Check_Looping:
	.check_loop:
		mov ax, [X_apple]
		cmp ax, [SNAKE_X_ARRAY+bx]
		jne .increment

		mov ax, [Y_apple]
		cmp ax, [SNAKE_Y_ARRAY+bx]
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


      
        

data:
	str_start0      db '                    Voce Ganhou!                                                    Aperte qualquer tecla para jogar novamente',0 
	str_start1      db '                    Voce Perdeu!                                                    Aperte qualquer tecla para tentar novamente',0
	str_start2		db '                                                                                                 Bem-vindo a Snake! Use W, A, S e D para jogar!',0
	str_start3		db '                                       Aperte qualquer tecla para continuar!', 0

	VIDMEM		equ 0B800h
	SCREENW		equ 80
	SCREENH		equ 25
	WINCOND		equ 10
	BGCOLOR		equ 7020h
	APPLECOLOR  equ 4020h
	SNAKECOLOR  equ 2020h
	TIMER       equ 046Ch
	SNAKE_X_ARRAY equ 1000h
	SNAKE_Y_ARRAY equ 2000h
	UP			equ 0
	DOWN		equ 1
	LEFT		equ 2
	RIGHT		equ 3

	X_snake:	 dw 40
	Y_snake:	 dw 12
	X_apple:		 dw 16
	Y_apple:		 dw 8
	direction:	 db 4
	snakeLength: dw 1

	
jmp $
