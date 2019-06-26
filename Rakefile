require "appraisal"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default do
    sh "rubocop && appraisal install && rake appraisal spec"
  end
else
  task default: [:rubocop, :spec]
end

task :bench do
  cmd = %w[bundle exec ruby benchmark/main.rb]
  exit system(*cmd)
end

task :memory do
  cmd = %w[bundle exec ruby benchmark/memory.rb]
  exit system(*cmd)
end
