#!/bin/bash

usage="Usage ./class_act.sh [num_dias] [Usuario]"

#Tiene 2 argumentos
if [ $# -eq 2 ]; then
	#Asignamos los valores
	time=$1
	usr=$2
	t_size=0
	cont=0
	usrname=`cat /etc/passwd | grep "$usr" | cut -d: -f1`

	#Buscamos los ficheros
	if [ $usrname != "root" ];then
		for file in `find /home/$usrname -type f -user $usrname -mtime $time`;do
			cont=$(($cont+1))
			size=`du -bs $file | cut -f1`
			t_size=$(($t_size+$size))
		done
	else
		for file in `find /$usrname -type f -user $usrname -mtime $time`;do
			cont=$(($cont+1))
			size=`du -bs $file | cut -f1`
			t_size=$(($t_size+$size))
		done
	fi
	#Tenemos todos los archivos y el tamaño, hay que modificar el tamaño si es necesario
	if [ ${t_size%.*} -gt 1000 ];then
		#Pasamos de B a KB
		t_size=`echo "scale=3; $t_size/1000" | bc -l`
		if [ ${t_size%.*} -gt 1024 ];then
			#Pasamos de KB a MB
			t_size=`echo "scale=3; $t_size/1024" | bc -l`
			if [ ${t_size%.*} -gt 1024 ];then
				#Pasamos de MB a GB
				t_size=`echo "scale=3; $t_size/1024" | bc -l`
				echo "$usr ($usrname) $cont fitxers modificats que ocupen $t_size GB"
			else
				echo "$usr ($usrname) $cont fitxers modificats que ocupen $t_size MB"
			fi
		else
			echo "$usr ($usrname) $cont fitxers modificats que ocupen $t_size KB"
		fi
	else
		echo "$usr ($usrname) $cont fitxers modificats que ocupen $t_size B"
	fi
else
	echo $usage
fi
