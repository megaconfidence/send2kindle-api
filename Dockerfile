FROM rust:1.67 as build

# create a new empty shell project
RUN USER=root cargo new --bin send2kindle-api
WORKDIR /send2kindle-api

# copy over manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# cache dependencies
RUN cargo install htop
RUN cargo build --release
RUN rm src/*.rs

# copy source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/send2kindle-api*
RUN cargo build --release

# final base
FROM debian:buster-slim

# copy the build artifact from build stage
COPY --from=build /send2kindle-api/target/release/send2kindle-api .

# set the startup command
ENV PORT 3456
EXPOSE 3456
CMD ["./send2kindle-api"]