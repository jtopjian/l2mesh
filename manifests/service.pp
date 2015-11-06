class l2mesh::service {

  include l2mesh::params

  $interface = $::l2mesh::interface
  $running = "tincd --net=${interface} --kill=USR1"

  # TODO: wrong debian init script: hard coded /etc/tinc config file
  service { 'tinc':
    name    => $::l2mesh::params::tinc_service_name,
    ensure  => running,
    enable  => true,
    pattern => 'tincd',
    start   => "tincd --net=${interface} && ${running}",
    stop    => "tincd --net=${interface} --kill",
    restart => "tincd --net=${interface} --kill=HUP && ${running}",
    path	=> ["/usr/sbin"],
    require => Package['tinc']
  }

}
