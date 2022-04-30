<?php
$CONF['configured'] = true;
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = '127.0.0.1';
$CONF['database_port'] = '3306';
$CONF['database_user'] = '{{db_username}}';
$CONF['database_password'] = '{{db_password}}';
$CONF['database_name'] = '{{db_name}}';
$CONF['encrypt'] = 'dovecot:ARGON2I';
$CONF['dovecotpw'] = "/usr/bin/doveadm pw -r 5";
if(@file_exists('/usr/bin/doveadm')) { // @ to silence openbase_dir stuff; see https://github.com/postfixadmin/postfixadmin/issues/171
    $CONF['dovecotpw'] = "/usr/bin/doveadm pw -r 5"; # debian
}