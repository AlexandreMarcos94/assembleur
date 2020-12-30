; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern exit
extern printf

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify    16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1


global main


section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
res:            resd    1


section .data

event:		times	24 dq 0


; Un point par ligne sous la forme X,Y,Z
dodec:	dd	0.0,50.0,80.901699		; point 0
		dd 	0.0,-50.0,80.901699		; point 1
		dd 	80.901699,0.0,50.0		; point 2
		dd 	80.901699,0.0,-50.0		; point 3
		dd 	0.0,50.0,-80.901699		; point 4
		dd 	0.0,-50.0,-80.901699	; point 5
		dd 	-80.901699,0.0,-50.0	; point 6
		dd 	-80.901699,0.0,50.0		; point 7
		dd 	50.0,80.901699,0.0		; point 8
		dd 	-50.0,80.901699,0.0		; point 9
		dd 	-50.0,-80.901699,0.0	; point 10
		dd	50.0,-80.901699,0.0		; point 11

; Une face par ligne, chaque face est composée de 3 points tels que numérotés dans le tableau dodec ci-dessus
; Les points sont donnés dans le bon ordre pour le calcul des normales.
; Exemples :
; pour la première face (0,8,9), on fera le produit vectoriel des vecteurs 80 (vecteur des points 8 et 0) et 89 (vecteur des points 8 et 9)	
; pour la deuxième face (0,2,8), on fera le produit vectoriel des vecteurs 20 (vecteur des points 2 et 0) et 28 (vecteur des points 2 et 8)
; etc...

Xoff: dd 300.0
Zoff: dd 300.0
Yoff: dd 300.0
df: dd  300.0

i: dd 0
j: dd 0

print: db "%f",10,0
print2: db "%d", 10,0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0
count:  dd  0
p:  dd  0

faces:	dd	0,8,9,0
		dd	0,2,8,0
		dd	2,3,8,2
		dd	3,4,8,3
		dd	4,9,8,4
		dd	6,9,4,6
		dd	7,9,6,7
		dd	7,0,9,7
		dd	1,10,11,1
		dd	1,11,2,1
		dd	11,3,2,11
		dd	11,5,3,11
		dd	11,10,5,11
		dd	10,6,5,10
		dd	10,7,6,10
		dd	10,1,7,10
		dd	0,7,1,0
		dd	0,1,2,0
		dd	3,5,4,3
		dd	5,6,4,5


section .text


;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

;####################################
;## Code de création de la fenêtre ##
;####################################
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

; boucle de gestion des évènements
boucle: 
	mov rdi,qword[display_name]
	mov rsi,event
	call XNextEvent

	cmp dword[event],ConfigureNotify
	je prog_principal
	cmp dword[event],KeyPress
	je closeDisplay
jmp boucle

;###########################################
;## Fin du code de création de la fenêtre ##
;###########################################

;############################################
;##	Ici commence VOTRE programme principal ##
;############################################ 
prog_principal:




;mov eax, dword[i]
;mov ebx, dword[faces + eax * DWORD]

;cvtss2sd xmm0, dword[dodec + 0 * DWORD]
;cvtss2sd xmm1, dword[dodec + 1 * DWORD]
;cvtss2sd xmm2, dword[dodec + 2 * DWORD]

;movss dword[x1], xmm0

; Equation : X' =(df * X)/(Z + Zoff)+ Xoff  :   Y' =(df * Y)(Z + Zoff) + Yoff 

;

; #########################################

boucle_j:

mov r11d, dword[j]
mov r12d, dword[faces + r11d * DWORD]
imul r12d, 3


boucle_i:


mov r15d, r12d;

movss xmm0, dword[dodec + r15d * DWORD] ; xmm0 = dodec[x]
mulss xmm0, dword[df] ; xmm0 = df * X

movss xmm1, dword[dodec + r15d * DWORD + 1] ; xmm1 = dodec[z]
addss xmm1, dword[Zoff] ; xmm1 = Z + Zoff

movss xmm2, dword[dodec + r15d * DWORD + 2] ; xmm2 = dodec[y]
mulss xmm2, dword[df] ; xmm2 = df *  Y

divss xmm0, xmm1 ; xmm0 = (df * X)/(Z + Zoff) 
divss xmm2, xmm1 ; xmm2 = (df * Y)/(Z + Zoff)

addss xmm0, dword[Xoff] ; xmm0 = X'
addss xmm2, dword[Xoff] ; xmm2 = Y'

cmp dword[i], 1
jb jump

cvtss2si ecx, xmm0
cvtss2si r8d, xmm2
cvtss2si r10, xmm6
 
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,ecx	; coordonnée source en x
mov r8d,r8d	; coordonnée source en y
mov r9d,r8d	; coordonnée destination en x
push r10		; coordonnée destination en y
call XDrawLine

jump:

inc dword[i]

movss xmm5, xmm0
movss xmm6, xmm2

;mov rdi, print
;cvtss2sd xmm0, dword[x1]
;mov rax, 1
;call printf

mov r12d, dword[j]
inc dword[j]
cmp dword[j], 80
jb boucle_j




 
;##############################################
;##	Ici se termine VOTRE programme principal ##
;##############################################																																																																																																																																	     		     		jb boucle
jmp flush



flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit

	