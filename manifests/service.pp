class l2mesh::service {

  include l2mesh::params

  service { 'tinc':
    name    => $::l2mesh::params::tinc_service_name,
    ensure  => running,
    enable  => true,
    status  => '/usr/bin/pgrep tinc',
    require => Package['tinc']
  }

}
