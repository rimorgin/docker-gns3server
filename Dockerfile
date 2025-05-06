FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install essential packages and set up locale
RUN apt-get update && apt-get install -y \
  software-properties-common \
  locales \
  && locale-gen en_US.UTF-8

# Add GNS3 PPA and i386 Architecture support
RUN add-apt-repository -y ppa:gns3/ppa \
  && dpkg --add-architecture i386 \
  && apt-get update

# Install core dependencies
RUN apt-get install -y \
  python3-pip \
  python3-dev \
  qemu-kvm \
  util-linux \
  bridge-utils \
  curl \
  nano \
  tigervnc-standalone-server \
  gns3-server \
  gns3-iou

# Install Docker (after system deps are in place)
RUN curl -sSL https://get.docker.com/ | sh

# Clean up: remove PPA, remove i386 arch, remove setup packages
RUN add-apt-repository --remove ppa:gns3/ppa && \
  apt-get clean && \
  apt-get purge -y software-properties-common && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*


# Copy config and startup scripts
COPY ./config.ini /config.ini
COPY ./start.sh /start.sh
COPY ./requirements.txt /tmp/requirements.txt

RUN pip install --no-cache-dir -r /tmp/requirements.txt 

# Ensure the startup script is executable
RUN chmod +x /start.sh 

WORKDIR /data
VOLUME /data

CMD ["/start.sh"]
