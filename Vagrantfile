# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check VBox Version for compatibility
if Gem::Version.new(`VBoxManage --version`.strip) <
    Gem::Version.new('6.1.0')
    abort "Please upgrade Virtualbox to 6.1.0 or later!"
end 

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

version_info = IO.readlines("VERSION")
nos3_version = version_info.grep(/^\s*NOS3\s*=/i)[0].split("=")[1].strip
nos3_version = /(\d+\.?)+/.match(nos3_version).to_s

require './vagrant-config.rb'
cp = Configuration::Parser.new(IO.readlines("CONFIG"))
OS = cp.get_string_in_list("OS", ["ubuntu", "oracle", "rocky"], "ubuntu")
GROUND = cp.get_string_in_list("GROUND", ["COSMOS", "AIT", "BOTH", "NONE"], "COSMOS")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Default to Ubuntu
    config.vm.box = "bento/ubuntu-20.04"
    config.vm.box_version = "202212.11.0"
    
    # Was another OS was selected?
    if (OS == "oracle")
        config.vm.box = "bento/oracle-8.5"
        config.vm.box_version = "202112.19.0"
    end
    
    if (OS == "rocky")
        config.vm.box = "bento/rockylinux-8.4"
        config.vm.box_version = "202110.26.0"
    end

    # Configure machine
    config.vm.hostname = "nos3"
    config.vm.synced_folder "./nos3_filestore", "/tmp/filestore"
    
    # https://github.com/hashicorp/vagrant/issues/5186#issuecomment-312349002
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |vbox|
        vbox.gui = true
        vbox.cpus = 2
        vbox.memory = "4096"
        vbox.customize ["modifyvm", :id, "--vram", 128]
        vbox.customize ["showvminfo", :id]
        vbox.customize ["storageattach", :id,  "--storagectl", "IDE Controller", "--port", 1, "--device", 0, "--type", "dvddrive", "--medium", "emptydrive"]
        vbox.customize ["modifyvm", :id, "--hwvirtex", "on"]
        vbox.customize ["modifyvm", :id, "--ioapic", "on"]
        vbox.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
        # Speed up ruby gem installs
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
        # Connect network
        vbox.customize ["modifyvm", :id, "--cableconnected1", "on"]
        # Bi-directional clipboard
        vbox.customize ['modifyvm', :id, '--clipboard-mode', 'bidirectional']
    end

    # One per machine... but multiple environments are/could be represented here 
    # - Operations, with perhaps a MOC and a RAP; Development/AI&T with a flatsat; Development with only a NOS3 entirely software only FSW/sim
    # So you may need to vagrant up one or several of these to get all the machines you need for your environment
    machine_playbooks = {
        "base": "base.yml",
        "dev": "dev.yml",
    }

    machine_playbooks.each do |machine, playbook|
        is_primary = (machine.to_s == "dev")

        config.vm.define machine, primary: is_primary, autostart: is_primary do |nos3|
            nos3.vm.provider "virtualbox" do |vbox|
                vbox.name = "nos3_#{machine}_#{nos3_version}_#{OS}"
            end

            nos3.vm.provision "ansible_local" do |ansible|
                ansible.inventory_path = "ansible/hosts.txt" # needs re-thought out sometime in the future for moc, smoc, etc.
                ansible.limit = "#{machine}"
                ansible.playbook = "ansible/#{playbook}"
                ansible.extra_vars = {
                    filestore: "/tmp/filestore",
                    MACHINE: "#{machine}",
                    OS: "#{OS}",
                    GROUND: "#{GROUND}",
                }
                ansible.playbook_command = "ANSIBLE_FORCE_COLOR=true ANSIBLE_CALLBACK_WHITELIST=profile_tasks ansible-playbook"
                ansible.galaxy_role_file = "ansible/requirements.yml"
                #ansible.tags="guest-additions" # debugging example to just run tasks/roles with this tag
                #ansible.verbose = "vvv" # set to "true" or "vvv" or "vvvv" for debugging
            end
        end
    end
end

