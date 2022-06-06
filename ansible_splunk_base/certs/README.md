# Ansible-Splunk-Base ./certs/

Authentication of the server (server is who it says it is), and optional authentication of the client are requirements of zero trust architecture. We also want to achieve bulk encryption of data in transit. There are several moving parts, "CA", "keys", "CSRs", and the "certs". We often say "SSL" when we mean "TLS". SSL is effectively deprecated.

Out of the box:
        - All certificates are generated on a default-shipped CA configuration
        - Splunkweb does not use SSL
        - Splunkd uses SSL for the REST port - with certificate verification **disabled**
        - No SSL data inputs/outputs are defined
        - Splunkd LDAP can use SSL - with certificate verification **disabled**


### Demo CA Creation
```bash
#Generate the CA private key file
openssl genrsa -out demo-ca.key 2048
#Provision the CA
openssl req -x509 -new -nodes\
  -key       demo-ca.key -sha256 -subj "/C=US/ST=MI/L=Detroit/O=Detroit Cyber/OU=Cybersecurity/CN=demo-ca"\
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
CN = 192.168.86.193

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

cat demo-splunk1.crt demo-ca.crt >> demo-chain-splunk1.crt
cp demo-chain-splunk1.crt ~/dvwa_azure_lab/ansible_splunk_base/certs/cert.pem
```

Place private key (PEM format) in certs/privkey.pem

```bash
cp demo-splunk1.key ~/dvwa_azure_lab/ansible_splunk_base/certs/privkey.pem
```

Upload the certs to $SPLUNK_HOME/etc/auth/my-certs/ on the splunk hosts and perform default configuration to reference these certs in $SPLUNK_HOME/etc/system/local/web.conf

```bash
ansible-playbook -i hosts tls-config.yml
```