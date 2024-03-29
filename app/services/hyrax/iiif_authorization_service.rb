# frozen_string_literal: true
module Hyrax
  class IIIFAuthorizationService
    attr_reader :controller
    def initialize(controller)
      @controller = controller
    end

    # @note we ignore the `action` param here in favor of the `:show` action for all permissions
    def can?(_action, object)
      controller.current_ability.can?(:show, file_set_id_for(object))
    end

    private

    def file_set_id_for(object)
      if object.id.include? '/'
        object.id.split('/').first
      else
        URI.decode(object.id).split('/').first
      end
    end
  end
end
