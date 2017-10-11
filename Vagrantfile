Vagrant.configure("2") do |config|

  config.vm.box = "puppetlabs/centos-6.6-64-puppet"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "public", "/var/www/", create: true, owner: 'vagrant', group: 'vagrant', mount_options: ['dmode=777,fmode=666']

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
  end

	config.vm.provision :shell, :path => "vagrant/bootstrap.sh"
	config.vm.provision :shell, run: "always", :inline => <<-EOT
		sudo service httpd restart
	EOT

end
