FROM perl:5.34

RUN mkdir -p /opt/app
WORKDIR /opt/app

RUN apt update  \
    && apt install -y \
    postgresql-client \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

COPY cpanfile /opt/app
RUN cpanm --notest --installdeps . \
    && rm -rf /root/.cpanm
