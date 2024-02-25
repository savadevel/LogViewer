FROM perl:5.34

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY cpanfile /opt/app
RUN cpanm --installdeps .
