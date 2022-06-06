# Ansible-Splunk-Base

This is an Ansible project that installs/upgrades Splunk to a specific version. Roles and associated `YAML` file to perform basic OS config (e.g., ulimits, THP disabled, hostname), ./splunk/etc/ backups, and tls cert installation.

## Prerequisites

On `ansible-server`(s), install `docker`

```bash
sudo apt update
sudo apt install docker docker.io
```

On `ansible-server` pull down latest ansible server

```bash
sudo docker pull ansible/ansible:default
```

On `ansible-server` Launch the `ansible` container and interactively connect **first-time only**:

```bash
docker run --name ansible-server ansible/ansible:default # start the container.
```

On `ansible-server` Launch the `ansible` container and interactively connect **following `exit`**:

```bash
docker exec ansible-server bash # interact following `# exit`.
```

On `ansible-server` Git clone this project to the `~` directory

```bash
cd ~
# Enter in all of your variable values between the double quotations. Obtain the values from https://github.com
name="" # Your name (e.g, "Jack Turner")
username="" #Your username located in `account`
email="" #Your email that is located in `profile`
access_token="" # Create your access token and copy here
repo_origin="https://$username:$access_token@gitlab.nps.edu/nps_csoc/socaas-splunk.git"

# git config [--global || --local] user.name "$name" (First time set as --global; we will change later)
git config --local user.name "$name"
git config --local user.email "$email"
git config --local --list

git clone $repo_origin

# Pull down any changes to the repo
#git pull

# When changing token; create a new token; copy the token; and complete the following
#git remote -v # print your `origin`

# Change your origin with the new access_token that you set
#git remote set-url origin $repo_origin

```

On `ansible-server` Navigate to project base directory

```bash
cd ./ansible-splunk-base		
``` 

**hosts**

On `ansible-server` Copy hosts.sample to hosts

```bash
cp ./hosts.sample hosts
```

On `ansible-server` Edit hosts file to include desired hosts

```bash
nano ./hosts
```

On `ansible-server` Copy group_vars/all.sample to group_vars/all

```bash
cp group_vars/all.sample group_vars/all
```

On `ansible-server` Edit group_vars/all variables as appropriate for desired environment

```bash
nano group_vars/all
```

**Certs**



## Operations

**SYNOPSIS**

On `ansible-server` set variable for playbook base directory

```bash
export $ansible_splunk_base="~/ansible-splunk-base/ "
```

On `ansible-server` target host stanzas, limit to select hosts within an host stanza, run one or multiple roles in one command.

```bash
$ansible_splunk_base ansible-playbook -i hosts --limit= demo-splunk1 combo.yml tls-config.yml
```

**Install Splunk only**

On `ansible-server` run the Splunk install playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts install.yml
```

**Upgrade Splunk**

On `ansible-server` run the Splunk upgrade playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts upgrade.yml
```

**Configure OS with Splunk best practices**

On `ansible-server` run the os configuration playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts os-config.yml
```

**Configure OS with Splunk best practices AND install Splunk**

On `ansible-server` run the os configuration and splunk installation playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts combo.yml	
```

**Configure an TLS/SSL key pair for the Splunk web UI on tcp/8000**

On `ansible-server` run the TLS/SSL configuration playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts tls-config.yml						
```

**Install universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF install playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts uf-install.yml
```

**Configure universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF config playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts uf-config.yml
```

**Install and Configure universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF install AND config playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts uf-combo.yml	
```

**Upgrade universal forwarder on Linux host(s)**
On `ansible-server` run the Splunk UF upgrade playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts uf-upgrade.yml					
```

**Backup splunk configuration on Linux host(s)**
On `ansible-server` run the Splunk configuration only (./etc/) backup playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts backup-etc.yml
```
**Backup full-backup splunk on Linux host(s)**

On `ansible-server` run the Splunk full backup (/opt/splunk/) playbook

```bash
$ansible_splunk_base ansible-playbook -i hosts backup-full.yml		
```

### Compatibility

This role has been tested on:

- Ubuntu 20.04 Server (LTS) with ssh and docker installed from ubuntu installation provisioning
- RHEL 8


### Notes

- The goal of this role is to quickly execute a best-practices base Splunk install/upgrade
- The primary goals with this build are simplicity of use, speed of management, and utility in the ecosystem.
- Both "systemd" and "initd" methods of Linux process management are supported. systemd is ONLY available in Splunk Enterprise version 7.2.2 and later. 
- Assuming a semi-default install (e.g., installed with this playbook), upgrade.yml will convert from initd process management to systemd process management if flagged "systemd" on install_method.
- A number of config items are set which disable pop-ups and modal dialogues which would normally be shown to the Splunk admin and/or users such as new version available notifications, UI tours, and python 2.7 deprecation notifications. Requirement: Avoid UI 'nags' present in automatic distributed Splunk deployments.
- This Ansible playbook does not currently handle OS-level firewall allowances for splunkd TCP ports.
- Bias towards being non-destructive; (e.g., detect existing/previous Splunk install == fail rather than damage the current install).