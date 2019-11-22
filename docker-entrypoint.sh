#!/usr/bin/env sh
set -eo pipefail

BIND_ADDRESS=${BIND_ADDRESS:-'0.0.0.0'}

if [ ! -z "$LOG_LEVEL" ]; then
  sed -i s"|LOG_LEVEL = 'DEBUG'|LOG_LEVEL = '${LOG_LEVEL}'|g" /app/config.py
fi

if [ ! -z $SECRET_KEY ]; then
  sed -i "s|SECRET_KEY = 'We are the world'|SECRET_KEY = '${SECRET_KEY}'|g" /app/config.py
fi

if [ ! -z $PORT ]; then
  sed -i "s|PORT = 9191|PORT = ${PORT}|g" /app/config.py
fi


if [ ! -z $BIND_ADDRESS ]; then
  sed -i "s|BIND_ADDRESS = '127.0.0.1'|BIND_ADDRESS = '${BIND_ADDRESS}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_USER ]; then
  sed -i "s|SQLA_DB_USER = 'pda'|SQLA_DB_USER = '${SQLA_DB_USER}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_PASSWORD ]; then
  sed -i "s|SQLA_DB_PASSWORD = 'changeme'|SQLA_DB_PASSWORD = '${SQLA_DB_PASSWORD}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_HOST ]; then
  sed -i "s|SQLA_DB_HOST = '127.0.0.1'|SQLA_DB_HOST = '${SQLA_DB_HOST}'|g" /app/config.py
fi

if [ ! -z $SQLA_DB_NAME ]; then
  sed -i "s|SQLA_DB_NAME = 'pda'|SQLA_DB_NAME = '${SQLA_DB_NAME}'|g" /app/config.py
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
