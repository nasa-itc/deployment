# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

version_info = IO.readlines("VERSION")
nos3_version = version_info.grep(/^\s*NOS3\s*=/i)[0].split("=")[1].strip
nos3_version = /(\d+\.?)+/.match(nos3_version).to_s

require './vagrant-config.rb'
cp = Configuration::Parser.new(IO.readlines("CONFIG"))
OS = cp.get_string_in_list("OS", ["ubuntu", "centos"], "ubuntu")
GROUND = cp.get_string_in_list("GROUND", ["COSMOS", "AIT", "BOTH", "NONE"], "COSMOS")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    if (OS == "centos")
        config.vm.box = "itc/itc-centos-7.6-x86_64-with-desktop"
    else
        config.vm.box = "itc/itc-ubuntu-mate-18.04-amd64"
    end
    config.vm.hostname = "nos3"
    config.vm.synced_folder "./nos3_filestore", "/tmp/filestore"
    config.vm.provider "virtualbox" do |vbox|
        vbox.gui = true
        vbox.cpus = 2
        vbox.memory = "4096"
        vbox.customize ["modifyvm", :id, "--vram", 128]
        vbox.customize ["showvminfo", :id]
        vbox.customize ['storageattach', :id,  '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'dvddrive', '--medium', 'emptydrive']
        vbox.customize ["modifyvm", :id, "--hwvirtex", "on"]
        vbox.customize ["modifyvm", :id, "--ioapic", "on"]
        # Speed up ruby gem installs
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
        # Connect network
        vbox.customize ["modifyvm", :id, "--cableconnected1", "on"]
        # Bi-directional clipboard
        vbox.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
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
                vbox.name = "nos3_#{machine}_#{nos3_version}"
            end

            nos3.vm.provision "ansible_local" do |ansible|
                ansible.inventory_path = "ansible/hosts.txt" # needs re-thought out sometime in the future for moc, smoc, etc.
                ansible.limit = "#{machine}"
                ansible.playbook = "ansible/#{playbook}"
                ansible.extra_vars = {
                    filestore: "/tmp/filestore",
                    MACHINE: "#{machine}",
                    GROUND: "#{GROUND}",
                }
                ansible.playbook_command = "ANSIBLE_FORCE_COLOR=true ANSIBLE_CALLBACK_WHITELIST=profile_tasks ansible-playbook"
                #ansible.verbose = "true" # set to "true" or "vvv" or "vvvv" for debugging
            end
        end
    end
end

