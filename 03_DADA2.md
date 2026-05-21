### DADA2

El proceso de secuenciación de amplicones introduce errores lo que dificulta la interpretación de los resultados. `DADA2` implementa un algoritmo que modela los errores introducidos durante la secuenciación de amplicones y utiliza dicho modelo para inferir la verdadera composición de la muestra. Reemplaza el paso de OTU, generando en su lugar tablas de mayor resolución de ASVs.
 
DADA2 espera que no haya bases no biológicas, por ejemplo, los cebadores de PCR que se incluyeron en la región del amplicón.

Una vez teniendo los *fastq demultiplexados* se puede comenzar el proceso.

El resultado del pipeline es una tabla de características de ASV que contiene filas correspondientes a las muestras y columnas a las ASV en esa muestra.

### Preparación del entorno

Ingresa a R

En la consola puedes escribir tu ruta donde están los archivos crudos:

En un script instala DADA2:

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install("dada2")
```

Cargar las librerias:

```r
library(dada2)
library(stats)
library(ShortRead)
library(ggplot2)
```

Ahora se definen rutas donde se encuentran los archivos de entrada que necesita DADA2:

```r
setwd("C:/Users/HP/OneDrive - Universidad Autónoma Metropolitana/Documentos/LandaLab/amplicones_paola/1.datoscrudos")
```

Y confirmar con:

```r
getwd()
```
Cargar la carpeta con los FASTQ recortados por Cutadapt:

```r
Cutadapt_fastq_directory <- path.expand("~/data/processed/01.cutadapt")
```

Crear la carpeta donde se guardarán los resultados de DADA2:

```r
Dada2_results_directory <- path.expand("~/results/07.dada2")
```

Crear las subcarpetas de salida:

```r
Dada2_logs_directory <- file.path(Dada2_results_directory, "logs")
Dada2_filtered_directory <- file.path(Dada2_results_directory, "filtered")
Dada2_tables_directory <- file.path(Dada2_results_directory, "tables")

dir.create(Dada2_results_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_logs_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_filtered_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_tables_directory, recursive = TRUE, showWarnings = FALSE)
```

Cargar los sets de datos limpios de adaptadores y primers:

```r
Forward_reads <- sort(list.files(
  Cutadapt_fastq_directory,
  pattern = "_R1_trimmed.fastq.gz$",
  full.names = TRUE
))

Reverse_reads <- sort(list.files(
  Cutadapt_fastq_directory,
  pattern = "_R2_trimmed.fastq.gz$",
  full.names = TRUE
))
```

Extrae los nombre de las muestras:

```r
Sample_names <- basename(Forward_reads)
Sample_names <- sub("_R1_trimmed.fastq.gz", "", Sample_names)
```

Verificar que esten los archivos:

```r
length(Forward_reads)
length(Reverse_reads)
```

Se revisan los perfiles de calidad de las lecturas forward y reverse usando la función `plotQualityProfile()`  Ejecuta el plot en Forward ´fnFs´ y en Reverse ´fnRs´.

Con el número que está dentro de ´[ ]´ se elije la muestra o muestras a graficar.

```r
plotQualityProfile(fnFs[2])
plotQualityProfile(fnRs[2])
```

En estas gráficas, la línea verde, representa la calidad mediana por posición. La zona gris, representa la variación de calidad entre lecturas. La línea roja, indica el porcentaje de lecturas que alcanzan cada posición.

Generalmente, basado en el perfil de calidad las lecturas en reverse disminuye más rápido en comparación con la lectura forward. Por ello, es común que el punto de de truncamiento sea menor en R2 que en R1.

Para ver con mayor detalle el area de decaimiento se puede abrir en un plot con un parámetro más cercano al decaimiento de calidad, ajustando con el comando que limita el eje de las x  (xlim=c(100,150).

Por ejemplo, en Forward:

```r
plotQualityProfile(fnFs[2]) + coord_cartesian(xlim=c(100,150))
```

O en el plot en Reverse, con una ventana mas cercana al final

```
plotQualityProfile(fnRs[2]) + coord_cartesian(xlim=c(150,100))
```

### Filtrar y recortar: filterAndTrim()

Este es un primer paso formal de DADA2 para eliminar lecturas con baja calidad.

Primero, se deben crear carpetas de filtrado

```r
filtered_directory <- file.path("~/results/07.dada2", "filtered")
dir.create(filtered_directory, recursive = TRUE, showWarnings = FALSE)
```

Cargar los sets de datos limpios de adaptadores y primers:

```r
filtFs <- file.path(filtered_directory, paste0(sample.names, "_R1_filtered.fastq.gz"))
filtRs <- file.path(filtered_directory, paste0(sample.names, "_R2_filtered.fastq.gz"))

names(filtFs) <- sample.names
names(filtRs) <- sample.names
```

Verificar que esten los archivos:

```r
length(filtFs)
length(filtRs)
```

Basado en los plots de calidad el Forwad se recortará en 100 y el Reverse en 90 (como ejemplo)

```r
out <- filterAndTrim(
  fnFs, filtFs,
  fnRs, filtRs,
  truncLen=c(100,90),
  trimLeft=c(0,0),      
  maxN=0,
  maxEE=c(2,2),
  truncQ=2,
  rm.phix=TRUE,
  compress=TRUE,
  verbose=TRUE,
  multithread=FALSE
)
```

Revisar cuantas lecturas se conservaron

```r
out
```

Calcular el porcentaje global retenido:

```r
porcentaje_retenido <- round(sum(out[, "reads.out"]) / sum(out[, "reads.in"]) * 100, 2)

porcentaje_retenido
```

Guardar en una tabla los resultados obtenidos en este paso:

```r
write.table(
  out,
  file = "~/results/07.dada2/filtering_summary.tsv",
  sep = "\t",
  quote = FALSE,
  col.names = NA
)
```
Se interpreta como:

>  70% bien

50–70% aceptable, revisar plots

< 50% bajo, habría que ajustar maxEE o truncLen

< 30% problemático


### Dereplicate: derepFastq()

Ahora se calcula el error
errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)


### Tasa de error: learnErrors()


### Inferir la composición de la muestra: dada()

### Fusión de lecturas pareadas: mergePairs()

### Crea una tabla de secuencias: makeSequenceTable()

### Eliminar quimeras: removeBimeraDenovo()

https://zenodo.org/records/14169026

###datitos extra de diccionario
```
set - e: si ocurre cualquier error, el script se detiene inmediatamente
set -u:si usas una variable que no existe, el script falla
