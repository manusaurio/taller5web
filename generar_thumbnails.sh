#!/usr/bin/env sh

for cmd in vips vipsthumbnail; do
    &>/dev/null command -v $cmd
    if [ $? -ne 0 ]; then
        >&2 echo "Error: no se encontró el programa $cmd"
        exit 1
    fi
done

PROYECTO_RUTA=$(cd "$(dirname "$0")"; pwd -P) # POSIX-compliant hack para MacOS
OBRAS_RUTA="$PROYECTO_RUTA/content/obra/"
ASSETS_RUTA="$PROYECTO_RUTA/assets/thumbnails/"

FIFO_A=$(mktemp)
FIFO_B=$(mktemp)

cleanup() {
    [ -p "$FIFO_A" ] && rm "$FIFO_A"
    [ -p "$FIFO_B" ] && rm "$FIFO_B"
    exit 0
}

trap cleanup EXIT

rm "$FIFO_A" && mkfifo "$FIFO_A"
rm "$FIFO_B" && mkfifo "$FIFO_B"

if [ -d "$OBRAS_RUTA" ]; then
    find "$OBRAS_RUTA" -mindepth 2 \
        -maxdepth 2 \
        -type f \
        -name 'index.md' > "$FIFO_A" &

    while IFS= read -r OBRA_RUTA; do
        OBRA_RUTA="$(dirname "$OBRA_RUTA")"
        OBRA="$(basename "$OBRA_RUTA")"

        find "$OBRA_RUTA" \
            -maxdepth 1 \
            -type f \
            \( -name 'obra-thumbnail.*' -o -name 'encabezado-main.*' \) > "$FIFO_B" &

        THUMBNAIL=0
        OBRA_IMAGEN_RUTA=

        while IFS= read -r RES; do
            OBRA_IMAGEN_RUTA="$RES"

            case "$(basename "$OBRA_IMAGEN_RUTA")" in
                "obra-thumbnail."*)
                    THUMBNAIL=1
                    break
            esac
        done < "$FIFO_B"

        if [ -n "$OBRA_IMAGEN_RUTA" ]; then
            echo -n Procesando $(basename "$OBRA_IMAGEN_RUTA") de $OBRA...

            {
                if [ ! "$THUMBNAIL" -gt 0 ]; then
                    vipsthumbnail --smartcrop attention --size 224x500 --format .png "$OBRA_IMAGEN_RUTA"
                else
                    cat "$OBRA_IMAGEN_RUTA"
                fi
            } | vips colourspace stdin .png VIPS_INTERPRETATION_GREY16 |
                vips composite2 stdin "$ASSETS_RUTA/obra-card-trama.webp" .png overlay |
                vips composite2 stdin "$ASSETS_RUTA/obra-card-gradiente.png" .png darken |
                vips composite2 "$ASSETS_RUTA/obra-card-base.png" stdin .png VIPS_BLEND_MODE_OVER |
                vips composite2 stdin "$ASSETS_RUTA/obra-card-cubierta.webp" "$OBRA_RUTA/thumb.webp[lossless]" VIPS_BLEND_MODE_OVER

            echo ' Hecho.'
        else
            >&2 echo "La obra «$(basename "$OBRA_RUTA")» existe pero no contiene imágenes para la galería."
        fi

    done < "$FIFO_A"
fi
