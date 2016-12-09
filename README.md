# sharkbait-vagrant
Puppetized configuration for a sharkbaitextraordinaire

## Requirements
- centos7
- an internet connection
- yum
  - ruby 2+
  
## Getting started
With a blank centos7 box, `vagrant up` should trigger the shell provisioner to install puppet via rpm, followed by the puppet provisioner to do everything else.

## Notes
### PostgreSQL
Currently ensuring that 2 databases are present but not doing anything if they are present. They need to be restored from backup (using pg_restore) for the hosted applications to be functional after provisioning.
Only accepting password-based login from localhost. 
### mosquitto
Mosquitto has no users configured via puppet
This also requires a manual step to create SSL certificates for the server and clients.
### InfluxDB
InfluxDB is currently installing 0.9 because I needed an older version for backwards-compatibility reasons.
Any existing configuration will need to be restored manually.
### mqtt_influx_bridge
This is a custom puppet module to install and configure a script that takes incoming events from MQTT and inserts them into InfluxDB series. I'm using it for some sensor data tracking so it is rather specific to those requirements. Future improvement is to generalize this mqtt_influx_bridge.rb for general usage.
This script does not have an init script, but does perform log rolling on its own. No logrotate configuration required, but you'd have to edit the script to change the existing logging configuration.
### vhosts
- sharkbaitextraordinaire needs to be restored from backup (tar.gz) after provisioning.
- Huginn requires a git clone, database restore, and manual setup after provisioning.
