FROM ruby:3.2.2

RUN apt-get update && apt-get -y install apt-utils
RUN apt-get update && apt-get -y install ncompress
RUN apt-get update && apt-get -y install vim
RUN apt-get update && apt-get -y install openssh-server
RUN apt-get update && apt-get -y install cron
RUN apt-get update && apt-get -y install tmux
RUN apt-get update && apt-get -y install golang
RUN git clone --branch fork https://github.com/anicolao/glow.git && for i in $(grep replace glow/go.mod | awk '{print $NF}'); do git clone --branch fork https://github.com/anicolao/${i##*/}.git; done && cd glow && go get && go build && cp ./glow /usr/local/bin
RUN apt-get update && apt-get -y install docker.io

RUN useradd -u 1000 dev -s /bin/bash

ENTRYPOINT if [ -S /var/run/docker.sock ]; then chown dev:dev /var/run/docker.sock /home/dev; fi && mkdir -p /root/.ssh && cp /home/dev/.ssh/authorized_keys /root/.ssh/authorized_keys && mkdir -p /run/sshd && /usr/sbin/cron && /usr/sbin/sshd -D
