### Preparación del directorio de trabajo e importación de datos crudos

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
