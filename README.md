# Manual de usuario:

Para ejecutar el compilador, se debe ejecutar el fichero *Makefile*, tras esto se crearán
los ficheros *.tab.h*, *.tab.c* y el ejecutable. Tras esto habrá que ejecutar el binario y 
pasarle como parámetro el fichero que contiene el código en pascal y a su vez indicarle en que fichero con extensión *.s* se debe volcar el 
resultado en el que tendremos el programa resultante en ensamblador:

`./ejecutable < test_cod2.mp > miprograma1.s`

Una vez tengamos el fichero *.s* podremos lanzarlo con un programa que ejecute mips.

--------------------------------------------

# User manual:

To execute the compiler, *Makefile* must be executed, after that, the files *.tab.h*, *.tab.c* and the executable will be created. After this we will have to execute the binary and
pass as a parameter the file that contains the code in pascal and also indicate in which file with *.s* extension the result of the resulting assembler program should be dumped:

`./ejecutable < test_cod2.mp > myprogram.s`

Once we have the *.s* file, we can launch it with a program that executes mips.
