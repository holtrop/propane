require "rake/clean"
require "rspec/core/rake_task"
require "simplecov"
require "stringio"

CLEAN.include %w[spec/run gen .yardoc yard coverage dist]

task :build_dist do
  sh "ruby rb/build_dist.rb"
end

RSpec::Core::RakeTask.new(:spec, :example_pattern) do |task, args|
  if args.example_pattern
    task.rspec_opts = %W[-e "#{args.example_pattern}" -f documentation]
  end
end
task :spec do |task, args|
  original_stdout = $stdout
  sio = StringIO.new
  $stdout = sio
  SimpleCov.collate Dir["coverage/.resultset.json"]
  $stdout = original_stdout
  sio.string.lines.each do |line|
    $stdout.write(line) unless line =~ /Coverage report generated for/
  end
end

# dspec task is useful to test the distributable release script, but is not
# useful for coverage information.
desc "Dist Specs"
task :dspec, [:example_string] => :build_dist do |task, args|
  ENV["dist_specs"] = "1"
  Rake::Task["spec"].execute(args)
  ENV.delete("dist_specs")
end

task :default => :spec

desc "Build user guide"
task :user_guide do
  system("ruby", "-Ilib", "rb/gen_user_guide.rb")
end

task :all => [:spec, :dspec, :user_guide]
