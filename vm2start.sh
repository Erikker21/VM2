#Uitrollen van testomgeving via vagrant en ansible
vagrantuitroltest () {
	cd /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving
	vagrant up
	ansible-playbook Host.yaml
	}

#Uitrollen van productieomgeving via vagrant en ansible
vagrantuitrolproductie () {
	cd /home/student/VM2/Klanten/"$_Klantnaam"
	vagrant up
	ansible-playbook Host.yaml
	}

Klantidcounter () {
	TEMPFILE=/home/student/VM2/Overige/counter
	COUNTER=$[$(cat $TEMPFILE) + 1]
 	echo $COUNTER > $TEMPFILE
}

files () {
	sed -i "s+klantnaam+$_Klantnaam+g" Vagrantfile
	sed -i "s+KLANTID+$COUNTER+g" Vagrantfile
	sed -i "s+klantnaam+$_Klantnaam+g" Vagrantfile
	sed -i "s+AANTALWEBSERVERS+$_Webservers+g" Vagrantfile
	sed -i "s+RAMSERVERS+$_Ramhoeveelheid+g" Vagrantfile
	sed -i "s+KLANTID+$COUNTER+g" inventory.ini
}

deleteroles () {
	rm -r roles
	rm Host.yaml
}

copyrolesp () {
	cp -r /home/student/VM2/Playbooks/roles /home/student/VM2/Klanten/"$_Klantnaam"/roles
	cp -r /home/student/VM2/Playbooks/Host_p.yaml /home/student/VM2/Klanten/"$_Klantnaam"/Host.yaml

}

copyrolest () {
	cp -r /home/student/VM2/Playbooks/roles /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/roles
	cp -r /home/student/VM2/Playbooks/Host_t.yaml /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/Host.yaml

}

#OMGEVING AANMAKEN FUNCTIE
omgevingaanmaken () {
	cd /home/student/VM2/Klanten
	mkdir -p "$_Klantnaam"
	cd "$_Klantnaam"

	Klantidcounter

	while true; do
		read -p "Wenst u een productie (p) of een testomgeving (t), beantwoord met p of t: " _TypeOmgeving
		read -p "Hoeveel webservers wenst u te installeren: " _Webservers
		read -p "Hoeveel RAM wenst u per server toe te voegen: " _Ramhoeveelheid

		if [ "$_TypeOmgeving" == "p" ]; then
			echo "U wenst een productieomgeving"
			cp /home/student/VM2/Overige/Vagrantfile_p /home/student/VM2/Klanten/"$_Klantnaam"/Vagrantfile
			cp /home/student/VM2/Overige/inventory_p.ini /home/student/VM2/Klanten/"$_Klantnaam"/inventory.ini
			cp /home/student/VM2/Overige/ansible.cfg /home/student/VM2/Klanten/"$_Klantnaam"/ansible.cfg
			copyrolesp
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/roles/Webserver/templates/index.php.j2
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/roles/lb/defaults/main.yml
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/roles/db/tasks/database-instellen.yml
			files
			vagrantuitrolproductie
			deleteroles

		elif [ "$_TypeOmgeving" == "t" ]; then
			echo "U wenst een testomgeving"
			mkdir -p "testomgeving"
			cp /home/student/VM2/Overige/Vagrantfile_t /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/Vagrantfile
			cp /home/student/VM2/Overige/inventory_t.ini /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/inventory.ini
			cp /home/student/VM2/Overige/ansible.cfg /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/ansible.cfg
			copyrolest
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/roles/Webserver/templates/index.php.j2
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/roles/lb/defaults/main.yml
			sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving/roles/db/tasks/database-instellen.yml
			cd "testomgeving"
			files
			vagrantuitroltest
			deleteroles
		else
			echo "Foutieve invoer, vul p of t in.."
			continue
		fi
		break
	done

}

#OMGEVING AANPASSEN FUNCTIE
omgevingaanpassen () {

	echo "Omgeving aanpassen"
	cd /home/student/VM2/Klanten/"$_Klantnaam"


	RamTestomgeving () {
		read -p "Hoeveel RAM wenst u per server te geven: " _Ramhoeveelheid
		cd "testomgeving"
		sed -i "s+512+$_Ramhoeveelheid+g" Vagrantfile
		sed -i "s+1024+$_Ramhoeveelheid+g" Vagrantfile
		sed -i "s+2048+$_Ramhoeveelheid+g" Vagrantfile
		vagrant reload
	}
	RamProductieomgeving () {
		read -p "Hoeveel RAM wenst u per server te geven: " _Ramhoeveelheid
		sed -i "s+512+$_Ramhoeveelheid+g" Vagrantfile
		sed -i "s+1024+$_Ramhoeveelheid+g" Vagrantfile
		sed -i "s+2048+$_Ramhoeveelheid+g" Vagrantfile
		vagrant reload

	}
	WebTestomgeving () {
		read -p "Hoeveel webservers wenst u te installeren: " _Webservers
		cd "testomgeving"
		sed -i "s+AANTALWEBSERVERS+$_Webservers+g" Vagrantfile
		vagrant reload
	}
	WebProductieomgeving () {
		read -p "Hoeveel webservers wenst u te installeren: " _Webservers
		sed -i "s+AANTALWEBSERVERS+$_Webservers+g" Vagrantfile
		vagrant reload

	}

	extraproductieomgeving () {
		Klantidcounter
		echo "Extra productie omgeving aanvraag"
		read -p "Hoeveel webservers wenst u te installeren: " _Webservers
		read -p "Hoeveel RAM wenst u per server toe te voegen: " _Ramhoeveelheid
		mkdir -p "productieomgeving2"
		cd "productieomgeving2"
		cp /home/student/VM2/Overige/Vagrantfile_p /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/Vagrantfile
		cp /home/student/VM2/Overige/inventory_p.ini /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/inventory.ini
		cp /home/student/VM2/Overige/ansible.cfg /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/ansible.cfg
		cp -r /home/student/VM2/Playbooks/roles /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/roles
		cp -r /home/student/VM2/Playbooks/Host_p.yaml /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/Host.yaml
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/roles/Webserver/templates/index.php.j2
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/roles/lb/defaults/main.yml
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/productieomgeving2/roles/db/tasks/database-instellen.yml
		sed -i "s+01+02+g" Vagrantfile
		files
		vagrant up
		ansible-playbook Host.yaml
		deleteroles
	}

	extratestomgeving () {
		Klantidcounter
		echo "Extra test omgeving aanvraag"
		read -p "Hoeveel webservers wenst u te installeren: " _Webservers
		read -p "Hoeveel RAM wenst u per server toe te voegen: " _Ramhoeveelheid
		mkdir -p "testomgeving2"
		cd "testomgeving2"
		cp /home/student/VM2/Overige/Vagrantfile_t /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/Vagrantfile
		cp /home/student/VM2/Overige/inventory_t.ini /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/inventory.ini
		cp /home/student/VM2/Overige/ansible.cfg /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/ansible.cfg
		cp -r /home/student/VM2/Playbooks/roles /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/roles
		cp -r /home/student/VM2/Playbooks/Host_t.yaml /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/Host.yaml
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/roles/Webserver/templates/index.php.j2
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/roles/lb/defaults/main.yml
		sed -i "s+KLANTID+$COUNTER+g" /home/student/VM2/Klanten/"$_Klantnaam"/testomgeving2/roles/db/tasks/database-instellen.yml
		sed -i "s+01+02+g" Vagrantfile
		files
		vagrant up
		ansible-playbook Host.yaml
		deleteroles
	}

	printf "Kies een optie uit de onderstaande lijst \n"
	printf "1): RAM Testomgeving aanpassen \n"
	printf "2): RAM Productieomgeving aanpassen \n"
	printf "3): Aantal webservers Testomgeving aanpassen \n"
	printf "4): Aantal webservers Productieomgeving aanpassen \n"
	printf "5): Extra testomgeving aanvragen \n"
	printf "6): Extra productieomgeving aanvragen \n"
	read -p "Vul uw optie in: " _Optie

	while true; do
		if [ "$_Optie" = 1 ]; then
			RamTestomgeving
		elif [ "$_Optie" = 2 ]; then
			RamProductieomgeving
		elif [ "$_Optie" = 3 ]; then
			WebTestomgeving
		elif [ "$_Optie" = 4 ]; then
			WebProductieomgeving
		elif [ "$_Optie" = 5 ]; then
			extratestomgeving
		elif [ "$_Optie" = 6 ]; then
			extraproductieomgeving
		else
			echo "Foutieve invoer, vul p of t in.."
			continue
		fi
		break
	done
}

#OMGEVING VERWIJDEREN FUNCTIE
omgevingverwijderen () {
	echo "Omgeving Verwijderen"
	cd /home/student/VM2/Klanten/"$_Klantnaam"

	while true; do
		read -p "Wenst u een productie (p) of een testomgeving (t) te verwijderen, beantwoord met p of t: " _TypeOmgeving
		if [ "$_TypeOmgeving" == "p" ]; then
			echo "Productieomgeving word verwijderd"
			vagrant destroy -f
			rm Vagrantfile
			rm ansible.cfg
			rm inventory.ini

		elif [ "$_TypeOmgeving" == "t" ]; then
			echo "Testomgeving word verwijderd"
			cd "testomgeving"
			vagrant destroy -f
			rm Vagrantfile
			rm ansible.cfg
			rm inventory.ini

		else
			echo "Foutieve invoer, vul p of t in.."
			continue
		fi
		break
	done

}

printf "Welkom op het VM Selfserviceportaal"
printf "\n"

read -p "Klantnaam: " _Klantnaam
read -p "Wachtwoord: "
echo "Welkom: $_Klantnaam"

printf "Kies een optie uit de onderstaande lijst \n"
printf "1): Omgeving aanvragen \n"
printf "2): Omgeving aanpassen \n"
printf "3): Omgeving verwijderen \n"
read -p "Vul uw optie in: " _Optie

while true; do
	if [ "$_Optie" = 1 ]; then
		omgevingaanmaken
	elif [ "$_Optie" = 2 ]; then
		omgevingaanpassen
	elif [ "$_Optie" = 3 ]; then
		omgevingverwijderen
	else
		echo "Foutieve invoer, vul p of t in.."
		continue
	fi
	break
done