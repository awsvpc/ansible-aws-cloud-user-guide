---
- name: Find device name for second interface on RHEL host
  hosts: your_host
  gather_facts: yes

  tasks:
    - name: Gather facts about the network interfaces
      setup:
        filter: "ansible_interfaces"

    - name: Exclude loopback interface
      set_fact:
        non_loopback_interfaces: "{{ ansible_interfaces | reject('match', '^lo$') | list }}"

    - name: Find device name for second interface
      set_fact:
        second_interface_device: "{{ non_loopback_interfaces.1 if non_loopback_interfaces | length > 1 else 'None' }}"

    - name: Print device name for second interface
      debug:
        msg: "Device name for second interface: {{ second_interface_device }}"
