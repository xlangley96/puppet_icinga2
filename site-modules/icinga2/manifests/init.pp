class icinga2 (
  String $package_ensure  = lookup('icinga2::package_ensure', String, 'first', 'present'),
  String $service_ensure  = lookup('icinga2::service_ensure', String, 'first', 'running'),
  String $config_dir      = lookup('icinga2::config_dir', String, 'first', '/etc/icinga2'),
  String $log_dir         = lookup('icinga2::log_dir', String, 'first', '/var/log/icinga2'),
) {

  package { 'icinga2':
    ensure => $package_ensure,
  }

  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $log_dir:
    ensure => directory,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0755',
  }

  service { 'icinga2':
    ensure     => $service_ensure,
    enable     => true,
    subscribe  => Package['icinga2'],
  }
}
