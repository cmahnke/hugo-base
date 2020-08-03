# syntax=docker/dockerfile:experimental

FROM alpine:3.12

LABEL maintainer="cmahnke@gmail.com"

ENV REQ_RUN="git bash sudo hugo yarn imagemagick python3 py3-pip py3-flask py3-pillow py3-click py3-jinja2 py3-magic py3-configargparse" \
    BUILD_CONTEXT=/mnt/build-context \
    NPM_DEPENDENCIES="tify svgo hugo-extended" \
    USER=hugo \
    HOME=/hugo \
    WWW_DIR=/var/www/html

RUN --mount=target=/mnt/build-context \
    apk --update upgrade && \
    apk add --no-cache $REQ_RUN && \
    pip install iiif && \
    yarn global add $NPM_DEPENDENCIES && \
    # Add user
    addgroup -Sg 1000 $USER && \
    adduser -SG $USER -u 1000 -h $HOME --shell /bin/bash $USER && \
    # Creating directories
    mkdir -p $WWW_DIR && \
    # Setup htdocs directory
    rm -rf $HOME/docs && \
    ln -s $WWW_DIR $HOME/docs && \
    # Settings for hugo user
    echo 'export PATH="$(yarn global bin):$PATH"' >> $HOME/.profile && \
    # Change permissions
    chown -R $USER $WWW_DIR $HOME && \
    # Cleanup
    apk del ${REQ_BUILD} && \
    rm -rf /var/cache/apk/*

USER $USER
