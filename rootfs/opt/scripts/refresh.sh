#!/bin/bash

[[ -f "/opt/scripts/refresh.conf" ]] && . "/opt/scripts/refresh.conf";
REFRESH_POSTPROCESS_OPTIONS="${_REFRESH_POSTPROCESS_OPTIONS:-nfo mov tv ama}";

until [[ -f "/opt/http/configuration/install.lock" ]]; do
    sleep 10;
done

while (true); do
    su - www-data -s /bin/bash -c "$(which php) /opt/http/misc/update/nix/multiprocessing/binaries.php 0";
    su - www-data -s /bin/bash -c "$(which php) /opt/http/misc/update/nix/multiprocessing/releases.php"
    for pparm in ${REFRESH_POSTPROCESS_OPTIONS}; do
        su - www-data -s /bin/bash -c "$(which php) /opt/http/misc/update/nix/multiprocessing/postprocess.php $pparm";
    done
    sleep 60;
done
 
