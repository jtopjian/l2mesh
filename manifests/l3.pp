class l2mesh::l3 (
  $interface      = 'eth0',
  $tunnel_device  = 'tun0',
  $tunnel_ip      = undef,
  $tunnel_netmask = undef,
  $meshid    = $::l2mesh::meshid,
) {

  include l2mesh::params

  $etcdir = $::l2mesh::params::etcdir
  $up = "${etcdir}/${interface}/tinc-up"

  if $tunnel_ip {

    file { $up:
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => "#!/bin/bash
ifconfig ${tunnel_device} ${tunnel_ip} netmask ${tunnel_netmask}
",
      require => File["${etcdir}/${interface}"],
    }

  }

}
