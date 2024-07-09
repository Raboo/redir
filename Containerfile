FROM alpine:3.20.1 AS build

RUN apk add --update alpine-sdk curl jq xz && \
    curl https://api.github.com/repos/troglobit/redir/releases/latest | jq -r '.tag_name | ltrimstr("v")' > vers && \
    curl -OLJ https://github.com/troglobit/redir/releases/download/v$(cat vers)/redir-$(cat vers).tar.xz && \
    tar xvf redir-$(cat vers).tar.xz && \
    cd redir-$(cat vers) && \
    ./configure --prefix=/usr && \
    make CFLAGS='-static -g -O2' -j$(nproc) && \
    strip redir && mv redir /

FROM scratch

COPY --from=build /redir /redir

ENTRYPOINT ["/redir"]
# CMD /redir
