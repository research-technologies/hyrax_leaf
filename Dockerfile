# Use an multi-stage build to setup ssh
#   copy the key and config to enable git clone
#   @todo Docker 18.9 provides an improved mechanism: https://docs.docker.com/develop/develop-images/build_enhancements/#using-ssh-to-access-private-data-in-builds
FROM ruby:2.6 as intermediate

RUN apt-get update
RUN apt-get install -y git

ARG SSH_PRIVATE_KEY=
ARG GEM_KEY
ARG GEM_SOURCE
ARG APP_WORKDIR

RUN mkdir /root/.ssh/

ADD docker/ssh_config /root/.ssh/config
RUN chmod 400 /root/.ssh/config 

ADD ${SSH_PRIVATE_KEY} /root/.ssh/id_rsa

# Copy local hyrax leaf
RUN mkdir $APP_WORKDIR
COPY . $APP_WORKDIR

WORKDIR $APP_WORKDIR

# Add the gem
COPY docker/repo_builder.sh /bin/
RUN chmod +x /bin/repo_builder.sh
RUN /bin/repo_builder.sh

FROM ruby:2.6

# Setup build variables
ARG APP_WORKDIR
ARG RAILS_ENV
ARG DERIVATIVES_PATH
ARG BRANDING_PATH
ARG UPLOADS_PATH
ARG CACHE_PATH
ARG WORKING_PATH
ARG FITS_VERSION
ARG GEM_KEY

# Install libraries, dependencies and java
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    apache2 \
    bzip2 \ 
    certbot \
    ffmpeg \
    ghostscript \
    git \
    imagemagick \
    libpq-dev \
    libreoffice \
    libxml2-dev libxslt1-dev \
    net-tools \
    nodejs \
    openjdk-11-jre-headless \
    python-certbot-apache \
    tree \
    ufraw \
    unzip \
    vim \
    xz-utils

## install apache, certs and modules for proxy##
COPY docker/ssl.conf /etc/apache2/conf-available/
RUN a2enconf ssl

COPY docker/hyrax.conf /etc/apache2/sites-available/
COPY docker/hyrax_ssl.conf /etc/apache2/sites-available/

#in case we are generating self-signed certs for a docker only instance
COPY docker/gen_cert.sh /bin/
RUN chmod +x /bin/gen_cert.sh

# For later use by certbot/cron
COPY docker/renew_cert /var/tmp/
RUN chmod +x /var/tmp/renew_cert

# SSL will be started after we are up and certbot has done its thang (so just the 80 vhost for now)
RUN a2ensite hyrax
# Not this one though
RUN a2dissite 000-default

RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_balancer
RUN a2enmod proxy_http
RUN a2enmod proxy_wstunnel

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

# Copy from intermdiate
COPY --from=intermediate $APP_WORKDIR $APP_WORKDIR

# Create shared directory - required by docker
RUN mkdir -p $APP_WORKDIR/shared/state

WORKDIR $APP_WORKDIR

RUN if [ "$RAILS_ENV" = "production" ]; then bundle install --without development test --quiet ; else bundle install --quiet; fi

# Run the gem installer
RUN if [ -n "${GEM_KEY+set}" ]; then bundle exec rails g $GEM_KEY:install ; fi

# Add the entrypoint files
COPY docker/docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh

COPY docker/docker-entrypoint-web.sh /bin/
RUN chmod +x /bin/docker-entrypoint-web.sh

COPY docker/docker-entrypoint-worker.sh /bin/
RUN chmod +x /bin/docker-entrypoint-worker.sh
