# frozen_string_literal: true

require "ar_lazy_preload/configuration"
require "ar_lazy_preload/ext/base"
require "ar_lazy_preload/ext/relation"
require "ar_lazy_preload/ext/association"
require "ar_lazy_preload/ext/merger"
require "ar_lazy_preload/ext/association_relation"

module ArLazyPreload
  class << self
    def config
      @config ||= Configuration.new
    end
  end

  ActiveRecord::Base.include(ArLazyPreload::Base)

  ActiveRecord::Relation.prepend(ArLazyPreload::Relation)
  ActiveRecord::AssociationRelation.prepend(ArLazyPreload::AssociationRelation)
  ActiveRecord::Relation::Merger.prepend(ArLazyPreload::Merger)

  [
    ActiveRecord::Associations::CollectionAssociation,
    ActiveRecord::Associations::Association
  ].each { |klass| klass.prepend(ArLazyPreload::Association) }
end
