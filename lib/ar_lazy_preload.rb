# frozen_string_literal: true

require "ar_lazy_preload/base"
require "ar_lazy_preload/relation"
require "ar_lazy_preload/association"
require "ar_lazy_preload/merger"

module ArLazyPreload
  ActiveRecord::Base.include(ArLazyPreload::Base)

  ActiveRecord::Relation.include(ArLazyPreload::Relation)
  ActiveRecord::Relation::Merger.include(ArLazyPreload::Merger)

  [
    ActiveRecord::Associations::CollectionAssociation,
    ActiveRecord::Associations::Association
  ].each { |klass| klass.include(ArLazyPreload::Association) }
end
