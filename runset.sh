#!/bin/bash
source ~/.bashrc
cat "000-default.conf" > /etc/apache2/sites-available/000-default.conf
python3 -m http.server 80 &> /dev/null &
/bin/bash
