FROM casperlabs/buildenv:latest AS builder
LABEL MAINTAINER="CasperLabs, LLC. <info@casperlabs.io>"

USER root
RUN mkdir -p /root/casperlabs-node/
WORKDIR /root/casperlabs-node/
ADD . /root/casperlabs-node/
RUN make setup-rs
RUN make build-system-contracts -j
RUN cargo build --release

# attempt to slice the layers
FROM rust:1.39

RUN mkdir -p /root/casperlabs-node/
WORKDIR /root/casperlabs-node
COPY --from=builder /root/casperlabs-node/target /root/casperlabs-node/target
# COPY resources /root/casperlabs-node/resources
RUN for exec_bin in `find /root/casperlabs-node/target/release -maxdepth 1 -executable -type f`; do mv $exec_bin /usr/bin/; done
RUN rm -rf /root/casperlabs-node/target/release
EXPOSE 34553
EXPOSE 40404
# ARG BIND_PORT
# ENV BIND_PORT=${BIND_PORT}
# EXPOSE ${BIND_PORT}
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
