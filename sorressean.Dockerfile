FROM debian:bullseye-20220622@sha256:859ea45db307402ee024b153c7a63ad4888eb4751921abbef68679fc73c4c739
LABEL  org.opencontainers.image.authors="Thaddeus Ryker <thad@edgerunner.org>"
LABEL version="latest"
LABEL description="This is the latest version of Sorressean's fork of ToastStunt server packaged with the latest Toast core"
LABEL core="Toast"

# build command: 
# docker build -f sorressean.Dockerfile -t wiredwizard/toaststunt:sorressean .

# Make directories, copy binary & scripts
RUN mkdir -p /home/moo/
RUN mkdir -p /home/moo-init
RUN mkdir -p /home/moorepo
RUN mkdir -p /home/repobackup
COPY ./startup.sh /usr/local/bin/startup
COPY ./restart.latest.sh /usr/local/bin/restart
COPY ./buildParameters.sh /usr/local/bin/buildParameters

# Download the latest toast core
ADD https://raw.githubusercontent.com/lisdude/toastcore/master/toastcore.db /home/moo-init/moo.db
RUN cp /home/moo-init/moo.db /home/moo/moo.db

# Install the various dependent packages
RUN apt-get update
RUN apt-get install -y build-essential bison gperf cmake libsqlite3-dev libaspell-dev libpcre3-dev nettle-dev libcurl4-openssl-dev libargon2-dev libssl-dev g++ libboost-all-dev

# Install Tini for us to use to insure a graceful shutdown of the moo
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://raw.githubusercontent.com/lisdude/toastcore/master/toastcore.db Toast/moo.db

# Install git, pull the latest repo of the ToastStunt server source and build it, then copy the binary to our moo directory
RUN apt-get -y install git
ADD https://api.github.com/repos/sorressean/toaststunt/compare/master...HEAD /dev/null
RUN git clone https://github.com/sorressean/toaststunt /home/moorepo

# Install gosu
RUN set -eux; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true

# Clone the repo for fresh setups with a mapped volume and build the server
RUN cp -R /home/moorepo/* /home/repobackup
RUN mkdir /home/moorepo/build
WORKDIR /home/moorepo/build
RUN cmake ../
RUN make -j2
RUN cp moo /usr/local/bin/moo

# Fix permissions on our various binaries and scripts just in case it is needed (but generally it will not be)
RUN chmod +x /tini
RUN chmod +x /usr/local/bin/moo
RUN chmod 777 /usr/local/bin/moo
RUN chmod +x /usr/local/bin/buildParameters
RUN chmod 777 /usr/local/bin/buildParameters
RUN chmod +x /usr/local/bin/restart
RUN chmod 777 /usr/local/bin/restart

ENV TZ="America/New_York"
ENV PORT="7777"
EXPOSE ${PORT}/tcp 7778/tcp 
# I added 7778 as the default exposed TLS port

# Change our stop signal so that we can ensure a safe shutdown of the moo when the container stops
STOPSIGNAL SIGINT

# Create our moo user and group
RUN \
  groupadd -o --gid 10001 moo && \
  useradd -u 10000 -g moo -d /home/moo moo && \
  usermod -G users moo

# Give moo user ownership of moo related assets
RUN chown -R moo:moo /home/*

# Set directory to our moo and execute the restart script via Tini for clean process control
WORKDIR /home/moo
ENTRYPOINT ["/tini", "-g", "-v", "--", "startup", "moo"]
