# == Define: l2mesh
#
# Create and update L2 ( http://en.wikipedia.org/wiki/Link_layer )
# mesh.
#
# The mesh interface is created by a *tincd* daemon ( one per mesh )
# which maintains a connection to all other machines in the mesh.
#
# Given three bare metal machines hosted at http://hetzner.de/,
# http://ovh.fr/ and http://online.net/, *l2mesh* can be used to
# create a new ethernet interface on each of them that
# behaves as if they had a physical ethernet card connected to one
# hardware switch in the same room. The machine at *hetzner* could be
# the DHCP server providing the IP for the interface of the
# OVH machine. In addition, if the connection between the *hetzner*
# machine and the *ovh* machine does not work, the packets will use
# the *online* machine as an intermediary, making the mesh resilient
# to network outage.
#
# tinc is not limited to the use case implemented by this module, see
# http://www.tinc-vpn.org/ for more information.
#
# == Parameters
#
# [*meshid*] The uuid of the mesh (nodes with same uuid will be members).
#   => default: vpn
#
# [*interface*] The interface to create the tunnel/mesh through
#
# [*ip*] ip address of the node
#
# [*port*] port number used by each tincd
#        (see the tinc.conf manual page for more information)
#
# [*tunnel_device*] The tunnel device/interface created
#
# [*tunnel_ip*] The IP address on the tunnel
#
# [*tunnel_netmask*] The netmask on the tunnel
#
# == Example
#
#  class { 'l2mesh':
#    meshid        => 'a7d8857d',
#    interface     => 'eth0',
#    ip            => $::ipaddress_eth0,
#    tunnel_device => 'tun0',
#    tunnel_ip     => '192.168.255.10',
#  }
#
# == Generating and distributing keys ==
#
# Each host participating in the mesh has a public / private keypair.
# The pair is generated on the puppetmaster by the *tinc_keygen*
# function located in the
# *l2mesh/lib/puppet/parser/functions/tinc_keygen.rb* source file
# and stored in */var/lib/puppet/l2mesh*, under a
# directory dedicated to the node owning the keypair. The
# *tinc_keygen* function is called each time the manifest containing
# it is compiled. If the files containing the keypair already
# exist, the key is not generated again. For instance, the
# */var/lib/puppet/l2mesh/there/bm0003there/rsa_key.pub* file contains
# the public part of the key for the node *bm0003there* in the *there*
# mesh.
#
# The keypair must be copied over to the node that owns it and
# the manifest takes care of it with file {} classes. The public
# part of the keypair must be copied to each node that is willing
# to accept connections from the node that owns it. Since the goal
# of the l2mesh module is to create a mesh where each node
# are connected with each other, the public key will be copied
# to each node participating in the mesh and included in the
# corresponding host file. For instance, the public key of
# the node *bm0003there* of the *there* mesh will be included in the file
# */etc/tinc/there/hosts/bm0003there* file.
#
# == Supported Operating Systems
#
# * Debian GNU/Linux
#
# Support for new operating systems can be implemented by adding a new
# section in the *l2mesh/manifests/params.pp* file.
#
# == Security and disaster recovery
#
# [the puppetmaster crashes] the */var/lib/puppet* directory will be
#   lost and all the keypairs with it. If the puppetmaster is reconstructed
#   but the content of */var/lib/puppet* cannot be recovered, the keys
#   for all hosts will be recreated.
#
# [impersonating a node] the keypairs are distributed from the puppetmaster
#   to the nodes and a node that would succeed in fooling the puppetmaster
#   into thinking it is the legitimate recipient of a keypair could enter
#   the mesh. If the puppetmaster can be sollicited by untrusted hosts,
#   using node selection based on fully qualified host names is a must.
#   For instance, instead of *node /www/* it is recommended to append
#   the top level domain name *node /www.*foo.com$/* otherwise any node
#   with a *www* in the name can enter the mesh.
#
# == TODO / Roadmap
#
# * Test for exported resources
#   https://groups.google.com/forum/#!topic/puppet-users/XgQXt5n017o[1-25]
#
# * Format and publish this documentation
#
# * What if a node is not reachable from the internet ? All other nodes
#   will have a ConnectTO trying to reach it and this is a waste of
#   resources although it does not break the mesh.
#
# * Add a test that checks if instantiating two lmesh does not run into
#   a conflict ( l2mehs(ip = 1) + l2mesh(ip = 2) ). How is it done with
#   rspec puppet ?
#
# * Change into defined types to support multiple tunnels per node.
#
# == Dependencies
#
#   Class['concat']
#
# == Authors
#
# Loic Dachary <loic@dachary.org>
# Joe Topjian <joe@topjian.net>
# Sebastien Fuchs <sebastien@les-infogereurs.com>
#
# == Copyright
#
# Copyright 2015 Sebastien Fuchs <sebastien@les-infogereurs.com>
# Copyright 2014 Joe Topjian <joe.topjian@cybera.ca>
# Copyright 2013 Cloudwatt <libre.licensing@cloudwatt.com>
# Copyright 2012 eNovance <licensing@enovance.com>
#
# == Notes
#
# This module was significantly rewrote by Joe Topjian. The original
# goals are still met, though.
#
class l2mesh (
  $meshid         = 'vpn',
  $interface      = 'eth0',
  $ip             = $::ipaddress_eth0,
  $port           = 655,
  $tunnel_device  = 'tun0',
  $tunnel_ip      = undef,
  $tunnel_netmask = undef,
) {

  anchor { 'l2mesh::start': } ->
  class { 'l2mesh::install': } ->
  class { 'l2mesh::configure':
    interface     => $interface,
    tunnel_device => $tunnel_device,
    meshid        => $meshid,
  } ->
  class { 'l2mesh::keys':
    interface => $interface,
    ip        => $ip,
    port      => $port,
    meshid    => $meshid,
  } ->
  class { 'l2mesh::l3':
    interface      => $interface,
    tunnel_device  => $tunnel_device,
    tunnel_ip      => $tunnel_ip,
    tunnel_netmask => $tunnel_netmask,
  } ->
  class { 'l2mesh::service': } ->
  anchor { 'l2mesh::end': }

}
