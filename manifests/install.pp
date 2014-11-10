class l2mesh::install {

  include l2mesh::params

  package { 'tinc':
    name   => $::l2mesh::params::tinc_package_name,
    ensure => present,
  }

}
