class l2mesh::configure (
  $interface     = 'eth0',
  $tunnel_device = 'tun0',
  $meshid        = $::l2mesh::meshid,
) {

  include l2mesh::params
  include concat::setup

  $etcdir = $::l2mesh::params::etcdir
  $root = "${etcdir}/${interface}"
  $boots = "${etcdir}/nets.boot"
  $hosts = "${root}/hosts"
  $conf = "${root}/tinc.conf"
  $fqdn = regsubst($::fqdn, '[._-]+', '', 'G')
  $tag = "tinc_${interface}"
  $tag_conf = "${tag}_connect"

  concat { $boots:
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['tinc'],
  }

  concat::fragment { "${boots}_${interface}":
    target	=> $boots,
    content	=> "${interface}\n",
  }

  file { $root:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Package['tinc'],
  }

  file { $hosts:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File[$root],
  }

  concat { $conf:
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Service['tinc'],
    require => File[$root],
  }

  concat::fragment { "${conf}_head":
    target      => $conf,
    content     => "
Name = ${fqdn}
AddressFamily = ipv4
Interface = ${tunnel_device}
Mode = switch
",
  }

  @@concat::fragment { "${tag_conf}_${fqdn}":
    target      => $conf,
    tag         => "${tag_conf}_${fqdn}",
    content     => "ConnectTO = ${fqdn}\n",
  }

  Concat::Fragment <<| tag != "${tag_conf}_${fqdn}" |>>
}
