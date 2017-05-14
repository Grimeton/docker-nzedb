#####/etc/nginx/sites-available/default#####
server {
    listen [+ $WEB_SERVER_HTTP_PORT +] default_server;
    listen [::]:[+ $WEB_SERVER_HTTP_PORT +] default_server;
    server_name [+ $WEB_SERVER_NAME +];
    root "[+ $PATH_WEB_SERVER_ROOT +]";
    index index.html index.htm index.php;
    [$ if $NZEDB_INSTALLED ne '1' $]
        set $is_installed "0";
    if (-f "[+ $PATH_INSTALL_ROOT +]/configuration/install.lock") {
        set $is_installed "1";
    }
    [$ endif $]
        set $_HTTPS "off";
    if ($http_x_offload_ssl ~* "on") {
        set $_HTTPS "on";
    }
    if ($https ~* on) {
        set $_HTTPS "on";
    }
    location ~* \.(?:css|eot|gif|gz|ico|inc|jpe?g|js|ogg|oga|ogv|mp4|m4a|mp3|png|svg|ttf|txt|woff|xml)$ {
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }
    [$ if $WEB_ROOT ne '' $]
        location / {
            return 302 $scheme://[+ $WEB_SERVER_NAME +][+ $WEB_ROOT +]/;
        }
    location [+ $WEB_ROOT +] {
        [$ else $]
            location / {
                [$ endif $]
                    [$ if $NZEDB_INSTALLED ne '1' $]
                        if ($is_installed = "0") {
                            return 302 $scheme://[+ $WEB_SERVER_NAME +][+ $WEB_ROOT +]/install/;
                        }
                [$ endif $]
                    alias "[+ $PATH_WEB_SERVER_ROOT +]/";
                try_files $uri $uri/ @rewrites;
            }
        location ^~ [+ $WEB_ROOT +]/covers {
            alias "[+ $PATH_WEB_RESOURCES +]/covers/";
        }
        location [+ $WEB_ROOT +]/install {
            [$ if $NZEDB_INSTALLED eq '1' $]
                return 302 $scheme://[+ $WEB_SERVER_NAME +][+ $WEB_ROOT +]/;
            [$ endif $]
        }
        location ^~ [+ $WEB_ROOT +]/themes {
            alias "[+ $PATH_WEB_SERVER_ROOT +]/themes/";
        }
        location @rewrites {
            rewrite ^[+ $WEB_ROOT +]/([^/\.]+)/([^/]+)/([^/]+)/? [+ $WEB_ROOT +]/index.php?page=$1&id=$2&subpage=$3 last;
            rewrite ^[+ $WEB_ROOT +]/([^/\.]+)/([^/]+)/?$ [+ $WEB_ROOT +]/index.php?page=$1&id=$2 last;
            rewrite ^[+ $WEB_ROOT +]/([^/\.]+)/?$ [+ $WEB_ROOT +]/index.php?page=$1 last;
        }
        location ~* ^[+ $WEB_ROOT +](/.*\.php)$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_buffering off;
            fastcgi_cache off;
            fastcgi_ignore_client_abort off;
            fastcgi_index index.php;
            fastcgi_param HTTPS $_HTTPS;
            fastcgi_param SCRIPT_FILENAME $document_root$1;
            fastcgi_param SERVER_NAME [+ $WEB_SERVER_NAME +];
            fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        }
    }
