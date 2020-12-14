#!/bin/sh
service supervisor restart
python manage.py celeryd

/usr/sbin/apache2ctl -D FOREGROUND
#service apache2 reload