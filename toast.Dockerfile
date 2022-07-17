FROM debian:bullseye-20220622@sha256:859ea45db307402ee024b153c7a63ad4888eb4751921abbef68679fc73c4c739
LABEL  org.opencontainers.image.authors="Thaddeus Ryker <thad@edgerunner.org>"
LABEL version="2.7.0 r39"
LABEL description="This is a version 2.7.0 ToastStunt server packaged with the latest Toast core"
LABEL core="Toast"

# build command: 
# docker build -f toast.Dockerfile -t wiredwizard/toaststunt:2.7.0 .

# Make directories, copy binary & scripts
RUN mkdir -p /home/moo/
RUN mkdir -p /home/moo-init
COPY ./v2.7.0/moo.debian /usr/local/bin/moo
COPY ./startup.sh /usr/local/bin/startup
COPY ./restart.sh /usr/local/bin/restart
COPY ./buildParameters.sh /usr/local/bin/buildParameters

# Download the latest toast core
ADD https://raw.githubusercontent.com/lisdude/toastcore/master/toastcore.db /home/moo-init/moo.db
RUN cp /home/moo-init/moo.db /home/moo/moo.db

# Install the various dependent packages
RUN apt-get update
RUN apt-get install -yq build-essential gperf libsqlite3-dev libaspell-dev libpcre3-dev nettle-dev libcurl4-openssl-dev libargon2-dev git

# Install Tini for us to use to insure a graceful shutdown of the moo
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

# Install gosu
RUN set -eux; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true

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
