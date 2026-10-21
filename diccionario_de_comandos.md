### Comandos

Esta lista está pensada para llevar un listado de los comandos que se ponen en práctica en este flujo de trabajo.

El siguiente sitio [powershell](https://explainshell.com/) arroja una explicación rápida de cada parte de un comando. ¡Pruebalo con el siguiente!:

```text
grep -i "pattern" file.txt
```

Comandos:

`scp` (secure copy): copia archivos de forma encriptada.

`cd` (change directory): permite entrar o salir de carpetas.

`cd ..`: regresa una carpeta atras.

`ls ` (list): muestra que archivos hay dentro de la carpeta donde estás situado.

`ls -lh`  `-l` ,(long), da detalles y, `-h` (human-readable) muestra el peso de los archivos en formato legible (KB, MB,GB).

`~` (Home Directory): es un atajo para la ruta de tu usuario principal (ejemplo:*/home/alumno/*)

`mkdir` (make directory): funciona para crear directorios y con el parámetro `-p` (parents) se crea directorios intermedios si no existen.

`set - e`: si ocurre cualquier error, el script se detiene inmediatamente

`set -u`: si usas una variable que no existe, el script falla

#### NUEVA VERSION CON COMANDOS QUE HE UTILIZADO ###
# Comandos básicos de R

Este documento es para quien nunca ha usado R o lo ha usado poco. La documentación de cada paso del pipeline explica **qué** se hace y **por qué**; aquí se explica **cómo leer y correr el código de R** que aparece en los scripts.

Los ejemplos salen de los scripts del pipeline, sobre todo de `scripts/02_pcr_in_silico.R` (Paso 6, PCR *in silico*). Las rutas son las de este proyecto (`C:/rcrux/...`); si las tuyas son distintas, cámbialas.

**Contenido**

1. [RStudio: abrir y correr un script](#1-rstudio-abrir-y-correr-un-script)
2. [Sesión de R y paquetes](#2-sesión-de-r-y-paquetes)
3. [Carpetas y archivos](#3-carpetas-y-archivos)
4. [Objetos, vectores y listas](#4-objetos-vectores-y-listas)
5. [Tablas: leer, ver y seleccionar](#5-tablas-leer-ver-y-seleccionar)
6. [Comparaciones y condiciones](#6-comparaciones-y-condiciones)
7. [Limpiar y transformar](#7-limpiar-y-transformar)
8. [Contar, unir, ordenar y resumir](#8-contar-unir-ordenar-y-resumir)
9. [Guardar tablas](#9-guardar-tablas)
10. [Buscar una especie en los resultados](#10-buscar-una-especie-en-los-resultados)
11. [Gráficas con R base](#11-gráficas-con-r-base)
12. [Gráficas con ggplot2](#12-gráficas-con-ggplot2)
13. [Diagramas de Venn con ggvenn](#13-diagramas-de-venn-con-ggvenn)
14. [Errores comunes](#14-errores-comunes)
15. [Comandos de terminal (no son de R)](#15-comandos-de-terminal-no-son-de-r)

---

## 1. RStudio: abrir y correr un script

### Los cuatro paneles

| Panel | Dónde está | Para qué sirve |
|---|---|---|
| Editor | arriba a la izquierda | Aquí se ve el script. Lo que escribas aquí no se ejecuta hasta que lo mandes a la consola |
| Consola | abajo a la izquierda | Aquí R ejecuta los comandos y muestra los resultados y los mensajes |
| Environment | arriba a la derecha | Lista los objetos que has creado (por ejemplo, las tablas que lees) |
| Files / Plots / Help | abajo a la derecha | Muestra carpetas, gráficas y la ayuda de las funciones |

### Abrir y correr un script

1. En el menú, elige *File → Open File…* y busca el script (por ejemplo, `scripts/02_pcr_in_silico.R`).
2. Corre el script **por partes, en orden, de arriba hacia abajo**.
3. Para correr un comando, pon el cursor en la línea y presiona **Ctrl + Enter** (en Mac, **Cmd + Enter**). RStudio lo manda a la consola y baja el cursor al siguiente.
4. Si un comando ocupa varias líneas (por ejemplo, `get_seeds_local(…)` con sus argumentos), es **un solo comando**: basta con tener el cursor en cualquiera de sus líneas y RStudio manda el comando completo.
5. Para correr varios comandos juntos, selecciónalos con el ratón y presiona Ctrl + Enter.
6. Espera a que aparezca `>` en la consola antes de correr el siguiente comando.

### Cómo leer el código

- Lo que va después de `#` es un **comentario**: una nota para quien lee, que R no ejecuta.
- `nombre <- valor` guarda un **objeto**: un valor con nombre, que después se usa escribiendo ese nombre. Por ejemplo, `blast_db_path <- "C:/rcrux/blast_db/mito"` guarda esa ruta con el nombre `blast_db_path`.
- `funcion(argumento = valor)` ejecuta una **función** (una orden) con sus **argumentos** (las opciones). Por ejemplo, `dir.create("C:/rcrux/outputs_pcr_insilico")` ejecuta `dir.create()`, que crea una carpeta.
- Escribir los argumentos con su nombre (`metabarcode_name = "12SV5"`) hace que el resultado no dependa del orden en que se escriben.
- Las **rutas** de Windows se escriben en R con `/` y no con `\`, y siempre entre comillas.
- R distingue mayúsculas de minúsculas: `Mammalia` no es lo mismo que `mammalia`.
- Si cierras R o reinicias la sesión, los objetos se borran. Al volver, corre otra vez `library(rCRUX)` y las rutas (paso 6.1) y, si vas a usar la vía remota, el bloque de correcciones (paso 6.3 a) antes de seguir.

### Leer la consola

| Lo que ves | Qué significa |
|---|---|
| `>` al inicio de la línea | R terminó y está listo para el siguiente comando |
| `+` al inicio de la línea | R espera que completes el comando (falta cerrar un paréntesis o unas comillas). Presiona **Esc** y vuelve a mandar el comando completo |
| Un cuadro rojo (*stop*) arriba a la derecha de la consola | R sigue trabajando. Espera a que desaparezca |
| Texto que empieza con `Aviso` o `Warning` | Advertencia: el comando sí corrió. Revisa la nota al pie del paso para saber si importa |
| Texto que empieza con `Error` | El comando no corrió. Busca el mensaje en la nota al pie del paso o en la [sección 14](#14-errores-comunes) |

---

## 2. Sesión de R y paquetes

Un **paquete** es un conjunto de funciones que alguien más escribió (por ejemplo, rCRUX o ggplot2). Se **instala** una sola vez y se **carga** cada vez que abres R.

| Código | Qué hace |
|---|---|
| `install.packages("ggplot2")` | Instala un paquete desde CRAN. Se hace **una sola vez** y necesita internet |
| `library(rCRUX)` | Carga un paquete para usar sus funciones. Hay que correrla **cada vez que abres R**. Puede no mostrar nada, o solo avisos de paquetes compilados con otra versión de R |
| `taxonomizr::read.nodes.sql` | `paquete::función` usa una función de un paquete sin cargarlo con `library()`, y deja claro de qué paquete viene |
| `installed.packages()[, c("Package", "Version")]` | Lista los paquetes instalados con su versión |
| `.libPaths()` | Muestra en qué carpetas del disco R busca y guarda los paquetes. Los nuevos se instalan en la primera |
| `?taxonomizr::read.accession2taxid` | Abre la ayuda oficial de la función en el panel *Help*: qué hace, sus argumentos y ejemplos |
| `args(taxonomizr::read.nodes.sql)` | Muestra en la consola los argumentos de la función, con su nombre exacto y su valor por defecto |
| `.rs.restartR()` | Reinicia la sesión de R (solo funciona dentro de RStudio). Es lo mismo que *Session → Restart R* en el menú, o **Ctrl + Shift + F10**. Borra los objetos y descarga los paquetes |

**Revisar los argumentos antes de correr.** Si una función da un error que menciona un argumento que no existe (`unused argument`), es que el nombre está mal escrito o no es el que usa la función. Revísalo con `args()` o `?` antes de volver a correrla:

```r
?taxonomizr::read.accession2taxid
args(taxonomizr::read.nodes.sql)
```

---

## 3. Carpetas y archivos

| Código | Qué hace |
|---|---|
| `getwd()` | Muestra la carpeta de trabajo, por ejemplo `"C:/rcrux"`. Una ruta incompleta (sin `C:/…`) se busca a partir de ahí. Los scripts del pipeline usan rutas completas, así que no dependen de ella |
| `dir.create("ruta")` | Crea una carpeta. No muestra nada si la creó; si ya existía, muestra el aviso `already exists`, que no es un problema. Sin `recursive = TRUE`, solo crea un nivel: la carpeta que la contiene ya debe existir |
| `dir.exists("ruta")` | `TRUE` si la carpeta existe, `FALSE` si no |
| `file.path("a", "b", "c")` | Une partes de una ruta con `/`. `file.path("C:/rcrux/outputs_pcr_insilico", "01_rcrux")` da `"C:/rcrux/outputs_pcr_insilico/01_rcrux"` |
| `file.rename(from = "origen", to = "destino")` | Mueve o renombra un archivo o una carpeta. Devuelve `TRUE` si funcionó |
| `unlink("ruta", recursive = TRUE)` | Borra una carpeta con todo lo que tiene dentro. **No pasa por la papelera: no se puede deshacer** |

Ejemplo: mover un archivo y borrar una carpeta que ya no se necesita, comprobando antes y después.

```r
file.rename(from = "C:/rcrux/especies_sitio.csv",
            to   = "C:/rcrux/datos/especies_sitio.csv")

dir.exists("C:/rcrux/outputs_pcr_insilico/01_rcrux/MiMammal_local")   # TRUE
unlink("C:/rcrux/outputs_pcr_insilico/01_rcrux/MiMammal_local", recursive = TRUE)
dir.exists("C:/rcrux/outputs_pcr_insilico/01_rcrux/MiMammal_local")   # debería devolver FALSE
```

> No hace falta borrar la carpeta de una corrida para repetirla: si ya existe, rCRUX vuelve a correr desde el principio y sobrescribe los archivos.

---

## 4. Objetos, vectores y listas

| Código | Qué hace |
|---|---|
| `objeto <- valor` | Guarda un valor en un objeto, para no escribirlo completo cada vez |
| `nombre_del_objeto` | Escribir solo el nombre de un objeto lo muestra en la consola (por ejemplo, `conteos` en 6.4) |
| `c(a, b, c)` | Junta varios valores en un **vector** (una fila de valores del mismo tipo). Ejemplo: `c("12SV5 local", "12SV5 remota")` |
| `1:3` | Los números del 1 al 3: `1, 2, 3` |
| `rep(x, 4)` / `rep(x, each = 2)` | Repite `x` completo 4 veces / repite cada elemento de `x` 2 veces seguidas |
| `list("12SV5" = a, "MiMammal" = b)` | Junta objetos en una **lista** con nombre. A diferencia de un vector, cada elemento puede tener distinto largo (en 6.7, una lista de especies por set) |
| `length(x)` | Cuenta cuántos elementos hay |
| `warnings()` | Muestra los avisos que dejó el último comando (se usa después de `get_seeds_remote()` en 6.3) |

Los nombres que empiezan con número, como `12SV5`, van entre comillas al crear la lista. Al usarlos después como nombre de columna, van entre comillas dentro de `[[ ]]` (`tab_esp[["12SV5"]]`) o entre acentos graves (`` `12SV5` ``).

---

## 5. Tablas: leer, ver y seleccionar

Una tabla en R se llama *data frame*: filas y columnas, como en Excel.

| Código | Qué hace |
|---|---|
| `read.csv("ruta.csv")` | Lee un archivo `.csv` y lo guarda como tabla. Con tablas grandes (más de 100,000 filas) puede tardar unos segundos |
| `read.csv("ruta.csv", fileEncoding = "UTF-8-BOM")` | Para `.csv` guardados desde Excel, que agrega una marca invisible al inicio del archivo (6.8.1) |
| `tabla$columna` | El `$` toma una columna de la tabla |
| `tabla[["12SV5"]]` | Igual que `$`, pero funciona con nombres que empiezan con número |
| `tabla[, c("order", "family", "species")]` | Toma solo esas columnas. Lo que va antes de la coma son las filas; vacío significa «todas» |
| `tabla[, 1:3]` | Toma las tres primeras columnas |
| `subset(tabla, class == "Mammalia")` | Deja solo las filas que cumplen la condición |
| `names(tabla) <- c(…)` / `colnames(tabla) <- c(…)` | Pone nombre a las columnas, en orden |
| `names(tabla)[1] <- "species"` | Cambia solo el nombre de la primera columna |
| `rownames(tabla) <- c(…)` | Pone nombre a cada fila, en el mismo orden en que están |
| `tabla$nueva <- "texto"` | Agrega una columna con ese valor en todas las filas |
| `nrow(tabla)` | Cuenta las filas |
| `data.frame(a = …, b = …)` | Arma una tabla nueva a partir de vectores del mismo largo (6.8.5) |

Ejemplo (6.5): leer la tabla principal de una corrida y quedarse con los mamíferos.

```r
t12_local <- read.csv("C:/rcrux/outputs_pcr_insilico/01_rcrux/12SV5_local/get_seeds_local/12SV5_filtered_get_seeds_local_output_with_taxonomy.csv")
m12_local <- subset(t12_local, class == "Mammalia")
```

---

## 6. Comparaciones y condiciones

Una comparación da `TRUE` (verdadero) o `FALSE` (falso).

| Código | Qué hace |
|---|---|
| `==` / `!=` | «es igual a» / «es distinto de» |
| `!` | «no»: invierte `TRUE` y `FALSE` |
| `a & b` | `TRUE` solo si `a` y `b` son `TRUE` |
| `x %in% y` | `TRUE` si `x` está en `y` |
| `is.na(x)` / `!is.na(x)` | Indica si un valor está vacío (NA) / si no lo está |
| `ifelse(condición, "sí", "no")` | Para cada fila, da el primer valor si la condición es `TRUE` y el segundo si es `FALSE` |
| `sum(x == valor, na.rm = TRUE)` | Cuenta cuántos elementos son iguales a `valor` (cada `TRUE` cuenta como 1); `na.rm = TRUE` ignora los NA |
| `rowSums(tabla != "No recuperada")` | Compara cada celda y suma los `TRUE` de cada fila: cuántas columnas cumplen la condición (6.8.5) |

**`ifelse()` anidado** (6.7.4). Un `ifelse()` dentro de otro permite elegir entre tres opciones:

```r
tab_esp$grupo <- ifelse(tab_esp[["12SV5"]] & tab_esp[["MiMammal"]], "Ambos sets",
                 ifelse(tab_esp[["12SV5"]], "Solo 12SV5", "Solo MiMammal"))
```

Si la especie está en los dos sets, es «Ambos sets»; si no, se revisa la segunda condición: si está en 12SV5 es «Solo 12SV5» y, si no, «Solo MiMammal».

---

## 7. Limpiar y transformar

| Código | Qué hace |
|---|---|
| `na.omit(x)` | Quita los valores vacíos (NA) |
| `x[is.na(x)] <- "Sin asignar"` | Reemplaza los valores vacíos por un texto |
| `unique(x)` | Deja cada valor (o cada fila, si es una tabla) una sola vez |
| `trimws(x)` | Quita los espacios sobrantes al inicio y al final de un texto |
| `sub(" .*", "", x)` | Borra desde el primer espacio hasta el final: deja la primera palabra. En un nombre científico, el género (`"Canis latrans"` → `"Canis"`) |
| `paste0(a, " (", b, ")")` | Une textos sin espacio entre ellos: `"Canis latrans (Coyote)"` |
| `as.character(x)` | Convierte a texto |
| `as.data.frame(x)` | Convierte un resultado (por ejemplo, un `table()`) en tabla |

En `sub(" .*", "", x)`, el primer texto es un **patrón**: `" "` es un espacio, `.` es cualquier letra y `*` significa «repetido las veces que sea».

Ejemplo (6.5): contar las especies de mamíferos sin contar el NA.

```r
length(unique(na.omit(m12_local$species)))   # 1,452
```

Se lee de adentro hacia afuera: toma la columna `species`, quita los NA, deja cada nombre una vez y cuenta cuántos quedan.

---

## 8. Contar, unir, ordenar y resumir

| Código | Qué hace |
|---|---|
| `table(x, useNA = "ifany")` | Cuenta cuántas veces aparece cada valor. Los vacíos se cuentan aparte como NA |
| `table(x, y)` | Tabla cruzada: cuántas filas hay de cada combinación de `x` y `y` (6.7.4) |
| `intersect(a, b)` | Valores que están en las dos listas |
| `setdiff(a, b)` | Valores de `a` que no están en `b` |
| `rbind(a, b, …)` | Pone tablas (o vectores) una debajo de otra; deben tener las mismas columnas. Con nombres (`rbind(Total = …, Mamíferos = …)`) nombra cada fila |
| `cbind(a, b)` | Pone columnas una al lado de otra |
| `merge(a, b, by = "species", all.x = TRUE)` | Une dos tablas por una columna en común. `all.x = TRUE` conserva todas las filas de `a`, aunque no tengan pareja en `b` (quedan con NA) |
| `order(x)` | Da el orden de las filas según `x`. Se usa dentro de `[ ]`: `tabla[order(tabla$Via), ]` |
| `aggregate(y ~ grupo, data = tabla, FUN = any)` | Resume `y` por grupo con la función `FUN`. Con `any`, da `TRUE` si al menos una fila del grupo es `TRUE` |
| `factor(x, levels = c(…))` | Fija el orden de las categorías (se usa para ordenar filas y leyendas en las gráficas) |

Ejemplo (6.8.3): por vía y género, ¿cada set recupera al menos una especie?

```r
generos <- aggregate(cbind(`12SV5`, MiMammal) ~ Via + genero, data = tab_esp, FUN = any)
```

A la izquierda de `~` van las columnas que se resumen y a la derecha las que forman los grupos.

---

## 9. Guardar tablas

| Código | Qué hace |
|---|---|
| `write.csv(tabla, "ruta.csv", row.names = FALSE)` | Guarda la tabla en un `.csv`. `row.names = FALSE` evita agregar una columna con números de fila. No muestra nada en la consola |

Los `.csv` se pueden abrir en Excel.

---

## 10. Buscar una especie en los resultados

Usa las tablas completas de 6.5 (`t12_local`, `t12_remota`, `tmm_local`, `tmm_remota`): tienen todas las accesiones de cada corrida y todas las clases. Hay que correr 6.5 antes.

**1. ¿Está la especie exacta en cada tabla?** (`TRUE` o `FALSE`)

```r
especie <- "Nasua narica"

especie %in% t12_local$species    # 12SV5, local
especie %in% t12_remota$species   # 12SV5, remota
especie %in% tmm_local$species    # MiMammal, local
especie %in% tmm_remota$species   # MiMammal, remota
```

**2. ¿Con cuántas accesiones aparece?** Cada fila es una accesión.

```r
sum(t12_remota$species == especie, na.rm = TRUE)
sum(tmm_remota$species == especie, na.rm = TRUE)
```

**3. Si no aparece, ¿qué nombres hay de ese género?**

```r
grep("^Canis ", unique(t12_local$species), value = TRUE)
```

**4. Para mamíferos: en qué vía y en qué grupo del Venn cae** (usa `tab_esp` de 6.7)

```r
subset(tab_esp, species == "Oryctolagus cuniculus")[, c("Via", "grupo")]
```

| Código | Qué hace |
|---|---|
| `grep("patrón", x, value = TRUE)` | Devuelve los elementos de `x` que contienen el patrón |
| `"^Canis "` | `^` = «que empiece con»; el espacio final evita coincidir con otros géneros que empiezan igual |

Notas:

- El nombre tiene que ser exacto: mayúscula solo en el género y sin espacios de más. Si hay duda, empieza por la opción 3.
- La columna `species` de rCRUX tiene nombres de dos palabras (nivel de especie): un nombre de tres palabras (subespecie, por ejemplo *Canis lupus familiaris*) nunca coincide.
- «No está en la tabla» no significa «no existe en NCBI»: solo que esa corrida no la recuperó con ese set de primers.

---

## 11. Gráficas con R base

| Código | Qué hace |
|---|---|
| `png("ruta.png", width, height, res)` | Abre un archivo de imagen; lo que se dibuje después se guarda ahí y no aparece en RStudio |
| `barplot(datos, beside = TRUE, …)` | Dibuja barras lado a lado. `col` da los colores, `ylim` el alto del eje, `ylab` su título, `las = 1` pone horizontales los números del eje y `legend.text = TRUE` agrega la leyenda |
| `"12SV5\nlocal"` | `\n` parte un texto en dos renglones (aquí, debajo de las barras) |
| `text(…)` | Escribe un texto (aquí, el número encima de cada barra) |
| `max(datos)` | El valor más alto; `max(datos) * 1.15` deja 15 % de espacio arriba de la barra más alta |
| `dev.off()` | Cierra y guarda la imagen. Muestra `null device 1`. Si no se corre, el archivo queda vacío |

---

## 12. Gráficas con ggplot2

Una gráfica de ggplot2 se arma por capas, unidas con `+`. Se instala con `install.packages("ggplot2")` y se carga con `library(ggplot2)`.

| Código | Qué hace |
|---|---|
| `ggplot(tabla, aes(x = …, y = …, fill = …))` | Inicia la gráfica y dice qué columna va en cada eje y cuál da el color |
| `reorder(Clase, Especies)` | Ordena las categorías según otra columna |
| `geom_col()` | Dibuja barras |
| `geom_text(aes(label = …))` | Escribe un número junto a cada barra |
| `geom_tile()` | Dibuja una cuadrícula de celdas de color, una por fila de la tabla (6.8.5) |
| `coord_flip()` | Pone las barras horizontales, para que se lean los nombres |
| `facet_wrap(~ Via, scales = "free_x")` | Separa la gráfica en paneles, uno por valor de la columna; `free_x` da a cada panel su propia escala |
| `scale_y_continuous(expand = expansion(mult = c(0, 0.25)))` | Deja 25 % de espacio extra al final del eje para que quepan los números |
| `scale_fill_manual(values = colores, drop = FALSE)` | Fija el color de cada categoría. `drop = FALSE` muestra en la leyenda también las categorías sin casos |
| `labs()`, `ggtitle()` | Título y nombres de los ejes |
| `theme_minimal()` | Estilo con fondo limpio |
| `theme(plot.title = element_text(hjust = 0.5))` | Ajustes finos; aquí, centra el título |
| `g12` (el objeto de la gráfica) | La muestra en el panel *Plots* de RStudio |
| `ggsave("ruta.png", grafica, width, height, dpi, bg = "white")` | Guarda la gráfica como imagen. `bg = "white"` le pone fondo blanco |

**Fijar el orden con `factor()`.** ggplot2 ordena las categorías alfabéticamente, salvo que se le dé otro orden. En 6.8.5 se fija el orden de la leyenda:

```r
largo$grupo <- factor(largo$grupo, levels = c("Ambos sets", "Solo MiMammal",
                                              "Solo 12SV5", "No recuperada"))
```

---

## 13. Diagramas de Venn con ggvenn

Funciones del paquete [`ggvenn`](https://cran.r-project.org/package=ggvenn), que se usa en 6.7. Se instala una sola vez con `install.packages("ggvenn")`.

| Código | Qué hace |
|---|---|
| `ggvenn(lista, fill_color = c(…), show_percentage = FALSE)` | Dibuja el diagrama a partir de una lista con un grupo de nombres por conjunto. `show_percentage = FALSE` muestra solo números |
| `get_venn_table(grafica)` | Devuelve cuántos nombres hay en cada zona del diagrama. En la columna `name`, `AB` son los compartidos, `A` los del primer elemento de la lista y `B` los del segundo |
| `list_to_data_frame(lista)` | Convierte la lista en una tabla: una fila por nombre y una columna `TRUE`/`FALSE` por conjunto. La primera columna se llama `_key` |

Ejemplo (6.7.1 y 6.7.2):

```r
venn_esp_local <- list("12SV5"    = unique(na.omit(m12_local$species)),
                       "MiMammal" = unique(na.omit(mmm_local$species)))

g_esp_local <- ggvenn(venn_esp_local, fill_color = c("#2E5395", "#4C9F70"),
                      show_percentage = FALSE)
get_venn_table(g_esp_local)[, c("name", "n")]   # AB 1,373 / A 79 / B 92
```

---

## 14. Errores comunes

| Si pasa esto… | Haz lo siguiente |
|---|---|
| La línea empieza con `+` y no pasa nada | Falta cerrar un paréntesis o unas comillas. Presiona **Esc** y vuelve a mandar el comando completo |
| `Error en … : no se pudo encontrar la función "get_seeds_local"` (o cualquier otra) | No se cargó el paquete. Corre `library(…)` (por ejemplo, `library(rCRUX)`) y repite |
| `Error … objeto 'accession_taxa_sql_path' no encontrado` (o cualquier otro) | Cerraste o reiniciaste R y se borraron los objetos, o aún no corres la línea que lo crea. Vuelve a correr las líneas donde se crearon (por ejemplo, las rutas del paso 6.1) |
| `no hay paquete llamado …` al correr `library()` | El paquete no está instalado. Instálalo con `install.packages("…")` |
| `install.packages()` da error | Revisa la conexión a internet e instala de nuevo |
| Error con `unused argument` | El nombre de un argumento está mal escrito o no existe en esa función. Revísalo con `args()` o `?` ([sección 2](#2-sesión-de-r-y-paquetes)) |
| `read.csv()` da `no se puede abrir la conexión` | La ruta o el nombre del archivo están mal. Revisa que existan y que usen `/` |
| La primera columna de un `.csv` de Excel sale con caracteres raros al inicio del nombre | Léelo con `fileEncoding = "UTF-8-BOM"` |

---

## 15. Comandos de terminal (no son de R)

Estos comandos se escriben en una **terminal de Linux**, no en la consola de R. El sitio [explainshell](https://explainshell.com/) explica cada parte de un comando de terminal. Pruébalo con este:

```text
grep -i "pattern" file.txt
```

| Comando | Qué hace |
|---|---|
| `cd carpeta` | (*change directory*) Entra a una carpeta |
| `cd ..` | Regresa una carpeta atrás |
| `~` | Atajo para la carpeta de tu usuario (por ejemplo, `/home/alumno/`) |
| `ls` | (*list*) Muestra qué archivos hay en la carpeta donde estás |
| `ls -lh` | `-l` (*long*) da detalles de cada archivo y `-h` (*human-readable*) muestra el peso en formato legible (KB, MB, GB) |
| `mkdir carpeta` | (*make directory*) Crea una carpeta. Con `-p` (*parents*) crea también las carpetas intermedias que no existan |
| `scp origen destino` | (*secure copy*) Copia archivos entre computadoras de forma encriptada, por ejemplo `scp archivo.csv usuario@servidor:ruta/` |
| `set -e` | En un script de terminal: si ocurre cualquier error, el script se detiene inmediatamente |
| `set -u` | En un script de terminal: si usas una variable que no existe, el script falla |


