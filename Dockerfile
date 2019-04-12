FROM ruby:2.6

# Setup build variables
ARG APP_WORKDIR
ARG RAILS_ENV
ARG DERIVATIVES_PATH
ARG BRANDING_PATH
ARG UPLOADS_PATH
ARG CACHE_PATH
ARG WORKING_PATH
ARG GEM_KEY
ARG GEM_SOURCE
ARG FITS_VERSION

# Install libraries, dependencies and java
RUN apt-get update -qq \
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
    openjdk-8-jre-headless

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
RUN mkdir -p $BRANDING_PATH
RUN mkdir -p $APP_WORKDIR/log

# Create shared directory - required by docker
RUN mkdir -p $APP_WORKDIR/shared/state

WORKDIR $APP_WORKDIR

# Copy local hyrax leaf
RUN mkdir app
COPY . $APP_WORKDIR

# Install the gem
COPY repo_builder.sh /bin/
RUN chmod +x /bin/repo_builder.sh
RUN /bin/repo_builder.sh

RUN if [ "$RAILS_ENV" = "production" ]; then bundle install --without development test; else bundle install; fi

# Run the gem installer
RUN if [ -n "${GEM_KEY+set}" ]; then bundle exec rails g $GEM_KEY:install ; fi

COPY docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh

COPY docker-entrypoint-web.sh /bin/
RUN chmod +x /bin/docker-entrypoint-web.sh

COPY docker-entrypoint-worker.sh /bin/
RUN chmod +x /bin/docker-entrypoint-worker.sh