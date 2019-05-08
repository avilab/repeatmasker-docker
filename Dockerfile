FROM debian:stretch

COPY RepBaseRepeatMaskerEdition-20181026.tar.gz /tmp
COPY test/seqs/small-1.fa /tmp
COPY test/seqs/small-2.fa /tmp

ARG RM_VERSION=4.0.9.p2
ARG RMB_VERSION=2.9.0
ARG TRF_VERSION=409
ARG REPBASE_VER=20181026

RUN apt-get update \
        && apt-get install -y --no-install-recommends wget build-essential locales

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
        && locale-gen en_US.utf8 \
        && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN wget -O - http://cpanmin.us | perl - --self-upgrade \
        && cpanm Text::Soundex

RUN cd /tmp \
        && wget -nv http://www.repeatmasker.org/rmblast-${RMB_VERSION}+-x64-linux.tar.gz \
        && cd /usr/local \
        && tar zxvf /tmp/rmblast-${RMB_VERSION}+-x64-linux.tar.gz \
        && ln -s /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/libpcre.so.0

RUN cd /tmp \
        && wget -nv http://tandem.bu.edu/trf/downloads/trf${TRF_VERSION}.linux64 \
        && cp trf${TRF_VERSION}.linux64 /usr/local/bin/ \
        && mv /usr/local/bin/trf${TRF_VERSION}.linux64 /usr/local/bin/trf \
        && chmod +x /usr/local/bin/trf

RUN wget -nv http://www.repeatmasker.org/RepeatMasker-open-$(echo $RM_VERSION | sed -e 's/\./\-/g').tar.gz \
        && cp RepeatMasker-open-$(echo $RM_VERSION | sed -e 's/\./\-/g').tar.gz /usr/local/ \
        && cd /usr/local/ \
        && gunzip RepeatMasker-open-$(echo $RM_VERSION | sed -e 's/\./\-/g').tar.gz \
        && tar xvf RepeatMasker-open-$(echo $RM_VERSION | sed -e 's/\./\-/g').tar \
        && cd / \
        && rm RepeatMasker-open-$(echo $RM_VERSION | sed -e 's/\./\-/g').tar

RUN ln -s /usr/local/RepeatMasker/RepeatMasker /usr/local/bin/RepeatMasker

RUN cp /tmp/RepBaseRepeatMaskerEdition-${REPBASE_VER}.tar.gz /usr/local/RepeatMasker \
        && cd /usr/local/RepeatMasker \
        && tar zxf RepBaseRepeatMaskerEdition-${REPBASE_VER}.tar.gz \
        && rm RepBaseRepeatMaskerEdition-${REPBASE_VER}.tar.gz

RUN cd /usr/local/RepeatMasker \
        && perl ./configure --trfbin=/usr/local/bin/trf --rmblastbin=/usr/local/rmblast-${RMB_VERSION}/
  
RUN /usr/local/bin/RepeatMasker /tmp/small-1.fa
RUN /usr/local/bin/RepeatMasker /tmp/small-2.fa

RUN cd / \
        && rm -rf /tmp/* \
        && apt-get autoremove -y \
        && apt-get autoclean -y \
        && rm -rf /var/lib/apt/lists/* 

CMD ["/usr/local/bin/RepeatMasker"]