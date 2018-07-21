module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include ::DogBiscuitsHelper

  def application_name
    if ENV['APPLICATION_NAME'].blank?
      t('hyrax.product_name', default: super)
    else
      ENV['APPLICATION_NAME']
    end
  end
end
