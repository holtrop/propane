class Propane

  class RuleSet

    class Pattern

      attr_reader :rule_set

      attr_reader :components

      attr_reader :code

      def initialize(rule_set, components, code)
        @rule_set = rule_set
        @components = components
        @code = code
      end

    end

    attr_reader :id

    attr_reader :name

    attr_reader :patterns

    def initialize(name, id)
      @name = name
      @id = id
      @patterns = []
    end

    def add_pattern(components, code)
      @patterns << Pattern.new(self, components, code)
    end

  end

end
