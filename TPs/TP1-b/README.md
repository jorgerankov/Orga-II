# Programación Assembly x86 - Convención C
Arquitectura y Organización del Computador

**Entrega:** 12/09/2024

**Reentrega del TP1 completo (tp1-a, tp1-b y tp1-c):** 03/10/2024

-------------
En este taller vamos a trabajar con código `C` y `ASM` para ejercitar el uso y adhesión a contratos estructurales y comportamentales. El punto 1 se trata de un repaso de los conceptos vistos en clase, necesarios para encarar la programación en forma efectiva. El resto de los puntos se resuelven programando determinadas rutinas en assembly.

## Preparación: actualizando su fork del repositorio grupal
Es importante que, para este tp1-b y el próximo tp1-c, **no creen un nuevo fork de este repositorio** si no que actualicen el repositorio grupal que estaban utilizando para el tp1-a.
Estas son las instrucciones para sincronizar su fork grupal con el nuevo contenido de esta parte del TP1.
Cuando subamos el tp1-c, o si actualizamos algún archivo del tp1-a o tp1-b, deberán seguir estas mismas instrucciones para sincronizar su repositorio con el de la cátedra.

Para actualizar su fork con cambios del repositorio de la cátedra, que llamaremos "upstream", deben ejecutar los siguientes comandos desde la línea de comandos, estando ubicados dentro del clon local de su fork (de no recordar como clonar localmente su fork del repositorio grupal, revisitar las instrucciones del tp0):

1. Agregar el repositorio de la cátedra como *upstream* remoto:
   - Si usaron https:
	```sh
	git remote add upstream https://git.exactas.uba.ar/ayoc-doc/individual-<id_cuatrimestre>.git
	```
   - Si usaron ssh:
	```sh
	git remote add upstream git@git.exactas.uba.ar:ayoc-doc/individual-<id_cuatrimestre>.git
	```
2. Traer el último estado del upstream
```sh
git fetch upstream
```
3. Moverse al branch principal (`master`) si habían cambiado de branch, ya que los cambios se sincronizarán en dicho branch únicamente
```sh
git checkout master
```
4. Combinar los cambios locales con los del *upstream*
```sh
git merge upstream/master
```

Es posible que al ejecutar el merge les aparezca CONFLICT y diga que arreglen los conflictos para poder terminar el merge.
En ese caso, deben:
1. Resolver los conflictos, ya sea con la herramienta de resolución de conflictos de VScode o a mano (se recomienda utilizar VScode).
2. Una vez resueltos los conflictos, tomar nota de cuales archivos tenían conflictos que fueron resueltos y ejecutar:
```sh
git add <archivos modificados>
git commit -m "Merge con actualizaciones cátedra"
git push origin
```

## Ejercicio 0: Conceptos generales

En este punto introductorio deberán responder algunas preguntas conceptuales relacionadas a lo que vimos en las clases teóricas y en la presentación de hoy. Las preguntas tienen que ver con _convención de llamada y bibliotecas compartidas_.

- :pen_fountain: ¿Qué entienden por convencion de llamada?

Se entiende como convencion de llamada a una serie de reglas/condiciones que explican de que manera pasar los parametros a las funciones y como se retornan los valores de las mismas dentro del programa.
Ademas, permite manejar los registros y la pila de las funciones que llamemos/utilicemos.


- ¿Cómo está definida en la ABI de System V para 64 y 32 bits?

**ABI de System V (64 bits):**

- Parametros:  
	Enteros / Punteros: Se pasan en RDI, RSI, RDX, RCX, R8 y R9. En caso de haber mas, se guardaran en la pila  
	Flotantes: Se pasan en XMM0 a XMM7. En caso de haber mas, se guardaran en la pila

- Retorno:  
	Enteros / Punteros: Se pasa en RAX  
	Flotantes: Se pasan en XMM0

- Base pointer:  
	Stack frame: Se usa RBP  
	Llamado a funcion: Se usa RBP -> Se guarda en la pila y se restaura al final de la funcion

- Reg. Volatiles (La función llamada puede modificarlos sin guardar sus valores originales):  
	RAX, RCX, RDX, RSI, RDI, R8 a R11, y XMM0 a XMM15

- Reg. No volatiles (La función llamada debe guardar los valores originales y restaurarlos antes del ret):  
	RBX, RBP, R12 a R15


**ABI de System V (32 bits):**

- Parametros:  
	Enteros: Se pasan en EAX, ECX y EDX. Si hay mas, se pasan en la pila  
	Flotantes: Se pasan en XMM0 a XMM7. Si hay mas, se pasan en la pila
	
- Retorno:  
	Enteros / Punteros: Se pasa en EAX  
	Flotantes: Se pasan en XMM0

- Base pointer:  
	Stack frame: Se usa EBP

- Reg. Volatiles (La función llamada puede modificarlos sin guardar sus valores originales):  
	EAX, ECX y EDX

- Reg. No volatiles (La función llamada debe guardar los valores originales y restaurarlos antes del ret):  
	EBX, EBP, ESI y EDI  


- :pen_fountain: ¿Quién toma la responsabilidad de asegurar que se cumple la convención de llamada en `C`? ¿Quién toma la responsabilidad de asegurar que se cumple la convención de llamada en `ASM`?

En **C**, el compilador es quien se encarga de asegurar que se cumple la convención de llamada (ademas de ser el que genera el código ensamblador correspondiente), mientras que en **ASM** es directamente el programador quien se encarga de esto (debe seguir las reglas establecidas en el lenguaje ensablador)

- :pen_fountain: ¿Qué es un stack frame? 

Un **stack frame** es un conjunto de bloques de memoria distribuidos en la pila de un programa que se esta ejecutando, y cumple el objetivo de especificar la forma en que se invocará a una función, para colocar o sacar los parámetros de una función y sus variables locales tal como se pide en el programa realizado


- ¿A qué se le suele decir **prólogo y epílogo**?

El **prologo** es el conjunto de instrucciones que se ejecutan al inicio de una función para establecer y configurar las condiciones iniciales del stack frame. Mientas que el **epilogo** es el conjunto de instrucciones que se ejecutan al final de una función para liberar y restaurar el stack frame antes antes de finalizar la función


- :pen_fountain: ¿Cuál es el mecanismo utilizado para almacenar **variables temporales**?

Se pueden almacenar de dos formas:

**Almacenamiento en la pila**:
	Almacena variables temporales a nivel de función. Las variables necesarias se almacenan en el stack frame, que reserva espacio en la pila para realizar esta tarea.

**Almacenamiento en Registros**:
	Sirve para almacenar variables temporales que se necesiten de manera rapida y no vayan a ser usadas por mucho tiempo en el programa. Esta forma es mucho mas rapida que la memoria de pila, pero el número de registros es menor que la cantidad de datos que se pueden almacenar en la pila.


- :pen_fountain: ¿A cuántos bytes es necesario alinear la pila si utilizamos funciones de `libc`? 

En arquitecturas de 64 bits, la alineación de la pila es (la mayoria de las veces) requerida a 16 bytes para optimizar el acceso a los datos, evitar errores en el programa y cumplir con las convenciones de llamada.

- ¿Si la pila está alineada a 16 bytes al realizarse una llamada función, cuál va a ser su alineamiento al ejecutar la primera instrucción de la función llamada?

Al ejecutar la primer instrucción de la función llamada, la pila puede llegar a estar alineada a 8 bytes, ya que el puntero de pila se desplaza 8 bytes para almacenar la dirección de retorno de la función.


- :pen_fountain: Una actualización de bibliotecas realiza los siguientes cambios a distintas funciones. ¿Cómo se ven impactados los programas ya compilados?
_Sugerencia:_ Describan la convención de llamada de cada una (en su versión antes y después del cambio).
	- Una biblioteca de procesamiento cambia la estructura `pixel_t`:
		* Antes era `struct { uint8_t r, g, b, a; }`
		* Ahora es `struct { uint8_t a, r, g, b; }`
			¿Cómo afecta esto a la función `void a_escala_de_grises(uint32_t ancho, uint32_t alto, pixel_t* data)`?  

			Asumiendo que la funcion a_escala_de_grises convierte un pixel en un tono gris (variando en su intensidad):  

			Antes del cambio:  
				a_escala_de_grises calcula un valor promedio usando los valores de r, g y b.  
				Los elementos estan ordenados como: r -> g -> b -> a  
  
			Después del cambio:  
				a_escala_de_grises devuelve un cálculo del valor de gris incorrecto, ya que el canal alpha desplaza a todos los colores hacia la derecha.  
				Los elementos estan ordenados como: a -> r -> g -> b  
			  

			Los programas ya compilados probablemente interpreten de forma incorrecta los píxeles si se ejecutan con la nueva versión de la biblioteca, ya que las direcciones de memoria de pixel_t cambiaron, pero el codigo compilado no fue recompilado para poder obtener los datos actuales. Por ejemplo, si paso 20, 50, 50, 50 como parametros en la funcion despues del cambio, al no estar el programa recompilado va a tomar mis datos de la forma 50, 50, 50, 20, que probablemente no sea el resultado esperado en los tests de prueba.
  

	- Se reordenan los parámetros (i.e. intercambian su posición) de la función `float sumar_floats(float* array, uint64_t tamaño)`.  

		Antes del cambio:  
			sumar_floats va a sumar todos los elementos (float) de un array de un tamaño determinado en la funcion  
  

		Después del cambio:  
			sumar_floats va a tomar a 'tamano' como un puntero a un array, mientras que a su vez va a tomar a 'array' como un valor de 64 bits que indica la cantidad de elementos en el array.  
			  
		Los programas ya compilados	tomaran a 'tamano' como un puntero, lo que probablemente va a generar accesos a memoria incorrectos, y el puntero al array será tratado como el tamaño, generando fallos en el programa.  
		  

	- La función `uint16_t registrar_usuario(char* nombre, char* contraseña)` registra un usuario y devuelve su ID. Para soportar más usuarios se cambia el tipo de retorno por `uint64_t`.  
	  
	Antes del cambio:  
		Se registran usuarios y sus contraseñas, y se denomina al ID del usuario como un valor de 16 bits unsigned.  
		  
	Después del cambio:  
		Se registran usuarios y sus contraseñas, pero ahora se denomina al ID del usuario como un valor de 64 bits unsigned.  
		  
	Los programas ya compilados tendran problemas con el valor que devuelve la funcion, ya que, al no haber sido recompilado, solo los 16 bits menos significativos de uint64_t van a ser guardados, mientras que los otros 48 bits restantes se van a perder, generando un gasto de recursos innecesario en el programa y probablemente comportamientos no deseados.  
	  
	- La función `void cambiar_nombre(uint16_t user_id, char* nuevo_nombre)` también recibe la misma actualización. ¿Qué sucede ahora?  
	  
	Antes del cambio:  
		cambiar_nombre va a recibir un ID de usuario de 16 bits unsigned y no retorna nada, ya que es de tipo void
  
	  
	Después del cambio:  
		cambiar_nombre recibe un ID de usuario de 64 bits unsigned y no retorna nada, ya que es de tipo void  
		  
	Los programas ya compilados van a tener problemas de compatibilidad debido al cambio de tamaño de user_id, ya que, por ejemplo, al querer llamar a la funcion sin haberla recompilado y le pasamos un valor de tipo uint16_t, la funcion va a estar esperando un valor de tipo uint64_t, generando que user_id contenga valores basura.  
	Ademas, el parametro nuevo_nombre puede no estar guardado en el user_id deseado, ya que, al no haber recompilado la funcion, user_id puede estar recibiendo datos no tan acertados o hasta indefinidos.  
  
	- Se reordenan los parámetros de `int32_t multiplicar(float a, int32_t b)`.  
	Antes del cambio:  
		la funcion multiplicar devuelve un int32_t, donde 'a' toma un float y 'b' toma un int32_t  
		  
	Después del cambio:  
		la funcion multiplicar devuelve un int32_t, donde 'b' toma un int32_t y 'a' toma un float  
		  
	Los programas ya compilados van a tener problemas de compatibilidad porque los parámetros van a pasarse de forma incorrecta en la nueva funcion. 'b' (tipo int32_t) va a ser pasado como un float, mientras que 'a' (tipo float) va a ser pasado como un int32_t. Esto puede causar resultados incorrectos, ya que la función recibirá valores incorrectos y probablemente provoque cálculos erróneos y un comportamiento no esperado en el programa.

	
Una vez analizados los casos específicos describan la situación general:
- :pen_fountain: ¿Qué sucede si una función externa utilizada por nuestro programa _(Es decir, que vive en una **biblioteca compartida**)_ cambia su interfaz (parámetros o tipo devuelto) luego de una actualización?  
En caso que la funcion externa no haya sido recompilada pero la funcion si:  
  
* Puede llevar a incompatibilidad de parametros: La funcion puede que esté esperando un parametro distinto al de la función externa modificada  
* Puede haber error de tipo de retorno: El programa podría querer procesar la devolucion de un valor incorrecto, o distinto a lo dado por la funcion externa  
* Puede haber errores de ejecución: Si el programa no admite compatibilidad con la nueva interfaz, podría no ejecutarse directamente en el código recompilado  
* Puede romper la funcionalidad del programa  
Ademas, si no se actualizan tanto el programa como la funcion externa, no se puede garantizar la compatibilidad y el funcionamiento correcto de nuestro trabajo

## Ejercicio 1: C/ASM pasaje de parámetros

En este punto y en los que siguen vamos a desarrollar funciones en `ASM` que son llamadas desde código `C` haciendo uso de la convención de llamada de 64 bits. Pueden encontrar el código vinculado a este checkpoint en [checkpoint2.asm](src/checkpoint2.asm) y [checkpoint2.c](src/checkpoint2.c), la declaración de las funciones se encuentra en [checkpoints.h](src/checkpoints.h). También ahí mismo se explica qué debe hacer dicha función.

Programen en assembly las siguientes funciones:

- `alternate_sum_4`
- `alternate_sum_4_using_c`
- `alternate_sum_4_simplified`
- `alternate_sum_8`
- `product_2_f`
- `product_9_f`

El archivo que tienen que editar es [checkpoint2.asm](src/checkpoint2.asm). Para todas las declaraciones de las funciones en `ASM` van a encontrar la firma de la función. Completar para cada parámetro en qué registro o posición de la pila se encuentra cada uno.

> *La siguiente información aplica para este ejercicio y los siguientes*

### Compilación y Testeo

El archivo [`main.c`](src/main.c) es para que ustedes realicen pruebas básicas de sus funciones. Siéntanse a gusto de manejarlo como crean conveniente.
Para compilar el código y poder correr las pruebas cortas implementadas en main deberá ejecutar `make main` y luego `./runMain.sh`.
En cambio, para compilar el código y correr las pruebas intensivas deberá ejecutar `./runTester.sh`.
El programa puede correrse con `./runMain.sh` para verificar que no se pierde memoria ni se realizan accesos incorrectos a la misma.

#### Pruebas intensivas (Testing)

Entregamos también una serie de *tests* o pruebas intensivas para que pueda verificarse el buen funcionamiento del código de manera automática. Para correr el testing se debe ejecutar `./runTester.sh`, que compilará el *tester* y correrá todos los tests de la cátedra.
Luego de cada test, el *script* comparará los archivos generados por su TP con las soluciones correctas provistas por la cátedra.
También será probada la correcta administración de la memoria dinámica.

## Ejercicio 2: Recorrido de estructuras C/ASM

En este checkpoint vamos implementar código vinculado al acceso de estructuras. En particular, vamos a usar dos estructuras muy similares a `lista\char_t` del TP1a y vamos a implementar en `ASM` la función que contaba la cantidad total de elementos de la lista, para ambas estructuras. Pueden encontrar el código vinculado a este checkpoint en [`checkpoint3.c`](src/checkpoint3.c) y [`checkpoint3.asm`](src/checkpoint3.asm).

Las definiciones de las estructuras las pueden encontrar en el archivo [`checkpoints.h`](src/checkpoints.h). Las de los nodos correspondientes son las siguientes:

```c
	typedef struct nodo_s {
		struct nodo_s* next;   // Siguiente elemento de la lista o NULL si es el final
		uint8_t categoria;     // Categoría del nodo
		uint32_t* arreglo;     // Arreglo de enteros
		uint32_t longitud;     // Longitud del arreglo
	} nodo_t;
	
	typedef struct __attribute__((__packed__)) packed_nodo_s {
		struct packed_nodo_s* next;   // Siguiente elemento de la lista o NULL si es el final
		uint8_t categoria;     // Categoría del nodo
		uint32_t* arreglo;     // Arreglo de enteros
		uint32_t longitud;     // Longitud del arreglo
	} packed_nodo_t;
```

Programen en assembly las funciones:

1. `uint32_t cantidad_total_de_elementos(lista_t* lista)`,
2. `uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista)`

El archivo que tienen que editar es [`checkpoint3.asm`](src/checkpoint3.asm). Para todas las declaraciones de las funciones en `ASM` van a encontrar la firma de la función. Completar para cada parámetro en qué registro o posición de la pila se encuentra cada uno.

## Ejercicio 3: Memoria dinámica con strings

En este checkpoint vamos implementar código vinculado para el manejo de strings. Recuerden que `C` representa a los strings como una sucesión de `char`'s terminada con el caracter nulo `'\0'`. Pueden encontrar el código vinculado a este checkpoint en [`checkpoint4.c`](src/checkpoint4.c) y [`checkpoint4.asm`](src/checkpoint4.asm). Recuerden que para realizar el clonado de un string, van a tener que usar memoria dinámica.
Luego analizaremos el uso de la pila.

Programen en assembly las siguientes funciones. El archivo que tienen que editar es [`checkpoint4.asm`](src/checkpoint4.asm).

1. `strLen`
2. `strPrint`
3. `strClone`
4. `strCmp`
5. `strdelete`
    
## Ejercicio 4: La pila...
### Preliminar
Para este ejercicio utilizarán el debugger `gdb` para indagar en un binario.
Se recomienda **fuertemente** instalar la extensión [gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard) que nos generará una interfaz más informativa y fácil de entender al momento de debuggear.
La instalación consiste en descargar un archivo al `home` de la computadora, no requiere permisos especiales, por lo que pueden hacerlo incluso en las computadoras del laboratorio.

Pueden instalar `gdb dashboard` utilizando el siguiente comando:
```sh
wget -P ~ https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit
```
Además, para habilitar syntax highlighting, pueden opcionalmente instalar el paquete `pygments` de python con el siguiente comando:
```sh
pip install pygments
``` 

### Ejercicio
En una máquina de uno de los labos de la facultad, nos encontramos un _pendrive_ con un programa ejecutable de linux adentro.
Investigando un poco vimos que se trata de un programa de prueba interno de una importante compañía de software, que sirve para probar la validez de claves para su sistema operativo.
Si logramos descubrir la clave... bueno, sería interesante...
Para ello llamamos por teléfono a la división de desarrollo en USA, haciéndonos pasar por Susan, la amiga de John (quien averiguamos estuvo en la ECI dando una charla sobre seguridad).
De esa llamada averiguamos:

- El programador que compiló el programa olvidó sacar los símbolos de *debug* en la función que imprime el mensaje de autenticación exitosa/fallida.
  Esta función toma un único parámetro de tipo `int` llamado `miss` que utiliza para definir y imprimir un mensaje de éxito o de falla de autenticación.
- La clave está guardada en una variable local (de tipo `char*`) de alguna función en la cadena de llamados de la función de autenticación.

Se pide:

1. Correr el programa con `gdb` y poner un breakpoint en la función que imprime el mensaje de autenticación exitosa/fallida.
2. :pen_fountain: Imprimir una porción adecuada del stack, con un formato adecuado para ver si podemos encontrar la clave.  

3. :pen_fountain: ¿En que función se encuentra la clave?  
	La clave se encuentra en la función strcmp@plt, mas precisamente en la direccion 0x0000555555559330 (rdi)  
  
	Explicar el mecanismo de como se llega a encontrar la función en la que se calcula la clave.  
  

	```
	gdb ./validate_key			# Abrimos el archivo con gdb
	info functions			# Listamos todas las funciones
	b strcmp@plt			# Hacemos un breakpoint en strcmp@plt (asumimos que tendria algun dato de la clave, sea el lugar donde se localizaba la clave o directamente la clave a comparar)
	r 12345			# Ejecutamos el breakpoint con un parametro random de tipo int para que logre acceder a esa funcion
	x/s 0x0000555555559330			# Vemos si encontramos algo dentro del registro rdi
				# Encontramos "clave_192.168.0.246" (parece ser un char*)
	x/s 0x00007fffffffe001			# Vemos si encontramos algo dentro del registro rsi
				# Encontramos 123545
	
				# Al pasarle "clave_192.168.0.246" como parametro a la funcion ./validate_key,
				# Devuelve "Enhorabuena! Tu sistema ahora es totalmente legal y está autorizado!"
				# No encontramos nada mas relevante en strcmp@plt, y lo encontrado funciona para acceder al programa
	exit			# Salimos de gdb habiendo logrado "hackear" el programa


### Ayuda de GDB:
- :exclamation: El comando `backtrace` de gdb permite ver el stack de llamados hasta el momento actual de la ejecución del programa, y el comando `frame` permite cambiar al frame determinado. 
  `info frame` permite ver información del frame activo actualmente.
- Los parámetros pasados al comando `run` dentro de gdb se pasan al binario como argumentos, por ejemplo `run clave` iniciará la ejecución del binario cargado en gdb, pasándole un argumento con valor "clave".
- El comando `p {tipo} dirección` permite pasar a `print` cómo se debe interpretar el contenido de la dirección.  
Por ejemplo: `p {char*} 0x12345678` es equivalente a `p *(char**) 0x12345678`.  
  - En el ejemplo mostrado, sabemos que en la dirección `0x12345678` hay un puntero a `char`, por lo que le decimos a `gdb` que interprete el contenido de esa dirección como un puntero a `char`.
- El comando `p ({tipo} dirección)@cantidad` permite imprimir una cantidad de elementos de un tipo determinado a partir de una dirección.
Esto es sumamente práctico cuando conocemos la dirección y el tipo de una variable y queremos ver su contenido.
