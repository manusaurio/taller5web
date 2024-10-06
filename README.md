# Artimañas 2023 - Sitio web
**Artimañas** es una muestra de trabajos finales de Taller Multimedial V para la Licencitura en Diseño Multimedial de la Universidad Nacional de La Plata (UNLP). Acá se encuentra el código de sitio web para el año 2023.

## Instrucciones de build
El proyecto está hecho con la versión extendida de [hugo](https://github.com/gohugoio/hugo).

Para generar el sitio y volcarlo en el directorio _public_ sólo se necesita ejecutar `hugo` en la raíz del proyecto. Es importante prestar atención al valor de `baseURL` especificado en [`hugo.yaml`](hugo.yaml) o por el parámetro `--baseURL`:

```sh
hugo --minify --baseURL 'https://minuevositio.com.ar/artimanias/2023/'
```

## Notas
De ser necesario, es posible regenerar los thumbnails de la lista de obras con el script [_generar_thumbnails.sh_](generar_thumbnails.sh). Su única dependencia es [libvips](https://github.com/libvips/libvips).

**Se recomienda también deshacerse posteriormente de archivos no utilizados** que `hugo` no es capaz de detectar y eliminar, los cuales copia a *public*:

```sh
# asumiendo la raíz del proyecto como CWD y la versión de GNU findutils de `find`:
find ./public -type f \( -regex '.*/[0-9]\..*' -o -name '*.txt' -o -name 'encabezado-main.*' -o -name 'encabezado-mini.*' -o -name 'obra-thumbnail.*' \) -delete
```
