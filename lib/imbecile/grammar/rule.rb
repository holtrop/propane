module Imbecile
  class Grammar

    class Rule

      attr_reader :components

      def initialize(name, rule, code)
        @name = name
        rule_components = rule.split(/\s+/)
        @components = rule_components
        @code = code
      end

    end

  end
end
