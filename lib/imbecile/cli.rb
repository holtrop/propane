module Imbecile
  module CLI

    USAGE = <<EOF
Usage: #{$0} [options] <input-file> <output-file>
Options:
  --version   Show program version and exit
  -h, --help  Show this usage and exit
EOF

    class << self

      def run(args)
        extra_args = []
        args.each do |arg|
          case arg
          when "--version"
            puts "imbecile v#{VERSION}"
            return 0
          when "-h", "--help"
            puts USAGE
            return 0
          when /^-/
            $stderr.puts "Error: unknown option #{arg}"
            return 1
          else
            extra_args << arg
          end
        end
        if extra_args.size != 2
          $stderr.puts "Error: specify input and output files"
          return 1
        end
        unless File.readable?(args[0])
          $stderr.puts "Error: cannot read #{args[0]}"
          return 2
        end
        Imbecile.run(*args)
      end

    end

  end
end
