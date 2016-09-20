SSL initial configuration for Apache server
==

1. Install and configure apache for serving your project on standard HTTP.

2. Activate ssl apache module.
```terminal
sudo a2enmod ssl
```

3. Clone this repository on your server
```terminal
git clone https://github.com/fpolacov/apache-ios-ssl-configuration
```

4. Create ssl certificates
```terminal
cd apache-ios-ssl-configuration
./init_ssl.sh
```

5. Create a new VirtualHost for port 443 and add your ssl certificates:
```terminal
<VirtualHost *:443>
        SSLEngine On
        SSLCertificateFile /etc/ssl/domain.com/domain.com.crt
        SSLCertificateKeyFile /etc/ssl/domain.com/domain.com.key
        ...
</VirtualHost>
```

6. Add your VirtualHost to apache sites-enabled folder.

7. Reload apache
```terminal
sudo service apache2 reload
```

Renew ssl certificate
==

```terminal
cd apache-ios-ssl-configuration
./renew_ssl.sh
```

Generate certificate for pinning from an iOS device
==

```terminal
cd /etc/ssl/domain.com
openssl x509 -in domain.com.crt -outform der -out domain.com.cer
```
