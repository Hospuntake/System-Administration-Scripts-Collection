import sys
import subprocess

def run(command):
    #creamos una funcion para ejecutar comandos por terminal
	process = subprocess.Popen(command,
							   shell = True,
							   stdout = subprocess.PIPE,
							   stderr = subprocess.PIPE)
							   
	if process.wait() == 0:
		return process.communicate()[0].decode('UTF-8').rstrip()
	else:
		return None

def view():
    #Creamos una variable para la suma de todos los paquetes
	num_paq = 0
    
    #Abrimos la ubicacion del archivo a leer y imprimimos la primera y tercera columnas
    # que seran enp0s3 y lo
	print(run("cat /proc/net/dev | tail -n2 | awk '{print $1, $3}'"))

	total = run("cat /proc/net/dev | tail -n2 | awk '{print $3}'").splitlines()
	for num in total:
		num_paq += int(num)
    #Imprimimos la suma total
	print("total: " + str(num_paq))
	
	
n = len(sys.argv)

if n == 1:

	view()

elif n == 2:
	#En base al tiempo indicado se mostraran los resultados
    #por pantalla
	time = sys.argv[1]
	while(True):
		view()
		print("---------------")
		run(f"sleep {time}")

else:

	print("Usage: net-out")
