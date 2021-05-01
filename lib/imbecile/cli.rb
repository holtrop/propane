module Imbecile
  module CLI

    USAGE = <<EOF
Usage: #{$0} [options] <input-file>
Options:
  --version   Show program version and exit
  -h, --help  Show this usage and exit
EOF

    class << self

      def run(args)
        input_file = nil
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
            if input_file
              $stderr.puts "Error: only one input file supported"
              return 1
            else
              input_file = arg
            end
          end
        end
        if input_file.nil?
          $stderr.puts "Error: must specify input file"
          return 1
        end
        unless File.readable?(input_file)
          $stderr.puts "Error: cannot read #{input_file}"
          return 2
        end
        Imbecile.run(input_file)
      end

    end

  end
end
