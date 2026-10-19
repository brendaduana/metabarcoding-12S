## Paso 1. Verificar el entorno de R y Rtools

**Qué hace:** Comprueba la versión de R y que Windows tenga una herramienta de compilación (`make`). Algunos paquetes de R se instalan desde código fuente y necesitan compilarse en tu computadora. En Windows, esa herramienta viene en Rtools, y la versión debe corresponder a la de R: Rtools44 es la que va con R 4.4.x.

El README de rCRUX no menciona Rtools porque es un requisito de Windows y no del paquete.

### 1.1 Verificar la versión de R y buscar `make`

Primero se consulta qué versión de R está instalada y si Windows encuentra `make`. `Sys.which("make")` busca ese programa en el PATH (la lista de carpetas donde Windows busca programas). Si devuelve una cadena vacía, no hay herramienta de compilación.

```r
R.version.string

Sys.which("make")
```

**Resultado:** R `"R version 4.4.0 (2024-04-24 ucrt)"`. `Sys.which("make")` devolvió cadena vacía, es decir, Rtools no estaba instalado.

### 1.2 Instalar Rtools44 y volver a verificar

Se descargó Rtools44 (`rtools44-6459-6401.exe`, ~431 MB) desde [aquí](https://cran.r-project.org/bin/windows/Rtools/rtools44/), se aceptaron los permisos de instalación y se reinició RStudio por completo. Al repetir la verificación:

```r
Sys.which("make")
```

**Resultado:**"C:\\rtools44\\usr\\bin\\make.exe"

R 4.4.0 no tenía herramienta de compilación. Con Rtools44 instalado, `make` quedó detectado.

### Decisión

Dado que `make` no estaba disponible, se instaló Rtools44 y se reinició RStudio para que se actualizara el PATH. Con `make` detectado, se puede instalar rCRUX en el Paso 2.

**Script:** `scripts/01_setup.R`, Paso 1.

> **Nota al pie: si `make` sigue sin aparecer**
>
> | Si pasa esto… | Haz lo siguiente |
> |---|---|
> | `Sys.which("make")` sigue devolviendo cadena vacía después de instalar Rtools | Cierra y abre RStudio por completo (no basta con reiniciar la sesión de R) y repite la verificación |
> | Persiste tras reiniciar | Confirma que instalaste Rtools44 y no otra versión. |

## Paso 2. Instalar rCRUX y sus dependencias

**Qué hace.** Instala rCRUX desde el repositorio de sus autores en GitHub (`CalCOFI/rCRUX`), porque no está en CRAN. `install_github()` no resolvió por sí sola cinco dependencias: tres de Bioconductor (`GenomeInfoDb`, `Biostrings`, `phyloseq`) y dos de GitHub (`phylotools`, `psadd`). Por eso se instalan primero, se verifica cada grupo y al final se instala rCRUX.

**Intentos que fallaron**

| # | Qué se intentó | Qué pasó | Qué se concluyó |
|---|---|---|---|
| 1 | `devtools::install_github("CalCOFI/rCRUX", build_vignettes = TRUE)` | Error de credenciales: Windows tenía guardado un PAT (Personal Access Token) de GitHub no válido | El repositorio es público y no necesita autenticación. Se borró la credencial con `gitcreds::gitcreds_delete()` (opción 2) |
| 2 | El mismo comando, ya sin la credencial | Tras ~50 min: `dependencies 'phylotools', 'psadd', 'phyloseq' are not available for package 'rCRUX'` | `phyloseq`, `Biostrings` y `GenomeInfoDb` son de Bioconductor. `phylotools` y `psadd` no estaban en CRAN en ese momento, aunque rCRUX los declara como dependencias. Hay que instalarlos aparte y antes. Declarar bien estas dependencias es un pendiente abierto en el repositorio de rCRUX ([issue #22](https://github.com/CalCOFI/rCRUX/issues/22) y [issue #23](https://github.com/CalCOFI/rCRUX/issues/23), 2023) |
### 2.1 Cargar devtools

`devtools` contiene `install_github()`, la función que instala rCRUX en 2.4. Se carga con `library()`.

```r
# install.packages("devtools")   # solo si no está instalado
library(devtools)
```

Los dos comandos siguientes solo son necesarios si `install_github()` falla por credenciales (intento 1). `gitcreds_delete()` muestra la credencial guardada y un menú; se eligió la opción 2 (*Delete these credentials*).

```r
install.packages("gitcreds")
gitcreds::gitcreds_delete()
```

### 2.2 Instalar las dependencias de Bioconductor

[Bioconductor](https://bioconductor.org/) es un repositorio distinto de CRAN y tiene su propio instalador, `BiocManager`. Esta línea instala `BiocManager` solo si falta:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
```

Los paquetes son grandes, así que el tiempo de espera de descarga se sube a 600 segundos. El cambio solo vale para la sesión actual. `update = FALSE` y `ask = FALSE` impiden que Bioconductor actualice otros paquetes o haga preguntas. Si de todos modos pregunta por actualizaciones, se responde `n`.

```r
options(timeout = 600)
BiocManager::install(c("GenomeInfoDb", "Biostrings", "phyloseq"),
                     update = FALSE, ask = FALSE)
```

Después se comprueba la instalación. `%in%` busca cada nombre en la lista de paquetes instalados y devuelve `TRUE` si lo encuentra. Así un fallo aparece aquí y no después de 50 minutos instalando rCRUX.

```r
c("GenomeInfoDb", "Biostrings", "phyloseq") %in% rownames(installed.packages())
```

Resultado obtenido: `TRUE TRUE TRUE`.

### 2.3 Instalar las dependencias de GitHub

`phylotools` y `psadd` se instalan desde el repositorio de cada autor con `remotes`, que se instala junto con `devtools`.

```r
remotes::install_github("helixcn/phylotools")
remotes::install_github("cpauvert/psadd")
```

Se verifican de la misma forma:

```r
c("phylotools", "psadd") %in% rownames(installed.packages())
```

Resultado obtenido: `TRUE TRUE`.

### 2.4 Instalar rCRUX

Con las cinco dependencias confirmadas se instala rCRUX con el comando del README oficial. Es el paso largo: tardó unos **54 minutos** y no debe interrumpirse.

```r
devtools::install_github("CalCOFI/rCRUX", build_vignettes = TRUE)
```

Luego se carga el paquete y se listan y cuentan sus objetos exportados, para confirmar que se puede usar. Resultado obtenido: **20 objetos**, que son 19 funciones de rCRUX más el operador `%>%`.

```r
library(rCRUX)
ls("package:rCRUX")
length(ls("package:rCRUX"))
```

Salida de `ls("package:rCRUX")`:

```
[1] "%>%"
"blast_datatable"
[3] "blast_seeds"
"combine_fasta_and_taxonomy"
[5] "compare_ref_db"
"convert_to_qiime2"
[7] "derep_and_clean_db"
"expand_multi_taxids"
[9] "filter_primer_hits"
"get_seeds_local"
[11] "get_seeds_remote"                        "get_taxonomy_from_accession"
[13] "has_blast_plus_binaries"                    "iterative_primer_search"
[15] "output_to_taxonomy_file"
"run_blastdbcmd"
[17] "run_blastdbcmd_blastn_and_aggregate_resuts"
"run_blastn"
[19] "run_primer_blastn"
"save_state"
```

Por último, se registran la versión y el commit exactos. El repositorio sigue cambiando, y el commit es lo que permite reinstalar esta misma versión.

```r
packageVersion("rCRUX")
packageDescription("rCRUX")$RemoteSha
```

Resultado obtenido: versión `0.1.0.0` (en el archivo DESCRIPTION aparece como `0.1.0.000`), commit `4c0aa9046d3636262d3f75b20d2a17f85381872c`.

rCRUX quedó instalado y funcional, con sus 20 objetos exportados.

### Decisión
Como `install_github()` no instaló las dependencias de Bioconductor ni las de GitHub, estas se instalan aparte y se verifican antes de instalar rCRUX. Se fija el commit `4c0aa904…872c` como la versión usada en este trabajo. El siguiente requisito es BLAST+ (Paso 3).

**Script:** `scripts/01_setup.R`, Paso 2.

> **Nota al pie**
>
> | Si pasa esto… | Haz lo siguiente |
> |---|---|
> | Al cargar `devtools` aparece `package 'usethis' was built under R version 4.4.3` | Es un aviso inofensivo: el paquete se compiló con un R un poco más nuevo que el instalado (4.4.0) |
> | Aparece *"`install_github()` was deprecated in devtools 2.5.0"* | Es solo un aviso y la función sigue funcionando. Se usa `devtools` porque es lo que indica el README de rCRUX |
> | Aparece *"Skipping install… the SHA1 (4c0aa904) has not changed since last install"* | No es un error: rCRUX ya está instalado en esa versión. Agrega `force = TRUE` solo si quieres reinstalar (otros ~54 min) |
> | `devtools` da problemas | `install.packages("remotes")` y luego `remotes::install_github("CalCOFI/rCRUX")` *(no probado)* |

## Paso 3. Instalar BLAST+

**Qué hace.** Instala NCBI BLAST+ y comprueba que R lo encuentre. rCRUX ejecuta por debajo dos programas de BLAST+: `blastn`, que busca los primers en la base de datos, y `blastdbcmd`, que extrae secuencias. rCRUX no los instala, y sin ellos `get_seeds_local()` no puede correr.

### 3.1 Descargar BLAST+ y comprobar que el archivo no está dañado

BLAST+ se descarga desde el [FTP de NCBI](https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.17.0/). El archivo depende del sistema operativo. Para Windows se descargaron `ncbi-blast-2.17.0+-win64.exe` y su archivo de verificación `ncbi-blast-2.17.0+-win64.exe.md5`.

Antes de instalar se comprueba que la descarga llegó completa. `readLines()` lee el código MD5 que NCBI calculó para el instalador y `tools::md5sum()` calcula el del archivo descargado. Si coinciden, el archivo está íntegro. Si no, hay que descargarlo otra vez.

```r
readLines("C:/Users/HP/Downloads/ncbi-blast-2.17.0+-win64.exe.md5")
tools::md5sum("C:/Users/HP/Downloads/ncbi-blast-2.17.0+-win64.exe")
```

Salida:

```
[1] "b78629d1739d1a70bb0907a07f7ea207  ncbi-blast-2.17.0+-win64.exe"

C:/Users/HP/Downloads/ncbi-blast-2.17.0+-win64.exe 
                "b78629d1739d1a70bb0907a07f7ea207" 
```

Resultado obtenido: los dos códigos coinciden, así que el instalador está completo.

### 3.2 Instalar BLAST+

La instalación se hace fuera de R, ejecutando `ncbi-blast-2.17.0+-win64.exe`.

### 3.3 Verificar que R encuentra BLAST+

`has_blast_plus_binaries()` es una función de rCRUX que busca `blastn` y `blastdbcmd` y les pide su versión. Si los encuentra, devuelve `TRUE`.

```r
rCRUX::has_blast_plus_binaries()
```

Salida:

```
[1] TRUE
attr(,"checked_binaries")
             blastn          blastdbcmd 
  "blastn: 2.17.0+" "BLASTD~1: 2.17.0+" 
```

Resultado
`BLASTD~1` es el nombre corto con el que Windows muestra `blastdbcmd`. No es un error. BLAST+ 2.17.0+ quedó instalado y R encuentra `blastn` y `blastdbcmd`.

### Decisión
Se usó BLAST+ **2.17.0+**, una versión posterior al rango que verificaron los autores de rCRUX: *"Version 2.10.1+ through 2.13.0 are verified compatible with rCRUX"* ([README de rCRUX](https://github.com/CalCOFI/rCRUX)). Que funciona se confirmó aquí con `has_blast_plus_binaries()` y, más adelante, con la ejecución correcta de `get_seeds_local()`. El siguiente requisito es la base de taxonomía `accessionTaxa.sql` (Paso 4).

**Script:** `scripts/01_setup.R`, Paso 3.

> **Nota al pie**
>
> | Si pasa esto… | Haz lo siguiente |
> |---|---|
> | `has_blast_plus_binaries()` no devuelve `TRUE` | Cierra RStudio por completo, vuelve a abrirlo y repite la verificación. Si sigue igual, comprueba que el instalador corresponda a tu sistema operativo (`win64.exe` en Windows) *(no probado)* |
> | Los dos códigos MD5 no coinciden | Borra el instalador, descárgalo de nuevo y repite la comprobación *(no probado: aquí coincidieron a la primera)* |

## Paso 4. Construir accessionTaxa.sql

**Qué hace:** Construye la base de datos local de taxonomía que rCRUX necesita para traducir números de accesión (por ejemplo `NC_012920.1`) a su clasificación taxonómica (especie, género, familia, etc.). 

Es una base SQLite creada con el paquete `taxonomizr` y pesa más de 110 GB, por eso el paso se hace una sola vez y conviene hacerlo con buena conexión y espacio libre en disco. 

Se construye a partir de dos fuentes de NCBI:

- Archivo de taxonomía`taxdump` (nombres y jerarquía de los taxones)
- Dos tablas de `accession2taxid`: `nucl_gb` y `nucl_wgs`, que relacionan cada accesión con su taxón

En el disco la base final ocupó 113.4 GB. Los archivos descargados de NCBI, que siguen en la carpeta, ocupan 10.07 GB más: 9.43 GB las dos tablas `accession2taxid` y el resto el taxdump y sus archivos extraídos.

> **Nota sobre el archivo.** Aunque termina en `.sql`, `accessionTaxa.sql` no es un script de texto con comandos SQL: es un archivo binario de base de datos SQLite, que se consulta desde R con las funciones de taxonomizr y no se abre con un editor de texto. No se descarga ya construido de ningún sitio. Se genera en la propia computadora a partir de los archivos públicos de la taxonomía de NCBI:
>
> - Taxonomía (`taxdump.tar.gz`): https://ftp.ncbi.nih.gov/pub/taxonomy/
> - Tablas acceso → taxid (`accession2taxid`): https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/
> - Paquete que la construye (taxonomizr): https://github.com/sherrillmix/taxonomizr y https://CRAN.R-project.org/package=taxonomizr

**¿Que significa FTP y HTTPS?**

> *FTP y HTTPS.* Son dos protocolos, es decir, dos formas en que la computadora pide y recibe archivos de un servidor. Aparecen en la tabla de intentos y en los pasos 4.3 y 4.4.
> - **FTP** (*File Transfer Protocol*, protocolo de transferencia de archivos) es un protocolo antiguo hecho solo para transferir archivos. Usa conexiones separadas para los comandos y para los datos, por eso se corta con más facilidad en conexiones inestables. El código `426` del intento 1 es una respuesta propia de FTP: la transferencia se abortó. Es el protocolo que usa `prepareDatabase()`.
> - **HTTPS** (*Hypertext Transfer Protocol Secure*, protocolo seguro de transferencia de hipertexto) es el que usan los navegadores para abrir páginas web. Descarga por una sola conexión cifrada.
>
> El servidor de NCBI se llama `ftp.ncbi.nih.gov` por razones históricas, pero también responde por `https://`, que es como se descargaron los archivos: a mano desde el navegador en el paso 4.3 y desde R en el paso 4.4.

**Intentos que fallaron**
 
| # | Qué se intentó | Qué pasó | Qué se concluyó |
|---|---|---|---|
| 1 | `prepareDatabase(accession_taxa_sql_path)`, la función oficial que descarga y construye todo de una vez | Falló la descarga de `taxdump.tar.gz`: `Transferred a partial file [ftp.ncbi.nih.gov]: server did not report OK, got 426` | Error de conexión FTP. El avance quedó guardado en la carpeta temporal de R |
| 2 | El mismo comando con `resume = FALSE`, para descargar desde cero | La descarga llegó al 100 %, pero taxonomizr detectó que el archivo no coincidía con el de NCBI: `Local: 2c384486b007d967e9d125bc267f53f2` / `Remote: 13f279c3e479a0437e06e6b16c2541df` | El archivo se dañó en el camino. taxonomizr revisa el MD5 por su cuenta y no lo usó |
| 3 | El mismo comando en una sesión nueva de R | Se cortó casi al empezar (4 %): `download interrupted ... Download failed` | `options(timeout)` se reinicia en cada sesión y no se había vuelto a poner |
| 4 | `Sys.setenv(TMPDIR = "C:/rcrux/temp_downloads")`, borrar los restos con "taxdump" en esa carpeta y repetir con `resume = FALSE` | `transfer closed with 6819615 bytes remaining to read` | Cuarto fallo seguido por FTP: se dejó de usar la descarga automática|
 
Por eso se hizo a mano lo mismo que `prepareDatabase()` hace por dentro (paso 4.2): 

- Descargar la taxonomía a mano, desde el navegador, por HTTPS (paso 4.3)
- Descargar las tablas `accession2taxid` desde R, por HTTPS (paso 4.4)
- Construir la base con las tres funciones de lectura (paso 4.5)

### 4.1 Crear las carpetas de trabajo

Todo el proyecto vive en `C:/rcrux`, con una carpeta por tipo de contenido para saber qué hay en cada una:

- `temp_downloads` guarda archivos temporales de SQLite durante la construccion (paso 4.5)
- `taxonomizr_db` guarda las descargas y la base de taxonomía
- `outputs` guarda los resultados del pipeline.

`showWarnings = FALSE` evita un aviso si la carpeta ya existe, y `recursive = TRUE` crea también `C:/rcrux` si todavía no existe.

```r
dir.create("C:/rcrux/temp_downloads", showWarnings = FALSE)

dir.create("C:/rcrux/taxonomizr_db", recursive = TRUE)

dir.create("C:/rcrux/outputs", recursive = TRUE)
```

### 4.2 Cargar taxonomizr y definir dónde quedará la base

Primero se comprueba que `taxonomizr` esté instalado (debe devolver `TRUE`), se carga y se define la ruta final del archivo `.sql`. Esa ruta se guarda en un objeto porque se usa varias veces. Si se cierra R, la variable se pierde y hay que volver a definirla.

```r
"taxonomizr" %in% rownames(installed.packages())

library(taxonomizr)

accession_taxa_sql_path <- "C:/rcrux/taxonomizr_db/accessionTaxa.sql"
```

Resultado obtenido: `TRUE`. Al cargar `taxonomizr` aparece el aviso `package 'taxonomizr' was built under R version 4.4.3`: el paquete se compiló con una versión de R un poco más nueva que la instalada (4.4.0). No impide nada.

Para saber qué hace `prepareDatabase()` por dentro se muestra su código. En R, el nombre de una función sin paréntesis muestra su código sin ejecutarla:
 
```r
taxonomizr::prepareDatabase
```
 
El código llama, en este orden, a cinco funciones de taxonomizr:
 
| Función dentro de `prepareDatabase()` | Qué hace | Cómo se hizo aquí |
|---|---|---|
| `getNamesAndNodes()` | Descarga y extrae el taxdump (`names.dmp`, `nodes.dmp`) | A mano desde el navegador + `untar()` (paso 4.3) |
| `read.names.sql()` | Carga los nombres en la base | Paso 4.5 |
| `read.nodes.sql()` | Carga la jerarquía en la base | Paso 4.5 |
| `getAccession2taxid()` | Descarga las tablas `accession2taxid` | Paso 4.4, con `protocol = "https"` |
| `read.accession2taxid()` | Carga la relación acceso → taxón en la base | Paso 4.5 |
 
Así se comprueba que hacerlo a mano equivale al método oficial. Aquí `read.nodes.sql()` se corrió antes que `read.names.sql()`; el orden no importa porque cada una llena su propia tabla.

### 4.3 Descargar la taxonomía de NCBI

`taxdump.tar.gz` contiene la jerarquía taxonómica (`nodes.dmp`) y los nombres (`names.dmp`). Como la descarga automática falló cuatro veces, se descargó desde el navegador por [HTTPS](https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz) y se guardó en `C:/rcrux/taxonomizr_db/`. `untar()` lo descomprime y `list.files()` muestra qué quedó en la carpeta.

```r
untar("C:/rcrux/taxonomizr_db/taxdump.tar.gz",
      exdir = "C:/rcrux/taxonomizr_db")
list.files("C:/rcrux/taxonomizr_db")
```
 
Salida (este comando se volvió a correr con el Paso 4 ya terminado, por eso también aparecen la base y las tablas de 4.4):
 
```
 [1] "accessionTaxa.sql"           "citations.dmp"
 [3] "delnodes.dmp"                "division.dmp"
 [5] "gc.prt"                      "gencode.dmp"
 [7] "images.dmp"                  "merged.dmp"
 [9] "names.dmp"                   "nodes.dmp"
[11] "nucl_gb.accession2taxid.gz"  "nucl_wgs.accession2taxid.gz"
[13] "readme.txt"                  "taxdump.tar.gz"
```
 
Los dos archivos que se usan de aquí son `names.dmp` y `nodes.dmp`.

### 4.4 Descargar las tablas accession2taxid por HTTPS
 
`getAccession2taxid()` es la función que `prepareDatabase()` llama por dentro, y por defecto descarga por FTP.

Aquí se ejecuta sola con `protocol = "https"`. `types` pide las dos tablas de nucleótidos (los mismos valores por defecto de taxonomizr). Con `resume = TRUE`, si la descarga se corta basta con repetir el comando y sigue donde se quedó. 

Como los archivos pesan varios GB, el tiempo de espera se sube a 7200 s (120 min). Este cambio solo vale para la sesión actual.

```r
options(timeout = 7200)
taxonomizr::getAccession2taxid(
  outDir   = "C:/rcrux/taxonomizr_db",
  types    = c("nucl_gb", "nucl_wgs"),
  protocol = "https",
  resume   = TRUE
)
```
 
Salida:
 
```
Download status: 1 done; 0 in progress. Total size: 2568.34 Mb (100%)... done!
Downloaded file: https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
Modified: 2026-08-01 03:21:28
Status: 200
Download status: 1 done; 0 in progress. Total size: 6423.63 Mb (100%)... done!
Downloaded file: https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
Modified: 2026-08-01 04:37:45
Status: 206
[1] "C:/rcrux/taxonomizr_db/nucl_gb.accession2taxid.gz"
[2] "C:/rcrux/taxonomizr_db/nucl_wgs.accession2taxid.gz"
```

### 4.5 Construir la base de datos

Con los cuatro archivos listos se ejecutan, en orden, las tres funciones que `prepareDatabase()` corre por dentro. Las tres escriben en el mismo archivo `accessionTaxa.sql`:
 
- `read.nodes.sql()` carga la jerarquía taxonómica (qué taxón pertenece a cuál).
- `read.names.sql()` carga los nombres de cada taxón.
- `read.accession2taxid()` carga la relación acceso → taxón. Es la más pesada.

`extraSqlCommand` hace que SQLite escriba sus archivos temporales en `temp_downloads`, una carpeta en un disco con espacio suficiente. La documentación de taxonomizr recomienda esta opción cuando la carpeta temporal por defecto tiene poco espacio.
 
```r
read.nodes.sql(
  nodeFile = "C:/rcrux/taxonomizr_db/nodes.dmp",
  sqlFile   = accession_taxa_sql_path
)
 
read.names.sql(
  nameFile = "C:/rcrux/taxonomizr_db/names.dmp",
  sqlFile   = accession_taxa_sql_path
)
 
read.accession2taxid(
  taxaFiles = c("C:/rcrux/taxonomizr_db/nucl_gb.accession2taxid.gz",
                "C:/rcrux/taxonomizr_db/nucl_wgs.accession2taxid.gz"),
  sqlFile   = accession_taxa_sql_path,
  extraSqlCommand = "PRAGMA temp_store_directory = 'C:/rcrux/temp_downloads'"
)
```
 
`read.accession2taxid()` muestra dos fases, *"Reading in values. This may take a while."* y *"Adding index. This may also take a while."*, y terminó sin interrupciones. En este equipo la construcción completa tardó unas **2 h 14 min**.

### 4.6 Verificar la base
 
Se comprueba que el archivo existe, cuánto pesa y que funciona. Para la prueba se busca un acceso conocido: `NC_012920.1`, el genoma mitocondrial humano de referencia, que debe devolver *Homo sapiens*.
 
```r
file.exists(accession_taxa_sql_path)
file.info(accession_taxa_sql_path)$size / 1e9
getTaxonomy(accessionToTaxa("NC_012920.1", accession_taxa_sql_path), accession_taxa_sql_path)
```
 
Salida:
 
```
[1] TRUE
[1] 113.438
     domain      phylum     class     
9606 "Eukaryota" "Chordata" "Mammalia"
     order      family      genus 
9606 "Primates" "Hominidae" "Homo"
     species       
9606 "Homo sapiens"
Hubo 33 avisos (use warnings() para verlos)
```
 
La prueba recorre las tres tablas: el acceso se traduce al taxid 9606 y el taxid a la clasificación completa. Las tres funcionan.
 
### Resultado
`accessionTaxa.sql` quedó construida (113.4 GB) con la taxonomía de NCBI del 2026-08-07 y las tablas `accession2taxid` del 2026-08-01, y traduce los accesos correctamente.
 
### Decisión
En lugar de `prepareDatabase()` se usaron por separado las funciones que esta ejecuta por dentro, descargando a mano y por HTTPS, porque la descarga automática por FTP falló cuatro veces seguidas. El resultado es el mismo tipo de base que produce el método oficial. Esta vía está prevista en el README de rCRUX: *"For poor bandwidth connections, please see the taxonomizr readme for manual installation of the accessionTaxa.sql database"* ([README de rCRUX](https://github.com/CalCOFI/rCRUX)). La ruta `C:/rcrux/taxonomizr_db/accessionTaxa.sql` es la que reciben las funciones de rCRUX en el argumento `accession_taxa_sql_path`.
 
**Script:** `scripts/01_setup.R`, Paso 4.
 
> **Nota al pie**
>
> | Si pasa esto… | Haz lo siguiente |
> |---|---|
> | `getTaxonomy()` muestra `Hubo 33 avisos`; con `warnings()` se ven como `In file.remove(tmp): no fue posible abrir el archivo 'C:\Users\HP\AppData\Local\Temp\Rtmp…\file…', motivo 'Permission denied'` | Inofensivo: `getTaxonomy()` crea archivos temporales para la consulta y Windows no deja borrarlos porque siguen abiertos. Aparecen en cada consulta y el resultado es correcto |
> | Se conservan en `C:/rcrux/taxonomizr_db` los archivos descargados (10.07 GB: taxdump, `.dmp` y las dos tablas `.accession2taxid.gz`), aunque el README de rCRUX recomienda borrar todo menos `accessionTaxa.sql` cuando la base se construye a mano | Se conservan para no tener que descargarlos de nuevo si hay que reconstruir la base. Si se borran, `accessionTaxa.sql` sigue funcionando igual y se liberan 10.07 GB, pero para reconstruirla habría que volver a descargar todo. Según los autores, conservarlos puede generar un aviso en rCRUX *(no observado hasta este paso)* |

## Paso 5. Descargar la base BLAST mito
 
**Qué hace:** Descarga y valida la base de datos de secuencias en la que rCRUX hace la PCR *in silico*.
 
**Qué pide rCRUX.** El README de rCRUX indica que se necesita una base de nucleótidos local en formato BLAST (*"rCRUX requires a local blast-formatted nucleotide database"*). La usan dos funciones del pipeline:
 
- `get_seeds_local()`: la PCR *in silico*. Busca en la base las secuencias que contienen los dos primers.
- `blast_seeds()`: el paso siguiente. Usa esas secuencias como semilla para buscar en la base secuencias parecidas a las que les falta uno o ambos primers.

Como base, el README propone la `nt` completa de NCBI (~242 GB) y su descarga con `update_blastdb.pl`, una herramienta que NCBI incluye con BLAST+ (*"NCBI provides a tool (perl script) for downloading databases as part of the blast+ package"*).
 
**Qué se hizo aquí.** En lugar de `nt` se descargó la base preformada `mito` de NCBI (*NCBI Genomic Mitochondrial Reference Sequences*, 194 MB), que contiene genomas mitocondriales de referencia. Se usa **solo para la PCR *in silico** (`get_seeds_local()`); `blast_seeds()` queda para una fase posterior.
 
**Por qué no se usó `update_blastdb.pl`.** Es un script de Perl, y R en Windows no lo ejecuta porque Windows no trae Perl. El equipo tiene WSL (Linux dentro de Windows), donde sí se podría correr, pero no se probó. No hacía falta: `update_blastdb.pl` solo automatiza la descarga de los archivos `.tar.gz` que NCBI publica en https://ftp.ncbi.nlm.nih.gov/blast/db/. Al bajarlos a mano desde el navegador se obtiene el mismo archivo, y el MD5 del apartado 5.1 lo confirma.
 
### 5.1 Descargar la base y comprobar que no está dañada
 
Se crea la carpeta donde vivirá la base. Después se descargan desde el navegador `mito.tar.gz` y su archivo de verificación `mito.tar.gz.md5` (https://ftp.ncbi.nlm.nih.gov/blast/db/mito.tar.gz, publicado el 2026-08-04) y se guardan en esa carpeta. Igual que con BLAST+ (paso 3.1), se compara el MD5 que publica NCBI con el del archivo descargado.
 
```r
dir.create("C:/rcrux/blast_db")
 
hash_esperado <- readLines("C:/rcrux/blast_db/mito.tar.gz.md5")
print(hash_esperado)
 
library(tools)
hash_obtenido <- md5sum("C:/rcrux/blast_db/mito.tar.gz")
print(hash_obtenido)
```
 
Salida:
 
```
[1] "bf58a9a1426cc41f2d2ad3b9f97ee0c1  mito.tar.gz"
     C:/rcrux/blast_db/mito.tar.gz 
"bf58a9a1426cc41f2d2ad3b9f97ee0c1" 
```
 
Resultado obtenido: los dos códigos coinciden, así que la descarga está completa.
 
### 5.2 Descomprimir y validar la base
 
`untar()` extrae los archivos de la base y `list.files()` muestra qué quedó en la carpeta.
 
```r
untar("C:/rcrux/blast_db/mito.tar.gz", exdir = "C:/rcrux/blast_db")
list.files("C:/rcrux/blast_db")
```
 
Salida:
 
```
 [1] "mito.ndb"  "mito.nhr"  "mito.nin"  "mito.nnd"  "mito.nni"  "mito.nog"
 [7] "mito.nos"  "mito.not"  "mito.nsq"  "mito.ntf"  "mito.nto"
[12] "mito.tar.gz"  "mito.tar.gz.md5"
[14] "taxdb.btd"  "taxdb.bti"  "taxonomy4blast.sqlite3"
```
 
Los 11 archivos `mito.*` forman la base en formato BLASTDB versión 5. La lista de 8 archivos que menciona el README de rCRUX (con `.nhd` y `.nhi`) corresponde a una versión anterior del formato. `taxdb.*` y `taxonomy4blast.sqlite3` vienen incluidos en `mito.tar.gz`.
 
Después se comprueba que BLAST+ reconoce la base. `blastdbcmd -info` lee la base y muestra su descripción:
 
```r
system('blastdbcmd -db "C:/rcrux/blast_db/mito" -info')
```
 
Salida:
 
```
Database: NCBI Genomic Mitochondrial Reference Sequences
	18,034 sequences; 594,169,998 total bases
 
Date: Aug 3, 2026  12:48 AM	Longest sequence: 2,290,019 bases
 
BLASTDB Version: 5
 
Volumes:
	C:\rcrux\blast_db\mito
[1] 0
```
 
Por último se extrae una secuencia, igual que la prueba que propone el README de rCRUX con `blastdbcmd -entry`. El acceso del README (`MN937193.1`) es de GenBank y no forma parte de `mito`, así que se usa el genoma mitocondrial humano de referencia, el mismo acceso que se usó para probar `accessionTaxa.sql` (paso 4.6):
 
```r
system('blastdbcmd -db "C:/rcrux/blast_db/mito" -entry NC_012920.1 -range 1-60')
```
 
Salida:
 
```
>NC_012920.1:1-60 Homo sapiens mitochondrion, complete genome
GATCACAGGTCTATCACCCTATTAACCACTCACGGGAGCTCTCCATGCATTTGGTATTTT
[1] 0
```
 
### Resultado
La base `mito` quedó descargada, íntegra y funcional: 18,034 secuencias mitocondriales de referencia, versión del 3 de agosto de 2026, de la que BLAST+ lee la descripción y extrae secuencias.
 
### Decisión
Se necesitaba una base local porque `get_seeds_remote()`, la vía que los autores proponen para probar primers sin descargar `nt`, no es confiable por sí sola: requiere corregir tres errores del código de rCRUX, la respuesta de NCBI varía entre consultas y los resultados tienen tope (ver la sección «Nota: la vía remota con `get_seeds_remote()`», al final de este documento). Se eligió `mito` en lugar de `nt` porque el equipo tenía 185 GB libres; según los autores, `nt` junto con la base de taxonomía requería más de 340 GB en abril de 2023 (Curd et al., 2024). `mito` contiene la región que amplifican los primers comparados, que son todos mitocondriales (12S, 16S y COI), y sirve para compararlos entre sí porque todos se prueban contra la misma base.
 
Usar `mito` como base BLAST tiene precedente en el artículo de rCRUX: una de las tres estrategias con las que los autores construyeron su base de COI fue *"NCBI mito blast database"* (Curd et al., 2024, Tabla 1, "CO1 ncbi mito").
 
**Limitación:** `mito` solo incluye genomas mitocondriales completos de referencia (RefSeq). Las especies que en NCBI solo tienen fragmentos de 12S, 16S o COI no están en esta base. 

En el artículo, la estrategia con `mito` recuperó 3,269,089 secuencias de COI, contra 5,413,965 de la base combinada (Curd et al., 2024, Tabla 1). Por eso los números de la PCR *in silico* son una estimación mínima de lo que cada primer puede amplificar, y una especie ausente puede deberse a la base y no al primer.
 
La base general `nt` está prevista para construirse en el servidor del laboratorio. `mito` es funcional para la PCR *in silico*, que es la etapa actual. 

Para completar la base de referencia hace falta `nt`: la usa `blast_seeds()` para encontrar secuencias de la misma región aunque no contengan los primers. Esa base de referencia es la que después se usará para asignar taxonomía a los ASV de las muestras. La ruta `C:/rcrux/blast_db/mito` es la que recibe `get_seeds_local()` en el argumento `blast_db_path`.
 
**Script:** `scripts/01_setup.R`, Paso 5.
 
> **Nota al pie**
>
> | Si pasa esto… | Haz lo siguiente |
> |---|---|
> | Después de cada `system()` aparece `[1] 0` | No es un error: es el código de salida del programa, y `0` significa que terminó bien |
> | Los dos códigos MD5 no coinciden | Borra `mito.tar.gz`, descárgalo de nuevo y repite la comprobación *(no probado: aquí coincidieron a la primera)* |
 
**Referencia:** Curd, E. E., Gal, L., Gallego, R., Silliman, K., Nielsen, S., & Gold, Z. (2024). rCRUX: A rapid and versatile tool for generating metabarcoding reference libraries in R. *Environmental DNA*, 6, e489. https://doi.org/10.1002/edn3.489
 
## Nota: la vía remota con `get_seeds_remote()`
 
**Qué dice rCRUX.** rCRUX tiene dos funciones para la PCR *in silico*. `get_seeds_local()` busca en una base BLAST guardada en la computadora (Paso 5). `get_seeds_remote()` no necesita base local: manda los primers a Primer-BLAST, la herramienta web de NCBI, y lee la página de resultados (*"submits a web form directly to NCBI's primer blast tool"*, Curd et al., 2024). Los autores la proponen para probar primers *"without downloading the large (>340 GB) nt database"*, aunque advierten que está sujeta a los límites del servidor de NCBI y señalan a `get_seeds_local()` como *"the preferred implementation in the rCRUX environment"*.
 
El README de rCRUX indica correrla así:
 
```r
forward_primer_seq = "TAGAACAGGCTCCTCTAG"
reverse_primer_seq = "TTAGATACCCCACTATGC"
output_directory_path <- "/my/directory/12S_V5F1_remote_111122"
metabarcode_name <- "12S_V5F1"
accession_taxa_sql_path <- "/my/directory/accessionTaxa.sql"
 
get_seeds_remote(forward_primer_seq,
                 reverse_primer_seq,
                 metabarcode_name,
                 output_directory_path,
                 accession_taxa_sql_path,
                 organism = c("1476529", "7776"),
                 return_table = FALSE)
```
 
`organism` indica los grupos en los que se busca: `1476529` son los vertebrados sin mandíbula (lampreas y mixinos) y `7776` los vertebrados con mandíbula (todos los demás, incluidos los mamíferos).
 
### Pruebas realizadas
 
Se corrió el ejemplo del README tal cual, cambiando solo las rutas (`C:/rcrux/outputs_remote/12S_V5F1_remote` y la base `accessionTaxa.sql` del Paso 4), en una sesión de R limpia, con rCRUX en el commit `4c0aa904` (el más reciente del repositorio). Cada vez que apareció un error se corrigió solo ese error y se repitió, para ver hasta dónde llega la función. 

El código de las seis pruebas está en `scripts/01_setup.R`, sección "Nota: get_seeds_remote()", dentro de un bloque `if (FALSE)` para que no se ejecute al correr el script completo (cada consulta a NCBI tarda de 4 a 20 minutos).
 
| # | Qué se corrió | Qué salió | Qué se concluyó |
|---|---|---|---|
| 1 | El ejemplo del README, sin cambios | `Error en inherits(response): el argumento "what" está ausente, sin valor por omisión` | Error en el código de rCRUX (corrección 1). El mismo error lo reportó otra persona en el repositorio de rCRUX con el ejemplo de la documentación ([issue #37](https://github.com/CalCOFI/rCRUX/issues/37), agosto de 2025), sin respuesta de los autores |
| 2 | Lo mismo, con la corrección 1 | `Output is not a data.frame` y el aviso `objeto 'num_primers' no encontrado` (una vez por cada grupo de `organism`) | Segundo error en el código de rCRUX (corrección 2) |
| 3 | Lo mismo, con las correcciones 1 y 2 | La consulta llegó a NCBI y regresó (`BLAST alignment completed`), pero falló al procesar los resultados: `Column 'forward_primer_seq' not found in '.data'` | Tercer error en el código de rCRUX (corrección 3). Además, el mensaje `Output directory: 12S_V5F1/get_seeds_local` muestra que el nombre del marcador se usó como carpeta (corrección 4) |
| 4 | Lo mismo, con las correcciones 1, 2 y 3 y los argumentos nombrados | Procesó y asignó taxonomía, pero falló al guardar: `no se puede abrir la conexión … No such file or directory` | rCRUX crea la subcarpeta de salida sin crear la carpeta que la contiene (corrección 5) |
| 5 | Lo mismo, con las cinco correcciones (23:28–23:49) | Guardó los tres archivos de salida, pero con el aviso `parse_primer_hits returned an object that is not a dataframe` y `This occurred while processing organism 7776`. Resultado: 102 hits y 30 especies, 101 de ellos de la clase Hyperoartia (lampreas) | Funcionó para `1476529`, pero **perdió todo el grupo `7776`** sin detenerse: no pudo leer la respuesta de NCBI para ese grupo |
| 6 | Consulta directa a NCBI solo para `7776`, con la función interna `primer_search()` (23:54–23:57), y lectura de la respuesta con `parse_primer_hits()` | La página trajo los resultados (448,893 caracteres, 1,000 etiquetas `<pre>`) y se leyeron sin error: 1,000 resultados (por ejemplo *Bos grunniens*, *Elacatinus prochilos*, *Anser anser*) | La misma consulta que en la prueba 5 no se pudo leer, aquí sí. **La respuesta de NCBI varía entre consultas.** Además, 1,000 exactos indica un tope de resultados |
 
Los tiempos que imprime rCRUX (*"BLAST alignment completed in 13.97 seconds"*) están en minutos aunque digan *seconds*: esa consulta tardó unos 14 minutos según `Sys.time()`.
 
### Correcciones al código de rCRUX
 
Ninguna corrección cambia el análisis (primers, bases, filtros o parámetros): solo hacen que el código haga lo que los autores describen. Los tres errores de código siguen en la versión más reciente del repositorio, y cada uno se puede verificar en el archivo y la línea indicados.
 
| # | Dónde está el error | Qué está mal | Corrección | Sustento |
|---|---|---|---|---|
| 1 | `R/iterative_primer_search.r`, líneas 41 y 53 | `inherits(response) == "try-error"`: a `inherits()` le falta el argumento `what` | `inherits(response, "try-error")` (igual con `parsed`) | Error al correr el ejemplo del README (prueba 1); documentación de R de `inherits(x, what)`; [issue #37](https://github.com/CalCOFI/rCRUX/issues/37) |
| 2 | `R/modifiedPrimerTreeFunctions.R`, función `primer_search()`, líneas 26–30 | El cálculo de `primers` y `num_primers` está dentro de `if (missing(forward) \|\| missing(reverse))`, que no se ejecuta en el uso normal | Sacar esas dos líneas del `if` | Error de la prueba 2; ese archivo está señalado por los autores como pendiente de limpieza ([issue #17](https://github.com/CalCOFI/rCRUX/issues/17)) |
| 3 | `R/filter_primer_hits.r`, líneas 50–52 | `nchar(.data$forward_primer_seq)` busca una columna con ese nombre en la tabla, y no existe | Usar los primers que recibe la función: `nchar(forward_primer_seq)` | Error de la prueba 3; los propios autores dejaron un comentario sobre la duda: *"we either need to pass the forward and reverse primers to this function… Or maybe that is supposed to happen in another function?"* |
| 4 | Ejemplo del README | Pasa `metabarcode_name` antes que `output_directory_path`, pero la función los define en el orden contrario | Llamar la función con los argumentos nombrados | Definición de la función y su propio ejemplo en `R/get_seeds_remote.R`, líneas 159–170, que usan el orden correcto. No es el único error reportado en el README: el [issue #31](https://github.com/CalCOFI/rCRUX/issues/31) (2024) señala que el README nombra `blast_seeds_local()` y `blast_seeds_remote()` donde debería decir `get_seeds_local()` y `get_seeds_remote()` |
| 5 | `R/get_seeds_remote.R`, línea 201: `dir.create(out, showWarnings = FALSE)` | Crea la subcarpeta sin `recursive = TRUE`, así que falla en silencio si la carpeta de salida no existe | Crear antes la carpeta de salida | Error de la prueba 4 |
 
Las correcciones 1 a 3 se aplican durante la sesión de R con `assignInNamespace()`, que reemplaza la función dentro del paquete sin modificar los archivos instalados. Hay que volver a aplicarlas cada vez que se abre R:
 
```r
library(rCRUX)
 
# Corrección 1: iterative_primer_search()
txt <- deparse(rCRUX::iterative_primer_search)
txt <- gsub('inherits\\((\\w+)\\) == "try-error"', 'inherits(\\1, "try-error")', txt)
fixed_iterative_primer_search <- eval(parse(text = txt))
environment(fixed_iterative_primer_search) <- asNamespace("rCRUX")
assignInNamespace("iterative_primer_search", fixed_iterative_primer_search, ns = "rCRUX")
 
# Corrección 2: primer_search(), con el cálculo de num_primers fuera del if
fixed_primer_search <- function(forward, reverse, num_permutations = 25,
                                ..., .parallel = FALSE, .progress = 'none') {
  if (missing(forward) || missing(reverse)) {
    BLAST_primer()
  }
  primers <- enumerate_primers(forward, reverse)
  num_primers <- nrow(primers)
  if (num_primers > num_permutations) {
    warning(immediate. = TRUE, 'primers have ', num_primers,
            ' possible combinations due to degenerate bases, sampling ',
            num_permutations, " primers, use 'num_permutations' to change")
    primers <- primers[sample.int(num_primers, num_permutations, replace = FALSE), ]
  }
  message('BLASTing ', nrow(primers), ' primer combinations')
  plyr::alply(.data = primers, .margins = 1, .expand = FALSE,
              .parallel = .parallel, .progress = .progress,
              function(row) {
                BLAST_primer(row$forward, row$reverse, ...)
              })
}
environment(fixed_primer_search) <- asNamespace("rCRUX")
assignInNamespace("primer_search", fixed_primer_search, ns = "rCRUX")
 
# Corrección 3: filter_primer_hits()
txt <- deparse(rCRUX::filter_primer_hits)
txt <- gsub(".data$forward_primer_seq", "forward_primer_seq", txt, fixed = TRUE)
txt <- gsub(".data$reverse_primer_seq", "reverse_primer_seq", txt, fixed = TRUE)
fixed_filter_primer_hits <- eval(parse(text = txt))
environment(fixed_filter_primer_hits) <- asNamespace("rCRUX")
assignInNamespace("filter_primer_hits", fixed_filter_primer_hits, ns = "rCRUX")
 
# Correcciones 4 y 5: crear la carpeta y nombrar los argumentos
dir.create(output_directory_path, recursive = TRUE, showWarnings = FALSE)
get_seeds_remote(forward_primer_seq      = forward_primer_seq,
                 reverse_primer_seq      = reverse_primer_seq,
                 output_directory_path   = output_directory_path,
                 metabarcode_name        = metabarcode_name,
                 accession_taxa_sql_path = accession_taxa_sql_path,
                 organism = c("1476529", "7776"),
                 return_table = FALSE)
```
 
La prueba 6 se hizo con este código, que no forma parte del flujo de trabajo de rCRUX: llama directamente a `primer_search()`, la función interna con la que rCRUX consulta NCBI, y revisa la página que devuelve.
 
```r
raw_response_list <- rCRUX:::primer_search(forward  = forward_primer_seq,
                                           reverse  = reverse_primer_seq,
                                           organism = "7776",
                                           primer_specificity_database = "nt")
r1 <- raw_response_list[[1]]
html_text <- httr::content(r1, as = "text", encoding = "UTF-8")
nchar(html_text)                              # 448893
length(gregexpr("<pre", html_text)[[1]])      # 1000
p <- rCRUX:::parse_primer_hits(r1)
nrow(p)                                       # 1000
```
 
### Ventajas y limitaciones frente a `get_seeds_local()`
 
| | `get_seeds_local()` + `mito` | `get_seeds_remote()` |
|---|---|---|
| Dónde busca | `mito`: 18,034 genomas mitocondriales de referencia (Paso 5) | `nt` completa, en los servidores de NCBI |
| Especies que en NCBI solo tienen fragmentos de 12S, 16S o COI | No las encuentra | **Sí las encuentra** (por ejemplo, accesos como `OZ482865.1` o `XR_014572079.1` de la prueba 6, que no son genomas de referencia) |
| Funciona tal como viene | Sí | No: requiere las cinco correcciones |
| Resultados estables entre corridas | Sí | No: la misma consulta a veces se lee y a veces no (pruebas 5 y 6) |
| Tope de resultados | No | Unos 1,000 por consulta con los valores por defecto. El README lo advierte (*"only 1047 hits are returned"*) y su ejemplo avanzado lo sube con `HITSIZE = '1000000'` |
| Necesita base local | Sí | No |
 
### Decisión
 
`get_seeds_local()` con `mito` es la vía principal para comparar los primers, porque funciona como la publican los autores y da resultados estables y sin tope. `get_seeds_remote()` no es confiable por sí sola: necesita cinco correcciones, puede perder grupos enteros sin detenerse y su número de resultados tiene tope. Su ventaja es que busca en `nt`, así que encuentra especies que no están en `mito`. Por eso cada set de primers se correrá con las dos vías y se compararán los resultados: la remota sirve para notar diferencias y para revisar si una especie no detectada con `mito` falta por la base o por el primer. En cada corrida remota hay que aplicar las correcciones y revisar los avisos (`warnings()`) para confirmar que no se perdió ningún grupo.
