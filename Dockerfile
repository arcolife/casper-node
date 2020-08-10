FROM casperlabs/buildenv:latest AS builder
LABEL MAINTAINER="CasperLabs, LLC. <info@casperlabs.io>"

USER root

RUN mkdir -p /root/casperlabs-node/
WORKDIR /root/casperlabs-node/
ADD . /root/casperlabs-node/

RUN make setup-rs
RUN make build-system-contracts -j
RUN cargo build --release

ARG BIND_PORT
ENV BIND_PORT=${BIND_PORT}

EXPOSE ${BIND_PORT}
EXPOSE 34553

# attempt to slice the layers
FROM rust:1.39

RUN mkdir -p /root/casperlabs-node/
WORKDIR /root/casperlabs-node

COPY --from=builder /root/casperlabs-node/target /root/casperlabs-node/target
COPY --from=builder /root/casperlabs-node/resources /root/casperlabs-node/resources
RUN for exec_bin in `find /root/casperlabs-node/target/release -maxdepth 1 -executable -type f`; do mv $exec_bin /usr/bin/; done
RUN rm -rf /root/casperlabs-node/target/release

ENTRYPOINT RUST_BACKTRACE=full RUST_LOG=debug casperlabs-node
CMD validator -C=validator_net.bind_port=${BIND_PORT} -C=validator_net.root_addr=${ROOT_ADDR}

#  RUST_BACKTRACE=full RUST_LOG=debug casperlabs-node validator -c=/root/casperlabs-node/resources/local/config.toml
