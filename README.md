This repository contains a Vagrant file and scripts to create a K8s Cluster with 1 master node and 1 worker node.
The scripts are slightly modified from those provided in the https://github.com/killer-sh/cks-course-environment

The modifications are specific to setting up the cluster using Vagrant and might be specific to my development setup on a Mac OSX laptop. Noteably, the bridge network.

Additionally, I've added a step in `scripts/install_master.sh` to output the token join command to a file so that it can be run automatically during the installation of the worker node.


You can learn more about Vagrant [here](https://learn.hashicorp.com/collections/vagrant/getting-started)

You can start the cluster using `vagrant up` and refresh the cluster using `vagrant halt && vagrant destroy -f && vagrant up`

