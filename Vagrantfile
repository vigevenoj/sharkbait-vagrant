# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos7"
  config.vm.hostname = "vagrant-centos7.local"
  
  config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.provision :shell, :path => 'bootstrap.sh'

  config.vm.provision :puppet do |puppet|
    puppet.facter = {
      "fqdn" => config.vm.hostname
    }
    puppet.module_path = "puppet/modules"
    puppet.manifests_path = "puppet/manifests"
  end
end
