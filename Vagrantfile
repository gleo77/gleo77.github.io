Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", path: "vagrant-scripts/ruby-provision.sh", privileged: false
  config.vm.provision "shell", path: "vagrant-scripts/run-jekyll.sh", privileged: false, run: "always"
  config.vm.network :forwarded_port, guest: 4000, host: 4000
end
