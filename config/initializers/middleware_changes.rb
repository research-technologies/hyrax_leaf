Rails.application.configure do
  config.to_prepare do
      Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithFilesActor, 
        Hyrax::Actors::CreateWithFilesOrderedMembersActor)

      Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithRemoteFilesActor, 
        Hyrax::Actors::CreateWithRemoteFilesOrderedMembersActor)
    end
end