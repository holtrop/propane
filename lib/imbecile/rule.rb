class Imbecile

  class Rule

    attr_reader :name

    attr_reader :components

    attr_reader :code

    def initialize(name, rule_components, code)
      @name = name
      @components = rule_components
      @code = code
    end

  end

end
