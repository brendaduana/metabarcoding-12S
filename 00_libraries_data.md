# Que comandos aprendimos:

`scp` (secure copy): copia archivos de forma encriptada.

`cd` (change directory): permite entrar o salir de carpetas.

`cd ..`: regresa una carpeta atras.

`ls ` (list): muestra que archivos hay dentro de la carpeta donde estás situado.

`ls -lh`  `-l` ,(long), da detalles y, `-h` (human-readable) muestra el peso de los archivos en formato legible (KB, MB,GB).

`~` (Home Directory): es un atajo para la ruta de tu usuario principal (ejemplo:*/home/alumno/*)

`mkdir` (make directory): funciona para crear directorios y con el parámetro `-p` (parents) se crea directorios intermedios si no existen.

### Crea tus carpetas de trabajo

Ingresa al servidor con tu usuario y contraseña:

``` bash
ssh alumno@123.456.78.91
```

Crea tu primer directorio de trabajo:

``` bash
mkdir -p data/raw/fastq/
```

Organización de la estructura:

`data/`: Contiene únicamente datos.

`data/raw/`: Contiene datos crudos, tal como salen del secuenciador.

`data/raw/fastq/`: Contiene todos los archivos `.fastq` del proyecto.

### Imporar datos crudos al servidor

Para importar datos debes tener a la mano:

1. Ruta de tu archivo `.zip` a importar
2. Usuario y contraseña en el servidor
3. IP del servidor

Este paso se realiza desde la terminal de tu PC local, *no dentro del servidor*:

``` bash
scp "C:/Users/HP/Documentos/LandaLab/1.datoscrudos.zip" alumno@123.456.78.91:/home/alumno/data/raw/fastq/
```

Posteriormente ingresa al servidor donde trabajarás (Usuario y contraseña):

``` bash
ssh alumno@123.456.78.91
```

Verifica que se han importado:

``` bash
cd ~/data/raw/fastq/
ls -lh
```

Se muestra el nombre del archivo `.zip`:

```text
1.datoscrudos.zip
```

Descomprime el `.zip`:

``` bash
unzip 1.datoscrudos.zip
```

Deben aparecer lineas como las siguientes: `inflating: HN00264030_ARCHIVOS_RAW_FASTQ/archivo_R1.fastq.gz`
 
Puedes confirmar cuantos FASTQ tienes con el siguiente comando:

``` bash
cd HN00264030_ARCHIVOS_RAW_FASTQ
```

```bash
ls *_R1_*.fastq.gz | wc -l
```

Esperado: 24

```bash
ls *_R2_*.fastq.gz | wc -l
```

Esperado: 24

Es recomendable utilizar una bitácora dentro de bash utiliza `nano`:

``` bash
nano bitacora_amplicones_16S.txt
```

Guarda con `Ctrl + O + Enter` y sales `Ctrl + X`

Para agregar los resultados o notas rápidamente sin abrir el editor utiliza `echo:

``` bash
echo "escribe el resultado entre comillas" >> bitacora_amplicones_16S.txt
```

Hasta este punto tendrás lo siguiente:

``` text
.
├── data
│   └── raw
│       ├── 20260114_HN00264030_MAS_Report.zip
│       ├── fastq
│       │   ├── CH1S_1.fastq.gz
│       │   ├── CH1S_2.fastq.gz
│       │   ├── CH1Y_1.fastq.gz
│       │   ├── CH1Y_2.fastq.gz
│       │   ├── CH2S_1.fastq.gz
│       │   ├── CH2S_2.fastq.gz
│       │   ├── CH2Y_1.fastq.gz
│       │   ├── CH2Y_2.fastq.gz
│       │   ├── CH3S_1.fastq.gz
│       │   ├── CH3S_2.fastq.gz
│       │   ├── CH3Y_1.fastq.gz
│       │   ├── CH3Y_2.fastq.gz
│       │   ├── KA1S_1.fastq.gz
│       │   ├── KA1S_2.fastq.gz
│       │   ├── KA1Y_1.fastq.gz
│       │   ├── KA1Y_2.fastq.gz
│       │   ├── KA2S_1.fastq.gz
│       │   ├── KA2S_2.fastq.gz
│       │   ├── KA2Y_1.fastq.gz
│       │   ├── KA2Y_2.fastq.gz
│       │   ├── KA3S_1.fastq.gz
│       │   ├── KA3S_2.fastq.gz
│       │   ├── KA3Y_1.fastq.gz
│       │   ├── KA3Y_2.fastq.gz
│       │   ├── SA1S_1.fastq.gz
│       │   ├── SA1S_2.fastq.gz
│       │   ├── SA1Y_1.fastq.gz
│       │   ├── SA1Y_2.fastq.gz
│       │   ├── SA2S_1.fastq.gz
│       │   ├── SA2S_2.fastq.gz
│       │   ├── SA2Y_1.fastq.gz
│       │   ├── SA2Y_2.fastq.gz
│       │   ├── SA3S_1.fastq.gz
│       │   ├── SA3S_2.fastq.gz
│       │   ├── SA3Y_1.fastq.gz
│       │   ├── SA3Y_2.fastq.gz
│       │   ├── XP1S_1.fastq.gz
│       │   ├── XP1S_2.fastq.gz
│       │   ├── XP1Y_1.fastq.gz
│       │   ├── XP1Y_2.fastq.gz
│       │   ├── XP2S_1.fastq.gz
│       │   ├── XP2S_2.fastq.gz
│       │   ├── XP2Y_1.fastq.gz
│       │   ├── XP2Y_2.fastq.gz
│       │   ├── XP3S_1.fastq.gz
│       │   ├── XP3S_2.fastq.gz
│       │   ├── XP3Y_1.fastq.gz
│       │   └── XP3Y_2.fastq.gz
│       └── HN00264030_ARCHIVOS_RAW_FASTQ.zip
└── bitacora_amplicones_16S.txt
```

Lo que se ha realizado:

1. Creación de directorios de trabajo en el servidor.
2. Carga del archivo original de secuenciación `.zip` desde la PC al servidor.
3. Acceso correcto al servidor LandaLab.
4. Identificación de lecturas paired-end en el archivo ZIP.
5. Creación de una bitácora en formato `.txt`.

### Reporte de Control de Calidad (QC)

Posteriormente, se hará un reporte de control de calidad con `FastQC`, en formato HTML que dice que "tan buena" es la calidad de la lectura en cada posición de la secuencia.

1. Para eso primero haremos un directorio de resultados que se llame `results/2.fastqc/`:

``` bash
mkdir  ~/results/2.fastqc/
```

2. Ahora corremos `FastQC`:

``` bash
fastqc ~/data/raw/fastq/*.fastq.gz -o ~/results/2.fastqc/
```

3. Al terminar, verifica los siguiente archivos en la carpeta `results/2.fastqc/`:

```
├── results
   └── 2.fastqc
       ├── CH1S_1_fastqc.html
       ├── CH1S_1_fastqc.zip
       ├── CH1S_2_fastqc.html
       ├── CH1S_2_fastqc.zip
       ├── CH1Y_1_fastqc.html
       ├── CH1Y_1_fastqc.zip
       ├── CH1Y_2_fastqc.html
       ├── CH1Y_2_fastqc.zip
       ├── CH2S_1_fastqc.html
       ├── CH2S_1_fastqc.zip
       ├── CH2S_2_fastqc.html
       ├── CH2S_2_fastqc.zip
       ├── CH2Y_1_fastqc.html
       ├── CH2Y_1_fastqc.zip
       ├── CH2Y_2_fastqc.html
       ├── CH2Y_2_fastqc.zip
       ├── CH3S_1_fastqc.html
       ├── CH3S_1_fastqc.zip
       ├── CH3S_2_fastqc.html
       ├── CH3S_2_fastqc.zip
       ├── CH3Y_1_fastqc.html
       ├── CH3Y_1_fastqc.zip
       ├── CH3Y_2_fastqc.html
       ├── CH3Y_2_fastqc.zip
       ├── KA1S_1_fastqc.html
       ├── KA1S_1_fastqc.zip
       ├── KA1S_2_fastqc.html
       ├── KA1S_2_fastqc.zip
       ├── KA1Y_1_fastqc.html
       ├── KA1Y_1_fastqc.zip
       ├── KA1Y_2_fastqc.html
       ├── KA1Y_2_fastqc.zip
       ├── KA2S_1_fastqc.html
       ├── KA2S_1_fastqc.zip
       ├── KA2S_2_fastqc.html
       ├── KA2S_2_fastqc.zip
       ├── KA2Y_1_fastqc.html
       ├── KA2Y_1_fastqc.zip
       ├── KA2Y_2_fastqc.html
       ├── KA2Y_2_fastqc.zip
       ├── KA3S_1_fastqc.html
       ├── KA3S_1_fastqc.zip
       ├── KA3S_2_fastqc.html
       ├── KA3S_2_fastqc.zip
       ├── KA3Y_1_fastqc.html
       ├── KA3Y_1_fastqc.zip
       ├── KA3Y_2_fastqc.html
       ├── KA3Y_2_fastqc.zip
       ├── SA1S_1_fastqc.html
       ├── SA1S_1_fastqc.zip
       ├── SA1S_2_fastqc.html
       ├── SA1S_2_fastqc.zip
       ├── SA1Y_1_fastqc.html
       ├── SA1Y_1_fastqc.zip
       ├── SA1Y_2_fastqc.html
       ├── SA1Y_2_fastqc.zip
       ├── SA2S_1_fastqc.html
       ├── SA2S_1_fastqc.zip
       ├── SA2S_2_fastqc.html
       ├── SA2S_2_fastqc.zip
       ├── SA2Y_1_fastqc.html
       ├── SA2Y_1_fastqc.zip
       ├── SA2Y_2_fastqc.html
       ├── SA2Y_2_fastqc.zip
       ├── SA3S_1_fastqc.html
       ├── SA3S_1_fastqc.zip
       ├── SA3S_2_fastqc.html
       ├── SA3S_2_fastqc.zip
       ├── SA3Y_1_fastqc.html
       ├── SA3Y_1_fastqc.zip
       ├── SA3Y_2_fastqc.html
       ├── SA3Y_2_fastqc.zip
       ├── XP1S_1_fastqc.html
       ├── XP1S_1_fastqc.zip
       ├── XP1S_2_fastqc.html
       ├── XP1S_2_fastqc.zip
       ├── XP1Y_1_fastqc.html
       ├── XP1Y_1_fastqc.zip
       ├── XP1Y_2_fastqc.html
       ├── XP1Y_2_fastqc.zip
       ├── XP2S_1_fastqc.html
       ├── XP2S_1_fastqc.zip
       ├── XP2S_2_fastqc.html
       ├── XP2S_2_fastqc.zip
       ├── XP2Y_1_fastqc.html
       ├── XP2Y_1_fastqc.zip
       ├── XP2Y_2_fastqc.html
       ├── XP2Y_2_fastqc.zip
       ├── XP3S_1_fastqc.html
       ├── XP3S_1_fastqc.zip
       ├── XP3S_2_fastqc.html
       ├── XP3S_2_fastqc.zip
       ├── XP3Y_1_fastqc.html
       ├── XP3Y_1_fastqc.zip
       ├── XP3Y_2_fastqc.html
       └── XP3Y_2_fastqc.zip
```

Al verificar que esten todos los `.html` y `.zip` ahora puedes correr un `multiqc`:

``` bash
cd ~/results/2.fastqc
```

Pero, ¿Qué es un [multiqc](https://docs.seqera.io/multiqc)?

``` bash
multiqc .
```

Te dará como resultado:

```text
/// MultiQC 🔍 v1.31

     version_check | MultiQC Version v1.33 now available!
       file_search | Search path: /home/alumno/results/2.fastqc
         searching | ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 96/96
            fastqc | Found 48 reports
     write_results | Data        : multiqc_data
     write_results | Report      : multiqc_report.html
           multiqc | MultiQC complete
```

Verifica que estén los archivos `multiqc_data` y `multiqc_report.html` correctamente:

```bash
 ls | grep multiqc
```

Posteriormente descarga los resultados del multiqc en tu PC para poder visualizar con el siguiente comando desde tu power shell:

```bash
scp alumno@123.456.78.91:/home/alumno/results/2.fastqc/multiqc_report.html .
```

##hasta aqui no estoy segura##
```bash
```
Se crea un directorio para hacer el trimming: 

nano code_for_loop_allsamples:
##hasta aqui no estoy segura##

Ahora dentro de R utilizaremos plotQualityProfile con [DADA2](https://github.com/benjjneb/dada2):

1. Generaremos el directorio donde se alojarán los resultados:

```bash
mkdir -p results/03.dada2
```

2. Crearemos un nano `plotQualityProfile` que contendrá el script:

```bash
nano scripts/01_plot_quality_batches.R
```


```r
# Plot Quality Profiles by Batches

# Cargar librería
library(dada2)

# Ruta a los FASTQ
path <- "data/raw/fastq"

# Listar archivos forward y reverse
fnFs <- sort(list.files(path, pattern = "_1.fastq.gz", full.names = TRUE))
fnRs <- sort(list.files(path, pattern = "_2.fastq.gz", full.names = TRUE))

# Crear carpeta de salida
output_dir <- "results/03.dada2/quality_batches"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Tamaño del lote (puedes cambiar 6 por otro número si quieres)
batch_size <- 6

# Número total de muestras
n <- length(fnFs)

# Secuencia de inicio de lotes
starts <- seq(1, n, by = batch_size)

# Loop por lotes
for (s in starts) {

  e <- min(s + batch_size - 1, n)

  message(sprintf("Procesando muestras %d a %d", s, e))

  # Forward
  pdf(file = sprintf("%s/R1_%02d-%02d.pdf", output_dir, s, e),
      width = 12, height = 8)
  plotQualityProfile(fnFs[s:e])
  dev.off()

  # Reverse
  pdf(file = sprintf("%s/R2_%02d-%02d.pdf", output_dir, s, e),
      width = 12, height = 8)
  plotQualityProfile(fnRs[s:e])
  dev.off()
}

message("Finalizado correctamente.")
```

3. Se ejecutará en background con el comando `nohup`:

```bash

nohup Rscript scripts/01_plot_quality_batches.R > results/03.dada2/plot_quality.log 2>&1 &

```

`Rscript`: ejecuta R sin modo interactivo

`>`: guarda salida

`2>&1`:guarda errores

`&`:lo manda al fondo

4. Para ver si está corriendo el scrip en el fondo:

```bash
ps aux | grep Rscript
```

5. Monitorea el progreso del scrip en el fondo con el siguiente comando:

```bash
tail -f results/03.dada2/plot_quality.log

```
Sal del monitoreo con `Ctrl + C`

6. Confirma que se generarón PDFs:

```bash
ls results/03.dada2/quality_batches | head
```

7. Confirma cuantos PDFs se generarón :

```bash
ls results/03.dada2/quality_batches/*.pdf | wc -l
```
ls data/
metadata  raw
ls data/raw/
20260114_HN00264030_MAS_Report.zip  fastq  HN00264030_ARCHIVOS_RAW_FASTQ.zip
ls data/raw/fastq/
CH1S_1.fastq.gz  CH1S_2.fastq.gz
CH2Y_2.fastq.gz  
KA1Y_1.fastq.gz  KA3S_2.fastq.gz  
SA2S_1.fastq.gz  SA3Y_2.fastq.gz  
XP2Y_1.fastq.gz  XP2Y_2.fastq.gz
  CH3S_1.fastq.gz  
KA1Y_2.fastq.gz  KA3Y_1.fastq.gz  
SA2S_2.fastq.gz  XP1S_1.fastq.gz  
CH1Y_1.fastq.gz  CH3S_2.fastq.gz  
KA2S_1.fastq.gz  KA3Y_2.fastq.gz  
SA2Y_1.fastq.gz  XP1S_2.fastq.gz  
XP3S_1.fastq.gz  XP3S_2.fastq.gz
CH1Y_2.fastq.gz  CH3Y_1.fastq.gz  
KA2S_2.fastq.gz  SA1S_1.fastq.gz  
SA2Y_2.fastq.gz  XP1Y_1.fastq.gz  
CH2S_1.fastq.gz  CH3Y_2.fastq.gz  
KA2Y_1.fastq.gz  SA1S_2.fastq.gz  
SA3S_1.fastq.gz  XP1Y_2.fastq.gz  
XP3Y_1.fastq.gz
CH2S_2.fastq.gz  KA1S_1.fastq.gz  
KA2Y_2.fastq.gz  SA1Y_1.fastq.gz  
SA3S_2.fastq.gz  XP2S_1.fastq.gz  
XP3Y_2.fastq.gz
CH2Y_1.fastq.gz  KA1S_2.fastq.gz  
KA3S_1.fastq.gz  SA1Y_2.fastq.gz  
SA3Y_1.fastq.gz  XP2S_2.fastq.gz

##LISTADO DE PAQUETES INSTALADOS EN EL SERVIDOR: 
```
conda env list

# conda environments:
#
# *  -> active
# + -> frozen
base                     /data/bin/miniconda3
comebin_env              /data/bin/miniconda3/envs/comebin_env
EukMS_run                /data/env/EukMS_run
annot_fun                /data/env/annot_fun
anvio                    /data/env/anvio
bakta                    /data/env/bakta
binning_refiner          /data/env/binning_refiner
bioqc                    /data/env/bioqc
bowtie2                  /data/env/bowtie2
checkm                   /data/env/checkm
checkm2                  /data/env/checkm2
checkv                   /data/env/checkv
comebin                  /data/env/comebin
comebin_env              /data/env/comebin_env
dastool                  /data/env/dastool
dbcan                    /data/env/dbcan
drep                     /data/env/drep
eggnog                   /data/env/eggnog
fastp_env                /data/env/fastp_env
gtdbtk                   /data/env/gtdbtk
kaiju                    /data/env/kaiju
kraken                   /data/env/kraken
magenta_geo              /data/env/magenta_geo
mapping                  /data/env/mapping
maxbin2                  /data/env/maxbin2
megahit_env              /data/env/megahit_env
metabat2                 /data/env/metabat2
metaquast                /data/env/metaquast
metaspades               /data/env/metaspades
pharokka                 /data/env/pharokka
prokka                   /data/env/prokka
qiime2                   /data/env/qiime2
qiime2-amplicon-2024.10     /data/env/qiime2-amplicon-2024.10
trimming                 /data/env/trimming
vamb                     /data/env/vamb
vibrant                  /data/env/vibrant
virsorter2               /data/env/virsorter2
```

PARA ENCONTRAR DONDE ESTAN ALOJADOS LOS PROGRAMAS SE ESCRIBE wich:
which conda
Y DA LO SIGUIENTE:
/data/bin/miniconda3/bin/conda

###esto sería en R
Dentro de R se generarán gráficas de calidad (R1 y R2) con `plotQualityProfile`:

```r
path <- "data/raw/fastq"

fnFs <- sort(list.files(path, pattern="_1.fastq.gz", full.names=TRUE))
fnRs <- sort(list.files(path, pattern="_2.fastq.gz", full.names=TRUE))

plotQualityProfile(fnFs[1:2])
plotQualityProfile(fnRs[1:2])
```





