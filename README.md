# docker-powerdns-admin

Run with something like:

```
docker run --name pdnsadmin-test -e SECRET_KEY='a-very-secret-key' \
  -e PORT='9393' \
  -e SQLA_DB_USER='powerdns_admin_user' \
  -e SQLA_DB_PASSWORD='exceptionallysecure' \
  -e SQLA_DB_HOST='192.168.0.100' \
  -e SQLA_DB_NAME='powerdns_admin_test' \
  -e LDAP_TYPE='ldap' \
  -e LDAP_URI='ldaps://ldap.jumpcloud.com:636' \
  -e LDAP_SEARCH_BASE='ou=Users,o=0000000000000000000000,dc=jumpcloud,dc=com' \
  -e PDNS_STATS_URL='http://192.168.1.200:8081/' \
  -e PDNS_API_KEY='sneakyapikey' \
  -d -p 9393:9393/tcp Mikroways/powerdns-admin:latest
```
