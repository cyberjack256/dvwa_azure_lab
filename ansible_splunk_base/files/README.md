# Ansible-Splunk-Base ./files/

By default, this project downloads Splunk Enterprise and Universal Forwarder versions, using the `wget` utility, from the official Splunk download links.

Download the Splunk .tgz from `files` to the `ansible-server`, do so by modifying the download_tgz_from_splunk_servers and download_uf_tgz_from_splunk_servers (specifically setting either of them to "false") in ./group_vars/all

If a file with the same MD5 checksum is already present on the server, this project does not re-download/upload the file.

Reference
[Secure Splunk Web with your own certificate](https://docs.splunk.com/Documentation/Splunk/8.2.0/Security/SecureSplunkWebusingasignedcertificate)