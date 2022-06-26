class Propane

  # Utility methods.
  module Util

    class << self

      def banner(message)
        s = "*" * (message.size + 4)
        "#{s}\n* #{message} *\n#{s}\n"
      end

    end

  end

end
