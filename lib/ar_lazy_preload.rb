# frozen_string_literal: true

require "ar_lazy_preload/configuration"
require "ar_lazy_preload/railtie" if defined?(::Rails)

require "ar_lazy_preload/active_record/base"
require "ar_lazy_preload/active_record/relation"
require "ar_lazy_preload/active_record/association"
require "ar_lazy_preload/active_record/collection_association"
require "ar_lazy_preload/active_record/merger"
require "ar_lazy_preload/active_record/association_relation"
require "ar_lazy_preload/active_record/collection_proxy"

module ArLazyPreload
  class << self
    def config
      @config ||= Configuration.new
    end

    def install_hooks
      ActiveRecord::Base.include(Base)

      ActiveRecord::Relation.prepend(Relation)
      ActiveRecord::AssociationRelation.prepend(AssociationRelation)
      ActiveRecord::Relation::Merger.prepend(Merger)

      ActiveRecord::Associations::CollectionAssociation.prepend(Association)
      ActiveRecord::Associations::Association.prepend(Association)

      ActiveRecord::Associations::CollectionAssociation.prepend(CollectionAssociation)
      ActiveRecord::Associations::CollectionProxy.prepend(CollectionProxy)

      ArLazyPreload::Preloader.patch_for_rails_7! if ActiveRecord::VERSION::MAJOR >= 7
    end
  end
end
