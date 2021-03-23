cat /home/vagrant/.ssh/authorized_keys | sed 's/vagrant/root/g' > /root/.ssh/authorized_keys
