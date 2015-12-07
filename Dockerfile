#pull image
FROM pianoserver:build.5
#FROM 192.168.0.20:7000/pianoserver:latest
#FROM pianoserver:latest 

WORKDIR /usr/src/app

RUN cd /usr/src/app

RUN mv /usr/src/app /tmp/ 

COPY . /usr/src/app

RUN bundle install

