#!/bin/bash
g=0
grupo=0
max_perm="0"
#Patron de input (10G, 1M, 100K....)
input_pattern="^[0-9]{1,99}+[K,M,G]{1}\b"
usage="Usage: ocupacio.sh [Max_permitido] Ej.: 300M, 1G..."
usage_g="Usage: ocupacio.sh -g [grupo] [Max_permitido] Ej.: 300M, 1G..."
#deteccio de opreacions de entrada
if [ $# -ne 0 ]; then
 
    if [ $# -eq 3 ]; then
	    if [ $1 == "-g" ];then
            g=1
            echo "- Modo grupo activado"
            grupo=$2
 
        else
            echo $usage_g; exit 1
        fi
    fi
    #si el -g esta activado
    if [[ $g -eq 1 ]]; then
 
        if [[ $3 =~ $input_pattern ]]; then
            to_bytes=`numfmt --from=iec $3`
            max_perm=$3
            echo "- Maximo permitido $max_perm en el grupo '$grupo'"
            max_perm=$to_bytes
 
        else
            echo $usage_g; exit 1
        fi
    fi
 
    #si el -g no esta activado
    if [[ $g -eq 0 ]]; then
        if [[ $1 =~ $input_pattern ]]; then
            to_bytes=`numfmt --from=iec $1`
	        max_perm=$1
            echo "- Maximo permitido $max_perm"
            max_perm=$to_bytes
 
        else
            echo $usage; exit 1
        fi
    fi
    
    #una vez ha pasado el control de entrada, obtener lo que pide el usuario
    line=1 #iterador
    end=0 #centinela
 
    #MOSTRAR USUARIOS Y ESCRIBIR EN EL .PROFILE
    while [ $end -eq 0 ] && [ $g -eq 0 ]; do
        #echo $line
        #output guarda el tamaño de cada usuario en bytes
        output=`du -d 1 -b /home | sort -n |head -n$line |tail -n1 |cut -d/ -f1`
 
        user=`du -d 1 -h /home | sort -n |head -n$line|tail -n1 |cut -d/ -f3`
        #size guarda el tamaño de cada usuario en formato human readable
        size=`du -d 1 -h /home | sort -n |head -n$line|tail -n1 |cut -d/ -f1`
        echo ""
 
        echo "$user			$size"
 
        #si es mayor, alertar en su .profile
        if [ $output -ge $max_perm ]; then
            echo "- El usuario '$user' ha superado la cuota. Enviando aviso!"
            echo "echo " >> /home/$user/.profile
            echo "echo -----------------------------------------------------------" >> /home/$user/.profile
            echo "echo PRECAUCIÓN: HAS ESCEDIDO LA CUOTA DE DISCO, CUIDADO AMIGO."  >> /home/$user/.profile
            echo "echo -----------------------------------------------------------" >> /home/$user/.profile
            echo "echo Para borrar este mensaje, ejecuta 'nano .profile' y borra estas lineas."  >> /home/$user/.profile
 
        fi
 
        line=$((line+1))
        check_fin=`du -d 1 -b /home| sort -n | head -n$line | tail -n1 | cut -d/ -f3`
        #echo $check_fin
        if [ "$check_fin" = "" ]; then
            end=1
        fi
 
    done

    #MODO GRUPO ------ MOSTRAR USUARIOS Y ESCRIBIR EN EL .PROFILE
    grup_total=0
    while [ $end -eq 0 ] && [ $g -eq 1 ]; do
        #echo $line
        #Tamaño del /home de cada linea
        output=`du -d 1 -b /home | sort -n |head -n$line |tail -n1 |cut -d/ -f1`
        #username de la misma linea
        user=`du -d 1 -h /home | sort -n |head -n$line|tail -n1 |cut -d/ -f3`
 
        #Guardamos el primer grupo (siempre suele ser el grupo personal, es decir que se llama igual que el usuario)
        check_group=`groups $user | cut -d: -f2 | cut -d' ' -f2`
        it=2
        #Recorremos los grupos a los que pertenece el usuario, si coincide con el parametro, printear
        while [ "$check_group" != "" ]; do
            it=$((it+1))
            check_group=`groups $user | cut -d: -f2 | cut -d' ' -f$it`
 
            if [ "$check_group" = "$grupo" ]; then
                #si pertenece a ese grupo, sumamos el total para comprobar despues si supera el max_perm
                grup_total=$((grup_total+output))
                #echo $grup_total
                size=`du -d 1 -h /home | sort -n |head -n$line|tail -n1 |cut -d/ -f1`
                echo ""
 
                echo "$user			$size"
 
                #si es mayor, alertar en su .profile
                if [ $output -ge $max_perm ]; then
                    echo "- El usuario '$user' ha superado la cuota. Enviando aviso!"
                    echo "echo " >> /home/$user/.profile
                    echo "echo -----------------------------------------------------------" >> /home/$user/.profile
                    echo "echo PRECAUCIÓN: HAS ESCEDIDO LA CUOTA DE DISCO, CUIDADO AMIGO."  >> /home/$user/.profile
                    echo "echo -----------------------------------------------------------" >> /home/$user/.profile
                    echo "echo Para borrar este mensaje, ejecuta 'nano .profile' y borra estas lineas."  >> /home/$user/.profile
 
                fi
 
 
 
            fi
 
        done
 
        line=$((line+1))
        check_fin=`du -d 1 -b /home| sort -n | head -n$line | tail -n1 | cut -d/ -f3`
        #echo $check_fin
        if [ "$check_fin" = "" ]; then
            end=1
        fi
 
    done
    #Aunque esto esté fuera del bucle de -g, nunca se ejecutará para el final del bucle de usuarios
    if [ $max_perm -le $grup_total  ]; then
        echo "- El grupo '$grupo' supera la cuota. Enviando aviso!"
 
    fi

else
    echo $usage; exit 1

fi