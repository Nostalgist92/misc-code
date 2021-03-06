#------------------------------------------------------------------------------#
### Jackett SUBMENU

jackett.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Jackett Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${ca}   1)${ca} Install - Private Trackers (Currently Unavailable)${nc}"
        echo -e "${ca}   1)${ca} Install - Public Trackers (Currently Unavailable)${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Jackett (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc} |${emp} m) Main Menu"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            #'1')	echo -e "${inf} Installing..${nc}" ; echo " "
            #    	. $scriptPath/"Download Tools"/Jackett/install.sh ;;
            #'2') 	echo -e "${inf} Running Update..${nc}" ; echo " "
            #    	. $scriptPath/"Download Tools"/Jackett/update.sh ;;
            #'3') 	echo -e "${inf} Backup..${nc}" ; echo " "
            #    	. $scriptPath/"Download Tools"/Jackett/backup.sh ;;
			
            #'a')	. $scriptPath/"Download Tools"/Jackett/about.sh ;;
            'h')	printf '\033\143'; (. $scriptPath/gethelp.sh);;
            #'i')	. $scriptPath/"Download Tools"/Jackett/moreinfo.sh ;;
			
            'b') 	printf '\033\143'; return ;;
			'm') 	. $scriptPath/mainmenu.sh ;;
					
            *)		echo -e "${alt}        Invalid choice, please try again${nc}" ; echo " " ;;
			
        esac
done
}

jackett.submenu