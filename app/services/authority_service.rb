# frozen_string_literal: true

module AuthorityService
  # Object based
  
  class DepartmentsService < DogBiscuits::Terms::DepartmentsTermsService
    include ::LocalAuthorityConcern
  end
  
  class EventsService < DogBiscuits::Terms::EventsTermsService
    include ::LocalAuthorityConcern
  end
  
  class GroupsService < DogBiscuits::Terms::GroupsTermsService
    include ::LocalAuthorityConcern
  end
  
  class PeopleService < DogBiscuits::Terms::PeopleTermsService
    include ::LocalAuthorityConcern
  end
  
  class PlacesService < DogBiscuits::Terms::PlacesTermsService
    include ::LocalAuthorityConcern
  end
  
  class OrganisationsService < DogBiscuits::Terms::OrganisationsTermsService
    include ::LocalAuthorityConcern
  end
  
  class ProjectsService < DogBiscuits::Terms::ProjectsTermsService
    include ::LocalAuthorityConcern
  end
  
  class ConceptsService < DogBiscuits::Terms::ConceptsTermsService
    include ::LocalAuthorityConcern
  end
  
  # File based
  
  class ResourceTypeGeneralsService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('resource_type_generals')
    end
  end
  
  class PublicationStatusesService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('publication_statuses')
    end
  end
  
  class QualificationLevelsService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('qualification_levels')
    end
  end
  
  class LicensesService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('licenses')
    end
  end
  
  class RightsStatementsService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('rights_statements')
    end
  end
  
  class QualificationNamesService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('qualification_names')
    end
  end
  
  class JournalArticleVersionsService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('journal_article_versions')
    end
  end
  
  class ResourceTypesService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('resource_types')
    end
  end
  
  class ContentVersionsService < Hyrax::QaSelectService
    include ::FileAuthorityConcern
    
    def initialize
      super('content_versions')
    end
  end
  

  # Table based
  class TableBasedAuthorityService < DogBiscuits::TableBasedAuthorityExtended
  end
end
