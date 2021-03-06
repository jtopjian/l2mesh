#
#    Copyright (C) 2012 eNovance <licensing@enovance.com>
#	
#    Author: Loic Dachary <loic@dachary.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require 'spec_helper'

describe 'l2mesh' do

  let :params do
    {
      :interface                => 'NAME',
      :ip			=> '1.2.3.4',
      :port			=> '666',
    }
  end

  facts = {
    :concat_basedir	=> '/var/lib/puppet/concat',
    :fqdn		=> 'bm0404.the.re',
  }

  let :pre_condition do
    'include concat::setup'
  end

  context 'when running on Debian GNU/Linux' do
    let :facts do
      facts.merge({
        'osfamily' => 'Debian',
      })
    end

    # it "bla" do
    #   Puppet::Rails::Resource.create!(Puppet::Rails::Resource.create!(
    #                                                                   :exported => true,
    #                                                                   :host_id => 2,
    #                                                                   :restype => 'file',
    #                                                                   :title => 'KKKK'
    #                                                                   ))
    # end
    it { should include_class('l2mesh::params') }
    it { should include_class('concat::setup') }
    it { should contain_package('tinc').with_ensure('present') }
    interface = 'NAME'
    it do
      should contain_exec("start_#{interface}").with({
                                            :command	=> /#{interface}/,
                                            :onlyif	=> /USR1/,
                                            :provider	=> 'shell',
                                          })
    end
    it { should contain_file("/etc/tinc/#{interface}").with_ensure('directory') }
    it { should contain_file("/etc/tinc/#{interface}/rsa_key.pub").with_content(/PUBLIC KEY/) }
    it { should contain_file("/etc/tinc/#{interface}/rsa_key.priv").with_content(/PRIVATE KEY/) }
    it { should contain_file("/etc/tinc/#{interface}/hosts").with_ensure('directory') }
    pending("how to test for exported resources https://groups.google.com/forum/#!topic/puppet-users/XgQXt5n017o[1-25]") { should contain_concat("/etc/tinc/#{interface}/hosts/bm0404there").with({
                                                                          :notify	=> "Service[tinc_#{interface}]",
                                                                          :content	=> /1.2.3.4/,
                                                                        }) }
  end

  context 'when running on RedHat' do
    let :facts do
      facts.merge({
        'osfamily' => 'RedHat'
      })
    end

    it {
       should contain_package('tinc').with_ensure('present')
    }
  end
  
  context 'when running on unknown' do
    let :facts do
      facts.merge({
        'osfamily' => 'Plan9'
      })
    end

    it do 
      expect {
        should 
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    end

  end
  
end


describe 'l2mesh::ip' do

  interface = 'NAME'

  context 'when matching fqdn into class C' do

    let :params do
      {
        :interface              => "#{interface}",
        :source			=> 'bm0044.the.re',
        :re			=> '^bm0+(\d+).*',
        :ip                       => '192.168.100.\1',
        :netmask                  => '255.255.255.0'
      }
    end

    it { should contain_file("/etc/tinc").with_ensure('directory') }
    it { should contain_file("/etc/tinc/#{interface}").with_ensure('directory') }
    it { should contain_file("/etc/tinc/#{interface}/tinc-up").with_content(/192.168.100.44/) }
  end  

  context 'when matching fqdn into class B' do

    let :params do
      {
        :interface              => "#{interface}",
        :source			=> 'bm0404.the.re',
        :re			=> '^bm(\d\d)(\d\d)*',
        :ip                       => '192.168.\1.\2',
        :netmask                  => '255.255.0.0'
      }
    end

    it { should contain_file("/etc/tinc").with_ensure('directory') }
    it { should contain_file("/etc/tinc/#{interface}").with_ensure('directory') }
    it { should contain_file("/etc/tinc/#{interface}/tinc-up").with_content(/192.168.04.04/) }
  end  
end
