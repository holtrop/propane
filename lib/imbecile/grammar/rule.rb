module Imbecile
  class Grammar

    class Rule

      def initialize(name, rule, code)
        @name = name
        rule_components = rule.split(/\s+/)
        @components = rule_components
        @code = code
      end

    end

  end
end
