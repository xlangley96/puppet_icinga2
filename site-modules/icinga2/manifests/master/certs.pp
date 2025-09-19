class icinga2::master::certs (
  String $master_cert = '/etc/icinga2/pki/master.crt',
  String $master_key  = '/etc/icinga2/pki/master.key',
  String $ca_cert     = '/etc/icinga2/pki/ca.crt',
) {

  # Ensure the PKI directory exists
  file { '/etc/icinga2/pki':
    ensure => directory,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0755',
  }

  # Deploy the master certificate
  file { $master_cert:
    ensure => file,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0644',
    source => "puppet:///modules/icinga2/certs/master.crt",
    require => File['/etc/icinga2/pki'],
  }

  # Deploy the master private key
  file { $master_key:
    ensure => file,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0600',
    source => "puppet:///modules/icinga2/certs/master.key",
    require => File['/etc/icinga2/pki'],
  }

  # Deploy the CA certificate
  file { $ca_cert:
    ensure => file,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0644',
    source => "puppet:///modules/icinga2/certs/ca.crt",
    require => File['/etc/icinga2/pki'],
  }

}
