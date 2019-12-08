FROM centos:7
MAINTAINER eldorplus

ENV VAGRANT_VERSION 2.2.6
ENV ONVER 5.4

COPY opennebula.repo /etc/yum.repos.d/opennebula.repo

# Install basic packages
# Turn off "nodocs" in yum to enable documentation for developers.
RUN yum -y install epel-release \
    && yum -y update \
    && yum -y install shadow-utils openssh-server openssh-clients libselinux-python sudo wget \
    && yum -y install opennebula-server opennebula-sunstone opennebula-ruby opennebula-gate opennebula-flow \
    && sed -i -e 's/^\(tsflags=nodocs\)/#\1/' /etc/yum.conf

# Setup SSH
RUN mkdir /var/run/sshd \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
    && systemctl enable sshd.service

RUN useradd --create-home -s /bin/bash vagrant && \
    echo -n 'vagrant:vagrant' | chpasswd && \
    echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 440 /etc/sudoers.d/vagrant

RUN date > /etc/vagrant_box_build_time && \
    mkdir -pm 700 /home/vagrant/.ssh && \
    wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys && \
    chmod 0600 /home/vagrant/.ssh/authorized_keys && \
    chown -R vagrant /home/vagrant

RUN yum install -y https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm \
    && vagrant plugin install vagrant-aws vagrant-digitalocean expunge opennebula-provider \
    && vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box \
    && vagrant box add dummy https://github.com/eucher/opennebula-provider/raw/master/boxes/dummy/dummy.box \
	&&  yum clean all \
    &&  rm -rf /var/cache/yum

RUN sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers && \
    sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
