FROM python:2.7

ARG uid
ARG gid
ARG user
ARG group
ARG dir

RUN apt-get update && \
    apt-get install -y -q \
    python-ldap \
    python-dev \    
    libsasl2-dev \
    libldap2-dev \
    apache2 \
    libapache2-mod-wsgi \
    build-essential \
    gettext \
    supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN groupadd -g $gid $group  &&\    
    useradd -d /home/$dir -u $uid -g $gid -m -s /bin/bash $user && \
    chown ${user}:$group -R /home/$dir && \
    chmod 0775 -R /home/$dir && \
    mkdir /var/log/$dir

COPY volumes/helios-server /home/$dir

RUN cd /home/$dir &&\
    pip install -r requirements.txt

COPY volumes/certs/unifesp.key /etc/ssl/private-unifesp/unifesp.key
COPY volumes/certs/intermediate.pem /etc/ssl/private-unifesp/intermediate.pem
COPY volumes/certs/unifesp.crt /etc/ssl/private-unifesp/unifesp.crt
COPY volumes/supervisor/eleicao.conf /etc/supervisor/conf.d/eleicao.conf
COPY volumes/supervisor/apache.conf /etc/supervisor/conf.d/apache.conf
COPY volumes/supervisor/supervisor.conf /etc/supervisor/supervisor.conf
COPY volumes/apache/eleicao.conf /etc/apache2/sites-available/eleicao.conf
COPY volumes/apache/eleicao-ssl.conf /etc/apache2/sites-available/eleicao-ssl.conf    
COPY volumes/services.sh /usr/local/services.sh

RUN chmod +x /usr/local/services.sh && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2dissite 000-default.conf && \    
    a2ensite eleicao-ssl.conf && \
    a2ensite eleicao.conf && \
    service apache2 restart 

WORKDIR /home/$dir    
EXPOSE 80
EXPOSE 443
CMD supervisord -c /etc/supervisor/supervisor.conf
