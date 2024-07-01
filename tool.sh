#!/bin/bash

# Validar que se haya pasado un dominio como argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <dominio>"
  exit 1
fi

dominio=$1

# Ejecutar gau y hakrawler, y combinar los resultados en un solo paso
urls=$(echo $dominio | (./gau  || ./hakrawler) | grep -Ev "\.(jpeg|jpg|png|ico|woff|svg|css|ico|woff|ttf)$")

# Ejecutar waymore y combinar los resultados en un solo paso
waymoreUrls=$(waymore -i $dominio -mode U -url-filename -p 4)

# Juntar ambos outputs, eliminar duplicados y filtrar URLs sensibles
allUrls=$(echo -e "$urls\n$waymoreUrls" | sort -u | uro)

# Lista de patrones para archivos que podrían contener información sensible
patterns=(
    "config\.js"
    "config\.php"
    "config\.json"
    "settings\.js"
    "settings\.php"
     "settings\.json"
    "environment\.js"
    "env\.js"
    "env\.php"
    "\.env"
    "phpinfo\.php"
    "info\.php"
    "php_info\.php"
    "\.env\.local"
    "\.env\.production"
    "\.env\.development"
    "\.env\.test"
    "env\.json"
    "environment\.json"
    "debug\.log"
    "error\.log"
    "access\.log"
    "key\.pem"
    "cert\.pem"
    "certificate\.pem"
)

# Concatenar patrones en una expresión regular
pattern_regex=$(IFS="|"; echo "${patterns[*]}")

# Filtrar URLs con grep utilizando la expresión regular y procesarlas con httpx
echo "$allUrls" | grep -E "$pattern_regex" | sort -u | ./uro | ./httpx -sc -title -mc 200

# Fin del script
echo "Proceso completado."
