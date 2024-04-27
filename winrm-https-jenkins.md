<pre>
  
To use WinRM over HTTPS, you'll need to perform a few additional steps compared to using WinRM over HTTP.
 Here's a script that sets up Ansible to use WinRM over HTTPS:

Dockerfile:

# Base image
FROM amazonlinux:2

# Install necessary packages
RUN yum install -y python3-pip && \
    yum clean all

# Install Ansible and dependencies
RUN pip3 install ansible pywinrm

# Copy files into the container
COPY ansible_playbook.yml /ansible/
COPY generate_inventory.sh /ansible/
COPY ansible.cfg /ansible/

# Set working directory
WORKDIR /ansible
Ansible Playbook (ansible_playbook.yml):

## code
---
- name: Example Playbook
  hosts: windows_servers
  tasks:
    - name: Example WinRM Task
      win_command: hostname
      register: hostname_output
    
    - debug:
        var: hostname_output.stdout
Bash Script (generate_inventory.sh):

## Code
#!/bin/bash

# Generate inventory file
echo "[windows_servers]" > inventory.txt
echo "your_windows_server_fqdn" >> inventory.txt

# Generate Ansible configuration file
cat <<EOF > ansible.cfg
[defaults]
inventory = inventory.txt
interpreter_python = auto_silent
[privilege_escalation]
become = true
become_method = runas
become_user = your_domain_username
become_password = '{{ lookup("env", "MYADCREDCRED_ID") }}'
[ssh_connection]
# Define connection type as winrm
transport = winrm
# Define protocol as https
winrm_transport = ntlm
# Define HTTPS port
winrm_port = 5986
# Define path to CA certificate
winrm_cert_validation = ignore
# Define whether to use SSL encryption
winrm_server_cert_validation = ignore
EOF
This script sets up Ansible to use WinRM over HTTPS by configuring the ansible.cfg file with the appropriate parameters:

transport: Specifies WinRM as the transport protocol.
winrm_transport: Specifies NTLM authentication.
winrm_port: Specifies the HTTPS port (5986).
winrm_cert_validation: Ignores certificate validation for the WinRM connection.
winrm_server_cert_validation: Ignores SSL encryption for the WinRM connection.
Replace "your_windows_server_fqdn" with the actual FQDN of your Windows server.

Ensure that the Jenkins credential ID for the AD credentials is "myadcred" as specified. The bash script uses an environment variable MYADCREDCRED_ID to fetch the password securely from Jenkins.

Remember to set appropriate permissions (chmod +x generate_inventory.sh) to make the script executable.

</pre>
