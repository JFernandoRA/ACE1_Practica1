   .data
menu:   .asciz "====Calculadora ARM64====\n"
        .asciz "1. Suma\n"
        .asciz "2. Resta\n"
        .asciz "3. Multiplicacion\n"
        .asciz "4. Division Entera\n"
        .asciz "5. Potencia\n"
        .asciz "6. Factorial\n"
        .asciz "7. Salir\n"
      .equ tamanio_menu, .-menu

msg_error: .asciz "Opcion Invalida, intente de nuevo\n"
      .equ tamanio_msg_error, .-msg_error

msg_num1: .asciz "Ingrese el primer numero:"
      .equ tamanio_numero1, .-msg_num1

msg_num2: .asciz "Ingrese el segundo numero:"
      .equ tamanio_numero2, .-msg_num2

msg_base:  .asciz "Ingrese numero base:"
      .equ tamanio_base, .-msg_base
msg_exp:   .asciz "Ingrese potencia:"
      .equ tamanio_exp, .-msg_exp

msg_fact:  .asciz "Ingrese numero (n!):"
      .equ tamanio_fact, .-msg_fact

msg_resultado: .asciz "El resultado es:"
      .equ tamanio_resultado, .-msg_resultado
msg_salto:     .asciz "\n"
      .equ tamanio_salto, .-msg_salto

   .bss
buffer_entrada:   .skip 16
   .equ tamanio_buffer, .-buffer_entrada
buffer_salida:    .skip 16
   .equ tamanio_buffer_salida, .-buffer_salida


   .text
   .global _start

_start:
menu_loop:
   mov x8, #64   //Indico que quiero que el sistema hago, en este caso escribir
   mov x0, #1    //Selecciono el canal de salida, en este caso la consola 
   ldr x1, =menu  //Cargo al registro x1 la direccion de mi mensaje
   mov x2, #tamanio_menu //Le indico cuantos bytes debe escribir en consola
   svc #0        //pauso el programa para que entre el kernel 

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa

   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   cmp w0, #1
   blt error_ingreso

   //Saltos a las subrutinas "suma, resta, mul..." (Cuando ya las tengan listas quiten el comentario)
   cmp w0, #1
   beq suma
   cmp w0, #2
   beq resta
   cmp w0, #3
   beq mult
  /* cmp w0, #4
   beq div                //division
   cmp w0, #5
   beq pot                //potencia
   cmp w0, #6 */
   beq fact               //factorial
   cmp w0, #7
   bgt error_ingreso
   beq salida

   b menu_loop

error_ingreso:
   bl mensaje_error
   b menu_loop
   
salida:
   mov x8, #93   //Syscall que indica salida 
   mov x0, #0    //retorno seguro que confirma al sistema que no hubieron errores
   svc #0        //le devuelvo el controla al kernel

atoi:
   mov w0, #0    //acumulador
   mov w3, #10   //multiplicador para correr el numero

atoi_loop:
   ldrb w2, [x1], #1 //Lectura de byte de entrada
   cmp w2, #10   
   beq atoi_fin
   cmp w2, #'0'
   blt atoi_error
   cmp w2, #'9'
   bgt atoi_error
   sub w2, w2, #'0'
   mul w0, w0, w3
   add w0, w0, w2
   b atoi_loop
   ret

atoi_fin:
   ret

atoi_error:
   mov w0, #-1
   ret

mensaje_error:
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_error
   mov x2, #tamanio_msg_error
   svc #0
   ret

suma: 
   //solicitar primer numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num1
   mov x2, #tamanio_numero1
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w19, w0

   //solicitar segundo numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num2
   mov x2, #tamanio_numero2
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w20, w0

   //sumar numeros
   add w21, w19, w20
   
   //Imprimir encabezado
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_resultado
   mov x2, #tamanio_resultado
   svc #0
   
   //conversion del entero a asci
   ldr x1, =buffer_salida
   add x1, x1, #15 
   mov w0, w21
   bl itoa
  //imprimir resultado con salto de linea
   mov x8, #64
   mov x0, #1
   svc #0
   
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_salto
   mov x2, #tamanio_salto
   svc #0
 
   b menu_loop

resta:
   //solicitar primer numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num1
   mov x2, #tamanio_numero1
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w19, w0

   //solicitar segundo numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num2
   mov x2, #tamanio_numero2
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w20, w0
   
   //restar numero
   sub w21, w19, w20

   //imprimir encabezado de resultado
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_resultado
   mov x2, #tamanio_resultado
   svc #0

   //convertir entero a asci 
   ldr x1, =buffer_salida
   add x1, x1, #15
   mov w0, w21
   bl itoa

   //Imprimir resultado
   mov x8, #64
   mov x0, #1
   svc #0

   //imprimir salto de linea
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_salto
   mov x2, #tamanio_salto
   svc #0
  
   b menu_loop

mult:
   //solicitar primer numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num1
   mov x2, #tamanio_numero1
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w19, w0

   //solicitar segundo numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_num2
   mov x2, #tamanio_numero2
   svc #0

   mov x8, #63   //Syscall para indicar lectura
   mov x0, #0    //Seleccion de canal, en este caso el teclado
   ldr x1, =buffer_entrada  //Carga al registro x1 el mensaje escrito
   mov x2, #tamanio_buffer  //Cuantos bytes se deben leer
   svc #0        //Entrada del kernel para ejecutar el programa
   
   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w20, w0
  
   //multiplicar
   mul w21, w19, w20

   //imprimir encabezado de resultado
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_resultado
   mov x2, #tamanio_resultado
   svc #0

   //convertir entero a asci 
   ldr x1, =buffer_salida
   add x1, x1, #15
   mov w0, w21
   bl itoa

   //Imprimir resultado
   mov x8, #64
   mov x0, #1
   svc #0

   //imprimir salto de linea
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_salto
   mov x2, #tamanio_salto
   svc #0
  
   b menu_loop

//AQUI VAYAN AGREGANDO LAS SUBRUTINAS DE LAS OPERACIONES QUE FALTAN

fact:
   //solicitar el numero
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_fact
   mov x2, #tamanio_fact
   svc #0

   mov x8, #63
   mov x0, #0
   ldr x1, =buffer_entrada
   mov x2, #tamanio_buffer
   svc #0

   ldr x1, =buffer_entrada
   bl atoi
   cmp w0, #-1
   beq error_ingreso
   mov w19, w0    //w19 = n

   //factorial iterativo: w21 = acumulador (0! = 1! = 1)
   mov w21, #1
   cmp w19, #0
   beq fact_imprimir    //si n = 0 el resultado ya es 1
   cmp w19, #1
   beq fact_imprimir    // si n = 1 el resultado ya es 1

   mov w22, #2          //w22 = contador, es decir que arranca en 2

fact_loop:
   cmp w22, w19
   bgt fact_imprimir    //si contador > n, se termina
   mul w21, w21, w22
   add w22, w22, #1
   b fact_loop

fact_imprimir:
   //imprimir encabezado del resultado
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_resultado
   mov x2, #tamanio_resultado
   svc #0

   //convertir entero a ascii
   ldr x1, =buffer_salida
   add x1, x1, #15
   mov w0, w21
   bl itoa

   //imprimir resultado
   mov x8, #64
   mov x0, #1
   svc #0

   //imprimir el salto de linea
   mov x8, #64
   mov x0, #1
   ldr x1, =msg_salto
   mov x2, #tamanio_salto
   svc #0

   b menu_loop

//DEJEN EL ITOA SIEMPRE DE ULTIMO


itoa:
  mov w4, #10
  mov x2, #0 
  mov w5, #0

  //numero negativo?
  cmp w0, #0
  bge itoa_loop

  mov w5, #1
  neg w0, w0

itoa_loop:
   udiv w3, w0, w4 // w3= w0/10
   msub w2, w3, w4, w0 // Calcular residuo y guardarlo en w2
   add w2, w2, #'0'  //sumar el codigo asci de 0 que es 48 al residuo
   strb w2, [x1, #-1]!  //retrocede 1 byte en ram y guarda w2 
   add x2, x2, #1  //incrementa el conteo de caracteres que ya fueron contados
   mov w0, w3   //El cociente pasa a ser el nuevo dividendo en la siguiente iteracion
   cbnz w0, itoa_loop  //compara la bandera zero, si esta no es 1 hace otra iteracion
   
   //Colocar signo "-" al resultado
   cbz w5, itoa_fin
   mov w2, #'-'
   strb w2, [x1, #-1]!
   add x2, x2, #1
   
itoa_fin:
   ret
