module Imbecile
  class Regex
    RSpec.describe Parser do

      it "parses various expressions" do
        expect(Parser.new("").unit).to be_a Parser::AlternatesUnit
      end

    end
  end
end
