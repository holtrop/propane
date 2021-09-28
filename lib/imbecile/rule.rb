class Imbecile

  class Rule

    class Pattern

      attr_reader :rule

      attr_reader :components

      attr_reader :code

      def initialize(rule, components, code)
        @rule = rule
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
