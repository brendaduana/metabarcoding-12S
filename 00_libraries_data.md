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












