require "rake/clean"
require "rspec/core/rake_task"

CLEAN.include %w[spec/run gen .yardoc yard coverage dist]

task :build_dist do
  sh "ruby rb/build_dist.rb"
end

RSpec::Core::RakeTask.new(:spec, :example_pattern) do |task, args|
  if args.example_pattern
    task.rspec_opts = %W[-e "#{args.example_pattern}" -f documentation]
  end
end

# dspec task is useful to test the distributable release script, but is not
# useful for coverage information.
desc "Dist Specs"
task :dspec, [:example_string] => :build_dist do |task, args|
  FileUtils.rm_rf("dspec")
  FileUtils.mkdir_p("dspec")
  FileUtils.cp("dist/propane", "dspec/propane")
  ENV["dist_specs"] = "1"
  Rake::Task["spec"].execute(args)
  ENV.delete("dist_specs")
end

task :default => :spec

desc "Build user guide"
task :user_guide do
  system("ruby", "-Ilib", "rb/gen_user_guide.rb")
end
