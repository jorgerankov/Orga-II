#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3

void print_scoreboard(screen pantalla)
{
	for (int i = 0; i < CANT_PONGS; i++)
	{
		// Calculamos la posición en memoria para cada puntaje
        uint32_t* current_task_record = (uint32_t*) (SHARED_SCORE_BASE_VADDR + i * sizeof(uint32_t) * 2);

		// Leemos los puntajes de cada jugador
        uint32_t player1_score = current_task_record[0];
        uint32_t player2_score = current_task_record[1];

		// Definimos coordenadas para imprimir los puntajes en pantalla
        uint32_t y_position = 3 + i * 3; // Espaciado vertical entre instancias
        uint32_t x_position = 2;

		// Imprimimos el puntaje de cada jugador
        task_print(pantalla, "Pong ", x_position, y_position, C_FG_WHITE);
        task_print_dec(pantalla, i + 1, 1, x_position + 5, y_position, C_FG_WHITE);
        
        task_print(pantalla, "P1: ", x_position, y_position + 1, C_FG_CYAN);
        task_print_dec(pantalla, player1_score, 2, x_position + 4, y_position + 1, C_FG_CYAN);

        task_print(pantalla, "P2: ", x_position + 10, y_position + 1, C_FG_MAGENTA);
        task_print_dec(pantalla, player2_score, 2, x_position + 14, y_position + 1, C_FG_MAGENTA);
	}
}

void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
		// Limpiamos la pantalla antes de actualizar
        task_draw_box(pantalla, 0, 0, WIDTH, HEIGHT, ' ', C_BG_BLACK);

		// Imprimimos los puntajes de cada instancia de Pong
        print_scoreboard(pantalla);

		// Mostramos la pantalla actualizada
        syscall_draw(pantalla);

		// Dormimos un poco antes de la siguiente actualización para evitar parpadeos rápidos
        task_sleep(50);
	}
}
