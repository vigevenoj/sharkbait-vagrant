yumrepo { 'home_oojah_mqtt':
  ensure   => 'present',
  baseurl  => 'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/',
  descr    => 'mqtt (CentOS_CentOS-7)',
  enabled  => '1',
  gpgcheck => '1',
  gpgkey   => 'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-7/repodata/repomd.xml.key',
}

yumrepo { 'epel':
  ensure         => 'present',
  descr          => 'Extra Packages for Enterprise Linux 7 - $basearch',
  enabled        => '1',
  failovermethod => 'priority',
  gpgcheck       => '1',
  gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7',
  mirrorlist     => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch',
}

resources { "firewall":
  purge => true
}
Firewall {
  before  => Class['my_fw::post'],
  require => Class['my_fw::pre'],
}
class { ['my_fw::pre', 'my_fw::post']: }
class { 'firewall': }

class my_fw::pre {
  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
    }->
    firewall { '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
      }->
      firewall { '002 accept related established rules':
        proto  => 'all',
        state  => ['RELATED', 'ESTABLISHED'],
        action => 'accept',
      }
      # Specific firewall rules for services
      firewall { '100 allow ssh':
        state  => ['NEW'],
        dport   => '22', 
        proto  => 'tcp',
        action => 'accept',
      }
      firewall { '101 allow http and https access':
        dport   => [80, 443],
        proto  => 'tcp',
        action => 'accept',
      }
      firewall { '102 allow mqtts access':
        dport   => '8883',
        proto  => 'tcp',
        action => 'accept',
      }
      firewall { '103 allow mqtt websocket access':
        dport   => '8884',
        proto  => 'tcp', 
        action => 'accept',
      }
      firewall { '104 allow mqtt access for embedded devices':
        dport   => '8885',
        proto  => 'tcp',
        action => 'accept',
      }
      firewall { '105 allow influxdb':
        dport   => '8086',
        proto  => 'tcp',
        action => 'accept',
      }
}
class my_fw::post {
  firewall { '999 drop all':
    proto  => 'all',
    action => drop,
    before => undef,
  }
}

# Ensure that these packages are installed
package { [
  "git",
  "php-pgsql",
  "php-mysql",
]:
  ensure => latest
}

# Security group for users who can update files in the httpd docroots
group { "webdevs" :
  ensure => present,
}

class { 'apache':
}
class { 'apache::mod::php':
}

apache::vhost { 'sharkbaitextraordinaire.com':
  default_vhost => true,
  port          => '80',
  docroot       => '/var/www/sharkbaitextraordinaire.com/',
  docroot_owner => 'root',
  docroot_group => 'webdevs',
}
apache::vhost { 'sharkbaitextraordinaire.com ssl':
  servername => 'sharkbaitextraordinaire.com',
  port       => '443',
  docroot    => '/var/www/sharkbaitextraordinaire.com/',
  ssl        => true,
}
#  apache::vhost { 'hugs.sharkbaitextraordinaire.com':
#servername      => 'hugs.sharkbaitextraordinaire.com',
#port            => '80',
#docroot         => '/opt/huginn/huginn/public',
#redirect_status => 'permanent',
#redirect_dest   => 'https://hugs.sharkbaitextraordinaire.coim/',
#}
#  apache::vhost { 'hugs.sharkbaitextraordinaire.com ssl':
#    servername      => 'hugs.sharkbaitextraordinaire.com',
#    port            => '443',
#    ssl             => true,
#    docroot         => '/opt/huginn/huginn/public',
#    request_headers => [ 'set X-Forwarded-Proto "https"', ],
#    proxy_pass      => [ { 'path'      =>  '/',  'url' => 'http://127.0.0.1:3000' } ],
#  }

file { '/var/www/sharkbaitextraordinaire.com':
  ensure => 'directory',
  group  => 'webdevs',
  mode   => '2775',
}

notify { 'message':
  message => hiera('message'),
}

#  file { '/opt/huginn':
#    ensure => 'directory'
#  }

#  file { '/opt/huginn/huginn/public':
#    ensure => 'directory',
#    group  => 'webdevs',
#    mode   => '2775',
#}

class { 'postgresql::globals':
  version             => '9.4',
  manage_package_repo => true,
  #    needs_initdb        => false,
  service_name        => 'postgresql-9.4',
  encoding            => 'UTF-8',
  locale              => 'en_US.UTF-8',
  }->
class { 'postgresql::server':
  listen_addresses        => 'localhost',
  postgres_password       => 'postgres',
  ip_mask_allow_all_users => '127.0.0.1/32',
  ipv4acls                => ['local all all md5'],
}

postgresql::server::db { 'workouts':
  user     => 'workout',
  password => 'runrunrun',
}
postgresql::server::db { 'huginn':
  user     => 'huginn',
  password => 'myhuginnpassword',
}

vcsrepo { '/opt/huginn/huginn':
  provider => git,
  source   => "https://github.com/vigevenoj/huginn.git",
  ensure   => present,
}

# mosquitto: configuration = base + websockets + embedded short tls cert devices
# mosquitto: users?
file { '/tmp/mosquitto-ws.conf':
  source => "puppet:///modules/mosquitto/mosquitto-ws.conf",
}

file { '/tmp/mosquitto-esp.conf':
  source => "puppet:///modules/mosquitto/mosquitto-esp.conf",
}


class { 'influxdb':
}
