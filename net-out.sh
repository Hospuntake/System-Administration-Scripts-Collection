#!/bin/bash
#Para imputs incorrectos
usage="Usage: net-out"

if [ $# -ne 0 ] && [ $# -ne 1 ]
then
	echo $usage; exit 1
fi
#Tiene un argumento, comprobamos que el input es correcto
if [ $# -eq 1 ]
then
#Mostramos la ruta absoluta del archivo por cada intervalo de tiempo(time)
	time=$1
	watch -n$time $(realpath $0)
fi

num_paq_totals=0

cat /proc/net/dev | tail -n2 | awk '{print $1, $3}'
#Nos vamos a esta ubicacion y leemos enp0s3 y lo para poder imprimirlos
for num_paq_interf in $(cat /proc/net/dev | tail -n2 | awk '{print $3}')
do
	num_paq_totals=$(echo "$num_paq_totals+$num_paq_interf" | bc -l )
done
#Sumamos los paquetes totales que aparecen en el archivo dev para poder
#imprimirlos
echo "Total: $num_paq_totals"
#Los imprimimos
