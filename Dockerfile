FROM linuxserver/baseimage

MAINTAINER Sparklyballs <sparkylballs@linuxserver.io>

ENV APTLIST="bzip2 libcurl4-openssl-dev mono-complete wget"

# install packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list && \
apt-get update -q && \
apt-get install $APTLIST -qy && \

# clean up
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# install Jackett
RUN jack_tag=$(wget -q https://github.com/Jackett/Jackett/releases/latest  -O - | grep -E \/tag\/ | awk -F "[><]" '{print $3}') && \
curl -o /tmp/jacket.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jack_tag/Jackett.Binaries.Mono.tar.gz && \
mkdir -p /app/Jackett && \
tar xvf /tmp/jacket.tar.gz -C /app/Jackett --strip-components=1 && \
rm -rf /tmp/*

# Adding Custom files
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run /etc/my_init.d/*.sh && \

# give abc a home folder
usermod -d /app abc

# ports and volumes
VOLUME /config /downloads
EXPOSE 9117

