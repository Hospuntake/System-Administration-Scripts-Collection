#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: root
"""
import sys
import subprocess as sp
import re
import os
g=0
grupo=0
max_perm=0
usage="Usage: ocupacio.py [Max_permitido] Ej.: 300M, 1G..."
usage_g="Usage: ocupacio.py -g [grupo] [Max_permitido] Ej.: 300M, 1G..."
if len(sys.argv) != 1:
    if len(sys.argv) == 4:
        if sys.argv[1] == "-g":
            print("- Modo grupo activado")
            g=1
            grupo = sys.argv[2]
        else:
            print(usage_g)
            sys.exit(1)
 
    #si modo grupo está activado
    if g==1:
        if re.match(r'\b\d{1,99}[KMG]\b', sys.argv[3]):
            to_bytes = sp.getoutput("numfmt --from=iec {}".format(sys.argv[3]))
            print("- Maximo permitido {} en el grupo '{}'".format(sys.argv[3],grupo))
            max_perm = to_bytes
 
 
        else:
            print(usage_g)
            sys.exit(1)
 
    #si modo grupo NO está activado        
    if g==0:
        if re.match(r'\b\d{1,99}[KMG]\b', sys.argv[1]):
            to_bytes = sp.getoutput("numfmt --from=iec {}".format(sys.argv[1]))
            print("- Maximo permitido {}".format(sys.argv[1]))
            max_perm = to_bytes
 
 
        else:
            print(usage)
            sys.exit(1)
 
 
    #una vez pasado el control de entrada, obtener lo que pide el usuario
    #MODO USUARIO
    line = 1 #it
    end = 0 #centinela
    while (end == 0) and (g == 0):
        #output guarda el tamaño de cada usuario en bytes
        output = sp.getoutput("du -d 1 -b /home | sort -n | head -n{} | tail -n1 | cut -d/ -f1".format(line))
        user = sp.getoutput("du -d 1 -h /home | sort -n | head -n{} | tail -n1 | cut -d/ -f3".format(line))
        size = sp.getoutput("du -d 1 -h /home | sort -n | head -n{} | tail -n1 | cut -d/ -f1".format(line))
 
        print("")
        print(user,"        ",size)
 
        #si es mayor, alertar en su profile
 
        if int(output) > int(max_perm):
            print("- El usuario '{}' ha superado la cuota. Enviando aviso!".format(user))
            os.system("echo 'echo ' >> /home/{}/.profile".format(user))
            os.system("echo 'echo -----------------------------------------------------------' >> /home/{}/.profile".format(user))
            os.system("echo 'echo PRECAUCIÓN: HAS ESCEDIDO LA CUOTA DE DISCO, CUIDADO AMIGO.' >> /home/{}/.profile".format(user))
            os.system("echo 'echo -----------------------------------------------------------' >> /home/{}/.profile".format(user))
            os.system("echo 'echo Para borrar este mensaje, ejecuta 'nano .profile' y borra estas lineas.' >> /home/{}/.profile".format(user))
 
        line = line+1
        check_fin = sp.getoutput("du -d 1 -b /home| sort -n | head -n{} | tail -n1 | cut -d/ -f3".format(line))
        if check_fin == "":
            end = 1
 
    #MODO GRUPO ----- MOSTRAR USUARIOS Y ESCRIBIR EN EL .PROFILE
    grup_total = 0
    while (end == 0) and (g == 1):
        #output guarda el tamaño de cada usuario en bytes
        output = sp.getoutput("du -d 1 -b /home | sort -n | head -n{} | tail -n1 | cut -d/ -f1".format(line))
        user = sp.getoutput("du -d 1 -h /home | sort -n | head -n{} | tail -n1 | cut -d/ -f3".format(line))    
 
        #guardamos el primer grupo (siempre suele ser el grupo personal, es decir, que se llama igual que el user)
        check_group = sp.getoutput("groups {} | cut -d: -f2 | cut -d' ' -f2".format(user))
        it = 2
        #recorremos los grupos a los que pertenece el usuario, si coincide con el parametro, printear
        while check_group != "":
            it = it+1
            check_group = sp.getoutput("groups {} | cut -d: -f2 | cut -d' ' -f{}".format(user,it))
 
            if check_group == grupo:
                grup_total = grup_total + int(output)
                size = sp.getoutput("du -d 1 -h /home | sort -n | head -n{} | tail -n1 | cut -d/ -f1".format(line))            
 
                print("")
                print(user,"        ",size)
 
                #si es mayor, alertar en su .profile
                if int(output) > int(max_perm):
                    print("- El usuario '{}' ha superado la cuota. Enviando aviso!".format(user))
                    os.system("echo 'echo ' >> /home/{}/.profile".format(user))
                    os.system("echo 'echo -----------------------------------------------------------' >> /home/{}/.profile".format(user))
                    os.system("echo 'echo PRECAUCIÓN: HAS ESCEDIDO LA CUOTA DE DISCO, CUIDADO AMIGO.' >> /home/{}/.profile".format(user))
                    os.system("echo 'echo -----------------------------------------------------------' >> /home/{}/.profile".format(user))
                    os.system("echo 'echo Para borrar este mensaje, ejecuta 'nano .profile' y borra estas lineas.' >> /home/{}/.profile".format(user))
 
        line = line+1
        check_fin = sp.getoutput("du -d 1 -b /home| sort -n | head -n{} | tail -n1 | cut -d/ -f3".format(line))
        if check_fin == "":
            end = 1            
 
    #aunque esto este fuera del bucle de -g nunca se ejecutará para el final del bucle de usuarios
    if (g == 1) and (int(max_perm) < int(grup_total)):
        print("- El grupo '{}' supera la cuota. Enviando aviso!".format(grupo))            
 
else:
    print(usage)
    sys.exit(1)