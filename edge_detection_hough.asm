section .text
    global _start

%define WIDTH  512
%define HEIGHT 512
%define THRESH_LOW  50
%define THRESH_HIGH 150

_start:
    ; BMP Dosyasını Aç
    mov rax, 2
    mov rdi, input_file
    mov rsi, 0
    syscall
    mov r8, rax  ; Dosya tanımlayıcıyı sakla

    ; BMP Başlığını Oku (54 Byte)
    mov rax, 0
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 54
    syscall

    ; Piksel Verisini Oku
    mov rax, 0
    mov rdi, r8
    mov rsi, pixels
    mov rdx, WIDTH * HEIGHT
    syscall

    ; **1. Aşama: Sobel Filtresi ve Kenar Algılama (AVX-512 ile)**
    mov rdi, pixels
    mov rsi, edges
    mov rcx, WIDTH * HEIGHT / 16

sobel_loop:
    vmovdqu32 zmm1, [rdi-1]  ; Sol piksel
    vmovdqu32 zmm2, [rdi]    ; Orta piksel
    vmovdqu32 zmm3, [rdi+1]  ; Sağ piksel

    vpsubusb zmm4, zmm3, zmm1 ; Gx = Sağ - Sol
    vpsubusb zmm5, zmm1, zmm3 ; Gy = Üst - Alt
    vpaddusb zmm6, zmm4, zmm5 ; |G| = |Gx| + |Gy|

    vpcmpgtb k1, zmm6, THRESH_LOW
    vpcmpgtb k2, zmm6, THRESH_HIGH

    vmovdqu8 [rsi] {k1}, zmm6
    vmovdqu8 [rsi] {k2}, zmm2

    add rdi, 64
    add rsi, 64
    loop sobel_loop

    ; **2. Aşama: Hough Transform (AVX-512 Optimize)**
    mov rdi, edges
    mov rsi, hough_space
    mov rcx, WIDTH * HEIGHT / 16

hough_loop:
    vmovdqu32 zmm1, [rdi]
    vptest zmm1, zmm1  ; Eğer sıfırsa devam et
    jz no_hough

    vmovdqu32 zmm2, angles
    vpmulld zmm3, zmm2, 100

    vpaddd zmm3, zmm3, HEIGHT / 2
    vmovdqu32 [rsi + zmm3 * 8], zmm1

no_hough:
    add rdi, 64
    loop hough_loop

    ; **3. Aşama: Çıktı BMP Kaydet**
    mov rax, 2
    mov rdi, output_file
    mov rsi, 0101o
    syscall
    mov r9, rax

    mov rax, 1
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 54
    syscall

    mov rax, 1
    mov rdi, r9
    mov rsi, edges
    mov rdx, WIDTH * HEIGHT
    syscall

    ; Çıkış Yap
    mov rax, 60
    xor rdi, rdi
    syscall

section .bss
    buffer resb 54
    pixels resb WIDTH * HEIGHT
    edges resb WIDTH * HEIGHT
    hough_space resq 180 * WIDTH  ; 180 açıya karşılık gelen akümülatör

section .data
    input_file db "input.bmp", 0
    output_file db "output.bmp", 0
    angles dq 0, 1, 2, ..., 179  ; 180 derece için açı verileri
