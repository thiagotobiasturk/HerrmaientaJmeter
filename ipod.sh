#!/bin/bash

# Función para imprimir un mensaje de saludo
saludo() {
    echo "Hola, bienvenido a la herramienta  de inspección de archivos .jmx."
}

# Función para obtener la lista de archivos .jmx en la carpeta actual
obtener_archivos() {
    archivos=()
    while IFS= read -r -d '' archivo; do
        archivos+=("$archivo")
    done < <(find . -maxdepth 1 -type f -name "*.jmx" -print0)
}

# Función para preguntar al usuario si desea extraer URLs o TestNames
preguntar_opcion() {
    read -p "¿Desea extraer URLs (U) o TestNames (T)? Ingrese 'U' o 'T': " opcion
    case $opcion in
        [Uu])
            opcion_seleccionada="URLs"
            ;;
        [Tt])
            opcion_seleccionada="TestNames"
            ;;
        *)
            echo "Opción no válida."
            exit 1
            ;;
    esac
    echo "Ha seleccionado extraer: $opcion_seleccionada"
}

# Función para mostrar los archivos .jmx en la carpeta actual con opciones numéricas
mostrar_archivos() {
    obtener_archivos
    echo "Archivos .jmx en la carpeta actual:"
    select archivo in "${archivos[@]}" "Salir"; do
        case $archivo in
            *.jmx)
                echo "Has seleccionado: $archivo"
                if [[ $opcion_seleccionada == "URLs" ]]; then
                    resultado=$(grep -oE 'HTTPSampler\.domain">([^<]+)' "$archivo" | sed 's/HTTPSampler\.domain">//')
                elif [[ $opcion_seleccionada == "TestNames" ]]; then
                    resultado=$(grep -oE '<HTTPSamplerProxy .*testname="[^"]*' "$archivo" | sed 's/.*testname="//')
                fi
                echo "$resultado"
                break
                ;;
            "Salir")
                exit 0
                ;;
            *)
                echo "Opción no válida."
                ;;
        esac
    done
}

# Llamada a las funciones
saludo
preguntar_opcion
mostrar_archivos

# Mensaje de agradecimiento
echo
echo
echo
echo "¡Gracias por utilizar la herramienta de extracción de datos para JMeter!"

