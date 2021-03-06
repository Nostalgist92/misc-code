#!/bin/sh
# NextCloud Script v2           Version: 2.0.4 (May 17, 2017)
# By Ashley Townsend (Nozza)    Copyright: Beerware License
#===============================================================================

#Grab the date & time to be used later
backupdate=$(date +"%Y.%m.%d-%I.%M%p")

# Add some colour!
nc='\033[0m'        # No Color
alt='\033[0;31m'    # Alert Text
emp='\033[1;31m'    # Emphasis Text
msg='\033[1;37m'    # Message Text
url='\033[1;32m'    # URL
qry='\033[0;36m'    # Query Text
sep='\033[1;30m-------------------------------------------------------\033[0m'    # Line Seperator
ssep='\033[1;30m#----------------------#\033[0m'    # Small Line Seperator
cmd='\033[1;35m'    # Command to be entered
fin='\033[0;32m'    # Green Text
inf='\033[0;33m'    # Information Text

# define our bail out shortcut function anytime there is an error - display
# the error message, then exit returning 1.
exerr () { echo -e "$*" >&2 ; exit 1; }



################################################################################
##### INSTALLERS
# TODO: Test
################################################################################


install.cloud ()
{

nextcloud.install.continue ()
{
echo " "
echo -e "${msep}"
echo -e "${emp}   Press Enter To Continue${nc}"
echo -e "${msep}"
echo " "
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
nextcloud.install.continue
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

cloud.trusteddomain.fix ()
{
# Confirm with the user
echo " "
echo -e "${emp} Please finish the nextcloud setup before continuing${nc}"
echo -e "${msg} Head to ${url}https://$userselected_ip:$userselected_port ${msg}to do this.${nc}"
echo -e "${msg} Fill out the page you are presented with and hit finish${nc}"
echo " "
echo -e "${msg} Admin username & password = whatever you choose${nc}"
echo " "
echo -e "${emp} Make sure you click 'Storage & database'${nc}"
echo " "
echo -e "${msg} Database user = ${qry}root${nc} | Database password = ${nc}"
echo -e "${msg} the ${qry}mysql password${msg} you chose earlier during the script.${nc}"
echo -e "${msg} Database name = ${database_name} ${nc}"
echo " "
echo " Once the page reloads,"
read -r -p "   do you have a 'untrusted domain' error? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, let's fix that.
              echo " "
              echo -e "${url} Doing some last second changes to fix that..${nc}"
              echo " "
              # Prevent "Trusted Domain" error
              echo "    '${userselected_ip}'," >> /usr/local/www/nextcloud/config/trusted.txt
              cp /usr/local/www/nextcloud/config/config.php /usr/local/www/nextcloud/config/old_config.bak
              cat "/usr/local/www/nextcloud/config/old_config.bak" | \
                sed '8r /usr/local/www/nextcloud/config/trusted.txt' > \
                "/usr/local/www/nextcloud/config/config.php"
              rm /usr/local/www/nextcloud/config/trusted.txt
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

cloud.trusteddomain.fix

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

nextcloud.install.continue

}

################################################################################
##### CONTACT
################################################################################

help ()
{
while [ "$choice" ]
do
        echo -e "${inf} Ways of contacting me / getting help from others:${nc}"
        echo " "
        echo -e "${fin}   My Discord Support (Usually faster responses):${nc}"
        echo -e "${msg}      https://discord.gg/0bXnhqvo189oM8Cr${nc}"
        echo -e "${fin}   My Email (Might add this later, Discord is easier though):${nc}"
        echo -e "${msg}      myemail@domain.com${nc}"
        echo -e "${fin}   Forums:${nc}"
        echo -e "${msg}      NAS4Free Forums:${nc}"
        echo -e "${url}      http://forums.nas4free.org/viewtopic.php?f=79&t=9383${nc}"
        echo -e "${msg}      VS Forums:${nc}"
        echo -e "${url}      forums.vengefulsyndicate.com${nc}"
        echo " "
        echo -e "${emp}   Press Enter To Go Back To The Main Menu${nc}"

        read choice

        case $choice in
            *)
                 return
                 ;;
        esac
done
}

################################################################################
##### OTHER OPTIONS
################################################################################

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

        echo -e " Head to your nextcloud admin page/refresh it${nc}"
        echo -e " There should no longer be a message at the top about memory caching${nc}"
        echo -e " If it didn't work follow these steps:${nc}"
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

howtofinishsetup ()
{
echo " "
echo -e "${emp} Follow these instructions carefully"
echo " "
echo -e "${msg} In a web browser, head to: ${url}https://$server_ip:$server_port${nc}"
echo " "
echo -e "${msg} Admin Username: Enter your choice of username${nc}"
echo -e "${msg} Admin Password: Enter your choice of password${nc}"
echo " "
echo -e "${alt}    Click Database options and choose MySQL${nc}"
echo -e "${msg} Database username: root${nc}"
echo -e "${msg} Database password: THE PASSWORD YOU ENTERED EARLIER FOR MYSQL${nc}"
echo -e "${msg} Database host: Leave as is (Should be localhost)${nc}"
echo -e "${msg} Database name: Your choice (nextcloud is fine)${nc}"
echo " "
echo -e "${emp} Click Finish Setup, the page will take a moment to refresh${nc}"
echo -e "${msg} After it refreshes, if you are seeing a 'Trusted Domain' error,${nc}"
echo -e "${msg} Head back to the scripts main menu and select option 4.${nc}"
echo " "
}



################################################################################
##### FIXES
################################################################################

trusteddomainfix ()
{
# Confirm with the user
echo " "
echo -e "${emp} Please finish the nextcloud setup before continuing${nc}"
echo -e "${msg} Head to ${url}https://$server_ip:$server_port ${msg}to do this.${nc}"
echo -e "${msg} Fill out the page you are presented with and hit finish${nc}"
echo " "
echo -e "${msg} Admin username & password = whatever you choose${nc}"
echo " "
echo -e "${emp} Make sure you click 'Storage & database'${nc}"
echo " "
echo -e "${msg} Database user = ${qry}root${nc} | Database password = ${nc}"
echo -e "${msg} the ${qry}mysql password${msg} you chose earlier during the script.${nc}"
echo -e "${msg} Database name = your choice (just ${qry}nextcloud${msg} is fine)${nc}"
echo " "
echo " When trying to access nextcloud"
read -r -p "   do you have a 'untrusted domain' error? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, let's fix that.
              echo " "
              echo -e "${url} Doing some last second changes to fix that..${nc}"
              echo " "
              # Prevent "Trusted Domain" error
              echo "    '${userselected_ip}'," >> /usr/local/www/nextcloud/config/trusted.txt
              cp /usr/local/www/nextcloud/config/config.php /usr/local/www/nextcloud/config/old_config.bak
              cat "/usr/local/www/nextcloud/config/old_config.bak" | \
                sed '8r /usr/local/www/nextcloud/config/trusted.txt' > \
                "/usr/local/www/nextcloud/config/config.php"
              rm /usr/local/www/nextcloud/config/trusted.txt
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
### Populating Raw Post Data Fix
#------------------------------------------------------------------------------#

phpini ()
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
##### UPDATERS
# TODO: Merge nextcloud_update.sh in to this script.
################################################################################

update.nextcloud ()
{
echo " "
echo -e "${sep}"
echo -e "${msg}     Welcome to the NextCloud Updater!${nc}"
echo -e "${sep}"
echo " "
echo " "
echo " "
echo -e "${sep}"
echo -e "${msg}     Let's start with downloading the update.${nc}"
echo -e "${sep}"
echo " "

cd "/tmp"
fetch "https://download.nextcloud.org/community/nextcloud-${nextcloud_update}.tar.bz2"

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
mkdir -p /usr/local/www/.nextcloud-backup

# Copy current install to backup directory
# mv /usr/local/www/nextcloud  /usr/local/www/.nextcloud-backup/nextcloud-${backupdate} # NOTE: May not need this but leaving it in just in case
cp -R /usr/local/www/nextcloud  /usr/local/www/.nextcloud-backup/nextcloud-${backupdate}

echo -e "${msg} Backup of current install made in:${nc}"
echo -e "${qry}     /usr/local/www/.nextcloud-backup/nextcloud-${nc}\033[1;36m${backupdate}${nc}"
echo -e "${msg} Keep note of this just in case something goes wrong with the update${nc}"

echo " "
echo -e "${sep}"
echo -e "${msg}     Now to extract NextCloud in place of the old install.${nc}"
echo -e "${sep}"
echo " "

tar xf "nextcloud-${nextcloud_update}.tar.bz2" -C /usr/local/www
echo " Done!"
# Give permissions to www
chown -R www:www /usr/local/www/

#echo " " # NOTE: May not need the next few lines but leaving them in just in case
#echo -e "${sep}"
#echo -e "${msg}     Restore nextcloud config, /data & /themes${nc}"
#echo -e "${sep}"
#echo " "

# cp -R /usr/local/www/.nextcloud-backup/nextcloud-${backupdate}/data /usr/local/www/nextcloud/
# cp -R /usr/local/www/.nextcloud-backup/nextcloud-${backupdate}/themes/* /usr/local/www/nextcloud/
# cp /usr/local/www/.nextcloud-backup/nextcloud-${backupdate}/config/config.php /usr/local/www/nextcloud/config/

echo " "
echo -e "${sep}"
echo -e "${msg}     Starting the web server back up${nc}"
echo -e "${sep}"
echo " "

/usr/local/etc/rc.d/lighttpd start

echo " "
echo -e "${sep}"
echo -e "${msg} That should be it!${nc}"
echo -e "${msg} Now head to your NextCloud webpage and make sure everything is working correctly.${nc}"
echo " "
echo -e "${msg} If something went wrong you can do the following to restore the old install:${nc}"
echo -e "${cmd}   rm -r /usr/local/www/nextcloud${nc}"
echo -e "${cmd}   mv /usr/local/www/.nextcloud-backup/nextcloud-${backupdate} /usr/local/www/nextcloud${nc}"
echo " "
echo -e "${msg} After you check to make sure everything is working fine as expected,${nc}"
echo -e "${msg} You can safely remove backups with this command (May take some time):${nc}"
echo -e "${cmd}   rm -r /usr/local/www/.nextcloud-backup${nc}"
echo -e "${alt} THIS WILL REMOVE ANY AND ALL BACKUPS MADE BY THIS SCRIPT${nc}"
echo " "
echo -e "${sep}"
echo " "
}



################################################################################
##### BACKUPS
# TODO: Create backup script
################################################################################

backup.cloud ()
{
echo -e "${emp} This part of the script is unfinished currently :("

# Create inital backup folder if it doesn't exist
mkdir -p /usr/local/www/.nextcloud-backup

# Copy current install to backup directory
# mv /usr/local/www/nextcloud  /usr/local/www/.nextcloud-backup/nextcloud-${backupdate} # NOTE: May not need this but leaving it in just in case
cp -R /usr/local/www/nextcloud  /usr/local/www/.nextcloud-backup/nextcloud-${backupdate}

echo -e "${msg} Backup of current install made in:${nc}"
echo -e "${qry}     /usr/local/www/.nextcloud-backup/nextcloud-${nc}\033[1;36m${backupdate}${nc}"
echo -e "${msg} Keep note of this.${nc}"

}



################################################################################
##### SUBMENUS
################################################################################

### ERROR FIXES SUBMENU
#------------------------------------------------------------------------------#

cloud.errorfix.submenu ()
{
while [ "$choice" != "q,m" ]
do
        echo -e "${qry} Choose one:"
        echo " "
        echo -e "${fin}   1)${msg} Trusted Domain Error"
        echo -e "${fin}   2)${msg} Populating Raw Post Data Error"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1') echo -e "${inf} ${nc}"
                trusteddomainfix
                ;;
            '2') echo -e "${inf} ${nc}"
                phpini
                ;;
            'm') return
                ;;
        esac
done
}



#------------------------------------------------------------------------------#
### FOR OTHER OPTIONS SUCH AS ENABLING MEMORY CACHING
#------------------------------------------------------------------------------#

cloud.otheroptions.menu ()
{
while [ "$choice" != "q,m" ]
do
        echo -e "${qry} Choose one:"
        echo " "
        echo -e "${fin}   1)${msg} Enable Memory Caching"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1') echo -e "${inf} Enabling Memory Caching..${nc}"

						echo " "
						echo "${sep}"
						echo -e "${emp} APCu memory cache is currently unavailable on BSD systems :(${nc}"
						echo "${sep}"
						echo " "

                #nextcloud.enablememcache
                ;;
            'm') return
                ;;
        esac
done
}



#------------------------------------------------------------------------------#
### MORE INFORMATION / HOW-TO / FURTHER INSCTRUCTIONS
#------------------------------------------------------------------------------#

moreinfo ()
{
while [ "$choice" != "q,m" ]
do
        echo -e "${qry} Choose one:"
        echo " "
        echo -e "${msg} How to..."
        echo -e "${fin}   1)${msg} Finish the nextcloud setup"
        echo " "
        echo -e "${emp}   m) Main Menu${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1') howtofinishsetup
                ;;
            'm') return
                ;;
        esac
done
}



################################################################################
##### CONFIRMATIONS
################################################################################

### INSTALL CONFIRMATIONS
#------------------------------------------------------------------------------#

confirm.install.cloud ()
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
echo -e "${url} Awesome, now we are ready to get on with it!${nc}"
# Confirm with the user
echo -e "${inf} Final confirmation before installing nextcloud.${nc}"
read -r -p "   Confirm Installation of NextCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              install.cloud
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

confirm.update.cloud ()
{
# Confirm with the user
echo " "
echo -e "${alt} This updater is untested and may not work at all${nc}"
echo -e "${emp} Do NOT use this on a primary live server without testing${nc}"
echo -e "${msg} Proceed at your own risk${nc}"
echo " "
echo " Highly recommended to Backup first"
read -r -p "   Confirm Update of NextCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              update.nextcloud
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}

#------------------------------------------------------------------------------#
### BACKUP CONFIRMATIONS
#------------------------------------------------------------------------------#

confirm.backup.cloud ()
{
# Confirm with the user
read -r -p "   Confirm Backup of NextCloud? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
              # If yes, then continue
              backup.cloud
               ;;
    *)
              # Otherwise exit...
              echo " "
              return
              ;;
esac
}



################################################################################
##### MAIN MENU
################################################################################

mainmenu=""

while [ "$choice" != "q,i,h" ]
do
        echo -e "${sep}"
        echo -e "${inf} NextCloud Script - Version: 2.0.4 (May 17, 2017)"
        echo -e "${sep}"
        echo -e "${emp} Main Menu"
        echo " "
        echo -e "${qry} Please make a selection!"
        echo " "
        echo -e "${fin}   1)${msg} Install${nc}"
        echo -e "${fin}   2)${msg} Update${nc}"
        echo -e "${fin}   3)${msg} Backup${nc}"
        echo " "
        echo -e "${fin}   4)${msg} Fix Known Errors${nc}"
        echo -e "${fin}   5)${msg} Other${nc}"
        echo " "
        echo -e "${inf}  i) More Info / How-To's${nc}"
        echo -e "${inf}  h) Get Help${nc}"
		echo " "
        echo -e "${alt}  q) Quit${nc}"

        echo -e "${ssep}"
        read -r -p "     Your choice: " choice
        echo -e "${ssep}"

        case $choice in
            '1')
                confirm.install.cloud
                ;;
            '2')
                confirm.update.cloud
                ;;
            '3')
                confirm.backup.cloud
                ;;
            '4')
                cloud.errorfix.submenu
                ;;
            '5')
                cloud.otheroptions.menu
                ;;
            'i')
                moreinfo
                ;;
            'h')
                help
                ;;
            'q') echo " "
                echo -e "${alt}        Quitting, Bye!${nc}"
                echo  " "
                exit
                ;;
            *)   echo -e "${emp}        Invalid choice, please try again${nc}"
                ;;
        esac
done



#------------------------------------------------------------------------------#
### Todo / Changes:
#------------------------------------------------------------------------------#

# FUTURE: Add MySQL alternative setup options
# FUTURE: Add LetsEncrypt SSL certificate setup. Will require some info about
# 		  port forwarding
