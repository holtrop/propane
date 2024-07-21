class Propane
  module CLI

    USAGE = <<EOF
Usage: #{$0} [options] <input-file> <output-file>
Options:
  -h, --help  Show this usage and exit.
  --log LOG   Write log file. This will show all parser states and their
              associated shifts and reduces. It can be helpful when
              debugging a grammar.
  --version   Show program version and exit.
  -w          Treat warnings as errors. This option will treat shift/reduce
              conflicts as fatal errors and will print them to stderr in
              addition to the log file.
EOF

    class << self

      def run(args)
        params = []
        options = {}
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
          when "-w"
            options[:warnings_as_errors] = true
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
        Propane.run(*params, log_file, options)
      end

    end

  end
end
