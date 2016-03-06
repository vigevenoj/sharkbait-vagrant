# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos7"
  config.vm.provision "ansible" do |ansible|
    ansible.verbose  = "v"
    ansible.playbook = "playbook.yaml"

#    ansible.raw_arguments = ["--roles-path=./etc/ansible/roles geerlingguy.firewall"]
  end
end
