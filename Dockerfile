FROM buildpack-deps:jammy-curl

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends iputils-ping snmp procps lm-sensors && \
  rm -rf /var/lib/apt/lists/*

RUN set -ex && \
  mkdir ~/.gnupg; \
  echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf; \
  for key in \
  05CE15085FC09D18E99EFB22684A14CF2582E0C5 ; \
  do \
  gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key" ; \
  done

ENV TELEGRAF_VERSION 1.28.4
ENV ARCH amd64
RUN ARCH=$(dpkg --print-architecture)
RUN wget --no-verbose https://dl.influxdata.com/telegraf/releases/telegraf_${TELEGRAF_VERSION}-1_${ARCH}.deb && \
  dpkg -i telegraf_${TELEGRAF_VERSION}-1_${ARCH}.deb && \
  rm -f telegraf_${TELEGRAF_VERSION}-1_${ARCH}.deb*

COPY ./telegraf /usr/bin/telegraf

EXPOSE 8125/udp 8092/udp 8094

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]

