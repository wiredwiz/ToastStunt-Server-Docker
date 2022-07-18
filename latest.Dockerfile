FROM ubuntu:18.04 as build

# Make directories, copy binary & scripts
RUN mkdir -p /home/moo
RUN mkdir -p /home/moo-init
RUN mkdir -p /home/moorepo
RUN mkdir -p /home/repobackup

# Copy our scripts to execute the moo
COPY ./startup.sh /usr/local/bin/startup
COPY ./restart.latest.sh /usr/local/bin/restart
COPY ./buildParameters.sh /usr/local/bin/buildParameters

# Download the latest toast core
ADD https://raw.githubusercontent.com/lisdude/toastcore/master/toastcore.db /home/moo-init/moo.db
RUN cp /home/moo-init/moo.db /home/moo/moo.db

# Install the various dependent packages
RUN apt-get update && \
    apt-get install -y \
      bison \
      build-essential \      
      cmake \
      git \
      gperf \    
      libargon2-0-dev \
      libaspell-dev \
      libcurl4-openssl-dev \
      libpcre3-dev \
      libsqlite3-dev \
      libssl-dev \
      nettle-dev

# Pull the latest repo of the ToastStunt server source
ADD https://api.github.com/repos/lisdude/toaststunt/compare/master...HEAD /dev/null
RUN git clone https://github.com/lisdude/toaststunt /home/moorepo

# Clone the repo for fresh setups with a mapped volume and build the server
RUN cp -R /home/moorepo/* /home/repobackup

# Build the server and copy our binary to the bin directory
RUN mkdir /home/moorepo/build
WORKDIR /home/moorepo/build
RUN cmake ../
RUN make -j2
RUN cp moo /usr/local/bin/moo

# Fix permissions on our various binaries and scripts just in case it is needed (but generally it will not be)
RUN chmod +x /usr/local/bin/moo && \
    chmod 777 /usr/local/bin/moo && \
    chmod +x /usr/local/bin/buildParameters && \
    chmod 777 /usr/local/bin/buildParameters && \
    chmod +x /usr/local/bin/restart && \
    chmod 777 /usr/local/bin/restart

FROM ubuntu:18.04
LABEL  org.opencontainers.image.authors="Thaddeus Ryker <thad@edgerunner.org>"
LABEL version="latest"
LABEL description="This is the latest version of ToastStunt server packaged with the latest Toast core"
LABEL core="Toast"

# build command: 
# docker build -f latest.Dockerfile -t wiredwizard/toaststunt:latest .

# Copy all our various files and directories now that all has been built
COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /home/* /home/

# Install the various dependent packages
RUN apt-get update && \
    apt-get install -y \
      bison \
      build-essential \      
      cmake \
      git \
      gperf \    
      libargon2-0-dev \
      libaspell-dev \
      libcurl4-openssl-dev \
      libpcre3-dev \
      libsqlite3-dev \
      libssl-dev \
      nettle-dev

# Install Tini for us to use to insure a graceful shutdown of the moo
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Install gosu to run at reduced permissions
RUN set -eux; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true

ENV TZ="America/New_York"
ENV PORT="7777"
# I added 7778 as the default exposed TLS port
EXPOSE ${PORT}/tcp 7778/tcp 

# Change our stop signal so that we can ensure a safe shutdown of the moo when the container stops
STOPSIGNAL SIGINT

# Create our moo user and group
RUN \
  groupadd -o --gid 10001 moo && \
  useradd -u 10000 -g moo -d /home/moo moo && \
  usermod -G users moo && \
  chown -R moo:moo /home/*

# Set directory to our moo and execute the restart script via Tini for clean process control
WORKDIR /home/moo
ENTRYPOINT ["/tini", "-g", "-v", "--", "startup", "moo"]
