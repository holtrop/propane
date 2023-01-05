require "rspec/core/rake_task"

task :build_dist do
  sh "ruby rb/build_dist.rb"
end

RSpec::Core::RakeTask.new(:spec, :example_pattern) do |task, args|
  if args.example_pattern
    task.rspec_opts = %W[-e "#{args.example_pattern}" -f documentation]
  end
end

task :default => :spec

desc "Build user guide"
task :user_guide do
  system("ruby", "-Ilib", "rb/gen_user_guide.rb")
end
