class Propane

  class RuleSet

    attr_reader :id

    attr_reader :name

    attr_reader :rules

    def initialize(name, id)
      @name = name
      @id = id
      @rules = []
    end

    def add_rule(rule)
      @rules << rule
    end

  end

end
