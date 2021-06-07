class TestLexer
  def initialize(token_dfa)
    @token_dfa = token_dfa
  end

  def lex(input)
    input_chars = input.chars
    output = []
    while lexed_token = lex_token(input_chars)
      output << lexed_token
      input_chars.slice!(0, lexed_token[1].size)
    end
    unless input_chars.empty?
      raise "Unmatched input"
    end
    output
  end

  def lex_token(input_chars)
    return nil if input_chars.empty?
    s = ""
    current_state = @token_dfa.start_state
    last_accepts = nil
    input_chars.each_with_index do |input_char, index|
      if next_state = transition(current_state, input_char)
        current_state = next_state
        if current_state.accepts
          last_accepts = current_state.accepts
        end
        s += input_char
      else
        break
      end
    end
    if last_accepts
      [last_accepts, s]
    end
  end

  def transition(state, input_char)
    state.transitions.each do |transition|
      if transition.code_point_range.include?(input_char.ord)
        return transition.destination
      end
    end
    nil
  end
end

describe Imbecile do
end
