require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'atsd/version'

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = %w[ -m markdown -M redcarpet -r README.md ]
  t.stats_options = []
end

