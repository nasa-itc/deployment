# NASA Operational Simulator for Small Satellites (NOS3)

NOS3 is a suite of tools developed by NASA's Katherine Johnson Independent Verification and Validation (IV&V) Facility to aid in areas such as software development, integration & test (I&T), mission operations/training, verification and validation (V&V), and software systems check-out. 
NOS3 provides a software development environment, a multi-target build system, an operator interface/ground station, dynamics and environment simulations, and software-based models of spacecraft hardware.

# Documentation

[NOS3 - ReadTheDocs](https://nos3.readthedocs.io/en/latest/)

## Issues and Feature Requests

Please report issues and request features on the GitHub tracking system - [NOS3 Issues](https://www.github.com/nasa/nos3/issues).

If you would like to contribute to the repository, please complete this [NASA Form][def] and submit it to gsfc-softwarerequest@mail.nasa.gov with John.P.Lucas@nasa.gov CC'ed.
Next, please create an issue describing the work to be performed noting that you intend to work it, create a related branch, and submit a pull request when ready. When complete, we will review and work to get it integrated.

If this project interests you or if you have any questions, please feel free to open an issue or discussion on the GitHub, contact any developer directly, or email `support@nos3.org`.

[def]: https://github.com/nasa/nos3/files/14578604/NOS3_Invd_CLA.pdf "NOS3 NASA Contributor Form PDF"

## License

This project is licensed under the NOSA 1.3 (NASA Open Source Agreement) License. 

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the tags on this repository.

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
    * 4 CPUs, 8192MB RAM, 128MB graphics, 64GB VMDK HDD
    * Skip unattended install
  * Install ubuntu manually
    * Name: jstar, Server name: itc
    * Reboot once prompted, log in as new jstar user
    * sudo apt install ubuntu-desktop-minimal linux-headers-$(uname -r) build-essential dkms python3-dev gnome-tweaks bzip2 gcc make perl
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
