class icinga2::master::config (
  Array[String] $agents = lookup('icinga2::master::agents', Array[String], 'first', []),
) {

  # Define hosts for all agents
  $agents.each |String $agent| {
    icinga2::object::host { $agent:
      ensure  => present,
      address => $agent,
      check_command => 'hostalive',
    }
  }

  # Example: Apply standard services to each agent
  $agents.each |String $agent| {
    icinga2::object::service { "${agent}_load":
      ensure      => present,
      host_name   => $agent,
      check_command => 'load',
      max_check_attempts => 3,
      check_interval    => 60,
      retry_interval    => 30,
    }

    icinga2::object::service { "${agent}_disk":
      ensure      => present,
      host_name   => $agent,
      check_command => 'disk',
      vars.disk_partitions => ['/'],
      max_check_attempts => 3,
      check_interval    => 60,
      retry_interval    => 30,
    }

    icinga2::object::service { "${agent}_memory":
      ensure      => present,
      host_name   => $agent,
      check_command => 'memory',
      max_check_attempts => 3,
      check_interval    => 60,
      retry_interval    => 30,
    }
  }

}
