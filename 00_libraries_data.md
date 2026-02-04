# Que comandos aprendimos:

`scp` (secure copy), copia los archivos de forma encriptada

`cd` (change directory), permite entrar o salir de carpetas

`cd ..` Regresa una carpeta atras

`ls ` (list), muestra que archivos hay dentro de la carpeta donde estás situado.

`ls -lh`  `-l` ,(long), da detalles y, `-h` (human-readable) muestra el peso de los archivos.


# Imporar datos crudos al servidor

Para importar datos debes tener a la mano:
1. Ruta de tu archivo .zip a importar
2. Usuario y contraseña en el servidor
3. IP del servidor

Este paso se realiza desde la terminal de tu PC
``` bash
scp "C:/Users/HP/Documentos/LandaLab/1.datoscrudos.zip" brendadh@123.456.78.91:/home/brendadh/00_datos_crudos/
```
Ingresa al servidor, tu username y contraseña

``` bash
ssh username@landalab
```
Verifica que se han importado 
``` bash
cd ~/00_datos_crudos
ls -lh
```
Se muestra el nombre del archivo `.zip`: 
```text
1.datoscrudos.zip
```
Descomprime el zip
``` bash
unzip 1.datoscrudos.zip
```
Es recomendable utilizar una bitácora dentro de bash, con el siguiente comando:
``` bash
nano bitacora_amplicones_16S.txt
```
Guarda con `Ctrl + O` y sales `Ctrl + X`
Agrega los resultados con el siguiente comando
``` bash
echo "escribe el resultado entre comillas" >> bitacora_amplicones_16S.txt
```
