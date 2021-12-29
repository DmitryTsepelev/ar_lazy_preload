# frozen_string_literal: true

require "ar_lazy_preload/active_record/base"
require "ar_lazy_preload/active_record/relation"
require "ar_lazy_preload/active_record/association"
require "ar_lazy_preload/active_record/collection_association"
require "ar_lazy_preload/active_record/merger"
require "ar_lazy_preload/active_record/association_relation"
require "ar_lazy_preload/active_record/collection_proxy"

module ArLazyPreload
  class Railtie < Rails::Railtie
    config.to_prepare do |_app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.include(Base)

        ActiveRecord::Relation.prepend(Relation)
        ActiveRecord::AssociationRelation.prepend(AssociationRelation)
        ActiveRecord::Relation::Merger.prepend(Merger)

        [
          ActiveRecord::Associations::CollectionAssociation,
          ActiveRecord::Associations::Association
        ].each { |klass| klass.prepend(Association) }

        ActiveRecord::Associations::CollectionAssociation.prepend(CollectionAssociation)
        ActiveRecord::Associations::CollectionProxy.prepend(CollectionProxy)

        ArLazyPreload::Preloader.patch_for_rails_7! if ActiveRecord::VERSION::MAJOR >= 7
      end
    end
  end
end
