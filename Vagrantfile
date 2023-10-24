# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check VBox Version for compatibility
if Gem::Version.new(`VBoxManage --version`.strip) <
    Gem::Version.new('6.1.0')
    abort "Please upgrade Virtualbox to 6.1.0 or later!"
end 

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require './vagrant-config.rb'
cp = Configuration::Parser.new(IO.readlines("CONFIG"))
OS = cp.get_string_in_list("OS", ["ubuntu", "oracle", "rocky"], "ubuntu")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Default to Ubuntu
    config.vm.box = "bento/ubuntu-20.04"
    config.vm.box_version = "202303.13.0"
    
    # Was another OS was selected?
    if (OS == "rocky")
        config.vm.box = "bento/rockylinux-8"
        config.vm.box_version = "202305.24.0"
    end

    # Configure machine
    config.vm.hostname = "nos3"
    config.vm.synced_folder "./nos3_filestore", "/tmp/filestore"
    
    # https://github.com/hashicorp/vagrant/issues/5186#issuecomment-312349002
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |vbox|
        vbox.gui = true
        vbox.cpus = 4
        vbox.memory = "8192"
        vbox.customize ["modifyvm", :id, "--paravirtprovider", "minimal"]
        vbox.customize ['modifyvm', :id, '--nested-hw-virt', 'on']
        vbox.customize ["modifyvm", :id, "--vram", 128]
        vbox.customize ["storageattach", :id,  "--storagectl", "IDE Controller", "--port", 1, "--device", 0, "--type", "dvddrive", "--medium", "emptydrive"]
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
    }

    machine_playbooks.each do |machine, playbook|
        is_primary = (machine.to_s == "base")

        config.vm.define machine, primary: is_primary, autostart: is_primary do |nos3|
            nos3.vm.provider "virtualbox" do |vbox|
                vbox.name = "nos3_#{OS}"
            end

            nos3.vm.provision "ansible_local" do |ansible|
                ansible.inventory_path = "ansible/hosts.txt" # needs re-thought out sometime in the future for moc, smoc, etc.
                ansible.limit = "#{machine}"
                ansible.playbook = "ansible/#{playbook}"
                ansible.extra_vars = {
                    filestore: "/tmp/filestore",
                    MACHINE: "#{machine}",
                    OS: "#{OS}",
                }
                ansible.playbook_command = "ANSIBLE_FORCE_COLOR=true ANSIBLE_CALLBACK_WHITELIST=profile_tasks ansible-playbook" #  ANSIBLE_KEEP_REMOTE_FILES=1
                #ansible.tags="gnome-nice-to-haves" # debugging example to just run tasks/roles with this tag
                #ansible.verbose = "vvv" # set to "true" or "vvv" or "vvvv" for debugging
            end
        end
    end
end
