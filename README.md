---
title:  README.md
description: README for base dvwa_azure_lab project
service: Splunk, DVAW, AZURE, ANSIBLE, DOCKER, Sentinel
author: Jack Turner
---

# dvwa_azure_lab

This project contains a proof-of-concept examining two scenarios using Microsoft Sentinel side-by-side with Splunk Enterprise for a Managed Security Service Provider MSSP log aggregation solution: 1) Resource, logging to Splunk from Azure Eventhub. 2) Resource logging to an Microsoft Sentinel, sending enriched Microsoft Sentinel alerts to 3rd party SIEM (Splunk. Using both the Damn Vulnerable Web Application (DVWA) and a Kali Linux, we are able to emulate malicious traffic originating from a threat, external to the internal network resources.


## Scenario One: On Premises resource -> Splunk
![](Resources/Images/dvwa_azure_lab.drawio.png)
