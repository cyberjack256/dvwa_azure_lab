---
title:  README.md
description: README for base dvwa_azure_lab project
service: ELK, DVAW, AZURE, ANSIBLE, DOCKER
author: Jack Turner
---

# dvwa_azure_lab

`This is a project overview of the lab created for MSU_VIRT_CYBER_2022 using both the Damn Vulnerable Web Application (DVWA) and Elastic Logstash and Kibana (ELK) Web-application services containerized in docker and built with anisble`

## Index
- [Azure](#azure)
- [Docker](#docker)
- [Ansible](#ansible)

## Azure

### Azure Environment Diagram:
```Note
TODO: Add Azure Diagram
```
## Docker
```Note:
TODO: Helpful commands for setting up environment
```

## Ansible
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
