
# GLPI & Wordpress Auto-Deployment

Here is a quick **shell** script to "deploy" GLPI *nor* Wordpress.

⚠️ This script was made for a school project, so don't be afraid about the shit code I wrote, it's working 🙂👍


## Deployment

To deploy this project, clone it like a classic GitHub Repository or download it (zip format).

*Unzip, in case you downloaded the zip one.*


#### Starting
You can edit four lines of the script' configuration.

Important one is the first one at line 8:
`CONF_WEB_DOMAINE_NAME="my-domain.xyz"`

Use a public domain name, it will be used to access to your web servers:
- glpi.**my-domain.xyz**
- intranet.**my-domain.xyz**

Then, simply run the shell script:

```bash
  sh install.sh
```

#### ⚠ Warning ⚠️

It will update your system by using: `apt update`. Also, it will install through `apt install` all the following packages:

- Apache2
- MariaDB Server
- PHP
- PHP-MYSQL
- PHP-INTL
- PHP-CLI
- PHP-MBSTRING
- PHP-GD
- PHP-XML
- PHP-CGI
- PHP-CURL
- PHP-ZIP



## Author

Myself, find me here:
- [Twitter](https://www.twitter.com/lwzff)
- [GitHub](https://www.github.com/lwzff)

