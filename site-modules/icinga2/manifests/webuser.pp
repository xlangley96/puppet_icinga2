class icinga2::webuser (
  String $web_user      = lookup('icinga2::master::web_user', String, 'first', 'icingaadmin'),
  String $web_password  = lookup('icinga2::master::web_password', String, 'first', 'ChangeMe123'),
) {

  # Create the Icinga Web 2 admin user via CLI
  exec { "create-icingaweb2-user-${web_user}":
    command => "/usr/share/icingaweb2/bin/icingacli setup user create --username '${web_user}' --password '${web_password}' --role 'administrator' --email '${web_user}@example.com'",
    unless  => "/usr/share/icingaweb2/bin/icingacli setup user list | grep '^${web_user}$'",
    path    => ['/usr/bin', '/usr/sbin', '/usr/local/bin'],
    require => Package['icingaweb2'], # ensures package installed before running
  }

}
