FROM alpine:3.20.2 AS build

WORKDIR /build

RUN apk add --update alpine-sdk curl jq xz

RUN curl https://api.github.com/repos/troglobit/redir/releases/latest | jq -r '.tag_name | ltrimstr("v")' > vers && \
    curl -OLJ https://github.com/troglobit/redir/releases/download/v$(cat vers)/redir-$(cat vers).tar.xz && \
    tar --no-same-owner --no-same-permissions -xvf redir-$(cat vers).tar.xz && \
    cd redir-$(cat vers) && \
    ./configure --prefix=/usr && \
    make CFLAGS='-static -g -O2' -j$(nproc) && \
    strip redir && mv redir /build

FROM scratch
LABEL org.opencontainers.image.description "A 'FROM scratch' container with redir"

COPY --from=build /build/redir /redir

ENTRYPOINT ["/redir"]
# CMD /redir
