# Errbot - the pluggable chatbot

FROM python:3.8-slim

MAINTAINER Msg4real

ENV ERR_USER=errbot
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set default locale for the environment
#LC_ALL=C.UTF-8
#LANG=en_US.UTF-8
#LANGUAGE=en_US.UTF-8

# Add err user and group
RUN groupadd -r errbot \
    && useradd -r \
       -g errbot \
       -d /srv \
       -s /bin/bash \
       errbot
# Install packages and perform cleanup
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
         git \
         qalc \
         locales \
         dnsutils \
         libssl-dev \
         build-essential \
         python3-dnspython \
         python3-dev \
         python3-openssl \
         python3-pip \
         python3-cffi \
         python3-pyasn1 \
         python3-geoip \
         python3-lxml \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8 \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen \
    && pip3 install virtualenv \
    && pip3 install -U setuptools \
	&& pip install errbot \
	&& rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/archives

RUN mkdir /app

COPY requirements.txt /app/requirements.txt

RUN virtualenv /app/venv
RUN . /app/venv/bin/activate; pip install --no-cache-dir -r /app/requirements.txt

COPY config.py /app/config.py
COPY run.sh /app/venv/bin/run.sh

RUN mkdir /srv/data /srv/plugins /srv/errbackends && chown -R $ERR_USER: /srv /app

RUN cd /srv/errbackends && git clone https://github.com/errbotio/err-backend-slackv3 && pip install -r /srv/errbackends/err-backend-slackv3/requirements.txt



EXPOSE 3141 3142
VOLUME ["/srv"]

CMD ["/app/venv/bin/run.sh"]
