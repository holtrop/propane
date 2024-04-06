class Propane
  module CLI

    USAGE = <<EOF
Usage: #{$0} [options] <input-file> <output-file>
Options:
  --log LOG   Write log file
  --version   Show program version and exit
  -h, --help  Show this usage and exit
EOF

    class << self

      def run(args)
        params = []
        log_file = nil
        i = 0
        while i < args.size
          arg = args[i]
          case arg
          when "--log"
            if i + 1 < args.size
              i += 1
              log_file = args[i]
            end
          when "--version"
            puts "propane version #{VERSION}"
            return 0
          when "-h", "--help"
            puts USAGE
            return 0
          when /^-/
            $stderr.puts "Error: unknown option #{arg}"
            return 1
          else
            params << arg
          end
          i += 1
        end
        if params.size != 2
          $stderr.puts "Error: specify input and output files"
          return 1
        end
        unless File.readable?(params[0])
          $stderr.puts "Error: cannot read #{params[0]}"
          return 2
        end
        Propane.run(*params, log_file)
      end

    end

  end
end
