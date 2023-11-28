import os
import sys
import subprocess

def run(command):

	process = subprocess.Popen(command,
							   shell = True,
							   stdout = subprocess.PIPE,
							   stderr = subprocess.PIPE)
							   
	if process.wait() == 0:
		return process.communicate()[0].decode('UTF-8').rstrip()



#MIRAMOS SI  SON DIAS / MESES / AÑOS Y LOS TRANSFORMAMOS A DIAS!
if (len(sys.argv) == 3 and sys.argv[1]=="-t"):
	TempsMax="0"
	tiempo= sys.argv[2]
	if(tiempo[-1] == "d"): 
		TempsMax= int(tiempo[0 : -1])
	if(tiempo[-1] == "m"): 
		TempsMax= int(tiempo[0 : -1]) * 30
	if(tiempo[-1] == "a"): 
		TempsMax= int(tiempo[0 : -1]) * 365

	printed = 0
	TempsMax=str(TempsMax)
	for user in str(run("cat /etc/passwd | cut -d: -f1 ")).splitlines(): #por cada usuario en el sistema : 
		##MIRADO POR TIEMPO -> TE  DICE LA ULTIMA CONEXION
		if(str(run("lastlog -u "+user+" -t "+TempsMax+" | tail -n+2 | wc -m "))=="0"):
			
			#MIRADO POR EJECUCIONES -> TE DICE SI EJECUTA PROCESOS
			if(str(run("ps -u "+user+" | tail -n +2 | wc -m "))=="0"):
			
			  	#TE DICE SI HA CAMBIADO ALGUN ARCHIVO EN LA MAQUINA
				if(str(run("find -user "+user+" -mtime -"+ TempsMax +" | wc -m "))=="0"):
					#SI TODO ESO LO CUMPLE , ENTONCES PRINTEAMOS EL NOMBRE == ESTA INACTIVO
    	
					print(user)

