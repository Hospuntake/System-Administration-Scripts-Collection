#!/bin/bash

# Resum de logins

temps=0

# tots els usuaris que alguna vegada han fet login
users=`last | sed '/reboot/d' | cut -d' ' -f1 | awk 'NF' | sort | uniq | head -n -1`

for user in $users
do
	M=0
	c=0
	last | grep $user | while read -r line ; do
	 	
	 	garb=`echo $line | cut -d' ' -f3`
	 	
		# separem el dia i la hora en variables separades

	 	if [ "$garb" = ":0" ]; then
			loginH=`echo $line | sed '/gone/d' | sed '/still/d' | tr -s ' ' | cut -d' ' -f10 | tr -d '(/)' | cut -d ":" -f1`	
			loginM=`echo $line | sed '/gone/d' | sed '/still/d' | tr -s ' ' | cut -d' ' -f10 | tr -d '(/)' | cut -d ":" -f2`
		else
			loginH=`echo $line | sed '/gone/d' | sed '/still/d' | tr -s ' ' | cut -d' ' -f9 | tr -d '(/)' | cut -d ":" -f1`
			loginM=`echo $line | sed '/gone/d' | sed '/still/d' | tr -s ' ' | cut -d' ' -f9 | tr -d '(/)' | cut -d ":" -f2`
	 	fi
	 	
		# calculem el temps total

	 	if [ ! -z $loginH ]; then

		 	if [[ $loginH =~ "+" ]]; then
				d=`echo $loginH | cut -d "+" -f1`
				h=`echo $loginH | cut -d "+" -f2`
				# M=`expr $M + $d \* 1440 + $h \* 60 + $loginM`
			else
				M=`expr $M + $loginH \* 60 + $loginM`
			fi
	 	
	 	fi

		let c++
		
		echo "Usuari $user: temps total de login: $M min, nombre total de logins: $c" > suport.txt
		
	done
	
	read -r res < suport.txt
	echo $res
	
done

echo ""

for user in $users
do

	CPU=0
	val=0
	c=0
	
	# processos que té actius l'usuari

	ps au | grep $user | while read -r line; do
	
		usuari=`echo $line | tr -s ' ' | cut -d' ' -f1`
	
		if [ $usuari == $user ]; then
			
			num=`echo $line | tr -s ' ' | cut -d' ' -f3`

			# sumem el percentatge d'ús de la CPU
			
			if [[ $num =~ "." ]]; then
				val=`echo $line | tr -s ' ' | cut -d' ' -f3 | cut -d. -f1`
				dec=`echo $line | tr -s ' ' | cut -d' ' -f3 | cut -d. -f2`
				
				if [ $dec -ge 5 ]; then 
					let val++ 
				fi
				
				CPU=`expr $CPU + $val`	
			else
				CPU=`expr $CPU + $num`
			fi
			
			let c++
			
		fi
		
		echo "Usuari $user: $c processos -> $CPU % CPU" > suport.txt

	done
	
	read -r res < suport.txt
	echo $res

done