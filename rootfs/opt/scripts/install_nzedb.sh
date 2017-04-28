#!/usr/bin/with-contenv bash

echo "================================================================================"
echo "Running install_nzedb.sh as $(whoami)".
echo "================================================================================"

[[ ! -d "${_PATH_INSTALL_ROOT}" ]] && exit 1;
[[ ! -f "/home/www-data/.composer/auth.json" ]] && exit 2;
[[ ! "$(whoami)" == "www-data" ]] && exit 3;
export HOME="/home/www-data"
cd "${_PATH_INSTALL_ROOT}" || exit 4;
echo ""
echo "=== Cloning nZEDb from https://github.com/nZEDb/nZEDb.git to ${_PATH_INSTALL_ROOT}"
echo ""
git clone https://github.com/nZEDb/nZEDb.git . || exit 5;
echo ""
echo "--- Done."
echo ""
echo "=== Running composer install on nZEDb directory."
echo ""
composer --no-ansi install || exit 6;
echo ""
echo "--- Done."
echo ""
echo "=== Installing additional modules required."
echo ""
composer --no-ansi require league/oauth2-google || exit 7;
echo ""
echo "--- Done."
exit 0;
