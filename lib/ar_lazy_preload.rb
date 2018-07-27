# frozen_string_literal: true

require "ar_lazy_preload/association"
require "ar_lazy_preload/custom_loader"
require "ar_lazy_preload/lazy_preload"
require "ar_lazy_preload/base"

module ArLazyPreload
  ActiveRecord::Base.include(ArLazyPreload::Base)

  ActiveRecord::Relation.include(ArLazyPreload::LazyPreload)
  ActiveRecord::Relation.include(ArLazyPreload::CustomLoader)

  [
    ActiveRecord::Associations::CollectionAssociation,
    ActiveRecord::Associations::Association
  ].each { |klass| klass.include(ArLazyPreload::Association) }
end
