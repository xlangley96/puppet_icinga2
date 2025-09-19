class icinga2::agent (
  String $master        = lookup('icinga2::agent::master', String, 'first'),
  String $hostname      = lookup('icinga2::agent::hostname', String, 'first', $facts['networking']['hostname']),
) {

  # Ensure Icinga2 package is installed
  package { 'icinga2':
    ensure => installed,
  }

  # Ensure Icinga2 service is running and enabled
  service { 'icinga2':
    ensure => running,
    enable => true,
  }

  # Ensure PKI directory exists
  file { '/etc/icinga2/pki':
    ensure => directory,
    owner  => 'icinga',
    group  => 'icinga',
    mode   => '0755',
  }

  # Copy CA certificate from Puppet fileserver
  file { '/etc/icinga2/pki/ca.crt':
    ensure  => file,
    source  => 'puppet:///modules/icinga2/certs/ca.crt',
    owner   => 'icinga',
    group   => 'icinga',
    mode    => '0644',
    require => File['/etc/icinga2/pki'],
  }

  # Configure agent API connection to master
  file { '/etc/icinga2/conf.d/api-master.conf':
    ensure  => file,
    content => template('icinga2/api-agent.conf.erb'),
    notify  => Service['icinga2'],
  }

  # Register the agent node with the master (idempotent)
  exec { "register-${hostname}-with-master":
    command => "/usr/sbin/icinga2 node setup --ticket $(curl -ks https://${master}:5665/v1/actions/generate-ticket) --master-host ${master}",
    unless  => "/usr/sbin/icinga2 node list | grep ${master}",
    require => File['/etc/icinga2/pki/ca.crt'],
    notify  => Service['icinga2'],
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
  }

  notify { "Agent ${hostname} configured to connect to master ${master}": }

}
