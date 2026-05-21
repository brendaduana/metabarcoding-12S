### Preparación del directorio de trabajo e importacion de datos crudos

Ingresa al servidor utilizando tu usuario, contraseña e IP:

``` bash
ssh alumno@123.456.78.91
```

Crea tu primer directorio de trabajo:

``` bash
mkdir -p ~/data/raw/fastq/
```

Organización de la estructura:

`data/`: Contiene únicamente datos.

`data/raw/`: Contiene datos crudos de secuenciación sin modificar.

`data/raw/fastq/`: Contiene todos los archivos `.fastq.gz` de secuenciación.

### Impotar datos crudos al servidor

Para importar datos debes tener a la mano:

1. Ruta local del archivo `.zip` que contiene los FASTQ
2. Usuario
3. IP del servidor
4. Contraseña del servidor


Este paso se realiza desde la terminal de tu PC local, *no dentro del servidor*:

``` bash
scp "C:/Users/HP/Documentos/01.datoscrudos.zip" alumno@123.456.78.91:/home/alumno/data/raw/fastq/
```

Verificar que el archivo fue importado correctamente al servidor

``` bash
ssh alumno@123.456.78.91
cd ~/data/raw/fastq/
ls -lh
```

Se muestra el nombre del archivo `.zip`:

```text
01.datoscrudos.zip
```

Descomprime el archivos FASTQ `.zip`:
En este punto se descomprime el `.zip` donde estan contenidos los datos, pero los `.fastq.gz` deben mantenerse comprimidos para el analisis.

``` bash
unzip 01.datoscrudos.zip
```

Deben aparecer lineas como las siguientes: 

`inflating: ARCHIVOS_RAW_FASTQ/archivo_R1.fastq.gz`

`inflating: ARCHIVOS_RAW_FASTQ/archivo_R2.fastq.gz`

Puedes confirmar cuantos FASTQ tienes con el siguiente comando:

``` bash
cd ARCHIVOS_RAW_FASTQ
```

Cuenta los archivos correspondientes a las lecturas forward, o R1:

```bash
ls *_R1_*.fastq.gz | wc -l
```

Esperado: *n*

```bash
ls *_R2_*.fastq.gz | wc -l
```

Esperado: *n*

Si ambos comandos muestran el *n* esperado, significa que se han importado correctamente los archivos pareados.

Hasta este punto tendrás lo siguiente:

``` text
.
├── data
│   └── raw
│       ├── fastq
│       │   ├── sample1_1.fastq.gz
│       │   ├── sample1_2.fastq.gz
│       │   ├── sample2_1.fastq.gz
│       │   ├── sample2_2.fastq.gz
│       │   ├── sample3_1.fastq.gz
│       │   ├── sample3_2.fastq.gz
│       └── ARCHIVOS_RAW_FASTQ.zip

```

Se puede hacer un control incial de lecturas por archivo FASTQ
Este paso permite revisar si todas las muestras tienen una cantidad similar o igual de lecturas entre muestras.

``` bash
cd ~/data/raw/fastq/ARCHIVOS_RAW_FASTQ
```

Crea un directorio de salida

``` bash
mkdir ~/results/01.read_counts/
```

Y ejecuta el siguiente comando

``` bash
for f in *.fastq.gz
do
    n_lines=$(gzip -cd "$f" | wc -l)
    n_reads=$((n_lines / 4))
    printf "%s\t%s\n" "$f" "$n_reads"
done > ~/results/01.read_counts/conteo_lecturas_raw.tsv
```

Ejemplo de resultado obtenido en `conteo_lecturas_raw.tsv`:

```text
sample1_R1_001.fastq	323473
sample1_R2_001.fastq	323473
sample2_R1_001.fastq	228163
sample2_R2_001.fastq	228163
sample3_R1_001.fastq	207120
sample3_R2_001.fastq	207120
```

Lo que se ha realizado:

1. Acceso correcto al servidor.
2. Creación de directorios inicales de trabajo.
3. Carga del archivo original de secuenciación `.zip` desde la PC al servidor.
4. Verificación del número de archivos FASTQ paired-end es correcto.
5. Conteo inicial de lecturas

### Reporte de Control de Calidad (QC)

Posteriormente, se hará un reporte de control de calidad con `FastQC`, en formato `.html`, que permite revisar la calidad de las lecturas en cada posicion de la secuencia por muestra.

Para eso, primero se crea un directorio de resultados que se llame `results/02.fastqc/`:

``` bash
mkdir -p ~/results/02.fastqc/
```

Ahora corremos `FastQC`:

``` bash
fastqc ~/data/raw/fastq/ARCHIVOS_RAW_FASTQ/*.fastq.gz -o ~/results/02.fastqc/
```

Al terminar, verifica que los archivos generados esten en el contenido de la carpeta `results/02.fastqc/` con el siguiente comando:

```
ls -lh ~/results/02.fastqc/
```

Por cada archivo `.fastq.gz`, FastQC genera dos archivos:

```
archivo_fastqc.html
archivo_fastqc.zip
```

La estructura del proyecto comenzara a ver asi:

```
.
├── data
│   └── raw
│       └── fastq
│           └── ARCHIVOS_RAW_FASTQ
│               ├── sample1_R1.fastq.gz
│               ├── sample1_R2.fastq.gz
│               └── ...
└── results
    └── 02.fastqc
        ├── sample1_R1_fastqc.html
        ├── sample1_R1_fastqc.zip
        ├── sample2_R2_fastqc.html
        ├── sample2_R2_fastqc.zip
        └── ...
```

Al verificar que esten todos los `.html` y `.zip` ahora puedes correr un [MultiQC](https://docs.seqera.io/multiqc). Su función es reunir todos los reportes individuales generados por `FastQC` y crear un solo reporte general en formato `.html`. 

Crea un directorio de salida:

``` bash
mkdir -p ~/results/03.multiqc_raw/
```

Ejecuta MultiQC indicando como entrada el directorio donde están los resultados de FastQC:

``` bash
multiqc ~/results/02.fastqc/ -o ~/results/03.multiqc_raw/
```

Te dará como resultado:

```text
/// MultiQC 🔍 v1.31

     version_check | MultiQC Version v1.33 now available!
       file_search | Search path: /home/alumno/results/03.multiqc_raw
         searching | ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% n/n
            fastqc | Found n reports
     write_results | Data        : multiqc_data
     write_results | Report      : multiqc_report.html
           multiqc | MultiQC complete
```

Verifica que estén los archivos `multiqc_data` y `multiqc_report.html` correctamente:

```bash
ls ~/results/03.multiqc_raw/ | grep multiqc
```

Descarga los resultados del multiqc en tu PC para poder visualizar con el siguiente comando desde tu power shell o desde la terminal:

```bash
scp alumno@123.456.78.91:/home/alumno/results/03.multiqc_raw/multiqc_report.html .
```

Abre el reporte de MultiQC en el navegador:

```bash
open ~/multiqc/multiqc_report.html
```
Tips de revisión en MultiQC:
- `Per base sequence quality`: permite observar cómo cambia la calidad de las lecturas a lo largo de la secuenciadefine zonas de truncado (Q≥25–30).
  
- `Adapter Content` u `Overrepresented sequences`: ayuda a identificar si hay adaptadores, primers u otras secuencias sobrerrepresentadas.
  
- `Sequence Length Distribution`: válida rango del amplicón esperado.

Observarás una estructura del directorio de la siguiente forma:

```text
results/
├── 02.fastqc/
│   ├── sample1_R1_fastqc.html
│   ├── sample1_R1_fastqc.zip
│   └── ...
└── 03.multiqc_raw/
    ├── multiqc_data/
    └── multiqc_report.html
```

Nota: `Anacapa` realiza control de calidad, recorte de primers/adaptadores y generación de ASVs mediante DADA2. Sin embargo, `FastQC` y `MultiQC` se utilizan previamente para inspeccionar visualmente la calidad de los datos crudos antes de ejecutar el pipeline completo.

### Remoción de primers y limpieza con cutadapt

Los primers son las secuencias que se añaden durante la PCR para amplificar la región de interés, en este caso, el set de primer utilizado es el siguiente:
```
Fragmento del gen mitocondrial 12S rRNA V5, 97 pb (Riaz et al., 2011),
utilizando los cebadores:
Forward 5′-TAGAACAGGCTCCTCTAG-3′
Reverse 5′-TTAGATACCCCACTATGC-3′ . 
```



Ahora utilizaremos DADA2 a través de QIIME2

QIIME2 necesita un manifest `.tsv` en donde se indique:
* Que archivo corresponde a que muestra
* Cual es la muestra forward (_1) y reverse (_2)

1. Crea directorios de salida

```bash
mkdir -p results/03.qiime2/{01.import,02.demux}
```

2. Activa el ambiente

En caso de no entrar donde está alojado el ambiente escribe en tu terminal: `which` + el ambiente a identificar, en este caso es `conda`

```bash
which conda
```

Y dará la ruta la ruta donde se encuentra alojado:`/data/bin/miniconda3/bin/conda`

Llama al ambiente con `source` o con `.`. seguido de la ruta:

```bash
source /data/bin/miniconda3/etc/profile.d/conda.sh
```

Y activalo:

```bash
conda activate qiime2-amplicon-2024.10
```

3. Crea el manifest desde la raíz

```bash
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > data/manifest_qiime2.tsv
```

```bash
for f in data/raw/fastq/*_1.fastq.gz; do
  sample=$(basename "$f" _1.fastq.gz)
  echo -e "${sample}\t$(pwd)/data/raw/fastq/${sample}_1.fastq.gz\t$(pwd)/data/raw/fastq/${sample}_2.fastq.gz"
done >> data/manifest_qiime2.tsv
```

4. Verifica que se haya creado con un head:

```bash
head data/metadata/manifest_qiime2.tsv
```

5. Importa a QIIME2 (paired-end): generando un script con ayuda de nano

```bash
nano scripts/01_import_demux.sh
```

```bash
#!/usr/bin/env bash
set -euo pipefail
#importa FASTQ
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path data/manifest_qiime2.tsv \
  --output-path results/03.qiime2/01.import/demux-paired-end.qza \
  --input-format PairedEndFastqManifestPhred33V2
#genera resumen de calidad
qiime demux summarize \
  --i-data results/03.qiime2/01.import/demux-paired-end.qza \
  --o-visualization results/03.qiime2/02.demux/demux.qzv
```

`Ctrl + O`, después `Enter` y sal con `Ctrl + X`

6. Se hace ejecutable:

```bash
chmod +x scripts/01_import_demux.sh
```

7. Ejecutar:

```bash
bash scripts/01_import_demux.sh
```

##hasta aqui no estoy segura##
```bash
```
```
data/

metadata  raw

data/raw/

20260114_HN00264030_MAS_Report.zip  fastq  HN00264030_ARCHIVOS_RAW_FASTQ.zip

data/raw/fastq/

CH1S_1.fastq.gz  CH1S_2.fastq.gz
CH2Y_1.fastq.gz  CH2Y_2.fastq.gz
KA1Y_1.fastq.gz  KA1Y_2.fastq.gz
SA2S_1.fastq.gz  SA2S_2.fastq.gz
SA3Y_1.fastq.gz  SA3Y_2.fastq.gz
XP2Y_1.fastq.gz  XP2Y_2.fastq.gz
CH3S_1.fastq.gz  CH3S_2.fastq.gz
KA1S_1.fastq.gz  KA1S_2.fastq.gz
KA3Y_1.fastq.gz  KA3Y_2.fastq.gz
KA3S_1.fastq.gz  KA3S_2.fastq.gz
XP1S_1.fastq.gz  XP1S_2.fastq.gz
CH1Y_1.fastq.gz  CH1Y_2.fastq.gz
KA2S_1.fastq.gz  KA2S_2.fastq.gz
SA2Y_1.fastq.gz  SA2Y_2.fastq.gz
XP3S_1.fastq.gz  XP3S_2.fastq.gz
CH3Y_1.fastq.gz  CH3Y_2.fastq.gz
SA1S_1.fastq.gz  SA1S_2.fastq.gz
XP1Y_1.fastq.gz  XP1Y_2.fastq.gz
CH2S_1.fastq.gz  CH2S_2.fastq.gz
KA2Y_1.fastq.gz  KA2Y_2.fastq.gz
SA3S_1.fastq.gz  SA3S_2.fastq.gz
XP3Y_1.fastq.gz  XP3Y_2.fastq.gz
SA1Y_1.fastq.gz  SA1Y_2.fastq.gz
XP2S_1.fastq.gz  XP2S_2.fastq.gz  
``` 

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
03/03/26
https://benjjneb.github.io/dada2/ . https://benjjneb.github.io/dada2/tutorial.html 
https://www.bioconductor.org/packages//release/bioc/vignettes/dada2/inst/doc/dada2-intro.html
https://www.nature.com/articles/nmeth.3869

### Introducción
El conocimiento de los microbiomas han sido develadas por el desarrollo de la secuenciación de amplicones. 
Un locus especifico como el gen RNAr 16S en bacterias se amplifica a partir de DNA extraído, eliminando la necesidad de cultivar microbios para detectar su presencia
y proporciona un censo exhaustivo de una comunidad de forma rentable.

Sin embargo, el proceso de secuenciación de amplicones introduce errores lo que dificulta la interpretación de los resultados.
DADA2 implementa un algoritmo que modela los errores introducidos durante la secuenciación de amplicones
 y utiliza dicho modelo para inferir la verdadera composición de la muestra.
 Reemplaza el paso de OTU, generando en su lugar tablas de mayor resolucion de ASVs.
 
### DADA2

Punto de partida: espera que haya un archivo un conjunto de archivos *fastq demultiplexados* para cada muestra
(o dos archivos fastq, un forward y otro reverse para cada muestra). El *demultiplexados* puede hacerse con QIIME2.

DADA2 espera que no haya bases no biológicas, por ejemplo los cebadores de PCR que se incluyeron en la región del amplicón.
Una vez teniendo los *fastq demultiplexados* se puede comenzar el proceso.

El resultado del pipeline es una tabla de características de ASV que contiene filas correspondientes a las muestras y columnas a las ASV en esa muestra.

### Quitar adaptadores con cutadapt:

En bash, verifica que esté instalado cutadapt:

```bash
cutadapt --version
```

Arrojando algo como `5.2`

Posteriorme se señalará la ruta donde se encuentren los datos (/mnt/c/Users/HP/OneDrive - Universidad Autónoma Metropolitana/Documentos/LandaLab/amplicones_paola/1.datoscrudos)
Y descomprime

```bash
unzip HN00264030_ARCHIVOS_RAW_FASTQ.zip
```

Se deben crear un directorio para los resultados de salida:

```bash
mkdir -p trimmed reports
```
Para poder correr correctamente el código se recomienda utilizar un `nano` :
5. creé un nano: nano 01_remove_primers.sh
```
#!/bin/bash
set -euo pipefail
for f in *_1.fastq.gz; do
  s="${f%_1.fastq.gz}"
  cutadapt \
    -g CCTACGGGNGGCWGCAG \
    -G GACTACHVGGGTATCTAATCC \
    -o "trimmed/${s}_1.fastq.gz" \
    -p "trimmed/${s}_2.fastq.gz" \
    "${s}_1.fastq.gz" "${s}_2.fastq.gz" \
    > "reports/cutadapt_${s}.log"
done
```
### ESTE FUE EL CÓDIGO UTILIZADO PARA EUK MBC
```
#!/usr/bin/env bash
set -euo pipefail

# Recorte de primers paired-end con cutadapt

# Configuración de rutas
# Define las rutas principales del proyecto: dónde están los datos originales, dónde se guardarán los resultados y los reportes.
# Crea las carpetas de salida y reportes si no existen.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RAW_DIR="${PROJECT_ROOT}/raw_fastqs"
OUT_DIR="${PROJECT_ROOT}/for_dada2"
REPORT_DIR="${PROJECT_ROOT}/cutadapt_reports"
mkdir -p "${OUT_DIR}" "${REPORT_DIR}"

# Prepara las secuencias de los primers que cutadapt usará para recortar los extremos correctos de las lecturas
# Primers (override con FWD=... REV=...)
# Define los primers forward y reverse (pueden ser cambiados al ejecutar el script).
# Calcula la reversa complementaria del reverse primer.
# Prepara la secuencia que se buscará en las lecturas R2.
FWD="${FWD:-ACACCGCCCGTCACTCT}"
REV="${REV:-CTTCCGGTACACTTACCATG}"
revcomp(){ echo "$1" | tr 'ACGTacgt' 'TGCAtgca' | rev; }
RC="$(revcomp "${REV}")"
ADAPTER_R2="${REV}"   # R2 comienza con REV (no RC)
```

# Parámetros (override con THREADS= MIN_LEN= ERROR_RATE= DISCARD_UNTRIMMED=0/1)
# Permite ajustar el número de hilos, el error permitido, la longitud mínima de las lecturas y si se descartan lecturas sin recortar.
THREADS="${THREADS:-4}"
ERROR_RATE="${ERROR_RATE:-0.10}"
MIN_LEN="${MIN_LEN:-40}"
DISCARD_UNTRIMMED="${DISCARD_UNTRIMMED:-0}"

# Localizar cutadapt
# Verifica si cutadapt está instalado y accesible, ya sea como comando directo o a través de Python.
# Si no se encuentra, el script termina con un error.
if command -v cutadapt >/dev/null 2>&1; then
  CUTADAPT_BIN="cutadapt"
elif python3 -m cutadapt --version >/dev/null 2>&1; then
  CUTADAPT_BIN="python3 -m cutadapt"
else
  echo "ERROR: cutadapt no encontrado"; exit 1
fi

# Verificaciones previas
# Asegura que el directorio de datos originales existe y contiene archivos FASTQ esperados
[[ -d "${RAW_DIR}" ]] || { echo "ERROR: falta ${RAW_DIR}"; exit 1; }
shopt -s nullglob
R1_LIST=( "${RAW_DIR}"/*_R1_001.fastq )
(( ${#R1_LIST[@]} > 0 )) || { echo "ERROR: no hay *_R1_001.fastq"; exit 1; }

# Preparar archivos de resumen
# Inicializa archivos para almacenar resúmenes detallados y tabulares de los resultados del recorte.
SUMMARY_TXT="${REPORT_DIR}/overall_report.txt"
SUMMARY_TSV="${REPORT_DIR}/overall_summary.tsv"
: > "${SUMMARY_TXT}"
echo -e "sample\tpairs_total\tread1_adapter\tread2_adapter\tpairs_written\tpct_written" > "${SUMMARY_TSV}"

echo "[INFO] FWD=${FWD} REV=${REV} RC=${RC} THREADS=${THREADS} MIN_LEN=${MIN_LEN} DISCARD_UNTRIMMED=${DISCARD_UNTRIMMED}"

# Procesar cada par de FASTQ
# Itera sobre cada archivo R1, encuentra su par R2, y ejecuta cutadapt con los parámetros especificados.
# Genera reportes individuales y actualiza los resúmenes generales.

for R1 in "${R1_LIST[@]}"; do
  base_R1="$(basename "${R1}")"
  R2="${R1/_R1_001.fastq/_R2_001.fastq}"
  [[ -f "${R2}" ]] || { echo "[WARN] Falta par R2 para ${base_R1}, omite"; continue; }
  sample="${base_R1/_R1_001.fastq/}"

  out_R1="${OUT_DIR}/${base_R1}"
  out_R2="${OUT_DIR}/$(basename "${R2}")"
  report="${REPORT_DIR}/${sample}_cutadapt.txt"

  # Construir argumentos (seguro con set -u)
  args=( -j "${THREADS}" -g "^${FWD}...${RC}" -G "^${ADAPTER_R2}...$(revcomp "${FWD}")" -e "${ERROR_RATE}" -m "${MIN_LEN}" --discard-untrimmed )
  if [[ "${DISCARD_UNTRIMMED}" == "1" ]]; then
    args+=( --discard-untrimmed )
  fi
  args+=( -o "${out_R1}" -p "${out_R2}" "${R1}" "${R2}" )

  echo "[INFO] Procesando ${sample}"
  "${CUTADAPT_BIN}" "${args[@]}" > "${report}"

  {
    echo "=== ${sample} ==="
    grep -E "^Total read pairs processed:|^  Read 1 with adapter:|^  Read 2 with adapter:|^Pairs written \(passing filters\):" "${report}" || true
    echo
  } >> "${SUMMARY_TXT}"

    # Parseo robusto (cutadapt 5.x)
  total=$(awk -F'[[:space:]]+' '/^Total read pairs processed:/ {gsub(",","",$5); print $5}' "${report}")
  r1adp=$(awk -F'[[:space:]]+' '/^ *Read 1 with adapter:/ {gsub(",","",$5); print $5}' "${report}")
  r2adp=$(awk -F'[[:space:]]+' '/^ *Read 2 with adapter:/ {gsub(",","",$5); print $5}' "${report}")
  written=$(awk -F'[[:space:]]+' '/^Pairs written \(passing filters\):/ {gsub(",","",$5); print $5}' "${report}")
  # Extraer porcentaje con sed (compatible BSD)
  pct=$(grep -E "^Pairs written \(passing filters\):" "${report}" | sed -E 's/.*\(([^%]+)%\).*/\1/')
  [[ -z "${pct}" ]] && pct="NA"

  echo -e "${sample}\t${total}\t${r1adp}\t${r2adp}\t${written}\t${pct}" >> "${SUMMARY_TSV}"
  done


echo "[OK] Terminado"
echo "[OK] FASTQ recortados: ${OUT_DIR}"
echo "[OK] Resumen TXT: ${SUMMARY_TXT}"
echo "[OK] Resumen TSV: ${SUMMARY_TSV}"
# fin del script
```

primers a utilizar
```
16S V3–V4 (341F / 806R)
```
4. permitir ejecución:
```
chmod +x 01_remove_primers.sh
```
6. ejecutar donde estoy posisicionada
```
./01_remove_primers.sh
```
8. verifica que ya no esten con un zcat
   zgrep -c "CCTACGGG" 01_cutadapt/*_1.fastq.gz

### Filtrar y recortar:filterAndTrim()

Se necesitan conocer los nombres de las muestras, deben estar en formato gzip de forma nativa

Se debe instalar dos programas: DADA2 y Phyloseq

Ingresa a R
En la consola puedes escribir tu ruta donde están los archivos crudos:

```r
setwd("C:/Users/HP/OneDrive - Universidad Autónoma Metropolitana/Documentos/LandaLab/amplicones_paola/1.datoscrudos")
```

Y confirma con:

```r
getwd()
```

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
library(ggplot2)
```

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
-o pipefail: detenerse si algo falla, no permitir variables no definidas, detectar errores dentro de pipes
