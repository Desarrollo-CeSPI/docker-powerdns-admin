FROM alpine:3.6

#File Author / Maintainer
MAINTAINER Troy Kelly

RUN apk update && \
    apk add --no-cache git && \
    apk add --update \
    python3 \
    python3-dev \
    py-pip \
    libffi-dev \
    openldap-dev \
    build-base \
    mariadb-dev \
    libxslt-dev \
    xmlsec-dev 
#&& \
RUN    pip3 install -U pip && \
    rm -rf /var/cache/apk/*

# Install Virtualenv
RUN pip install virtualenv

# Create a new directory where the virtual environment will be created and add the requirements file.
RUN git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git /app

WORKDIR /app

RUN virtualenv flask && \
  source ./flask/bin/activate && \
  pip3 install -r requirements.txt && \
  cp config_template.py config.py && \
  sed -i "s|LOG_FILE = 'logfile.log'|LOG_FILE = ''|g" /app/config.py; \
  sed -i "s|BASIC_ENABLED = True|BASIC_ENABLED = False|g" /app/config.py; \
  sed -i "s|SIGNUP_ENABLED = True|SIGNUP_ENABLED = False|g" /app/config.py; \
  sed -i "s|PRETTY_IPV6_PTR = False|PRETTY_IPV6_PTR = True|g" /app/config.py; \
  sed -i "s|^SQLALCHEMY_DATABASE_URI =|#SQLALCHEMY_DATABASE_URI =|g" /app/config.py && \
  echo "SQLALCHEMY_DATABASE_URI = 'mysql://'+SQLA_DB_USER+':'\\" >> /app/config.py && \
  echo "    +SQLA_DB_PASSWORD+'@'+SQLA_DB_HOST+'/'+SQLA_DB_NAME" >> /app/config.py && \
  apk add -U yarn

ENV FLASK_APP=/app/app/__init__.py

RUN virtualenv flask && \
  source ./flask/bin/activate && \
  yarn install --pure-lockfile && \
  flask assets build


EXPOSE 9191

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
