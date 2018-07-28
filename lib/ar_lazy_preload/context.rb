# frozen_string_literal: true

class Context
  attr_reader :records, :associations

  def initialize(records, associations)
    @records = records
    @associations = associations
  end

  def preload_association(association)
    preloader.preload(records, association) if associations.include?(association)
  end

  private

  def preloader
    @preloader ||= ActiveRecord::Associations::Preloader.new
  end
end
