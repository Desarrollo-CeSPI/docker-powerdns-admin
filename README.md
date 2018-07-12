# docker image for PowerDNS Admin

This image installs [PowerDNS Admin](https://github.com/ngoduykhanh/PowerDNS-Admin) application. As it's code is not tagged, we
juts build it for the latest relase.

This image is also inspired by its
[fork](https://github.com/reallyreally/docker-powerdns-admin)

## Sample docker-compose


```
version: '2'
services:
  pdnsadmin:
    image: mikroways/powerdns-admin
    environment:
      SECRET_KEY: 'a-very-secret-key'
      SQLA_DB_USER: root
      SQLA_DB_PASSWORD: root_pass
      SQLA_DB_HOST: db
      SQLA_DB_NAME: pdnsadmin
      LOG_LEVEL: info
      PDNS_STATS_URL: http://powerdns.example.com/
      PDNS_API_KEY: 'powerdns-api-key'
    ports:
      - 9191:9191
    depends_on:
      - db
    links:
    - db
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root_pass
      MYSQL_DATABASE: pdnsadmin
    volumes:
    -  pdns-db:/var/lib/mysql

volumes:
  pdns-db:

```

## Configuration options

If you take a look at `docker-entrypoint.sh` you can see which configuration
options are accepted. For the moment, not every accepted option is supported.
All available options are available within [config_template.py](https://github.com/ngoduykhanh/PowerDNS-Admin/blob/master/config_template.py)
