######
######  MADE BY @ArthurCNS
######  03/27/2023 (mm-dd-yyyy)
######

# Configuration code

CONF_WEB_DOMAIN_NAME="my-domain.xyz"
CONF_WEB_DIR="/var/www"
CONF_LOG_DIR="/var/log/apache2"
CONF_VHOST_DIR="/etc/apache2/sites-available"

######
######      IN CASE YOU ARE NOT FAMILIAR WITH SHELL SCRIPTING,
######     DON'T TOUCH ANYTHING FROM HERE, YOU CAN BREAK ALL THE SCRIPT.
######

###### Installation functions

update_system()
{
    echo "Updating apps.."
    sleep 1
    apt update
    sleep 1
    clear
    echo "Installing packages.."
    apt install apache2 mariadb-server libapache2-mod-php7.4 php php-mysql php-intl php-cli php-mbstring php-gd php-xml php-cgi php-curl php-zip -y
    sleep 1
    clear
}

glpi_install()
{
    ###### Create root web directory.
    echo "----------"
    echo "Creating web directory: GLPI"
    mkdir ${CONF_WEB_DIR}/glpi
    chown -R www-data:www-data ${CONF_WEB_DIR}/glpi
    sleep 1

    ###### Creating logs directory.
    echo "----------"
    echo "Creating logs directory: GLPI"
    mkdir ${CONF_LOG_DIR}/glpi
    touch ${CONF_LOG_DIR}/glpi/error.log
    touch ${CONF_LOG_DIR}/glpi/access.log
    sleep 1

    ###### Create virtual hosts.
    echo "----------"
    echo "Creating virtual host: GLPI"
    sleep 1
    echo "<VirtualHost *:80>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tServerName glpi.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tServerAlias www.glpi.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tDocumentRoot ${CONF_WEB_DIR}/glpi" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tServerAdmin webmaster@localhost" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tErrorLog \${APACHE_LOG_DIR}/glpi/error.log" >> ${CONF_VHOST_DIR}/glpi.conf
    #echo "\tCustomLog \${APACHE_LOG_DIR}/glpi/access.log" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tRewriteEngine On" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tRewriteCond %{HTTPS} off" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tRewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\t<Directory /var/www/glpi/>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tOptions -Indexes +FollowSymLinks +MultiViews" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tAllowOverride All" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tRequire all granted" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t</Directory>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n</VirtualHost>" >> ${CONF_VHOST_DIR}/glpi.conf

    echo "\n<VirtualHost *:443>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tServerName glpi.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tServerAlias www.glpi.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tDocumentRoot ${CONF_WEB_DIR}/glpi" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\tServerAdmin webmaster@localhost" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tErrorLog \${APACHE_LOG_DIR}/glpi/error.log" >> ${CONF_VHOST_DIR}/glpi.conf
    #echo "\tCustomLog \${APACHE_LOG_DIR}/glpi/access.log" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n\tSSLEngine On" >> ${CONF_VHOST_DIR}/glpi.conf

    ###### Generating custom cert or use apache self-signed cert. 
    echo "----------"
    echo "Generating custom (self-signed) certificate? (Y/N)"
    read GenerateSelfSignedCertChoice1
    if [ "$GenerateSelfSignedCertChoice1" = "y" -o "$GenerateSelfSignedCertChoice1" = "Y" -o -z "$GenerateSelfSignedCertChoice1" ] 
    then
        sleep 1
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/glpi-customss-cert.key -out /etc/ssl/certs/glpi-customss-cert.crt
        sleep 2
        echo "\tSSLCertificateFile	/etc/ssl/certs/glpi-customss-cert.crt" >> ${CONF_VHOST_DIR}/glpi.conf
        echo "\tSSLCertificateKeyFile /etc/ssl/private/glpi-customss-cert.key" >> ${CONF_VHOST_DIR}/glpi.conf
    else
        echo "SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem" >> ${CONF_VHOST_DIR}/glpi.conf
        echo "SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key" >> ${CONF_VHOST_DIR}/glpi.conf
    fi

    echo "\n\t<Directory /var/www/glpi/>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tOptions -Indexes +FollowSymLinks +MultiViews" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tAllowOverride All" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t\tRequire all granted" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\t</Directory>" >> ${CONF_VHOST_DIR}/glpi.conf
    echo "\n</VirtualHost>" >> ${CONF_VHOST_DIR}/glpi.conf

    sleep 1
    echo "Virtual host has been created for: GLPI."
    
    ###### Download GLPI repos
    echo "----------"
    echo "Downloading GLPI 10.0.6"
    sleep 1
    cd ${CONF_WEB_DIR}/glpi/
    wget https://github.com/glpi-project/glpi/releases/download/10.0.6/glpi-10.0.6.tgz%20
    sleep 1
    echo "Download complete."
    sleep 2
    echo "----------"
    echo "Extracting files.."
    sleep 1
    tar -xvzf 'glpi-10.0.6.tgz '
    sleep 2
    echo "----------"
    echo "Removing old folders.."
    sleep 1
    rm 'glpi-10.0.6.tgz '
    cd glpi
    mv * ..
    mv .htaccess ..
    cd ..
    rm -Rf glpi/
    chown -R www-data:www-data ${CONF_WEB_DIR}/glpi
    sleep 1
    echo "Old folders removed."
    sleep 2

    ###### Create GLPI database
    echo "----------"
    echo "Creating database.."
    mysql -e "CREATE DATABASE glpi_db;"
    mysql -e "CREATE USER glpi_user@localhost IDENTIFIED BY 'PepsIT2023-';"
    mysql -e "GRANT ALL PRIVILEGES ON glpi_db.* TO 'glpi_user'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    sleep 1
    echo "Database has been created."
    sleep 2

    ###### Enable virtual host.
    echo "----------"
    echo "Enabling website: GLPI"
    cd ${CONF_VHOST_DIR}
    a2ensite glpi.conf
    sleep 1
    echo "Website has been enabled."
    sleep 2
}

intranet_install()
{
    ###### Create root web directory.
    echo "----------"
    echo "Creating web directory: INTRANET"
    mkdir ${CONF_WEB_DIR}/intranet
    chown -R www-data:www-data ${CONF_WEB_DIR}/intranet
    sleep 1

    ###### Creating logs directory.
    echo "----------"
    echo "Creating logs directory: INTRANET"
    mkdir ${CONF_LOG_DIR}/intranet
    touch ${CONF_LOG_DIR}/intranet/error.log
    touch ${CONF_LOG_DIR}/intranet/access.log
    sleep 1

    ###### Create virtual hosts.
    echo "----------"
    echo "Creating virtual host: INTRANET"
    sleep 1
    echo "<VirtualHost *:80>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tServerName intranet.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tServerAlias www.intranet.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tDocumentRoot ${CONF_WEB_DIR}/intranet" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tServerAdmin webmaster@localhost" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tErrorLog \${APACHE_LOG_DIR}/intranet/error.log" >> ${CONF_VHOST_DIR}/intranet.conf
    #echo "\tCustomLog \${APACHE_LOG_DIR}/intranet/access.log combined" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tRewriteEngine On" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tRewriteCond %{HTTPS} off" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tRewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\t<Directory /var/www/intranet/>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tOptions -Indexes +FollowSymLinks +MultiViews" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tAllowOverride All" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tRequire all granted" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t</Directory>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n</VirtualHost>" >> ${CONF_VHOST_DIR}/intranet.conf

    echo "\n<VirtualHost *:443>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tServerName intranet.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tServerAlias www.intranet.${CONF_WEB_DOMAIN_NAME}" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tDocumentRoot ${CONF_WEB_DIR}/intranet" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\tServerAdmin webmaster@localhost" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tErrorLog \${APACHE_LOG_DIR}/intranet/error.log" >> ${CONF_VHOST_DIR}/intranet.conf
    #echo "\tCustomLog \${APACHE_LOG_DIR}/intranet/access.log combined" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n\tSSLEngine On" >> ${CONF_VHOST_DIR}/intranet.conf

    ###### Generating custom cert or use apache self-signed cert. 
    echo "----------"
    echo "Generating custom (self-signed) certificate? (Y/N)"
    read GenerateSelfSignedCertChoice2
    if [ "$GenerateSelfSignedCertChoice2" = "y" -o "$GenerateSelfSignedCertChoice2" = "Y" -o -z "$GenerateSelfSignedCertChoice2" ] 
    then
        sleep 1
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/intranet-customss-cert.key -out /etc/ssl/certs/intranet-customss-cert.crt
        sleep 2
        echo "\tSSLCertificateFile	/etc/ssl/certs/intranet-customss-cert.crt" >> ${CONF_VHOST_DIR}/intranet.conf
        echo "\tSSLCertificateKeyFile /etc/ssl/private/intranet-customss-cert.key" >> ${CONF_VHOST_DIR}/intranet.conf
    else
        echo "SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem" >> ${CONF_VHOST_DIR}/intranet.conf
        echo "SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key" >> ${CONF_VHOST_DIR}/intranet.conf
    fi

    echo "\n\t<Directory /var/www/intranet/>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tOptions -Indexes +FollowSymLinks +MultiViews" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tAllowOverride All" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t\tRequire all granted" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\t</Directory>" >> ${CONF_VHOST_DIR}/intranet.conf
    echo "\n</VirtualHost>" >> ${CONF_VHOST_DIR}/intranet.conf

    sleep 1
    echo "Virtual host has been created for: INTRANET."

    ###### Download Wordpress for intranet
    echo "----------"
    echo "Downloading: Wordpress Latest version.."
    sleep 1
    cd ${CONF_WEB_DIR}/intranet
    wget https://fr.wordpress.org/latest-fr_FR.tar.gz
    sleep 1
    echo "Wordpress latest version has been downloaded."
    sleep 2
    echo "----------"
    echo "Extracting files.."
    sleep 1
    tar -xvzf 'latest-fr_FR.tar.gz'
    sleep 2
    echo "----------"
    echo "Removing old folders.."
    sleep 1
    rm 'latest-fr_FR.tar.gz'
    cd wordpress
    mv * ..
    cd ..
    rm -Rf wordpress/
    chown -R www-data:www-data ${CONF_WEB_DIR}/intranet
    sleep 1
    echo "Old folders removed."
    sleep 2

    ###### Create Wordpress database
    echo "----------"
    echo "Creating database.."
    mysql -e "CREATE DATABASE wordpress_db;"
    mysql -e "CREATE USER wordpress_user@localhost IDENTIFIED BY 'PepsIT2023-';"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    sleep 1
    echo "Databse has been created."

    ###### Enable virtual host.
    echo "----------"
    echo "Enabling website: INTRANET"
    cd ${CONF_VHOST_DIR}
    a2ensite intranet.conf
    sleep 1
    echo "Website has been enabled."
    sleep 2
}

init_main()
{
    echo "----------"
    echo "Which web server do you want to install? (1, 2 or 3)"
    echo "1. GLPI Web Server"
    echo "2. Wordpress Web Server"
    echo "3. Both (GLPI & Wordpress)"
    read userInputChoice

    if [ "$userInputChoice" = "1" -o -z "$userInputChoice" ] 
    then
        glpi_install

        ###### Enable "Rewrite" module to force HTTP -> HTTPS.
        echo "----------"
        echo "Enabling modules: Rewrite (needed for web redirections)"
        a2enmod rewrite
        sleep 1
        echo "Module "Rewrite" has been enabled."
        sleep 2

        ###### Restarting Apache2 service to apply all changes.
        echo "----------"
        echo "Restarting service: Apache2"
        systemctl restart apache2
        sleep 1
        echo "Service "Apache2" has been restarted."
        sleep 2

        echo "Script is finished."
        echo "\n----------"
        echo "Don't forget to complete GLPI installation through your web browser:"
        echo "\nDatabase server: 127.0.0.1 (or localhost) \nDatabase name: glpi_db \nDatabase user: glpi_user \nDatabase password: PepsIT2023- \nUrl: https://glpi.${CONF_WEB_DOMAIN_NAME}/"
        echo "\n\nMade by @lwzff, 03/27/2023 (mm-dd-yyyy). \n"

    elif [ "$userInputChoice" = "2" -o -z "$userInputChoice" ] 
    then
        intranet_install

        ###### Enable "Rewrite" module to force HTTP -> HTTPS.
        echo "----------"
        echo "Enabling modules: Rewrite (needed for web redirections)"
        a2enmod rewrite
        sleep 1
        echo "Module "Rewrite" has been enabled."
        sleep 2

        ###### Restarting Apache2 service to apply all changes.
        echo "----------"
        echo "Restarting service: Apache2"
        systemctl restart apache2
        sleep 1
        echo "Service "Apache2" has been restarted."
        sleep 2

        echo "Script is finished."
        echo "\n----------"
        echo "Don't forget to complete GLPI installation through your web browser:"
        echo "\nDatabase name: wordpress_db \nDatabase user: wordpress_user \nDatabase password: PepsIT2023- \nUrl: https://intranet.${CONF_WEB_DOMAIN_NAME}/"
        echo "\n\nMade by @lwzff, 03/27/2023 (mm-dd-yyyy). \n"

    elif [ "$userInputChoice" = "3" -o -z "$userInputChoice" ]
    then
        glpi_install
        intranet_install

        ###### Enable "Rewrite" module to force HTTP -> HTTPS.
        echo "----------"
        echo "Enabling modules: Rewrite (needed for web redirections)"
        a2enmod rewrite
        sleep 1
        echo "Module "Rewrite" has been enabled."
        sleep 2

        ###### Restarting Apache2 service to apply all changes.
        echo "----------"
        echo "Restarting service: Apache2"
        systemctl restart apache2
        sleep 1
        echo "Service "Apache2" has been restarted."
        sleep 2

        echo "Script is finished."
        echo "\n----------"
        echo "Don't forget to complete GLPI & Wordpress installation through your web browser:"
        echo "\nGLPI\nDatabase name: glpi_db \nDatabase user: glpi_user \nDatabase password: PepsIT2023- \nUrl: https://glpi.${CONF_WEB_DOMAIN_NAME}/"
        echo "\nWORDPRESS\nDatabase name: wordpress_db \nDatabase user: wordpress_user \nDatabase password: PepsIT2023- \nUrl: https://intranet.${CONF_WEB_DOMAIN_NAME}/"
        echo "\n\nMade by @lwzff, 03/27/2023 (mm-dd-yyyy). \n"
    fi
}

###### Main code

update_system
init_main