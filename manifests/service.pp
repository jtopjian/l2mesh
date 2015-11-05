class l2mesh::service {

  include l2mesh::params

  # TODO: wronf debian init script: hard coded /etc/tinc config file
  #service { 'tinc':
  #  name    => $::l2mesh::params::tinc_service_name,
  #  ensure  => running,
  #  enable  => true,
  #  status  => '/usr/bin/pgrep tinc',
  #  require => Package['tinc']
  #}

  $start = "start_${interface}"
  $running = "tincd --net=${interface} --kill=USR1"

   exec { $start:
     command	=> "tincd --net=${interface} && ${running}",
     onlyif	=> "! ${running}",
     provider	=> 'shell',
   }

   $reload = "reload_${interface}"

   exec { $reload:
     command	=> "tincd --net=${interface} --kill=HUP",
     provider	=> 'shell',
     refreshonly	=> true,
   }

}
