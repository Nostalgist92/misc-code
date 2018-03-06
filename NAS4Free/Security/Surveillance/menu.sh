#!/bin/sh
#------------------------------------------------------------------------------#
### ZONEMINDER SUBMENU

zoneminder.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Surveillance Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} ZoneMinder${nc}"
        echo " "
        echo -e "${ca}  a) About Surveillance${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc} |${emp} m) Main Menu"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1')	printf '\033\143'; echo -e "${inf} Installing..${nc}" ; echo " "
					. $scriptPath/Security/Surveillance/ZoneMinder/menu.sh ;;

            'a')	printf '\033\143'; . $scriptPath/Security/Surveillance/about.sh ;;
            'h')	printf '\033\143'; (. $scriptPath/gethelp.sh);;
            'i')	printf '\033\143'; . $scriptPath/Security/Surveillance/moreinfo.sh ;;

            'b') 	printf '\033\143'; return ;;
			'm') 	. $scriptPath/mainmenu.sh ;;

            *)		echo -e "${alt}        Invalid choice, please try again${nc}" ; echo " " ;;
        esac
done
}

zoneminder.submenu
