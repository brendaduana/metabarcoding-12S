# Metabarcoding 12S

El monitoreo de fauna silvestre utilizando DNA ambiental (eDNA) han sido utilizado en diversos ecosistemas.

Anacapa, procesa las lecturas de eDNA y asigna taxonomía.

Incluye un paquete de R (ranacapa) para conocer las diferencias de biodiversidad entre muestras.

Las lecturas de DNA ambiental se deben comparar con secuencias de referencias para las  asignaciones taxonómicas

Incluye una herramienta rCRUX para crear bases de datos de referencia personalizadas para el barcode elegido.

Anacapa procesa lecturas de una plataforma Miseq

1. Conserva lecturas de calidad
2. Elimina secuencias quiméricas
3. Asigna "Variantes de secuencias de Amplicones" (ASV), a la mejor coincidencia en la base de datos de secuencias de referencias.

Emplean un algoritmo del ancestro común más bajo bayesiano para generar tanto la asignación taxonómica como una estimación de confianza para cada nivel taxonómico, hasta llegar a nivel de especie, basada en el análisis de las 100 secuencias con mayor coincidencia. 




























