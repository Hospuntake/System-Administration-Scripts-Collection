import subprocess 
import sys

#Funcion para enviar comandos
def command(cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    retcode = p.wait()
    if retcode != 0:
        raise Exception("Problema executant la comanda: "+cmd)
    stdout, stderr = p.communicate()
    return stdout.decode('UTF-8').rstrip()

#Comprobamos que el input es correcto
if len(sys.argv) > 1:
    user = sys.argv[1]
    
    #Buscamos home del input con cat
    home = command("cat /etc/passwd | grep "+user+" | cut -d: -f6") #grep busca una cadena de texto
    print ("Home: " + home)
    
    #Buscamos cuanto espacio ocupan los directorios usando du
    #En el caso de root
    if (user == "root"):
        home_size = command("du -hs /"+user+" | cut -f1") #du estima el espacio ocupado por un fichero, conj de fich o directorio
    #En cualquier otro caso (/home/)
    else:
        home_size = command("du -hs /home/"+user+" | cut -f1")
    print ("Home size: " + home_size)
    
    #Ficheros fuera de home
    ficheros=""
    #Usamos un for para ver todos los directorios fuera de home
    for otros_ficheros in command("ls /").splitlines():
        cont=command("find . -type f -user "+user+" | wc -l") #find de files 
        if int(cont) != 0:
            ficheros=ficheros+" /"+otros_ficheros
    
    print ("Other dirs:"+ficheros)
    
    #Guardamos el número de procesos usando ps
    num_proc = command("ps -u "+ user +" --no-headers | wc -l") #ps para ver los procesos
                                                                #--no-headers para descontar la primera línea
    print ("Active processes: " + num_proc)

#Si el input es incorrecto, lo notifica
else:
	print ('Tienes que introducir python 3 info_user.sh [usuario]')