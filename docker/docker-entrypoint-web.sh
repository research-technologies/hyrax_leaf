#!/bin/bash

# Run the base entrypoint
bash /bin/docker-entrypoint.sh

if [ ! -d $DERIVATIVES_PATH ]; then
  mkdir -p $DERIVATIVES_PATH $UPLOADS_PATH $CACHE_PATH $WORKING_PATH $SOURCE_BRANDING_PATH
  
  # Symlink the branding directory
  ln -s $SOURCE_BRANDING_PATH $APP_WORKDIR/$BRANDING_PATH
fi

if [ ! -d $LOGS_PATH ]; then
  # Persist some logs (assuming that LOGS_PATH is somewhere on a PV)
  mkdir -p $LOGS_PATH/apache2
  mkdir -p $LOGS_PATH/hyrax
  mkdir -p /etc/cron.daily
  # trim_weblogs will trim away logs older than 21 days
  mv /var/tmp/trim_weblogs /etc/cron.daily/trim_weblogs
fi


# Run the initialization tasks on first run

FLAG=""
# On first deploy set the --initial flag
# This is global and persists across images
#   ie. we don't want to re-initialize on a new image
if [ ! -f /data/shared/state/.hyrax_initialized ]; then
    echo "Setting the initial flag"
    FLAG="initialize"
    mkdir /data/shared/state
    touch /data/shared/state/.hyrax_initialized
fi

# Solr / Fedora need to be running for initial setup only
if [ "$FLAG" == "initialize" ]; then 

  # wait for Solr and Fedora to come up
  sleep 15s
  
  # check that Solr is running
  SOLR=$(curl --silent --connect-timeout 45 "http://${SOLR_HOST:-solr}:${SOLR_PORT:-8983}/solr/" | grep "Apache SOLR")
  if [ -n "$SOLR" ] ; then
      echo "Solr is running..."
  else
      echo "ERROR: Solr is not running"
      # exit 1
  fi
  
  # check that Fedora is running
  FEDORA=$(curl --silent --connect-timeout 45 "http://${FEDORA_HOST:-fcrepo}:${FEDORA_PORT:-8080}/fcrepo/" | grep "Fedora Commons Repository")
  if [ -n "$FEDORA" ] ; then
      echo "Fedora is running..."
  else
      echo "ERROR: Fedora is not running"
      # exit 1
  fi

  if [ -n "${GEM_KEY+set}" ]; then
    echo "Running the installer"
    bundle exec rails g $GEM_KEY:initialize
    bundle exec rake assets:clean assets:precompile
    # setup the admin user
    bundle exec rake leaf_addons:create_admin_user[$( echo $ADMIN_USER),$( echo $ADMIN_PASSWORD)]
  # If the GEM_KEY isn't set on the initial run; run the setup tasks (I'm not sure this ever really happens)
  elif [ ! -n "${GEM_KEY+set}" ]; then
    echo "Running the initialization tasks"
    echo "Create the db and run any pending migrations"
    bundle exec rake leaf_addons:db:setup_and_migrate
    bundle exec rake hyrax:default_admin_set:create
    bundle exec rake hyrax:workflow:load
    bundle exec rake hyrax:default_collection_types:create
    bundle exec rake assets:clean assets:precompile
    # setup the admin user
    bundle exec rake leaf_addons:create_admin_user[$( echo $ADMIN_USER),$( echo $ADMIN_PASSWORD)]

  fi
fi

##########
# apache #
##########

# put server name in apache conf
sed -i "s/#SERVER_NAME#/$SERVER_NAME/g" /etc/apache2/sites-available/hyrax.conf
sed -i "s/#SERVER_NAME#/$SERVER_NAME/g" /etc/apache2/sites-available/hyrax_ssl.conf

# For now $USE_SS_CERT will control whether or not to use a self-signed certificate or get one from letsencrypt
# letsenrypt won't work with IPs, or with domainnames without dots in then (eg localhost) or from behind a firewall even if we give the NSG the acme :@ (!!)
if [ $USE_SS_CERT ]; then
  echo -e "-- ${bold}Making self-signed certificates for local container ($SERVER_NAME)${normal} --"
  /bin/gen_cert.sh $SERVER_NAME
  if [ -f /etc/ssl/certs/$SERVER_NAME.crt ]; then
    printf "%-50s $print_ok\n" "Certificates generated"
  else
    printf "%-50s $print_fail\n" "Certificates Could not be generated ($?)"
  fi
else
  echo -e "-- ${bold}Obtaining certificates from letsencrypt using certbot ($SERVER_NAME)${normal} --"
  service apache2 start

#  [ ! -d /data/letsencrypt ] && mkdir /data/letsencrypt
#  [ ! -d /data/pki/certs ] && mkdir -p /data/pki/certs
#  [ ! -d /data/pki/priv ] && mkdir -p /data/pki/priv
  staging=""
  ## Maybe we want staging certs for dev instances? but they will use a FAKE CA and not really allow us to test stuff properly
  ## Perhaps when letsencrypt start issuing certs for IPs we should modify the above so that --staging is used with certbot when HOSTNAME_IS_IP?
  [[ $ENVIRONMENT == "dev" ]] && staging="--staging"

  mkdir -p /var/www/acme-docroot

  # Correct cert on data volume in /data/pki/certs? We should be able to just bring apache up with ssl
  # If not...
  if [ ! -f /etc/ssl/certs/$SERVER_NAME.crt ]; then
    # Lets encrypt has a cert but for some reason this has not been copied to where apache wants them
    if [ -f /etc/letsencrypt/live/base/fullchain.pem ]; then
      echo -e "Linking existing cert/key to /etc/ssl" 
      ln -s /etc/letsencrypt/live/base/fullchain.pem /etc/ssl/certs/$SERVER_NAME.crt
      ln -s /etc/letsencrypt/live/base/privkey.pem /etc/ssl/private/$SERVER_NAME.key
    else
      # No cert here, We'll register and get one and store all the gubbins on the letsecnrypt volume (n.b. this needs to be an azuredisk for symlink reasons)
      echo -e "Getting new cert and linking cert/key to /etc/ssl"
      certbot -n certonly --webroot $staging -w /var/www/acme-docroot/ --expand --agree-tos --email $ADMIN_EMAIL --cert-name base -d $SERVER_NAME
      # In case these are somehow hanging around to wreck the symlinking
      [ -f  /etc/ssl/certs/$SERVER_NAME.crt ] && rm /etc/ssl/certs/$SERVER_NAME.crt
      [ -f  /etc/ssl/private/$SERVER_NAME.key ] && rm /etc/ssl/private/$SERVER_NAME.key

      # Link cert and key to a location that our general apache config will know about
      if [ -f /etc/letsencrypt/live/base/fullchain.pem ]; then
        ln -s /etc/letsencrypt/live/base/fullchain.pem /etc/ssl/certs/$SERVER_NAME.crt
        ln -s /etc/letsencrypt/live/base/privkey.pem /etc/ssl/private/$SERVER_NAME.key
      else
        echo -e "${red}${bold}Certificate could not be obtained from letsencrypt using certbot!${normal}"
      fi

      # Certbot starts apache as a service.... we have no need for this once the certificate is generated so let's stop it
      service apache2 stop
    fi
    printf "%-50s $print_ok\n" "Certificate obtained"; # hmmm... catch an error maybe?
  else
     printf "%-50s $print_ok\n" "Certificate already in place";
  fi
  echo -e "-- ${bold}Setting up auto renewal${normal} --"
  # Remove this one as it is no good to us in this context
  rm /etc/cron.d/certbot
  # Add some evaluated variables 
  sed -i "s/#SERVER_NAME#/$SERVER_NAME/" /var/tmp/renew_cert
  sed -i "s/#ADMIN_EMAIL#/$ADMIN_EMAIL/" /var/tmp/renew_cert
  # copy renew_script into cron.weekly (whould be frequent enough)
  mkdir -p /etc/cron.weekly
  mv /var/tmp/renew_cert /etc/cron.weekly/renew_cert
  service cron start
  printf "%-50s $print_ok\n" "renew_cert script moved to /etc/cron.weekly";
fi


a2ensite hyrax_ssl
service apache2 reload
service apache2 restart

#########
# Rails #
#########

echo "--------- Starting Hyrax in $RAILS_ENV mode ---------"
RAILS_START=`bundle exec rails server -p $RAILS_PORT -b '0.0.0.0' --pid $PIDS_PATH/$APPLICATION_KEY.pid`
if [ "$?" -ne "0" ]; then
  echo "### There was an issue starting rails/puma. We have kept this container alive for you to go and see what's up ###"
  tail -f /dev/null
fi
                                                                                                                                                                                                                                   145,1         Bot
