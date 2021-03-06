#!/bin/sh
#[ -n "$DEBUG" ] && set -x -o pipefail -e
# AIO Script                    Version: 1.0.32 (May 19, 2017)
# By Ashley Townsend (Nozza)    Copyright: Beerware License
################################################################################
# While using "nano" to edit this script (nano /aioscript.sh),
# Use the up, down, left and right arrow keys to navigate. Once done editing,
# Press "X" while holding "Ctrl", Press "Y" then press "Enter" to save changes
################################################################################
##### START OF CONFIGURATION SECTION #####
#
#   In some instances of this script, the following variables must be defined
#   by the user:
#
#   cloud_server_port:  Used to specify the port OwnCloud will be listening to.
#                       Needed due to some installs of N4F having trouble with
#            the admin webgui showing up, even when browsing to the jail's IP.
#
#
#   cloud_server_ip:    This value is used to specify the ip address Owncloud
#                       will listen to. This is needed to keep the jail from
#            listening on all ip's
#
###! OWNCLOUD / NEXTCLOUD INSTALLER CONFIG ! IMPORTANT ! DO NOT IGNORE ! #######

cloud_server_port="81"
cloud_server_ip="192.168.1.200"
cloud_database_name="nextcloud" # Only needed for nextcloud, owncloud can ignore
owncloud_version="9.0.0"        # The version of ownCloud you wish to install.
                        # You can set this to "latest" but it isn't recommended
                        # as owncloud updates may require an updated script.
nextcloud_version="11.0.2"      # Same as owncloud_version but for nextcloud.

##! END OF OWNCLOUD / NEXTCLOUD INSTALLER CONFIG ! IMPORTANT ! DO NOT IGNORE ! ##
###! No need to edit below here unless the script asks you to !###
##### OWNCLOUD / NEXTCLOUD UPDATER CONFIG #####
owncloud_update="latest"    # This can be safely ignored unless you are planning
                        # on using the updater in this script (not recommended)
                        # It's best to leave it alone and let owncloud update itself
################################################################################
##### OTHER APPS CONFIGURATION #####
jail_ip="192.168.1.200"   # ! No need to change this for OwnCloud installs !
                          # Only change this for OTHER jails/apps
                        # MUST be different to cloud_server_ip if you have
                        # installed OwnCloud previously.
################################################################################
###! EMBY CONFIG !###
emby_def_update_ver="3.2.13.0"  # You can find release numbers here:
                        # https://github.com/MediaBrowser/Emby/releases
                        # Example, To use the beta: "3.0.5947-beta"
                        # Example, To use the dev: "3.0.5966.988-dev"
################################################################################
###! SABNZBD CONFIG !###
sab_ver="2.0.0"         # You can find release numbers here:
                        # https://github.com/sabnzbd/sabnzbd/releases
################################################################################
###! SUBSONIC / MADSONIC CONFIG !###
subsonic_ver="6.0"      # You can find release numbers here:
                        # sourceforge.net/projects/subsonic/files/subsonic
madsonic_ver="6.2.9040" # http://beta.madsonic.org/pages/download.jsp
################################################################################
###! THEBRIG CONFIG !###
# Define where to install TheBrig
thebriginstalldir="/mnt/Storage/System/Jails"
thebrigbranch="alcatraz"    # Define which version of TheBrig to install
                        # master   - For 9.0 and 9.1 FreeBSD versions
                        # working  - For 9.1 and 9.2 FreeBSD versions
                        # alcatraz - For 9.3 and 10.x FreeBSD versions
# thebrigversion="3"    # Not needed anymore

###! END OF THEBRIG CONFIG !###
################################################################################
### OTHER ###
# Modify this to reflect your storage location
mystorage="/mnt/Storage"
myappsdir="/mnt/Storage/Apps"
##################################################
###! CALIBRE CONFIG !#############################
# Modify to where you store all of your books.
CALIBRELIBRARYPATH="/mnt/Storage/Media/Books"
##################################################
###! MUNIN CONFIG !###############################
# Enter the jail name you wish to run Munin in
#muninjail="Munin"   # Unused currently
                     # (For a future idea)
##################################################
###! NZBGET CONFIG !##############################
#nzbgetjail="NZBGet" # Unused currently
                     # (For a future idea)
##################################################
###! DELUGE CONFIG !##############################
#delugejail="Deluge" # Unused currently
user_ID="UID"
deluge_user="JonDoe"
deluge_user_password="MyC0mpL3xPass"
##################################################
##### END OF CONFIGURATION SECTION #####
################################################################################


# Get IP
jailip=$(ifconfig | grep -e "inet" -e "addr:" | grep -v "inet6" | grep -v "127.0.0.1" | head -n 1 | awk '{print $2}')
#Grab the date & time to be used later
date=$(date +"%Y.%m.%d-%I.%M%p")

# Add some colour!
nc='\033[0m'        # Default Text (No Formatting / No Color)
alt='\033[0;31m'    # Alert Text
emp='\033[1;31m'    # Emphasis Text
msg='\033[1;37m'    # Message Text
url='\033[1;32m'    # URL
qry='\033[0;36m'    # Query Text
ssep='\033[1;30m#----------------------#\033[0m'    # Small Line Separator
msep='\033[1;30m#--------------------------------------#\033[0m'    # Medium Line Separator
sep='\033[1;30m----------------------------------------------------------------------\033[0m'   # Line Separator
cmd='\033[1;35m'    # Command to be entered
fin='\033[0;32m'    # Green Text
inf='\033[0;33m'    # Information Text
ul='\033[4m'        # Underline Text
lbt='\033[1;34m'    # Light Blue Text
yt='\033[1;33m'     # Yellow Text
lct='\033[1;36m'    # Light Cyan Text
ca='\033[1;30m'     # Currently Unavailable (Dark Grey Text)



################################################################################
##### CONTACT
################################################################################

gethelp ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} Ways of contacting me / Getting help from others:${nc}"
        echo -e "${sep}"
        echo " "
        echo -e "${fin}   ${ul}My Discord Support${fin} (Usually faster responses):${nc}"
        echo -e "${msg}      https://discord.gg/0bXnhqvo189oM8Cr${nc}"
        echo -e "${fin}   ${ul}My Email${fin} (Discord is easier):${nc}"
        echo -e "${msg}      support@vengefulsyndicate.com${nc}"
        echo -e "${fin}   ${ul}Forums:${nc}"
        echo -e "${msg}      NAS4Free Forums - NextCloud/OwnCloud:${nc}"
        echo -e "${url}      http://forums.nas4free.org/viewtopic.php?f=79&t=9383${nc}"
        echo -e "${msg}      [VS] Forums:${nc}"
        echo -e "${url}      forums.vengefulsyndicate.com${nc}"
        echo " "
        echo -e "${fin}   Find an issue with the script or have a suggestion?${nc}"
        echo -e "${msg}   Drop a message using the above or head here:${nc}"
        echo -e "${url}      https://github.com/Nozza-VS/misc-code/issues"
        echo " "
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}



################################################################################
##### Debug
################################################################################

OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "dnvh" opt; do
      case $opt in
        h)	echo " "
			echo -e "${inf} -v ${msg}Run the script run in verbose mode${nc}"
			echo -e "${inf} -d ${msg}Print command traces before executing command${nc}"
			echo -e "${inf} -n ${msg}Read commands but do not execute them${nc}"
			echo " "
			exit 1;;
        d)	set -x;;
        n)	set -n;;
        v)	set -v;;
        *)  echo " "
			echo -e "${alt}        Invalid choice, please try again${nc}"
			echo " "
            exit 1;;

      esac
    done



################################################################################
##### OTHER OPTIONS
################################################################################

#------------------------------------------------------------------------------#
### CLOUD - ENABLE MEMORY CACHING
#TODO: Add option for automatic or manual (Will also need to ask if user is
#      using default installation folder otherwise the auto version won't work)
#------------------------------------------------------------------------------#

owncloud.enablememcache ()
{

while [ "$choice" ]
do
        echo "  'memcache.local' => '\OC\Memcache\APCu'," >> /usr/local/www/owncloud/config/memcache.txt
        cp /usr/local/www/owncloud/config/config.php /usr/local/www/owncloud/config/old_config.bak
        cat "/usr/local/www/owncloud/config/old_config.bak" | \
	        sed '21r /usr/local/www/owncloud/config/memcache.txt' > \
            "/usr/local/www/owncloud/config/config.php"
        rm /usr/local/www/owncloud/config/memcache.txt

        /usr/local/etc/rc.d/lighttpd restart

        echo " "
        echo "${sep}"
        echo " "

        echo -e " Head to your owncloud admin page/refresh it"
        echo -e " There should no longer be a message at the top about memory caching"
        echo -e " If it didn't work follow these steps:"
        echo -e " "
        echo -e "${msg} This is entirely optional. Edit config.php:${nc}"
        echo -e "${msg} Default location is:${nc}"
        echo -e "\033[1;36m    /usr/local/www/owncloud/config/config.php${nc}"
        echo -e "${msg} Add the following right above the last line:${nc}"
        echo -e "\033[1;33m    'memcache.local' => '\OC\Memcache\APCu',${nc}"
        echo " "
        echo -e "${msg} Once you've saved the file, restart the server with:${nc}"
        echo -e "${cmd}    /usr/local/etc/rc.d/lighttpd restart"
        echo " "
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#

nextcloud.enablememcache ()
{

while [ "$choice" ]
do
        echo "  'memcache.local' => '\OC\Memcache\APCu'," >> /usr/local/www/nextcloud/config/memcache.txt
        cp /usr/local/www/nextcloud/config/config.php /usr/local/www/nextcloud/config/old_config.bak
        cat "/usr/local/www/nextcloud/config/old_config.bak" | \
	        sed '21r /usr/local/www/nextcloud/config/memcache.txt' > \
            "/usr/local/www/nextcloud/config/config.php"
        rm /usr/local/www/nextcloud/config/memcache.txt

        /usr/local/etc/rc.d/lighttpd restart

        echo " "
        echo "${sep}"
        echo " "

        echo -e " Head to your nextcloud admin page/refresh it"
        echo -e " There should no longer be a message at the top about memory caching"
        echo -e " If it didn't work follow these steps:"
        echo -e " "
        echo -e "${msg} This is entirely optional. Edit config.php:${nc}"
        echo -e "${msg} Default location is:${nc}"
        echo -e "\033[1;36m    /usr/local/www/nextcloud/config/config.php${nc}"
        echo -e "${msg} Add the following right above the last line:${nc}"
        echo -e "\033[1;33m    'memcache.local' => '\OC\Memcache\APCu',${nc}"
        echo " "
        echo -e "${msg} Once you've saved the file, restart the server with:${nc}"
        echo -e "${cmd}    /usr/local/etc/rc.d/lighttpd restart"
        echo " "
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}



################################################################################
##### INFORMATION / ABOUT
################################################################################

#------------------------------------------------------------------------------#
### ABOUT: THIS SCRIPT

about.thisscript ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: This Script${nc}"
        echo " "
        echo -e "${msg} I've been maintaining the 'OwnCloud in a Jail' NAS4Free script${nc}"
        echo -e "${msg} for some time now and I tend to do a lot of messing around in jails on NAS4Free${nc}"
        echo -e "${msg} As well as helping others set up jails for different things.${nc}"
        echo " "
        echo -e "${msg} So I figured, 'why am i always manually doing all this when i can script it?'${nc}"
        echo -e "${msg} And now here we are! Aiming to have a mostly automated script for some of the${nc}"
        echo -e "${msg} most common jail setups and hopefully some useful info about these setups${nc}"
        echo -e "${msg} to help aid with any possible issues without google search frenzies!${nc}"
        echo " "
        echo -e "${msg} Wish to contribute? Feel free to drop me a message anyhere listed in the${nc}"
        echo -e "${msg} 'Contact / Get Help' menu.${nc}"
        echo " "
        echo -e "${msg} Like my work enough to buy me a pizza? Please do!${nc}"
        echo -e "${url} https://www.paypal.me/AshleyTownsend${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: MYSQL

about.mysql ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: MySQL${nc}"
        echo " "
        echo -e "${msg} MySQL is an open-source relational database management system (RDBMS). The SQL${nc}"
        echo -e "${msg} abbreviation stands for Structured Query Language. The MySQL development${nc}"
        echo -e "${msg} project has made its source code available under the terms of the GNU General${nc}"
        echo -e "${msg} Public License, as well as under a variety of proprietary agreements.${nc}"
        echo " "
        echo -e "${msg} MySQL is a popular choice of database for use in web applications, and is a${nc}"
        echo -e "${msg} central component of the widely used LAMP open-source web application software${nc}"
        echo -e "${msg} stack (and other 'AMP' stacks).${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: CLOUD STORAGE

about.cloudstorage ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Cloud Storage${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: OWNCLOUD

about.owncloud ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: ownCloud${nc}"
        echo " "
        echo -e "${msg} ownCloud is a self-hosted file sync & share server. It provides access to your${nc}"
        echo -e "${msg} data through a web interface, sync clients or WebDAV while providing a platform${nc}"
        echo -e "${msg} to view, sync and share across devices easily — all under your control.${nc}"
        echo " "
        echo -e "${msg} ownCloud’s open architecture is extensible via a simple but powerful API for${nc}"
        echo -e "${msg} applications and plugins and it works with any storage.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: NEXTCLOUD

about.nextcloud ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: NextCloud${nc}"
        echo " "
        echo -e "${emp} 'About: NextCloud' hasn't been added to this script yet :(${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: NEXTCLOUD / OWNCLOUD DIFFERENCES

about.cloud.differences ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Difference between NextCloud & ownCloud${nc}"
        echo " "
        echo -e "${emp} This info hasn't been added to this script yet :(${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: PYDIO

about.pydio ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Pydio${nc}"
        echo " "
        echo -e "${msg} Pydio (formely AjaXplorer) is a mature open source software solution for${nc}"
        echo -e "${msg} file sharing and synchronization. With intuitive user interfaces${nc}"
        echo -e "${msg} (web/mobile/desktop), Pydio provides enterprise-grade features to gain back${nc}"
        echo -e "${msg} control and privacy of your data. Pydio is hosted exclusively on your private${nc}"
        echo -e "${msg} server or cloud so you can rest assured that files are securely managed under your control.${nc}"
        echo -e "${msg} your control.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: EMBY SERVER

about.emby ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Emby Media Server${nc}"
        echo " "
        echo -e "${msg} Emby Server is a home media server built on top of other popular open source${nc}"
        echo -e "${msg} technologies such as Service Stack, jQuery, jQuery  mobile, and Mono.${nc}"
        echo " "
        echo -e "${msg} It features a REST-based API with built-in documention to  facilitate client${nc}"
        echo -e "${msg} development. It also has client libraries for API to enable rapid development.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: PLEX MEDIA SERVER

about.plex ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Plex Media Server${nc}"
        echo " "
        echo -e "${msg} Plex organizes all of your personal media so you can enjoy it,${nc}"
        echo -e "${msg} no matter where you are.${nc}"
        echo " "
        echo -e "${msg} Plex's front-end media player, Plex Media Player (formerly Plex Home Theater),${nc}"
        echo -e "${msg} allows the user to manage and play audiobooks, music, photos, podcasts, and${nc}"
        echo -e "${msg} videos from a local or remote computer running Plex Media Server. Additionally,${nc}"
        echo -e "${msg} the integrated Plex Online service provides the user with a growing list of${nc}"
        echo -e "${msg} community-driven plugins for online content such as Netflix, Hulu, etc.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: SUBSONIC

about.subsonic ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Subsonic${nc}"
        echo " "
        echo -e "${msg} Subsonic is a free, web-based media streamer, providing ubiqutious access${nc}"
        echo -e "${msg} to your music. Use it to share your music with friends, or to listen to your${nc}"
        echo -e "${msg} own music while at work. You can stream to multiple players simultaneously,${nc}"
        echo -e "${msg} for instance to one player in your kitchen and another in your living room.${nc}"
        echo " "
        echo -e "${msg} Subsonic is designed to handle very large music collections${nc}"
        echo -e "${msg} (hundreds of gigabytes). Although optimized for MP3 streaming, it works for any${nc}"
        echo -e "${msg} audio or video format that can stream over HTTP, for instance AAC and OGG.${nc}"
        echo -e "${msg} By using transcoder plug-ins, Subsonic supports on-the-fly conversion and${nc}"
        echo -e "${msg} streaming of virtually any audio format, including WMA, FLAC, APE, Musepack,${nc}"
        echo -e "${msg} WavPack and Shorten.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}

#------------------------------------------------------------------------------#
### ABOUT: SONARR

about.sonarr ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Sonarr (Formerly NZBDrone)${nc}"
        echo " "
        echo -e "${msg} Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS${nc}"
        echo -e "${msg} feeds for new episodes of your favorite shows and  will grab, sort and rename${nc}"
        echo -e "${msg} them. It can also be configured to  automatically upgrade the quality of files${nc}"
        echo -e "${msg} already downloaded  when a better quality format becomes available.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: COUCHPOTATO

about.couchpotato ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: CouchPotato${nc}"
        echo " "
        echo -e "${msg} CouchPotato (CP) is an automatic NZB and torrent downloader.${nc}"
        echo -e "${msg} You can keep a 'movies I want'-list and it will search for NZBs/torrents${nc}"
        echo -e "${msg} of these movies every X hours. Once a movie is  found, it will send it to${nc}"
        echo -e "${msg} SABnzbd/NZBGet or download the torrent to a specified directory.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: HEADPHONES

about.headphones ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Headphones${nc}"
        echo " "
        echo -e "${msg} Headphones is an automated music downloader for NZB and Torrent, written in${nc}"
        echo -e "${msg} Python. It supports SABnzbd, NZBget, Transmission, µTorrent, Deluge and${nc}"
        echo -e "${msg} Blackhole.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### ABOUT: THEBRIG

about.thebrig ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: TheBrig${nc}"
        echo " "
        echo -e "${msg} thebrig is a set of PHP pages used to create & manage FreeBSD jails on NAS4Free${nc}"
        echo " "
        echo -e "${msg} The main advantage of thebrig is that it leverages the existing webgui control${nc}"
        echo -e "${msg} and accounting mechanisms found within Nas4Free, and can be used on an embedded${nc}"
        echo -e "${msg} installation.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}

#------------------------------------------------------------------------------#
### ABOUT: DELUGE

about.deluge ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Deluge${nc}"
        echo " "
        echo -e "${msg} Deluge is a lightweight, Free Software, cross-platform BitTorrent client.${nc}"
        echo " "
        echo -e "${msg} It provides: Full Encryption, WebUI, Plugin System & Much more${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}

#------------------------------------------------------------------------------#
### ABOUT: NZBGET

about.nzbget ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: NZBGet${nc}"
        echo " "
        echo -e "${msg} NZBGet is a binary downloader, which downloads files from Usenet based on${nc}"
        echo -e "${msg} information given in nzb-files.${nc}"
        echo " "
        echo -e "${msg} NZBGet is written in C++ and is known for its extraordinary performance and${nc}"
        echo -e "${msg} efficiency.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}

#------------------------------------------------------------------------------#
### ABOUT: SABNZBD

about.sabnzbd ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: SABnzbd${nc}"
        echo " "
        echo -e "${msg} SABnzbd makes Usenet as simple and streamlined as possible by automating${nc}"
        echo -e "${msg} everything we can. All you have to do is add an .nzb. SABnzbd takes over from${nc}"
        echo -e "${msg} there, where it will be automatically downloaded, verified, repaired, extracted${nc}"
        echo -e "${msg} and filed away with zero human interaction.${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}

#------------------------------------------------------------------------------#
### ABOUT: TEAMSPEAK 3

about.teamspeak3 ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} About: Teamspeak 3${nc}"
        echo " "
        echo -e "${msg} ${nc}"
        echo -e "${sep}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done

}



#------------------------------------------------------------------------------#
### Clean ports tree

clean.portstree ()
{
echo " rm -rf /usr/ports/*/*/work"
}



################################################################################
##### HOW-TO'S
################################################################################

#------------------------------------------------------------------------------#
### OWNCLOUD - HOW-TO: FINISH SETUP
#------------------------------------------------------------------------------#

owncloud.howto.finishsetup ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} OwnCloud - How to finalize setup${nc}"
        echo -e "${sep}"
        echo " "
        echo -e "${emp} Follow these instructions carefully${nc}"
        echo " "
        echo -e "${msg} In a web browser, head to: ${url}https://$cloud_server_ip:$cloud_server_port${nc}"
        echo " "
        echo -e "${msg} Admin Username: ${inf}Enter your choice of username${nc}"
        echo -e "${msg} Admin Password: ${inf}Enter your choice of password${nc}"
        echo " "
        echo -e "${alt}    Click Database options and choose MySQL${nc}"
        echo -e "${msg} Database username: ${inf}root${nc}"
        echo -e "${msg} Database password: ${inf}THE PASSWORD YOU ENTERED EARLIER FOR MYSQL${nc}"
        echo -e "${msg} Database host: ${inf}Leave as is (Should be localhost)${nc}"
        echo -e "${msg} Database name: ${inf}Your choice (owncloud is fine)${nc}"
        echo " "
        echo -e "${emp} Click Finish Setup, the page will take a moment to refresh${nc}"
        echo -e "${msg} After it refreshes, if you are seeing a 'Trusted Domain' error,${nc}"
        echo -e "${msg} head back to the owncloud menu and select option 4.${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}



################################################################################
##### HOW-TO'S: EMBY
################################################################################

#------------------------------------------------------------------------------#
### EMBY - HOW-TO: RESTART THE SERVER

emby.howto.restartserver ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} Emby - How to restart your server${nc}"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} If you need to restart the server, you can with:${nc}"
        echo -e "${cmd}    service emby-server restart${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

################################################################################
##### HOW-TO'S: THEBRIG
################################################################################

#------------------------------------------------------------------------------#
### THEBRIG - HOW-TO: INSTALL THEBRIG
#------------------------------------------------------------------------------#

thebrig.howto.installthebrig ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - How to install TheBrig manually${nc}"
        echo -e "${sep}"
        echo " "
        # Create directory
        # mkdir -p ${thebriginstalldir}
        # change to directory
        # cd ${thebriginstalldir}
        # Fetch TheBrig installer
        # fetch https://raw.githubusercontent.com/fsbruva/thebrig/alcatraz/thebrig_install.sh
        # Execute the script
        # /bin/sh thebrig_install.sh ${thebriginstalldir} &

        # echo " 1: Go to Extensions page in WebGUI > TheBrig > Maintenance > Rudimentary Config (Should take you to this config by default)"
        # echo " 2: Click 'Save' (Make sure 'Installation folder' is correct first,"
        # echo "    we want it outside of the NAS4Free operating system drive"
        # echo " 3: Head to Tarball Management (Underneath 'Maintenance') > Clicked Query!"
        # echo " 4: Chose 'Release: 10.2-RELEASE' from dropdown menu (Should be selected by     default after clicking query)"
        # echo " 5: Tick all boxes below (Only 'base.txz' and 'lib32.txz' are really needed but grab all anyway)"
        # echo " 6: Click Fetch, wait a while for the downloads to finish"
        # echo " Once all the download bars are gone you can proceed to making your jail"
        # echo " Instructions on creating a jail can be found in the 'more info' menu"
        echo -e "${emp} This part of the script is unfinished currently :(${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### THEBRIG - HOW-TO: CREATE A JAIL
#------------------------------------------------------------------------------#

thebrig.howto.createajail ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - How to create a jail${nc}"
        echo -e "${sep}"
        echo " "
        echo -e "${emp} This assumes you have installed TheBrig already and${nc}"
        echo -e "${emp} have done the initial configuration.${nc}"
        echo " "
        echo -e "${msg} Head to your NAS webgui, you should see a menu${nc}"
        echo -e "${msg} named '${inf}Extensions${msg}'. Hover over it and click '${inf}TheBrig${msg}'${nc}"
        echo -e "${msg} From here, click the '${inf}+${msg}' icon${nc}"
        echo -e "${msg} On the new page, there are some things to change${nc}"
        echo " "
        echo -e "${fin} OPTIONAL ${msg}things are: '${inf}Jail name${msg}', '${inf}Path to jail${msg}'${nc}"
        echo -e "${msg}    & '${inf}Description${msg}'${nc}"
        echo " "
        echo -e "${emp} MUST ${msg}change items are: '${inf}Jail Network settings${msg}'"
        echo -e "${msg}    & '${inf}Official FreeBSD Flavor${msg}'${nc}"
        echo " "
        echo -e "${msg} For Jail IP enter an address that is NOT your NAS IP${nc}"
        echo -e "${msg} or conflicts with any other IP on your network${nc}"
        echo -e "${msg} It must be filled out like so: ${inf}192.168.1.200/24${nc}"
        echo -e "${msg} Once you have entered your desired IP, click '${inf}<<${msg}'.${nc}"
        echo " "
        echo -e "${msg} For FreeBSD Flavor, select at least 1 of each type:${nc}"
        echo -e "${msg} '${inf}base${msg}' & '${inf}lib32${msg}'${nc}"
        echo " "
        echo -e "${msg} Now press '${inf}Add${msg}' at the bottom and that should be it!${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### THEBRIG - HOW-TO: MOUNT YOUR STORAGE IN JAIL WITH FSTAB
#------------------------------------------------------------------------------#

thebrig.howto.mountviafstab ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - How to mount any storage folder in a jail using fstab${nc}"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} First, you need to create a folder in the jail matching the name of the folder to mount${nc}"
        echo -e "${msg} Example: mkdir /mnt/Storage/Jails/JailName/mnt/MEDIA${nc}"
        echo -e "${msg} Now, head to your NAS webgui and go to '${inf}Extensions${msg}' -> '${inf}TheBrig.${nc}"
        echo -e "${msg} Click the settings icon for the jail you wish to have your folder mounted in.${nc}"
        echo -e "${msg} Now click the '${inf}More${msg}' button near the bottom.${nc}"
        echo -e "${msg} You should be presented with a lot more options.${nc}"
        echo -e "${msg} Look for '${inf}Fstab for current jail${msg}'${nc}"
        echo -e "${msg} An example of what to set in here is:${nc}"
        echo -e "${msg} /mnt/Storage/Media /mnt/Jails/JailName/mnt/MEDIA nullfs rw 0 0${nc}"
        echo -e "${msg} /mnt/Storage/Media = The folder you want mounted${nc}"
        echo -e "${msg} /mnt/Jails/JailName/mnt/MEDIA = The jail folder to mount in${nc}"
        echo -e "${msg} 'rw 0 0' at the end = the jail may write to the folder${nc}"
        echo -e "${msg} 'ro 0 0' at the end = the jail may NOT write to the folder${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### THEBRIG - HOW-TO: ENABLE PORTS TREE
#------------------------------------------------------------------------------#

thebrig.howto.enableportstree ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - How to enable the ports tree in jails:"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} Head to your NAS webgui and go to '${inf}Extensions${msg}' -> '${inf}TheBrig.${nc}"
        echo -e "${msg} From here, you want to click '${inf}Updates${msg}' and then '${inf}Central Ports.${nc}"
        echo -e "${msg} First thing to do here is click '${inf}Fetch & Update${msg}'${nc}"
        echo -e "${msg} After it has done, tick the box next to the name of the jail you wish${nc}"
        echo -e "${msg} to enable the ports tree in. Finally, click '${inf}Save${msg}'.${nc}"
        echo -e "${msg} Optionally you may also tick the '${inf}Cronjob${msg}' box and click '${inf}Save${msg}'.${nc}"
        echo -e "${msg} This won't automatically apply the updates but it will make it so in future,${nc}"
        echo -e "${msg} You may come back to this page and simply click '${inf}Update${msg}'${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### THEBRIG - ABOUT: RUDIMENTARY CONFIGURATION
#------------------------------------------------------------------------------#

info.thebrig.rudimentaryconfig ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - Rudimentary Configuration"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} Head to that new ${fin}Extensions->TheBrig${msg} page in your WebGUI${nc}"
        echo -e "${msg} After making sure the '${fin}Installation folder${msg}' =${fin} ${mystorage}/Jails${msg}, Click '${inf}Save${msg}'${nc}"
        echo " "
        echo -e "${msg} Now head to '${fin}Tarball Management${msg}' (Underneath 'Maintenance') > Click ${inf}Query!${nc}"
        echo -e "${msg} It should now have '${fin}10.2-RELEASE${msg}' in the new dropdown menu${nc}"
        echo -e "${msg}    (Select it if it isn't already)${nc}"
        echo -e "${msg} Tick all boxes below that ${nc}"
        echo -e "${msg}    (Only '${fin}base.txz${msg}' and '${fin}lib32.txz${msg}' are really needed${nc}"
        echo -e "${msg}     but let's grab them all just in case)${nc}"
        echo -e "${msg} Click '${inf}Fetch${msg}', wait some time for the downloads to finish${nc}"
        echo -e "${msg} Once all the download bars are gone you can proceed to making your jail${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}



#------------------------------------------------------------------------------#
### EMBY SERVER - HOW-TO: UPDATE FFMPEG FROM PORTS TREE (FOR TRANSCODING)
#------------------------------------------------------------------------------#

emby.howto.updateffmpeg ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} Emby - How to update FFMpeg from ports tree:"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} Remove default FFMpeg package:${nc}"
        echo -e "${cmd}    pkg delete -f ffmpeg${nc}"
        echo -e "${msg} Reinstall FFMpeg from ports with 'lame' & 'ass' options${nc}"
        echo -e "${msg} enabled. To enable an option, highlight it using the arrow${nc}"
        echo -e "${msg} keys and press space (I also enable 'OPUS' option)${nc}"
        echo -e "${cmd}    cd /usr/ports/multimedia/ffmpeg${nc}"
        echo -e "${cmd}    make config${nc}"
        echo -e "${msg} This final step will take some time and you will also${nc}"
        echo -e "${msg} get a few prompts, just press enter each time.${nc}"
        echo -e "${cmd}    make install clean${nc}"
        echo -e "${msg} Once it is done, restart the emby server${nc}"
        echo -e "${cmd}    service emby-server restart${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER - HOW-TO: Set up the server bot
#------------------------------------------------------------------------------#

teamspeak3.howto.setupbot ()
{
while [ "$choice" ]
do
        echo -e "${sep}"
        echo -e "${inf} Emby - How to set up the server bot:"
        echo -e "${sep}"
        echo " "
        echo -e "${msg} ${nc}"
        echo " "

        echo -e "${msep}"
        echo -e "${emp}   Press Enter To Go Back To The Menu${nc}"
        echo -e "${msep}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}



################################################################################
##### FIXES
################################################################################

#------------------------------------------------------------------------------#
### OWNCLOUD - TRUSTED DOMAIN WARNING FIX
#------------------------------------------------------------------------------#

owncloud.trusteddomain.fix ()
{
# Confirm with the user
echo " "
echo -e "${emp} Please finish the owncloud setup before continuing${nc}"
echo -e "${emp} Can ignore the next few steps if you've already done it.${nc}"
echo -e "${msg} Head to ${url}https://$cloud_server_ip:$cloud_server_port ${msg}to do this.${nc}"
echo -e "${msg} Fill out the page you are presented with and hit finish${nc}"
echo " "
echo -e "${msg} Admin username & password = whatever you choose${nc}"
echo " "
echo -e "${emp} Make sure you click 'Storage & database'${nc}"
echo " "
echo -e "${msg} Database user = ${qry}root${nc} | Database password = ${nc}"
echo -e "${msg} the ${qry}mysql password${msg} you chose earlier during the script.${nc}"
echo -e "${msg} Database name = your choice (just ${qry}owncloud${msg} is fine)${nc}"
echo " "
echo " When trying to access owncloud"
read -r -p "   do you have a 'untrusted domain' error? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, let's fix that.
              echo " "
              echo -e "${url} Doing some last second changes to fix that..${nc}"
              echo " "
              # Prevent "Trusted Domain" error
              echo "    '${server_ip}'," >> /usr/local/www/owncloud/config/trusted.txt
              cp /usr/local/www/owncloud/config/config.php /usr/local/www/owncloud/config/old_config.bak
              cat "/usr/local/www/owncloud/config/old_config.bak" | \
                sed '8r /usr/local/www/owncloud/config/trusted.txt' > \
                "/usr/local/www/owncloud/config/config.php"
              rm /usr/local/www/owncloud/config/trusted.txt
              echo -e " Done, continuing with the rest of the script"
               ;;
    *)
              # If no, just continue like normal.
              echo " "
              echo -e "${qry} Great!, no need to do anything, continuing with script..${nc}"
              echo " "
              ;;
esac
}

#------------------------------------------------------------------------------#
### OWNCLOUD - Populating Raw Post Data Fix
#------------------------------------------------------------------------------#

cloud.phpini ()
{
echo " "
echo -e "${sep}"
echo -e "${msg} Modifying php.ini${nc}"
echo -e "${msg}    (/usr/local/etc/php.ini)${nc}"
echo -e "${sep}"
echo " "

echo always_populate_raw_post_data = -1 > /usr/local/etc/php.ini
}



################################################################################
##### OTHER
################################################################################

#------------------------------------------------------------------------------#
### EMBY - RECOMPILE FROM PORTS
#------------------------------------------------------------------------------#
recompile.imagemagick ()
{

recompile.imagemagick.continue ()
{
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
read -r -p " " response
case "$response" in
    *)
              # Otherwise continue with backup...
              ;;
esac
}


# Confirm with the user
echo -e "${msg} These steps could take some time${nc}"
read -r -p "   Would you like to recompile these now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              echo " "
              echo -e "${sep}"
              echo -e "${fin} First, lets do ImageMagick${nc}"
              echo -e "${msg} When the options pop up, disable (By pressing space when its highlighted):${nc}"
              echo -e "${inf}    16BIT_PIXEL   ${msg}(to increase thumbnail generation performance)${nc}"
              echo -e "${msg} and then press 'Enter'${nc}"
              echo " "

              recompile.imagemagick.continue

              cd /usr/ports/graphics/ImageMagick && make deinstall
              make clean && make clean-depends
              make config

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Press 'OK'/'Enter' if any box that follows.${nc}"
              echo -e "${msg}    (There shouldn't be any that pop up)${nc}"
              echo -e "${sep}"
              echo " "

              recompile.imagemagick.continue

              make install clean
              #make -DBATCH install clean

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Finished with the recompiling!${nc}"
              echo -e "${sep}"
              echo " "
              ;;
esac
}



recompile.ffmpeg ()
{

recompile.ffmpeg.continue ()
{
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
read -r -p " " response
case "$response" in
    *)
              # Otherwise continue with backup...
              ;;
esac
}

# Confirm with the user
echo -e "${msg} These steps could take some time${nc}"
read -r -p "   Would you like to recompile these now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              echo " "
              echo -e "${sep}"
              echo -e "${fin} Great, now ffmpeg${nc}"
              echo -e "${sep}"
              echo " "

              cd /usr/ports/multimedia/ffmpeg && make deinstall

              echo " "
              echo -e "${sep}"
              echo -e "${msg} When the options pop up, enable (By pressing space when its highlighted):${nc}"
              echo -e "${inf}    ASS     ${msg}(required for subtitle rendering)${nc}"
              echo -e "${inf}    LAME    ${msg}(required for mp3 audio transcoding -${nc}"
              echo -e "${inf}            ${msg}disabled by default due to mp3 licensing restrictions)${nc}"
              echo -e "${inf}    OPUS    ${msg}(required for opus audio codec support)${nc}"
              echo -e "${inf}    X265    ${msg}(required for H.265 video codec support${nc}"
              echo -e "${msg} Then press 'OK' for every box that follows.${nc}"
              echo -e "${msg} This one may take a while, please be patient${nc}"
              echo -e "${sep}"
              echo " "

              recompile.ffmpeg.continue

              make clean
              make clean-depends
              make config

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Press 'OK'/'Enter' for any box that follows.${nc}"
              echo -e "${sep}"
              echo " "

              recompile.ffmpeg.continue

              #make install clean
              make -DBATCH install clean

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Finished with the recompiling!${nc}"
              echo -e "${sep}"
              echo " "
              ;;
esac
}

emby.server.improvements ()
{
	echo " "
}



################################################################################
##### INSTALLERS
# TODO: Finish the rest of the installers
################################################################################

#------------------------------------------------------------------------------#
### MYSQL INSTALL

install.mysql ()
{
webmin ()
{
# Confirm with the user
read -r -p "   Install Webmin? [y/N]" response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${fin} Setting up Webmin..${nc}"
              pkg install -y webmin
              echo 'webmin_enable="YES"' >> /etc/rc.conf
              /usr/local/lib/webmin/setup.sh
              /usr/local/etc/rc.d/webmin restart
              echo -e "${msg} You should now be able to visit${nc}"
              echo -e "${url} http://jailip:10000 ${msg}and log in to webmin.${nc}"
              echo " "
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${inf} Skipping Webmin..${nc}"
              echo " "
              ;;
esac
}

phpmyadmin ()
{
echo " "
mkdir /usr/local/www/phpMyAdmin/config && chmod o+w /usr/local/www/phpMyAdmin/config
chmod o+r /usr/local/www/phpMyAdmin/config.inc.php
echo -e "${emp} Follow these instructions carefully before continuing:${nc}"
echo " "
echo -e "${msg} 1: In your web browser, go to ${url}http://jailip/phpMyAdmin/setup${nc}"
echo -e "${msg} 2: Click ${cmd}'New server'${msg} and select the ${cmd}'Authentication'${msg} tab.${nc}"
echo -e "${msg} 3: Under the ${cmd}'Authentication type'${msg} choose ${cmd}'http'${nc}"
echo -e "${msg}    from the drop-down list (prevents storing login${nc}"
echo -e "${msg}    credentials directly in config.inc.php)${nc}"
echo -e "${msg} 4: Also remove ${cmd}'root'${msg} from the ${cmd}'User for config auth'${nc}"
echo -e "${msg} 5: Now click ${cmd}'Apply'${msg} and you'll return to the Overview page.${nc}"
echo -e "${msg} 6: Finally, Click ${cmd}'Save'${msg} to save your configuration in${nc}"
echo -e "${msg}      /usr/local/www/phpMyAdmin/config/config.inc.php.${nc}"
echo " "
echo " Only continue once you have done the above steps"
read -r -p "   Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Great! Moving on..${nc}"
              #Now let’s move that file up one directory to /usr/local/www/phpMyAdmin where phpMyAdmin can make use of it.
              mv /usr/local/www/phpMyAdmin/config/config.inc.php /usr/local/www/phpMyAdmin
              rm -r /usr/local/www/phpMyAdmin/config
              chmod o-r /usr/local/www/phpMyAdmin/config.inc.php
              echo " "
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt} phpMyAdmin wont work without setting it up.${nc}"
              echo -e "${msg} It's not required though so skipping..${nc}"
              echo " "
              ;;
esac
}

dbtype ()
{
echo " "
echo -e "${emp} Choose between MariaDB or MySQL:${nc}"
echo " "
echo -e "${msg} 1: MariaDB${nc}"
echo -e "${msg} 2: MySQL${nc}"
echo " "
echo " Choose carefully, in some cases this cannot be changed!"
read -r -p "   Make your selection? [1 or 2] " response
case "$response" in
    [1])
              echo " Installing MariaDB"
              echo " "
              pkg install -y mariadb10-server
          ;;
    [2])
              echo " Installing MySQL"
              echo " "
              pkg install -y mysql56-server
          ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt} No DB Selected${nc}"
              echo " "
          ;;
esac
}


echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the MySQL guided setup script!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with downloading some packages.${nc}"
echo -e "${msg} If you get an error about '${qry}package management tool${nc}"
echo -e "${qry} is not yet installed${msg}', just press y then enter.${nc}"
echo -e " "
echo -e "${msg} You may also get 2 errors later from Apache:${nc}"
echo -e "${msg} AH00557 & AH00558, these can be safely ignored.${nc}"
echo -e "${sep}"
echo " "

pkg install -y nano mysql56-server mod_php56 php56-mysql php56-mysqli phpmyadmin apache24

#dbtype

# -------------------------------------------------------
# MySQL

echo " "
echo -e "${sep}"
echo -e "${msg}   Great, now let's get MySQL set up.${nc}"
echo -e "${sep}"
echo " "

echo 'mysql_enable="YES"' >> /etc/rc.conf
echo '[mysqld]' >> /var/db/mysql/my.cnf

/usr/local/etc/rc.d/mysql-server start

mysql_secure_installation

/usr/local/etc/rc.d/mysql-server restart

# -------------------------------------------------------
# Webmin

echo " "
echo -e "${sep}"
echo -e "${msg}   Would you like Webmin also? (Not required)${nc}"
echo -e "${sep}"
echo " "

webmin

# -------------------------------------------------------
# Apache

echo " "
echo -e "${sep}"
echo -e "${msg}   Getting there! Time for Apache setup.${nc}"
echo -e "${sep}"
echo " "

echo 'apache24_enable="YES"' >> /etc/rc.conf
service apache24 start
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini

# Configure Apache to Use PHP Module

echo '<IfModule dir_module>' >> /usr/local/etc/apache24/Includes/php.conf
echo '    DirectoryIndex index.php index.html' >> /usr/local/etc/apache24/Includes/php.conf
echo '    <FilesMatch "\.php$">' >> /usr/local/etc/apache24/Includes/php.conf
echo '        SetHandler application/x-httpd-php' >> /usr/local/etc/apache24/Includes/php.conf
echo '    </FilesMatch>' >> /usr/local/etc/apache24/Includes/php.conf
echo '    <FilesMatch "\.phps$">' >> /usr/local/etc/apache24/Includes/php.conf
echo '        SetHandler application/x-httpd-php-source' >> /usr/local/etc/apache24/Includes/php.conf
echo '    </FilesMatch>' >> /usr/local/etc/apache24/Includes/php.conf
echo '</IfModule>' >> /usr/local/etc/apache24/Includes/php.conf

# Is this next step even needed anymore? If so, use sed command for this.

#echo -e "${msg} Find: ${qry}DirectoryIndex index.html${nc}"
#echo -e "${msg} and add ${qry}index.php${msg} to the end of that line${nc}"
#echo -e "${msg} It should then look like this:${nc}"
#echo -e "${qry}    DirectoryIndex index.html index.php${nc}"
#echo -e "${msg} Once you're done, press Ctrl+X then Y then Enter${nc}"

# nano /usr/local/etc/apache24/httpd.conf

# Adding stuff to above file to get phpmyadmin working.

echo '<FilesMatch "\.php$">' >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php' >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>' >> /usr/local/etc/apache24/httpd.conf
echo '<FilesMatch "\.phps$">' >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php-source' >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>' >> /usr/local/etc/apache24/httpd.conf
echo ' ' >> /usr/local/etc/apache24/httpd.conf
echo 'Alias /phpMyAdmin "/usr/local/www/phpMyAdmin"' >> /usr/local/etc/apache24/httpd.conf
echo ' ' >> /usr/local/etc/apache24/httpd.conf
echo '<Directory "/usr/local/www/phpMyAdmin">' >> /usr/local/etc/apache24/httpd.conf
echo 'Options None' >> /usr/local/etc/apache24/httpd.conf
echo 'AllowOverride None' >> /usr/local/etc/apache24/httpd.conf
echo 'Require all granted' >> /usr/local/etc/apache24/httpd.conf
echo '</Directory>' >> /usr/local/etc/apache24/httpd.conf

service apache24 restart

# -------------------------------------------------------
# phpMyAdmin

echo " "
echo -e "${sep}"
echo -e "${msg}   Now for phpMyAdmin${nc}"
echo -e "${msg}   This may seem confusing but follow the steps closely${nc}"
echo -e "${msg}   and you shouldn't run in to any issues!${nc}"
echo -e "${sep}"
echo " "

phpmyadmin

# -------------------------------------------------------
# Now restart Apache, MySQL too for good measure.

echo " "
echo -e "${sep}"
echo -e "${msg}   Last step! Restart apache and mysql.${nc}"
echo -e "${msg}   Reminder: You can safely ignore the AH00557 & AH00558 errors.${nc}"
echo -e "${sep}"
echo " "

service apache24 restart
service mysql-server restart

echo " "
echo -e "${sep}"
echo -e "${msg} It looks like we finished here!!! NICE${nc}"
echo -e "${msg} Now when you have an app that requires a mysql${nc}"
echo -e "${msg} you can use this jails ip in the host setting${nc}"
echo " "
echo -e "${msg} You can also head to ${url}http://yourjailip/phpMyAdmin${nc}"
echo -e "${msg} enter root for the username and use the password you set earlier${nc}"
echo -e "${msg} to easily create/modify/etc. your new mysql database!${nc}"
echo " "
echo -e " More information will be added to this script later"
echo -e " And will also be added to a forum post somewhere."
echo " "
echo -e "${msg} You can get in touch with me any of the ways listed here:${nc}"
echo -e "${url} http://vengefulsyndicate.com/about-us${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### OWNCLOUD INSTALL

install.owncloud ()
{

confirm ()
{
# Confirm with the user
read -r -p "   Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Great! Moving on..${nc}"
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt}Stopping script..${nc}"
              echo " "
              exit
              ;;
esac
}

setconfig ()
{
read -r -p " Did you modify the script before running? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY])
            echo " No need to do anything here then${nc}"
            ;;
        *)
            echo " "
            echo -e "${msg} Set your IP. MUST MATCH YOUR JAIL IP!${nc}"
            echo -e "${qry} Example:"
            echo -e "${url} 192.168.1.200${nc}"
            echo " "
            echo "Server IP:"
            read oc_server_ip
            echo " "
            echo -e "${msg} Set your Port (Default [81] is fine)${nc}"
            echo -e "${qry} Example:"
            echo -e "${url} 81${nc}"
            echo " "
            echo "Server Port:"
            read oc_server_port
            echo " "
            echo -e "${msg} ownCloud version to install${nc}"
            echo -e "${qry} Example:"
            echo -e "${url} 9.0.0${nc}"
            echo " "
            echo "ownCloud Version:"
            read oc_server_ver
            ;;
    esac
}

trusteddomain.error ()
{
# Confirm with the user
echo " "
echo -e "${emp} Please finish the owncloud setup before continuing${nc}"
echo -e "${msg} Head to ${url}https://$cloud_server_ip:$cloud_server_port ${msg}to do this.${nc}"
echo -e "${msg} Fill out the page you are presented with and hit finish${nc}"
echo " "
echo -e "${msg} Admin username & password = whatever you choose${nc}"
echo " "
echo -e "${emp} Make sure you click 'Storage & database'${nc}"
echo " "
echo -e "${msg} Database user = ${qry}root${nc} | Database password = ${nc}"
echo -e "${msg} the ${qry}mysql password${msg} you chose earlier during the script.${nc}"
echo -e "${msg} Database name = your choice (just ${qry}owncloud${msg} is fine)${nc}"
echo " "
echo -e "${inf} You can always perform this next step later from the menu but it's best to do${nc}"
echo -e "${inf} it now if your installing version 9.0.0 or above (8.x.x shouln't need this)${nc}"
echo " "
read -r -p "    Once the page reloads, do you have a 'untrusted domain' warning? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, let's fix that.
              echo " "
              echo -e "${url} Doing some last second changes to fix that..${nc}"
              echo " "
              # Prevent "Trusted Domain" error
              echo "    '${server_ip}'," >> /usr/local/www/owncloud/config/trusted.txt
              cat "/usr/local/www/owncloud/config/old_config.bak" | \
                sed '8r /usr/local/www/owncloud/config/trusted.txt' > \
                "/usr/local/www/owncloud/config/config.php"
              rm /usr/local/www/owncloud/config/trusted.txt
              echo -e " Done, continuing with the rest of the script"
               ;;
    *)
              # If no, just continue like normal.
              echo " "
              echo -e "${qry} Great!, no need to do anything, continuing with script..${nc}"
              echo " "
              ;;
esac
}

echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the ownCloud installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with the config!!${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Let's install all the requirements${nc}"
echo -e "${sep}"
echo " "

echo "If you get a question regarding package management tool, answer yes"
# Install packages
pkg install -y lighttpd php56-openssl php56-ctype php56-curl php56-dom php56-fileinfo php56-filter php56-gd php56-hash php56-iconv php56-json php56-mbstring php56-mysql php56-pdo php56-pdo_mysql php56-pdo_sqlite php56-session php56-simplexml php56-sqlite3 php56-xml php56-xmlrpc php56-xmlwriter php56-xmlreader php56-gettext php56-mcrypt php56-zip php56-zlib php56-posix mp3info mysql56-server pecl-apcu

echo " "
echo -e "${sep}"
echo -e "${msg} Packages installed - now configuring MySQL${nc}"
echo -e "${sep}"
echo " "

echo 'mysql_enable="YES"' >> /etc/rc.conf
echo '[mysqld]' >> /var/db/mysql/my.cnf
echo 'skip-networking' >> /var/db/mysql/my.cnf

# Start MySQL Server
/usr/local/etc/rc.d/mysql-server start

echo " "
echo -e "${sep}"
echo -e "${msg} Securing the install. Default root password is blank,${nc}"
echo -e "${msg} you want to provide a strong root password, remove the${nc}"
echo -e "${msg} anonymous accounts, disallow remote root access,${nc}"
echo -e "${msg} remove the test database, and reload privilege tables${nc}"
echo -e "${sep}"
echo " "

mysql_secure_installation

echo " "
echo -e "${sep}"
echo -e "${msg} Done hardening MySQL - Performing key operations now${nc}"
echo -e "${sep}"
echo " "

cd ~
openssl genrsa -des3 -out server.key 1024

echo " "
echo -e "${sep}"
echo -e "${msg} Removing password from key${nc}"
echo -e "${sep}"
echo " "

openssl rsa -in server.key -out no.pwd.server.key

echo " "
echo -e "${sep}"
echo -e "${msg} Creating cert request. The Common Name should match${nc}"
echo -e "${msg} the URL you want to use${nc}"
echo -e "${sep}"
echo " "

openssl req -new -key no.pwd.server.key -out server.csr

echo " "
echo -e "${sep}"
echo -e "${msg} Creating cert & pem file & moving to proper location${nc}"
echo -e "${sep}"
echo " "

openssl x509 -req -days 365 -in /root/server.csr -signkey /root/no.pwd.server.key -out /root/server.crt
cat no.pwd.server.key server.crt > server.pem
mkdir /usr/local/etc/lighttpd/ssl
cp server.crt /usr/local/etc/lighttpd/ssl
chown -R www:www /usr/local/etc/lighttpd/ssl/
chmod 0600 server.pem

echo " "
echo -e "${sep}"
echo -e "${msg} Creating backup of lighttpd config${nc}"
echo -e "${sep}"
echo " "

cp /usr/local/etc/lighttpd/lighttpd.conf /usr/local/etc/lighttpd/old_config.bak

echo " "
echo -e "${sep}"
echo -e "${msg} Modifying lighttpd.conf file${nc}"
echo -e "${sep}"
echo " "

cat "/usr/local/etc/lighttpd/old_config.bak" | \
	sed -r '/^var.server_root/s|"(.*)"|"/usr/local/www/owncloud"|' | \
	sed -r '/^server.use-ipv6/s|"(.*)"|"disable"|' | \
	sed -r '/^server.document-root/s|"(.*)"|"/usr/local/www/owncloud"|' | \
	sed -r '/^#server.bind/s|(.*)|server.bind = "'"${server_ip}"'"|' | \
	sed -r '/^\$SERVER\["socket"\]/s|"0.0.0.0:80"|"'"${server_ip}"':'"${server_port}"'"|' | \
	sed -r '/^server.port/s|(.*)|server.port = '"${server_port}"'|' > \
	"/usr/local/etc/lighttpd/lighttpd.conf"

echo " "
echo -e "${sep}"
echo -e "${msg} Adding stuff to lighttpd.conf file${nc}"
echo -e "${sep}"
echo " "

echo 'ssl.engine = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.pemfile = "/root/server.pem"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.ca-file = "/usr/local/etc/lighttpd/ssl/server.crt"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.cipher-list  = "ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4-SHA:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.honor-cipher-order = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.disable-client-renegotiation = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["url"] =~ "^/data/" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'url.access-deny = ("")' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["url"] =~ "^($|/)" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'dir-listing.activate = "disable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'cgi.assign = ( ".php" => "/usr/local/bin/php-cgi" )' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'server.modules += ( "mod_setenv" )' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["scheme"] == "https" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '    setenv.add-response-header  = ( "Strict-Transport-Security" => "max-age=15768000")' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Enabling the fastcgi module${nc}"
echo -e "${sep}"
echo " "

cp /usr/local/etc/lighttpd/modules.conf /usr/local/etc/lighttpd/old_modules.bak
cat "/usr/local/etc/lighttpd/old_modules.bak" | \
	sed -r '/^#include "conf.d\/fastcgi.conf"/s|#||' > \
	"/usr/local/etc/lighttpd/modules.conf"

echo " "
echo -e "${sep}"
echo -e "${msg} Adding stuff to fastcgi.conf file${nc}"
echo -e "${sep}"
echo " "
echo 'fastcgi.server = ( ".php" =>' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '((' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"socket" => "/tmp/php.socket",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"bin-path" => "/usr/local/bin/php-cgi",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"allow-x-send-file" => "enable",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"bin-environment" => (' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"MOD_X_SENDFILE2_ENABLED" => "1",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"PHP_FCGI_CHILDREN" => "16",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"PHP_FCGI_MAX_REQUESTS" => "10000"' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '),' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"min-procs" => 1,' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"max-procs" => 1,' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"idle-timeout" => 20' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '))' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo ' )' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Obtaining corrected MIME.conf file for lighttpd to use${nc}"
echo -e "${sep}"
echo " "

mv /usr/local/etc/lighttpd/conf.d/mime.conf /usr/local/etc/lighttpd/conf.d/mime_conf.bak
fetch -o /usr/local/etc/lighttpd/conf.d/mime.conf http://www.xenopsyche.com/mkempe/oc/mime.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Creating www folder and downloading ownCloud${nc}"
echo -e "${sep}"
echo " "

mkdir -p /usr/local/www
# Get ownCloud, extract it, copy it to the webserver
# and have the jail assign proper permissions
cd "/tmp"
fetch "https://download.owncloud.org/community/owncloud-${owncloud_version}.tar.bz2"
tar xf "owncloud-${owncloud_version}.tar.bz2" -C /usr/local/www
chown -R www:www /usr/local/www/

echo " "
echo -e "${sep}"
echo -e "${msg} Adding lighttpd to rc.conf${nc}"
echo -e "${sep}"
echo " "

echo 'lighttpd_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg}  Done, lighttpd should start up automatically!${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Attempting to start webserver.${nc}"
echo -e "${msg} If you get a Cannot 'start' lighttpd error, add:${nc}"
echo -e "\033[1;33m     lighttpd_enable="YES"${nc}   to   \033[1;36m/etc/rc.conf${nc}"
echo -e "${msg} Command being run here is:"
echo -e "${cmd}     /usr/local/etc/rc.d/lighttpd start${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/lighttpd start

echo " "
echo -e "${sep}"
echo -e "${msg} Now to finish owncloud setup${nc}"
echo -e "${sep}"
echo " "

trusteddomain.error

echo " "
echo -e "${sep}"
echo -e "${msg} It looks like we finished here!!! NICE${nc}"
echo -e "${msg} Now you can head to ${url}https://$cloud_server_ip:$cloud_server_port${nc}"
echo -e "${msg} to use your owncloud whenever you wish!${nc}"
echo " "
echo " "
echo " "
echo -e "${emp} Memory Caching ${msg}is an optional feature that is not enabled by default${nc}"
echo -e "${msg} This is entirely optional and any messages about it can be safely ignored.${nc}"
echo -e "${msg} If you wish to enable it, head to the owncloud 'Other Options' menu.${nc}"
echo " "
echo " "
echo " "
echo -e "${msg} If you need any help, visit the forums here:${nc}"
echo -e "${url} http://forums.nas4free.org/viewtopic.php?f=79&t=9383${nc}"
echo -e "${msg} Or jump on my Discord server${nc}"
echo -e "${url} https://discord.gg/0bXnhqvo189oM8Cr${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### NEXTCLOUD INSTALL

install.nextcloud ()
{

nextcloud.continue ()
{
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
read -r -p " " response
case "$response" in
    *)
              ;;
esac
}

nextcloud.options ()
{
echo " "
echo -e "${msg} What is your jails IP?${nc}"
echo -e "${alt} This MUST be your jails IP${nc}"
printf "${inf} Detected IP: ${nc}" ; ifconfig | grep -e "inet" -e "addr:" | grep -v "inet6" | grep -v "127.0.0.1" | head -n 1 | awk '{print $2}'
echo " "
printf "${emp} Set IP: ${nc}" ; read userselected_ip
echo -e "${fin}    IP set to: ${msg}${userselected_ip}${nc}"
echo " "
echo -e "${msg} What port do you want to run it on?${nc}"
echo -e "${inf}    Recommended: ${msg}81${nc}"
echo " "
printf "${emp} Set Port: ${nc}" ; read userselected_port
echo -e "${fin}    Port set to: ${msg}${userselected_port}${nc}"
echo " "
echo -e "${msg} What version would you like to install${nc}"
echo -e "${inf}    Tested & Confirmed Working: 11.0.0"
echo " "
printf "${emp} Set Version: ${nc}" ; read -r userselected_version
echo -e "${fin}    Version set to: ${msg}${userselected_version}${nc}"
echo " "
nextcloud.continue
#echo " "
#echo -e "${emp} Only do so if you know what you're doing!${nc}"
#echo " Default Database name: nextcloud"
#read -r -p " Set Database name to something else? [y/N] " response
#    case $response in
#        [yY][eE][sS]|[yY])
#			echo " "
#			echo -e "${msg} What port do you want to run it on?${nc}"
#			echo "Recommended: 81"
#			echo " "
#			echo " Input Port:"
#			read userselected_dbname
#			;;
#		*)
#			database_name="nextcloud"
#			;;
#	esac
}

echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the NextCloud installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   First, some configuration${nc}"
echo -e "${sep}"
echo " "

nextcloud.options

echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get to installing some stuff!!${nc}"
echo -e "${sep}"
echo " "

# Install packages
pkg install -y lighttpd php70-openssl php70-ctype php70-curl php70-dom php70-fileinfo php70-filter php70-gd php70-hash php70-iconv php70-json php70-mbstring php70-pdo php70-pdo_mysql php70-pdo_sqlite php70-session php70-simplexml php70-sqlite3 php70-xml php70-xmlrpc php70-xmlwriter php70-xmlreader php70-gettext php70-mcrypt php70-zip php70-zlib php70-posix mp3info mysql56-server
# php70-APCu - No longer in repositories
# Alternative
# php70-memcache php70-memcached

echo " "
echo -e "${sep}"
echo -e "${msg} Packages installed - now configuring MySQL${nc}"
echo -e "${sep}"
echo " "

echo 'mysql_enable="YES"' >> /etc/rc.conf
echo '[mysqld]' >> /var/db/mysql/my.cnf
echo 'skip-networking' >> /var/db/mysql/my.cnf

# Start MySQL Server
/usr/local/etc/rc.d/mysql-server start

echo " "
echo -e "${sep}"
echo -e "${msg} Creating database for nextcloud${nc}"
echo -e "${sep}"
echo " "

mysql -u root -e "create database ${database_name}";
echo -e "${msg} Database was created: ${database_name}.${nc}"

echo " "
echo -e "${sep}"
echo -e "${msg} Securing the install. Default root password is blank,${nc}"
echo -e "${msg} you want to provide a strong root password, remove the${nc}"
echo -e "${msg} anonymous accounts, disallow remote root access,${nc}"
echo -e "${msg} remove the test database, and reload privilege tables${nc}"
echo -e "${sep}"
echo " "

mysql_secure_installation

echo " "
echo -e "${sep}"
echo -e "${msg} Done hardening MySQL - Performing key operations now${nc}"
echo -e "${sep}"
echo " "

cd ~
openssl genrsa -des3 -out server.key 1024

echo " "
echo -e "${sep}"
echo -e "${msg} Removing password from key${nc}"
echo -e "${sep}"
echo " "

openssl rsa -in server.key -out no.pwd.server.key

echo " "
echo -e "${sep}"
echo -e "${msg} Creating cert request. The Common Name should match${nc}"
echo -e "${msg} the URL you want to use${nc}"
echo -e "${sep}"
echo " "

openssl req -new -key no.pwd.server.key -out server.csr

echo " "
echo -e "${sep}"
echo -e "${msg} Creating cert & pem file & moving to proper location${nc}"
echo -e "${sep}"
echo " "

openssl x509 -req -days 365 -in /root/server.csr -signkey /root/no.pwd.server.key -out /root/server.crt
cat no.pwd.server.key server.crt > server.pem
mkdir /usr/local/etc/lighttpd/ssl
cp server.crt /usr/local/etc/lighttpd/ssl
chown -R www:www /usr/local/etc/lighttpd/ssl/
chmod 0600 server.pem

echo " "
echo -e "${sep}"
echo -e "${msg} Creating backup of lighttpd config${nc}"
echo -e "${sep}"
echo " "

cp /usr/local/etc/lighttpd/lighttpd.conf /usr/local/etc/lighttpd/old_config.bak

echo " "
echo -e "${sep}"
echo -e "${msg} Modifying lighttpd.conf file${nc}"
echo -e "${sep}"
echo " "

cat "/usr/local/etc/lighttpd/old_config.bak" | \
	sed -r '/^var.server_root/s|"(.*)"|"/usr/local/www/nextcloud"|' | \
	sed -r '/^server.use-ipv6/s|"(.*)"|"disable"|' | \
	sed -r '/^server.document-root/s|"(.*)"|"/usr/local/www/nextcloud"|' | \
	sed -r '/^#server.bind/s|(.*)|server.bind = "'"${userselected_ip}"'"|' | \
	sed -r '/^\$SERVER\["socket"\]/s|"0.0.0.0:80"|"'"${userselected_ip}"':'"${userselected_port}"'"|' | \
	sed -r '/^server.port/s|(.*)|server.port = '"${userselected_port}"'|' > \
	"/usr/local/etc/lighttpd/lighttpd.conf"

echo " "
echo -e "${sep}"
echo -e "${msg} Adding stuff to lighttpd.conf file${nc}"
echo -e "${sep}"
echo " "

echo 'ssl.engine = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.pemfile = "/root/server.pem"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.ca-file = "/usr/local/etc/lighttpd/ssl/server.crt"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.cipher-list  = "ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4-SHA:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.honor-cipher-order = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'ssl.disable-client-renegotiation = "enable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["url"] =~ "^/data/" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'url.access-deny = ("")' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["url"] =~ "^($|/)" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'dir-listing.activate = "disable"' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'cgi.assign = ( ".php" => "/usr/local/bin/php-cgi" )' >> /usr/local/etc/lighttpd/lighttpd.conf
echo 'server.modules += ( "mod_setenv" )' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '$HTTP["scheme"] == "https" {' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '    setenv.add-response-header  = ( "Strict-Transport-Security" => "max-age=15768000")' >> /usr/local/etc/lighttpd/lighttpd.conf
echo '}' >> /usr/local/etc/lighttpd/lighttpd.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Enabling the fastcgi module${nc}"
echo -e "${sep}"
echo " "

cp /usr/local/etc/lighttpd/modules.conf /usr/local/etc/lighttpd/old_modules.bak
cat "/usr/local/etc/lighttpd/old_modules.bak" | \
	sed -r '/^#include "conf.d\/fastcgi.conf"/s|#||' > \
	"/usr/local/etc/lighttpd/modules.conf"

echo " "
echo -e "${sep}"
echo -e "${msg} Adding stuff to fastcgi.conf file${nc}"
echo -e "${sep}"
echo " "
echo 'fastcgi.server = ( ".php" =>' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '((' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"socket" => "/tmp/php.socket",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"bin-path" => "/usr/local/bin/php-cgi",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"allow-x-send-file" => "enable",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"bin-environment" => (' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"MOD_X_SENDFILE2_ENABLED" => "1",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"PHP_FCGI_CHILDREN" => "16",' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"PHP_FCGI_MAX_REQUESTS" => "10000"' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '),' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"min-procs" => 1,' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"max-procs" => 1,' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '"idle-timeout" => 20' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo '))' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf
echo ' )' >> /usr/local/etc/lighttpd/conf.d/fastcgi.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Obtaining corrected MIME.conf file for lighttpd to use${nc}"
echo -e "${sep}"
echo " "

mv /usr/local/etc/lighttpd/conf.d/mime.conf /usr/local/etc/lighttpd/conf.d/mime_conf.bak
fetch -o /usr/local/etc/lighttpd/conf.d/mime.conf http://www.xenopsyche.com/mkempe/oc/mime.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Modifying php.ini${nc}"
echo -e "${sep}"
echo " "

echo always_populate_raw_post_data = -1 > /usr/local/etc/php.ini

echo " "
echo -e "${sep}"
echo -e "${msg} Creating www folder and downloading NextCloud${nc}"
echo -e "${sep}"
echo " "

mkdir -p /usr/local/www
# Get NextCloud, extract it, copy it to the webserver
# and have the jail assign proper permissions
cd "/tmp"
fetch "https://download.nextcloud.com/server/releases/nextcloud-${userselected_version}.tar.bz2"
tar xf "nextcloud-${userselected_version}.tar.bz2" -C /usr/local/www
chown -R www:www /usr/local/www/

echo " "
echo -e "${sep}"
echo -e "${msg} Adding lighttpd to rc.conf${nc}"
echo -e "${sep}"
echo " "

echo 'lighttpd_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg}  Done, lighttpd should start up automatically!${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Attempting to start webserver.${nc}"
echo -e "${msg} If you get a Cannot 'start' lighttpd error, add:${nc}"
echo -e "\033[1;33m     lighttpd_enable="YES"${nc}   to   \033[1;36m/etc/rc.conf${nc}"
echo -e "${msg} Command being run here is:"
echo -e "${cmd}     /usr/local/etc/rc.d/lighttpd start${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/lighttpd start

#echo " "
#echo -e "${sep}"
#echo -e "${msg} Enable Memory Caching${nc}"
#echo -e "${sep}"
#echo " "

#TODO: Enable Memory Caching by default
#echo "  'memcache.local' => '\OC\Memcache\APCu'," >> #/usr/local/www/nextcloud/config/memcache.txt
#cp /usr/local/www/nextcloud/config/config.php /usr/local/www/nextcloud/config/old_config.bak
#cat "/usr/local/www/nextcloud/config/old_config.bak" | \
#	sed '21r /usr/local/www/nextcloud/config/memcache.txt' > \
#    "/usr/local/www/nextcloud/config/config.php"
#rm /usr/local/www/nextcloud/config/memcache.txt

echo " "
echo -e "${sep}"
echo -e "${msg} Now to finish nextcloud setup${nc}"
echo -e "${sep}"
echo " "



echo " "
echo -e "${sep}"
echo -e "${msg} It looks like we finished here!!! NICE${nc}"
echo -e "${msg} Now you can head to ${url}https://$userselected_ip:$userselected_port${nc}"
echo -e "${msg} to use your nextcloud whenever you wish!${nc}"
echo " "
echo " "
echo " "
echo -e "${emp} Memory Caching ${msg}is an optional feature that is not enabled by default${nc}"
echo -e "${msg} This is entirely optional and any messages about it can be safely ignored.${nc}"
echo -e "${msg} If you wish to enable it, you can do so via the 'Other Options' menu.${nc}"
echo " "
echo " "
echo " "
echo -e "${msg} If you need any help, visit the forums here:${nc}"
echo -e "${url} http://forums.nas4free.org/viewtopic.php?f=79&t=9383${nc}"
echo -e "${msg} Or jump on my Discord server${nc}"
echo -e "${url} https://discord.gg/0bXnhqvo189oM8Cr${nc}"
echo -e "${sep}"
echo " "

nextcloud.continue

echo " "
}

#------------------------------------------------------------------------------#
### PYDIO INSTALL

install.pydio ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Pydio Install Script${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with installing the prerequisites${nc}"
echo -e "${sep}"
echo " "

pkg install nginx php70 php70-extensions php70-curl php70-gd php70-imap php70-mbstring php70-mcrypt php70-mysqli php70-openssl php70-pdo_mysql php70-zip php70-zlib mysql57-server

echo 'nginx_enable="YES"' >> /etc/rc.conf
echo 'php_fpm_enable="YES"' >> /etc/rc.conf
echo 'mysql_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg}   Packages installed, configuring mysql${nc}"
echo -e "${sep}"
echo " "

#touch /usr/local/etc/my.cnf
echo '# The MySQL server configuration' >> /var/db/mysql/my.cnf
echo '[mysqld]' >> /var/db/mysql/my.cnf
echo 'socket          = /tmp/mysql.sock' >> /var/db/mysql/my.cnf
echo '' >> /var/db/mysql/my.cnf
echo "# Don't listen on a TCP/IP port at all." >> /var/db/mysql/my.cnf
echo 'skip-networking' >> /var/db/mysql/my.cnf
echo 'skip-name-resolve' >> /var/db/mysql/my.cnf
echo '' >> /var/db/mysql/my.cnf
echo '#Expire binary logs after one day:' >> /var/db/mysql/my.cnf
echo 'expire_logs_days = 1' >> /var/db/mysql/my.cnf

service mysql-server start

mysql_secure_installation

#mysql -u root -e "create database ${pydio_database_name}";
mysql -u root -e "create database pydio";

# SSL Certificates setup
#cd /usr/local/etc/nginx
#openssl genrsa -des3 -out server.key 2048
#openssl req -new -key server.key -out server.csr
#openssl x509 -req -days 3650 -in server.csr -signkey server.key -out ssl-bundle.crt
#cp server.key server.key.orig
#openssl rsa -in server.key.orig -out server.key

cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini

service php-fpm start

fetch "https://download.pydio.com/pub/core/archives/pydio-core-7.0.3.tar.gz"
tar -xzvf pydio-*

mv pydio-core-5.x.x /usr/local/www/pydio

chown -R www:www /usr/local/www/pydio
chmod -R 770 /usr/local/www/pydio

service nginx start
}

#------------------------------------------------------------------------------#
### EMBY SERVER INSTALL

install.emby ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Emby Install Script${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with installing Emby from packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y emby-server

echo " "
echo -e "${sep}"
echo -e "${msg}   Enable automatic startup of Emby Server${nc}"
echo -e "${sep}"
echo " "

sysrc emby_server_enable="YES"

echo " "
echo -e "${sep}"
echo -e "${msg}   Start the Emby Server${nc}"
echo -e "${sep}"
echo " "

service emby-server start

echo " "
echo -e "${sep}"
echo -e "${msg} Using a web browser, head to ${url}yourjailip:8096${nc}"
echo -e "${msg} to finish setting up your Emby server${nc}"
echo -e " "
echo -e "${msg} You should also recompile ffmpeg+imagemagick${nc}"
echo -e "${msg} This option can be found in the Emby submenu of this script${nc}"
echo -e "${msg} It's also advised to run the update option after a clean install.${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### PLEX SERVER INSTALL

install.plex ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Plex Install Script${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with downloading the install script${nc}"
echo -e "${sep}"
echo " "

cd ${myappsdir}
fetch https://raw.githubusercontent.com/JRGTH/nas4free-plex-extension/master/plex-install.sh && chmod +x plex-install.sh && ./plex-install.sh

}

#------------------------------------------------------------------------------#
### OMBI INSTALL

install.ombi ()
{

ombi.continue ()
{
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
read -r -p " " response
case "$response" in
    *)
              echo " "
              ;;
esac
}

echo " "
echo -e "${sep}"
echo -e "${msg}   Ombi Install Script${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with some required packages${nc}"
echo -e "${sep}"
echo " "

#Install packages
pkg install wget mono screen unzip nano git sqlite3

# Set default editor
setenv EDITOR /usr/local/bin/nano

echo " "
echo -e "${sep}"
echo -e "${msg}   Download Ombi${nc}"
echo -e "${sep}"
echo " "

# Download Ombi
wget -O /tmp/Ombi.zip https://github.com/tidusjar/Ombi/releases/download/v2.2.1/Ombi.zip

echo " "
echo -e "${sep}"
echo -e "${msg}   Extract Ombi${nc}"
echo -e "${sep}"
echo " "

# Unzip Ombi
unzip /tmp/Ombi.zip -d /usr/local/share/
# Move Ombi
mv /usr/local/share/Release /usr/local/share/ombi/

echo " "
echo -e "${sep}"
echo -e "${msg}   Create startup file${nc}"
echo -e "${sep}"
echo " "

# Create ombi file
touch /usr/local/bin/ombi
echo "#!/bin/sh" > /usr/local/bin/ombi
echo "cd /usr/local/share/ombi/" > /usr/local/bin/ombi
echo "/usr/local/bin/screen -d -m -S ombi /usr/local/bin/mono /usr/local/share/ombi/Ombi.exe" > /usr/local/bin/ombi
chmod 775 /usr/local/bin/ombi

echo " "
echo -e "${sep}"
echo -e "${msg}   Add these lines to crontab${nc}"
echo -e "${msg}   Copy the lines before pressing Enter then paste in to crontab${nc}"
echo -e "${msg}   Close crontab afterwards with the following combination of keys${nc}"
echo -e "${msg}   Ctrl+X then Y then Enter${nc}"
echo -e "${sep}"
echo " "

# Add to crontab
echo "SHELL=/bin/sh"
echo "PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin"
echo "#start ombi"
echo "@reboot /usr/local/bin/ombi"
echo " "

ombi.continue

crontab -e

echo " "
echo -e "${sep}"
echo -e "${msg}   Restart jail and visit http://jailip:3579${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### SUBSONIC INSTALL

install.subsonic ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the Subsonic installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y subsonic-standalone
pkg install -y xtrans xproto xextproto javavmwrapper flac openjdk8 ffmpeg
pkg install -y https://github.com/Nozza-VS/misc-code/blob/master/NAS4Free/Streaming/Subsonic/lame.tbz

echo " "
echo -e "${sep}"
echo -e "${msg} Create folders for Subsonic${nc}"
echo -e "${sep}"
echo " "

mkdir -p /var/subsonic/transcode
mkdir /var/subsonic/standalone
cp /usr/local/bin/lame /var/subsonic/transcode/
cp /usr/local/bin/flac /var/subsonic/transcode/
cp /usr/local/bin/ffmpeg /var/subsonic/transcode/
cd /tmp/
# Download Subsonic from sourceforge & extract
fetch http://heanet.dl.sourceforge.net/project/subsonic/subsonic/${subsonic_ver}/subsonic-${subsonic_ver}-standalone.tar.gz
tar xvzf /tmp/subsonic-${subsonic_ver}-standalone.tar.gz -C /var/subsonic/standalone
chmod 777 *.*

echo " "
echo -e "${sep}"
echo -e "${msg} Now let's make sure subsonic starts.${nc}"
echo -e "${msg} You can manually do this with:${nc}"
echo -e "${cmd}    sh /var/subsonic/standalone/subsonic.sh${nc}"
echo -e "${msg} For now, this script will do it automatically.${nc}"
echo -e "${sep}"
echo " "

sh /var/subsonic/standalone/subsonic.sh

echo " "
echo -e "${sep}"
echo -e "${msg} If subsonic started as it should you can connect to it via the browser at the${nc}"
echo -e "${msg} following adress: Jail-IP:4040, default username is admin, and password admin.${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo " That should be it!"
echo " Enjoy your Subsonic server!"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### MADSONIC INSTALL

install.madsonic ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the Madsonic installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

#pkg install -y madsonic-jetty
pkg install -y madsonic-standalone

echo " "
echo -e "${sep}"
echo " Adding madsonic to rc.conf"
echo -e "${sep}"
echo " "

echo 'madsonic_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Now let's make sure madsonic starts.${nc}"
echo -e "${msg} You can manually do this with:${nc}"
echo -e "${cmd}    /usr/local/etc/madsonic start${nc}"
echo -e "${msg} For now, this script will do it automatically.${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/madsonic start

echo " "
echo -e "${sep}"
echo -e "${msg} If madsonic started as it should you can connect to it via your${nc}"
echo -e "${msg} browser with following adress: Jail-IP:4040${nc}"
echo -e "${msg} Default username is admin, and password admin.${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo " That should be it!"
echo " Enjoy your Subsonic server!"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### SONARR INSTALL

install.sonarr ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Sonarr Install Script${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with installing Sonarr from packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y sonarr mediainfo

echo " "
echo -e "${sep}"
echo -e "${msg}   Start Sonarr${nc}"
echo -e "${sep}"
echo " "

service sonarr start

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}yourjailip:8989${nc}"
echo -e "${msg} to finish setting up Sonarr${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### COUCHPOTATO INSTALL

install.couchpotato ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   CouchPotato Installer${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's install required packages first${nc}"
echo -e "${sep}"
echo " "

pkg install python py27-sqlite3 fpc-libcurl docbook-xml git-lite

echo " "
echo -e "${sep}"
echo -e "${msg} Grab CouchPotato from github${nc}"
echo -e "${msg} CouchPotato will be installed to:${nc}"
echo -e "${inf}    /usr/local/CouchPotato${nc}"
echo -e "${sep}"
echo " "

#If running as root, expects python here
ln -s /usr/local/bin/python /usr/bin/python
git clone https://github.com/CouchPotato/CouchPotatoServer.git /usr/local/CouchPotato

echo " "
echo -e "${sep}"
echo -e "${msg} Copy startup script & make executable${nc}"
echo -e "${sep}"
echo " "

cp CouchPotatoServer/init/freebsd /usr/local/etc/rc.d/couchpotato
chmod +x /usr/local/etc/rc.d/couchpotato
chmod 555 /usr/local/etc/rc.d/couchpotato

echo " "
echo -e "${sep}"
echo -e "${msg} Enable CouchPotato at startup${nc}"
echo -e "${sep}"
echo " "

echo 'couchpotato_enable="YES"' >> /etc/rc.conf

#Read the options at the top of more /usr/local/etc/rc.d/couchpotato
#If not default install, specify options with startup flags in ee /etc/rc.conf
#Finally,

echo " "
echo -e "${sep}"
echo -e "${msg} Start CouchPotato${nc}"
echo -e "${sep}"
echo " "

service couchpotato start

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}yourjailip:5050${nc}"
echo -e "${msg} to finish setting up your CouchPotato server${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Done here!${nc}"
echo -e "${msg} Feel free to visit the project homepage at:${nc}"
echo -e "${url}    https://github.com/CouchPotato/CouchPotatoServer${nc}"
echo -e "${url}    https://couchpota.to${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### WATCHER INSTALL

install.watcher ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Watcher installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg update && pkg upgrade
pkg install git python3 sqlite3

cd /usr/local/
git clone https://github.com/nosmokingbandit/Watcher3.git

echo " "
echo -e "${sep}"
echo -e "${sep} Start watcher${nc}"
echo -e "${sep}"
echo " "

python watcher/watcher.py --daemon --log /var/log/ --db /var/db/watcher.sqlite --pid /var/run/watcher.pid

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}:9090${nc}"
echo -e "${sep}"
echo " "



}

#------------------------------------------------------------------------------#
### RADARR INSTALL

install.radarr ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Radarr installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg update && pkg upgrade
pkg install -y mono mediainfo sqlite3 libgdiplus

cd /usr/local/
fetch https://github.com/Radarr/Radarr/releases/download/latest/Radarr.develop.latest.linux.tar.gz
tar -zxvf Radarr.develop.*.linux.tar.gz
rm Radarr.*.linux.tar.gz
echo "/usr/local/bin/mono /usr/local/Radarr/Radarr.exe" > /etc/rc.d/radarr
chmod 555 /etc/rc.d/radarr
#this is needed for updates within Radarr
ln -s /usr/local/bin/mono /bin

echo " "
echo -e "${sep}"
echo -e "${sep} Start watcher${nc}"
echo -e "${sep}"
echo " "

service radarr start

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}:7878${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### HEADPHONES INSTALL

install.headphones ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Headphones Installer${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's install required packages first${nc}"
echo -e "${sep}"
echo " "

pkg install python py27-sqlite3 fpc-libcurl docbook-xml git-lite ffmpeg flac lame

echo " "
echo -e "${sep}"
echo -e "${msg} Grab Headphones from github${nc}"
echo -e "${msg} Headphones will be installed to:${nc}"
echo -e "${inf}    /usr/local/Headphones${nc}"
echo -e "${sep}"
echo " "

git clone https://github.com/rembo10/headphones.git /usr/local/Headphones

echo " "
echo -e "${sep}"
echo -e "${msg} Fetch Headphones startup script from github${nc}"
echo -e "${sep}"
echo " "

# cp headphones/init-scripts/init.freebsd /usr/local/etc/rc.d/headphones
#Fetch Nozza-VS's startup script instead
fetch --no-verify-peer -o /usr/local/etc/rc.d/headphones "https://raw.githubusercontent.com/Nozza-VS/misc-code/master/NAS4Free/Search Tools/Headphones/headphones-init-script"
#Make startup script executable
chmod 555 /usr/local/etc/rc.d/headphones
chmod +x /usr/local/etc/rc.d/headphones
# Potentially need to modify the line:
#command_args = "- f -p $ {python headphones_pid} $ {} headphones_dir /Headphones.py $ {} headphones_flags --quiet --nolaunch"
# To:
#command_args = "- f -p $ {} headphones_pid python2.7 $ {} headphones_dir /Headphones.py $ {} headphones_flags --quiet --nolaunch"
# Further testing needed, will update my init script if deemed necessary.

echo " "
echo -e "${sep}"
echo -e "${msg} Enable automatic startup at boot for Headphones${nc}"
echo -e "${sep}"
echo " "

echo 'headphones_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Start Headphones${nc}"
echo -e "${sep}"
echo " "

service headphones start

#
echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}jailip:8181${nc}"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Done here!${nc}"
echo -e "${msg} Feel free to visit the project homepage at:${nc}"
#echo -e "${url}    https://gitlab.com/sarakha63/headphones${nc}"
echo -e "${url}    https://github.com/rembo10/headphones${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### THEBRIG EXPERIMENTAL INSTALL

install.thebrig.EXPERIMENTAL ()
{
confirmstorage ()
{
# Confirm with the user
read -r -p "   Correct path? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Great! We'll install thebrig in '${mystorage}/Jails'.${nc}"
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt} This needs to be correct.${nc}"
              echo -e "${alt} Please modify the 'mystorage' at the start of${nc}"
              echo -e "${alt} the script before running this again.${nc}"
              echo " "
              exit
              ;;
esac
}

confirmsuccess ()
{
# Confirm with the user
echo -e "${msg} Head to your NAS WebGUI - Refresh page if it's already open${nc}"
read -r -p "   Can you seen an 'Extensions' tab with 'TheBrig' listed? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Good! Now follow the How-To for finalizing the setup.${nc}"
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt} Seems this script had an issue somewhere ${nc}"
              echo " "
              exit
              ;;
esac
}

echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to theBrig installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   This should hopefully install TheBrig for you without any problems!${nc}"
echo " "
echo -e "${msg} Let's start with double checking your storage path.${nc}"
echo -e "${msg} Is this the correct path to your mounted storage?${nc}."
echo -e "${qry} ${mystorage} ${nc}."
echo -e "${sep}"
echo -e " "

confirmstorage

echo " "
echo -e "${sep}"
echo -e "${msg} Let's get on with the install.${nc}"
echo -e "${sep}"
echo " "

# Make folder for TheBrig and it's jails to live in
mkdir ${mystorage}/Jails

# Head to the directory we just made
cd ${mystorage}/Jails

# Download the installer
fetch https://raw.githubusercontent.com/fsbruva/thebrig/alcatraz/thebrig_install.sh

# Run the installer
/bin/sh thebrig_install.sh ${mystorage}/Jails

echo " "
echo -e "${sep}"
echo -e "${msg} TheBrig should now be successfully installed${nc}"
echo -e "${sep}"
echo " "

# Confirm with user
confirmsuccess

}



#------------------------------------------------------------------------------#
### OBI INSTALL

install.obi ()
{


echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to OneButtonInstaller... installer!${nc}"
echo -e "${sep}"
echo " "

echo " "

echo " "
echo -e "${sep}"
echo -e "${msg} Let's get on with the install.${nc}"
echo -e "${sep}"
echo " "

fetch https://raw.github.com/crestAT/nas4free-onebuttoninstaller/master/OBI.php && mkdir -p ext/OBI && echo '<a href="OBI.php">OneButtonInstaller</a>' > ext/OBI/menu.inc && echo -e "\nDONE"

echo " "
echo -e "${sep}"
echo -e "${msg} OBI should now be successfully installed${nc}"
echo -e "${msg} Head to your NAS4Free WebGUI and you should find it under${nc}"
echo -e "${msg}    EXTENSIONS | OneButtonInstaller${nc}"
echo -e "${msg} On this page choose where to install it to and hit 'Save'.${nc}"
echo -e "${msg} Now your done and ready to easily install things such as TheBrig!${nc}"
echo -e "${sep}"
echo " "
}


#------------------------------------------------------------------------------#
### HTPC MANAGER INSTALL

install.htpcmanager ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the HTPC installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg update && pkg upgrade
pkg install -y python27 sqlite3 git

echo " "
echo -e "${sep}"
echo -e "${sep} Grab HTPC manager from github${nc}"
echo -e "${sep}"
echo " "

cd /usr/local/
git clone https://github.com/styxit/HTPC-Manager.git

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}:9090${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### ORGANIZR INSTALL

install.organizr ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Organizr installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg update && pkg upgrade
pkg install -y apache24 php56 mod_php56 php56-extensions php56-pdo php56-pdo_sqlite php56-simplexml php56-zip php56-openssl git

echo " "
echo -e "${sep}"
echo -e "${sep} Modify apache${nc}"
echo -e "${sep}"
echo " "

sysrc apache_enable=YES
service apache24 start

echo " "
echo -e "${sep}"
echo -e "${sep} Grab Organizer from github${nc}"
echo -e "${sep}"
echo " "

cd  /usr/local/www/
git clone https://github.com/causefx/Organizr.git

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}/${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### CALIBRE INSTALL

install.calibre ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Calibre installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y nano calibre

# Configure /etc/rc.conf
echo 'calibre_enable="YES"' >> /etc/rc.conf
echo 'calibre_user="root"' >> /etc/rc.conf
echo 'calibre_library="${CALIBRELIBRARYPATH}"' >> /etc/rc.conf

#echo " Modify this file to use root as the user"
#echo "    : ${calibre_user:=root}" #TODO: Use sed for this

nano /usr/local/etc/rc.d/calibre

echo " Start Calibre"
echo " If you want to start it manually without restarting your jail"
calibre-server --with-library="${CALIBRELIBRARYPATH}"

echo " "
echo -e "${sep}"
echo " That should be it!"
echo " Happy reading!!"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### MYLAR INSTALL

install.mylar ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Mylar installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y python27 git py27-cherrypy

cd /usr/local/
git clone https://github.com/evilhero/mylar.git

echo " "
echo -e "${sep}"
echo -e "${msg} Run Mylar${nc}"
echo -e "${sep}"
echo " "

python mylar/mylar.py -d

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}:8090${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### LAZYLIBRARIAN INSTALL

install.lazylibrarian ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the Lazy Librarian installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

pkg update && pkg upgrade
pkg install -y python27 git

cd /usr/local/
git clone https://github.com/DobyTang/LazyLibrarian.git

echo " "
echo -e "${sep}"
echo -e "${msg} Run LazyLibrarian${nc}"
echo -e "${sep}"
echo " "

python LazyLibrarian.py -d

echo " "
echo -e "${sep}"
echo -e "${msg} Open your browser and go to: ${url}http://${jailip}:5299${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### DELUGE INSTALL

install.deluge ()
{
confirm ()
{
# Confirm with the user
read -r -p "   Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e " "
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e " "
              echo " "
              exit
              ;;
esac
}
echo -e "${sep}"
echo -e "     \033[1;37mWelcome to the Deluge setup!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo -e "${emp}   This should be run in host NAS system${nc}"
echo -e "${emp}   If you are inside a jail please answer no${nc}"
echo -e "${emp}   Exit your jail and start again${nc}"
echo " "
continue
echo " "
echo -e "${sep}"
echo -e "${msg} Let's get started with adding a user${nc}"
echo -e "${sep}"
echo " "

pw useradd -n deluge -c "Deluge BitTorrent Client" -s /sbin/nologin -w no

echo " "
echo -e "${sep}"
echo -e "${msg} Now to enter the jail and set up some basic stuff${nc}"
echo -e "${sep}"
echo " "

jexec ${jail} csh
pw useradd -n deluge -u ${user_ID} -c "Deluge BitTorrent Client" -s /sbin/nologin -w no
mkdir -p /home/deluge/.config/deluge
chown -R deluge:deluge /home/deluge/

# Also create folder for plugins
mkdir /.python-eggs
chmod 777 /.python-eggs

echo " "
echo -e "${sep}"
echo -e "${msg} Time to install the packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y deluge nano

# Create file
touch /usr/local/etc/rc.d/deluged

# Tell user to modify certain things before moving on
echo " Change the deluge user in the scripts from the default asjklasdfjklasdf"
echo " to the 'deluge' user created earlier"

# Set permissions
chmod 555 /usr/local/etc/rc.d/deluged

# Set daemon to launch upon jail start
echo 'deluged_enable="YES"' >> /etc/rc.conf
echo 'deluge_web_enabled="YES"' >> /etc/rc.conf
echo 'deluged_user="deluge"' >> /etc/rc.conf

# User to allow remote access to daemon
echo "${deluge_user}:${deluge_user_password}:10" >> /home/deluge/.config/deluge/auth
# Let user know how to add more users to connect to the daemon
echo " ${deluge_user}:${deluge_user_password}:10" >> /home/deluge/.config/deluge/auth
echo " "

# Allow remote connections
echo " Find and change 'allow_remote' from false to true."
echo " Once you are done press Ctrl+X then Y to close and save the file"
echo -e "${emp}   Make sure you read above before continuing${nc}"
continue
nano /home/deluge/.config/deluge/core.conf

# Disable IPV6
echo "Edit /etc/protocols and disable ipv6 by placing '#' in front of ipv6"
echo -e "${emp}   Make sure you read above before continuing${nc}"
continue
nano /etc/protocols

# Start the daemon
/usr/local/etc/rc.d/deluged start
# May have to use this instead:
# /usr/local/etc/rc.d/deluge_web start

echo " Now you should be able to head to http://jailsipaddress:8112 and login"
echo " using the password 'deluge' without the quotes"

echo " "
echo -e "${sep}"
echo " That should be it!"
echo " Happy torrenting!!"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### NZBGET INSTALL

install.nzbget ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the NZBGet installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get right to it and download the package${nc}"
echo -e "${msg}    Will grab ffmpeg as well purely for ffprobe${nc}"
echo -e "${sep}"
echo " "

pkg install -y nzbget ffmpeg

echo " "
echo -e "${sep}"
echo -e "${msg} Copy the default configuration to get the webui working${nc}"
echo -e "${sep}"
echo " "

cp /usr/local/etc/nzbget.conf.sample /usr/local/etc/nzbget.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Enable NZBGet at startup${nc}"
echo -e "${sep}"
echo " "

sysrc 'nzbget_enable=YES'

echo " "
echo -e "${sep}"
echo -e "${msg} Create a temp folder for NZBGet and modify config file${nc}"
echo -e "${msg} to enable the web interface${nc}"
echo -e "${sep}"
echo " "

mkdir -p /downloads/dst
# Need to modify "WebDir=" at line 79 of "/usr/local/etc/nzbget.conf"
# Needs to be "WebDir=/usr/local/share/nzbget/webui"
# Maybe use "sed" command for this which could also eliminate the cp command above

echo " "
echo -e "${sep}"
echo -e "${msg} Start NZBGet${nc}"
echo -e "${sep}"
echo " "

service nzbget start

echo " "
echo -e "${sep}"
echo -e "${msg} Now finish setting it up by opening your web browser and heading to:${nc}"
echo -e "${url}    http://your-jail-ip:6789${nc}"
echo -e "${msg} Default username: nzbget${nc}"
echo -e "${msg} Default password: tegbzn6789${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### SABNZBD INSTALL

install.sabnzbd ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the SABnzbd installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get right to it and download the required packages${nc}"
echo -e "${sep}"
echo " "

pkg install -y python27 py27-sqlite3
pkg install -y py27-pip py27-yenc py27-cheetah py27-openssl py27-feedparser py27-utils par2cmdline-tbb
pkg install -y unrar unzip par2cmdline nano

pip install cryptography --upgrade
pip install --upgrade sabyenc

echo " "
echo -e "${sep}"
echo -e "${msg} Now let's grab SABnzbd itself${nc}"
echo -e "${sep}"
echo " "

cd tmp
#fetch --no-verify-peer -o /tmp/SABnzbd-${sab_ver}-src.tar.gz https://github.com/sabnzbd/sabnzbd/releases/download/${sab_ver}/SABnzbd-${sab_ver}-src.tar.gz
fetch "http://downloads.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${sab_ver}/SABnzbd-${sab_ver}-src.tar.gz"
tar xfz SABnzbd-${sab_ver}-src.tar.gz -C /usr/local
rm SABnzbd-${sab_ver}-src.tar.gz
mv /usr/local/SABnzbd-${sab_ver} /usr/local/Sabnzbd

#ln -s /usr/local/bin/python /usr/bin/python

echo " "
echo -e "${sep}"
echo -e "${msg} Fetch startup script${nc}"
echo -e "${sep}"
echo " "

fetch --no-verify-peer -o /usr/local/etc/rc.d/sabnzbd "https://raw.githubusercontent.com/Nozza-VS/misc-code/master/NAS4Free/Download Tools/SABnzbd/init-script"
chmod 755 /usr/local/etc/rc.d/sabnzbd
chmod +x /usr/local/etc/rc.d/sabnzbd
echo 'sabnzbd_enable="YES"' >> /etc/rc.conf

echo " "
echo -e "${sep}"
echo -e "${msg} Before we are able to run SABnzbd, we need to modify a file${nc}"
echo -e "${msg} Using nano, change the first line '/usr/bin/python'${nc}"
echo -e "${msg} to match the following:${nc}"
echo -e "${cmd}    #!/usr/local/bin/python2.7${nc}"
echo -e "${sep}"
echo " "

nano /usr/local/Sabnzbd/SABnzbd.py
# On the first line, change #!/usr/bin/python to #!/usr/local/bin/python

echo " "
echo -e "${sep}"
echo -e "${msg} Start it up${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/sabnzbd start

echo " "
echo -e "${sep}"
echo -e "${msg} Done! Head to: ${url}yourjailip:8080${nc}"
echo -e "${msg} to finish the setup!${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### NZBHYDRA INSTALL

install.nzbhydra ()
{

echo -e "${sep}"
echo -e "${sep}     Welcome to the NZBHydra installer!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${sep} Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

}

#------------------------------------------------------------------------------#
### WEB SERVER INSTALL

install.webserver ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the MySQL / phpMyAdmin / Apache web server setup!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get started with some packages${nc}"
echo -e "${sep}"
echo " "

# Install packages
pkg install -y mysql56-server phpmyadmin mod_php56 php56-extensions php56-mysql php56-mysqli apache24 nano imagemagick

echo " "
echo -e "${sep}"
echo "Packages installed - now configuring mySQL"
echo -e "${sep}"
echo " "

echo 'mysql_enable="YES"' >> /etc/rc.conf
echo '[mysqld]' >> /var/db/mysql/my.cnf
echo 'skip-networking' >> /var/db/mysql/my.cnf

service mysql-server start
#/usr/local/etc/rc.d/mysql-server start

echo " "
echo -e "${sep}"
echo "Getting ready to secure the install. The root password is blank, "
echo "and you want to provide a strong root password, remove the anonymous accounts"
echo "disallow remote root access, remove the test database, and reload privilege tables"
echo -e "${sep}"
echo " "

mysql_secure_installation
# OR (Less Secure)
# /usr/local/bin/mysqladmin -u root password 'your-password'

echo " "
echo -e "${sep}"
echo -e "${msg}     MySQL done, now to apache${nc}"
echo -e "${sep}"
echo " "

echo 'apache24_enable="YES"' >> /etc/rc.conf
service apache24 start
#/usr/local/etc/rc.d/apache24 start

# Confirm apache is working
echo -e "${emp} Head to your jail ip, blah blah blah${nc}"
confirm

# Copy sample config file which will set php to default settings
cp /usr/local/etc/php.ini-development /usr/local/etc/php.ini

# Configure apache: /usr/local/etc/apache24/httpd.conf
# Modify this line: DirectoryIndex index.html (Line 278)
# To show as: DirectoryIndex index.html index.php
# Restart apache to update changes

# Also add these lines:
#<FilesMatch "\.php$">
#    SetHandler application/x-httpd-php
#</FilesMatch>
#<FilesMatch "\.phps$">
#    SetHandler application/x-httpd-php-source
#</FilesMatch>
#
#Alias /phpmyadmin "/usr/local/www/phpMyAdmin"
#
#<Directory "/usr/local/www/phpMyAdmin">
#Options None
#AllowOverride None
#Require all granted
#</Directory>

service apache24 restart

echo " "
echo -e "${sep}"
echo -e "${msg}     Apache setup done, now to phpmyadmin${nc}"
echo -e "${sep}"
echo " "

# Create basic config & make it writable
mkdir /usr/local/www/phpMyAdmin/config && chmod o+w /usr/local/www/phpMyAdmin/config
chmod o+r /usr/local/www/phpMyAdmin/config.inc.php
echo -e "${emp} Head to http://your-hostname-or-IP-address/phpmyadmin/setup, do stuff there${nc}"
confirm

# Move configuration file up one directory so phpmyadmin can make use of it
mv /usr/local/www/phpMyAdmin/config/config.inc.php /usr/local/www/phpMyAdmin
echo -e "${emp} Double check before proceeding${nc}"
confirm

# Everything should be working so deleting config directory
rm -r /usr/local/www/phpMyAdmin/config

# Secure permissions of config file
chmod o-r /usr/local/www/phpMyAdmin/config.inc.php

# Restart Apache & MySQL servers
service apache24 restart
service mysql-server restart

echo " "
echo -e "${sep}"
echo " That should be it!"
echo " Enjoy your Web server!"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER INSTALL

install.teamspeak3 ()
{

#Update the pkg management system first
pkg update
pkg upgrade

cd /usr/ports/audio/teamspeak3-server
make install clean; rehash

# Tell user to accept defaults
# Tell user to press A when license shows

# fetch scripts from github
# teamspeak3-server init script
# ts3server.sh

echo 'teamspeak_enable="YES"' >> /etc/rc.conf

# Start server
service teamspeak start

# Instruct user to check log files for admin token
cat /var/log/teamspeak/ts3server_*_1.log

# mention port forwarding
# Forward the following ports to your jails IP
# TCP: 10011,30033
# UDP: 9987

}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT HOSTING EDITION INSTALL (MUCH HARDER TO SET UP)

install.teamspeak3bot ()
{

# Update the pkg management system first
pkg update
pkg upgrade

# Install packages
pkg install -y screen openjdk8 wget

# download server bot
wget -r -l1 -np -A "JTS3ServerMod_*.zip" http://www.stefan1200.de/downloads/

# fetch start script from github
# ts3serverbot.sh

# make it executable

# run it

# Instruct user how to make it run at jail startup

}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT HOSTING EDITION INSTALL

install.teamspeak3bothosting ()
{

# Update the pkg management system first
pkg update
pkg upgrade

# Install packages, may not need ALL of these but grabbing them anyway
pkg install -y openjdk8 wget apache24 phpmyadmin mysql56-server php56-mysql php56-mysqli mod_php56 php56-extensions php56-sockets php56-session

echo " "
echo -e "${sep}"
echo -e "${msg} Packages installed - now configuring MySQL${nc}"
echo -e "${sep}"
echo " "

echo 'mysql_enable="YES"' >> /etc/rc.conf
echo '[mysqld]' >> /var/db/mysql/my.cnf
echo 'skip-networking' >> /var/db/mysql/my.cnf

# Start MySQL Server
/usr/local/etc/rc.d/mysql-server start

echo " "
echo -e "${sep}"
echo -e "${msg} Securing the install. Default root password is blank,${nc}"
echo -e "${msg} you want to provide a strong root password, remove the${nc}"
echo -e "${msg} anonymous accounts, disallow remote root access,${nc}"
echo -e "${msg} remove the test database, and reload privilege tables${nc}"
echo -e "${sep}"
echo " "

mysql_secure_installation

# Copy php ini
cp /usr/local/etc/php.ini-development /usr/local/etc/php.ini

# Enable apache server at startup
echo 'apache24_enable="YES"' >> /etc/rc.conf

# Modify web server
# First, we will configure Apache to load index.php files by default by adding the following lines:
# Configure apache: /usr/local/etc/apache24/httpd.conf
# Modify this line: DirectoryIndex index.html (Line 278)
# To show as: DirectoryIndex index.html index.php
# Restart apache to update changes

# Next, we will configure Apache to process requested PHP files with the PHP processor.
echo '<FilesMatch "\.php$">' >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php' >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>' >> /usr/local/etc/apache24/httpd.conf
echo '<FilesMatch "\.phps$">' >> /usr/local/etc/apache24/httpd.conf
echo '    SetHandler application/x-httpd-php-source' >> /usr/local/etc/apache24/httpd.conf
echo '</FilesMatch>' >> /usr/local/etc/apache24/httpd.conf

# Start web server
service apache24 start

# Download server bot
wget -r -l1 -np -A "JTS3ServerMod_HostingEdition_*.zip" http://www.stefan1200.de/downloads/ -O /tmp/JTS3ServerMod_HostingEdition.zip
unzip -o "/tmp/JTS3ServerMod_HostingEdition.zip"
mv /tmp/JTS3ServerMod_HostingEdition /usr/local/share/teamspeak-bot
cp -R /usr/local/share/teamspeak-bot/webinterface/* /usr/local/www/apache24/data
rm /usr/local/www/apache24/data/index.html
#chmod /usr/local/www/apache24/data
#chown /usr/local/www/apache24/data

# create database
echo "create database ts3" | mysql -u root

}



################################################################################
##### UPDATERS
# TODO: Start working on all applicable updaters
################################################################################

#------------------------------------------------------------------------------#
### MYSQL UPDATE

update.mysql ()
{
echo -e "${emp} This part of the script isn't entirely finished but should${nc}"
echo -e "${emp} still work as intended.${nc}"
echo " "

service apache24 stop
/usr/local/etc/rc.d/mysql-server stop

pkg update
pkg upgrade mysql56-server mod_php56 php56-mysql php56-mysqli phpmyadmin apache24

/usr/local/etc/rc.d/mysql-server start
service apache24 start

}

#------------------------------------------------------------------------------#
### OWNCLOUD UPDATE

update.owncloud ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}     Welcome to the OwnCloud Updater!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}     Let's start with downloading the update.${nc}"
echo -e "${sep}"
echo " "

cd "/tmp"
fetch "https://download.owncloud.org/community/owncloud-${owncloud_update}.tar.bz2"

echo " "
echo -e "${sep}"
echo -e "${msg}     Stop the web server until the update is done.${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/lighttpd stop

echo " "
echo -e "${sep}"
echo -e "${msg}     Create backup.${nc}"
echo -e "${sep}"
echo " "

# Create inital backup folder if it doesn't exist
mkdir -p /usr/local/www/.owncloud-backup

# Copy current install to backup directory
# mv /usr/local/www/owncloud  /usr/local/www/.owncloud-backup/owncloud-${date} # NOTE: May not need this but leaving it in just in case
cp -R /usr/local/www/owncloud  /usr/local/www/.owncloud-backup/owncloud-${date}

echo -e "${msg} Backup of current install made in:${nc}"
echo -e "${qry}     /usr/local/www/.owncloud-backup/owncloud-${nc}\033[1;36m${date}${nc}"
echo -e "${msg} Keep note of this just in case something goes wrong with the update${nc}"

echo " "
echo -e "${sep}"
echo -e "${msg}     Now to extract OwnCloud in place of the old install.${nc}"
echo -e "${sep}"
echo " "

tar xf "owncloud-${owncloud_update}.tar.bz2" -C /usr/local/www
echo " Done!"
# Give permissions to www
chown -R www:www /usr/local/www/

#echo " " # NOTE: May not need the next few lines but leaving them in just in case
#echo -e "${sep}"
#echo -e "${msg}     Restore owncloud config, /data & /themes${nc}"
#echo -e "${sep}"
#echo " "

# cp -R /usr/local/www/.owncloud-backup/owncloud-${date}/data /usr/local/www/owncloud/
# cp -R /usr/local/www/.owncloud-backup/owncloud-${date}/themes/* /usr/local/www/owncloud/
# cp /usr/local/www/.owncloud-backup/owncloud-${date}/config/config.php /usr/local/www/owncloud/config/

echo " "
echo -e "${sep}"
echo -e "${msg}     Starting the web server back up${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/lighttpd start

echo " "
echo -e "${sep}"
echo -e "${msg} That should be it!${nc}"
echo -e "${msg} Now head to your OwnCloud webpage and make sure everything is working correctly.${nc}"
echo " "
echo -e "${msg} If something went wrong you can do the following to restore the old install:${nc}"
echo -e "${cmd}   rm -r /usr/local/www/owncloud${nc}"
echo -e "${cmd}   mv /usr/local/www/.owncloud-backup/owncloud-${date} /usr/local/www/owncloud${nc}"
echo " "
echo -e "${msg} After you check to make sure everything is working fine as expected,${nc}"
echo -e "${msg} You can safely remove backups with this command (May take some time):${nc}"
echo -e "${cmd}   rm -r /usr/local/www/.owncloud-backup${nc}"
echo -e "${alt} THIS WILL REMOVE ANY AND ALL BACKUPS MADE BY THIS SCRIPT${nc}"
echo " "
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### NEXTCLOUD UPDATE

update.nextcloud ()
{
	echo " "
}

#------------------------------------------------------------------------------#
### PYDIO UPDATE

update.pydio ()
{
	echo " "
}

#------------------------------------------------------------------------------#
### EMBY SERVER UPDATE

update.emby ()
{

update.emby.continue ()
{
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
read -r -p " " response
case "$response" in
    *)
              ;;
esac
}

remove.old.backups ()
{
read -r -p "   Remove old backups? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then make a backup before proceeding
              rm -r /usr/local/lib/emby-server-backups/*
              rm -r /var/db/emby-server-backups/*
              ;;
    *)
              # Otherwise continue with backup...
              echo " "
              echo -e "${inf} Continuing with backup..${nc}"
              ;;
esac
}

create.emby.backup ()
{
# Confirm with the user
echo -e "${msg} Recommended if you haven't done so already:${nc}"
read -r -p "   Create a backup before updating? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then make a backup before proceeding
              echo " "
              echo -e "${sep}"
              echo -e "${msg}   Would you like to remove any old backups before creating a new one?${nc}"
              echo -e "${msg}   This helps reduce the amount of space used by backups.${nc}"
              echo -e "${sep}"
              echo " "

              remove.old.backups

              echo " "
              echo -e "${sep}"
              echo -e "${msg}   Make sure we have rsync and then use it to create a backup${nc}"
              echo -e "${sep}"
              echo " "

              # Using rsync rather than cp so we can see progress actually happen on the backup for large servers.
              pkg install -y rsync

              # If yes, then create backup
              echo " "
              echo -e "${sep}"
              echo -e "${msg} Running backups${nc}"
              echo -e "${sep}"
              echo " "

              echo -e "${emp} Application backup${nc}"
              mkdir -p /usr/local/lib/emby-server-backups/${date} # Using -p in case you've never run the script before or you have deleted this folder
              rsync -a --info=progress2 /usr/local/lib/emby-server/ /usr/local/lib/emby-server-backups/${date}
              echo -e "${fin}    Application backup done..${nc}"

              echo " "

              echo -e "${emp} Server data backup ${inf}(May take a while, % may not be accurate)${nc}"
              mkdir -p /var/db/emby-server-backups/${date}
              rsync -a --info=progress2 /var/db/emby-server/ /var/db/emby-server-backups/${date}
              echo -e "${fin}    Server backup done.${nc}"
              ;;
    *)
              # Otherwise continue with update...
              echo " "
              echo -e "${inf} Skipping backup..${nc}"
              ;;
esac
}

select.emby.update.version ()
{
echo -e "${msg} You can let the script install the default version (${qry}${emby_def_update_ver}${msg})${nc}"
echo -e "${msg} Or you can select the version to install yourself.${nc}"
echo -e "${emp} Only do so if you know what you're doing!${nc}"
echo " "
read -r -p " Select version yourself? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY])
            echo " "
            echo -e "${msg} You can find release numbers here:${nc}"
            echo -e "${url} https://github.com/MediaBrowser/Emby/releases${nc}"
            echo " "
            echo -e "${emp} NOTE: ${inf}If selecting a beta or dev version,${nc}"
            echo -e "${inf} leave off the '-beta'/'-dev' from version number!${nc}"
            echo " "
            echo -e "${msg} Which version number do you want?${nc}"
            echo -e "${qry} Example version:${nc}"
            echo -e "${url} 3.2.17.0${nc}"
            echo " "
			printf "${emp} Version: ${nc}" ; read userselected_emby_update_ver
			echo -e "${fin}    Version set to: ${msg}${userselected_emby_update_ver}${nc}"
			echo " "
            echo -e "${sep}"
            echo -e "${msg} Grab the update for Emby from github${nc}"
            echo -e "${sep}"
            echo " "
            fetch --no-verify-peer -o /tmp/emby-$userselected_emby_update_ver.zip https://github.com/MediaBrowser/Emby/releases/download/$userselected_emby_update_ver/Emby.Mono.zip
            echo " "
            echo -e "${sep}"
            echo -e "${msg} Download done, let's stop the server${nc}"
            echo -e "${sep}"
            echo " "

            service emby-server stop

            echo " "
            echo -e "${sep}"
            echo -e "${msg} Now to extract the download and replace old version${nc}"
            echo -e "${sep}"
            echo " "

            unzip -o "/tmp/emby-${userselected_emby_update_ver}.zip" -d /usr/local/lib/emby-server
            ;;
        *)
            echo " "
            echo " Using default version as defined by script (${emby_def_update_ver})"
            echo " "
            echo -e "${sep}"
            echo -e "${msg} Grab the update for Emby from github${nc}"
            echo -e "${sep}"
            echo " "

            fetch --no-verify-peer -o /tmp/emby-${emby_def_update_ver}.zip https://github.com/MediaBrowser/Emby/releases/download/${emby_def_update_ver}/Emby.Mono.zip
            echo " "
            echo -e "${sep}"
            echo -e "${msg} Download done, let's stop the server${nc}"
            echo -e "${sep}"
            echo " "

            service emby-server stop

            echo " "
            echo -e "${sep}"
            echo -e "${msg} Now to extract the download and replace old version${nc}"
            echo -e "${sep}"
            echo " "

            unzip -o "/tmp/emby-${emby_def_update_ver}.zip" -d /usr/local/lib/emby-server
            ;;
    esac
}

# Split this function in to multiple parts?
recompile.from.ports ()
{
# Confirm with the user
echo -e "${msg} These steps could take some time and are NOT required.${nc}"
echo -e "${msg} If you're unsure what 'ports' are or if you have them, choose 'No'.${nc}"
read -r -p "   Would you like to recompile these now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then make a backup before proceeding
              echo " "
              echo -e "${sep}"
              echo -e "${fin} First, lets do ImageMagick${nc}"
              echo -e "${msg} When the options pop up, disable (By pressing space when its highlighted):${nc}"
              echo -e "${inf}    16BIT_PIXEL   ${msg}(to increase thumbnail generation performance)${nc}"
              echo -e "${msg} and then press 'Enter'${nc}"
              echo " "

              update.emby.continue

              cd /usr/ports/graphics/ImageMagick && make deinstall
              make clean && make clean-depends
              make config

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Press 'OK'/'Enter' if any box that follows.${nc}"
              echo -e "${msg}    (There shouldn't be any that pop up)${nc}"
              echo -e "${sep}"
              echo " "

              update.emby.continue

              make install clean
              #make -DBATCH install clean

              echo " "
              echo -e "${sep}"
              echo -e "${fin} Great, now ffmpeg${nc}"
              echo -e "${sep}"
              echo " "

              cd /usr/ports/multimedia/ffmpeg && make deinstall

              echo " "
              echo -e "${sep}"
              echo -e "${msg} When the options pop up, enable (By pressing space when its highlighted):${nc}"
              echo -e "${inf}    ASS     ${msg}(required for subtitle rendering)${nc}"
              echo -e "${inf}    LAME    ${msg}(required for mp3 audio transcoding -${nc}"
              echo -e "${inf}            ${msg}disabled by default due to mp3 licensing restrictions)${nc}"
              echo -e "${inf}    OPUS    ${msg}(required for opus audio codec support)${nc}"
              echo -e "${inf}    X265    ${msg}(required for H.265 video codec support${nc}"
              echo -e "${msg} Then press 'OK' for any box that follows.${nc}"
              echo -e "${msg} This one may take a while, please be patient${nc}"
              echo -e "${sep}"
              echo " "

              update.emby.continue

              make clean
              make clean-depends
              make config

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Press 'OK'/'Enter' for any box that follows.${nc}"
              echo -e "${sep}"
              echo " "

              update.emby.continue

              #make install clean
              make -DBATCH install clean

              echo " "
              echo -e "${sep}"
              echo -e "${msg} Finished with the recompiling!${nc}"
              echo -e "${sep}"
              echo " "

              ;;
    *)
              # Otherwise continue with update...
              echo " "
              echo -e "${inf} Skipping for now.. (You can do this later via the Emby menu)${nc}"
              ;;
esac
}

remove.downloaded.files ()
{
read -r -p "   Remove downloaded .zip files? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then make a backup before proceeding
              echo -e "${inf} Deleting files${nc}"
              rm /tmp/emby-*.zip
              ;;
    *)
              # Otherwise continue with backup...
              echo " "
              echo -e "${inf} Not deleting files${nc}"
              ;;
esac
}

echo " "
echo -e "${sep}"
echo -e "${msg}   Emby Updater${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg} Shall we create a backup before updating?${nc}"
echo -e "${sep}"
echo " "

create.emby.backup

echo " "
echo -e "${sep}"
echo -e "${msg} Updating packages..${nc}"
echo -e "${msg} (You may see some things get uninstalled/reinstalled here)${nc}"
echo -e "${sep}"
echo " "

pkg update
pkg upgrade -y
pkg install -y emby-server # In case it gets uninstalled

echo " "

echo -e "${msg} Package updates done${nc}"

echo " "
echo -e "${sep}"
echo -e "${inf} Recompile ffmpeg and ImageMagick${nc}"
echo " "
echo -e "${msg} This is 100% optional but doing so can improve your Emby Server${nc}"
echo -e "${msg}    This can be done either later via Emby menus or now.${nc}"
echo -e "${msg}    Additional information can also be found in the menu.${nc}"
echo -e "${emp} You will also need the 'ports tree' enabled for this to work.${nc}"
echo -e "${sep}"
echo " "

recompile.from.ports

echo " "
echo -e "${sep}"
echo -e "${msg} What version would you like to update to?${nc}"
echo -e "${sep}"
echo " "

select.emby.update.version

#echo " "
#echo -e "${sep}"
#echo -e "${msg} Download done, let's stop the server${nc}"
#echo -e "${sep}"
#echo " "

#service emby-server stop

#echo " "
#echo -e "${sep}"
#echo -e "${msg} Now to extract the download and replace old version${nc}"
#echo -e "${sep}"
#echo " "

#unzip -o "/tmp/emby-${userselected_emby_update_ver}.zip" -d /usr/local/lib/emby-server
#unzip -o "/tmp/emby-${emby_def_update_ver}.zip" -d /usr/local/lib/emby-server

# Script default version
#if [ -f "/tmp/emby-${userselected_emby_update_ver}.zip" ]
#then
#	echo "$userselected_emby_update_ver.zip found, extracting"
#    unzip -o "/tmp/emby-${userselected_emby_update_ver}.zip" -d /usr/local/lib/emby-server
#else
#	echo "/tmp/emby-${userselected_emby_update_ver}.zip not found, trying 'emby-${emby_def_update_ver}.zip'"
#fi
#
# User selected version
#if [ -f "/tmp/emby-${userselected_emby_update_ver}.zip" ]
#then
#	echo "$userselected_emby_update_ver.zip found, extracting"
#    unzip -o "/tmp/emby-${userselected_emby_update_ver}.zip" -d /usr/local/lib/emby-server
#else
#	echo "$userselected_emby_update_ver.zip not found"
#fi

echo " "
echo -e "${sep}"
echo -e "${msg} And finally, start the server back up.${nc}"
echo -e "${sep}"
echo " "

service emby-server start

echo " "
echo -e "${sep}"
echo -e "${msg} Optional: Remove temporary files that were downloaded?${nc}"
echo -e "${sep}"
echo " "

remove.downloaded.files

echo " "
echo -e "${sep}"
echo -e "${msg} That should be it!${nc}"
echo -e "${msg} Now head to your Emby dashboard to ensure it's up to date.${nc}"
echo -e "${msg}    (Refresh the page if you already have Emby open)${nc}"
echo " "
echo -e "${msg} If something went wrong you can do this to restore the old app version:${nc}"
echo -e "${cmd}   rm -r /usr/local/lib/emby-server${nc}"
echo -e "${cmd}   mv /usr/local/lib/emby-server-backups/${date} /usr/local/lib/emby-server${nc}"
echo -e "${cmd}   service emby-server restart${nc}"
echo " "
echo -e "${msg} And use this to restore your server database/settings:${nc}"
echo -e "${cmd}   rm -r /var/db/emby-server${nc}"
echo -e "${cmd}   mv /var/db/emby-server-backups/${date} /var/db/emby-server${nc}"
echo -e "${cmd}   service emby-server restart${nc}"
echo -e "${sep}"
echo -e "${msg} If you have any issues, see the main menu for ways to get help.${nc}"
echo -e "${msg}      Happy Streaming!${nc}"
echo -e "${sep}"
echo " "

update.emby.continue

}

#------------------------------------------------------------------------------#
### PLEX UPDATE

update.plex ()
{

echo " "
echo -e "${sep}"
echo "   Plex Media Server Updater"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo "   Let's start with downloading the update script and running it"
echo -e "${sep}"
echo " "

cd $(myappsdir)
fetch https://raw.githubusercontent.com/JRGTH/nas4free-plex-extension/master/plex/plexinit && chmod +x plexinit && ./plexinit

}

#------------------------------------------------------------------------------#
### SUBSONIC UPDATE

update.subsonic ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

pkg update
pkg upgrade

}

#------------------------------------------------------------------------------#
### MADSONIC UPDATE

update.madsonic ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the Madsonic updater!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's get started with some questions${nc}"
echo -e "${sep}"
echo " "
read -r -p " Double check your version, is it the latest? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY])
            echo " No need to update anything then${nc}"
            ;;
        *)
            echo " "
            echo -e "${sep}"
            echo -e "${msg} Paste the download link to the madsonic standalone package${nc}"
            echo -e "${qry} Example link:"
            echo -e "${url} http://madsonic.org/download/6.2/20161222_madsonic-6.2.9080-war-jspc.zip${nc}"
            echo " "
            echo "Link:"
            read madlink
            echo " "
            echo -e "${msg} Which version number is it?${nc}"
            echo -e "${qry} Example version:${nc}"
            echo -e "${url} 6.2.9080${nc}"
            echo " "
            echo "Version:"
            read madversion
            echo " "
            echo -e "${sep}"
            echo -e "${msg} Downloading update${nc}"
            echo -e "${sep}"
            echo " "

            #fetch -o madsonic"$buildno".tar.gz "$madlink"
            fetch -o /tmp/madsonic-"$madversion".zip "$madlink"
            #tar xvzf madsonic"$buildno".tar.gz -C /usr/local/share/madsonic-standalone
            echo " Download finished"

            echo " "
            echo -e "${sep}"
            echo -e "${msg} Stopping madsonic service to apply update${nc}"
            echo -e "${sep}"
            echo " "

            service madsonic stop

            echo " "
            echo -e "${sep}"
            echo -e "${msg} Extracting downloaded file${nc}"
            echo -e "${sep}"
            echo " "

            unzip -o /tmp/madsonic-"$madversion".zip -d /usr/local/share/madsonic-standalone
            chmod +x /usr/local/share/madsonic-standalone/*
            echo " Extraction finished"

            echo " "
            echo -e "${sep}"
            echo -e "${msg} Starting madsonic service${nc}"
            echo -e "${sep}"
            echo " "
            service madsonic start
            ;;
    esac
}

#------------------------------------------------------------------------------#
### SONARR UPDATE

update.sonarr ()
{
# Would user like automatic script?
# If yes, fetch from github or [VS] website.
# Guide user through steps
# Proceed to use following update steps for now

# Sonarr update script
# Version 2.0.1 (March 17, 2016)

echo " "
echo -e "${sep}"
echo "   Sonarr Updater"
echo -e "${sep}"
echo " "

echo " "
echo -e "${sep}"
echo "   Let's start with downloading the update"
echo -e "${sep}"
echo " "

cd /tmp
fetch http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz

echo " "
echo -e "${sep}"
echo "   Deleting any old updates & extracting files"
echo -e "${sep}"
echo " "

rm -r /tmp/sonarr_update
tar xvfz NzbDrone.master.tar.gz
mv /tmp/NzbDrone /tmp/sonarr_update

echo " "
echo -e "${sep}"
echo "   Shutting down Sonarr"
echo -e "${sep}"
echo " "

service sonarr stop

echo " "
echo -e "${sep}"
echo "   Backing up config and database"
echo -e "${sep}"
echo " "

mkdir /tmp/sonarr_backup
cp /usr/local/sonarr/nzbdrone.db /tmp/sonarr_backup/nzbdrone.db-${date}
cp /usr/local/sonarr/config.xml /tmp/sonarr_backup/config.xml-${date}
mv /tmp/nzbdrone_update /tmp/sonarr_update

echo " "
echo -e "${sep}"
echo "   Renaming old sonarr folder & copying new"
echo "   Setting permissions while we are at it"
echo -e "${sep}"
echo " "

mkdir /usr/local/share/sonarr.backups
mv /usr/local/share/sonarr /usr/local/share/sonarr.backups/manualupdate-${date}
mv /tmp/sonarr_update/NzbDrone /usr/local/share/sonarr
chown -R 351:0 /usr/local/share/sonarr/
chmod -R 755 /usr/local/share/sonarr/

echo " "
echo -e "${sep}"
echo "   Last second housecleaning"
echo -e "${sep}"
echo " "

rm /tmp/NzbDrone.master.tar.gz
rm -r /tmp/nzbdrone_backup
rm -r /tmp/sonarr_update

echo " "
echo -e "${sep}"
echo "   Starting up Sonarr"
echo -e "${sep}"
echo " "

service sonarr restart
}

#------------------------------------------------------------------------------#
### COUCHPOTATO UPDATE

update.couchpotato ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
# CouchPotato can be updated automatically
# TODO: Add instructions on how to enable auto updates
# TODO: Add manual update here just in case (via github)
echo " "

pkg update
pkg upgrade

}

#------------------------------------------------------------------------------#
### HEADPHONES UPDATE

update.headphones ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
# Headphones can be updated automatically
# TODO: Add instructions on how to enable auto updates
# TODO: Add manual update here just in case (via github)
echo " "

pkg update
pkg upgrade

}

#------------------------------------------------------------------------------#
### DELUGE UPDATE

update.deluge ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

pkg update
pkg upgrade

}

#------------------------------------------------------------------------------#
### NZBGET UPDATE

update.nzbget ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

pkg update
pkg upgrade nzbget

}

#------------------------------------------------------------------------------#
### SABNZBD UPDATE

update.sabnzbd ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Welcome to the SABnzbd updater!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}   Let's start with updating packages if needed${nc}"
echo -e "${sep}"
echo " "

pkg update
pkg upgrade

echo " "
echo -e "${sep}"
echo -e "${msg} Now let's grab the update of SABnzbd${nc}"
echo -e "${msg} Currently set to grab:${inf} ${sab_ver} ${nc}"
echo -e "${msg} You can modify the 'sab_ver' variable near the top of the script${nc}"
echo -e "${msg} to change the version that is downloaded.${nc}"
echo -e "${sep}"
echo " "

cd tmp
fetch "http://downloads.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${sab_ver}/SABnzbd-${sab_ver}-src.tar.gz"
tar xfz SABnzbd-${sab_ver}-src.tar.gz -C /usr/local
rm SABnzbd-${sab_ver}-src.tar.gz
mv /usr/local/SABnzbd-${sab_ver} /usr/local/Sabnzbd

echo " "
echo -e "${sep}"
echo -e "${msg} Before we are able to run SABnzbd, we need to modify a file${nc}"
echo -e "${msg} Using nano, change the first line (/usr/bin/python)${nc}"
echo -e "${msg} to match the following:${nc}"
echo -e "${cmd}    #!/usr/local/bin/python2.7${nc}"
echo -e "${sep}"
echo " "

nano /usr/local/Sabnzbd/SABnzbd.py

echo " "
echo -e "${sep}"
echo -e "${msg} Start it up${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/sabnzbd start

echo " "
echo -e "${sep}"
echo -e "${msg} Done! Head to: ${url}yourjailip:8080${nc}"
echo -e "${msg} to visit your SABnzbd!${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER UPDATE

update.teamspeak3 ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

pkg update
pkg upgrade nzbget

}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT UPDATE

update.teamspeak3bot ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

pkg update
pkg upgrade nzbget

}



################################################################################
##### BACKUPS
# TODO: Start working on all applicable backups
################################################################################

#------------------------------------------------------------------------------#
### MYSQL BACKUP

backup.mysql ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### OWNCLOUD BACKUP

backup.owncloud ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### PYDIO BACKUP

backup.pydio ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### EMBY SERVER BACKUP

backup.emby ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   First, make sure we have rsync and then${nc}"
echo -e "${msg}   we will use it to create a backup${nc}"
echo -e "${sep}"
echo " "

# Using rsync rather than cp so we can see progress actually happen on the backup for large servers.
pkg install -y rsync

echo " "
echo -e "${sep}"
echo -e "${msg} Create backups${nc}" # TODO: Give user option to backup or not
echo -e "${sep}"
echo " "

echo -e "${emp} Application backup${nc}"
mkdir -p /usr/local/lib/emby-server-backups/${date} # Using -p in case you've never run the script before or you have deleted this folder
rsync -a --info=progress2 /usr/local/lib/emby-server/ /usr/local/lib/emby-server-backups/${date}
echo -e "${fin}    Application backup done..${nc}"

echo " "

echo -e "${emp} Server data backup ${inf}(May take a while)${nc}"
mkdir -p /var/db/emby-server-backups/${date}
rsync -a --info=progress2 /var/db/emby-server/ /var/db/emby-server-backups/${date}
echo -e "${fin}    Server backup done.${nc}"

echo " "
echo -e "${sep}"
echo -e "${msg} That should be it!${nc}"
echo " "
echo " "
echo " "
echo -e "${msg} If something goes wrong you can do the following to restore an old version:${nc}"
echo -e "${cmd}   rm -r /usr/local/lib/emby-server${nc}"
echo -e "${cmd}   mv /usr/local/lib/emby-server-backups/${date} /usr/local/lib/emby-server${nc}"
echo " "
echo -e "${msg} And use this to restore your server database/settings:${nc}"
echo -e "${cmd}   rm -r /var/db/emby-server${nc}"
echo -e "${cmd}   mv /var/db/emby-server-backups/${date} /var/db/emby-server${nc}"
echo -e "${sep}"
echo " "
}

#------------------------------------------------------------------------------#
### SONARR BACKUP

backup.sonarr ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### COUCHPOTATO BACKUP

backup.couchpotato ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### HEADPHONES BACKUP

backup.headphones ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}



#------------------------------------------------------------------------------#
### THEBRIG BACKUP

backup.thebrig ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### DELUGE BACKUP

backup.deluge ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### NZBGET BACKUP

backup.nzbget ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### SABNZBD BACKUP

backup.sabnzbd ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### WEB SERVER BACKUP

backup.webserver ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### SUBSONIC BACKUP

backup.subsonic ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BACKUP

backup.teamspeak3 ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT BACKUP

backup.teamspeak3bot ()
{
echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "
}



################################################################################
##### CONFIRMATIONS
# TODO: Add confirms for all installs as a safety thing
################################################################################

### INSTALL CONFIRMATIONS
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
### MYSQL CONFIRM INSTALL

confirm.install.mysql ()
{
# Confirm with the user
read -r -p "   Confirm Installation of MySQL? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.mysql
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### OWNCLOUD CONFIRM INSTALL

confirm.install.owncloud ()
{
confirm ()
{
# Confirm with the user
read -r -p "   Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Great! Moving on..${nc}"
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt} Stopping script..${nc}"
              echo " "
              echo -e "${sep}"
              exit
              ;;
esac
}
echo -e "${sep}"
echo -e "${msg}   Let's start with double checking some things${nc}"
echo -e "${sep}"
echo " "

echo -e "${msg} Is this script running ${alt}INSIDE${msg} of a jail?${nc}"

confirm

echo " "
echo -e "${msg} Checking to see if you need to modify the script${nc}"
echo -e "${msg} If ${emp}ANY${msg} of these ${emp}DON'T${msg} match YOUR setup, answer with ${emp}no${nc}."
echo -e " "
echo -e "      ${alt}#1: ${msg}Is this your jails IP? ${qry}$cloud_server_ip${nc}"
echo -e "      ${alt}#2: ${msg}Is this the port you want to use? ${qry}$cloud_server_port${nc}"
echo -e "      ${alt}#3: ${msg}Is this the ownCloud version you want to install? ${qry}$owncloud_version${nc}"
echo -e " "
echo -e "${emp} If #1 or #2 are incorrect you will encounter issues!${nc}"

confirm

echo " "
echo -e "${fin} Awesome, now we are ready to get on with it!${nc}"
# Confirm with the user
echo " "
echo -e "${inf} Final confirmation before installing owncloud.${nc}"
read -r -p "   Confirm Installation of OwnCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.owncloud
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${sep}"
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### NEXTCLOUD CONFIRM INSTALL

confirm.install.nextcloud ()
{
confirm ()
{
# Confirm with the user
read -r -p "   Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              echo -e "${url} Great! Moving on..${nc}"
               ;;
    *)
              # Otherwise exit...
              echo " "
              echo -e "${alt}Stopping script..${nc}"
              echo " "
              exit
              ;;
esac
}

echo -e "${sep}"
echo -e "${msg}   Let's start with double checking some things${nc}"
echo -e "${sep}"
echo " "

echo -e "${msg} Is this script running ${alt}INSIDE${msg} of a jail?${nc}"

confirm

#echo " "
#echo -e "${msg} Checking to see if you need to modify the script${nc}"
#echo -e "${msg} If ${emp}ANY${msg} of these ${emp}DON'T${msg} match YOUR setup, answer with ${emp}no${nc}."
#echo -e " "
#echo -e "      ${alt}#1: ${msg}Is this your jails IP? ${qry}$server_ip${nc}"
#echo -e "      ${alt}#2: ${msg}Is this the port you want to use? ${qry}$server_port${nc}"
#echo -e "      ${alt}#3: ${msg}Is this the NextCloud version you want to install? ${qry}$nextcloud_version${nc}"
#echo -e " "
#echo -e "${emp} If #1 or #2 are incorrect you will encounter issues!${nc}"

#confirm

echo " "

# Confirm with the user
echo -e "${inf} Final confirmation before installing nextcloud.${nc}"
read -r -p "   Confirm Installation of NextCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.nextcloud
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### PYDIO CONFIRM INSTALL

confirm.install.pydio ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Pydio? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.pydio
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### EMBY SERVER CONFIRM INSTALL

confirm.install.emby ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Emby Media Server? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.emby
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### OMBI SERVER CONFIRM INSTALL

confirm.install.ombi ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Ombi Media Requests? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.ombi
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### SONARR CONFIRM INSTALL

confirm.install.sonarr ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Sonarr? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.sonarr
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### COUCHPOTATO CONFIRM INSTALL

confirm.install.couchpotato ()
{
# Confirm with the user
read -r -p "   Confirm Installation of CouchPotato? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.couchpotato
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### HEADPHONES CONFIRM INSTALL

confirm.install.headphones ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Headphones? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.headphones
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### CALIBRE CONFIRM INSTALL

confirm.install.calibre ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Calibre? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.calibre
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### DELUGE CONFIRM INSTALL

confirm.install.deluge ()
{
# Confirm with the user
echo -e "${emp} WARNING: THIS HAS BEEN UNTESTED"
echo -e "${emp} USE AT YOUR OWN RISK"
read -r -p "   Confirm Installation of Deluge? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.deluge
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### NZBGET CONFIRM INSTALL

confirm.install.nzbget ()
{
# Confirm with the user
read -r -p "   Confirm Installation of NZBGet? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.nzbget
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### SABNZBD CONFIRM INSTALL

confirm.install.sabnzbd ()
{
# Confirm with the user
read -r -p "   Confirm Installation of SABnzbd? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.sabnzbd
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### WEB SERVER CONFIRM INSTALL

confirm.install.webserver ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Web Server? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.webserver
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### SUBSONIC CONFIRM INSTALL

confirm.install.subsonic ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Subsonic? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.subsonic
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### MADSONIC CONFIRM INSTALL

confirm.install.madsonic ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Madsonic? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.madsonic
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER CONFIRM INSTALL

confirm.install.teamspeak3 ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Teamspeak 3? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.teamspeak3
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT CONFIRM INSTALL

confirm.install.teamspeak3bot ()
{
# Confirm with the user
read -r -p "   Confirm Installation of Teamspeak 3 Server Bot? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.teamspeak3bot
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### OBI CONFIRM INSTALL

confirm.install.obi ()
{
# Confirm with the user
echo -e "${emp} WARNING: THIS HAS BEEN UNTESTED${nc}"
echo -e "${emp} USE AT YOUR OWN RISK${nc}"
echo -e "${emp} DO NOT INSTALL INSIDE A JAIL, RUN ON HOST SYSTEM${nc}"
echo " "
read -r -p "   Confirm Installation of OneButtonInstaller? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.obi
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}



#------------------------------------------------------------------------------#
### UPDATE CONFIRMATIONS
# TODO: Add run backup before update commands + inform the user of backup
#------------------------------------------------------------------------------#

### MYSQL CONFIRM UPDATE
#------------------------------------------------------------------------------#

confirm.update.mysql ()
{
# Confirm with the user
read -r -p "   Confirm Update of MySQL? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.mysql
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### OWNCLOUD CONFIRM UPDATE

confirm.update.owncloud ()
{
# Confirm with the user
echo -e "${emp} NOTE: ${msg}OwnCloud should be able to handle it's own updates automatically${nc}"
echo -e "${msg}       This updater should only be used if the built-in one fails${nc}"
echo " "
echo -e "${msg} Also note that this won't remove any old backups so the backup folder may get${nc}"
echo -e "${msg} very large depending on your /data, it's up to you to clean it up if you wish.${nc}"
echo " "
echo -e "${msg} One last thing to note is you need to modify the .${nc}"
echo " "
read -r -p "   Confirm Update of OwnCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.owncloud
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### PYDIO CONFIRM UPDATE

confirm.update.pydio ()
{
# Confirm with the user
read -r -p "   Confirm Update of Pydio? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.pydio
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### EMBY SERVER CONFIRM UPDATE (LATEST GIT METHOD)

confirm.update.emby ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}   Emby Server Updater${nc}"
echo -e "${sep}"
echo " "
echo -e "${emp} CAUTION: Things can go wrong! I highly suggest${nc}"
echo -e "${emp}          having a backup just in case!${nc}"
echo -e "${inf}          (Script will offer to create one)${nc}"
echo " "
echo -e "${qry} Update Version${msg}: ${inf} ${emby_def_update_ver} ${msg})${nc}"
echo -e "${msg}      You are able to change this shortly.${nc}"
echo " "
echo -e "${msg} You can find the latest version number here:${nc}"
echo -e "${url} https://github.com/MediaBrowser/Emby/releases${url}"
echo " "
echo -e "${msg} Only continue if you are 100% sure${nc}"
# Confirm with the user
read -r -p "   Confirm Update of Emby Media Server? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.emby
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
echo " "
echo " "
}

#------------------------------------------------------------------------------#
### SONARR CONFIRM UPDATE

confirm.update.sonarr ()
{
# Confirm with the user
read -r -p "   Confirm Update of Sonarr? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.sonarr
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### COUCHPOTATO CONFIRM UPDATE

confirm.update.couchpotato ()
{
# Confirm with the user
read -r -p "   Confirm Update of CouchPotato? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.couchpotato
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### HEADPHONES CONFIRM UPDATE

confirm.update.headphones ()
{
# Confirm with the user
read -r -p "   Confirm Update of Headphones? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.headphones
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### THEBRIG CONFIRM UPDATE

confirm.update.thebrig ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### DELUGE CONFIRM UPDATE

confirm.update.deluge ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### NZBGET CONFIRM UPDATE

confirm.update.nzbget ()
{

echo -e "${emp} This part of the script is unfinished currently :(${nc}"
echo " "

}

#------------------------------------------------------------------------------#
### SABNZBD CONFIRM UPDATE

confirm.update.sabnzbd ()
{
# Confirm with the user
read -r -p "   Confirm Update of Sabnzbd? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.sabnzbd
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### WEB SERVER CONFIRM UPDATE

confirm.update.webserver ()
{
# Confirm with the user
read -r -p "   Confirm Update of Web Server? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.webserver
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### SUBSONIC CONFIRM UPDATE

confirm.update.subsonic ()
{
# Confirm with the user
read -r -p "   Confirm Update of Subsonic? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.subsonic
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### MADSONIC CONFIRM UPDATE

confirm.update.madsonic ()
{
# Confirm with the user
read -r -p "   Confirm Update of Madsonic? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.madsonic
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER CONFIRM UPDATE

confirm.update.teamspeak3 ()
{
# Confirm with the user
read -r -p "   Confirm Update of Teamspeak 3 Server? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.teamspeak3
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### TEAMSPEAK 3 SERVER BOT CONFIRM UPDATE

confirm.update.teamspeak3bot ()
{
# Confirm with the user
read -r -p "   Confirm Update of Teamspeak 3 Server Bot? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.teamspeak3bot
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}



################################################################################
##### SUBMENUS
# TODO: Add appropriate commands to backups option once finished
################################################################################

### DATABASES SUBMENU
#------------------------------------------------------------------------------#

databases.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
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
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Please confirm that you wish to install MySQL${nc}"
                echo " "
                confirm.install.mysql
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.mysql
                ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.mysql
            #    ;;
            'a')
                about.mysql
                ;;
            #'i')
            #    moreinfo.submenu.mysql
            #    ;;
            'h')
                gethelp
                ;;
            'm')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### CLOUD SUBMENU

cloud.submenu ()
{
while [ "$choice" != "a,h,i,b" ]
do
        echo -e "${sep}"
        echo -e "${fin} Self Hosted Cloud Storage Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} OwnCloud${nc}"
        echo -e "${fin}   2)${msg} NextCloud (Preferred)${nc}"
        echo -e "${ca}   3)${ca} Pydio (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Cloud Storage (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Information / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1')
                owncloud.submenu
                ;;
            '2')
                nextcloud.submenu
                ;;
            #'3')
            #    pydio.submenu
            #    ;;
            'a')
                about.cloudstorage
                ;;
            #'i')
            #    moreinfo.submenu.cloud
            #    ;;
            'h')
                gethelp
                ;;
            'b')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### OWNCLOUD SUBMENU

owncloud.submenu ()
{
while [ "$choice" != "a,h,i,b,d" ]
do
        echo -e "${sep}"
        echo -e "${fin} OwnCloud Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update${nc}"
        echo -e "${ca}   3)${ca} Backup${nc}"
        echo " "
        echo -e "${fin}   4)${msg} Fix Known Errors${nc}"
        echo -e "${fin}   5)${msg} Other${nc}"
        echo " "
        echo -e "${inf}  a) About OwnCloud${nc}"
        echo -e "${ca}  d) Difference between ownCloud / NextCloud${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.owncloud
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.owncloud
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.owncloud
            #    ;;
            '4')
                owncloud.errorfix.submenu
                ;;
            '5')
                owncloud.otheroptions.menu
                ;;
            'a')
                about.owncloud
                ;;
            'd')
                about.cloud.differences
                ;;
            'i')
                moreinfo.submenu.owncloud
                ;;
            'h')
                gethelp
                ;;
            'b')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### NEXTCLOUD SUBMENU

nextcloud.submenu ()
{
while [ "$choice" != "a,h,i,b,d" ]
do
        echo -e "${sep}"
        echo -e "${fin} NextCloud Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update${nc}"
        echo -e "${ca}   3)${ca} Backup${nc}"
        echo " "
        echo -e "${inf}  a) About NextCloud${nc}"
        echo -e "${ca}  d) Difference between NextCloud / ownCloud${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.nextcloud
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.nextcloud
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.nextcloud
            #    ;;
            '4')
                nextcloud.errorfix.submenu
                ;;
            '5')
                nextcloud.otheroptions.menu
                ;;
            'a')
                about.nextcloud
                ;;
            'd')
                about.cloud.differences
                ;;
            'i')
                moreinfo.submenu.nextcloud
                ;;
            'h')
                gethelp
                ;;
            'b')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### PYDIO SUBMENU

pydio.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Pydio Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${inf}  a) About Pydio${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.pydio
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.pydio
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.pydio
                ;;
            'a')
                about.pydio
                ;;
            'i')
                moreinfo.submenu.pydio
                ;;
            'h')
                gethelp
                ;;
            'm')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### STREAMING SUBMENU

streaming.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Self Hosting Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one: Media Streaming with...${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Emby Media Server${nc}"
        echo -e "${ca}   2)${ca} Plex Media Server (Currently Unavailable)${nc}"
        echo -e "${fin}   3)${msg} Subsonic${nc}"
        echo -e "${fin}   4)${msg} Madsonic${nc}"
        echo " "
        echo -e "${fin}   5)${msg} Ombi - Plex/Emby Requests${nc}"
        echo " "
        echo -e "${ca}  a) About Media Streaming (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Taking you to the Emby menu..${nc}"
                echo " "
                emby.submenu
                ;;
            #'2') echo -e "${inf} Taking you to the Plex menu..${nc}"
            #    echo " "
            #    plex.submenu
            #    ;;
            '3')
                subsonic.submenu
                ;;
            '4')
                madsonic.submenu
                ;;
			'5')
                ombi.submenu
                ;;
            #'a')
            #    about.streaming
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.streaming
            #    ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### EMBY SERVER SUBMENU

emby.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Emby Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${fin}   4)${msg} Increase server performance${nc}"
        echo -e "${fin}   5)${msg} Enable more transcoding options${nc}"
        echo " "
        echo -e "${ca}  a) About Emby${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.emby
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.emby
                ;;
            '3') echo -e "${inf} ..${nc}"
                echo " "
                backup.emby
                ;;
            '4') echo -e "${inf} ..${nc}"
                echo " "
                recompile.imagemagick
                ;;
            '5') echo -e "${inf} ..${nc}"
                echo " "
                recompile.ffmpeg
                ;;
            'a')
                about.emby
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.emby
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### PLEX SERVER SUBMENU

plex.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Plex Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${ca}  a) About Plex${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.plex
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.plex
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.plex
                ;;
            'a')
                about.plex
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.plex
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### OMBI SERVER SUBMENU

ombi.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Ombi Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Plex${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.ombi
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.ombi
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.ombi
                ;;
            'a')
                about.ombi
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.ombi
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SUBSONIC SUBMENU

subsonic.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Subsonic Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${ca}  a) About Subsonic${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.subsonic
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.subsonic
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.subsonic
                ;;
            'a')
                about.subsonic
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.subsonic
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### MADSONIC SUBMENU

madsonic.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Madsonic Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Madsonic (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.madsonic
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.madsonic
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.madsonic
                ;;
            'a')
                about.madsonic
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.madsonic
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SEARCH TOOLS / DOWNLOAD AUTOMATION SUBMENU

searchtools.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Automation Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Automate your downloads with:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Sonarr (TV & Anime) (Preferred)${nc}"
        echo -e "${ca}   2)${ca} Sickbeard (TV & Anime) (Currently Unavailable)${nc}"
        echo -e "${fin}   3)${msg} CouchPotato (Movies)${nc}"
        echo -e "${ca}   4)${ca} Watcher (Movies)${nc}"
        echo -e "${ca}   5)${ca} Radarr (Sonarr for Movies)${nc}"
        echo -e "${fin}   6)${msg} HeadPhones (Music) (Currently Unavailable)${nc}"
        echo -e "${ca}   7)${ca} Mylar (Comics) (Currently Unavailable)${nc}"
        echo -e "${ca}   8)${ca} LazyLibrarian (Books) (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}   0)${ca} HTPC Manager${nc}"
        echo " "
        echo -e "${ca}  a) About Automation (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Taking you to the Sonarr menu..${nc}"
                echo " "
                sonarr.submenu
                ;;
            #'2') echo -e "${inf} Taking you to the Sickbeard menu..${nc}"
            #    echo " "
            #    sickbeard.submenu
            #    ;;
            '3') echo -e "${inf} Taking you to the CouchPotato menu..${nc}"
                echo " "
                couchpotato.submenu
                ;;
            '4') echo -e "${inf} Taking you to the HeadPhones menu..${nc}"
                echo " "
                headphones.submenu
                ;;
            #'5') echo -e "${inf} Taking you to the Mylar menu..${nc}"
            #    echo " "
            #    mylar.submenu
            #    ;;
            #'6') echo -e "${inf} Taking you to the LazyLibrarian menu..${nc}"
            #    echo " "
            #    lazylibrarian.submenu
            #    ;;
            #'0') echo -e "${inf} Taking you to the HTPC Manager menu..${nc}"
            #    echo " "
            #    htpc.submenu
            #    ;;
            #'a')
            #    about.searchtools
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.searchtools
            #    ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SONARR SUBMENU

sonarr.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Sonarr Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${inf}  a) About Sonarr${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.sonarr
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.sonarr
                ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.sonarr
            #    ;;
            'a')
                about.sonarr
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.sonarr
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SICKBEARD SUBMENU

sickbeard.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} SickBeard Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${ca}   1)${msg} Install (Currently Unavailable)${nc}"
        echo -e "${ca}   2)${msg} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About SickBeard (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${ca}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.sickbeard
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.sickbeard
                ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.sickbeard
            #    ;;
            #'a')
            #    about.sickbeard
            #    ;;
            #'h')
            #    gethelp
            #    ;;
            #'i')
            #    moreinfo.submenu.sickbeard
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}


#------------------------------------------------------------------------------#
### COUCHPOTATO SUBMENU

couchpotato.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} CouchPotato Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${inf}  a) About CouchPotato${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.couchpotato
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.couchpotato
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.couchpotato
            #    ;;
            'a')
                about.couchpotato
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.couchpotato
            #    ;;
            'b')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### HEADPHONES SUBMENU

headphones.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} HeadPhones Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${inf}  a) About CouchPotato${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.headphones
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.headphones
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.headphones
            #    ;;
            'a')
                about.headphones
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.headphones
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}



#------------------------------------------------------------------------------#
### THEBRIG SUBMENU

thebrig.submenu ()
{
while [ "$choice" != "a,e,h,i,m" ]
do
        echo -e "${sep}"
        echo -e "${fin} TheBrig Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install (Guide Only)${nc}"
        echo -e "${ca}   2)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${inf}  a) About TheBrig${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Taking you to install instructions..${nc}"
                echo " "
                thebrig.howto.installthebrig
                ;;
            #'2') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.thebrig
            #    ;;
            'a')
                about.thebrig
                ;;
            'h')
                gethelp
                ;;
            'i')
                moreinfo.submenu.thebrig
                ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### OBI SUBMENU

obi.submenu ()
{
while [ "$choice" != "a,e,h,i,m" ]
do
        echo -e "${sep}"
        echo -e "${fin} OneButtonInstaller Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a)${ca} About OneButtonInstaller${nc}"
        echo -e "${ca}  i)${ca} More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.obi
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.obi
            #    ;;
            #'a')
            #    about.obi
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.obi
            #    ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### DOWNLOAD TOOLS SUBMENU

downloadtools.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Download Tools${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Deluge (Torrenting)${nc}"
        echo -e "${fin}   2)${msg} NZBGet (Usenet Downloader)${nc}"
        echo -e "${fin}   3)${msg} SABnzbd (Usenet Downloader)${nc}"
        echo " "
        echo -e "${fin}   4)${msg} Jackett (Torrent Meta Search)${nc}"
        echo -e "${fin}   5)${msg} NZBHydra (Usenet Meta Search)${nc}"
        echo " "
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1')
                deluge.submenu
                ;;
            '2')
                nzbget.submenu
                ;;
            '3')
                sabnzbd.submenu
                ;;
            '4')
                jackett.submenu
                ;;
            '5')
                nzbhydra.submenu
                ;;
            #'i')
            #    moreinfo.submenu.downloadtools
            #    ;;
            'h')
                gethelp
                ;;
            'm')
                return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### DELUGE SUBMENU

deluge.submenu ()
{
while [ "$choice" != "a,h,i,b" ]
do
        echo -e "${sep}"
        echo -e "${fin} Deluge Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${ca}   1)${ca} Install (Currently Unavailable)${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Deluge (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            #'1') echo -e "${inf} Installing..${nc}"
            #    echo " "
            #    confirm.install.deluge
            #    ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.deluge
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.deluge
            #    ;;
            #'a')
            #    about.deluge
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.deluge
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### NZBGET SUBMENU

nzbget.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} NZBGet Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${ca}   3)${msg} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${inf}  a) About NZBGet${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.nzbget
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.nzbget
                ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.nzbget
            #    ;;
            'a')
                about.nzbget
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.nzbget
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SABnzbd SUBMENU

sabnzbd.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} SABnzbd Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${fin}  a) About SABnzbd${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.sabnzbd
                ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.sabnzbd
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.sabnzbd
            #    ;;
            'a')
                about.sabnzbd
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.sabnzbd
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### NZBHydra SUBMENU

nzbhydra.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} NZBHydra Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${ca}   1)${ca} Install (Currently Unavailable)${nc}"
        echo -e "${ca}   2)${ca} Update (Currently Unavailable)${nc}"
        echo -e "${ca}   3)${ca} Backup (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About NZBHydra (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            #'1') echo -e "${inf} Installing..${nc}"
            #    echo " "
            #    confirm.install.nzbhydra
            #    ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.nzbhydra
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.nzbhydra
            #    ;;
            'a')
                about.nzbhydra
                ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.nzbhydra
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

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
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            #'1') echo -e "${inf} Installing..${nc}"
            #    echo " "
            #    confirm.install.jackett
            #    ;;
            #'2') echo -e "${inf} Running Update..${nc}"
            #    echo " "
            #    confirm.update.jackett
            #    ;;
            #'3') echo -e "${inf} Backup..${nc}"
            #    echo " "
            #    backup.jackett
            #    ;;
            #'a')
            #    about.jackett
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.jackett
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### SELF HOSTING SUBMENU

selfhosting.submenu ()
{
while [ "$choice" != "a,h,i,m,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Self Hosting Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one: Host Your Own...${nc}"
        echo " "
        echo -e "${ca}   1)${ca} Web Server (Currently Unavailable)${nc}"
        echo -e "${fin}   2)${msg} Cloud Storage (${lbt}OwnCloud${nc} / ${lbt}Pydio${nc})${nc}"
        echo -e "${ca}   3)${ca} Game Server(s) (Currently Unavailable)${nc}"
        echo -e "${ca}   4)${ca} Voice Servers ${nc}(Teamspeak / Mumble / Vent) (Currently Unavailable)${nc}"
        echo " "
        echo -e "${ca}  a) About Self Hosting (Currently Unavailable)${nc}"
        echo -e "${ca}  i) More Info / How-To's (Currently Unavailable)${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            #'1') echo -e "${inf} Taking you to the Web Server menu..${nc}"
            #    echo " "
            #    webserver.submenu
            #    ;;
            '2') echo -e "${inf} Taking you to the Cloud Services menu..${nc}"
                echo " "
                cloud.submenu
                ;;
            #'3')
            #    gameservers.submenu
            #    ;;
            #'4')
            #    voip.submenu
            #    ;;
            #'a')
            #    about.selhosting
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.selfhosting
            #    ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### WEB SERVER SUBMENU

webserver.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Web Server Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${ca}   4)${ca} Install WordPress (Currently Unavailable)${nc}"
        # (Use above install first)
        echo " "
        echo -e "${inf}  a) About Web Server${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.webserver
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.webserver
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.webserver
                ;;
            #'3') echo -e "${inf} Installing WordPress..${nc}"
            #    echo " "
            #    confirm.install.wordpress
            #    ;;
            'a')
                about.webserver
                ;;
            'h')
                gethelp
                ;;
            'i')
                moreinfo.submenu.webserver
                ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### VOICE SERVERS SUBMENU

voip.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Voice Server Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update${nc}"
        echo -e "${ca}   3)${ca} Backup${nc}"
        echo " "
        echo -e "${ca}  a) About Teamspeak${nc}"
        echo -e "${ca}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.teamspeak3
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.teamspeak3
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.teamspeak3
                ;;
            #'a')
            #    about.teamspeak3
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.teamspeak3
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### TEAMSPEAK SERVER SUBMENU

teamspeak3.submenu ()
{
while [ "$choice" != "a,h,i,b,q" ]
do
        echo -e "${sep}"
        echo -e "${fin} Teamspeak 3 Server Options${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${ca}   2)${ca} Update${nc}"
        echo -e "${ca}   3)${ca} Backup${nc}"
        echo " "
        echo -e "${ca}   4)${ca} Install JTS3ServerMod [Server Bot] (Currently Unavailable)${nc}" # (Use above install first)
        echo -e "${ca}   5)${ca} Update JTS3ServerMod [Server Bot] (Currently Unavailable)${nc}" # (Use above install first)
        echo " "
        echo -e "${ca}  a) About Teamspeak${nc}"
        echo -e "${ca}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
        echo " "
        echo -e "${emp}  b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Installing..${nc}"
                echo " "
                confirm.install.teamspeak3
                ;;
            '2') echo -e "${inf} Running Update..${nc}"
                echo " "
                confirm.update.teamspeak3
                ;;
            '3') echo -e "${inf} Backup..${nc}"
                echo " "
                backup.teamspeak3
                ;;
            #'4') echo -e "${inf} Installing..${nc}"
            #    echo " "
            #    confirm.install.teamspeak3bot
            #    ;;
            #'5') echo -e "${inf} Updating..${nc}"
            #    echo " "
            #    confirm.update.teamspeak3bot
            #    ;;
            #'a')
            #    about.teamspeak3
            #    ;;
            'h')
                gethelp
                ;;
            #'i')
            #    moreinfo.submenu.teamspeak3
            #    ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

#------------------------------------------------------------------------------#
### MUMBLE/MURMUR SERVER SUBMENU

murmur.submenu ()
{

}

#------------------------------------------------------------------------------#
### VENTRILO SERVER SUBMENU

ventrilo.submenu ()
{

}



#------------------------------------------------------------------------------#
### MORE INFORMATION / HOW-TO / FURTHER INSTRUCTIONS SUBMENU (COMBINED)

moreinfo.combined.submenu ()
{
while [ "$choice" != "m" ]
do
        echo -e "${sep}"
        echo -e "${inf} More Info / How-To's Top Menu"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${msg} More info & how-to's about..."
        echo -e "${fin}   1)${msg} OwnCloud"
        echo -e "${fin}   2)${msg} TheBrig (Jails)"
        echo -e "${fin}   3)${msg} Emby"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') moreinfo.submenu.owncloud
                ;;
            '2') moreinfo.submenu.thebrig
                ;;
            '3') moreinfo.submenu.emby
                ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}



#------------------------------------------------------------------------------#
### MORE INFORMATION / HOW-TO / FURTHER INSTRUCTIONS SUBMENU (SPECIFIC)
# YAY OR NAY?

moreinfo.submenu.owncloud ()
{
while [ "$choice" != "m" ]
do
        echo -e "${sep}"
        echo -e "${inf} OwnCloud - Info / How-To's Menu${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${msg} How to...${nc}"
        echo -e "${fin}   1)${msg} Finish the owncloud setup${nc}"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') owncloud.howto.finishsetup
                ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

moreinfo.submenu.thebrig ()
{
while [ "$choice" != "b" ]
do
        echo -e "${sep}"
        echo -e "${inf} TheBrig - Info / How-To's Menu${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${msg} More info about...${nc}"
        echo -e "${fin}   1)${msg} Rudimentary Config${nc}"
        echo " "
        echo -e "${msg} How to...${nc}"
        echo -e "${fin}   2)${msg} Create a jail${nc}"
        echo -e "${fin}   3)${msg} Enable the 'Ports Tree'${nc}"
        echo -e "${fin}   4)${msg} Mount a folder in the jail via fstab${nc}"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1')
                info.thebrig.rudimentaryconfig
                ;;
            '2')
                thebrig.howto.createajail
                ;;
            '3')
                thebrig.howto.enableportstree
                ;;
            '4')
                thebrig.howto.mountviafstab
                ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}

moreinfo.submenu.emby ()
{
while [ "$choice" != "m" ]
do
        echo -e "${sep}"
        echo -e "${inf} Emby - Info / How-To's Menu${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${msg} How to...${nc}"
        echo -e "${fin}   1)${msg} Update FFMPEG (To enable more transcoding options)"
        echo -e "${fin}   2)${msg} Update ImageMagick (To increase server performance)"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') emby.howto.updateffmpeg
                ;;
            'm') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}



### OWNCLOUD ERROR FIXES SUBMENU
#------------------------------------------------------------------------------#

owncloud.errorfix.submenu ()
{
while [ "$choice" != "b" ]
do
        echo -e "${sep}"
        echo -e "${inf} OwnCloud - Fixes For Known Errors${nc}"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Trusted Domain Error"
        echo -e "${fin}   2)${msg} Populating Raw Post Data Error"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} ${nc}"
                owncloud.trusteddomain.fix
                ;;
            '2') echo -e "${inf} ${nc}"
                owncloud.phpini
                ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}



#------------------------------------------------------------------------------#
### OWNCLOUD OTHER OPTIONS SUBMENU

owncloud.otheroptions.menu ()
{
while [ "$choice" != "b" ]
do
        echo -e "${sep}"
        echo -e "${inf} OwnCloud - Other Options"
        echo -e "${sep}"
        echo -e "${qry} Choose one:${nc}"
        echo " "
        echo -e "${fin}   1)${msg} Enable Memory Caching"
        echo " "
        echo -e "${emp}   b) Back${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1') echo -e "${inf} Enabling Memory Caching..${nc}"
                owncloud.enablememcache
                ;;
            'b') return
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done
}



################################################################################
##### MAIN MENU
################################################################################

mainmenu=""

while [ "$choice" != "q,a,h,i,j" ]
do
        echo -e "${sep}"
        echo -e "${inf} AIO Script - Version: 1.0.32 (May 19, 2017) by Nozza"
        echo -e "${sep}"
        echo -e "${emp} Main Menu"
        echo " "
        echo -e "${qry} Please make a selection! ${nc}(It's best to run 1-5 INSIDE of a jail)"
        echo " "
        echo -e "${fin}   1)${url} MySQL/MariaDB + phpMyAdmin${nc}"
        echo -e "${fin}   2)${url} Host Your Own: ${msg}Web Server / Cloud Storage / Game Server / + More${nc}"
        echo -e "         (WordPress / NextCloud / Pydio / Teamspeak etc.)"
        echo -e "${fin}   3)${url} Media Streaming Servers ${nc}(Emby / Plex / Subsonic etc.)"
        echo -e "${fin}   4)${url} Sonarr ${nc}(TV & Anime) / ${url}CouchPotato ${nc}(Movies) / ${url}HeadPhones ${nc}(Music)"
        echo -e "${fin}   5)${url} Download Tools ${nc}(NZBGet - Usenet / Deluge - Torrents)${nc}"
        echo " "
        echo -e "${cmd}   o)${msg} OneButtonInstaller${nc}"
        echo " "
        echo -e "${inf}  a) About This Script${nc}"
        echo -e "${inf}  h) Contact / Get Help${nc}"
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo " "
        echo -e "${alt}   q) Quit${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"
        echo " "

        case $choice in
            '1')
                databases.submenu
                ;;
            '2')
                selfhosting.submenu
                ;;
            '3')
                streaming.submenu
                ;;
            '4')
                searchtools.submenu
                ;;
            '5')
                downloadtools.submenu
                ;;
            'a')
                about.thisscript
                ;;
            'o')
                obi.submenu
                ;;
            'i')
                moreinfo.combined.submenu
                ;;
            'h')
                gethelp
                ;;
            'q')
                echo -e "${alt}     Quitting, Bye!${nc}"
                echo  " "
                echo -e "${ssep}"
                exit
                ;;
            *)   echo -e "${alt}        Invalid choice, please try again${nc}"
                echo " "
                ;;
        esac
done



################################################################################
##### Completed / Almost Complete but fully functional
################################################################################
# Emby
# OwnCloud
# NextCloud


################################################################################
##### In Progress
################################################################################
# Sooo much stuff


################################################################################
##### To-Do's / Future Changes / Planned Additions / etc.
################################################################################

#------------------------------------------------------------------------------#
### General


# FUTURE: Allow users to select owncloud/nextcloud version/ip/port via script
# without the need to edit the script manually.

#------------------------------------------------------------------------------#
### Voice Servers

# LOW-PRIORITY: Finish adding Teamspeak 3 Server & JTS3ServerMod (Server Bot)
# FUTURE: Add "Ventrilo"
# FUTURE: Add "Murmur" (Mumble)

#------------------------------------------------------------------------------#
### Media Download / Search / Management

# FUTURE: Add "Mylar" (Comic Books)
# FUTURE: Add "LazyLibrarian" (Books)
# FUTURE: Add "Sickbeard" (TV/Anime)
# FUTURE: Add "XDM"
# FUTURE: Finish adding "Calibre" (Books)

# FUTURE: Add "Radarr"
# FUTURE: Add "Watcher" (Movies - CouchPotato Alternative)


# FUTURE: Add "HTPC Manager" (Combines many services in one interface)

# FUTURE: Add "NZBHydra" (Meta search for NZB indexers)
# FUTURE: Add "Jackett" (Meta search for torrents)

# LOW-PRIORITY: Finish "Deluge" scripts (Lots of issues with it)

#------------------------------------------------------------------------------#
### Media Server

# FUTURE: Add "Plex"
    # Maybe utilize ezPlex Portable Addon by JoseMR? (With permission of course)

        # INSTALL
        # cd $(myappsdir)
        # fetch https://raw.githubusercontent.com/JRGTH/nas4free-plex-extension/master/plex-install.sh && chmod +x plex-install.sh && ./plex-install.sh

        # UPDATE
        # fetch https://raw.githubusercontent.com/JRGTH/nas4free-plex-extension/master/plex/plexinit && chmod +x plexinit && ./plexinit

    # Or make use of OneButtonInstaller by "Crest"
    # If not, use ports tree or whatever, will decide later.

# FUTURE: Add "Serviio"
# FUTURE: Add "SqueezeBox"
# FUTURE: Add "UMS (Universal Media Server)"
# FUTURE: If this script has no issues then i may remove standalone scripts from github
# FUTURE: IF & when jail creation via shell is possible for thebrig, will add that option to script.

#------------------------------------------------------------------------------#
### Web Server / Cloud Server

# FUTURE: Add "Pydio"

#------------------------------------------------------------------------------#
### Databases

# FUTURE: Add "MariaDB"

#------------------------------------------------------------------------------#
### System Monitoring

# LOW-PRIORITY: Finish adding "Munin"

# FUTURE: Add "Monit" (Free) & "M/Monit" (Free Trial but requires purchase)
# "M/Monit" is NOT required to be able to use "Monit"
    #pkg install monit
    #echo 'monit_enable="YES"' >> /etc/rc.conf
    #cp /usr/local/etc/monitrc.sample /usr/local/etc/monitrc
    #chmod 600 /usr/local/etc/monitrc
    #service monit start
# FUTURE: Add "Zabbix"
# FUTURE: Add "Pandora"
# FUTURE: Add "Icinga"
# FUTURE: Add "Observium"
# FUTURE: Add "Cacti"
# FUTURE: Add "Nagios"
# FUTURE: Add "nTop"
# FUTURE: Add "Grafana"

#------------------------------------------------------------------------------#
### XMPP Server

# FUTURE: Add "Jabber" Server (Or Prosody as i'm pretty sure that is easier to set up)
    #pkg install ejabberd
    #echo 'ejabberd_enable="YES"' >> /etc/rc.conf
    #cp /usr/local/etc/ejabberd/ejabberd.yml.example /usr/local/etc/ejabberd/ejabberd.yml
    #chown 543:543 /usr/local/etc/ejabberd/ejabberd.yml
    #service ejabberd start

#------------------------------------------------------------------------------#
### Other

# FUTURE: Add "Mail Server"
# FUTURE: Add OneButtonInstaller
    # http://www.nas4free.org/forums/viewtopic.php?f=71&t=11189
    # fetch https://raw.github.com/crestAT/nas4free-onebuttoninstaller/master/OBI.php && mkdir -p ext/OBI && echo '<a href="OBI.php">OneButtonInstaller</a>' > ext/OBI/menu.inc && echo -e "\nDONE"


################################################################################
# By Ashley Townsend (Nozza)    Copyright: Beerware License
################################################################################
