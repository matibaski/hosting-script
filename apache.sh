#!/bin/bash
apacheconfig="<VirtualHost *:80>\n
  \tServerName "$domain"\n
  \tServerAlias www."$domain"\n
  \tServerAdmin serveradmin@coundco.ch\n
  \tDocumentRoot "$hostingfolders"/"$domain"/htdocs\n
  \t<Directory "$hostingfolders"/"$domain"/htdocs>\n
  \t\t        Options All\n
  \t\t        AllowOverride All\n
  \t\t        Order allow,deny\n
  \t\t        allow from all\n
  \t</Directory>\n
\n
  \t# CGI BIN location\n
  \tScriptAlias /cgi-bin/ "$hostingfolders"/"$domain"/cgi-bin/\n
  \t<Directory \""$hostingfolders"/"$domain"/cgi-bin\">\n
  \t\t        AllowOverride None\n
  \t\t        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch\n
  \t\t        Order allow,deny\n
  \t\t        Allow from all\n
  \t</Directory>\n
\n
  \t# Log Settings\n
  \tErrorLog "$hostingfolders"/"$domain"/logs/error.log\n
  \tLogLevel warn\n
  \tCustomLog "$hostingfolders"/"$domain"/logs/access.log combined\n
</VirtualHost>\n
\n"
      
apachessl="<VirtualHost *:443>\n
  \tServerName "$domain"\n
  \tServerAlias www."$domain"\n
  \tServerAdmin serveradmin@coundco.ch\n
\n
  \t#SSLEngine on\n
  \t#SSLCertificateFile      /etc/apache2/ssl/crt-file.crt\n
  \t#SSLCertificateKeyFile   /etc/apache2/ssl/key-file.key\n
  \t#SSLCACertificateFile    /etc/apache2/ssl/ca-cert-file.pem\n
\n
  \tDocumentRoot "$hostingfolders"/"$domain"/htdocs\n
  \t<Directory "$hostingfolders"/"$domain"/htdocs>\n
    \t\tOptions All\n
    \t\tAllowOverride All\n
    \t\tOrder allow,deny\n
    \t\tallow from all\n
  \t</Directory>\n
\n
  \t#CGI BIN location\n
  \tScriptAlias /cgi-bin/ "$hostingfolders"/"$domain"/cgi-bin/\n
  \t<Directory \""$hostingfolders"/"$domain"/cgi-bin\">\n
    \t\t    AllowOverride None\n
    \t\t    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch\n
    \t\t    Order allow,deny\n
    \t\t    Allow from all\n
  \t</Directory>\n
\n
        \t#Log Settings\n
        \tErrorLog "$hostingfolders"/"$domain"/logs/https_error.log\n
\tLogLevel warn\n
\tCustomLog "$hostingfolders"/"$domain"/logs/https_access.log combined\n
</VirtualHost>"
          

testfile="<html>\n
<head>\n
<style>\n
body {\n
\twidth:100%;\n
\ttext-align:center;\n
\tfont-family:Helvetica,Verdana,sans-serif;\n
\tfont-size:25px;\n
\tpadding-top:50px;\n
}\n
\n
h1 {\n
\tfont-size:50px;\n
}\n
</style>\n
\n
<body>\n
<h1>It works!</h1>\n
Domain \""$domain"\" successfully added!<br />\n
Have fun!<br />\n
</body>\n
</html>\n
"
