#!/bin/bash



clear
echo -e "\033[1;36m"
cat << "EOF"

 _     _             __  __       
| |   | |           |  \/  |      
| |   | |_   _ _ __ | \  / | ___  
| |   | | | | | '_ \| |\/| |/ _ \ 
| |___| | |_| | | | | |  | |  __/ 
\_____/_|\__, |_| |_|_|  |_|\___| 
          __/ |  Security Recon Tool
         |___/   v1.0

     Nmap • Nikto • SSL/TLS • One Script

EOF
echo -e "\033[0m"
echo -e " \033[1;35mScanning with precision. Watching every byte.\033[0m"

echo  "Choose an option:"
echo  "  1) Nmap Full Scan"
echo  "  2) Nikto Web Scan"
echo  "  3) SSL/TLS Audit"
echo  "  4) Run All Scans"
echo  "  5) Nmap Local Scan(fully automated)"
echo  "  6) bored of tools? play eldenring "
echo  "  7) start cowsay story(Under developmnet)"
# eldenring and cowsay will be combined in one section called games,in future.
echo  "  8) IP full recon(Under development) "
echo  "  9) Exit"


read option

#do loop until user does not input something
if [[ "$option" != "5" && "$option" != "6" && "$option" != "8" ]]; then
    read -p "Target(IP or Domain):" target
	while  [[ "$target" = "" ]] 
	do
        
 		read -p "Target cannot be empty ,enter (IP or Domain):" target
	done
	echo "Target set to: $target"
fi

#filename
NAME="${target}-scan_$(date +%Y%m%d_%H%M%S)"


sleep 1
#fucntions
loading() {

	sleep 1
    echo -n "#" 
    sleep 1
	echo -n "#"
	x=0
        while [[ $x -le 10 ]]
	do
		echo -n "#"
		(( x ++ ))
	done 
	echo "Loaded"
}
scan_result() {
	if [[ $? != 0 ]]; then
		echo "scan failed or results failed to save"
	else
		echo "done succesfully"	
		sleep 1
		echo "scan results saved to  ----> ./scans"		
	fi
}

run_nmap() {
	echo "Starting Nmap full scan"

    loading

	mkdir -p "scans"
	

    nmap   -A -T5 -v --reason --script "vuln,vulners" -oX "scans/${NAME}_nmap.xml" "$target"
    #converting xml to html 
	xsltproc ./"scans/${NAME}_nmap.xml" -o ./"scans/${NAME}_nmap.html"
	
	scan_result
		
}


run_nikto() {
	echo "Starting Nikto"

	loading

	mkdir -p "scans"

	nikto -h "$target" -timeout 15 -maxtime 180 -output "scans/${NAME}_nikto.txt"

    grep -iE "(Apache|nginx|IIS|PHP|OpenSSL)/*" "scans/${NAME}_nikto.txt" 2>/dev/null | \
        sed "s|^|${ip}: |" >> "scans/${NAME}_nikto_SUMMARY.txt" 2>/dev/null

    grep -iE "(OSVDB|CVE|vulnerable|allowed|directory listing|misconfiguration)" "scans/${NAME}_nikto.txt" 2>/dev/null | \
        head -5 | \
        sed "s|^|${ip}: |" >> "scans/${NAME}_nikto_SUMMARY.txt" 2>/dev/null

	scan_result	

}

run_ssl_tls(){
	echo "Starting SSL/TLS audit"

    loading

	mkdir -p "scans"

	testssl --quiet --color 0 --htmlfile "scans/${NAME}_testssl.html" "$target"

	scan_result
	
}

run_all() {
	
	echo "Starting full Combined scanning..."
	run_nmap
	run_nikto
	run_ssl_tls
}



run_nmap_local(){

    subnet=$(hostname -I | awk '{print $1}' | cut -d'.' -f1-3)
	SUB_NAME="${subnet}-scan_$(date +%Y%m%d_%H%M%S)"
	echo "Starting Nmap full local  scan"
     
	loading

	mkdir -p "scans"
	

    nmap   -A -T5 -v --reason -oX "scans/${SUB_NAME}.xml" "$subnet.0/24"
 
	xsltproc ./"scans/${SUB_NAME}.xml" -o ./"scans/${SUB_NAME}.html"

	scan_result
	
}

run_eldenring() {
	
	echo "Welcome Tarnished. Please select your starting class:"
	echo "1 - Samurai"
	echo "2 - Prisoner"
	echo "3 - Prophet"
	echo "Choose a class by typing the corresponding number:"
	read class

	case $class in
		1) type="Samurai"
		hp=10
		attack=15
		
		;;
		2) type="Prisoner"
		hp=15
		attack=20
	
		;;
		3) type="Prophet"
		hp=20
		attack=12
		
		;;
		*) echo "Invalid selection. Exiting game." 
		exit 1
		;;

		
	esac
	
	#first beast battle
 
	while [[ $hp -ge 0 ]]
	do

		read -p "Your first beast approaches.Prepare to battle. Pick a number bettween 0-1. (0/1)" tarnished
		

		beast=$(( $RANDOM % 10 ))
		if [[ $beast == $tarnished ]]; then		
				echo "Beast VANQUISHED!! Congrats fellow tarnished"
				break
		else
				echo "You Died"
				(( hp-- ))
                
		fi
	done	

   
	

	sleep 2


	while [[ $hp -ge 0 ]]
	do
		read -p "Boss battle. Get scared. It's Margit. Pick a number between 0-9. (0-9)" tarnished
		beast=$(( $RANDOM % 10 ))
		if [[ $beast == $tarnished ]]; then		
				echo "Beast VANQUISHED!! Congrats fellow tarnished"
		else
				echo "You Died"
		        (( hp-- ))

		fi
	done	


}

run_cowsay_story(){
		echo "Welcome to cowsay theatre,sit back ,relax and enjoy the show"
}
ip_full_recon() {
	echo "ip full recon starting"

	scan_result
}

exit_fun() {
	echo "exitting...."
	sleep 1
	exit 0
}
case $option in
	1)run_nmap;;
	2)run_nikto;;
	3)run_ssl_tls;;
	4)run_all;;
	5)run_nmap_local;;
	6)run_eldenring;;
	7)run_cowsay_story;;
	8)ip_full_recon;;
	9)exit_fun;;
	
esac






