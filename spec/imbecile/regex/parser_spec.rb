module Imbecile
  class Regex
    RSpec.describe Parser do

      it "parses an empty expression" do
        parser = Parser.new("")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0].size).to eq 0
      end

      it "parses a single character unit expression" do
        parser = Parser.new("a")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterUnit
      end

      it "parses a group with a single character unit expression" do
        parser = Parser.new("(a)")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::AlternatesUnit
        alt_unit = seq_unit[0]
        expect(alt_unit.alternates.size).to eq 1
        expect(alt_unit.alternates[0]).to be_a Parser::SequenceUnit
        expect(alt_unit.alternates[0][0]).to be_a Parser::CharacterUnit
      end

      it "parses a *" do
        parser = Parser.new("a*")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 0
        expect(m_unit.max_count).to be_nil
        expect(m_unit.unit).to be_a Parser::CharacterUnit
      end

      it "parses a +" do
        parser = Parser.new("a+")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 1
        expect(m_unit.max_count).to be_nil
        expect(m_unit.unit).to be_a Parser::CharacterUnit
      end

      it "parses a ?" do
        parser = Parser.new("a?")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 0
        expect(m_unit.max_count).to eq 1
        expect(m_unit.unit).to be_a Parser::CharacterUnit
      end

      it "parses a multiplicity count" do
        parser = Parser.new("a{5}")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 5
        expect(m_unit.max_count).to eq 5
        expect(m_unit.unit).to be_a Parser::CharacterUnit
      end

      it "parses a minimum-only multiplicity count" do
        parser = Parser.new("a{5,}")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 5
        expect(m_unit.max_count).to be_nil
        expect(m_unit.unit).to be_a Parser::CharacterUnit
      end

      it "parses a minimum and maximum multiplicity count" do
        parser = Parser.new("a{5,8}")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::MultiplicityUnit
        m_unit = seq_unit[0]
        expect(m_unit.min_count).to eq 5
        expect(m_unit.max_count).to eq 8
        expect(m_unit.unit).to be_a Parser::CharacterUnit
        expect(m_unit.unit.code_point).to eq "a".ord
      end

      it "parses an escaped *" do
        parser = Parser.new("a\\*")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 2
        expect(seq_unit[0]).to be_a Parser::CharacterUnit
        expect(seq_unit[0].code_point).to eq "a".ord
        expect(seq_unit[1]).to be_a Parser::CharacterUnit
        expect(seq_unit[1].code_point).to eq "*".ord
      end

      it "parses an escaped +" do
        parser = Parser.new("a\\+")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 2
        expect(seq_unit[0]).to be_a Parser::CharacterUnit
        expect(seq_unit[0].code_point).to eq "a".ord
        expect(seq_unit[1]).to be_a Parser::CharacterUnit
        expect(seq_unit[1].code_point).to eq "+".ord
      end

      it "parses an escaped \\" do
        parser = Parser.new("\\\\d")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 2
        expect(seq_unit[0]).to be_a Parser::CharacterUnit
        expect(seq_unit[0].code_point).to eq "\\".ord
        expect(seq_unit[1]).to be_a Parser::CharacterUnit
        expect(seq_unit[1].code_point).to eq "d".ord
      end

      it "parses a character class" do
        parser = Parser.new("[a-z_]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.negate).to be_falsey
        expect(ccu.size).to eq 2
        expect(ccu[0]).to be_a Parser::CharacterRangeUnit
        expect(ccu[0].min_code_point).to eq "a".ord
        expect(ccu[0].max_code_point).to eq "z".ord
        expect(ccu[1]).to be_a Parser::CharacterUnit
        expect(ccu[1].code_point).to eq "_".ord
      end

      it "parses a negated character class" do
        parser = Parser.new("[^xyz]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.negate).to be_truthy
        expect(ccu.size).to eq 3
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq "x".ord
      end

      it "parses - as a plain character at beginning of a character class" do
        parser = Parser.new("[-9]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.size).to eq 2
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq "-".ord
      end

      it "parses - as a plain character at end of a character class" do
        parser = Parser.new("[0-]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.size).to eq 2
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq "0".ord
        expect(ccu[1]).to be_a Parser::CharacterUnit
        expect(ccu[1].code_point).to eq "-".ord
      end

      it "parses - as a plain character at beginning of a negated character class" do
        parser = Parser.new("[^-9]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.negate).to be_truthy
        expect(ccu.size).to eq 2
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq "-".ord
      end

      it "parses . as a plain character in a negated character class" do
        parser = Parser.new("[.]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.negate).to be_falsey
        expect(ccu.size).to eq 1
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq ".".ord
      end

      it "parses - as a plain character when escaped in middle of character class" do
        parser = Parser.new("[0\\-9]")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 1
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        seq_unit = parser.unit.alternates[0]
        expect(seq_unit.size).to eq 1
        expect(seq_unit[0]).to be_a Parser::CharacterClassUnit
        ccu = seq_unit[0]
        expect(ccu.negate).to be_falsey
        expect(ccu.size).to eq 3
        expect(ccu[0]).to be_a Parser::CharacterUnit
        expect(ccu[0].code_point).to eq "0".ord
        expect(ccu[1]).to be_a Parser::CharacterUnit
        expect(ccu[1].code_point).to eq "-".ord
        expect(ccu[2]).to be_a Parser::CharacterUnit
        expect(ccu[2].code_point).to eq "9".ord
      end

      it "parses alternates" do
        parser = Parser.new("ab|c")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 2
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[1]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[0].size).to eq 2
        expect(parser.unit.alternates[1].size).to eq 1
      end

      it "parses something complex" do
        parser = Parser.new("(a|)*|[^^]|\\|v|[x-y]+")
        expect(parser.unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates.size).to eq 4
        expect(parser.unit.alternates[0]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[0].size).to eq 1
        expect(parser.unit.alternates[0][0]).to be_a Parser::MultiplicityUnit
        expect(parser.unit.alternates[0][0].min_count).to eq 0
        expect(parser.unit.alternates[0][0].max_count).to be_nil
        expect(parser.unit.alternates[0][0].unit).to be_a Parser::AlternatesUnit
        expect(parser.unit.alternates[0][0].unit.alternates.size).to eq 2
        expect(parser.unit.alternates[0][0].unit.alternates[0]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[0][0].unit.alternates[0].size).to eq 1
        expect(parser.unit.alternates[0][0].unit.alternates[0][0]).to be_a Parser::CharacterUnit
        expect(parser.unit.alternates[0][0].unit.alternates[1]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[0][0].unit.alternates[1].size).to eq 0
        expect(parser.unit.alternates[1]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[1].size).to eq 1
        expect(parser.unit.alternates[1][0]).to be_a Parser::CharacterClassUnit
        expect(parser.unit.alternates[1][0].negate).to be_truthy
        expect(parser.unit.alternates[1][0].size).to eq 1
        expect(parser.unit.alternates[1][0][0]).to be_a Parser::CharacterUnit
        expect(parser.unit.alternates[2]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[2].size).to eq 2
        expect(parser.unit.alternates[2][0]).to be_a Parser::CharacterUnit
        expect(parser.unit.alternates[2][0].code_point).to eq "|".ord
        expect(parser.unit.alternates[2][1]).to be_a Parser::CharacterUnit
        expect(parser.unit.alternates[2][1].code_point).to eq "v".ord
        expect(parser.unit.alternates[3]).to be_a Parser::SequenceUnit
        expect(parser.unit.alternates[3].size).to eq 1
        expect(parser.unit.alternates[3][0]).to be_a Parser::MultiplicityUnit
        expect(parser.unit.alternates[3][0].min_count).to eq 1
        expect(parser.unit.alternates[3][0].max_count).to be_nil
        expect(parser.unit.alternates[3][0].unit).to be_a Parser::CharacterClassUnit
        expect(parser.unit.alternates[3][0].unit.size).to eq 1
        expect(parser.unit.alternates[3][0].unit[0]).to be_a Parser::CharacterRangeUnit
        expect(parser.unit.alternates[3][0].unit[0].min_code_point).to eq "x".ord
        expect(parser.unit.alternates[3][0].unit[0].max_code_point).to eq "y".ord
      end

    end
  end
end
