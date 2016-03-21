class mqtt_influx_bridge (
  $mqtt_host,
  $mqtt_port,
  $mqtt_username,
  $mqtt_password,
  $mqtt_topic,

  $influx_database,
  $influx_username,
  $influx_password
) {

  package { 'rubygems':
    ensure => 'present',
  }
  package { 'ruby-devel':
    ensure => 'latest',
  }
  package { 'mqtt':
    ensure   => 'latest',
    provider => 'gem',
  }
  package { 'json':
    ensure   => 'latest',
    provider => 'gem',
  }
  package { 'logger':
    ensure   => 'latest',
    provider => 'gem',
  }

  file { '/opt/mqtt_influx_bridge':
    ensure => 'directory',
  }

  file { '/opt/mqtt_influx_bridge/mqtt_influx_bridge.rb':
    #content => template ( mqtt_influx_bridge/mqtt_influx_bridge.rb ),
    source  => "puppet:///modules/mqtt_influx_bridge/bridge/gistfile1.txt" ,
    owner   => nobody,
    group   => nobody,
    mode    => '644',
  }
  file { '/opt/mqtt_influx_bridge/config.yaml':
    content => template('mqtt_influx_bridge/config.yaml.erb'),
    owner   => nobody,
    group   => nobody,
    mode    => '644',
  }
}
