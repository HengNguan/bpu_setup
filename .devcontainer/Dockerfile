FROM registry.d-robotics.cc/deliver/ai_toolchain_ubuntu_20_x5_cpu:v1.2.8

# Set default shell to bash
ENV SHELL=/bin/bash

# Configure SSH to use a writable known_hosts file, since /root/.ssh is mounted as read-only
RUN echo "    UserKnownHostsFile ~/.ssh_known_hosts ~/.ssh/known_hosts ~/.ssh/known_hosts2" >> /etc/ssh/ssh_config

