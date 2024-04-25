<pre>
To disable ICMP timestamp requests and replies on a Linux system, you can modify the kernel parameters using the sysctl command. Here's how you can disable ICMP timestamp requests and replies:

sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1
sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
The first command disables responding to ICMP echo requests (ping), and the second command disables responding to broadcast ICMP echo requests. This effectively disables ICMP timestamp requests and replies as well.

To make these changes permanent, you can add these lines to /etc/sysctl.conf:

Copy code
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_broadcasts=1
Then, run sudo sysctl -p to apply the changes without rebooting
</pre>
