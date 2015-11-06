<!-- -*- mode: markdown -*- -->
Introduction
============

[l2mesh](http://redmine.the.re/projects/l2mesh "l2mesh") is a
[tinc](http://www.tinc-vpn.org/ "tinc") based virtual switch,
implemented as a puppet module.

It creates a new ethernet interface on the machine and connects it to
the switch.

Here is how the situation looks like when dealing with physical
machines and a hardware switch:


    +----------------+                        +---------------+
    |                |                        |               |
    |          +-----+                        +-----+         |
    | MACHINE  | eth0+---------+    +---------+eth0 | MACHINE |
    |    A     +-----+         |    |         +-----+   C     |
    |                |         |    |         |               |
    +----------------+     +---+----+---+     +---------------+
                           |  SWITCH    |
                           +-----+------+
                                 |
    +----------------+           |
    |                |           |
    |          +-----+           |
    | MACHINE  | eth0+-----------+
    |    B     +-----+
    |                |
    +----------------+

Each of the three machines ( *A, B, C* ) have a physical ethernet
connector which shows as *eth0*. They are connected with a cable to a
*SWITCH* which transmits the packet coming from *MACHINE A* to *MACHINE B*
or *MACHINE C*.

With *l2mesh*, a new virtual interface ( named *tun0* below ) is
created on each machine and they are all connected by a [TINC daemon](http://www.tinc-vpn.org/).
Packets go from *MACHINE A* to *MACHINE B* or *MACHINE C* as if they were
connected to a physical switch.

    +---------+-----+
    |         |eth0 |
    |         +-----+
    | MACHINE |tun0 |
    |    A    +-----+
    |           TINC+---
    +--------------++   \-------
                   |            \-------   +---------------+
                   |                    X--+TINC           |
                   |            /-------   +-----+         |
     +-------------+-+   /------           |tun0 | MACHINE |
     |           TINC+---                  +-----+    C    |
     |         +-----+                     |eth0 |         |
     | MACHINE |tun0 |                     +-----+---------+
     |    B    +-----+
     |         |eth0 |
     +---------+-----+

Here is how it looks on each machine:

    $ ip link show eth0
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
       link/ether fa:16:3e:48:ae:6f brd ff:ff:ff:ff:ff:ff

    $ ip link show dev tun0
    2: tun0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
       link/ether 72:75:6e:60:59:f0 brd ff:ff:ff:ff:ff:ff

Usage
=====

*l2mesh* is a puppet module that should be installed in the puppet master as follows

    git clone http://redmine.the.re/git/l2mesh.git /etc/puppet/modules/l2mesh

Here is an example usage that can be included in */etc/puppet/manifests/site.pp*

    node /MACHINE-A.example.com/, /MACHINE-B.example.com/ {

      class { 'l2mesh':
        interface     => 'eth0'
        ip            => $::ipaddress_eth0,
        port          => 656,
        tunnel_device => 'tun0',
        tunnel_ip     => '192.168.255.1',
      }
    }

On both *MACHINE-A* and *MACHINE-B*, it will

* create the *tun0* ethernet interface
* run the *tincd* daemon to listen on port *656* and
  bind it to the *$::ipaddress_eth0* IP address

In addition, both machines will try to reach each other:

* *tincd* on *MACHINE-A* will try to connect to *tincd* on *MACHINE-B*
* *tincd* on *MACHINE-B* will try to connect to *tincd* on *MACHINE-A*

Adding a new machine to the *tun* virtual switch is done by adding the
hostname of the machine to the node list. For instance,
*MACHINE-C.example.com* can be added with:

    node /MACHINE-A.example.com/, /MACHINE-B.example.com/, /MACHINE-C.example.com/  {
    ...

l2mesh is not
=============

* l2mesh is not an equivalent to *brctl* : it is a switch made of *tinc* daemons running on multiple machines

Implementation
==============

See the implementation notes at the beginning of the file [manifests/init.pp](http://redmine.the.re/projects/l2mesh/repository/revisions/master/entry/manifests/init.pp "manifests/init.pp")

License
=======

    Copyright (C) 2012 eNovance <licensing@enovance.com>
                  2014 Joe Topjian <joe@topjian.net>

	Authors:
    Loic Dachary <loic@dachary.org>
    Joe Topjian <joe@topjian.net>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


Running tests
=============

    l2mesh has been heavily rewritten. Tests do not work right now.

    apt-get install -y tinc
    apt-get install -y ruby1.8 rubygems
    apt-get remove -y ruby1.9.1
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 1.1.3 diff-lcs
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 1.6.14 facter
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 0.0.1 metaclass
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 0.13.0 mocha
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 2.7.18 puppet
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 0.1.13 puppet-lint
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 0.2.0 puppetlabs_spec_helper
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 10.0.2 rake
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 2.12.0 rspec
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 2.12.0 rspec-core
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 2.12.0 rspec-expectations
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 2.12.0 rspec-mocks
    GEM_HOME=$HOME/.gem-installed gem install --include-dependencies --no-rdoc --no-ri --version 0.1.4 rspec-puppet
    export PATH=$HOME/.gem-installed/bin:$PATH ; GEM_HOME=$HOME/.gem-installed rake spec
