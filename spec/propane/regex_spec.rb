class Propane
  RSpec.describe Regex do

    it "parses an empty expression" do
      regex = Regex.new("", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0].size).to eq 0
    end

    it "parses a single character unit expression" do
      regex = Regex.new("a", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterRangeUnit
    end

    it "parses a group with a single character unit expression" do
      regex = Regex.new("(a)", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::AlternatesUnit
      alt_unit = seq_unit[0]
      expect(alt_unit.alternates.size).to eq 1
      expect(alt_unit.alternates[0]).to be_a Regex::SequenceUnit
      expect(alt_unit.alternates[0][0]).to be_a Regex::CharacterRangeUnit
    end

    it "parses a *" do
      regex = Regex.new("a*", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 0
      expect(m_unit.max_count).to be_nil
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
    end

    it "parses a +" do
      regex = Regex.new("a+", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 1
      expect(m_unit.max_count).to be_nil
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
    end

    it "parses a ?" do
      regex = Regex.new("a?", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 0
      expect(m_unit.max_count).to eq 1
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
    end

    it "parses a multiplicity count" do
      regex = Regex.new("a{5}", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 5
      expect(m_unit.max_count).to eq 5
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
    end

    it "parses a minimum-only multiplicity count" do
      regex = Regex.new("a{5,}", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 5
      expect(m_unit.max_count).to be_nil
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
    end

    it "parses a minimum and maximum multiplicity count" do
      regex = Regex.new("a{5,8}", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::MultiplicityUnit
      m_unit = seq_unit[0]
      expect(m_unit.min_count).to eq 5
      expect(m_unit.max_count).to eq 8
      expect(m_unit.unit).to be_a Regex::CharacterRangeUnit
      expect(m_unit.unit.first).to eq "a".ord
    end

    it "parses an escaped *" do
      regex = Regex.new("a\\*", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 2
      expect(seq_unit[0]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[0].first).to eq "a".ord
      expect(seq_unit[1]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[1].first).to eq "*".ord
    end

    it "parses an escaped +" do
      regex = Regex.new("a\\+", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 2
      expect(seq_unit[0]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[0].first).to eq "a".ord
      expect(seq_unit[1]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[1].first).to eq "+".ord
    end

    it "parses an escaped \\" do
      regex = Regex.new("\\\\d", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 2
      expect(seq_unit[0]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[0].first).to eq "\\".ord
      expect(seq_unit[1]).to be_a Regex::CharacterRangeUnit
      expect(seq_unit[1].first).to eq "d".ord
    end

    it "parses a character class" do
      regex = Regex.new("[a-z_]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_falsey
      expect(ccu.size).to eq 2
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "a".ord
      expect(ccu[0].last).to eq "z".ord
      expect(ccu[1]).to be_a Regex::CharacterRangeUnit
      expect(ccu[1].first).to eq "_".ord
    end

    it "parses a negated character class" do
      regex = Regex.new("[^xyz]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_truthy
      expect(ccu.size).to eq 3
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "x".ord
    end

    it "parses a negated character class with inner character classes" do
      regex = Regex.new("[^x\\sz]")
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_truthy
      expect(ccu.size).to eq 8
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "x".ord
      expect(ccu[1].first).to eq " ".ord
      expect(ccu[7].first).to eq "z".ord
    end

    it "parses - as a plain character at beginning of a character class" do
      regex = Regex.new("[-9]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.size).to eq 2
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "-".ord
    end

    it "parses - as a plain character at end of a character class" do
      regex = Regex.new("[0-]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.size).to eq 2
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "0".ord
      expect(ccu[1]).to be_a Regex::CharacterRangeUnit
      expect(ccu[1].first).to eq "-".ord
    end

    it "parses - as a plain character at beginning of a negated character class" do
      regex = Regex.new("[^-9]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_truthy
      expect(ccu.size).to eq 2
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "-".ord
    end

    it "parses . as a plain character in a character class" do
      regex = Regex.new("[.]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_falsey
      expect(ccu.size).to eq 1
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq ".".ord
    end

    it "parses - as a plain character when escaped in middle of character class" do
      regex = Regex.new("[0\\-9]", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      seq_unit = regex.unit.alternates[0]
      expect(seq_unit.size).to eq 1
      expect(seq_unit[0]).to be_a Regex::CharacterClassUnit
      ccu = seq_unit[0]
      expect(ccu.negate).to be_falsey
      expect(ccu.size).to eq 3
      expect(ccu[0]).to be_a Regex::CharacterRangeUnit
      expect(ccu[0].first).to eq "0".ord
      expect(ccu[1]).to be_a Regex::CharacterRangeUnit
      expect(ccu[1].first).to eq "-".ord
      expect(ccu[2]).to be_a Regex::CharacterRangeUnit
      expect(ccu[2].first).to eq "9".ord
    end

    it "parses alternates" do
      regex = Regex.new("ab|c", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 2
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[1]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[0].size).to eq 2
      expect(regex.unit.alternates[1].size).to eq 1
    end

    it "parses a ." do
      regex = Regex.new("a.b", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 1
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[0][0]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[0][1]).to be_a Regex::CharacterClassUnit
      expect(regex.unit.alternates[0][1].units.size).to eq 2
      expect(regex.unit.alternates[0][2]).to be_a Regex::CharacterRangeUnit
    end

    it "parses something complex" do
      regex = Regex.new("(a|)*|[^^]|\\|v|[x-y]+", 1)
      expect(regex.unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates.size).to eq 4
      expect(regex.unit.alternates[0]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[0].size).to eq 1
      expect(regex.unit.alternates[0][0]).to be_a Regex::MultiplicityUnit
      expect(regex.unit.alternates[0][0].min_count).to eq 0
      expect(regex.unit.alternates[0][0].max_count).to be_nil
      expect(regex.unit.alternates[0][0].unit).to be_a Regex::AlternatesUnit
      expect(regex.unit.alternates[0][0].unit.alternates.size).to eq 2
      expect(regex.unit.alternates[0][0].unit.alternates[0]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[0][0].unit.alternates[0].size).to eq 1
      expect(regex.unit.alternates[0][0].unit.alternates[0][0]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[0][0].unit.alternates[1]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[0][0].unit.alternates[1].size).to eq 0
      expect(regex.unit.alternates[1]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[1].size).to eq 1
      expect(regex.unit.alternates[1][0]).to be_a Regex::CharacterClassUnit
      expect(regex.unit.alternates[1][0].negate).to be_truthy
      expect(regex.unit.alternates[1][0].size).to eq 1
      expect(regex.unit.alternates[1][0][0]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[2]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[2].size).to eq 2
      expect(regex.unit.alternates[2][0]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[2][0].first).to eq "|".ord
      expect(regex.unit.alternates[2][1]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[2][1].first).to eq "v".ord
      expect(regex.unit.alternates[3]).to be_a Regex::SequenceUnit
      expect(regex.unit.alternates[3].size).to eq 1
      expect(regex.unit.alternates[3][0]).to be_a Regex::MultiplicityUnit
      expect(regex.unit.alternates[3][0].min_count).to eq 1
      expect(regex.unit.alternates[3][0].max_count).to be_nil
      expect(regex.unit.alternates[3][0].unit).to be_a Regex::CharacterClassUnit
      expect(regex.unit.alternates[3][0].unit.size).to eq 1
      expect(regex.unit.alternates[3][0].unit[0]).to be_a Regex::CharacterRangeUnit
      expect(regex.unit.alternates[3][0].unit[0].first).to eq "x".ord
      expect(regex.unit.alternates[3][0].unit[0].last).to eq "y".ord
    end

  end
end
