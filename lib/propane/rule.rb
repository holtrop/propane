class Propane

  class Rule

    attr_reader :name

    attr_reader :components

    attr_reader :code

    def initialize(name, components, code)
      @name = name
      @components = components
      @code = code
    end

  end

end
