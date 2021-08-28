class Imbecile

  class Rule

    class Pattern

      attr_reader :components

      attr_reader :code

      def initialize(components, code)
        @components = components
        @code = code
      end

    end

    attr_reader :name

    attr_reader :patterns

    def initialize(name)
      @name = name
      @patterns = []
    end

    def add_pattern(components, code)
      @patterns << Pattern.new(components, code)
    end

  end

end
