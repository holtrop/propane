class Propane
  class Parser

    describe Item do

      it "operates properly with a set" do
        rule = Object.new
        item1 = Item.new(rule, 2)
        item2 = Item.new(rule, 2)
        expect(item1).to eq item2
        expect(item1.eql?(item2)).to be_truthy
        set = Set.new([item1, item2])
        expect(set.size).to eq 1
      end

    end

  end
end
