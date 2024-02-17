FROM osgeo/gdal:ubuntu-full-3.6.3
MAINTAINER joeakeem "info@singletrail-map.eu"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean

RUN apt-get update -y && apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntugis/ppa

RUN apt-get update -y && apt-get install -y \
        postgis \
        make \
        curl \
        unzip \
        git \
        cmake \
        g++ \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libexpat1-dev zlib1g-dev \
        libbz2-dev \
        libpq-dev \
        libproj-dev \
        lua5.2 \
        liblua5.2-dev \
        build-essential \
        libsqlite3-dev \
        zlib1g-dev \
        wget \
        python3-gdal \
        gdal-bin \
		parallel

# build & install tippecanoe
WORKDIR /tmp
RUN git clone https://github.com/mapbox/tippecanoe.git
WORKDIR /tmp/tippecanoe
RUN make
RUN make install

# cleanup
RUN rm -rf /tmp/tippecanoe

WORKDIR /tmp
ENV GO_PMTILES=go-pmtiles_1.16.1_Linux_x86_64.tar.gz
RUN wget https://github.com/protomaps/go-pmtiles/releases/download/v1.16.1/go-pmtiles_1.16.1_Linux_x86_64.tar.gz -O go-pmtiles.tgz \
    && tar -xzf go-pmtiles.tgz \
    && cp /tmp/pmtiles /usr/local \
    && rm -f /tmp/go-pmtiles.tgz /tmp/pmtiles

# Add the Makefile & sql scripts
COPY Makefile /contours/Makefile
COPY download.sh /contours/download.sh
COPY sql /sql

WORKDIR /contours

ENTRYPOINT ["/bin/bash", "-c", "sleep 10s && export OGR_GEOJSON_MAX_OBJ_SIZE=100000MB && /usr/bin/make"]
CMD ["all"]