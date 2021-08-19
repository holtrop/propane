module Imbecile

  class FA

    attr_reader :start_state

    def initialize
      @start_state = State.new
    end

    def to_s
      chr = lambda do |value|
        if value < 32 || value > 127
          "{#{value}}"
        else
          value.chr
        end
      end
      rv = ""
      states = enumerate
      states.each do |state, id|
        accepts_s = state.accepts ? " #{state.accepts}" : ""
        rv += "#{id}#{accepts_s}:\n"
        state.transitions.each do |transition|
          if transition.nil?
            range_s = "nil"
          else
            range_s = chr[transition.code_point_range.first]
            if transition.code_point_range.size > 1
              range_s += "-" + chr[transition.code_point_range.last]
            end
          end
          accepts_s = transition.destination.accepts ? " #{transition.destination.accepts}" : ""
          rv += "  #{range_s} => #{states[transition.destination]}#{accepts_s}\n"
        end
      end
      rv
    end

    def enumerate
      @_enumerated ||=
        begin
          id = 0
          states = {}
          visit = lambda do |state|
            unless states.include?(state)
              states[state] = id
              id += 1
              state.transitions.each do |transition|
                visit[transition.destination]
              end
            end
          end
          visit[@start_state]
          states
        end
    end

  end

end
