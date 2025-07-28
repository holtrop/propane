class Propane

  # Utility methods.
  module Util

    class << self

      def banner(message)
        s = "*" * (message.size + 4)
        "#{s}\n* #{message} *\n#{s}\n"
      end

      # Determine the number of threads to use.
      #
      # @return [Integer]
      #   The number of threads to use.
      def determine_n_threads
        # Try to figure out how many threads are available on the host hardware.
        begin
          case RbConfig::CONFIG["host_os"]
          when /linux/
            return File.read("/proc/cpuinfo").scan(/^processor\s*:/).size
          when /mswin|mingw|msys/
            if `wmic cpu get NumberOfLogicalProcessors -value` =~ /NumberOfLogicalProcessors=(\d+)/
              return $1.to_i
            end
          when /darwin/
            if `sysctl -n hw.ncpu` =~ /(\d+)/
              return $1.to_i
            end
          end
        rescue
        end

        # If we can't figure it out, default to 4.
        4
      end

    end

  end

end
