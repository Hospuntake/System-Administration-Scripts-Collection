import subprocess as subp
import sys
import os

def run_command(command):
    p = subp.Popen(command, shell=True, stdout=subp.PIPE, stderr=subp.PIPE)
    retcode = p.wait()
    if retcode != 0:
        raise Exception("Error con el comando.")
    stdout, stderr = p.communicate()
    return stdout.decode('UTF-8').rstrip()

if len(sys.argv) != 3:
    print('Error. python ./class_act.py [num_dias] [Usuario]')
else:
    #Tiene 2 argumentos
    #Asignamos valores
    time = str(sys.argv[1])
    usr = sys.argv[2]
    t_size = 0.0
    cont = 0
    usrname = run_command("cat /etc/passwd | grep '"+ usr + "' | cut -d: -f1")
    
    #Buscamos ficheros
    if usrname != "root":
        for file in run_command("find /home/"+usrname+" -type f -user "+ usrname +" -mtime "+time).splitlines():
            cont = cont+1
            size = run_command("du -bs "+ file +" | cut -f1")
            t_size = t_size + int(size)
    else:
        for file in run_command("find /"+usrname+" -type f -user "+ usrname +" -mtime "+time).splitlines():
            cont = cont+1
            size = run_command("du -bs "+ file +" | cut -f1")
            t_size = t_size + int(size)
    #Tenemos tods los archivos y el tamaño, hay que modificar el tamaño si es necesario
    if t_size > 1000:
        #De B a KB
        t_size = (round(t_size/1000),3)
        if t_size > 1024:
            #De KB a MB
            t_size = (round(t_size/1024),3)
            if t_size > 1024:
                #De MB a GB
                t_size = (round(t_size/1000),3)
                print(usr +" ("+ usrname +") "+ str(cont) +" fitxers modificats que ocupen "+ str(t_size) +" GB")
            else:
                print(usr +" ("+ usrname +") "+ str(cont) +" fitxers modificats que ocupen "+ str(t_size) +" MB")
        else:
            print(usr +" ("+ usrname +") "+ str(cont) +" fitxers modificats que ocupen "+ str(t_size) +" KB")
    else:
        print(usr +" ("+ usrname +") "+ str(cont) +" fitxers modificats que ocupen "+ str(t_size) +" B")
        