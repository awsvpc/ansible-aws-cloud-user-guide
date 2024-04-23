---
- name: Check second network interface on RHEL host
  hosts: your_host
  gather_facts: yes

  tasks:
    - name: Gather facts about the EC2 instance
      setup:
        filter: "ansible_net*"  # Only gather network facts

    - name: Exclude loopback IP address
      set_fact:
        ipv4_addresses_no_loopback: "{{ ec2_instance_info.ansible_net_all_ipv4_addresses | reject('search', '^127\\.0\\.0\\.1$') | list }}"

    - name: Count the number of non-loopback private IP addresses
      set_fact:
        num_non_loopback_private_ips: "{{ ipv4_addresses_no_loopback | length }}"

    - name: Check if second network interface exists
      set_fact:
        second_interface_exists: "{{ num_non_loopback_private_ips > 1 }}"

    - name: Print result
      debug:
        msg: "Second network interface exists: {{ second_interface_exists }}"
