# syntax=docker/dockerfile:experimental

FROM alpine:3.12

LABEL maintainer="cmahnke@gmail.com"

ENV REQ_RUN="git bash sudo hugo yarn imagemagick python3 py3-pip py3-flask py3-pillow py3-click py3-jinja2 py3-magic py3-configargparse" \
    BUILD_CONTEXT=/mnt/build-context \
    NPM_DEPENDENCIES="svgo hugo-extended leaflet leaflet-iiif leaflet.fullscreen" \
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
    # Setup profile
    sed -i -E 's/export PATH=\/usr\/local\/sbin:\/usr\/local\/bin:\/usr\/sbin:\/usr\/bin:\/sbin:\/bin/export PATH=\/usr\/sbin:\/usr\/bin:\/sbin:\/bin:\/usr\/local\/sbin:\/usr\/local\/bin/g'  /etc/profile && \
    # Settings for hugo user
    PATH=$( . /etc/profile ; echo $PATH ) && \
    echo 'export PATH="$PATH:$(yarn global bin)"' >> $HOME/.profile && \
    echo "export PATH=$PATH" >> $HOME/.bashrc && \
    echo 'export PATH="$PATH:$(yarn global bin)"' >> $HOME/.bashrc && \
    # Change permissions
    chown -R $USER $WWW_DIR $HOME && \
    # Cleanup
    apk del ${REQ_BUILD} && \
    rm -rf /var/cache/apk/*

USER $USER
