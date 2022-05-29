require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec, :example_pattern) do |task, args|
  if args.example_pattern
    task.rspec_opts = %W[-e "#{args.example_pattern}" -f documentation]
  end
end

task :default => :spec
