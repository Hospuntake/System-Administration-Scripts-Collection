#!/bin/bash
#usage por si el input es incorrecto
usage="Tienes que introducir ./info_user.sh [usuario]"
#Comprobamos que el input es correcto
if [ $# -eq 1 ]; then
	#guardamos user en una variable para que sea mas accesible
	user=$1
	#Buscamos home del input usando cat
	home=`cat /etc/passwd | grep "^$user\>" | cut -d: -f6`
	echo "Home:" $home
	#Buscamos cuanto espacio ocupan los directorios usando du
	home_size=`du -hs $home | cut -f1`
	echo "Home size:" $home_size
	echo -e "Other dirs: \c"
	#Usamos un for para ver todos los directorios fuera de home
	for otros_ficheros in `ls /`;do
		#find de files
		cont=`find . -type f -user $user | wc -l`
		if [ "$cont" -gt 0 ];then
			echo -e "/$otros_ficheros \c"
		fi
	done
	#Mostramos el numero de procesos usando ps
	#Usamos --no-headers para descontar la primera linea
	echo -e "\nActive processes: `ps -u $user --no-headers | wc -l`"
#Si el input es incorrecto, lo notifica
else
	echo $usage
fi
