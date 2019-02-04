FROM ruby:2.6

# Setup build variables
ARG RAILS_ENV=production

ENV RAILS_ENV="$RAILS_ENV" \
    LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre \
    RAILS_LOG_TO_STDOUT=yes_please \
    PATH=/fits/fits-1.0.5/:$PATH \
    BUNDLE_JOBS=2 \
    APP_PRODUCTION=/app/ \
    APP_WORKDIR="/app/hull_culture"

# Add backports to apt-get sources/
# Install libraries, dependencies, java and fits

RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    libpq-dev \
    libxml2-dev libxslt1-dev \
    nodejs \
    imagemagick \
    libreoffice \
    ghostscript \
    ffmpeg \
    ufraw \
    bzip2 unzip xz-utils \
    vim \
    git \
    # install open-jdk and ca-certs from jessie-backports
    && apt-get install -t jessie-backports -y --no-install-recommends openjdk-8-jre-headless ca-certificates-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN mkdir -p /fits/ \
    && wget -q http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip -O /fits/fits-1.0.5.zip \
    && unzip -q /fits/fits-1.0.5.zip -d /fits \
    && chmod a+x /fits/fits-1.0.5/fits.sh \
    && rm /fits/fits-1.0.5.zip

# create a folder to store derivatives
RUN mkdir -p /derivatives
RUN mkdir -p /data

WORKDIR $APP_WORKDIR

# Copy local hyrax leaf
RUN mkdir app
COPY hyrax_leaf /app/hull_culture

COPY repo_builder.sh /bin/
RUN chmod +x /bin/repo_builder.sh
RUN /bin/repo_builder.sh

COPY setup.sh /bin/
RUN chmod +x /bin/setup.sh
RUN /bin/setup.sh

RUN mkdir -p /app/hull_culture/shared/pids
RUN mkdir -p /app/hull_culture/shared/log/hull_culture

COPY docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh
