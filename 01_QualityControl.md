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

