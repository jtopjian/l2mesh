class l2mesh::keys (
  $interface = 'eth0',
  $ip        = $::ipaddress_eth0,
  $port      = 655,
  $meshid    = $::l2mesh::meshid,
) {

  include l2mesh::params

  $etcdir = $::l2mesh::params::etcdir
  $root = "${etcdir}/${interface}"
  $hosts = "${root}/hosts"
  $tag = "tinc_${interface}_${meshid}"

  $fqdn = regsubst($::fqdn, '[._-]+', '', 'G')
  $host = "${hosts}/${fqdn}"

  $private = "${root}/rsa_key.priv"
  $public = "${root}/rsa_key.pub"

  $keys = tinc_keygen("${::l2mesh::params::keys_directory}/${meshid}/${fqdn}")

  $private_key = $keys[0]
  $public_key = $keys[1]

  file { $private:
    owner   => root,
    group   => root,
    mode    => '0600',
    content => $private_key,
    notify  => Service['tinc'],
    require => Package['tinc'],
  }

  file { $public:
    owner   => root,
    group   => root,
    mode    => '0640',
    content => $public_key,
    notify  => Service['tinc'],
    require => Package['tinc'],
  }

  @@file { $host:
    owner   => root,
    group   => root,
    mode    => '0640',
    content => "Address = $ip
Port = $port
Compression = 0

${public_key}
",
    tag     => $tag, 
    notify  => Service['tinc'],
    require => Package['tinc'],
  }

  File <<| tag == $tag |>>
}
