#!/usr/bin/env bash
#
# Bootstrap the environment on a given host and update with
# that latest configuration.
#
# see usage() below for script usage
#
# THIS SCRIPT MUST BE ENTIRELY SELF-CONTAINED! Do not use any other script.
################################################################################

# output message to STDERR and exit program
function ss_die() {
    echo -e "ERROR: $*" >&2;
    exit -1
}

# announce a section
function ss_announce()
{
    echo -e "\n########################################"
    echo -e "$1"
    echo -e "########################################\n"

    return 0;
}

# provide status output
function ss_status() { echo -e "# -- $1";  return 0; }

# provide warning output
function ss_warn() { echo -e "# -- WARNING: $1";  return 0; }

# display program usage and exit
function usage
{
  cat <<EOF

Usage: deploy-local-env.sh [ansible command line args]

This script sets up the environment on a non Vagrant managed host.
This script performs the following functions:

1) Installs pip (if missing)
2) Installs ansible (if missing or wrong version)
3) Sets up a symlink in the root directory to allow the playbooks to access the
   filestore in the same manner as they do in the VM
4) Configure the host using Ansible

This scripts will pass any arguments directly to the ansible-playbook command
EOF

exit 1
}

################################################################################
# DEFAULTS
################################################################################

# Version of Ansible to install
REQ_ANSIBLE_VER="2.9.13"

################################################################################
# PROCESS OPTIONS
################################################################################

# Left in script for now in case we want to add overrides in the future

#[[ 1 -le $# ]] || usage
#CNE_HOSTNAME="$1"
#[[ $CNE_HOSTNAME = -* ]] && usage
#shift 1

# process options - see getopt documentation for what this is doing
#set +e
#TEMP=`getopt -o b:p:h \
#   -n "$(basename $0)" -- "$@"`
#[ $? == 0 ] || usage
#set -e
#eval set -- "$TEMP"
#while true ; do
#  case "$1" in
#    -p) ANSIBLE_PLAYBOOK="$2"; shift 2 ;;
#    -b) BRANCH_NAME="$2" ; shift 2 ;;
#    -h|--help) usage ; shift ;;
#    --) shift ; break ;;
#    *) echo "Internal error '$1' '$2'!" ; exit 1 ;;
#  esac
#done

################################################################################
# CHECKS
################################################################################

################################################################################
# MAIN LOGIC
################################################################################

ss_announce "Installing Dependencies"

if [ -f "/etc/debian_version" ]; then
    EXTRA_VARS="OS=ubuntu GROUND=NONE"
    which pip >/dev/null 2>&1
    PIP_INSTALLED=$?

    if [[ $PIP_INSTALLED -eq 0 ]]; then
    	ss_status "pip already installed"
    else
    	sudo apt install -y python3-pip 
    	sudo pip3 install --upgrade pip
    	sudo pip3 install markupsafe typing ansible==2.9.13
    fi
else
    EXTRA_VARS="OS=rocky GROUND=NONE"
    which pip >/dev/null 2>&1
    PIP_INSTALLED=$?

    if [[ $PIP_INSTALLED -eq 0 ]]; then
        ss_status "pip already installed"
    else
        # Add repository that hosts package
        ss_status "Installing pip"
        sudo yum install -y epel-release
        sudo yum -y update
        sudo yum install -y python3-pip
        sudo pip3 install --upgrade 'pip<21.0'
        sudo pip3 install markupsafe typing ansible==2.9.13
    fi
fi

####################

ANSIBLE_INFO=$(pip show ansible 2>/dev/null | grep -E "^Version:")

if [[ "Version: $REQ_ANSIBLE_VER" == "$ANSIBLE_INFO" ]]; then
    ss_status "ansible $REQ_ANSIBLE_VER already installed"
else
    ss_status "Installing ansible"
    sudo -H pip3 install "ansible==$REQ_ANSIBLE_VER"
fi

####################

ss_status "Configure fileshare symlink at /vagrant"
sudo ln -sfn $(pwd)/ /vagrant

####################

ss_announce "Configuring environment"
ss_status "Running ansible playbook: ansible/server.yml"

ANSIBLE_CALLBACK_WHITELIST=profile_tasks \
ansible-playbook ansible/server.yml \
    --ask-become-pass \
    -i ansible/hosts.txt \
    --extra-vars "$EXTRA_VARS" \
    "$@" # we allow passtrough arguments from this script to ansible-playbook command
