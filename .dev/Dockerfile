FROM ruby:3.2

RUN apt-get update
RUN apt-get -y install apt-utils ncompress vim

RUN useradd -u 1000 dev
USER dev
WORKDIR /home/dev

CMD [ "bash" ]
