# Metabarcoding 12S

El monitoreo de fauna silvestre utilizando DNA ambiental (eDNA) han sido utilizado en diversos ecosistemas.

Anacapa procesa las lecturas de eDNA y asigna taxonomía.

Incluye un paquete de R (ranacapa) para conocer ls diferencias de biodiversidad entre muestras.

Las lecturas de DNA ambiental se dben comparar con secuencias de referencias con asignaciones taxonómicas

Incluye una herramienta CRUX para crear bases de datos de referencia personalizadas para el barcod elegida.

Anacapa procesa lecturas de una plataforma Miseq

1. Conserva lecturas de calidad
2. Elimina secuencias quiméricas
3. Asigna "Variantes de secuencias de Amplicones" (ASV), a la mejor coincidencia en la base de datos de secuencias de referencias.

Emplean un algoritmo del ancestro común más bajo bayesiano para generar tanto la asignación taconómica como una una estimacion de confianza para cada nivel taxonómico, hasta la especies, basada en el análisis de las 100 secuencias con mayor coincidencia. 

Es necesario instalar un conjunto de software en la maquina de análisis.

Contenedor del pipeline, está en Ubuntu Linux con todas las dependencias preinstaladas.

Es compatible con cluster mediante Singularity.





























