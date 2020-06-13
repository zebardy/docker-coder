FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	openssl \
	net-tools \
	git \
	locales \
	sudo \
	dumb-init \
	vim \
	curl \
	wget \
	nodejs \
	&& rm -rf /var/lib/apt/lists/*
	
RUN ln -s /usr/bin/node /usr/local/lib/node

RUN locale-gen en_US.UTF-8
# We cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.
ENV LC_ALL=en_US.UTF-8 \
	SHELL=/bin/bash

RUN \
 mkdir /tmp/code-server && \
 curl -o \
	/tmp/code-server/code-server.deb -L \
    "https://github.com/cdr/code-server/releases/download/3.4.1/code-server_3.4.1_arm64.deb" && \
 dpkg -i /tmp/code-server/code-server.deb && \
 rm -rf /tmp/code-server

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder
# Create first so these directories will be owned by coder instead of root
# (workdir and mounting appear to both default to root).
RUN mkdir -p /home/coder/project \
  && mkdir -p /home/coder/.local/share/code-server

WORKDIR /home/coder/project

# This ensures we have a volume mounted even if the user forgot to do bind
# mount. So that they do not lose their data if they delete the container.
#VOLUME [ "/home/coder/project" ]

EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server", "--host", "0.0.0.0"]
