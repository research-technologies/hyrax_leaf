Hyrax.config do | config |
      Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithFilesActor, 
        Hyrax::Actors::CreateWithFilesOrderedMembersActor)

      Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CreateWithRemoteFilesActor, 
        Hyrax::Actors::CreateWithRemoteFilesOrderedMembersActor)
end