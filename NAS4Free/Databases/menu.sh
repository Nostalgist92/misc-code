### DATABASES SUBMENU
#------------------------------------------------------------------------------#

while [ "$choice" != "a,h,i,b,m,q" ]
do
	echo -e "${sep}"
    echo -e "${fin} MySQL/MariaDB + phpMyAdmin${nc}"
	echo -e "${sep}"
	echo -e "${qry} Choose one:${nc}"
	echo " "
	echo -e "${fin}   1)${msg} Install MySQL${nc}"
	echo -e "${fin}   2)${msg} Update MySQL${nc}"
	echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
	echo " "
	echo -e "${inf}  a) About MySQL${nc}"
	echo -e "${ca}  i) More Information (Currently Unavailable)${nc}"
	echo -e "${inf}  h) Get Help${nc}"
	echo " "
	echo -e "${emp}  b) Back${nc} |${emp} m) Main Menu"

	echo -e "${ssep}"
	read -r -p "     Your choice: " choice
	echo -e "${ssep}"
	echo " "

	case $choice in
    	'1')	printf '\033\143'; echo -e "${inf} Please confirm that you wish to install MySQL${nc}" ; echo " "
					. $scriptPath/Databases/MySQL/install.sh ;;
    	'2') 	printf '\033\143'; echo -e "${inf} Running Update..${nc}" ; echo " "
					. $scriptPath/Databases/MySQL/update.sh ;;
    	'3')	printf '\033\143'; echo -e "${inf} Backup..${nc}" ; echo " "
					. $scriptPath/Databases/MySQL/backup.sh ;;

    	'a')	printf '\033\143'; about.mysql ;;
    	'i')	printf '\033\143'; moreinfo.submenu.mysql ;;
    	'h')	printf '\033\143'; (. $scriptPath/gethelp.sh);;

		'b') 	printf '\033\143'; return ;;
		'm') 	. $scriptPath/mainmenu.sh ;;

    	*)		echo -e "${alt}			Invalid choice, please try again${nc}" ; echo " " ;;
esac
done
