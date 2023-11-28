import subprocess

# funció per executar comandes de terminal
def run(command):

	process = subprocess.Popen(command,
							   shell = True,
							   stdout = subprocess.PIPE,
							   stderr = subprocess.PIPE)
							   
	if process.wait() == 0:
		return process.communicate()[0].decode('UTF-8').rstrip()

# tots els usuaris que alguna vegada han fet login
users = run("last | sed '/reboot/d' | cut -d' ' -f1 | awk 'NF' | sort | uniq | head -n -1").splitlines()

for user in users:

	line = run(f"last | grep {user}").splitlines()

	c = 0	
	minuts=0
	
	for res in line:
		temps = run('echo "' + res + '"' + "| sed '/gone/d' | sed '/still/d' | cut -d '(' -f2 | cut -d ')' -f1")
		
		# separem el dia i la hora en variables separades
		# calculem el temps total

		if "+" not in temps and len(temps) > 0:
			
			h = temps.split(':')[0]
			m = temps.split(':')[1]
			
			minuts = minuts + int(h) * 60 + int(m)

		c = c + 1
			
	print(f"Usuari {user}: temps total de login: {minuts} min, nombre total de logins: {c}")
	

for user in users:

	# processos que té actius l'usuari
	line = run(f"ps au | grep {user}").splitlines()
	
	c = 0
	CPU = 0
	
	for res in line:
		
		usuari = run('echo "' + res + '"' + "| tr -s ' ' | cut -d' ' -f1")
	
		# sumem el percentatge d'ús de la CPU

		if user == usuari:
		
			CPU = CPU + float(run(f"echo {res} | tr -s ' ' | cut -d' ' -f3"))
			c = c + 1
			
	print(f"Usuari {user}: {c} processos -> {CPU} % CPU")





