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

Carga las librerias:

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

Y confirma con:

```r
getwd()
```
Carga la carpeta con los FASTQ recortados por Cutadapt:

```r
Cutadapt_fastq_directory <- path.expand("~/data/processed/01.cutadapt")
```

Crea la carpeta donde se guardarán los resultados de DADA2:

```r
Dada2_results_directory <- path.expand("~/results/07.dada2")
```

Crea las subcarpetas de salida:

```r
Dada2_logs_directory <- file.path(Dada2_results_directory, "logs")
Dada2_filtered_directory <- file.path(Dada2_results_directory, "filtered")
Dada2_tables_directory <- file.path(Dada2_results_directory, "tables")

dir.create(Dada2_results_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_logs_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_filtered_directory, recursive = TRUE, showWarnings = FALSE)
dir.create(Dada2_tables_directory, recursive = TRUE, showWarnings = FALSE)
```

Carga los sets de datos limpios de adaptadores y primers:

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

Verifica que esten los archivos:

```r
length(Forward_reads)
length(Reverse_reads)
```

Se revisan los perfiles de calidad de las lecturas forward y reverse usando la función `plotQualityProfile()`  Ejecuta el plot en Forward ´fnFsy´ y en Reverse ´fnRs´.
Con el número que está dentro de ´[ ]´ se elije la muestra o muestras a graficar.

```r
# Forward
plotQualityProfile(fnFs[20])
```

```r
# Reverse
plotQualityProfile(fnRs[20])
```

Para ver con mayor detalle el area de decaimiento se puede abrir en un plot con un parámetro más cercano al decaimiento de calidad.
Ajusta con el comando que limita el eje de las x  (xlim=c(270,300).

En Forward:

```r
plotQualityProfile(fnFs[20]) + coord_cartesian(xlim=c(270,300))
```

11. Ejecuta el plot en Reverse con una ventana mas cercana al final
```
plotQualityProfile(fnRs[20]) + coord_cartesian(xlim=c(270,300))
```
Basado en el perfil de calidad las lecturas en Reverse disminuye más en comparación con la lectura Forward.

De acuerso con la calidad aproximada se cortará despues de la calidad Q26
Para hacer el trucLen se debe de observar:
 1.Antes de que baje la calidad. La linea verde comienza a decaer
 2.Antesde que caiga el porcentaje de lecturas. La linea roja se desploma.





### Filtrar y recortar:filterAndTrim()

Se necesitan conocer los nombres de las muestras, deben estar en formato gzip de forma nativa

Se debe instalar dos programas: DADA2 y Phyloseq

Carga los sets de datos limpios de adaptadores y primers:

```r
data <- "01_cutadapt"
fnFs <- sort(list.files(path, pattern="_1.fastq.gz", full.names=TRUE))
fnRs <- sort(list.files(path, pattern="_2.fastq.gz", full.names=TRUE))
```

Verifica que esten los archivos:

```r
length(fnFs)
length(fnRs)
```

Ejecuta el plot en Forward ´fnFsy´ y en Reverse ´fnRs´.
Con el número que está dentro de ´[ ]´ se elije la muestra o muestras a graficar.

```r
# Forward
plotQualityProfile(fnFs[20])
```

```r
# Reverse
plotQualityProfile(fnRs[20])
```

Para ver con mayor detalle el area de decaimiento se puede abrir en un plot con un parámetro más cercano al decaimiento de calidad.
Ajusta con el comando que limita el eje de las x  (xlim=c(270,300).

En Forward:

```r
plotQualityProfile(fnFs[20]) + coord_cartesian(xlim=c(270,300))
```

11. Ejecuta el plot en Reverse con una ventana mas cercana al final
```
plotQualityProfile(fnRs[20]) + coord_cartesian(xlim=c(270,300))
```
Basado en el perfil de calidad las lecturas en Reverse disminuye más en comparación con la lectura Forward.

De acuerso con la calidad aproximada se cortará despues de la calidad Q26
Para hacer el trucLen se debe de observar:
 1.Antes de que baje la calidad. La linea verde comienza a decaer
 2.Antesde que caiga el porcentaje de lecturas. La linea roja se desploma.

Basado en los plots de calidad el F se recortará en 280 y el Reverse en 275
```
out <- filterAndTrim(
  fnFs, filtFs,
  fnRs, filtRs,
  truncLen=c(280,275),
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
```
out
```
```
write.csv(out, file.path(filt_data, "filtering_summary.csv"))
```

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
