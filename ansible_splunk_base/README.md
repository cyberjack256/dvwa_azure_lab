# Ansible-Splunk-Base

This is an Ansible project that installs/upgrades Splunk to a specific version. Roles and associated `YAML` file to perform basic OS config (e.g., ulimits, THP disabled, hostname), ./splunk/etc/ backups, and tls cert installation.

## Prerequisites

On `ansible-server`, install `docker`

```bash
sudo apt upgrade -y && sudo apt update -y
sudo apt install docker docker.io
```

On `ansible-server` pull down latest ansible server

```bash
sudo docker pull diodonfrost/ansible-ubuntu:20.04
```

On `ansible-server` Launch the `ansible-server container` and interactively connect **first-time only**:

```bash
sudo docker run --name ansible-server diodonfrost/ansible-ubuntu:20.04 # start the container and interact
```

On `ansible-server container` Launch the `ansible` container and interactively connect **following `exit`**:

```bash
sudo docker exec -it ansible-server bash # interact following `# exit`.
```

On `ansible-server container` upgrade and update the container

```bash
apt update && apt upgrade -y && apt install nano sshpass
```

On `ansible-server container` Git clone this project to the `~` directory

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

On `ansible-server container` Navigate to project base directory

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

Out of the box:
        - All certificates are generated on a default-shipped CA configuration
        - Splunkweb does not use SSL
        - Splunkd uses SSL for the REST port - with certificate verification **disabled**
        - No SSL data inputs/outputs are defined
        - Splunkd LDAP can use SSL - with certificate verification **disabled**


**Demo CA Creation**
```bash
#Generate the CA private key file
openssl genrsa -out demo-ca.key 2048
#Provision the CA
openssl req -x509 -new -nodes\
        -key demo-ca.key -sha256 -subj "/C=US/ST=MI/L=Detroit/O=Detroit Cyber/OU=Cybersecurity/CN=demo-ca"\
        -days 365 -out demo-ca.crt #1 year CA

```
### Splunk Cert Signing Request (CSR) Configuration Creation
Create a configuration file named <server>csr.conf for generating the Certificate Signing Request (CSR) as shown below. Replace the values as appropriate. 



```bash
cat > demo-splunk1.csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = Michigan
L = Detroit
O = Detroit Cyber
OU = Cybersecurity
CN = demo-splunk1.turnerhomestead.com

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = demo-splunk1.turnerhomestead.com
IP.1 = 192.168.86.193


EOF
```
### Splunk server private key creation

openssl genrsa -out demo-splunk1.key 2048

### Splunk server cert signing request (CSR) creation

```bash
openssl req -new -key demo-splunk1.key -out demo-splunk1.csr -config demo-splunk1.csr.conf
```
### Generate the Splunk server SSL certificate using ca.key, ca.crt and server.csr
```
openssl x509 -req -in demo-splunk1.csr -CA demo-ca.crt -CAkey demo-ca.key  -extfile demo-splunk1.csr.conf -CAcreateserial -out demo-splunk1.crt -days 90 # 3-month 
```

### Operations

To upload custom SSL certs to install with Splunk for the Web UI (default tcp/8000):

Place public key (PEM format) in certs/cert.pem (include intermediate chain after the public key if available).

```bash
cat demo-splunk1.crt demo-ca.crt >> demo-chain.crt
cp demo-chain.crt ~/dvwa_azure_lab/ansible_splunk_base/certs/cert.pem
```

Place private key (PEM format) in certs/privkey.pem

```bash
cp demo-splunk1.key ~/dvwa_azure_lab/ansible_splunk_base/certs/privkey.pem
```

Upload the certs to $SPLUNK_HOME/etc/auth/my-certs/ on the splunk hosts and perform default configuration to reference these certs in $SPLUNK_HOME/etc/system/local/web.conf

```bash
ansible-playbook -i hosts tls-config.yml
```

## Operations

**SYNOPSIS**

On `ansible-server` set variable for playbook base directory

```bash
export ="~/ansible-splunk-base/ "
```

On `ansible-server` target host stanzas, limit to select hosts within an host stanza, run one or multiple roles in one command.

```bash
ansible-playbook -i hosts --limit= demo-splunk1 combo.yml tls-config.yml
```

**Install Splunk only**

On `ansible-server` run the Splunk install playbook

```bash
ansible-playbook -i hosts install.yml
```

**Upgrade Splunk**

On `ansible-server` run the Splunk upgrade playbook

```bash
ansible-playbook -i hosts upgrade.yml
```

**Configure OS with Splunk best practices**

On `ansible-server` run the os configuration playbook

```bash
ansible-playbook -i hosts os-config.yml
```

**Configure OS with Splunk best practices AND install Splunk**

On `ansible-server` run the os configuration and splunk installation playbook

```bash
ansible-playbook -i hosts combo.yml	
```

**Configure an TLS/SSL key pair for the Splunk web UI on tcp/8000**

On `ansible-server` run the TLS/SSL configuration playbook

```bash
ansible-playbook -i hosts tls-config.yml						
```

**Install universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF install playbook

```bash
ansible-playbook -i hosts uf-install.yml
```

**Configure universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF config playbook

```bash
ansible-playbook -i hosts uf-config.yml
```

**Install and Configure universal forwarder on Linux host(s)**

On `ansible-server` run the Splunk UF install AND config playbook

```bash
ansible-playbook -i hosts uf-combo.yml	
```

**Upgrade universal forwarder on Linux host(s)**
On `ansible-server` run the Splunk UF upgrade playbook

```bash
ansible-playbook -i hosts uf-upgrade.yml					
```

**Backup splunk configuration on Linux host(s)**
On `ansible-server` run the Splunk configuration only (./etc/) backup playbook

```bash
ansible-playbook -i hosts backup-etc.yml
```
**Backup full-backup splunk on Linux host(s)**

On `ansible-server` run the Splunk full backup (/opt/splunk/) playbook

```bash
ansible-playbook -i hosts backup-full.yml		
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