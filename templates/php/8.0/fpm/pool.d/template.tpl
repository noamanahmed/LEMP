
[{{$username}}]


user = {{$username}}
group = {{$username}}
listen = /run/php/{{$username}}-php80-fpm.sock
listen.owner = {{$username}}
listen.group = {{$username}}
listen.mode = 0660

pm = dynamic
pm.max_children = 5
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 4
pm.max_requests = 500
pm.process_idle_timeout = 5s

php_admin_value[error_log] = /home/{{$username}}/logs/php/php80-fpm-www-errors.log
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 128M
php_admin_value[upload_max_filesize] = 256M
php_admin_value[post_max_size] = 258M


[global]
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 10s
error_log = /home/{{$username}}/logs/php/pp80-fpm-errors.log
