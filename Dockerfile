FROM armv7/armhf-ubuntu:14.04.3
MAINTAINER kayrus

RUN mkdir -p /opt/plex/Application
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get install -yy -q wget \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Download QNAP ARMv7-X31+ archive and extract it (https://plex.tv/downloads)
COPY PlexMediaServer_1.0.3.2461-35f0caa_arm-x31plus.qpkg /tmp/plex_media_server.tar
RUN { dd if=/tmp/plex_media_server.tar bs=22954 skip=1 status=none | tar -xzf - -C /opt/plex/Application || true; } && rm -f /tmp/plex_media_server.tar
# Add plex user
RUN useradd -r -d /var/lib/plex -s /sbin/nologin plex
# Generate the locale
RUN locale-gen en_US.UTF-8
# Fix performance issues related to 6 channels processing
RUN sed -i 's/name="audio.channels" value="6"/name="audio.channels" value="2"/' /opt/plex/Application/Resources/Profiles/Web.xml
# Start container using plex user
USER plex
VOLUME ["/var/lib/plex","/media"]
# Plex web interface default port
EXPOSE 32400/tcp
WORKDIR /opt/plex/Application
ADD start.sh /opt/plex/Application/start.sh
ENTRYPOINT /opt/plex/Application/start.sh
