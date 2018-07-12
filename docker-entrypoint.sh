#!/usr/bin/env sh
set -eo pipefail

BIND_ADDRESS=${BIND_ADDRESS:-'0.0.0.0'}
PDNS_VERSION=${PDNS_VERSION:-'4.1.3'}

if [ ! -z "$PDNS_VERSION" ]; then
  sed -i "s|PDNS_VERSION = '.*|PDNS_VERSION = '${PDNS_VERSION}'|g" /app/config.py
fi

if [ ! -z "$LOG_LEVEL" ]; then
  sed -i s"|LOG_LEVEL = 'DEBUG'|LOG_LEVEL = '${LOG_LEVEL}'|g" /app/config.py
fi

if [ ! -z $SECRET_KEY ]; then
  sed -i "s|SECRET_KEY = 'We are the world'|SECRET_KEY = '${SECRET_KEY}'|g" /app/config.py
fi

if [ ! -z $PORT ]; then
  sed -i "s|PORT = 9393|PORT = ${PORT}|g" /app/config.py
fi


if [ ! -z $BIND_ADDRESS ]; then
  sed -i "s|BIND_ADDRESS = '127.0.0.1'|BIND_ADDRESS = '${BIND_ADDRESS}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_USER ]; then
  sed -i "s|SQLA_DB_USER = 'powerdnsadmin'|SQLA_DB_USER = '${SQLA_DB_USER}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_PASSWORD ]; then
  sed -i "s|SQLA_DB_PASSWORD = 'powerdnsadminpassword'|SQLA_DB_PASSWORD = '${SQLA_DB_PASSWORD}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_HOST ]; then
  sed -i "s|SQLA_DB_HOST = 'mysqlhostorip'|SQLA_DB_HOST = '${SQLA_DB_HOST}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_NAME ]; then
  sed -i "s|SQLA_DB_NAME = 'powerdnsadmin'|SQLA_DB_NAME = '${SQLA_DB_NAME}'|g" /app/config.py
fi

if [ ! -z $LDAP_TYPE ]; then
  sed -i "s|LDAP_TYPE = 'ldap'|LDAP_TYPE = '${LDAP_TYPE}'|g" /app/config.py
  LDAP_ENABLED=1
fi

if [ ! -z $LDAP_URI ]; then
  sed -i "s|LDAP_URI = 'ldaps://your-ldap-server:636'|LDAP_URI = '${LDAP_URI}'|g" /app/config.py
  LDAP_ENABLED=1
fi

if [ ! -z $LDAP_USERNAME ]; then
  sed -i "s|LDAP_USERNAME = 'cn=dnsuser,ou=users,ou=services,dc=duykhanh,dc=me'|LDAP_USERNAME = '${LDAP_USERNAME}'|g" /app/config.py
else
  sed -i "s|LDAP_USERNAME = 'cn=dnsuser,ou=users,ou=services,dc=duykhanh,dc=me'|LDAP_USERNAME = ''|g" /app/config.py
fi

if [ ! -z $LDAP_PASSWORD ]; then
  sed -i "s|LDAP_PASSWORD = 'dnsuser'|LDAP_PASSWORD = '${LDAP_PASSWORD}'|g" /app/config.py
else
  sed -i "s|LDAP_PASSWORD = 'dnsuser'|LDAP_PASSWORD = ''|g" /app/config.py
fi

if [ ! -z $LDAP_SEARCH_BASE ]; then
  sed -i "s|LDAP_SEARCH_BASE = 'ou=System Admins,ou=People,dc=duykhanh,dc=me'|LDAP_SEARCH_BASE = '${LDAP_SEARCH_BASE}'|g" /app/config.py
fi

if [ ! -z $LDAP_USERNAMEFIELD ]; then
  sed -i "s|LDAP_USERNAMEFIELD = 'uid'|LDAP_USERNAMEFIELD = '${LDAP_USERNAMEFIELD}'|g" /app/config.py
fi

if [ ! -z $LDAP_FILTER ]; then
  sed -i "s|LDAP_FILTER = '(objectClass=inetorgperson)'|LDAP_FILTER = '${LDAP_FILTER}'|g" /app/config.py
fi

if [ ! -z $LDAP_BIND_TYPE ]; then
  sed -i "s|LDAP_BIND_TYPE= 'direct'|LDAP_BIND_TYPE= '${LDAP_BIND_TYPE}'|g" /app/config.py
fi

if [ ! -z $LDAP_ENABLED ]; then
  sed -i "s|LDAP_ENABLED = False|LDAP_ENABLED = True|g" /app/config.py
fi

if [ ! -z $PDNS_STATS_URL ]; then
  sed -i "s|PDNS_STATS_URL = 'http://172.16.214.131:8081/'|PDNS_STATS_URL = '${PDNS_STATS_URL}'|g" /app/config.py
fi

if [ ! -z $PDNS_API_KEY ]; then
  sed -i "s|PDNS_API_KEY = 'you never know'|PDNS_API_KEY = '${PDNS_API_KEY}'|g" /app/config.py
fi

. /app/flask/bin/activate


echo "===> Assets management"
echo "---> Running Yarn"
yarn install --pure-lockfile

echo "---> Running Flask assets"
flask assets build

echo "---> Running DB Migration"
flask db migrate -m "Upgrade BD Schema" --directory /app/migrations || true
flask db upgrade --directory /app/migrations

gunicorn -t 120 --workers 4 --bind '0.0.0.0:9191' --log-level info app:app
