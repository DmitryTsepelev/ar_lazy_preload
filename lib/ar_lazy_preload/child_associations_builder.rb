# frozen_string_literal: true

module ArLazyPreload
  class ChildAssociationsBuilder
    attr_reader :association_values

    def initialize(association_values)
      @association_values = association_values
    end

    def build(association)
      hash_values = association_values.select { |value| value.is_a?(Hash) }
      hash_values.map { |value| value[association] }
    end
  end
end
