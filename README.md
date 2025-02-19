# Deployment

Ansible scripts used to provision the NOS3 VM for development.

## Prerequisites

Each of the applications listed below are required to continue:
* [Git 2.36+](https://git-scm.com/)
* [Vagrant 2.3.4+](https://www.vagrantup.com/)
* [VirtualBox 7.0.6+](https://www.virtualbox.org/)

Older versions of the above software may still work, but were not used to verify the release.
You will need to obtain administrator privileges on your machine in order to install these.
Please contact your favorite IT professional for assistance.

## Choosing Your Configuration

The configuration file must manually be edited prior to provisioning.
This file can be found at the top level of this repository and is called `CONFIG`.
Let's walk through your options:
* Operating System (OS)
  - `rocky` is a distribution based on RHEL
  - `ubuntu` is a distribution of Debian GNU/Linux
* Role (ROLE)
  - `base` is simply the base box with no specific software installed

The default configuration is currently set up as: `ubuntu` and `base`.

## Provisioning from Scratch

Once you've selected your desired configuration, you're ready to provision your VM.
This essentially means downloading and installing all the required software in a specific and repeatable way.
Here are the steps to get this done:
* Use git to clone this repository (if you haven't already)
  - `git clone https://github.com/nasa-itc/deployment.git`
* Open a terminal or command prompt
* Navigate to the deployment folder in the repository that is now local your machine
* Run Vagrant
  - `vagrant up`
* Grab some tea and wait until you get a cursor again
  - The VM will pop up and restart, don't interact with it until provisioning is done
  - Feel free to work on other things while this process is running
* The play recap should be the last thing printed out, use this to verify everything went according to plan
* Restart / reload the VM
  - `vagrant reload`
* In the Virutalbox window, select `Devices > Upgrade Guest Additions...`
  - Wait for the pop-up to close showing completed
* Restart / reload the VM
  - `vagrant reload`
* Login and get to work

## Provisioning to Local Environment

If you're deploying to an existing local environment, a simple script has been provided assuming that the environment is RHEL based called `deploy-local-env.sh`.
This script will run ansible for you.
The script can be edited manually to change settings as needed.
Note that no new user will be created during this process as would typically be done when provisioning from scratch.
Users are expected to be in the `domainusers` group to access shared source at `/opt/jstar`.

## Logging In

The `jstar` user is the typical login you will want to use.
The `vagrant` user was created automatically by the provisioning process and can be left alone.
You'll want to be sure you know the following passwords:
* Username - password
* `jstar` - `jstar123!`
* `vagrant` - `vagrant`

## Quality of Life Improvements

It is recommended that you log-in and setup the virtual machine to your tastes.
The first thing would be to install Virtual Box Guest Additions for your current version by using the `Devices > Upgrade Guest Additions...` option in the toolbar, auto-launching the CD, and following the instructions.
Additionally, you will want to remove the current SSH keys at `/home/jstar/.ssh` and replace them with your personal ones so that you may commit to the git repositories. 

## Re-Provisioning

If changes are made to this repository that you want, you can re-provision your VM to install the latest and greatest.
Note that this only works if you did the entire vagrant process, not if you simply imported an OVA:
* Open a terminal or command prompt
* Navigate to the cloned repository that is now local your machine
* Pull the latest changes
  - `git pull`
* Confirm the `CONFIG` file matches your desired configuration
* Run Vagrant provision
  - `vagrant provision`

## Destroying

Once you've used up your VM you can simply destroy it by following these steps:
* Open a terminal or command prompt
* Navigate to the cloned repository that is now local your machine
* Run Vagrant destroy
  - `vagrant destroy`

Note that this process will not remove all the downloaded base boxes from your machine

# Support

## FAQs:

* A GUI environment hasn't shown up after an extended period (> 1.5 hours), what should I do?
  - Stop the provision, delete the existing VM (if it was created), and try again
  - `CTRL + C`, `vagrant destroy`, `y`, `vagrant up`, wait, `vagrant reload`
* Why doesn't the shared clipboard work?
  - You will most likely need to re-install / update the guest additions and reboot for this to function properly
  - In the VirtualBox menu select: Devices -> Insert Guest Additions CD Image...
  - Follow the instructions provided
* How can I mount a shared folder so that I edit on my host and compile / run in the VM?
  - In the VirtualBox menu select: Devices -> Shared Folders -> Shared Folders Settings...
  - Select the folder with a plus to add your `git` folder, select `Auto-mount`, `Make Permanent`, and `OK`
* After running `vagrant destroy`, the following `vagrant up` command fails with an error stating that it could not rename the directory?
  - You will have to run `vagrant destroy` again then delete the specified directory and try again
* An error appeared during `vagrant up` that stated VT-x was disabled?
  - You'll need to restart your entire machine and enter the bios to enable it
  - Every computer has different bios unfortunately, but it should be something like System Configuration > Virtualization Technology > ENABLE
  - You may then attempt to `vagrant destroy`, and `vagrant up` again!

## References:

* Ansible
  - https://docs.ansible.com/ansible/latest/index.html
  - https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
  - https://yaml.org/spec/1.2/spec.html 
* Git
  - https://git-scm.com/docs/gittutorial
  - https://www.gitkraken.com/learn-git 
* Linux
  - https://ubuntu.com/tutorials/command-line-for-beginners#1-overview 
* Vagrant
  - https://www.vagrantup.com/docs/
* Virtual Box
  - https://www.virtualbox.org/manual/ch01.html

## Debugging

* To see the exact commands executed by vagrant provisioning (and other debugging), try `vagrant provision --debug`
* Within the VM, the ansible_local provisioner can be run (especially for debugging) something like this:
  - `cd /vagrant && PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ANSIBLE_CALLBACK_WHITELIST=profile_tasks ansible-playbook --inventory-file=ansible/hosts.txt --extra-vars=\{\"filestore\":\"/tmp/filestore\",\"MACHINE\":\"basic\",\"GROUND\":\"COSMOS\"\} ansible/nos3-sim.yml --tags base,config`
  - (`--tags ...` can be omitted if all plays/tasks should be run.  Tag `base` just runs the base software env and user creation, tag `config` just performs configuration of 42, ground, planning, and RAP)

## Creating an OVA

Some additional care must be taken when generating an OVA from this process.
Things that should be checked include:
* Remove personal SSH keys if they were added
* Remove all shared folders
* Ensure extended additions is not enabled / is not required

## Creating a base box

### Windows

* Change your configuration as necessary
* `vagrant up`
* Wait until complete
* Confirm no errors
* `vagrant halt`
* Remove all shared folders from box
* Remove or rename any previously generated `package.box` files in local directory
* `vagrant package --output jstar_YYMMDD.box`

### Mac (ARM M1/M2)

* Download Ubuntu ISO manually
  * https://ubuntu.com/download/server/arm
* Setup VM
  * Create new VM manually in VirtualBox
    * sudo su
    * apt install ubuntu-desktop-minimal linux-headers-$(uname -r) build-essential dkms python3-dev gnome-tweaks bzip2 gcc make perl
    * reboot now
  * Insert guest additions ISO and install
  * In a terminal:
    * Follow docker engine install instructions - https://docs.docker.com/engine/install/ubuntu/
    * sudo systemctl disable systemd-networkd
    * sudo usermod -a -G dialout,docker,vboxsf jstar
    * sudo shutdown -h now
* Remove all shared folders from box
* Remove or rename any previously generated `package.box` files in local directory
* vagrant package --base jstar_ubuntu --output jstar_YYMMDD.box

## Docker

* `docker build -t nos3 .`
* `docker run -t -i -v /home/nos3/git:/git nos3 /bin/bash`

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the tags on this repository.
The following list captures a brief description of the version history for reference:
* 0.0.1 - Initial Release
