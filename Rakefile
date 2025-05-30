# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

::Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/test_*.rb"
  t.warning = false
  t.verbose = true
end

::RuboCop::RakeTask.new do |task|
  task.plugins << "rubocop-performance"
  task.plugins << "rubocop-rake"
end

::YARD::Rake::YardocTask.new

::Dir["tasks/**/*.rake"].each { |t| load t }

task default: %i[
  generate_rubocop_yaml
  yard
  test
  rubocop:autocorrect
]
