FROM ruby:3.2.2

RUN apt-get update && apt-get -y install apt-utils ncompress vim openssh-server cron

RUN useradd -u 1000 dev -s /bin/bash
#USER dev
WORKDIR /home/dev

#ENTRYPOINT service ssh restart && if [ -S /var/run/docker.sock ]; then chown dev:dev /var/run/docker.sock; fi && mkdir -p /root/.ssh && cp /home/dev/.ssh/authorized_keys /root/.ssh/authorized_keys && bash -i
ENTRYPOINT if [ -S /var/run/docker.sock ]; then chown dev:dev /var/run/docker.sock; fi && mkdir -p /root/.ssh && cp /home/dev/.ssh/authorized_keys /root/.ssh/authorized_keys && mkdir -p /run/sshd && /usr/sbin/cron && /usr/sbin/sshd -D
