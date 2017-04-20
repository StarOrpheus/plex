FROM armv7/armhf-ubuntu:16.04
MAINTAINER kayrus

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && apt-get install -yy -q wget \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate the locale
RUN locale-gen en_US.UTF-8

# Add plex user
RUN useradd -r -d /var/lib/plex -s /sbin/nologin plex
VOLUME ["/var/lib/plex","/media"]
RUN install -d -o plex -g plex /opt/plex/Application
# Start container using plex user
USER plex

# Plex web interface default port; DLNA ports added
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp
WORKDIR /opt/plex/Application

ENV PLEX_VERSION 1.2.7.2987-1bef33a
RUN wget https://downloads.plex.tv/plex-media-server/${PLEX_VERSION}/plexmediaserver-ros6-binaries-annapurna_${PLEX_VERSION}_armel.deb -O /tmp/plex_media_server.deb
RUN dpkg-deb --fsys-tarfile /tmp/plex_media_server.deb | tar -xf - -C /opt/plex/Application --strip-components=4 ./apps/plexmediaserver-annapurna/Binaries && rm -f /tmp/plex_media_server.deb

ADD start.sh /opt/plex/Application/start.sh

# Fix performance issues related to 6 channels processing
RUN sed -i 's/name="audio.channels" value="6"/name="audio.channels" value="2"/' /opt/plex/Application/Resources/Profiles/Web.xml

ENTRYPOINT /opt/plex/Application/start.sh
