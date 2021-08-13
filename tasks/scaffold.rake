# frozen_string_literal: true

desc "Scaffold"
task :scaffold! do
  Dir.chdir("test") do
    paths = %w[. ..]

    Dir.entries(".").reject { |name| paths.include?(name) }.each do |example|
      Dir.chdir(example) do
        print "Generating #{example} test suite... "

        `bundle exec brutal`

        puts "Done."
      end
    end
  end
end
