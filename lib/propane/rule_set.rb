class Propane

  class RuleSet

    attr_reader :name

    attr_reader :rules

    def initialize(name)
      @name = name
      @rules = []
    end

    def <<(rule)
      @rules << rule
    end

  end

end
