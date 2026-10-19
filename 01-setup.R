### PIPELINE rCRUX ###

# Fuente: README - CalCOFI/rCRUX
# https://github.com/CalCOFI/rCRUX
# Este script se corre una sola vez para preparar el entorno y equipo.


# Paso 1. Verificar el entorno de R y Rtools ---####
# Lo siguiente es un requisito de windows para instalar paquetes

# 1.1 Version de R
# La version de Rtools debe coincidir con la de R
R.version.string # "R version 4.4.0 (2024-04-24 ucrt)"

# 1.2 Verificar si R encuentra Rtools (herramienta de compilacion)
# Verifiacion de herramienta de compilacion - RTools
Sys.which("make") ## ""  -> Rtools no instalado

# 1.3 Instalacion de Rtools44 (fuera de R)

# Al no estar instalado se descargó desde el sitio oficial
# https://cran.r-project.org/bin/windows/Rtools/rtools44/
# rtools44-6459-6401.exe (~431 MB)
# Acepta los permisos y reinicia completamente Rstudio

# 1.4 Repetir la verificacion de RTools
Sys.which("make") # "C:\\rtools44\\usr\\bin\\make.exe"

# Paso 2. Instalar rCRUX y sus dependencias ---####
# Orden: devtools -> dependencias de Bioconductor -> 
# dependencias de GitHub -> rCRUX.

# 2.1 Cargar devtools
# devtools trae install_github(), que instala rCRUX desde GitHub en 2.4

# Instala la paqueteria
# if (!require("devtools")) install.packages("devtools")

# Llama a la libreria
library(devtools)

# Solo si install_github() falla con "Bad credentials" (PAT de GitHub 
# guardado en Windows):
# install.packages("gitcreds")
# gitcreds::gitcreds_delete() # opción 2: "Delete these credentials"

# 2.2 Instalar las dependencias de Bioconductor

# No están en CRAN; se instalan con el gestor de Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE)) 
  install.packages("BiocManager")

options(timeout = 600) # 600 s para paquetes grandes; vale solo para esta sesion

BiocManager::install(c("GenomeInfoDb", "Biostrings", "phyloseq"),
                     update = FALSE, ask = FALSE) 
# si pregunta por actualizar: n

c("GenomeInfoDb", "Biostrings", "phyloseq") %in% rownames(installed.packages())
# TRUE TRUE TRUE

# 2.3 Instalar las dependencias de GitHub
# No estaban disponibles en CRAN al momento de la instalación
remotes::install_github("helixcn/phylotools")
remotes::install_github("cpauvert/psadd")

c("phylotools", "psadd") %in% rownames(installed.packages())
# TRUE TRUE

# 2.4 Instalar rCRUX
# Comando del README oficial; tardó ~54 min
devtools::install_github("CalCOFI/rCRUX", build_vignettes = TRUE)

library(rCRUX)
ls("package:rCRUX")
length(ls("package:rCRUX")) # 20

# Versión y commit exactos, para poder reinstalar esta misma versión
packageVersion("rCRUX") 
# 0.1.0.0
packageDescription("rCRUX")$RemoteSha 
# 4c0aa9046d3636262d3f75b20d2a17f85381872c

# Paso 3. Instalar BLAST+ ---####

# rCRUX usa los programas blastn y blastdbcmd de NCBI
# BLAST+, pero no los instala.

# En el README de rCRUX: versiones verificadas 2.10.1+ a 2.13.0
# Aquí se usa 2.17.0+

# 3.1 Descargar BLAST+ y comprobar que el archivo no esta dañado

# Descarga: https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.17.0/
# Archivos (Windows): ncbi-blast-2.17.0+-win64.exe y 
# ncbi-blast-2.17.0+-win64.exe.md5. Si el MD5 de NCBI y el del archivo 
# descargado coinciden, el archivo está íntegro

readLines("C:/Users/HP/Downloads/ncbi-blast-2.17.0+-win64.exe.md5")
# "b78629d1739d1a70bb0907a07f7ea207  ncbi-blast-2.17.0+-win64.exe"

tools::md5sum("C:/Users/HP/Downloads/ncbi-blast-2.17.0+-win64.exe")
# "b78629d1739d1a70bb0907a07f7ea207"  -> coinciden

# 3.2 Instalar BLAST+ (fuera de R)
# Ejecutar ncbi-blast-2.17.0+-win64.exe

# 3.3 Verificar que R encuentra BLAST+
rCRUX::has_blast_plus_binaries()

# TRUE  (blastn 2.17.0+, blastdbcmd 2.17.0+)

# Paso 4. Construir accessionTaxa.sql ---####
# Base SQLite de taxonomizr que traduce números de acceso de NCBI a taxonomía.
# rCRUX la necesita en todas sus funciones. 
# PrepareDatabase() falló por FTP

# 4.1 Crear las carpetas de trabajo

# Carpetas creadas para proyecto rCRUX

dir.create("C:/rcrux/temp_downloads", showWarnings = FALSE)
dir.create("C:/rcrux/taxonomizr_db", recursive = TRUE)
dir.create("C:/rcrux/outputs", recursive = TRUE)

# 4.2 Cargar taxonomizr y definir dónde quedará la base
"taxonomizr" %in% rownames(installed.packages()) # TRUE
library(taxonomizr)
accession_taxa_sql_path <- "C:/rcrux/taxonomizr_db/accessionTaxa.sql"

# Muestra el código de prepareDatabase() sin ejecutarlo: llama a 
# getNamesAndNodes(), read.names.sql(), read.nodes.sql(), getAccession2taxid() 
# y read.accession2taxid()
taxonomizr::prepareDatabase

# 4.3 Descargar la taxonomía de NCBI
# Descargado a mano desde el navegador:
# https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz -> C:/rcrux/taxonomizr_db/
untar("C:/rcrux/taxonomizr_db/taxdump.tar.gz",
      exdir = "C:/rcrux/taxonomizr_db")
list.files("C:/rcrux/taxonomizr_db") # deben aparecer names.dmp y nodes.dmp

# 4.4 Descargar las tablas accession2taxid por HTTPS
# 7200 s (120 min); vale solo para esta sesión
options(timeout = 7200)
taxonomizr::getAccession2taxid(
  outDir   = "C:/rcrux/taxonomizr_db",
  types    = c("nucl_gb", "nucl_wgs"),
  protocol = "https",
  resume   = TRUE # si se corta, repetir el comando: sigue donde se quedó
)
# nucl_gb.accession2taxid.gz (2568.34 MB) y nucl_wgs.accession2taxid.gz 
# (6423.63 MB)

# 4.5 Construir la base de datos
# Las tres funciones que prepareDatabase() corre por dentro; tardó ~2 h 14 min
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

# 4.6 Verificar la base
file.exists(accession_taxa_sql_path) # TRUE
file.info(accession_taxa_sql_path)$size / 1e9 # 113.438
getTaxonomy(accessionToTaxa("NC_012920.1", accession_taxa_sql_path), 
            accession_taxa_sql_path)
# Homo sapiens (taxid 9606); 33 avisos inofensivos

# Paso 5. Descargar la base BLAST mito ---####
# rCRUX necesita una base de nucleótidos en formato BLAST para get_seeds_local()
# (PCR in silico) y blast_seeds(). El README propone nt (~242 GB).
# Aquí se usa mito (genomas mitocondriales de referencia, 194 MB) solo para la PCR in silico.

# 5.1 Descargar la base y comprobar que no está dañada

#crear un directorio de almacenamiento para la base descargada
dir.create("C:/rcrux/blast_db")

# Descarga manual desde el navegador a C:/rcrux/blast_db/
# (en lugar de update_blastdb.pl, que es un script de Perl; ver README):
# https://ftp.ncbi.nlm.nih.gov/blast/db/mito.tar.gz y mito.tar.gz.md5

# Hash esperado (el que publica NCBI)
hash_esperado <- readLines("C:/rcrux/blast_db/mito.tar.gz.md5")
print(hash_esperado)

# Hash obtenido
library(tools)
hash_obtenido <- md5sum("C:/rcrux/blast_db/mito.tar.gz")
print(hash_obtenido)
# bf58a9a1426cc41f2d2ad3b9f97ee0c1 en ambos -> coinciden

# 5.2 Descomprimir y validar la base
untar("C:/rcrux/blast_db/mito.tar.gz", exdir = "C:/rcrux/blast_db")
list.files("C:/rcrux/blast_db") # 11 archivos mito.* (BLASTDB v5) + taxdb

# Verificar que blastn reconoce la base como válida
system('blastdbcmd -db "C:/rcrux/blast_db/mito" -info')
# 18,034 secuencias; 594,169,998 bases; Aug 3, 2026; BLASTDB Version: 5

# Extraer una secuencia de prueba (genoma mitocondrial humano)
system('blastdbcmd -db "C:/rcrux/blast_db/mito" -entry NC_012920.1 -range 1-60')
# >NC_012920.1:1-60 Homo sapiens mitochondrion, complete genome

# Nota: get_seeds_remote() ---####
# El README de rCRUX propone get_seeds_remote() para la PCR in silico sin base local.
# Aquí se probó tal como indica el README y se corrigió un error a la vez.
# Resultado: tres errores en el código de rCRUX, el ejemplo del README pasa dos argumentos
# en el orden equivocado y la carpeta de salida debe existir antes. Con las cinco
# correcciones funciona, pero la respuesta de NCBI varía entre consultas y tiene tope
# (~1000 resultados). Detalle y salidas: README, "Nota: la vía remota con get_seeds_remote()".
#
# El bloque va dentro de if (FALSE) para que NO se ejecute al correr el script completo:
# cada consulta a NCBI tarda de 4 a 20 minutos. Para repetir las pruebas, correr las líneas
# una por una, en una sesión de R limpia.

if (FALSE) {
  
  library(rCRUX)
  forward_primer_seq = "TAGAACAGGCTCCTCTAG"
  reverse_primer_seq = "TTAGATACCCCACTATGC"
  output_directory_path <- "C:/rcrux/outputs_remote/12S_V5F1_remote"
  metabarcode_name <- "12S_V5F1"
  accession_taxa_sql_path <- "C:/rcrux/taxonomizr_db/accessionTaxa.sql"
  
  # Prueba 1. Ejemplo del README tal cual
  # Error: inherits(response): el argumento "what" está ausente (igual al issue #37)
  get_seeds_remote(forward_primer_seq, reverse_primer_seq, metabarcode_name,
                   output_directory_path, accession_taxa_sql_path,
                   organism = c("1476529", "7776"), return_table = FALSE)
  
  # Corrección 1: iterative_primer_search(), inherits(x) == "try-error" -> inherits(x, "try-error")
  txt <- deparse(rCRUX::iterative_primer_search)
  txt <- gsub('inherits\\((\\w+)\\) == "try-error"', 'inherits(\\1, "try-error")', txt)
  fixed_iterative_primer_search <- eval(parse(text = txt))
  environment(fixed_iterative_primer_search) <- asNamespace("rCRUX")
  assignInNamespace("iterative_primer_search", fixed_iterative_primer_search, ns = "rCRUX")
  
  # Prueba 2. Error: objeto 'num_primers' no encontrado
  get_seeds_remote(forward_primer_seq, reverse_primer_seq, metabarcode_name,
                   output_directory_path, accession_taxa_sql_path,
                   organism = c("1476529", "7776"), return_table = FALSE)
  
  # Corrección 2: primer_search(), num_primers fuera del if
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
  
  # Prueba 3. NCBI responde; error: Column 'forward_primer_seq' not found in '.data'
  get_seeds_remote(forward_primer_seq, reverse_primer_seq, metabarcode_name,
                   output_directory_path, accession_taxa_sql_path,
                   organism = c("1476529", "7776"), return_table = FALSE)
  
  # Corrección 3: filter_primer_hits(), usar los primers que recibe la función
  txt <- deparse(rCRUX::filter_primer_hits)
  txt <- gsub(".data$forward_primer_seq", "forward_primer_seq", txt, fixed = TRUE)
  txt <- gsub(".data$reverse_primer_seq", "reverse_primer_seq", txt, fixed = TRUE)
  fixed_filter_primer_hits <- eval(parse(text = txt))
  environment(fixed_filter_primer_hits) <- asNamespace("rCRUX")
  assignInNamespace("filter_primer_hits", fixed_filter_primer_hits, ns = "rCRUX")
  
  # Prueba 4. Corrección 4 (argumentos nombrados)
  # Error al guardar: no se puede abrir la conexión (la carpeta de salida no existe)
  get_seeds_remote(forward_primer_seq      = forward_primer_seq,
                   reverse_primer_seq      = reverse_primer_seq,
                   output_directory_path   = output_directory_path,
                   metabarcode_name        = metabarcode_name,
                   accession_taxa_sql_path = accession_taxa_sql_path,
                   organism = c("1476529", "7776"),
                   return_table = FALSE)
  
  # Prueba 5. Corrección 5: crear la carpeta antes
  # Guarda 3 archivos, pero pierde el grupo 7776:
  # "parse_primer_hits returned an object that is not a dataframe"
  dir.create(output_directory_path, recursive = TRUE, showWarnings = FALSE)
  get_seeds_remote(forward_primer_seq      = forward_primer_seq,
                   reverse_primer_seq      = reverse_primer_seq,
                   output_directory_path   = output_directory_path,
                   metabarcode_name        = metabarcode_name,
                   accession_taxa_sql_path = accession_taxa_sql_path,
                   organism = c("1476529", "7776"),
                   return_table = FALSE)
  warnings()
  res <- read.csv(file.path(output_directory_path, "get_seeds_local",
                            "12S_V5F1_filtered_get_seeds_remote_output_with_taxonomy.csv"))
  nrow(res)                          # 102
  length(unique(res$species))        # 30
  table(res$class, useNA = "always") # Hyperoartia 101, NA 1
  
  # Prueba 6. Consulta directa a NCBI solo para 7776 (código propio de diagnóstico)
  raw_response_list <- rCRUX:::primer_search(forward  = forward_primer_seq,
                                             reverse  = reverse_primer_seq,
                                             organism = "7776",
                                             primer_specificity_database = "nt")
  r1 <- raw_response_list[[1]]
  html_text <- httr::content(r1, as = "text", encoding = "UTF-8")
  writeLines(html_text, "C:/rcrux/outputs_remote/respuesta_ncbi_7776.html")
  nchar(html_text)                           # 448893
  length(gregexpr("<pre", html_text)[[1]])   # 1000
  p <- rCRUX:::parse_primer_hits(r1)
  nrow(p)                                    # 1000 (tope)
}
