#!/bin/bash


if [ $# == 0 ] ;then
	echo "Usage: BadUsers.sh [-p] o BadUsers.sh [-t] [temps+(d|m|a)]"
	exit 1
fi
if [ $# == 1 ] && [ $1 != "-p" ] ;then
	echo "Usage: BadUsers.sh [-p] o BadUsers.sh [-t] [temps+(d|m|a)]"
	exit 1
fi
if [ $# == 2 ] && [ $1 != "-t" ] ;then
	echo "Usage: BadUsers.sh [-p] o BadUsers.sh [-t] [temps+(d|m|a)]"
	exit 1
fi
 
if [ $# == 1 ] && [ $1 == "-p" ] ;then
#First Usage BadUsers.sh [-p]
for user in `cat /etc/passwd | cut -d: -f1`; do
    home=`cat /etc/passwd | grep "^$user\>" | cut -d: -f6`
    if [ -d $home ]; then
        num_fich=`find $home -type f -user $user | wc -m`
    else
        num_fich=0
    fi

    if [ $num_fich -eq 0 ] ; then
        if [ $p -eq 1 ]; then

# afegiu una comanda per detectar si l'usuari te processos en execució, 
# si no te ningú la variable $user_proc ha de ser 0
            user_proc=`ps -u $user --no-headers | wc -m`
            if [ $user_proc -eq 0 ]; then
                echo "$user"
            fi
        else
            echo "$user"
        fi
    fi    
done

fi


MaxTemps=-1
if [ $# -eq 2 ] && [ $1 == "-t" ];then

#MIRAMOS SI  SON DIAS / MESES / AÑOS Y LOS TRANSFORMAMOS A DIAS!
    tiempo=$2  
    if [ ${tiempo: -1 } == "d" ];then
    	MaxTemps=${tiempo%"d"}
    fi
    
    if [ ${tiempo: -1 } == "m" ];then
    	MaxTemps=${tiempo%"m"}
    	MaxTemps=$((MaxTemps * 30))
    fi
    if [ ${tiempo: -1 } == "a" ];then
    	MaxTemps=${tiempo%"a"}
    	MaxTemps=$((MaxTemps * 365))
    fi
    
    if [ $MaxTemps == -1 ];then
		echo "Usage: BadUsers.sh [-p] o BadUsers.sh [-t] [temps+(d|m|a)]"
		exit 1
	fi
    
    
    #AQUI EL SCRIPT
    for user in `cat /etc/passwd | cut -d: -f1`; do #por cada usuario en el sistema :
    
    	if [ `lastlog -u $user -t $MaxTemps | tail -n+2 | wc -m ` -eq 0 ];then  ##MIRADO POR TIEMPO -> TE  DICE LA ULTIMA CONEXION

		
    	
    	
    	if [ `ps -u $user | tail -n +2 | wc -m ` -eq 0 ];then  #MIRADO POR EJECUCIONES -> TE DICE SI EJECUTA PROCESOS

    		
    	
    	
    	if [ `find -user $user -mtime $MaxTemps | wc -m` -eq 0 ];then
    	#TE DICE SI HA CAMBIADO ALGUN ARCHIVO EN LA MAQUINA
    	echo "$user"
 			#SI TODO ESO LO CUMPLE , ENTONCES PRINTEAMOS EL NOMBRE == ESTA INACTIVO
    	
    	fi
    	fi
    	fi
    done
    fi




