### Remoción de primers y limpieza con cutadapt

Los primers son las secuencias que se añaden durante la PCR para amplificar la región de interés, en este caso, el set de primer utilizado es el siguiente:

```
Fragmento del gen mitocondrial 12S rRNA V5, 97 pb (Riaz et al., 2011),
utilizando los cebadores:
Forward 5′-TAGAACAGGCTCCTCTAG-3′
Reverse 5′-TTAGATACCCCACTATGC-3′ . 
```

Este paso es importante realizarlo porque los primers no forman parte de la secuencia biológica que se quiere analizar. Si permanecen en los archivos FASTQ, pueden afectar el filtrado posterior, la inferencia de ASV y la asignación taxonómica.

[Cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html) se utiliza antes de `dada2` para remover artefactos de secuenciación y primers de metabarcode. 

En bash, verifica que esté instalado cutadapt:

```bash
cutadapt --version
```

Arrojando algo como `5.2`

Primero, se crean los directorios de salida:

```bash
mkdir -p ~/scripts
nano ~/scripts/04_cutadapt.sh
```

Después se abrirá un `nano` para escribir el script completo que requiere `Cutadapt`

```bash
#!/bin/bash

# Script: 04_cutadapt.sh

# Detiene el script si ocurre un error
set -e

# Define rutas de entrada y salida
Raw_fastq_directory="$HOME/data/raw/fastq/ARCHIVOS_RAW_FASTQ"
Cutadapt_output_directory="$HOME/data/processed/01.cutadapt"
Cutadapt_report_directory="$HOME/results/04.cutadapt_reports"

# Crea carpetas de salida
mkdir -p "${Cutadapt_output_directory}"
mkdir -p "${Cutadapt_report_directory}"

# Primers 12S V5 (Riaz et al. 2011):
Forward_primer="TAGAACAGGCTCCTCTAG"
Reverse_primer="TTAGATACCCCACTATGC"

# Complementos reversos de los primers
Reverse_complement() {
    echo "$1" | tr 'ACGTacgt' 'TGCAtgca' | rev
}
Forward_primer_reverse_complement="$(Reverse_complement "${Forward_primer}")"
Reverse_primer_reverse_complement="$(Reverse_complement "${Reverse_primer}")"

# Parámetros generales de cutadapt
Number_of_threads="4"
Allowed_error_rate="0.10"
Minimum_length_after_trimming="40"
Discard_untrimmed_reads="1"

# Corre cutadapt por cada par de archivos R1/R2

for Read_1_file in "$Raw_fastq_directory"/*_R1_*.fastq.gz
do
    Read_2_file="${Read_1_file/_R1_/_R2_}"

    Sample_name=$(basename "$Read_1_file" | sed 's/_R1_.*//')

    echo "Procesando muestra: $Sample_name"

    cutadapt \
        -e "$Allowed_error_rate" \
        -m "$Minimum_length_after_trimming" \
        -g "^$Forward_primer" \
        -G "^$Reverse_primer" \
        -a "$Reverse_primer_reverse_complement" \
        -A "$Forward_primer_reverse_complement" \
        --discard-untrimmed \
        -o "$Cutadapt_output_directory/${Sample_name}_R1_trimmed.fastq.gz" \
        -p "$Cutadapt_output_directory/${Sample_name}_R2_trimmed.fastq.gz" \
        "$Read_1_file" "$Read_2_file" \
        > "$Cutadapt_report_directory/${Sample_name}_cutadapt.log"

done

echo "Cutadapt terminó correctamente."
echo "FASTQ recortados en: $Cutadapt_output_directory"
echo "Reportes en: $Cutadapt_report_directory"
```

Guarda con: `Ctrl + O`, después `Enter` y sal con `Ctrl + X`

Se hace ejecutable:

```bash
chmod +x ~/scripts/04_cutadapt.sh
bash ~/scripts/04_cutadapt.sh
```

Posteriormente, se vuelve a ejecutar `FastQC` y `MultiQC` pero ahora se utilizarán los archivos generados por `Cutadapt`:

Primero se crea un nuevo directorio de salida:

```bash
mkdir -p ~/results/05.fastqc_cutadapt/
```

Corre `FastQC`

```bash
fastqc ~/data/processed/01.cutadapt/*.fastq.gz -o ~/results/05.fastqc_cutadapt/
```

Y verifica si se crearon correctamente:

```bash
ls -lh ~/results/05.fastqc_cutadapt/
```

Se crea un nuevo directorio de salida:

```bash
mkdir -p ~/results/06.multiqc_cutadapt/
```

Corre `FastQC`

```bash
multiqc ~/results/05.fastqc_cutadapt/ -o ~/results/06.multiqc_cutadapt/
```

Y verifica si se crearon correctamente:

```bash
ls ~/results/06.multiqc_cutadapt/ | grep multiqc
```

La estructura final se verá así:

```text
results/
├── 02.fastqc/
│   ├── sample1_R1_fastqc.html
│   ├── sample1_R1_fastqc.zip
│   └── ...
├── 03.multiqc_raw/
│   ├── multiqc_data/
│   └── multiqc_report.html
├── 04.cutadapt_reports/
│   ├── sample1_cutadapt.log
│   ├── sample2_cutadapt.log
│   └── ...
└── 05.fastqc_cutadapt/
│    ├── sample1_R1_trimmed_fastqc.html
│    ├── sample1_R1_trimmed_fastqc.zip
│    ├── sample1_R2_trimmed_fastqc.html
│    ├── sample1_R2_trimmed_fastqc.zip
│    └── ...
└── 06.multiqc_cutadapt/
    ├── multiqc_data/
    └── multiqc_report.html
```

