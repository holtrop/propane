unless ENV["dist_specs"]
  require "bundler/setup"
  require "simplecov"

  class MyFormatter
    def format(*args)
    end
  end
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/.bundle/"
    if ENV["partial_specs"]
      command_name "RSpec-partial"
    else
      command_name "RSpec"
    end
    project_name "Propane"
    merge_timeout 3600
    formatter(MyFormatter)
  end

  RSpec.configure do |config|
    # Enable flags like --only-failures and --next-failure
    config.example_status_persistence_file_path = ".rspec_status"

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end
  end
end

require "propane"
