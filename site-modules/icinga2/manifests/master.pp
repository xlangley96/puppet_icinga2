class icinga2::master (
  String $hostname        = lookup('icinga2::master::hostname', String, 'first'),
  String $web_user        = lookup('icinga2::master::web_user', String, 'first', 'icingaadmin'),
  String $web_password    = lookup('icinga2::master::web_password', String, 'first'),
  Boolean $api_enabled    = lookup('icinga2::master::api_enabled', Boolean, 'first', true),
  Array[String] $agents   = lookup('icinga2::master::agents', Array[String], 'first', []),
  Boolean $web_enabled    = lookup('icinga2::master::web_enabled', Boolean, 'first', true),
  String $db_host         = lookup('icinga2::master::db_host', String, 'first', 'localhost'),
  String $db_name         = lookup('icinga2::master::db_name', String, 'first', 'icinga'),
  String $db_user         = lookup('icinga2::master::db_user', String, 'first', 'icinga'),
  String $db_password     = lookup('icinga2::master::db_password', String, 'first', 'ChangeMe123'),
) {

  include icinga2  # Base installation

  if $api_enabled {
    file { '/etc/icinga2/features-available/api.conf':
      ensure  => file,
      content => template('icinga2/api.conf.erb'),
      notify  => Service['icinga2'],
    }

    exec { 'enable_api':
      command => '/usr/sbin/icinga2 feature enable api',
      unless  => '/usr/sbin/icinga2 feature list | grep enabled | grep api',
      notify  => Service['icinga2'],
    }
  }

  if $web_enabled {
    include icinga2::webdb
    include icinga2::webuser
    include icinga2::master::certs
    
    package { ['icingaweb2', 'php', 'php-cli', 'php-mysql', 'php-pdo', 'php-mbstring']:
      ensure => present,
    }

    file { '/etc/icingaweb2':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
    }

    # Database configuration for Icinga Web 2
    file { '/etc/icingaweb2/config.ini':
      ensure  => file,
      content => template('icinga2/web_config.ini.erb'),
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0640',
      notify  => Service['apache2'], # reload Apache if config changes
    }

    service { 'apache2':
      ensure => running,
      enable => true,
    }
  }

  # Finally, configure hosts and services after everything else
  include icinga2::master::config
}
