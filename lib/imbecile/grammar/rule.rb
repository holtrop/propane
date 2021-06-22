module Imbecile
  class Grammar

    class Rule

      attr_reader :name

      attr_reader :components

      attr_reader :code

      def initialize(name, rule, code)
        @name = name
        rule_components = rule.split(/\s+/)
        @components = rule_components
        @code = code
      end

    end

  end
end
