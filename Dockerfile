FROM centos:7
MAINTAINER eldorplus

ENV VAGRANT_VERSION 2.2.6

RUN yum install -y https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm && \
	vagrant plugin install vagrant-aws vagrant-digitalocean expunge opennebula-provider && \
	vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box && \
	vagrant box add dummy https://github.com/eucher/opennebula-provider/raw/master/boxes/dummy/dummy.box && \
