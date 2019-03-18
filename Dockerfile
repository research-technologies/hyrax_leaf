FROM ruby:2.6

# Setup build variables
ARG APP_WORKDIR
ARG RAILS_ENV
ARG DERIVATIVES_PATH
ARG UPLOADS_PATH
ARG CACHE_PATH
ARG WORKING_PATH
ARG GEM_KEY
ARG GEM_SOURCE
ARG FITS_VERSION

# Add backports to apt-get sources/
# Install libraries, dependencies and java
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

# Install fits
RUN mkdir -p /fits/ \
    && wget -q http://projects.iq.harvard.edu/files/fits/files/$FITS_VERSION.zip -O /fits/$FITS_VERSION.zip \
    && unzip -q /fits/$FITS_VERSION.zip -d /fits \
    && chmod a+x /fits/$FITS_VERSION/fits.sh \
    && rm /fits/$FITS_VERSION.zip

# Create folders to store hyrax derivatives, uploads, cache and working directory
RUN mkdir -p $DERIVATIVES_PATH
RUN mkdir -p $UPLOADS_PATH
RUN mkdir -p $CACHE_PATH
RUN mkdir -p $WORKING_PATH

# Create shared directory - required by docker
RUN mkdir -p $APP_WORKDIR/shared

WORKDIR $APP_WORKDIR

# Copy local hyrax leaf
RUN mkdir app
COPY hyrax_leaf $APP_WORKDIR

COPY repo_builder.sh /bin/
RUN chmod +x /bin/repo_builder.sh
RUN /bin/repo_builder.sh -gemkey $GEM_KEY -gemsrc $GEM_SOURCE

RUN bundle install --without development test
RUN bundle clean --force

COPY docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh

COPY docker-entrypoint-sidekiq.sh /bin/
RUN chmod +x /bin/docker-entrypoint-sidekiq.sh
