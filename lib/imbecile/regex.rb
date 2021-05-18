module Imbecile
  class Regex

    attr_accessor :parser

    def initialize(pattern)
      @parser = Parser.new(pattern)
    end

  end
end
