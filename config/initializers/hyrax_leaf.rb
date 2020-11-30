Hyrax.config do | config |
  
  # Middleware changes
  Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithFilesActor, 
    Hyrax::Actors::CreateWithFilesOrderedMembersActor)

  Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithRemoteFilesActor, 
    Hyrax::Actors::CreateWithRemoteFilesOrderedMembersActor)

  # Paths
  config.upload_path = ->() { ENV.fetch('UPLOADS_PATH', File.join(Rails.root, 'tmp', 'uploads/')) }
  config.cache_path = ->() { ENV.fetch('CACHE_PATH', File.join(Rails.root, 'tmp', 'uploads', 'cache')) }
  config.derivatives_path = ENV.fetch('DERIVATIVES_PATH', File.join(Rails.root, 'tmp', 'derivatives'))
  config.working_path = ENV.fetch('WORKING_PATH', File.join(Rails.root, 'tmp', 'uploads'))
  config.branding_path = ENV.fetch('BRANDING_PATH', Rails.root.join('public', 'branding'))
  fits_version = ENV.fetch('FITS_VERSION', 'fits-1.0.5')
  config.fits_path = ENV['FITS_PATH'] || "/fits/#{fits_version}/fits.sh"
  config.libreoffice_path = ENV.fetch('LIBREOFFICE_PATH', 'soffice') 
 
  # Emails
  config.contact_email = ENV['CONTACT_FORM_RECIPIENT_EMAIL'] || "repo-admin@example.org"
  config.subject_prefix = ENV['CONTACT_FORM_SUBJECT_PREFIX'] || "Contact form:"
  # config.batch_user_key = 'batchuser@example.com'
  # config.audit_user_key = 'batchuser@example.com'
  
  # Other config
  config.banner_image = ENV['BANNER'] if ENV['BANNER']
  config.geonames_username = ENV.fetch('GEONAMES_USERNAME', 'hykuleaf')
  config.iiif_image_server = true
  
  config.contact_email = ENV['CONTACT_EMAIL'] if ENV['CONTACT_EMAIL']

  config.iiif_image_url_builder = lambda do |file_id, base_url, size|
      Riiif::Engine.routes.url_helpers.image_url(file_id, host: base_url, size: size)
  end
  
  config.iiif_info_url_builder = lambda do |file_id, base_url|
      uri = Riiif::Engine.routes.url_helpers.info_url(file_id, host: base_url, port: ENV.fetch("PORT", ""))
      uri.sub(%r{/info\.json\Z}, '')
  end

  # config.iiif_image_compliance_level_uri = 'http://iiif.io/api/image/2/level2.json'

  # Returns a IIIF image size default
  # config.iiif_image_size_default = '600,'

  # Fields to display in the IIIF metadata section; default is the required fields
  # config.iiif_metadata_fields = Hyrax::Forms::WorkForm.required_fields
  
end
