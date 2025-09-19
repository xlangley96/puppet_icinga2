class icinga2::webdb (
  String $db_host      = lookup('icinga2::master::db_host', String, 'first', 'localhost'),
  String $db_name      = lookup('icinga2::master::db_name', String, 'first', 'icinga'),
  String $db_user      = lookup('icinga2::master::db_user', String, 'first', 'icinga'),
  String $db_password  = lookup('icinga2::master::db_password', String, 'first', 'ChangeMe123'),
) {

  # Install MariaDB/MySQL server (optional if already installed)
  package { 'mariadb-server':
    ensure => present,
  }

  service { 'mariadb':
    ensure => running,
    enable => true,
  }

  # Install MySQL client (for schema import)
  package { 'mariadb-client':
    ensure => present,
  }

  # Ensure database exists
  exec { "create-database-${db_name}":
    command => "/usr/bin/mysql -h ${db_host} -e 'CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8 COLLATE utf8_general_ci;'",
    unless  => "/usr/bin/mysql -h ${db_host} -e 'SHOW DATABASES;' | grep ${db_name}",
  }

  # Create or update database user
  exec { "create-db-user-${db_user}":
    command => "/usr/bin/mysql -h ${db_host} -e \"CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}'; GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%'; FLUSH PRIVILEGES;\"",
    unless  => "/usr/bin/mysql -h ${db_host} -e 'SELECT User FROM mysql.user WHERE User = \"${db_user}\";' | grep ${db_user}",
  }

  # Import Icinga Web 2 schema if not already imported
  exec { 'import-icingaweb2-schema':
    command => "/usr/share/icingaweb2/bin/icingaweb2-db-tool create-schema --db-name ${db_name} --db-user ${db_user} --db-pass ${db_password} --db-host ${db_host}",
    unless  => "/usr/share/icingaweb2/bin/icingaweb2-db-tool list-databases | grep ${db_name}",
    require => [ Exec["create-database-${db_name}"], Exec["create-db-user-${db_user}"] ],
  }

}
