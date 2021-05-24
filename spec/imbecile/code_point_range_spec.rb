module Imbecile
  describe CodePointRange do

    describe "#<=>" do
      it "sorts ranges" do
        arr = [
          CodePointRange.new(100,102),
          CodePointRange.new(65, 68),
          CodePointRange.new(65, 65),
          CodePointRange.new(100, 100),
          CodePointRange.new(68, 70),
        ]
        arr.sort!
        expect(arr[0]).to eq CodePointRange.new(65, 65)
        expect(arr[1]).to eq CodePointRange.new(65, 68)
        expect(arr[2]).to eq CodePointRange.new(68, 70)
        expect(arr[3]).to eq CodePointRange.new(100, 100)
        expect(arr[4]).to eq CodePointRange.new(100, 102)
      end
    end

    describe "#include?" do
      it "returns whether the code point is included in the range" do
        expect(CodePointRange.new(100).include?(100)).to be_truthy
        expect(CodePointRange.new(100, 100).include?(99)).to be_falsey
        expect(CodePointRange.new(100, 100).include?(101)).to be_falsey
        expect(CodePointRange.new(100, 120).include?(99)).to be_falsey
        expect(CodePointRange.new(100, 120).include?(100)).to be_truthy
        expect(CodePointRange.new(100, 120).include?(110)).to be_truthy
        expect(CodePointRange.new(100, 120).include?(120)).to be_truthy
        expect(CodePointRange.new(100, 120).include?(121)).to be_falsey
      end

      it "returns whether the range is included in the range" do
        expect(CodePointRange.new(100).include?(CodePointRange.new(100))).to be_truthy
        expect(CodePointRange.new(100, 100).include?(CodePointRange.new(99))).to be_falsey
        expect(CodePointRange.new(100, 100).include?(CodePointRange.new(99, 100))).to be_falsey
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(90, 110))).to be_falsey
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(110, 130))).to be_falsey
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(100, 120))).to be_truthy
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(100, 110))).to be_truthy
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(110, 120))).to be_truthy
        expect(CodePointRange.new(100, 120).include?(CodePointRange.new(102, 118))).to be_truthy
      end
    end

    describe ".invert_ranges" do
      it "inverts ranges" do
        expect(CodePointRange.invert_ranges(
          [CodePointRange.new(60, 90),
           CodePointRange.new(80, 85),
           CodePointRange.new(80, 100),
           CodePointRange.new(101),
           CodePointRange.new(200, 300)])).to eq [
             CodePointRange.new(0, 59),
             CodePointRange.new(102, 199),
             CodePointRange.new(301, 0xFFFFFFFF)]
        expect(CodePointRange.invert_ranges(
          [CodePointRange.new(0, 500),
           CodePointRange.new(7000, 0xFFFFFFFF)])).to eq [
             CodePointRange.new(501, 6999)]
      end
    end

    describe ".first_subrange" do
      it "returns the first subrange to split" do
        expect(CodePointRange.first_subrange(
          [CodePointRange.new(65, 90),
           CodePointRange.new(66, 66),
           CodePointRange.new(80, 90)])).to eq CodePointRange.new(65)
        expect(CodePointRange.first_subrange(
          [CodePointRange.new(65, 90)])).to eq CodePointRange.new(65, 90)
        expect(CodePointRange.first_subrange(
          [CodePointRange.new(65, 90),
           CodePointRange.new(80, 90)])).to eq CodePointRange.new(65, 79)
        expect(CodePointRange.first_subrange(
          [CodePointRange.new(65, 90),
           CodePointRange.new(65, 100),
           CodePointRange.new(65, 95)])).to eq CodePointRange.new(65, 90)
        expect(CodePointRange.first_subrange(
          [CodePointRange.new(100, 120),
           CodePointRange.new(70, 90)])).to eq CodePointRange.new(70, 90)
      end
    end

  end
end
