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
[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_ext
distinguished_name = dn

[dn]
C = US
ST = Michigan
L = Detroit
O = Detroit Cyber
OU = Cybersecurity
CN = 192.168.86.193

[ req_ext ]
subjectAltName = @alt_names

[v3_ext]
subjectAltName = @alt_names
extendedKeyUsage = serverAuth
keyUsage = keyEncipherment, dataEncipherment

[alt_names]
DNS.1 = demo-splunk1.turnerhomestead.com
DNS.2 = demo-splunk1
IP.1  = 192.168.86.193


EOF
```
### Splunk server private key creation

```bash
openssl genrsa -out demo-splunk1.key 2048
```

### Splunk server cert signing request (CSR) creation

```bash
openssl req -new -key demo-splunk1.key -out demo-splunk1.csr -config demo-splunk1.csr.conf
```
### Generate the Splunk server SSL certificate using ca.key, ca.crt and server.csr
```
openssl x509 -req -in demo-splunk1.csr -CA demo-ca.crt -CAkey demo-ca.key  -extfile demo-splunk1.csr.conf -extensions 'v3_ext' -CAcreateserial -out demo-splunk1.crt -days 90 # 3-month 
```

### View the output of your newly minted SSL certificate with SAN names
```bash
openssl x509 -in demo-splunk1.crt -noout -text
```

The output should look nearly identical
```root@9bf78502c3f1:~# openssl x509 -in demo-splunk1.crt -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            3f:d3:7a:48:86:98:a3:38:62:68:0b:64:5f:7f:a8:16:cd:40:c3:97
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = US, ST = MI, L = Detroit, O = Detroit Cyber, OU = Cybersecurity, CN = demo-ca
        Validity
            Not Before: Jun  8 21:17:25 2022 GMT
            Not After : Sep  6 21:17:25 2022 GMT
        Subject: C = US, ST = Michigan, L = Detroit, O = Detroit Cyber, OU = Cybersecurity, CN = 192.168.86.193
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:a0:b5:ff:f4:ff:85:53:10:cf:0a:2f:3b:73:85:
                    4d:68:e4:1c:ff:a6:7c:ac:d7:cb:e4:75:dd:26:2c:
                    de:a6:cb:04:a5:92:38:46:a0:cd:16:c5:48:7e:4c:
                    64:71:cd:22:33:7a:cb:10:a7:3d:2b:5c:87:a4:a4:
                    86:2c:8d:b6:cd:e9:fe:0c:03:71:da:72:0e:b5:7b:
                    cc:7d:c6:ce:a7:76:25:f0:88:0d:2e:18:40:0f:ed:
                    9d:e3:49:1e:bf:e6:8f:91:df:5e:f2:40:5c:2f:38:
                    c0:8a:4c:79:9d:a7:88:66:74:64:ba:d8:70:ba:ea:
                    7a:e4:53:1b:f3:80:40:40:85:da:08:1d:73:a3:19:
                    49:2d:59:ff:0b:23:8e:e8:c0:ab:6d:43:d7:80:62:
                    c5:f2:2e:60:0e:73:fc:e1:ca:15:7c:45:5a:04:21:
                    07:13:06:9e:15:6d:b8:4d:b6:df:b8:7c:e9:06:d3:
                    88:fd:3b:90:f3:39:2e:9d:8a:ca:92:d2:96:41:58:
                    c2:63:25:a4:2e:2c:6f:d9:6b:98:ea:8b:6c:c1:7e:
                    09:2b:07:84:e7:f1:5e:2d:5a:6c:e7:5e:9d:13:93:
                    58:43:68:6d:fe:5a:1f:67:7f:62:69:17:cc:2a:82:
                    84:b9:c4:31:2b:01:0d:5e:0d:6d:19:8d:fb:4b:6d:
                    ed:ed
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Alternative Name:
                DNS:demo-splunk1.turnerhomestead.com, DNS:demo-splunk1, DNS:*.demo-splunk1.turnerhomestead.com, IP Address:192.168.86.193
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Key Usage:
                Key Encipherment, Data Encipherment
    Signature Algorithm: sha256WithRSAEncryption
         39:8b:4e:ce:f7:e4:9d:c2:2b:62:b1:e9:13:9f:e7:62:70:50:
         17:ba:44:44:27:0d:e0:88:35:41:49:89:e5:02:81:d7:81:e9:
         1c:40:84:55:43:d8:13:28:8a:fa:d1:4e:84:43:52:ce:a5:fa:
         26:18:d8:87:0b:89:64:7c:a6:21:7c:96:8c:cb:08:6d:7f:ff:
         b6:e8:bd:3c:f5:2c:1f:be:3f:48:29:0f:d5:b2:c3:02:2b:40:
         2b:43:ae:d1:33:ac:59:83:fd:99:5d:7d:77:31:12:24:af:a4:
         db:ab:c3:1a:6c:91:d9:d4:d9:91:e8:6f:60:08:f5:5a:a3:63:
         92:43:ba:fa:bb:b4:30:76:17:84:3a:cf:f8:57:29:71:8e:e4:
         b1:08:35:f5:7c:ca:30:ab:f2:09:ad:66:be:d5:2f:68:aa:8c:
         83:9e:62:2c:65:84:a6:04:dd:70:72:e3:5a:26:e1:ae:a1:5a:
         42:d5:11:ad:6d:bb:ae:51:25:73:0a:91:00:24:64:4d:46:df:
         ab:e9:8f:a6:d9:fa:d5:04:f2:cb:49:0c:b9:ab:c8:4a:a5:6e:
         d9:8c:93:2a:c0:e7:d6:cd:65:23:80:f0:ec:48:78:bd:48:d4:
         66:f2:96:77:f2:e5:f4:cd:cb:90:15:90:ff:f8:d8:a2:bb:c2:
         13:ad:b8:3a

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