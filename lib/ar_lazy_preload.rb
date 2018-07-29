# frozen_string_literal: true

require "ar_lazy_preload/ext/base"
require "ar_lazy_preload/ext/relation"
require "ar_lazy_preload/ext/association"
require "ar_lazy_preload/ext/merger"

module ArLazyPreload
  ActiveRecord::Base.include(ArLazyPreload::Base)

  ActiveRecord::Relation.prepend(ArLazyPreload::Relation)
  ActiveRecord::Relation::Merger.prepend(ArLazyPreload::Merger)

  [
    ActiveRecord::Associations::CollectionAssociation,
    ActiveRecord::Associations::Association
  ].each { |klass| klass.prepend(ArLazyPreload::Association) }
end
