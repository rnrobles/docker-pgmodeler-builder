FROM rnrobles87/pgmodeler-builder-postgres:latest
LABEL com.handcraftedbits.image.authors="opensource@handcraftedbits.com"
LABEL net.baotran.image.authors="contact@baotran.net"

COPY data /

WORKDIR /opt
ENTRYPOINT ["/bin/bash", "src/script/build.sh"]

