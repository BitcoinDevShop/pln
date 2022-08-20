FROM rust:1-buster AS builder
WORKDIR /workspace
COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY entity/Cargo.toml  ./entity/
COPY migration/Cargo.toml  ./migration/
COPY plncore/Cargo.toml  ./plncore/
RUN mkdir -p ./src && echo 'fn main() { println!("Dummy!"); }' > ./src/main.rs && \
    mkdir -p ./entity/src && echo 'fn main() { println!("Dummy!"); }' > ./entity/src/lib.rs && \
    mkdir -p ./migration/src && echo 'fn main() { println!("Dummy!"); }' > ./migration/src/lib.rs && \
    mkdir -p ./plncore/src && echo 'fn main() { println!("Dummy!"); }' > ./plncore/src/lib.rs && \
    cargo build --release && \
    rm -rf target src entity migration plncore
COPY proto ./proto
COPY migration ./migration
COPY entity ./entity
COPY build.rs ./
COPY plncore ./plncore
COPY src ./src
RUN cargo build --release

FROM debian:buster-slim AS final
WORKDIR /workspace
COPY --from=builder /workspace/target/release/pln /usr/local/bin/pln
ENTRYPOINT [ "pln" ]
