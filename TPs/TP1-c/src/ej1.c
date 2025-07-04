#include "ej1.h"

/**
 * Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej1
 */
bool EJERCICIO_1_HECHO = true;

/**
 * Convierte una imagen dada (`src`) a escala de grises y la escribe en el
 * canvas proporcionado (`dst`).
 *
 * Para convertir un píxel a escala de grises alcanza con realizar el
 * siguiente cálculo:
 * ```
 * luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
 * ```
 *
 * Como los píxeles de las imágenes son RGB entonces el píxel destino será
 * ```
 * rojo  = luminosidad
 * verde = luminosidad
 * azul  = luminosidad
 * alfa  = 255
 * ```
 *
 * Parámetros:
 *   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
 *             canal.
 *   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
 *             canal.
 *   - width:  El ancho en píxeles de `src` y `dst`.
 *   - height: El alto en píxeles de `src` y `dst`.
 */
void ej1(
	rgba_t* dst,
	rgba_t* src,
	uint32_t width, uint32_t height
) {
	float float_rojo = 0.2126;
	float float_verde = 0.7152;
	float float_azul = 0.0722;

	uint32_t pixeles_total = width * height;

	for (uint32_t i = 0; i < pixeles_total; i++)
	{
		uint8_t rojo = src[i].r; // extraigo el valor de rojo
		uint8_t verde = src[i].g; // extraigo el valor de verde
		uint8_t azul = src[i].b; // extraigo el valor de azul

		float luminosidad = (float_rojo * rojo) + (float_verde * verde) + (float_azul * azul);
		uint8_t luminosidad_byte = (uint8_t)luminosidad;

		dst[i].r = luminosidad_byte; // r es el valor de rojo
		dst[i].g = luminosidad_byte; // g es el valor de verde
		dst[i].b = luminosidad_byte; // b es el valor de azul
		dst[i].a = 255; // 255 es el valor de alfa	
	}
}
