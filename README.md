---
title:  README.md
description: README for base dvwa_azure_lab project
service: Splunk, DVAW, AZURE, ANSIBLE, DOCKER, Sentinel
author: Jack Turner
---

# dvwa_azure_lab

`This is a project overview of the lab created for MSU_VIRT_CYBER_2022 using both the Damn Vulnerable Web Application (DVWA) and Elastic Logstash and Kibana (ELK) Web-application services containerized in docker and built with anisble`

## Index
- [Azure](#azure)
- [Docker](#docker)
- [Ansible](#ansible)

## Azure

### Azure Red-Team Environment:
![](Resources/Images/dvwa_azure_lab.drawio.png)

### Azure Purple-Team Environment:
```Note
TODO: Add Azure Diagram
```

## Docker
```Note:
TODO: Helpful commands for setting up environment
```

## Ansible

More times than not I have observed organizations struggle with config management and it is key for concise mitigation and remediation plan. In this series of blog posts which will hopefully walk you through a simple deployment of Ansible all the way to the most complex use-cases I have seen. I will first be covering how Ansible can be leverage to manage a Splunk deployment . Phase Two work will will cover how this can be done in a larger scale with Azure utilizing dynamically changing inventory of hosts for deployments which need to scale in a cloud environment. Finally, Phase Three will cover how to manage a enterprise deployment of Splunk with multi-tenecy requirements where there are various “customers” or business units with different Splunk config needs. The idea is to embark the necessary knowledge to not only deploy Splunk but anything else using Ansible as our configuration management system.

### Why Use Ansible
There are a few config management system. Many configuration management solutions exist (e.g., [Ansible](https://www.ansible.com), [Chef](https://www.chef.io/), [Vagrant](https://www.vagrantup.com/)). Ansible meets the requirements needed for deploying Splunk, among other security tools:

  - **No Agent Required** – This is awesome! Personally, I think the less agents a system has the less moving parts it has and the smaller your exploit landscape is. Ansible also has the ability to deploy an agent specially on a scenario where the client endpoint pulls configs instead of a master server pushing them.
  - **Uses SSH as Transport** – No need to deal with custom communication protocols, everything is encrypted natively. Keys are used instead of passwords. SSH is ubiquitous across the varied linux distributions. More often than not clients are already talking to servers via SSH.
  - **Moderate Learning Curve** – I found that the learning curve in Ansible is tremendously flatter than other configuration management frameworks. This is primarily due to the fact that play books read easily. Playbooks are YAML base and the project has thorough [documentation](https://docs.ansible.com/)
  - **Low overhead and scales to huge deployments** – There is no need to run a dedicated Ansible master server; the application has very low resource requirements. Ansible is also shown to scale. Check out how N
  - **Python Base** – Do not like something, want to integrate with something else? Ansible is python based and very easily extendable.

### Ansible Structure
![](Resources/Images/Ansible.png)


  - **ansible-playbook:** Ansible executable which runs the playbooks etc..
  - **hosts:** INI file which contains the role/group and host mapping
  - playbooks: Ties in Roles, host groups and task together to create orchestrated actions on target hosts
  - **roles:** contains the actions each group will complete (this is where the deployment logic lives).

### Roles
Lets walk through the structure of a role. I will start with the common role. The common role should be ran no matter what kind of role the host has as it performs common functions that you would want on every host. If we look at the main.yml under tasks for this role we can see all the tasks it performs.

```bash
cat roles/common/tasks/main.yml
```

```YAML
---
# This playbook contains common tasks in this role
- include: apt.yml
- include: users.yml
- include: files.yml
- include: cron.yml
- include: time.yml
```

```bash
cat roles/common/tasks/apt.yml
```

```YAML
---
# This playbook install the apps required in a server
- name: install security controls
tags:
- configuration
- security
apt: name={{ item }} state=present
with_items:
- chkrootkit
- clamav
- name: install basic utilities
tags:
- system applications
apt: name={{ item }} state=present
with_items:
- vim
- net-tools
- yum-utils
- wget
- htop
```

The description of this is at the top as a comment. Using the “apt” Ansible module (follow the link for information on modules) we install a variety of software on the server. The first batch of software is tagged as “configuration” and “security” and the last are just configurations. The first batch install chkrootkit, clamav, and the second stanza installs a set of configuration utilities (vim, net-tools, yum-utils, wget, and htop. This is the typical structure of an Ansible play, which coordinates what happens on the host system. Plays are powered by different kinds of Ansible modules, the one used above is apt module. A full list of supported modules is available in the Ansible [Docs](https://docs.ansible.com/).



```bash
#Directory Structure
.:
ansible.cfg
elk.yml
filebeat-config.yml
filebeat-playbook.yml
files
hosts
metricbeat-playbook.yml
pentest.yml

./files:
filebeat-config.yml
metricbeat-config.yml
```


### pentest.yml
```
Description of playbook
```
```YAML
---
# This ansible-playbook is used to install Docker,Python/Pip, and the DVWA Web-App on two Azure hosts
- name: Config Web VM with Docker
  hosts: webservers
  become: true
  tasks:
# This section installs docker.io with the apt pkg mgr if not present
    - name: docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present
# This section to install pip3 using the apt pkg mgr if not present
    - name: Install pip3
      apt:
        name: python3-pip
        state: present
# This section to install Docker Python Module using the pip pkg mgr if not present
    - name: Install Docker Python Module
      pip:
        name: docker
        state: present
# This section to install Docker web container cyberxserucirty/dvwa Image and Start the container
    - name: Download and Launch a Docker Web Container
      docker_container:
        name: dvwa
        image: cyberxsecurity/dvwa
        state: started
        restart_policy: always
        published_ports: 80:80
# This section enables the Docker service at start
    - name: Enable Docker Service
      systemd:
        name: docker
        enabled: yes
```
### elk.yml
```
Description of playbook
```
```YAML
---
# This ansible-playbook is used to install Docker,Python/Pip, and the DVWA Web-App on two Azure hosts
- name: Config Elk VM with Docker
  hosts: elk
  become: true
  tasks:
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: '262144'
        state: present
        reload: yes
# This section installs docker.io with the apt pkg mgr if not present
    - name: docker.io
      apt:
        update_cache: yes
        name: docker.io
        state: present
# This section to install pip3 using the apt pkg mgr if not present
    - name: Install pip3
      apt:
        name: python3-pip
        state: present
# This section to install Docker Python Module using the pip pkg mgr if not present
    - name: Install Docker Python Module
      pip:
        name: docker
        state: present

# This section to install Docker web container sebp/elk:761 Image, start the container, and map ports
    - name: Download and Launch a Docker Elk Container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        published_ports: 
          - 5601:5601
          - 9200:9200
          - 5044:5044
# This section enables the Docker service at start
    - name: Enable Docker Service
      systemd:
        name: docker
        enabled: yes

```

### hosts

```
Ensure to add the following roles (e.g., [webservers])
IP addresses will vary depending on your deployment
```

```YAML
[webservers]
10.3.0.5 ansible_python_interpreter=/usr/bin/python3
10.3.0.6 ansible_python_interpreter=/usr/bin/python3

[elk]
10.0.0.4 ansible_python_interpreter=/usr/bin/python3
```

### ansible.cfg

```
Ensure to uncomment the following `remote_user` and update with `Web-1` and `Web-1` <username>
```
```YAML
remote_user = redadmin
```

### filebeat-config.yml
```
Ensure to change the `hosts`, `username` and `password` lines appropriately
IP addresses will vary depending on your deployment
```
```YAML
#-------------------------- Elasticsearch output -------------------------------
output.elasticsearch:
  # Boolean flag to enable or disable the output module.
  #enabled: true

  # Array of hosts to connect to.
  # Scheme and port can be left out and will be set to the default (http and 9200)
  # In case you specify and additional path, the scheme is required: http://localhost:9200/path
  # IPv6 addresses should always be defined as: https://[2001:db8::1]:9200
  hosts: ["10.0.0.4:9200"]
  username: "elastic"
  password: "changeme" # Change this to the password you set
```
...
```YAML
#============================== Kibana =====================================

# Starting with Beats version 6.0.0, the dashboards are loaded via the Kibana API.
# This requires a Kibana endpoint configuration.
setup.kibana:
  host: "10.0.0.4:5601" # Change this to the IP address of your ELK server
```

### filebeat-playbook.yml
```
TODO: Description of playbook
```
```YAML
---
- name: Install and Launch Filebeat
  hosts: webservers
  become: yes
  tasks:
  - name: Download filebeat.deb file
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.1-amd64.deb

  - name: Install filebeat.yml
    command: dpkg -i filebeat-7.6.1-amd64.deb

  - name: Dropper for Filebeat config
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml

  - name: Enable the configuration System Module
    command: filebeat modules enable system

  - name: Setup filebeat
    command: filebeat setup

  - name: Enable the service filebeat on startup
    systemd:
      name: filebeat
      enabled: yes

  - name: Point config to filebeat.yml
    command: filebeat -c /etc/filebeat/filebeat.yml
```

### metricbeat-config.yml
```
Ensure to change the `hosts`, `username` and `password` lines appropriately
IP addresses will vary depending on your deployment
```
```YAML
#============================== Kibana =====================================

# Starting with Beats version 6.0.0, the dashboards are loaded via the Kibana API.
# This requires a Kibana endpoint configuration.
setup.kibana:
  host: "10.0.0.4:5601" # Change this to the IP address of your ELK server
```
...
```YAML
#================================ Outputs =====================================

# Configure what output to use when sending the data collected by the beat.

#-------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["10.0.0.4:9200"] # Change this to the IP address of your ELK server
  username: "elastic" 
  password: "changeme" # Change this to the password you set
```


### metricbeat-playbook.yml
```
TODO: Description of playbook
```
```YAML
---
- name: Install Metric Beat
  hosts: webservers
  become: true
  tasks:
  - name: Download Metric Beat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

  - name: Install Metric Beat
    command: dpkg -i metricbeat-7.6.1-amd64.deb

  - name: Drop Metric Beat Config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

  - name: Enable and configure docker module for Metric Beat
    command: metricbeat modules enable docker
    
  - name: Setup Metric Beat
    command: metricbeat setup

  - name: Start Metric Beat
    command: service metricbeat start

  - name: Enable Service Metric Beat on Startup
    systemd:
      name: metricbeat
      enabled: true
```
